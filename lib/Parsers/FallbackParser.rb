$lib = File.expand_path('../', File.dirname(__FILE__))

require "Helper"
require "Parsers/Parser"
require 'Models/Paragraph'

class FallbackParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        Helper.makeWarningText("Undefined Paragraph Type: #{paragraph.type}, will treat as plain text temporarily.")
        "#{paragraph.text}"
    end
end