Gem::Specification.new do |gem|
    gem.authors       = ['ZhgChgLi']
    gem.description   = 'ZMediumToMarkdown lets you download Medium post and convert it to markdown format easily.'
    gem.summary       = 'This project can help you to make an auto-sync or auto-backup service from Medium, like auto-sync Medium posts to Jekyll or other static markdown blog engines or auto-backup Medium posts to the Github page.'
    gem.homepage      = 'https://github.com/ZhgChgLi/ZMediumToMarkdown'
    gem.files         = Dir['lib/**/*.*']
    gem.executables   = ['ZMediumToMarkdown']
    gem.name          = 'ZMediumToMarkdown'
    gem.version       = '2.3.3'
  
    gem.license       = "MIT"
  
    gem.add_dependency 'nokogiri', '>= 1.14.3', '< 1.16.0'
    gem.add_dependency 'net-http', '~> 0.1.0'
    gem.add_dependency 'rubyzip', '~> 2.3.2'
end