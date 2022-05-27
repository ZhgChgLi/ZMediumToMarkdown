$lib = File.expand_path('../', File.dirname(__FILE__))

require 'uri'

require "Request"
require "Parsers/Parser"
require 'Models/Paragraph'
require 'nokogiri'

require 'ImageDownloader'
require 'PathPolicy'

class IframeParser < Parser
    attr_accessor :nextParser, :pathPolicy
    def parse(paragraph)
        if paragraph.type == 'IFRAME'
            if !paragraph.iframe.src.nil? && paragraph.iframe.src != ""
                url = paragraph.iframe.src
            else
                url = "https://medium.com/media/#{paragraph.iframe.id}"
            end

            if !url[/(www\.youtube\.com)/].nil?
                # is youtube
                youtubeURL = URI(URI.decode(url)).query
                params = URI::decode_www_form(youtubeURL).to_h
                if !params["image"].nil? && !params["url"].nil?

                    fileName = "#{paragraph.name}_#{URI(params["image"]).path.split("/").last}" #21de_default.jpg

                    imageURL = params["image"]
                    imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(nil), paragraph.postID)
                    absolutePath = imagePathPolicy.getAbsolutePath(fileName)
                    
                    if  ImageDownloader.download(absolutePath, imageURL)
                        relativePath = "#{pathPolicy.getRelativePath(nil)}/#{imagePathPolicy.getRelativePath(fileName)}"
                        result = "\n[![YouTube](#{relativePath} \"YouTube\")](#{params["url"]})"
                    else
                        result = "\n[YouTube](#{params["url"]})"
                    end
                end
            else
                html = Request.html(Request.URL(url))
                src = html.search('script').first.attribute('src')
                result = nil
                if !src.to_s[/^(https\:\/\/gist\.github\.com)/].nil?
                    # is gist
                    gist = Request.body(Request.URL(src)).scan(/(document\.write\('){1}(.*)(\)){1}/)[1][1]
                    gist.gsub! '\n', ''
                    gist.gsub! '\"', '"'
                    gist.gsub! '<\/', '</'
                    gistHTML = Nokogiri::HTML(gist)
                    lang = gistHTML.search('table').first['data-tagsearch-lang']
                    gistHTML.search('a').each do |a|
                        if a.text == 'view raw'
                            gistRAW = Request.body(Request.URL(a['href']))
                            result = "```#{lang}\n#{gistRAW}\n```"
                        end
                    end
                end
            end

            if result.nil?
                "[#{paragraph.iframe.title}](#{url})"
            else
                result
            end
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
