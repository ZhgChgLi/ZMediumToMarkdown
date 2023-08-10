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

    def self.fetchOGImage(url)
        html = Request.html(Request.URL(url))
        return "" unless html
        image = html.search("meta[property='og:image']")
        image.attribute('content') || ""
    end

    def self.escapeMarkdown(text)
        text.gsub(/(\*|_|`|\||\\|\{|\}|\[|\]|\(|\)|#|\+|\-|\.|\!)/){ |x| "\\#{x}" }
    end

    def self.escapeHTML(text)
        text = text.gsub(/(<)/, '&lt;')
        text = text.gsub(/(>)/, '&gt;')
        text
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

    def self.createPostInfo(postInfo, isPin, isForJekyll)
        title = postInfo.title&.gsub("[","")
        title = title&.gsub("]","")

        tags = ""
        if !postInfo.tags.nil? && postInfo.tags.length > 0
            tags = "\"#{postInfo.tags.map { |tag| tag&.gsub("\"", "\\\"") }.join("\",\"")}\""
        end

        result = "---\n"
        result += "title: \"#{title&.gsub("\"", "\\\"")}\"\n"
        result += "author: \"#{postInfo.creator&.gsub("\"", "\\\"")}\"\n"
        result += "date: #{postInfo.firstPublishedAt.strftime('%Y-%m-%dT%H:%M:%S.%L%z')}\n"
        result += "last_modified_at: #{postInfo.latestPublishedAt.strftime('%Y-%m-%dT%H:%M:%S.%L%z')}\n"
        result += "categories: \"#{postInfo.collectionName&.gsub("\"", "\\\"")}\"\n"
        result += "tags: [#{tags}]\n"
        result += "description: \"#{postInfo.description&.gsub("\"", "\\\"")}\"\n"
        if !postInfo.previewImage.nil?
            result += "image:\r\n"
            result += "  path: /#{postInfo.previewImage}\r\n"
        end
        if !isPin.nil? && isPin == true
            result += "pin: true\r\n"
        end

        if isForJekyll
            result += "render_with_liquid: false\n"
        end
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

        
    def self.createWatermark(postURL, isForJekyll)
        jekyllOpen = ""
        if isForJekyll
            jekyllOpen = "{:target=\"_blank\"}"
        end

        text = "\r\n\r\n\r\n"
        text += "_[Post](#{postURL})#{jekyllOpen} converted from Medium by [ZMediumToMarkdown](https://github.com/ZhgChgLi/ZMediumToMarkdown)#{jekyllOpen}._"
        text += "\r\n"

        text
    end
end