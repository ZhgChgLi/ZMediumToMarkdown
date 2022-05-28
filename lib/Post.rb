$lib = File.expand_path('../lib', File.dirname(__FILE__))

require "Request"
require 'uri'
require 'nokogiri'
require 'json'
require 'date'

class Post

  class PostInfo
    attr_accessor :title, :tags, :creator, :firstPublishedAt
  end

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
    result = content&.dig("Post:#{postID}", "content({\"postMeteringOptions\":null})", "bodyModel", "paragraphs")
    if result.nil?
      nil
    else
      result.map { |paragraph| content[paragraph["__ref"]] }
    end
  end

  def self.parsePostInfoFromPostContent(content, postID)
    postInfo = PostInfo.new()
    postInfo.title = content&.dig("Post:#{postID}", "title")
    postInfo.tags = content&.dig("Post:#{postID}", "tags").map{ |tag| tag["__ref"].gsub! 'Tag:', '' }
    
    creatorRef = content&.dig("Post:#{postID}", "creator", "__ref")
    if !creatorRef.nil?
      postInfo.creator = content&.dig(creatorRef, "name")
    end

    firstPublishedAt = content&.dig("Post:#{postID}", "firstPublishedAt")
    if !firstPublishedAt.nil?
      postInfo.firstPublishedAt = DateTime.strptime(firstPublishedAt.to_s,'%Q')
    end
    
    postInfo
  end
end