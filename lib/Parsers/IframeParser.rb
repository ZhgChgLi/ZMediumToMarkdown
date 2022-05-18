$lib = File.expand_path('../', File.dirname(__FILE__))

require "Request"
require "Parsers/Parser"
require 'Models/Paragraph'
require 'nokogiri'

class IframeParser < Parser
    attr_accessor :nextParser
    def parse(paragraph)
        if paragraph.type == 'IFRAME'
            if !paragraph.iframe.src.nil? && paragraph.iframe.src != ""
                url = paragraph.iframe.src
            else
                url = "https://medium.com/media/#{paragraph.iframe.id}"
            end
            
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
