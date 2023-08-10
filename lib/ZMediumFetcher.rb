

$lib = File.expand_path('../lib', File.dirname(__FILE__))

require "fileutils"

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
require "Parsers/MarkupParser"
require "Parsers/OLIParser"
require "Parsers/MIXTAPEEMBEDParser"
require "Parsers/PQParser"
require "Parsers/CodeBlockParser"

require "PathPolicy"
require "Request"
require "Post"
require "User"
require 'date'
require "uri"

module URI
  def self.decode url
    url ? URI.decode_www_form_component(url).gsub(" ", "%20") : ""
  end
end
    

class ZMediumFetcher

    attr_accessor :progress, :usersPostURLs, :isForJekyll

    class Progress
        attr_accessor :username, :postPath, :currentPostIndex, :totalPostsLength, :currentPostParagraphIndex, :totalPostParagraphsLength, :message

        def printLog()
            info = ""
            if !username.nil?
                if !currentPostIndex.nil? && !totalPostsLength.nil?
                    info += "[#{username}(#{currentPostIndex}/#{totalPostsLength})]"
                else
                    info += "[#{username}]"
                end
            end

            if !postPath.nil?
                if info != ""
                    info += "-"
                end
                if !currentPostParagraphIndex.nil? && !totalPostParagraphsLength.nil?
                    info += "[#{postPath[0..15]}...(#{currentPostParagraphIndex}/#{totalPostParagraphsLength})]"
                else
                    info += "[#{postPath[0..15]}...]"
                end
            end

            if !message.nil?
                if info != ""
                    info += "-"
                end
                info += message
            end

            if info != "" 
                puts info
            end
        end
    end

    def initialize
        @progress = Progress.new()
        @usersPostURLs = nil
        @isForJekyll = false
    end

    def buildParser(imagePathPolicy)
        h1Parser = H1Parser.new()
        h2Parser = H2Parser.new()
            h1Parser.setNext(h2Parser)
        h3Parser = H3Parser.new()
            h2Parser.setNext(h3Parser)
        h4Parser = H4Parser.new()
            h3Parser.setNext(h4Parser)
        ppParser = PParser.new()
            h4Parser.setNext(ppParser)
        uliParser = ULIParser.new()
            ppParser.setNext(uliParser)
        oliParser = OLIParser.new()
            uliParser.setNext(oliParser)
        mixtapeembedParser = MIXTAPEEMBEDParser.new(isForJekyll)
            oliParser.setNext(mixtapeembedParser)
        pqParser = PQParser.new()
            mixtapeembedParser.setNext(pqParser)
        iframeParser = IframeParser.new(isForJekyll)
        iframeParser.pathPolicy = imagePathPolicy
            pqParser.setNext(iframeParser)
        imgParser = IMGParser.new(isForJekyll)
        imgParser.pathPolicy = imagePathPolicy
            iframeParser.setNext(imgParser)
        bqParser = BQParser.new()
            imgParser.setNext(bqParser)
        preParser = PREParser.new(isForJekyll)
            bqParser.setNext(preParser)
        codeBlockParser = CodeBlockParser.new(isForJekyll)
            preParser.setNext(codeBlockParser)
        fallbackParser = FallbackParser.new()
            codeBlockParser.setNext(fallbackParser)


        h1Parser
    end

    def downloadPost(postURL, pathPolicy, isPin)
        postID = Post.getPostIDFromPostURLString(postURL)

        if isForJekyll
            postPath = postID # use only post id is more friendly for url seo
        else
            postPath = Post.getPostPathFromPostURLString(postURL)
        end

        if isForJekyll
            postPathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath("_posts/zmediumtomarkdown"), pathPolicy.getRelativePath("_posts/zmediumtomarkdown"))
            imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath("assets"), "assets")
        else
            postPathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath("zmediumtomarkdown"), pathPolicy.getRelativePath("zmediumtomarkdown"))
            imagePathPolicy = PathPolicy.new(postPathPolicy.getAbsolutePath("assets"), "assets")
        end

        progress.postPath = URI.decode(postPath)
        progress.message = "Downloading Post..."
        progress.printLog()

        postHtml = Request.html(Request.URL(postURL))

        postContent = Post.parsePostContentFromHTML(postHtml)
        if postContent.nil?
            raise "Error: Content is empty! PostURL: #{postURL}"
        end
        
        postInfo = Post.parsePostInfoFromPostContent(postContent, postID, imagePathPolicy)

        sourceParagraphs = Post.fetchPostParagraphs(postID)
        if sourceParagraphs.nil?
            raise "Error: Paragraph not found! PostURL: #{postURL}"
        end 
        
        progress.message = "Formatting Data..."
        progress.printLog()

        paragraphs = []
        oliIndex = 0
        previousParagraph = nil
        preTypeParagraphs = []
        sourceParagraphs.each do |sourcParagraph|
          return if (!sourcParagraph || !postID)
            paragraph = Paragraph.new(sourcParagraph, postID)
            if OLIParser.isOLI(paragraph)
                oliIndex += 1
                paragraph.oliIndex = oliIndex
            else
                oliIndex = 0
            end

            # if previous is OLI or ULI or BQ and current is not OLI or ULI or BQ
            # than insert a blank paragraph to keep markdown foramt correct
            if (OLIParser.isOLI(previousParagraph) && !OLIParser.isOLI(paragraph)) ||
                (ULIParser.isULI(previousParagraph) && !ULIParser.isULI(paragraph))||
                (BQParser.isBQ(previousParagraph) && !BQParser.isBQ(paragraph))
                paragraphs.append(Paragraph.makeBlankParagraph(postID))
            end

            # group by PRE paragraph to code block
            # because medium will give continue pre to present code block
            # e.g.
            # type=pre, text=<html>
            # type=pre, text=text
            # type=pre, text=</html>
            
            if !previousParagraph.nil?
                if PREParser.isPRE(paragraph)
                    # if current is pre
                    preTypeParagraphs.append(paragraph)
                elsif PREParser.isPRE(previousParagraph) && !PREParser.isPRE(paragraph)
                    # if current is note pre and previousParagraph is pre and preTypeParagraphs > 1
                    if preTypeParagraphs.length > 1
                        lastPreTypeParagraph = preTypeParagraphs.pop

                        # group by preParagraphs text to last preParagraph
                        groupByText = ""
                        preTypeParagraphs.each do |preTypeParagraph|
                            if groupByText != ""
                                groupByText += "\n"
                            end

                            groupByText += preTypeParagraph.orgText
                        end
                        
                        lastPreTypeParagraph.text = "#{groupByText}"
                        lastPreTypeParagraph.type = CodeBlockParser.getTypeString()
                        
                        # remove all preParagraphs
                        preTypeParagraphNames = preTypeParagraphs.map do |preTypeParagraph|
                            preTypeParagraph.name
                        end
                        paragraphs = paragraphs.select do |paragraph| 
                            !preTypeParagraphNames.include? paragraph.name
                        end
                    end
                    preTypeParagraphs = []
                end
            end

            paragraphs.append(paragraph)
            previousParagraph = paragraph
        end
        
        startParser = buildParser(imagePathPolicy)

        progress.totalPostParagraphsLength = paragraphs.length
        progress.currentPostParagraphIndex = 0
        progress.message = "Converting Post..."
        progress.printLog()

        postWithDatePath = "#{postInfo.firstPublishedAt.strftime("%Y-%m-%d")}-#{postPath}"
        absolutePath = URI.decode(postPathPolicy.getAbsolutePath("#{postWithDatePath}")) + ".md"
        
        fileLatestPublishedAt = nil
        filePin = false
        if File.file?(absolutePath)
            lines = File.foreach(absolutePath).first(15)
            if lines.first&.start_with?("---")
                latestPublishedAtLine = lines.select { |line| line.start_with?("last_modified_at:") }.first
                if !latestPublishedAtLine.nil?
                    fileLatestPublishedAt = Time.parse(latestPublishedAtLine[/^(last_modified_at:)\s+(\S*)/, 2]).to_i
                end

                pinLine = lines.select { |line| line.start_with?("pin:") }.first
                if !pinLine.nil?
                    filePin = pinLine[/^(pin:)\s+(\S*)/, 2].downcase == "true"
                end
            end
        end

        if (!fileLatestPublishedAt.nil? && fileLatestPublishedAt >= postInfo.latestPublishedAt.to_i) && (!isPin.nil? && isPin == filePin)
            # Already downloaded and nothing has changed!, Skip!
            progress.currentPostParagraphIndex = paragraphs.length
            progress.message = "Skip, Post already downloaded and nothing has changed!"
            progress.printLog()
        else
            Helper.createDirIfNotExist(postPathPolicy.getAbsolutePath(nil))
            File.open(absolutePath, "w+") do |file|
                # write postInfo into top
                postMetaInfo = Helper.createPostInfo(postInfo, isPin, isForJekyll)
                if !postMetaInfo.nil?
                    file.puts(postMetaInfo)
                end
                
                index = 0
                paragraphs.each do |paragraph|

                    if !(CodeBlockParser.isCodeBlock(paragraph) || PREParser.isPRE(paragraph))
                        markupParser = MarkupParser.new(paragraph, isForJekyll)
                        markupParser.usersPostURLs = usersPostURLs
                        paragraph.text = markupParser.parse()
                    end

                    result = startParser.parse(paragraph)

                    file.puts(result)
    
                    index += 1
                    progress.currentPostParagraphIndex = index
                    progress.message = "Converting Post..."
                    progress.printLog()
                end
    
                postWatermark = Helper.createWatermark(postURL, isForJekyll)
                if !postWatermark.nil?
                    file.puts(postWatermark)
                end
            end
            FileUtils.touch absolutePath, :mtime => postInfo.latestPublishedAt

            progress.message = "Post Successfully Downloaded!"
            progress.printLog()
        end
        
        progress.postPath = nil
    end
    
    def downloadPostsByUsername(username, pathPolicy)
        progress.username = username
        progress.message = "Fetching posts..."
        progress.printLog()

        userID = User.convertToUserIDFromUsername(username)
        if userID.nil?
            raise "Medium's Username:#{username} not found!"
        end

        postURLS = []
        nextID = nil
        begin
            postPageInfo = User.fetchUserPosts(userID, nextID)
            postPageInfo["postURLs"].each do |postURL|
                postURLS.append(postURL)
            end
            nextID = postPageInfo["nextID"]
        end while !nextID.nil?

        @usersPostURLs = postURLS.map{ |post| post["url"] }

        progress.totalPostsLength = postURLS.length
        progress.currentPostIndex = 0
        progress.message = "Downloading posts..."
        progress.printLog()

        if isForJekyll
            downloadPathPolicy = pathPolicy
        else
            downloadPathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath("users/#{username}"), pathPolicy.getRelativePath("users/#{username}"))
        end
       
        index = 1
        postURLS.each do |postURL|
          begin
            # todo: unless File.exists? Post.getPostPathFromPostURLString(postURL) +".md"
            downloadPost(postURL["url"], downloadPathPolicy, postURL["pin"]) 
          rescue => e
            puts e
          end

          index += 1
          progress.currentPostIndex = index
          progress.message = "Downloading posts..."
          progress.printLog()
        end

        progress.message = "All posts has been downloaded!, Total posts: #{postURLS.length}"
        progress.printLog()
    end
end