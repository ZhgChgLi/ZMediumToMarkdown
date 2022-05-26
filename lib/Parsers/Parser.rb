$lib = File.expand_path('../lib', File.dirname(__FILE__))

class Parser
    attr_accessor :nextParser
    def initialize()
        @nextParser = nil
    end

    def parse(paragraph)

    end

    def setNext(parser)
        @nextParser = parser
    end
end