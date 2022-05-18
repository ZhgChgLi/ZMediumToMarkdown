$lib = File.expand_path('../lib', File.dirname(__FILE__))

require "Request"
require 'uri'
require 'nokogiri'
require 'json'

class Post
  def self.getPostIDFromPostURLString(postURLString)
    uri = URI.parse(postURLString)
    postID = uri.path.split('/').last.split('-').last
    
    postID
  end

  def self.getPostPathFromPostURLString(postURLString)
    uri = URI.parse(postURLString)
    postPath = uri.path.split('/').last
    
    URI.decode(postPath)
  end

  def self.parsePostContentFromHTML(html)
    json = nil
    html.search('script').each do |script|
        match = script.to_s[/(<script>window\.__APOLLO_STATE__ \= ){1}(.*)(<\/script>){1}/,2]
        if !match.nil? && match != ""
            json = JSON.parse(match)
        end
    end

    json
  end

  def self.parsePostParagraphsFromPostContent(content, postID)
    content["Post:#{postID}"]["content({\"postMeteringOptions\":null})"]["bodyModel"]["paragraphs"].map { |paragraph| content[paragraph["__ref"]] }
  end
end