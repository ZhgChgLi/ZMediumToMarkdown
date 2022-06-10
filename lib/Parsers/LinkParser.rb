$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Models/Paragraph'

class LinkParser
    attr_accessor :usersPostURLs, :isForJekyll

    def initialize(usersPostURLs, isForJekyll)
        @usersPostURLs = usersPostURLs
        @isForJekyll = isForJekyll
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

                        if isForJekyll
                            postPath = link.split("/").last.split("-").last
                        else
                            postPath = link.split("/").last
                        end
                        
                        if !usersPostURLs.find { |usersPostURL| usersPostURL.split("/").last.split("-").last == postPath.split("-").last }.nil?
                            if isForJekyll
                                markdownString = markdownString.sub! link, "../#{postPath}"
                            else
                                markdownString = markdownString.sub! link, "#{postPath}"
                            end
                        end
                    end
                end
            end
        end

        markdownString
    end
end
