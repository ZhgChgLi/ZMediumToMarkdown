$lib = File.expand_path('../', File.dirname(__FILE__))

require 'uri'
require 'net/http'

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

        jekyllOpen = ""
        if isForJekyll
            jekyllOpen = "{:target=\"_blank\"}"
        end

        if paragraph.type == 'IFRAME'
            return unless paragraph.iframe
            if !paragraph.iframe.src.nil? && paragraph.iframe.src != ""
                url = paragraph.iframe.src
            else
                url = "https://medium.com/media/#{paragraph.iframe.id}"
            end

            result = "[#{paragraph.iframe.title}](#{url})#{jekyllOpen}"

            if !url[/(www\.youtube\.com)/].nil?
                # is youtube
                youtubeURL = URI(URI.decode(url)).query
                params = URI::decode_www_form(youtubeURL).to_h
                
                if !params["image"].nil? && !params["url"].nil?

                    fileName = "#{paragraph.name}_#{URI(params["image"]).path.split("/").last}" #21de_default.jpg

                    imageURL = params["image"]
                    imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(paragraph.postID), pathPolicy.getRelativePath(paragraph.postID))
                    absolutePath = imagePathPolicy.getAbsolutePath(fileName)
                    title = paragraph.iframe.title
                    if title.nil? or title == ""
                        title = "Youtube"
                    end

                    if  ImageDownloader.download(absolutePath, imageURL)
                        relativePath = imagePathPolicy.getRelativePath(fileName)
                        if isForJekyll
                            result = "\r\n\r\n[![#{title}](/#{relativePath} \"#{title}\")](#{params["url"]})#{jekyllOpen}\r\n\r\n"
                        else
                            result = "\r\n\r\n[![#{title}](#{relativePath} \"#{title}\")](#{params["url"]})#{jekyllOpen}\r\n\r\n"
                        end
                    else
                        result = "\r\n[#{title}](#{params["url"]})#{jekyllOpen}\r\n"
                    end
                end
            else
                html = Request.html(Request.URL(url))
                return "" unless html
                src = html.search('script').first
                srce = src.attribute('src') if src
                result = nil
                if !srce.to_s[/^(https\:\/\/gist\.github\.com)/].nil?
                    # is gist
                    gist = Request.body(Request.URL(srce)).scan(/(document\.write\('){1}(.*)(\)){1}/)[1][1]
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

                    twitterID = ogURL[/^(https\:\/\/twitter\.com\/){1}.+(\/){1}(\d+)/, 3]

                    if !twitterID.nil?
                        uri = URI("https://api.twitter.com/1.1/statuses/show.json?simple_quoted_tweet=true&include_entities=true&tweet_mode=extended&include_cards=1&id=#{twitterID}")
                        https = Net::HTTP.new(uri.host, uri.port)
                        https.use_ssl = true
                
                        request = Net::HTTP::Get.new(uri)
                        request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.17.375.766 Safari/537.36';
                        request['Authorization'] = 'Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA'; # twitter private api
                
                        response = https.request(request)
                        if response.code.to_i == 200
                            twitterObj = JSON.parse(response.read_body)
                            
                            fullText = twitterObj["full_text"]
                            twitterObj["entities"]["user_mentions"].each do |user_mention|
                                fullText = fullText.gsub(user_mention["screen_name"],"[#{user_mention["screen_name"]}](https://twitter.com/#{user_mention["screen_name"]})")
                            end
                            twitterObj["entities"]["urls"].each do |url|
                                fullText = fullText.gsub(url["url"],"[#{url["display_url"]}](#{url["expanded_url"]})")
                            end

                            createdAt = Time.parse(twitterObj["created_at"]).strftime('%Y-%m-%d %H:%M:%S')
                            result = "\n\n"
                            result += "■■■■■■■■■■■■■■ \n"
                            result += "> **[#{twitterObj["user"]["name"]}](https://twitter.com/#{twitterObj["user"]["screen_name"]})#{jekyllOpen} @ Twitter Says:** \n\n"
                            result += "> > #{fullText} \n\n"
                            result += "> **Tweeted at [#{createdAt}](#{ogURL})#{jekyllOpen}.** \n\n"
                            result += "■■■■■■■■■■■■■■ \n\n"
                        end
                    elsif ![/^(https\:\/\/app\.widgetic\.com)/].nil?
                        #Skip widgetic
                        result = nil
                    else
                        ogImageURL = Helper.fetchOGImage(ogURL)

                        title = paragraph.iframe.title
                        if title.nil? or title == ""
                            title = Helper.escapeMarkdown(ogURL)
                        end
                        
                        if !ogImageURL.nil?
                            result = "\r\n\r\n[![#{title}](#{ogImageURL} \"#{title}\")](#{ogURL})#{jekyllOpen}\r\n\r\n"
                        else
                            result = "[#{title}](#{ogURL})#{jekyllOpen}"
                        end
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
