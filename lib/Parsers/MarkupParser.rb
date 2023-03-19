$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Models/Paragraph'
require 'Parsers/MarkupStyleRender'
require 'nokogiri'
require 'securerandom'
require 'User'

class MarkupParser
    attr_accessor :body, :paragraph, :isForJekyll, :usersPostURLs
    
    def initialize(paragraph, isForJekyll)
        @paragraph = paragraph
        @isForJekyll = isForJekyll
    end

    def parse()
        result = paragraph.text
        if !paragraph.markups.nil? && paragraph.markups.length > 0
            markupRender = MarkupStyleRender.new(paragraph, isForJekyll)
            markupRender.usersPostURLs = usersPostURLs
            begin
                result = markupRender.parse()
            rescue => e
                puts e.backtrace
                Helper.makeWarningText("Error occurred during render markup text, please help to open an issue on github.")
            end
        end
        
        if isForJekyll
            result = Helper.escapeHTML(result)
        end

        result
    end
end
