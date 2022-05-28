$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Models/Paragraph'
require 'reverse_markdown'
require 'nokogiri'

class MarkupParser
    attr_accessor :body, :paragraph

    def initialize(html, paragraph)
        @body = html.search("body").first
        @paragraph = paragraph
    end

    def parse()
        result = paragraph.text
        if paragraph.hasMarkup
            p = body.at_css("##{paragraph.name}")
            if !p.nil?
                result = ReverseMarkdown.convert p.inner_html
            end
        end

        result
    end
end
