$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class CodeBlockParser < Parser
    attr_accessor :nextParser

    def self.getTypeString()
        'CODE_BLOCK'
    end

    def parse(paragraph)
        if paragraph.type == CodeBlockParser.getTypeString()
            "```\n#{paragraph.text}\n```"
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end