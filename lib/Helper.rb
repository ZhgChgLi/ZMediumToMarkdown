$lib = File.expand_path('../lib', File.dirname(__FILE__))

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