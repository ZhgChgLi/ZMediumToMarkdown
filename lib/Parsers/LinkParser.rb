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

                        postPath = link.split("/").last.split("-").last
                        if !usersPostURLs.find { |usersPostURL| usersPostURL.split("/").last.split("-").last == postPath.split("-").last }.nil?
                            markdownString = markdownString.sub! link, "../#{postPath}"
                        end
                    end
                end
            end
        end

        markdownString
    end
end
