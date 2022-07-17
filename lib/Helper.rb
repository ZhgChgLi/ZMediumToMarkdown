$lib = File.expand_path('../lib', File.dirname(__FILE__))

require 'fileutils'
require 'date'
require 'PathPolicy'
require 'Post'
require "Request"
require 'json'
require 'open-uri'
require 'zip'
require 'nokogiri'

class Helper

    def self.escapeMarkdown(text)
        text.gsub(/(\*|_|`|\||\\|\{|\}|\[|\]|\(|\)|#|\+|\-|\.|\!)/){ |x| "\\#{x}" }
    end

    def self.fetchOGImage(url)
        html = Request.html(Request.URL(url))
        content = html.search("meta[property='og:image']").attribute('content')
        
        content
    end

    def self.escapeHTML(text)
        if text == "<"
            "&lt;"
        elsif text == ">"
            "&gt;"
        else
            text
        end
    end

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

    def self.downloadLatestVersion()
        rootPath = File.expand_path('../', File.dirname(__FILE__))
        
        if File.file?("#{rootPath}/ZMediumToMarkdown.gemspec")
            apiPath = 'https://api.github.com/repos/ZhgChgLi/ZMediumToMarkdown/releases'
            versions = JSON.parse(Request.URL(apiPath).body).sort { |a,b| b["id"] <=> a["id"] }

            version = nil
            index = 0
            while version == nil do
                thisVersion = versions[index]
                if thisVersion["prerelease"] == false
                    version = thisVersion
                    next
                end
                index += 1
            end
            
            zipFilePath = version["zipball_url"]
            puts "Downloading latest version from github..."
            open('latest.zip', 'wb') do |fo|
                fo.print open(zipFilePath).read
            end

            puts "Unzip..."
            Zip::File.open("latest.zip") do |zipfile|
                zipfile.each do |file|
                    fileNames = file.name.split("/")
                    fileNames.shift
                    filePath = fileNames.join("/")
                    if filePath != ''
                        puts "Unzinp...#{filePath}"
                        zipfile.extract(file, filePath) { true }
                    end
                end
            end
            File.delete("latest.zip")

            tagName = version["tag_name"]
            puts "Update to version #{tagName} successfully!"
        else
            system("gem update ZMediumToMarkdown")
        end
    end

    def self.createPostInfo(postInfo)

        title = postInfo.title.gsub("[","")
        title = title.gsub("]","")

        result = "---\n"
        result += "title: #{title}\n"
        result += "author: #{postInfo.creator}\n"
        result += "date: #{postInfo.firstPublishedAt.strftime('%Y-%m-%dT%H:%M:%S.%LZ')}\n"
        result += "categories: #{postInfo.collectionName}\n"
        result += "tags: [#{postInfo.tags.join(",")}]\n"
        result += "description: #{postInfo.description}\n"
        result += "render_with_liquid: false\n"
        result += "---\n"
        result += "\r\n"

        result
    end

    def self.printNewVersionMessageIfExists() 
        if Helper.getRemoteVersionFromGithub() > Helper.getLocalVersion()
            puts "##########################################################"
            puts "#####           New Version Available!!!             #####"
            puts "##### Please type `ZMediumToMarkdown -n` to update!! #####"
            puts "##########################################################"
        end
    end

    def self.getLocalVersion()
        rootPath = File.expand_path('../', File.dirname(__FILE__))
        
        result = nil
        if File.file?("#{rootPath}/ZMediumToMarkdown.gemspec")
            gemspecContent = File.read("#{rootPath}/ZMediumToMarkdown.gemspec")
            result = gemspecContent[/(gem\.version){1}\s+(\=)\s+(\'){1}(\d+(\.){1}\d+(\.){1}\d+){1}(\'){1}/, 4]
        else
            result = Gem.loaded_specs["ZMediumToMarkdown"].version.version
        end

        if !result.nil?
            Gem::Version.new(result)
        else
            nil
        end
    end

    def self.getRemoteVersionFromGithub()
        apiPath = 'https://api.github.com/repos/ZhgChgLi/ZMediumToMarkdown/releases'
        versions = JSON.parse(Request.URL(apiPath).body).sort { |a,b| b["id"] <=> a["id"] }

        tagName = nil
        index = 0
        while tagName == nil do
            thisVersion = versions[index]
            if thisVersion["prerelease"] == false
                tagName = thisVersion["tag_name"]
                next
            end
            index += 1
        end

        if !tagName.nil?
            Gem::Version.new(tagName.downcase.gsub! 'v','')
        else
            nil
        end
    end

    def self.compareVersion(version1, version2)
        if version1.major > version2.major
            true
        else
            if version1.minor > version2.minor
                true
            else
                if version1.patch > version2.patch
                    true
                else
                    false
                end
            end
        end
    end

        
    def self.createWatermark(postURL)
        text = "\r\n\r\n\r\n"
        text += "+-----------------------------------------------------------------------------------+"
        text += "\r\n"
        text += "\r\n"
        text += "| **[View original post on Medium](#{postURL}) - Converted by [ZhgChgLi](https://zhgchg.li)/[ZMediumToMarkdown](https://github.com/ZhgChgLi/ZMediumToMarkdown)** |"
        text += "\r\n"
        text += "\r\n"
        text += "+-----------------------------------------------------------------------------------+"
        text += "\r\n"
        
        text
    end
end
