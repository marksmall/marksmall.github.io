---
title:  "Getting Started with GitHub Pages!"
date:   2016-04-19 23:55:02
categories: [jekyll, github, github pages]
tags: [jekyll, github, github pages]
---
I've just started with GitHub Pages, so I am the proverbial newbie. See my failures and successes
when starting a GitHub Pages site.

Skip why I did it and get to the [meat and bones](#the-beginning).


## Why
Like most I have my own GitHub repos, while they are public, who really cares, right?, there are far better toys out
there to play with. While I work in software I don't really contribute to open-source
projects, so I've nothing really fancy to show off. That being said, I've started a project to build a
[Re-usable Angular 2 Build System](https://github.com/marksmall/node-build-web-app). I figured I may as well write
up my experiences but I need somewhere to do that. GitHub Pages seemed the sensible option, more and more
infrastructure for projects exists on-line e.g. GitHub, travis-ci etc. GitHub Pages seemed the logical choice, so
I figured I'd just jump in.

I've always thought people interested in software are broadly of 2 types, those that read and read about the subject
before doing anything and those that just dive in. For better or worse, I'm the type that dives in. What does this
mean? Well, normally I do a bit of googling, open 10 pages on the topic, I'm lucky if I read a couple before I get
antsy and want to start using it. As usual this is exactly what happened. I ignored the generation of a new project
in favour of looking for a seed project.

> **NOTE:** Once you've gone through some docs, I advise using a seed project, these have generally fixed many of
> of the initial project startup issues you come across.

Most docs take ages to explain a few fundamental concepts and I get bored easily, so I end up skipping most of them
and learn by trial and error. Don't get me wrong, I do go back to the docs and blogs, but only when I've got a
specific problem.


## The Beginning

I started by following the steps in [this blog](https://github.com/poole/poole), the gems, I installed manually as root.
This was very quick and easy to follow, the folder structure was simple and it gave me a good starting point. I discovered
the gems that where necessary by running the jekyll development server `jekyll serve`, this produced errors until I
installed all necessary gems:

`sudo gem install jekyll jekyll-pagination jekyll-gist`

Once I got the development server running, I was able to review the project. I felt the look and feel was a bit too
minimal, neither was I very happy with the navigation. I did a quick google to see what
[Jekyll themes](http://jekyllthemes.org/) existed. There are many, the one I opted for was
[Uno](http://jekyllthemes.org/themes/jekyll-uno/).


## Setup

After cloning the repo I quickly realised installing gems manually as root was not going to work. Initially I didn't
notice the *Gemfile*. Using this file as an input to [Bundler](http://bundler.io/), makes installing
all necessary dependencies really easy, all you need to do is `bundle install`.

> **NOTE:** My advice, all such projects should use a Gemfile, it, just makes life easier for those using your project.
> I also advise installing everything locally, to prevent clashes between projects. Some gems may need to be installed
> as root, you can get round that by using `bundle install --path vendor/bundle`.

I got errors as I had removed the previously installed GEMs:
```
sudo gem uninstall jekyll
sudo gem uninstall jekyll-pagination
sudo gem uninstall jekyll-gist
```

To fix this I added the necessary GEMs to the *Gemfile*:

```
gem "jekyll"
gem "jekyll-paginate"
```


## Building

When running the jekyll development server `jekyll serve`, I kept getting the same error:

```
Configuration file: /home/msmall/dev/projects/testbench/marksmall.github.io/_config.yml
/var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/plugin_manager.rb:30:in `require': cannot load such file -- jekyll-paginate (LoadError)
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/plugin_manager.rb:30:in `block in require_gems'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/plugin_manager.rb:27:in `each'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/plugin_manager.rb:27:in `require_gems'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/plugin_manager.rb:19:in `conscientious_require'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/site.rb:97:in `setup'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/site.rb:49:in `initialize'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/commands/build.rb:30:in `new'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/commands/build.rb:30:in `process'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/lib/jekyll/commands/serve.rb:26:in `block (2 levels) in init_with_program'
        from /var/lib/gems/2.3.0/gems/mercenary-0.3.6/lib/mercenary/command.rb:220:in `block in execute'
        from /var/lib/gems/2.3.0/gems/mercenary-0.3.6/lib/mercenary/command.rb:220:in `each'
        from /var/lib/gems/2.3.0/gems/mercenary-0.3.6/lib/mercenary/command.rb:220:in `execute'
        from /var/lib/gems/2.3.0/gems/mercenary-0.3.6/lib/mercenary/program.rb:42:in `go'
        from /var/lib/gems/2.3.0/gems/mercenary-0.3.6/lib/mercenary.rb:19:in `program'
        from /var/lib/gems/2.3.0/gems/jekyll-3.0.3/bin/jekyll:17:in `<top (required)>'
        from /usr/local/bin/jekyll:23:in `load'
        from /usr/local/bin/jekyll:23:in `<main>'
```

I fixed this/got round it, not sure which yet, by using `bundle exec jekyll serve`. This is because I installed all
dependencies using **bundler**, this executes the command `jekyll serve` making all gems within the *Gemfile* available.

> **NOTE:** To simplify life I made a small script to install all dependencies and run the development server. This
> I'm sure will also be of benefit to those learning Jekyll, just like I am.

```
#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage : $0 setup|serve"
    exit
fi

case "$1" in

setup)
    echo "Installing necessary GEMs locally"
    bundle install --path vendor/bundle
    ;;
serve)
    echo  "Starting Development Server"
    bundle exec jekyll serve
    ;;
*)
    echo "Action: $1 is not valid, use setup|serve"
    ;;
esac
```

And that's it as they say, not exactly earth-shattering by any means but hopefully it saves you from some of the
problems I encountered. Now it is all about generating content.

> **UPDATE:** I tried creating a new post using todays date, yet it would never show as a post during development.
> After a bit of googling I found out I had to add `future: true` to the *_config.yml* config file for Jekyll. The
> other option is to ensure the date in the filename is in the past.

You are welcome to use this repo as a starting point for your own project, get the source from my
[GitHub Repo](https://github.com/marksmall/marksmall.github.io.git)
