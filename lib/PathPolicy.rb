$lib = File.expand_path('../lib', File.dirname(__FILE__))

class PathPolicy
    attr_accessor :rootPath, :path
    def initialize(rootPath, path)
        @rootPath = rootPath
        @path = path
    end

    def getRelativePath(lastPath)
        if lastPath.nil?
            "#{path}"
        else
            "#{path}/#{lastPath}"
        end
    end

    def getAbsolutePath(lastPath)
        if lastPath.nil?
            "#{rootPath}/#{path}"
        else
            "#{rootPath}/#{path}/#{lastPath}"
        end
    end
end