$lib = File.expand_path('../', File.dirname(__FILE__))

require "Helper"
require "Parsers/Parser"
require 'Models/Paragraph'

class MIXTAPEEMBEDParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        if paragraph.type == 'MIXTAPE_EMBED'
            if !paragraph.mixtapeMetadata.nil? && !paragraph.mixtapeMetadata.href.nil?
                ogImageURL = Helper.fetchOGImage(paragraph.mixtapeMetadata.href)
                if !ogImageURL.nil?
                    "\r\n\r\n[![#{paragraph.text}](#{ogImageURL} \"#{paragraph.text}\")](#{paragraph.mixtapeMetadata.href})\r\n\r\n"
                else
                    "\n[#{paragraph.text}](#{paragraph.mixtapeMetadata.href})"
                end
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
