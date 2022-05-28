$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Parsers/PParser'
require 'securerandom'

class Paragraph
    attr_accessor :postID, :name, :text, :type, :href, :metadata, :mixtapeMetadata, :iframe, :hasMarkup, :oliIndex, :markupLinks

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

    def self.makeBlankParagraph(postID)
        json = {
            "name" => "fakeBlankParagraph_#{SecureRandom.uuid}",
            "text" => "",
            "type" => PParser.getTypeString()
        }
        Paragraph.new(json, postID, nil)
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
        
        if !json['markups'].nil? && json['markups'].length > 0
            links = json['markups'].select{ |markup| markup["type"] == "A" }
            if !links.nil? && links.length > 0
                @markupLinks = links.map{ |link| link["href"] }
            end
            @hasMarkup = true
        else
            @hasMarkup = false
        end
    end
end