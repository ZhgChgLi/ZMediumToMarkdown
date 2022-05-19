#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$lib = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift($lib)

require "open-uri"

# require 'nokogiri'
# require 'json'
# require 'uri'

# require 'fileutils'

require "Parsers/H1Parser"
require "Parsers/H2Parser"
require "Parsers/H3Parser"
require "Parsers/H4Parser"
require "Parsers/PParser"
require "Parsers/ULIParser"
require "Parsers/IframeParser"
require "Parsers/IMGParser"
require "Parsers/FallbackParser"
require "Parsers/BQParser"
require "Parsers/PREParser"

require "Request"
require "Post"
require "User"

class ZMediumFetcher

    def self.getOutputDirName()
        "./Output"
    end

    def initialize
        Dir.mkdir(ZMediumFetcher.getOutputDirName()) unless File.exists?(ZMediumFetcher.getOutputDirName())
    end
    
    def queryPosts()
        User.fetchUserPosts(User.convertToUserIDFromUsername("zhgchgli")).each do |postURL|
            postURL = "https://medium.com/@hcgggg_11814/title-medium-test-708003bf8714"
            postID = Post.getPostIDFromPostURLString(postURL)
            postPath = Post.getPostPathFromPostURLString(postURL)
            html = Request.html(Request.URL(postURL))
            postContent = Post.parsePostContentFromHTML(html)
            paragraphs = Post.parsePostParagraphsFromPostContent(postContent, postID)

            h1Parser = H1Parser.new(H2Parser.new(H3Parser.new(H4Parser.new(PParser.new(ULIParser.new(IframeParser.new(IMGParser.new(BQParser.new(PREParser.new(FallbackParser.new()))))))))))
            
            File.open("#{ZMediumFetcher.getOutputDirName()}/#{postPath}.md", "w+") do |file|
                paragraphs.each do |sourcParagraph|
                    paragraph = Paragraph.new(sourcParagraph, postID, postContent)
                    markupParser = MarkupParser.new(paragraph.text, paragraph.markups)
                    paragraph.text = markupParser.parse()
                    file.puts(h1Parser.parse(paragraph))
                end
            end
            break
        end
        

        # postURL = "https://medium.com/pinkoi-engineering/%E5%AF%A6%E6%88%B0%E7%B4%80%E9%8C%84-4-%E5%80%8B%E5%A0%B4%E6%99%AF-7-%E5%80%8B-design-patterns-78507a8de6a5"
        # postID = Post.getPostIDFromPostURLString(postURL)
        # postPath = Post.getPostPathFromPostURLString(postURL)
        # html = Request.html(Request.URL(postURL))
        # postContent = Post.parsePostContentFromHTML(html)
        # paragraphs = Post.parsePostParagraphsFromPostContent(postContent, postID)

        # h1Parser = H1Parser.new(H2Parser.new(H3Parser.new(H4Parser.new(PParser.new(ULIParser.new(IframeParser.new(IMGParser.new(BQParser.new(PREParser.new(FallbackParser.new()))))))))))
        
        # File.open("#{ZMediumFetcher.getOutputDirName()}/#{postPath}.md", "w+") do |file|
        #     paragraphs.each do |paragraph|
        #         file.puts(h1Parser.parse(Paragraph.new(paragraph, postID, postContent)))
        #     end
        # end
        


        # json["Post:#{postID}"]["content({\"postMeteringOptions\":null})"]["bodyModel"]["paragraphs"].each do |paragraph|
        #     row = json[paragraph["__ref"]]
        #     if  row["type"] == 'H1'
        #         puts "# #{row['text']}"
        #     elsif row["type"] == 'H2'
        #         puts "## #{row['text']}"
        #     elsif row["type"] == 'H3'
        #         puts "### #{row['text']}"
        #     elsif row["type"] == 'H4'
        #         puts "#### #{row['text']}"
        #     elsif row["type"] == 'P'
        #         puts "#{row['text']}"
        #     elsif row["type"] == 'BQ'
        #         puts "> #{row['text']}"

        #     elsif row["type"] == 'IMG'
        #         image = json[row['metadata']['__ref']]
        #         dir = "./#{postID}/"
        #         downloadURL = "#{dir}/#{image['id']}"

        #         Dir.mkdir(dir) unless File.exists?(dir)
        #         File.write(downloadURL, open("https://miro.medium.com/max/1400/#{image['id']}").read, {mode: 'wb'})
                
        #         puts "![#{row['text']}](/path/to/img.jpg \"#{row['text']}\")"
        #     elsif row["type"] == 'IFRAME'
        #         mediaSourceID = json[row['iframe']['mediaResource']['__ref']]['id']
        #         mediaSource = requestURL("https://medium.com/media/#{mediaSourceID}")
                
        #         mediaSourceHTML = Nokogiri::HTML(mediaSource.body)
                
        #         gistSRC = mediaSourceHTML.search('script').first.attribute('src')

        #         if !gistSRC.to_s[/^(https\:\/\/gist\.github\.com)/].nil?
        #             # is gist
        #             gist = requestURL(gistSRC).body.scan(/(document\.write\('){1}(.*)(\)){1}/)[1][1]
        #             gist.gsub! '\n', ''
        #             gist.gsub! '\"', '"'
        #             gist.gsub! '<\/', '</'
        #             gistHTML = Nokogiri::HTML(gist)
        #             lang = gistHTML.search('table').first['data-tagsearch-lang']
        #             gistHTML.search('a').each do |a|
        #                 if a.text == 'view raw'
        #                     gistRAW = requestURL(a['href']).body
        #                     puts "```#{lang}\n#{gistRAW}\n```"
        #                 end
        #             end
        #         end
        #     else
        #         puts row['text']
        #     end
        # end
    end
end

fetcher = ZMediumFetcher.new
fetcher.queryPosts()
