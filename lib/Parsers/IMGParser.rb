$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'
require 'open-uri'

class IMGParser < Parser
    attr_accessor :nextParser, :username
    def parse(paragraph)
        if paragraph.type == 'IMG'
            dir = ZMediumFetcher.getOutputDirName()
            if !username.nil?
                dir = "#{dir}/#{username}"
                Dir.mkdir("#{dir}") unless File.exists?("#{dir}")
            end
            localURL = "#{paragraph.postID}/#{paragraph.metadata.id}"

            Dir.mkdir("#{dir}/#{paragraph.postID}") unless File.exists?("#{dir}/#{paragraph.postID}")
            
            imageURL = "https://miro.medium.com/max/1400/#{paragraph.metadata.id}"
            begin
                imageResponse = open(imageURL)
                File.write("#{dir}/#{localURL}", imageResponse.read, {mode: 'wb'})
                "![#{paragraph.text}](./#{localURL} \"#{paragraph.text}\")"
            rescue
                "![#{paragraph.text}](./#{imageURL} \"#{paragraph.text}\")"
            end
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
