$lib = File.expand_path('../lib', File.dirname(__FILE__))

require 'Helper'

class ImageDownloader
    def self.download(path, url)
        dir = path.split("/")
        dir.pop()
        Helper.createDirIfNotExist(dir.join("/"))
        
        begin
            imageResponse = open(url)
            File.write(path, imageResponse.read, {mode: 'wb'})
            true
        rescue
            false
        end
    end
end