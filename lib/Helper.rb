$lib = File.expand_path('../lib', File.dirname(__FILE__))

require 'date'
require 'Post'

class Helper
    def self.createDirIfNotExist(dirPath)
        dirs = dirPath.split("/")
        currentDir = ""
        begin
            dir = dirs.shift
            currentDir = "#{currentDir}/#{dir}"
            Dir.mkdir(currentDir) unless File.exists?(currentDir)
        end while dirs.length > 0
    end

    def self.makeWarningText(message)
        puts "####################################################\n"
        puts "#WARNING:\n"
        puts "##{message}\n"
        puts "#--------------------------------------------------#\n"
        puts "#Please feel free to open an Issue or submit a fix/contribution via Pull Request on:\n"
        puts "#https://github.com/ZhgChgLi/ZMediumToMarkdown\n"
        puts "####################################################\n"
    end

    def self.createPostInfo(postInfo)
        result = "---\n"
        result += "title: #{postInfo.title}\n"
        result += "author: #{postInfo.creator}\n"
        result += "date: #{postInfo.firstPublishedAt.strftime('%Y-%m-%dT%H:%M:%S.%LZ')}\n"
        result += "tags: [#{postInfo.tags.join(",")}]\n"
        result += "---\n"
        result += "\r\n"

        result
    end

    def self.createWatermark(postURL)
        text = "\r\n\r\n\r\n"
        text += "+-----------------------------------------------------------------------------------+"
        text += "\r\n"
        text += "\r\n"
        text += "| **[View original post on Medium](#{postURL}) - Converted by [ZhgChgLi](https://blog.zhgchg.li)/[ZMediumToMarkdown](https://github.com/ZhgChgLi/ZMediumToMarkdown)** |"
        text += "\r\n"
        text += "\r\n"
        text += "+-----------------------------------------------------------------------------------+"
        text += "\r\n"
        
        text
    end
end