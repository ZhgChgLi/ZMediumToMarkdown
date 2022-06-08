$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class CodeBlockParser < Parser
    attr_accessor :nextParser

    def self.getTypeString()
        'CODE_BLOCK'
    end

    def self.isCodeBlock(paragraph)
        if paragraph.nil? 
            false
        else
            paragraph.type == CodeBlockParser.getTypeString()
        end
    end

    def parse(paragraph)
        if CodeBlockParser.isCodeBlock(paragraph)
            "```\n#{paragraph.text}\n```"
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end