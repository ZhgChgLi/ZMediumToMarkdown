$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class PREParser < Parser
    attr_accessor :nextParser, :isForJekyll

    def initialize(isForJekyll)
        @isForJekyll = isForJekyll
    end

    def self.isPRE(paragraph)
        if paragraph.nil? 
            false
        else
            paragraph.type == "PRE"
        end
    end

    def parse(paragraph)
        if PREParser.isPRE(paragraph)
            
            lang = ""
            if !paragraph.codeBlockMetadata.nil?
                lang = paragraph.codeBlockMetadata.lang
            end

            result = "```#{lang}\n"
            
            paragraph.text.each_line do |p|
                result += p
            end

            result = result.chomp
            result += "\n```"

            result
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
