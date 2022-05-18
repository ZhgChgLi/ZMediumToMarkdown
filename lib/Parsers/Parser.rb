$lib = File.expand_path('../lib', File.dirname(__FILE__))

class Parser
    attr_accessor :nextParser
    def initialize(nextParser = nil)
        @nextParser = nextParser
    end

    def parse(paragraph)

    end
end