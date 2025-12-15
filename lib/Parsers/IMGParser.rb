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

            miro_host = ENV.fetch('MIRO_MEDIUM_HOST', 'https://miro.medium.com')
            imageURL = "#{miro_host}/#{fileName}"

            imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(paragraph.postID), pathPolicy.getRelativePath(paragraph.postID))
            absolutePath = imagePathPolicy.getAbsolutePath(fileName)
            
            result = ""
            alt = ""

            if  ImageDownloader.download(absolutePath, imageURL)
                relativePath = imagePathPolicy.getRelativePath(fileName)
                if isForJekyll
                    result = "\r\n\r\n![#{paragraph.text}](/#{relativePath}#{alt})\r\n\r\n"
                else
                    result = "\r\n\r\n![#{paragraph.text}](#{relativePath}#{alt})\r\n\r\n"
                end
            else
                result = "\r\n\r\n![#{paragraph.text}](#{imageURL}#{alt})\r\n\r\n"
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
