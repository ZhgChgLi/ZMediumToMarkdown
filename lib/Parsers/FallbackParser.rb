$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

class FallbackParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        puts paragraph.type
        "#{paragraph.text}"
    end
end