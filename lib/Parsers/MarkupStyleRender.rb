
$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Models/Paragraph'

class MarkupStyleRender 
    attr_accessor :paragraph, :chars, :encodeType

    class TextChar
        attr_accessor :chars, :type
        def initialize(chars, type)
            @chars = chars
            @type = type
        end
    end

    class TagChar < TextChar
        attr_accessor :sort, :startIndex, :endIndex, :startChars, :endChars
        def initialize(sort, startIndex, endIndex, startChars, endChars)
            @sort = sort
            @startIndex = startIndex
            @endIndex = endIndex - 1
            @startChars = TextChar.new(startChars.chars, 'TagStart')
            @endChars = TextChar.new(endChars.chars, 'TagEnd')
        end
    end


    def initialize(paragraph)
        @paragraph = paragraph

        chars = {}
        index = 0
        
        emojiRegex = /[\u{203C}\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E7}-\u{1F1EC}\u{1F1EE}-\u{1F1F0}\u{1F1F3}\u{1F1F5}\u{1F1F7}-\u{1F1FA}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F320}\u{1F330}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F380}-\u{1F393}\u{1F3A0}-\u{1F3C4}\u{1F3C6}-\u{1F3CA}\u{1F3E0}-\u{1F3F0}\u{1F400}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4F7}\u{1F4F9}-\u{1F4FC}\u{1F500}-\u{1F507}\u{1F509}-\u{1F53D}\u{1F550}-\u{1F567}\u{1F5FB}-\u{1F640}\u{1F645}-\u{1F64F}\u{1F680}-\u{1F68A}]/
        excludesEmojis = ["⚠"]
        paragraph.text.each_char do |char|
            chars[index] = TextChar.new([char], "Text")
            index += 1
            if char =~ emojiRegex && !excludesEmojis.include?(char)
                # some emoji need more space (in Medium)
                chars[index] = TextChar.new([], "Text")
                index += 1
            end
        end
        
        @chars = chars
    end

    def optimize(chars) 
        while true
            hasExcute = false
            
            index = 0
            startTagIndex = nil
            preTag = nil
            preTagIndex = nil
            preTextChar = nil
            preTextIndex = nil
            chars.each do |char|

                if !preTag.nil?
                    if preTag.type == "TagStart" && char.type == "TagEnd"
                        chars.delete_at(index)
                        chars.delete_at(preTagIndex)
                        hasExcute = true
                        break
                    end
                end
                
                if char.type == "TagStart" && (preTag == nil || preTag.type == "TagEnd" || preTag.type == "Text")
                    startTagIndex = index
                elsif (char.type  == "TagEnd" || char.type  == "Text") && startTagIndex != nil
                    if preTextChar != nil && preTextChar.chars.join() != "\n"
                        # not first tag & insert blank between start tag and before text
                        if preTextChar.chars.join() != " "
                            chars.insert(startTagIndex, TextChar.new(" ".chars, "Text"))
                            hasExcute = true
                            break
                        end
                    end
                    startTagIndex = nil
                end

                if !preTag.nil?
                    if preTag.type == "TagStart" && char.type  == "Text"
                        # delete blank between start tag and after text
                        if char.chars.join().strip == ""
                            chars.delete_at(index)
                            hasExcute = true
                            break
                        end
                    end

                    if preTag.type == "Text" && char.type  == "TagEnd"
                        if preTextChar.chars.join().strip == "" && preTextChar.chars.join() != "\n"
                            chars.delete_at(preTextIndex)
                            hasExcute = true
                            break
                        end
                    end

                    if preTag.type == "TagEnd" && char.type  == "Text"
                        if char.chars.join() != " "
                            chars.insert(index, TextChar.new(" ".chars, "Text"))
                            hasExcute = true
                            break
                        end
                    end

                end

                if char.type == "Text"
                    preTextChar = char
                    preTextIndex = index
                end
                
                preTag = char
                preTagIndex = index

                index += 1
            end
            
            if !hasExcute
                break
            end
        end

        chars
    end

    def parse()
        result = paragraph.text

        if !paragraph.markups.nil? && paragraph.markups.length > 0
            
            tags = []
            paragraph.markups.each do |markup|
                tag = nil
                if markup.type == "EM"
                    tag = TagChar.new(2, markup.start, markup.end, "_", "_")
                elsif markup.type == "CODE"
                    tag = TagChar.new(3, markup.start, markup.end, "`", "`")
                elsif markup.type == "STRONG"
                    tag = TagChar.new(2, markup.start, markup.end, "**", "**")
                elsif markup.type == "A"
                    url = markup.href
                    if markup.anchorType == "LINK"
                        url = markup.href
                    elsif markup.anchorType == "USER"
                        url = "https://medium.com/u/#{markup.userId}"
                    end
                    
                    tag = TagChar.new(1, markup.start, markup.end, "[", "](#{url})")
                else
                    Helper.makeWarningText("Undefined Markup Type: #{markup.type}.")
                end

                if !tag.nil?
                    tags.append(tag)
                end
            end

            tags.sort_by(&:startIndex)

            response = []
            stack = []

            chars.each do |index, char|

                if char.chars.join() == "\n"
                    brStack = stack.dup
                    while brStack.length > 0
                        tag = brStack.pop
                        response.push(tag.endChars)
                    end
                    response.append(TextChar.new(char.chars, 'Text'))
                    brStack = stack.dup.reverse
                    while brStack.length > 0
                        tag = brStack.pop
                        response.push(tag.startChars)
                    end
                end

                startTags = tags.select { |tag| tag.startIndex == index }.sort_by(&:sort)
                if !startTags.nil?
                    startTags.each do |tag|
                        response.append(tag.startChars)
                        stack.append(tag)
                    end
                end

                if char.chars.join() != "\n"
                    response.append(TextChar.new(char.chars, 'Text'))
                end

                endTags = tags.select { |tag| tag.endIndex == index }
                if !endTags.nil? && endTags.length > 0
                    mismatchTags = []
                    while endTags.length > 0
                        stackTag = stack.pop
                        stackTagInEndTagsIndex = endTags.find_index(stackTag)
                        if !stackTagInEndTagsIndex.nil?
                            # as expected
                            endTags.delete_at(stackTagInEndTagsIndex)
                        else
                            mismatchTags.append(stackTag)
                        end
                        response.append(stackTag.endChars)
                    end

                    while mismatchTags.length > 0
                        mismatchTag = mismatchTags.pop
                        response.append(mismatchTag.startChars)
                        stack.append(mismatchTag)
                    end
                end
            end

            while stack.length > 0
                tag = stack.pop
                response.push(tag.endChars)
            end
            
            response = optimize(response)
            result = response.map{ |response| response.chars }.join()
        end

        result
    end

end