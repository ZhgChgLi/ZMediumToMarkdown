$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

require 'ImageDownloader'
require 'PathPolicy'

class IMGParser < Parser
    attr_accessor :nextParser, :pathPolicy, :isForJekyll
    
    def initialize(isForJekyll)
        @isForJekyll = isForJekyll
    end

    def parse(paragraph)
        if paragraph.type == 'IMG'

            fileName = paragraph.metadata.id #d*fsafwfe.jpg

            imageURL = "https://miro.medium.com/max/1400/#{paragraph.metadata.id}"

            imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(nil), paragraph.postID)
            absolutePath = imagePathPolicy.getAbsolutePath(fileName)
            
            result = ""

            if  ImageDownloader.download(absolutePath, imageURL)
                relativePath = "#{pathPolicy.getRelativePath(nil)}/#{imagePathPolicy.getRelativePath(fileName)}"
                if isForJekyll
                    result = "\r\n![#{paragraph.orgText}](/#{relativePath} \"#{paragraph.orgText}\")\r\n"
                else
                    result = "\r\n![#{paragraph.orgText}](#{relativePath} \"#{paragraph.orgText}\")\r\n"
                end
            else
                result = "\r\n![#{paragraph.orgText}](#{imageURL} \"#{paragraph.orgText}\")\r\n"
            end

            if paragraph.text != ""
                result += "#{paragraph.text}\r\n"
            end

            result
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
