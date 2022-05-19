$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Parsers/MarkupParser'

class Paragraph
    attr_accessor :postID, :name, :text, :type, :href, :metadata, :iframe, :markups

    class Markup
        attr_accessor :type, :start, :end, :href
        def initialize(json)
            @type = json['type']
            @start = json['start']
            @end = json['end']
            @href = json['href']
        end
    end

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

        if json['iframe'].nil?
            @iframe = nil
        else
            @iframe = Iframe.new(resource[json['iframe']['mediaResource']['__ref']])
        end
        
        @markups = json['markups'].map do |thisMarkup|
            markup = Markup.new(thisMarkup)
        end

        markupParser = MarkupParser.new(text, markups)
        @text = markupParser.parse()
    end
end