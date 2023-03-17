$lib = File.expand_path('../', File.dirname(__FILE__))

require "Helper"
require "Parsers/Parser"
require 'Models/Paragraph'

class MIXTAPEEMBEDParser < Parser
    attr_accessor :nextParser, :isForJekyll
    
    def initialize(isForJekyll)
        @isForJekyll = isForJekyll
    end

    def parse(paragraph)
        if paragraph.type == 'MIXTAPE_EMBED'
            if !paragraph.mixtapeMetadata.nil? && !paragraph.mixtapeMetadata.href.nil?
                ogImageURL = Helper.fetchOGImage(paragraph.mixtapeMetadata.href)
                if !ogImageURL.nil? && ogImageURL != ""
                    jekyllOpen = ""
                    if isForJekyll
                        jekyllOpen = "{:target=\"_blank\"}"
                    end
                    "\r\n\r\n[![](#{ogImageURL})](#{paragraph.mixtapeMetadata.href})#{jekyllOpen}\r\n\r\n"
                else
                    "\n#{paragraph.text}"
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
