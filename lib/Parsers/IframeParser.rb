$lib = File.expand_path('../', File.dirname(__FILE__))

require 'uri'

require "Request"
require "Parsers/Parser"
require 'Models/Paragraph'
require 'nokogiri'
require 'Helper'
require 'ImageDownloader'
require 'PathPolicy'

class IframeParser < Parser
    attr_accessor :nextParser, :pathPolicy, :isForJekyll

    def initialize(isForJekyll)
        @isForJekyll = isForJekyll
    end

    def parse(paragraph)
        if paragraph.type == 'IFRAME'
            
            if !paragraph.iframe.src.nil? && paragraph.iframe.src != ""
                url = paragraph.iframe.src
            else
                url = "https://medium.com/media/#{paragraph.iframe.id}"
            end

            result = "[#{paragraph.iframe.title}](#{url})"

            if !url[/(www\.youtube\.com)/].nil?
                # is youtube
                youtubeURL = URI(URI.decode(url)).query
                params = URI::decode_www_form(youtubeURL).to_h
                
                if !params["image"].nil? && !params["url"].nil?

                    fileName = "#{paragraph.name}_#{URI(params["image"]).path.split("/").last}" #21de_default.jpg

                    imageURL = params["image"]
                    imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(nil), paragraph.postID)
                    absolutePath = imagePathPolicy.getAbsolutePath(fileName)
                    title = paragraph.iframe.title
                    if title.nil? or title == ""
                        title = "Youtube"
                    end

                    if  ImageDownloader.download(absolutePath, imageURL)
                        relativePath = "#{pathPolicy.getRelativePath(nil)}/#{imagePathPolicy.getRelativePath(fileName)}"
                        if isForJekyll
                            result = "\r\n\r\n[![#{title}](/#{relativePath} \"#{title}\")](#{params["url"]})\r\n\r\n"
                        else
                            result = "\r\n\r\n[![#{title}](#{relativePath} \"#{title}\")](#{params["url"]})\r\n\r\n"
                        end
                    else
                        result = "\r\n[#{title}](#{params["url"]})\r\n"
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
                    lang = gistHTML.search('table').first['data-tagsearch-lang'].downcase
                    if isForJekyll and lang == "objective-c"
                        lang = "objectivec"
                    end
                    gistHTML.search('a').each do |a|
                        if a.text == 'view raw'
                            gistRAW = Request.body(Request.URL(a['href']))

                            result = "```#{lang}\n"

                            result += gistRAW.chomp
                            
                            result += "\n```"
                        end
                    end
                else
                    ogURL = url
                    if !url[/(cdn\.embedly\.com)/].nil?
                        params = URI::decode_www_form(URI(URI.decode(url)).query).to_h
                        if !params["url"].nil?
                            ogURL = params["url"]
                        end
                    end
                    ogImageURL = Helper.fetchOGImage(ogURL)

                    title = paragraph.iframe.title
                    if title.nil? or title == ""
                        title = Helper.escapeMarkdown(ogURL)
                    end
                    
                    if !ogImageURL.nil?
                        result = "\r\n\r\n[![#{title}](#{ogImageURL} \"#{title}\")](#{ogURL})\r\n\r\n"
                    else
                        result = "[#{title}](#{ogURL})"
                    end
                end
            end

            result
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
