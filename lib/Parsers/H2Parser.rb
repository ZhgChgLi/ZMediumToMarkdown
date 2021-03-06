$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class H2Parser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        if paragraph.type == 'H2'
            "## #{paragraph.text}"
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
