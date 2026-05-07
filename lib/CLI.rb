require 'optparse'
require 'fileutils'
require 'timeout'

require 'ZMediumFetcher'
require 'Helper'
require 'PathPolicy'
require 'Request'

# All CLI-side concerns for the `ZMediumToMarkdown` executable. Pulled out
# of bin/ so it can be exercised by unit tests without spawning processes.
module CLI
    COOKIE_SETUP_URL = 'https://zhgchg.li/posts/zrealm-dev/medium-api-%E7%88%AC%E5%8F%96%E8%B3%87%E6%96%99%E8%88%87%E7%AA%81%E7%A0%B4-cloudflare-%E9%98%B2%E8%AD%B7-%E5%AE%8C%E6%95%B4-graphql-%E6%93%8D%E4%BD%9C%E6%95%99%E5%AD%B8-88f0fb935120/'.freeze

    # How long we'll wait for the user to paste each cookie before giving
    # up and continuing without them. The timeout matters because users
    # commonly walk away to Chrome to grab cookies and might never come
    # back (closed window, switched apps, lost focus) — without a
    # timeout the CLI would block on $stdin.gets forever.
    INTERACTIVE_PROMPT_TIMEOUT_SECONDS = 120

    COOKIE_WARNING_BANNER = <<~BANNER.strip.freeze
      ──────────────────────────────────────────────────────────────────────
      ⚠  No Medium login cookie detected.

      Medium's Cloudflare layer often blocks unauthenticated requests
      (especially from cloud runners / CI / Docker), and paywalled posts
      can't be fetched in full. Strongly recommended to provide cookies:

        ZMediumToMarkdown -p URL -s YOUR_SID -d YOUR_UID
        # or via env (less likely to leak into shell history):
        MEDIUM_COOKIE_SID=... MEDIUM_COOKIE_UID=... ZMediumToMarkdown -p URL

      How to get sid / uid:
        1. Open https://medium.com in a browser, logged in.
        2. DevTools -> Application/Storage -> Cookies -> medium.com.
        3. Copy the values of the `sid` and `uid` cookies.

      Background and a Cloudflare Worker proxy workaround:
        #{COOKIE_SETUP_URL}
      ──────────────────────────────────────────────────────────────────────
    BANNER

    module_function

    def main(argv, output: $stdout, errput: $stderr, input: $stdin, cwd: ENV['PWD'] || ::Dir.pwd)
        argv = argv.dup
        argv << '-h' if argv.empty?

        options = parseArgs(argv, errput: errput)
        loadCookiesFromEnv!
        warnIfNoCookies(options, errput: errput)
        promptForCookiesIfTTY(options, input: input, errput: errput)
        run(options, cwd, output: output)
    end

    def parseArgs(argv, errput: $stderr)
        options = {}
        parser = OptionParser.new do |opts|
            opts.banner = "Usage: ZMediumToMarkdown [options]"

            opts.on('-s', '--cookie_sid SID', 'Medium logged-in cookie sid value (or set $MEDIUM_COOKIE_SID)') do |v|
                $cookies['sid'] = v
            end

            opts.on('-d', '--cookie_uid UID', 'Medium logged-in cookie uid value (or set $MEDIUM_COOKIE_UID)') do |v|
                $cookies['uid'] = v
            end

            opts.on('-u', '--username USERNAME', 'Download all posts from a Medium username') do |v|
                options[:username] = v
            end

            opts.on('-p', '--postURL POST_URL', 'Download a single post URL') do |v|
                options[:postURL] = v
            end

            opts.on('--jekyll', 'Emit Jekyll-friendly output (combine with -u or -p)') do
                options[:jekyll] = true
            end

            opts.on('-j', '--jekyllUsername USERNAME', 'DEPRECATED: use `--jekyll -u USERNAME`') do |v|
                options[:username] = v
                options[:jekyll] = true
                errput.puts '[deprecated] -j/--jekyllUsername is deprecated; use `--jekyll -u USERNAME`.'
            end

            opts.on('-k', '--jekyllPostURL POST_URL', 'DEPRECATED: use `--jekyll -p POST_URL`') do |v|
                options[:postURL] = v
                options[:jekyll] = true
                errput.puts '[deprecated] -k/--jekyllPostURL is deprecated; use `--jekyll -p POST_URL`.'
            end

            opts.on('-n', '--new', 'Update to latest version') do
                options[:upgrade] = true
            end

            opts.on('-c', '--clean', 'Remove all downloaded posts data under cwd') do
                options[:clean] = true
            end

            opts.on('-v', '--version', 'Print current ZMediumToMarkdown version') do
                options[:version] = true
            end

            opts.on('-h', '--help', 'Show this help message') do
                options[:help] = opts.to_s
            end
        end

        parser.parse!(argv)
        options
    end

    def loadCookiesFromEnv!
        $cookies['sid'] = ENV['MEDIUM_COOKIE_SID'] if cookieMissing?('sid') && !ENV['MEDIUM_COOKIE_SID'].to_s.empty?
        $cookies['uid'] = ENV['MEDIUM_COOKIE_UID'] if cookieMissing?('uid') && !ENV['MEDIUM_COOKIE_UID'].to_s.empty?
    end

    def cookieMissing?(name)
        return true unless defined?($cookies) && $cookies.is_a?(Hash)
        $cookies[name].to_s.empty?
    end

    def cookiesPresent?
        !cookieMissing?('sid') || !cookieMissing?('uid')
    end

    # Only warn when the invocation will actually hit Medium - skip for
    # --version, --clean, --help, --new.
    def warnIfNoCookies(options, errput: $stderr)
        return if cookiesPresent?
        return unless willHitMedium?(options)
        errput.puts COOKIE_WARNING_BANNER
    end

    def willHitMedium?(options)
        !options[:postURL].nil? || !options[:username].nil?
    end

    # Offer an inline paste flow for sid / uid right after the warning
    # banner, but ONLY when stdin is a real terminal — never when running
    # under Docker, GitHub Actions, cron, or any other piped invocation.
    #
    # Each line read is wrapped in Timeout so the CLI doesn't deadlock
    # when the user (very commonly) tabs away to Chrome to copy cookies
    # and then closes the browser / their terminal / loses focus before
    # coming back. EOF (Ctrl-D), empty input, and timeout all fall
    # through to the existing "no cookies, fail loudly later" behaviour.
    def promptForCookiesIfTTY(options, input: $stdin, errput: $stderr, timeout: INTERACTIVE_PROMPT_TIMEOUT_SECONDS, interactive: nil)
        return if cookiesPresent?
        return unless willHitMedium?(options)

        effective_interactive = interactive.nil? ? input.respond_to?(:tty?) && input.tty? : interactive
        return unless effective_interactive

        errput.puts ""
        errput.puts "You can paste cookies now (or press Enter / Ctrl-D to skip — we'll continue without them):"

        sid = readCookieLine(input, errput: errput, prompt: "  sid: ", timeout: timeout)
        $cookies['sid'] = sid unless sid.nil?

        uid = readCookieLine(input, errput: errput, prompt: "  uid: ", timeout: timeout)
        $cookies['uid'] = uid unless uid.nil?
    end

    # Returns the trimmed line, or nil for empty / EOF / timeout.
    # Re-raises Interrupt so Ctrl-C aborts the whole program cleanly.
    def readCookieLine(input, errput:, prompt:, timeout:)
        errput.print prompt
        errput.flush if errput.respond_to?(:flush)

        line = Timeout.timeout(timeout) { input.gets }
        return nil if line.nil? # EOF (Ctrl-D)

        trimmed = line.strip
        trimmed.empty? ? nil : trimmed
    rescue Timeout::Error
        errput.puts ""
        errput.puts "[timeout after #{timeout}s] Continuing without cookies."
        nil
    rescue Interrupt
        errput.puts ""
        errput.puts "Aborted."
        raise
    end

    def run(options, cwd, output: $stdout)
        if options[:help]
            output.puts options[:help]
            return
        end

        if options[:version]
            output.puts "Version:#{Helper.getLocalVersion()}"
            Helper.printNewVersionMessageIfExists()
            return
        end

        if options[:clean]
            outputFilePath = PathPolicy.new(cwd, "")
            FileUtils.rm_rf(Dir[outputFilePath.getAbsolutePath(nil)])
            output.puts "All downloaded posts data has been removed."
            Helper.printNewVersionMessageIfExists()
            return
        end

        if options[:upgrade]
            remote = Helper.getRemoteVersionFromGithub()
            local  = Helper.getLocalVersion()
            if remote && local && remote > local
                Helper.downloadLatestVersion()
            else
                output.puts "You're using the latest version :)"
            end
            return
        end

        return unless willHitMedium?(options)

        fetcher = ZMediumFetcher.new
        fetcher.isForJekyll = options[:jekyll] == true

        targetPolicy = pathPolicyFor(cwd, fetcher.isForJekyll)

        if options[:postURL]
            fetcher.downloadPost(options[:postURL], targetPolicy, nil)
        elsif options[:username]
            fetcher.downloadPostsByUsername(options[:username], targetPolicy)
        end

        Helper.printNewVersionMessageIfExists()
    end

    # Jekyll mode writes into the cwd (so files land in `_posts/...` and
    # `assets/...` of an existing Jekyll site). Plain mode nests under
    # `Output/` to keep the user's cwd tidy.
    def pathPolicyFor(cwd, isForJekyll)
        if isForJekyll
            PathPolicy.new(cwd, "")
        else
            PathPolicy.new("#{cwd}/Output", "Output")
        end
    end
end
