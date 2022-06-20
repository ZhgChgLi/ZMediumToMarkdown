$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class OLIParser < Parser
    attr_accessor :nextParser

    def self.isOLI(paragraph)
        if paragraph.nil? 
            false
        else
            paragraph.type == "OLI"
        end
    end

    def parse(paragraph)
        if OLIParser.isOLI(paragraph)
            "#{paragraph.oliIndex}. #{paragraph.text}"
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
