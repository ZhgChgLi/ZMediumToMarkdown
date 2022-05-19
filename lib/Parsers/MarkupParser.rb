$lib = File.expand_path('../', File.dirname(__FILE__))


require 'open-uri'

class MarkupParser
    attr_accessor :markups, :utf8Text, :utf16Chars

    class UTF16Char
        attr_accessor :utf16Char
        def initialize(utf16Char)
            @utf16Char = utf16Char
        end
    end
    
    class OriginUTF16Char < UTF16Char
        attr_accessor :index
        def initialize(index, utf16Char)
            @index = index
            @utf16Char = utf16Char
        end
    end
    
    class MarkupUTF16Char < UTF16Char
        def initialize(utf16Char)
            @utf16Char = utf16Char
        end
    end

    def initialize(utf8Text, markups)
        @utf8Text = utf8Text
        @markups = markups

        utf16Chars = []
        index = 0
        utf8Text.encode('utf-16').chars.each do |char|
            utf16Chars.append(OriginUTF16Char.new(index, char))
            index += 1
        end
        
        @utf16Chars = utf16Chars
    end

    def inserStringIntoResultChars(index, utf8String, resultChars)
        utf8String.encode("utf-16").chars.each do |char|
            resultChars.insert(index, MarkupUTF16Char.new(char))
            index += 1
        end

        resultChars
    end

    def parse()
        resultChars = utf16Chars.dup
        length = resultChars.length
        
        if markups.nil? || markups.length == 0
            return utf8Text
        end
        
        markups.each do |markup|
            
            start_index = resultChars.index { |char|
                (char.is_a? OriginUTF16Char) && char.index == markup.start
            } + 1

            end_index = resultChars.index { |char|
                e = markup.end == length ? markup.end - 1 : markup.end
                (char.is_a? OriginUTF16Char) && char.index == e
            } + 3
            
            if markup.type == "EM"
                resultChars = inserStringIntoResultChars(start_index, '_', resultChars)
                resultChars = inserStringIntoResultChars(end_index, '_', resultChars)
            elsif markup.type == "STRONG"
                resultChars = inserStringIntoResultChars(start_index, '**', resultChars)
                resultChars = inserStringIntoResultChars(end_index, '**', resultChars)
            elsif markup.type == "CODE"
                resultChars = inserStringIntoResultChars(start_index, '`', resultChars)
                resultChars = inserStringIntoResultChars(end_index, '`', resultChars)
            elsif markup.type == "A"
                resultChars = inserStringIntoResultChars(start_index, '[', resultChars)
                resultChars = inserStringIntoResultChars(end_index,"](#{markup.href})", resultChars)
            end
        end

        return resultChars.map { |char| char.utf16Char }.join.encode('utf-8').gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
    end
end
