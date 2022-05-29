Gem::Specification.new do |gem|
    gem.authors       = ['ZhgChgLi']
    gem.description   = 'ZMediumToMarkdown lets you download Medium post and convert it to markdown format easily.'
    gem.summary       = 'This project can help you to make an auto-sync or auto-backup service from Medium, like auto-sync Medium posts to Jekyll or other static markdown blog engines or auto-backup Medium posts to the Github page.'
    gem.homepage      = 'https://github.com/ZhgChgLi/ZMediumToMarkdown'
    gem.files         = Dir['lib/**/*.*']
    gem.executables   = ['ZMediumFetcher']
    gem.name          = 'ZMediumToMarkdown'
    gem.version       = '1.0.3'
  
    gem.license       = "MIT"
  
    gem.add_dependency 'nokogiri', '~> 1.13.1'
    gem.add_dependency 'reverse_markdown', '~> 2.1.1'
    gem.add_dependency 'net-http', '~> 0.1.0'
end