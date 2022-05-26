# ZMediumToMarkdown

## Feature
- Support convert Gist source code to markdown code block
- Support download medium post's image to local
- Support download youtube preview image to local and link it as image

## Setup
1. clone this project
2. bundle install

## Usage
### Downloading all posts from any user
```
bundle exec ruby bin/ZMediumFetcher -u [USEERNAME]
```

### Downloading single post
```
bundle exec ruby bin/ZMediumFetcher -p [MEDIUM POST URL]
```


### ToDo
- [ ] official release
- [ ] complete readme
- [ ] L10N Readme
- [ ] Supoort replace post link to local link
- [ ] Term of use check
- [ ] Error handle
- [ ] Github Action Templete (so you can backup your medium post to markdown on github repo automatically)
