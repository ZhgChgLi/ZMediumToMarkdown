# ZMediumToMarkdown

![Harry's Idea Draw](https://user-images.githubusercontent.com/33706588/170814437-98c067f1-bee1-47ad-941a-d943352a9cec.jpg)

ZMediumToMarkdown lets you download Medium post and convert it to markdown format easily.

This project can help you to make an auto-sync or auto-backup service from Medium, like auto-sync Medium posts to Jekyll or other static markdown blog engines or auto-backup Medium posts to the Github page.

## Features
- [X] Support download post and convert to markdown format
- [X] Support download all posts and convert to markdown format from any user without login access.
- [X] Support download paid content
- [X] Support command line interface
- [X] Download all of post's images to local and convert to local path
- [X] Convert [Gist](https://gist.github.com/) source code to markdown code block
- [X] Convert youtube link which embed in post to preview image
- [X] Adjust post's last modification date from Medium to the local downloaded markdown file
- [X] Auto skip when post has been downloaded and last modification date from Medium doesn't changed (convenient for auto-sync or auto-backup service, to save server's bandwidth and execution time)
- [X] [Support using Github Action as auto sync/backup service](https://github.com/ZhgChgLi/ZMediumToMarkdown/tree/main#using-github-action-as-your-free-auto-syncbackup-service)
- [X] Highly optimized markdown format for Medium
- [X] Native Markdown Style Render Engine
(Feel free to contribute if you any optimize idea! `MarkupStyleRender.rb`)
- [X] jekyllrb friendly

## Result
- [Original post on Medium](https://medium.com/pinkoi-engineering/%E5%AF%A6%E6%88%B0%E7%B4%80%E9%8C%84-4-%E5%80%8B%E5%A0%B4%E6%99%AF-7-%E5%80%8B-design-patterns-78507a8de6a5)
- [Downloaded & Converted Output Result](example/實戰紀錄-4-個場景-7-個-design-patterns-78507a8de6a5.md)
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

## Acknowledgement
- [Ruby](https://www.ruby-lang.org/zh_tw/)
- [net-http](https://github.com/ruby/net-http)
- [nokogiri](https://github.com/sparklemotion/nokogiri)
- [reverse_markdown](https://github.com/xijo/reverse_markdown)

## Made In Taiwan 🇹🇼🇹🇼🇹🇼
- [ZhgChgLi's Medium (CH)](https://blog.zhgchg.li/)

If this is helpful, please help to star the repo or recommend it to your friends.

Please feel free to open an Issue or submit a fix/contribution via Pull Request. :)
