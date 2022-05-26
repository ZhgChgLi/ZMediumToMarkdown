$lib = File.expand_path('../', File.dirname(__FILE__))

class Paragraph
    attr_accessor :postID, :name, :text, :type, :href, :metadata, :mixtapeMetadata, :iframe, :hasMarkup

    class Iframe
        attr_accessor :id, :title, :type, :src
        def initialize(json)
            @id = json['id']
            @type = json['__typename']
            @title = json['title']
            @src = json['iframeSrc']
        end

        def parse()

        end
    end

    class MetaData
        attr_accessor :id, :type
        def initialize(json)
            @id = json['id']
            @type = json['__typename']
        end
    end

    class MixtapeMetadata
        attr_accessor :href
        def initialize(json)
            @href = json['href']
        end
    end

    def initialize(json, postID, resource)
        @name = json['name']
        @text = json['text']
        @type = json['type']
        @href = json['href']
        @postID = postID

        if json['metadata'].nil?
            @metadata = nil
        else
            @metadata = MetaData.new(resource[json['metadata']['__ref']])
        end

        if json['mixtapeMetadata'].nil?
            @mixtapeMetadata = nil
        else
            @mixtapeMetadata = MixtapeMetadata.new(json['mixtapeMetadata'])
        end

        if json['iframe'].nil?
            @iframe = nil
        else
            @iframe = Iframe.new(resource[json['iframe']['mediaResource']['__ref']])
        end
        
        if json['markups'].length > 0
            @hasMarkup = true
        else
            @hasMarkup = false
        end
    end
end