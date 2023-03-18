$lib = File.expand_path('../lib', File.dirname(__FILE__))

require "Request"
require 'uri'
require 'nokogiri'
require 'json'
require 'date'

require 'ImageDownloader'
require 'PathPolicy'

class Post
  class PostInfo
    attr_accessor :title, :tags, :creator, :firstPublishedAt, :latestPublishedAt, :collectionName, :description, :previewImage
  end

  def self.getPostIDFromPostURLString(postURLString)
    uri = URI.parse(postURLString)
    postID = uri.path.split('/').last.split('-').last
    
    postID
  end

  def self.getPostPathFromPostURLString(postURLString)
    uri = URI.parse(postURLString)
    uri.path.split('/').last
  end

  def self.parsePostContentFromHTML(html)
    json = nil
    return "" unless html
    html.search('script').each do |script|
        match = script.to_s[/(<script>window\.__APOLLO_STATE__ \= ){1}(.*)(<\/script>){1}/,2]
        if !match.nil? && match != ""
            json = JSON.parse(match)
        end
    end

    json
  end

  def self.fetchPostParagraphs(postID)
    query = [
      {
        "operationName": "PostViewerEdgeContentQuery",
        "variables": {
          "postId": postID
        },
        "query": "query PostViewerEdgeContentQuery($postId: ID!, $postMeteringOptions: PostMeteringOptions) {\n  post(id: $postId) {\n    ... on Post {\n      id\n      viewerEdge {\n        id\n        fullContent(postMeteringOptions: $postMeteringOptions) {\n          isLockedPreviewOnly\n          validatedShareKey\n          bodyModel {\n            ...PostBody_bodyModel\n            __typename\n          }\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment PostBody_bodyModel on RichText {\n  sections {\n    name\n    startIndex\n    textLayout\n    imageLayout\n    backgroundImage {\n      id\n      originalHeight\n      originalWidth\n      __typename\n    }\n    videoLayout\n    backgroundVideo {\n      videoId\n      originalHeight\n      originalWidth\n      previewImageId\n      __typename\n    }\n    __typename\n  }\n  paragraphs {\n    id\n    ...PostBodySection_paragraph\n    __typename\n  }\n  ...normalizedBodyModel_richText\n  __typename\n}\n\nfragment PostBodySection_paragraph on Paragraph {\n  name\n  ...PostBodyParagraph_paragraph\n  __typename\n  id\n}\n\nfragment PostBodyParagraph_paragraph on Paragraph {\n  name\n  type\n  ...ImageParagraph_paragraph\n  ...TextParagraph_paragraph\n  ...IframeParagraph_paragraph\n  ...MixtapeParagraph_paragraph\n  ...CodeBlockParagraph_paragraph\n  __typename\n  id\n}\n\nfragment ImageParagraph_paragraph on Paragraph {\n  href\n  layout\n  metadata {\n    id\n    originalHeight\n    originalWidth\n    focusPercentX\n    focusPercentY\n    alt\n    __typename\n  }\n  ...Markups_paragraph\n  ...ParagraphRefsMapContext_paragraph\n  ...PostAnnotationsMarker_paragraph\n  __typename\n  id\n}\n\nfragment Markups_paragraph on Paragraph {\n  name\n  text\n  hasDropCap\n  dropCapImage {\n    ...MarkupNode_data_dropCapImage\n    __typename\n    id\n  }\n  markups {\n    type\n    start\n    end\n    href\n    anchorType\n    userId\n    linkMetadata {\n      httpStatus\n      __typename\n    }\n    __typename\n  }\n  __typename\n  id\n}\n\nfragment MarkupNode_data_dropCapImage on ImageMetadata {\n  ...DropCap_image\n  __typename\n  id\n}\n\nfragment DropCap_image on ImageMetadata {\n  id\n  originalHeight\n  originalWidth\n  __typename\n}\n\nfragment ParagraphRefsMapContext_paragraph on Paragraph {\n  id\n  name\n  text\n  __typename\n}\n\nfragment PostAnnotationsMarker_paragraph on Paragraph {\n  ...PostViewNoteCard_paragraph\n  __typename\n  id\n}\n\nfragment PostViewNoteCard_paragraph on Paragraph {\n  name\n  __typename\n  id\n}\n\nfragment TextParagraph_paragraph on Paragraph {\n  type\n  hasDropCap\n  codeBlockMetadata {\n    mode\n    lang\n    __typename\n  }\n  ...Markups_paragraph\n  ...ParagraphRefsMapContext_paragraph\n  __typename\n  id\n}\n\nfragment IframeParagraph_paragraph on Paragraph {\n  iframe {\n    mediaResource {\n      id\n      iframeSrc\n      iframeHeight\n      iframeWidth\n      title\n      __typename\n    }\n    __typename\n  }\n  layout\n  ...getEmbedlyCardUrlParams_paragraph\n  ...Markups_paragraph\n  __typename\n  id\n}\n\nfragment getEmbedlyCardUrlParams_paragraph on Paragraph {\n  type\n  iframe {\n    mediaResource {\n      iframeSrc\n      __typename\n    }\n    __typename\n  }\n  __typename\n  id\n}\n\nfragment MixtapeParagraph_paragraph on Paragraph {\n  type\n  mixtapeMetadata {\n    href\n    mediaResource {\n      mediumCatalog {\n        id\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n  ...GenericMixtapeParagraph_paragraph\n  __typename\n  id\n}\n\nfragment GenericMixtapeParagraph_paragraph on Paragraph {\n  text\n  mixtapeMetadata {\n    href\n    thumbnailImageId\n    __typename\n  }\n  markups {\n    start\n    end\n    type\n    href\n    __typename\n  }\n  __typename\n  id\n}\n\nfragment CodeBlockParagraph_paragraph on Paragraph {\n  codeBlockMetadata {\n    lang\n    mode\n    __typename\n  }\n  __typename\n  id\n}\n\nfragment normalizedBodyModel_richText on RichText {\n  paragraphs {\n    markups {\n      type\n      __typename\n    }\n    codeBlockMetadata {\n      lang\n      mode\n      __typename\n    }\n    ...getParagraphHighlights_paragraph\n    ...getParagraphPrivateNotes_paragraph\n    __typename\n  }\n  sections {\n    startIndex\n    ...getSectionEndIndex_section\n    __typename\n  }\n  ...getParagraphStyles_richText\n  ...getParagraphSpaces_richText\n  __typename\n}\n\nfragment getParagraphHighlights_paragraph on Paragraph {\n  name\n  __typename\n  id\n}\n\nfragment getParagraphPrivateNotes_paragraph on Paragraph {\n  name\n  __typename\n  id\n}\n\nfragment getSectionEndIndex_section on Section {\n  startIndex\n  __typename\n}\n\nfragment getParagraphStyles_richText on RichText {\n  paragraphs {\n    text\n    type\n    __typename\n  }\n  sections {\n    ...getSectionEndIndex_section\n    __typename\n  }\n  __typename\n}\n\nfragment getParagraphSpaces_richText on RichText {\n  paragraphs {\n    layout\n    metadata {\n      originalHeight\n      originalWidth\n      id\n      __typename\n    }\n    type\n    ...paragraphExtendsImageGrid_paragraph\n    __typename\n  }\n  ...getSeriesParagraphTopSpacings_richText\n  ...getPostParagraphTopSpacings_richText\n  __typename\n}\n\nfragment paragraphExtendsImageGrid_paragraph on Paragraph {\n  layout\n  type\n  __typename\n  id\n}\n\nfragment getSeriesParagraphTopSpacings_richText on RichText {\n  paragraphs {\n    id\n    __typename\n  }\n  sections {\n    startIndex\n    __typename\n  }\n  __typename\n}\n\nfragment getPostParagraphTopSpacings_richText on RichText {\n  paragraphs {\n    layout\n    text\n    codeBlockMetadata {\n      lang\n      mode\n      __typename\n    }\n    __typename\n  }\n  sections {\n    startIndex\n    __typename\n  }\n  __typename\n}\n"
      }
    ]

    body = Request.body(Request.URL("https://medium.com/_/graphql", "POST", query))
    if !body.nil?
      json = JSON.parse(body)
      json&.dig(0, "data", "post", "viewerEdge", "fullContent", "bodyModel", "paragraphs")
    else
      nil
    end
  end

  def self.parsePostInfoFromPostContent(content, postID, pathPolicy)
    postInfo = PostInfo.new()
    postInfo.description = content&.dig("Post:#{postID}", "previewContent", "subtitle")&.gsub(/[^[:print:]]/ , '')
    postInfo.title = content&.dig("Post:#{postID}", "title")&.gsub(/[^[:print:]]/ , '')
    postInfo.tags = content&.dig("Post:#{postID}", "tags").map{ |tag| tag["__ref"].gsub! 'Tag:', '' }
    
    previewImage = content&.dig("Post:#{postID}", "previewImage", "__ref")
    if !previewImage.nil?
      previewImageFIleName = content&.dig(previewImage, "id")

      imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(postID), pathPolicy.getRelativePath(postID))
      
      absolutePath = imagePathPolicy.getAbsolutePath(previewImageFIleName)

      imageURL = "https://miro.medium.com/max/1400/#{previewImageFIleName}"

      if  ImageDownloader.download(absolutePath, imageURL)
          relativePath = imagePathPolicy.getRelativePath(previewImageFIleName)
          postInfo.previewImage = relativePath
      end
    end

    creatorRef = content&.dig("Post:#{postID}", "creator", "__ref")
    if !creatorRef.nil?
      postInfo.creator = content&.dig(creatorRef, "name")
    end

    colletionRef = content&.dig("Post:#{postID}", "collection", "__ref")
    if !colletionRef.nil?
      postInfo.collectionName = content&.dig(colletionRef, "name")
    end

   

    firstPublishedAt = content&.dig("Post:#{postID}", "firstPublishedAt")
    if !firstPublishedAt.nil?
      postInfo.firstPublishedAt = Time.at(0, firstPublishedAt, :millisecond) 
    end

    latestPublishedAt = content&.dig("Post:#{postID}", "latestPublishedAt")
    if !latestPublishedAt.nil?
      postInfo.latestPublishedAt = Time.at(0, latestPublishedAt, :millisecond)
    end

    postInfo
  end
end