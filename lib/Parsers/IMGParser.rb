$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'
require 'open-uri'

class IMGParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        if paragraph.type == 'IMG'
            dir = ZMediumFetcher.getOutputDirName()
            localURL = "#{paragraph.postID}/#{paragraph.metadata.id}"

            Dir.mkdir("#{dir}/#{paragraph.postID}") unless File.exists?("#{dir}/#{paragraph.postID}")
            File.write("#{dir}/#{localURL}", open("https://miro.medium.com/max/1400/#{paragraph.metadata.id}").read, {mode: 'wb'})
            
            "![#{paragraph.text}](./#{localURL} \"#{paragraph.text}\")"
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
