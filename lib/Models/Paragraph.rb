$lib = File.expand_path('../', File.dirname(__FILE__))

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
        
        newText = @text.dup
        textSettings = {}
        @markups = json['markups'].map do |thisMarkup|
            markup = Markup.new(thisMarkup)
            if textSettings[markup.start].nil?
                textSettings[markup.start] = []
            end

            if textSettings[markup.end].nil?
                textSettings[markup.end] = []
            end

            if markup.type == "EM"
                textSettings[markup.start].insert(0, "_")
                textSettings[markup.end].insert(0,"_")
            elsif markup.type == "STRONG"
                textSettings[markup.start].insert(0,"**")
                textSettings[markup.end].insert(0,"**")
            elsif markup.type == "CODE"
                textSettings[markup.start].insert(0,"`")
                textSettings[markup.end].insert(0,"`")
            elsif markup.type == "A"
                textSettings[markup.start].insert(0,"[")
                textSettings[markup.end].insert(0,"](#{markup.href})")
            end
        end
        
        if textSettings != {}
            offset = 0
            textSettings.sort_by {|k, v| k}.to_h.each do |position, values|
                values.each do |value|
                    puts newText
                    puts position
                    puts offset
                    puts value
                    newText.insert(position+offset, value)
                    offset += value.length
                end
            end
        end

        @text = newText
    end
end