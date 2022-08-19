$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class BQParser < Parser
    attr_accessor :nextParser

    def self.isBQ(paragraph)
        if paragraph.nil? 
            false
        else
            paragraph.type == "BQ"
        end
    end

    def parse(paragraph)
        if BQParser.isBQ(paragraph)
            result = "\r\n\r\n"
            paragraph.text.each_line do |p|
                result += "> #{p} \n\n"
            end
            result += "\r\n\r\n"
            result
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
