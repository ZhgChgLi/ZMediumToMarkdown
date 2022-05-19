$lib = File.expand_path('../', File.dirname(__FILE__))


require 'open-uri'

class MarkupParser
    attr_accessor :markups, :text, :chars

    class MarkupTextChar
        attr_accessor :index, :char
        def initialize(index, char)
            @index = index
            @char = char
        end
    end

    def initialize(text, markups)
        @text = text
        @markups = markups

        chars = []
        chars.append(MarkupTextChar.new(0, ''.encode('utf-16')))
        index = 1
        text.encode('utf-16').chars.each do |char|
            chars.append(MarkupTextChar.new(index, char))
            index += 1
        end
        

        @chars = chars
    end

    def parse()
        length = chars.length
        if markups.nil? || length == 0
            return text
        end

        markups.each do |markup|
            start_index = chars.index { |char| 
                char.index == markup.start
            }
            end_index = chars.index { |char| 
                char.index == markup.end
             }

            # if end_index.nil?
            #     puts text.encode('utf-16').length

            #     chars.each do |c|
            #         puts "#{c.index},#{c.char}"
            #     end

            #     puts text
            #     puts end_index
            #     puts markup.end
            #     puts length
            # end

            if markup.type == "EM"
                chars.insert(start_index,MarkupTextChar.new(nil, '_'.encode('utf-16')))
                chars.insert(end_index,MarkupTextChar.new(nil, '_'.encode('utf-16')))
            elsif markup.type == "STRONG"
                chars.insert(start_index,MarkupTextChar.new(nil, '**'.encode('utf-16')))
                chars.insert(end_index,MarkupTextChar.new(nil, '**'.encode('utf-16')))
            elsif markup.type == "CODE"
                chars.insert(start_index,MarkupTextChar.new(nil, '`'.encode('utf-16')))
                chars.insert(end_index,MarkupTextChar.new(nil, '`'.encode('utf-16')))
            elsif markup.type == "A"
                chars.insert(start_index,MarkupTextChar.new(nil, '['.encode('utf-16')))
                chars.insert(end_index,MarkupTextChar.new(nil, "](#{markup.href})".encode('utf-16')))
            end
        end

        chars.map { |char| char.char }.join('').encode('UTF-8')
    end
end
