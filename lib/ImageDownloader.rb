$lib = File.expand_path('../lib', File.dirname(__FILE__))

require 'Helper'

class ImageDownloader
    def self.download(path, url)
        dir = path.split("/")
        dir.pop()
        Helper.createDirIfNotExist(dir.join("/"))
        
        if File.exist?(path)
            return true
        end

        begin
            imageResponse = URI.open(url)
            File.write(path, imageResponse.read)
            true
        rescue
            false
        end
    end
end