# ZMediumToMarkdown

![ZMediumToMarkdown](https://user-images.githubusercontent.com/33706588/184416147-c2ec74d4-7107-484e-8ad2-302340cf6c1f.png)

ZMediumToMarkdown lets you download Medium posts and convert them to markdown format easily.

This project can help you create an auto-sync or auto-backup service from Medium, such as automatically syncing Medium posts to Jekyll or other static markdown blog engines, or backing up Medium posts to Github pages.

[![ZMediumToMarkdown](https://badge.fury.io/rb/ZMediumToMarkdown.svg)](https://rubygems.org/gems/ZMediumToMarkdown)

## Features
- [x] Supports downloading posts and converting them to markdown format
- [x] Supports downloading all posts and converting them to markdown format from any user without requiring login access
- [x] Supports downloading paid content
- [x] Supports downloading all of a post's images to the local drive and converting them to local paths
- [x] Supports parsing Twitter tweet content to blockquotes
- [x] Supports a command line interface
- [x] Converts Gist source code to markdown code blocks
- [x] Converts YouTube links embedded in a post to preview images
- [x] Adjusts a post's last modification date from Medium to the locally downloaded markdown file
- [x] Auto-skips posts that have already been downloaded and whose last modification date from Medium hasn't changed (convenient for auto-sync or auto-backup services, to save server bandwidth and execution time)
- [x] Supports using Github Action as an auto-sync/backup service
- [x] Highly optimized markdown format for Medium
- [x] Native Markdown-style Render Engine
(Feel free to contribute if you have any optimization ideas! MarkupStyleRender.rb)
- [x] Jekyll and social share (og: tag) friendly
- [x] 100% Ruby @ RubyGem

## Result
- [Original post on Medium](https://medium.com/zrealm-ios-dev/avplayer-%E5%AF%A6%E8%B8%90%E6%9C%AC%E5%9C%B0-cache-%E5%8A%9F%E8%83%BD%E5%A4%A7%E5%85%A8-6ce488898003)
- [Downloaded & Converted Output Result](example/2021-01-31-avplayer-實踐本地-cache-功能大全-6ce488898003.md)
![Harry's Idea Draw](https://user-images.githubusercontent.com/33706588/171560402-40b23bec-a836-4468-9f07-68350ce82d4a.jpg)

and I use this tool to convert from Meidum to [jekyllrb](https://zhgchg.li/)

## Setup

### I'M NOT GEEK, PLEASE SHOW ME HOW TO USE WITHOUT CODING
- Please follow this post, step by step to creat your auto backup service without any coding:

[How to use Github Action as your free & no code Medium Posts backup service](https://github.com/ZhgChgLi/ZMediumToMarkdown/wiki/How-to-use-Github-Action-as-your-free-&-no-code-Medium-Posts-backup-service)

### Using Gem
#### If you are familiar with ruby:
1. make sure you have Ruby in your environment (I use `2.6.5p114`)
2. make sure you have Bundle in your environment (I use `2.3.13`)
3. type `gem install ZMediumToMarkdown` in terminal

#### If you are **NOT** familiar with ruby:
1. MacOS comes with a System Ruby pre-installed, but we are **NOT** Recommend to use that, using rvm/rbenv's Ruby instead.
2. install [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to manage Ruby environment
3. install Ruby through rbenv/rym (you can install ruby version `2.6.X`)
4. change the systme ruby to rbenv/rvm's Ruby
5. type `which ruby` in terminal to make sure current Ruby is **NOT** `/usr/bin/ruby`
6. type `gem install ZMediumToMarkdown` in terminal

#### Usage
Command: `ZMediumToMarkdown`

**Downloading all posts from any user**
```
ZMediumToMarkdown -u [USEERNAME]
```

**Downloading single post**
```
ZMediumToMarkdown -p [MEDIUM POST URL]
```

**Update to latest version**
```
ZMediumToMarkdown -n
```

**Remove all downloaded posts data**
```
ZMediumToMarkdown -c
```

**Print current ZMediumToMarkdown Version & Output Path**
```
ZMediumToMarkdown -v
```

#### For Jeklly Dir Friendly

**Downloading all posts from user with Jekyll friendly**
```
ZMediumToMarkdown -j [USEERNAME]
```

**Downloading single post with Jekyll friendly**
```
ZMediumToMarkdown -k [MEDIUM POST URL]
```

#### Manually 
1. MacOS comes with a System Ruby pre-installed, but we are **NOT** Recommend to use that, using rvm/rbenv's Ruby instead.
2. install [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to manage Ruby environment
3. install Ruby through rbenv/rym (you can install ruby version `2.6.X`)
4. change the systme ruby to rbenv/rvm's Ruby
5. type `which ruby` in terminal to make sure current Ruby is **NOT** `/usr/bin/ruby`
6. type `gem install bundler` install RubyGem dependency manager (you can install Bundle version `2.3.x`)
7. git clone or download this project
8. type `cd ./ZMediumToMarkdown` go into project
9. type `bundle install` in terminal to install project dependencies
10. use `bundle exec ruby [USAGE Command]` in the furture (USAGE Command write down below)

#### Usage
Execute File: `bin/ZMediumToMarkdown`

**Downloading all posts from any user**
```
bundle exec ruby bin/ZMediumToMarkdown -u [USEERNAME]
```

**Downloading single post**
```
bundle exec ruby bin/ZMediumToMarkdown -p [MEDIUM POST URL]
```

**Update to latest version**
```
bundle exec ruby bin/ZMediumToMarkdown -n
```

**Remove all downloaded posts data**
```
bundle exec ruby bin/ZMediumToMarkdown -c
```

**Print current ZMediumToMarkdown Version & Output Path**
```
bundle exec ruby bin/ZMediumToMarkdown -v
```

## Output
### Where can I find the results of the downloaded post?
The default path of the downloaded post will be in the `./Output` directory.
- Downloading all posts from user：`./Ouput/users/[USERNAME]/posts/[POST_PATH_NAME]`
- Downloading single post：`./Ouput/posts/[POST_PATH_NAME]`
- Post's images：`[POST_PATH_NAME]/images/[POST_ID]/[IMAGE_PATH_NAME]`

## Disclaimer
This repository is for research purposes only, the use of this code is your responsibility.

- Code authors take NO responsibility and/or liability for how you choose to use any of the source code available here.
- By using any of the files available in this repository, you understand that you are AGREEING TO USE AT YOUR OWN RISK.
- ALL files available here are for EDUCATION and/or RESEARCH purposes ONLY.

## Using Github Action as your [free](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration) auto sync/backup service
```yml
name: ZMediumToMarkdown
on:
  workflow_dispatch:
  schedule:
    - cron: "10 1 15 * *" # At 01:10 on day-of-month 15.
jobs:
  ZMediumToMarkdown:
    runs-on: ubuntu-latest
    steps:
    - name: ZMediumToMarkdown Automatic Bot
      uses: ZhgChgLi/ZMediumToMarkdown@main
      with:
        command: '[USAGE Command]' # e.g. -u zhgchgli
```
[exmaple repo](https://github.com/ZhgChgLi/ZMediumToMarkdown-github-action)

## More Tools
- [ZReviewTender](https://github.com/ZhgChgLi/ZReviewTender) uses brand new App Store & Google Play API to resend App reviews to your Slack channel automatically.

## Made In Taiwan 🇹🇼🇹🇼🇹🇼
- [ZhgChg.Li (CH)](https://zhgchg.li/)
- [ZhgChgLi's Medium (CH)](https://blog.zhgchg.li/)

[![Buy Me A Coffe](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20beer!&emoji=%F0%9F%8D%BA&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/zhgchgli)

If you find this library helpful, please consider starring the repo or recommending it to your friends.

Feel free to open an issue or submit a fix/contribution via pull request. :)
