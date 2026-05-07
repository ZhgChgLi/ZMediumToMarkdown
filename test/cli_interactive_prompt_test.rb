require_relative 'test_helper'
require 'stringio'

# Verifies the interactive cookie prompt does NOT deadlock the CLI when
# the user follows the cookie banner instructions (open Chrome, copy
# cookies) but then walks away / closes the browser / loses focus before
# coming back to paste.

# A stdin-shaped IO that blocks on `gets` forever — used to drive the
# Timeout::Error branch.
class BlockingInput
    def gets
        sleep 60
    end

    def tty?
        true
    end
end

# A stdin that lets us drive a sequence of `gets` returns plus a tty? flag.
class FakeInput
    def initialize(lines, tty: true)
        @lines = lines.dup
        @tty = tty
    end

    def gets
        @lines.shift
    end

    def tty?
        @tty
    end
end

class CLIInteractivePromptTest < Minitest::Test
    def setup
        $cookies = {}
        @err = StringIO.new
    end

    # --- gating: when do we even attempt to prompt? -----------------------

    def test_skips_prompt_when_stdin_is_not_a_tty
        input = FakeInput.new([], tty: false)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 0.1)
        assert_empty $cookies
        refute_match(/sid:/, @err.string)
    end

    def test_skips_prompt_when_cookies_already_present
        $cookies['sid'] = 'existing'
        input = FakeInput.new([], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 0.1)
        assert_equal 'existing', $cookies['sid']
        refute_match(/sid:/, @err.string)
    end

    def test_skips_prompt_for_non_medium_invocations
        # `--version` / `--clean` shouldn't even ask about cookies.
        input = FakeInput.new(["whatever\n", "whatever\n"], tty: true)
        CLI.promptForCookiesIfTTY({ version: true },
                                  input: input, errput: @err, timeout: 0.1, interactive: true)
        assert_empty $cookies
    end

    # --- happy paths ------------------------------------------------------

    def test_paste_both_sid_and_uid_populates_cookie_jar
        input = FakeInput.new(["my_sid_value\n", "my_uid_value\n"], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 1)
        assert_equal 'my_sid_value', $cookies['sid']
        assert_equal 'my_uid_value', $cookies['uid']
    end

    def test_strips_surrounding_whitespace_from_pasted_values
        input = FakeInput.new(["  sid_with_spaces  \n", "\tuid_with_tab\t\n"], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 1)
        assert_equal 'sid_with_spaces', $cookies['sid']
        assert_equal 'uid_with_tab', $cookies['uid']
    end

    def test_paste_only_sid_does_not_set_uid
        input = FakeInput.new(["just_sid\n", "\n"], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 1)
        assert_equal 'just_sid', $cookies['sid']
        assert_nil $cookies['uid']
    end

    def test_empty_lines_skip_both_cookies
        input = FakeInput.new(["\n", "\n"], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 1)
        assert_nil $cookies['sid']
        assert_nil $cookies['uid']
    end

    # --- the bug the user reported: Chrome closed before pasting --------

    def test_does_not_hang_when_user_closes_terminal_before_pasting_sid
        # gets returning nil on the first read simulates EOF, which is what
        # happens when the controlling terminal is closed.
        input = FakeInput.new([nil, nil], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 1)
        assert_nil $cookies['sid']
        assert_nil $cookies['uid']
    end

    def test_does_not_hang_when_user_closes_terminal_after_pasting_sid
        input = FakeInput.new(["good_sid\n", nil], tty: true)
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 1)
        assert_equal 'good_sid', $cookies['sid']
        assert_nil $cookies['uid']
    end

    def test_falls_back_to_no_cookies_when_input_blocks_past_timeout
        # Simulates: user opens Chrome to copy cookies, gets distracted
        # (closes the window, switches workspace, walks away). Without a
        # timeout the CLI would block on `gets` forever.
        input = BlockingInput.new
        elapsed = Time.now
        CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                  input: input, errput: @err, timeout: 0.05)
        assert_operator (Time.now - elapsed), :<, 5,
                        'Timeout must trigger quickly even when input never arrives'
        assert_match(/timeout after 0\.05s/, @err.string)
        assert_nil $cookies['sid']
        assert_nil $cookies['uid']
    end

    def test_propagates_ctrl_c_so_the_program_exits_cleanly
        input = Object.new
        def input.gets
            raise Interrupt
        end
        def input.tty?
            true
        end

        assert_raises(Interrupt) do
            CLI.promptForCookiesIfTTY({ postURL: 'https://medium.com/p/abc' },
                                      input: input, errput: @err, timeout: 1)
        end
        assert_match(/Aborted/, @err.string)
    end
end
