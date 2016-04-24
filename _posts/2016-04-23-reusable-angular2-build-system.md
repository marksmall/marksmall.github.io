---
title:  "Re-usable Angular 2 Build System"
date:   2016-04-23 21:39:48
categories: [NodeJS, NPM, Gulp, Angular 2, JSPM]
tags: [NodeJS, NPM, Gulp, Angular 2, JSPM]
comments: true
---

The purpose of this post is to describe a re-usable Angular 2 Build System.

> **DISCLAIMER:** This project was forked from [ModernWebDevBuild](https://github.com/dsebastien/modernWebDevBuild)


## Why

I've started a few Angular projects in the past, and looked at more examples of other peoples webapps. Each had it's
own **Build System** and I had to re-learn each and on occasion, fix them, before I could get started. Coming from
the Java world where **Maven** has been prevalent, I wanted an opinionated **Build System** similar to Maven. What
I discovered was there are no agreed system, I would say such a system would benefit everyone but I understand it is
hard for people to give up what they have built. Neither am I saying this project is perfect and everyone must use it.
What I am saying is that this works for me, I use it in a couple of projects that are under development and it has
saved me time and effort, allowing me to get on with building the project, not setting it up.

As stated in the disclaimer above, I wasn't the first to consider this and Sebastien Dubois had already built such a
system called [ModernWebDevBuild](https://www.npmjs.com/package/modern-web-dev-build). I liked this project a lot, but
considered it to be lacking 2 major features:

* Configure location of application source to not be `./app`.
* Provide ability to hook in a proxy middleware to run a proxy API server stub during development.


## The Big Decision

Do I fork Sebastien's repo, add missing features and create a pull request for Sebastien or not? I chose to fork and
add the missing features, but not create the pull request. I still don't yet know if that was the right decision, but
it is the one I made. I suppose it is still possible that this will occur, but not so far.

> **NOTE:** I know this goes against my reasons for this project in the first place. Wouldn't it be better to contribute
> to the existing project? Certainly, it would reduce confusion for other users, do we really need competing Build
> Systems, even though they are so very similar. My only excuse is that I've made a number of changes to the original
> that to go back and extract these into pull requests would be a pain and I don't really have the time right now.
> This decision will work for and against me I'm sure.


## What Does The Build System Provide

The Build System uses [Gulp](http://gulpjs.com/) to provide the tasks necessary for a web application. A full list of
features can be found at the [ModernWebDevBuild](https://www.npmjs.com/package/modern-web-dev-build) NPM page, but I
will list a few of the most important here.

### Features

* ES2015 and TypeScript support
* built-in HTTP server with live reloading & cross-device synchronization (BrowserSync)
 * configured to support CORS
* change detection mechanism that automagically:
 * transpiles TypeScript > ESx w/ sourcemaps (you choose the target version)
 * transpiles ES2015 > ESx w/ sourcemaps (you choose the target version)
 * transpiles SASS > CSS w/ sourcemaps
 * checks JavaScript/TypeScript code quality/style and report on the console (without breaking the build)
* production bundle creation support with:
 * CSS bundle creation
 * CSS optimization & minification
 * JS bundle creation
 * JS minification
 * HTML minification
 * images optimization


## New Features

### Configurable Application Source Location

This was a big one for me, while I could live with everything else, I couldn't accept that the front-end code would
exist at the root of the project. It is one thing to be opinionated but there has to be some wiggle room. I updated
the code to look for the override. The config necessary is added to the project using this Build System, if it exists,
that location will be used, else stick with the default.


###  Proxy API Stub Server

This is a feature I've used in all other projects, it just makes it easier to focus on front-end development. As long
as an agreement has been made on the API, it's inputs/outputs, you don't have to worry about the rest. This feature
adds [http-proxy-middleware](https://www.npmjs.com/package/http-proxy-middleware). This listens for requests matching
what the middleware is configured with and forwards the request to that location. I tend to use
[express](https://github.com/expressjs/express), but there are others that can be used, there is a list on the module's
NPM page. Again, the config is set in the project using this Build System, if it exists, the middleware is used,
otherwise not.


### SASS Linting

The Build System already checks the TypeScript code for potential errors but not the SASS. I feel this is just as
valid a feature, so I added it via [gulp-sass-lint](https://www.npmjs.com/package/gulp-sass-lint), you can override
the default rules by providing a *.sass-lint.yml* file.

## Future Features

### Check For Unused CSS

Experience has shown that CSS selectors come and go, and with that, some get left behind and just bloat the app. It
is just good practice to be tidy. It is preferrable that the Build System informs us that CSS is no longer necessary,
giving us the opportunity to remove it. It would also be good if we could ignore the fact that obsolete CSS was found,
it shouldn't prevent development from progressing.


## Summary

This has been a very quick introduction to the Build System, it's introduced what already existed and what was added,
as well as what I'd like to add. I'm interested in other opinions and would love to hear from you so please add an
issue against the [project](https://github.com/marksmall/node-build-web-app/issues) if anything comes to mind.

To see the Build System in action you can clone the Angular 2 seed project that is kept up-to-date with the latest
version of the Build System at [angular2-jspm-seed](https://github.com/marksmall/angular2-jspm-seed).
