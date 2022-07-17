$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class CodeBlockParser < Parser
    attr_accessor :nextParser, :isForJekyll

    def initialize(isForJekyll)
        @isForJekyll = isForJekyll
    end

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
            result = "```\n"
            
            result += paragraph.text.chomp

            result += "\n```"
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end