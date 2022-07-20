$lib = File.expand_path('../lib', File.dirname(__FILE__))

class PathPolicy
    attr_accessor :rootPath, :path
    def initialize(rootPath, path)
        @rootPath = rootPath
        @path = path
    end

    def getRelativePath(lastPath)
        result = path

        if result != ""
            result += "/"
        end

        if !lastPath.nil?
            result += lastPath
        end

        result
    end

    def getAbsolutePath(lastPath)
        result = rootPath        

        if !lastPath.nil?
            if result != ""
                result += "/"
            end
            result += "#{lastPath}"
        end

        result
    end
end