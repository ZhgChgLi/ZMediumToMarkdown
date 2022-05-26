$lib = File.expand_path('../', File.dirname(__FILE__))

require 'uri'

require "Request"
require "Parsers/Parser"
require 'Models/Paragraph'
require 'nokogiri'

class IframeParser < Parser
    attr_accessor :nextParser, :username
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
                    filePath = URI(params["image"]).path.split("/").last
                    dir = ZMediumFetcher.getOutputDirName()
                    if !username.nil?
                        dir = "#{dir}/#{username}"
                        Dir.mkdir("#{dir}") unless File.exists?("#{dir}")
                    end
                    localURL = "#{paragraph.postID}/#{paragraph.name}_#{filePath}"
        
                    Dir.mkdir("#{dir}/#{paragraph.postID}") unless File.exists?("#{dir}/#{paragraph.postID}")

                    begin
                        imageResponse = open(params["image"])
                        File.write("#{dir}/#{localURL}", imageResponse.read, {mode: 'wb'})
                        result = "[![YouTube](./#{localURL} \"YouTube\")](#{params["url"]})"
                    rescue
                        result = "[YouTube](#{params["url"]})"
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
