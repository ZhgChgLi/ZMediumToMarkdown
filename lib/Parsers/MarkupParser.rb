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
        def initialize(utf8Char)
            @utf16Char = utf8Char.encode('utf-16')
        end
    end

    def initialize(utf8Text, markups)
        @utf8Text = utf8Text
        @markups = markups

        utf16Chars = []
        utf16Chars.append(OriginUTF16Char.new(0, ''.encode('utf-16')))
        index = 1
        utf8Text.encode('utf-16').chars.each do |char|
            utf16Chars.append(OriginUTF16Char.new(index, char))
            index += 1
        end
        
        @utf16Chars = utf16Chars
    end

    def parse()
        resultChars = utf16Chars.dup
        length = resultChars.length - 1
        
        if markups.nil? || length == 0
            return utf8Text
        end
        
        markups.each do |markup|
            start_index = resultChars.index { |char|
                (char.is_a? OriginUTF16Char) && char.index == markup.start
            }
            end_index = resultChars.index { |char|
                (char.is_a? OriginUTF16Char) && char.index == markup.end
             }
            
            if end_index.nil?
                puts end_index
                puts length
                puts markup.end
            end

            if markup.type == "EM"
                resultChars.insert(start_index,MarkupUTF16Char.new('_'))
                resultChars.insert(end_index,MarkupUTF16Char.new('_'))
            elsif markup.type == "STRONG"
                resultChars.insert(start_index,MarkupUTF16Char.new('**'))
                resultChars.insert(end_index,MarkupUTF16Char.new('**'))
            elsif markup.type == "CODE"
                resultChars.insert(start_index,MarkupUTF16Char.new('`'))
                resultChars.insert(end_index,MarkupUTF16Char.new('`'))
            elsif markup.type == "A"
                resultChars.insert(start_index,MarkupUTF16Char.new('['))
                resultChars.insert(end_index,MarkupUTF16Char.new("](#{markup.href})"))
            end
        end

        resultChars.map { |char| char.utf16Char }.join('').encode('UTF-8')
    end
end
