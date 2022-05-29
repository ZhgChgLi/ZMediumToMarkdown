$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class BQParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        if paragraph.type == 'BQ'
            result = ""
            paragraph.text.each_line do |p|
                result += "> #{p}"
            end
            result
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
