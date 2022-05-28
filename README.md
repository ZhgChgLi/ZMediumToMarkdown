# ZMediumToMarkdown

# Feature
- Support convert Gist source code to markdown code block
- Support download medium post's image to local
- Support download youtube preview image to local and link it as image

# Setup
1. clone this project
2. bundle install

# Usage
## Downloading all posts from any user
```
bundle exec ruby bin/ZMediumFetcher -u [USEERNAME]
```

## Downloading single post
```
bundle exec ruby bin/ZMediumFetcher -p [MEDIUM POST URL]
```

# Disclaimer
This repository is for research purposes only, the use of this code is your responsibility.

- Code authors take NO responsibility and/or liability for how you choose to use any of the source code available here.
- By using any of the files available in this repository, you understand that you are AGREEING TO USE AT YOUR OWN RISK.
- ALL files available here are for EDUCATION and/or RESEARCH purposes ONLY.


# To Do
- [ ] official release
- [ ] complete readme
- [ ] L10N Readme
- [ ] Supoort replace post link to local link
- [ ] Term of use check
- [ ] Error handle
- [ ] Github Action Templete (so you can backup your medium post to markdown on github repo automatically)
