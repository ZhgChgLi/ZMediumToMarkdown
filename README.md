# ZMediumToMarkdown
ZMediumToMarkdown lets you download Medium post and convert it to markdown format easily.

This project can help you to make an auto-sync or auto-backup service from Medium, like auto-sync Medium posts to Jekyll or other static markdown blog engines or auto-backup Medium posts to the Github page.

You can also use [Github Action](https://github.com/features/actions) as the auto service.

## Features
- [X] Support download post and convert to markdown format
- [X] Support download all posts and convert to markdown format from any user without login access.
- [X] Support command Line Interface
- [X] Download all of post's images to local and convert to local path
- [X] Convert [Gist](https://gist.github.com/) source code to markdown code block
- [X] Convert youtube link which embed in post to preview image


## Setup
1. make sure you have Ruby in your environment (I use ruby `2.6.5p114`)
2. git clone or download this project
3. type `cd ./ZMediumToMarkdown` go into project
4. type `bundle install` in terminal to install project dependencies

## Usage
### Downloading all posts from any user
```
bundle exec ruby bin/ZMediumFetcher -u [USEERNAME]
```
![image](https://user-images.githubusercontent.com/33706588/170810772-ec7cd618-d208-4fca-9fe5-9ae6ee745951.png)

### Downloading single post
```
bundle exec ruby bin/ZMediumFetcher -p [MEDIUM POST URL]
```
![image](https://user-images.githubusercontent.com/33706588/170810799-7da207ff-0642-4beb-9b3a-6af11d6e918d.png)

## Output
### Where can I find the results of the downloaded post?
The default path of the downloaded post will be in the `./Output` directory.
- Downloading all posts from user：`./Ouput/users/[USERNAME]/posts/[POST_PATH_NAME]`
- Downloading single post：`./Ouput/posts/[POST_PATH_NAME]`
- Post's images：`[POST_PATH_NAME]/images/[POST_ID]/[IMAGE_PATH_NAME]`
### Example
- [Original post on Medium](https://medium.com/pinkoi-engineering/%E5%AF%A6%E6%88%B0%E7%B4%80%E9%8C%84-4-%E5%80%8B%E5%A0%B4%E6%99%AF-7-%E5%80%8B-design-patterns-78507a8de6a5)
- [Downloaded & Converted Output Result](example/實戰紀錄-4-個場景-7-個-design-patterns-78507a8de6a5.md)

## Disclaimer
This repository is for research purposes only, the use of this code is your responsibility.

- Code authors take NO responsibility and/or liability for how you choose to use any of the source code available here.
- By using any of the files available in this repository, you understand that you are AGREEING TO USE AT YOUR OWN RISK.
- ALL files available here are for EDUCATION and/or RESEARCH purposes ONLY.


## Acknowledgement
- [Ruby](https://www.ruby-lang.org/zh_tw/)
- [net-http](https://github.com/ruby/net-http)
- [nokogiri](https://github.com/sparklemotion/nokogiri)
- [reverse_markdown](https://github.com/xijo/reverse_markdown)

## Made In Taiwan 🇹🇼🇹🇼🇹🇼
- [ZhgChgLi's Medium (CH)](https://blog.zhgchg.li/)

Please feel free to open an Issue or submit a fix/contribution via Pull Request. :)
