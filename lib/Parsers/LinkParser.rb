$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Models/Paragraph'

class LinkParser
    attr_accessor :usersPostURLs

    def initialize(usersPostURLs)
        @usersPostURLs = usersPostURLs
    end

    def parse(markdownString, markupLinks)
        if !markupLinks.nil?
            matchLinks = markdownString.scan(/\[[^\]]*\]\(([^\)]*)\)/)
            if !matchLinks.nil?

                matchLinks.each do |matchLink|
                    link = matchLink[0]

                    if !usersPostURLs.nil?
                        # if have provide user's post urls
                        # find & replace medium url to local post url if matched

                        postPath = link.split("/").last
                        if !usersPostURLs.find { |usersPostURL| usersPostURL.split("/").last.split("-").last == postPath.split("-").last }.nil?
                            markdownString = markdownString.sub! link, postPath
                        end
                    else
                        if !(link =~ /\A#{URI::regexp(['http', 'https'])}\z/)
                            # medium will give you an relative path if url is medium's post (due to we use html to markdown render)
                            # e.g. /zrealm-ios-dev/visitor-pattern-in-ios-swift-ba5773a7bfea
                            # it's not a vaild url
    
                            # fullfill url from markup attribute
                            match = markupLinks.find{ |markupLink| markupLink.include? link }
                            if !match.nil?
                                markdownString = markdownString.sub! link, match
                            end
                        end
                    end
                end
            end
        end

        markdownString
    end
end
