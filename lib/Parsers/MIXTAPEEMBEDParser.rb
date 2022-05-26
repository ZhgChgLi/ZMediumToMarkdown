$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class MIXTAPEEMBEDParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        if paragraph.type == 'MIXTAPE_EMBED'
            if !paragraph.mixtapeMetadata.nil? && !paragraph.mixtapeMetadata.href.nil?
                "\n[#{paragraph.text}](#{paragraph.mixtapeMetadata.href})"
            else
                "\n#{paragraph.text}"
            end
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
