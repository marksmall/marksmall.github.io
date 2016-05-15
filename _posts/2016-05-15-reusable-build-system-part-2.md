---
title:  "Re-usable Angular 2 Build System - Part 2"
date:   2016-05-15 14:55:06
categories: [NodeJS, NPM, Gulp, Angular 2, JSPM]
tags: [NodeJS, NPM, Gulp, Angular 2, JSPM]
comments: true
---

## Introduction
In a [previous blog](http://marksmall.github.io/2016/reusable-angular2-build-system/) I gave a very quick introduction to a re-usable Angular 2
with JSPM Build System. In this part we delve more into the Build System and how it works.


### Project Structure

All the interesting code is under the `$ROOT/src` directory. This contains all functionality the system provides the user. This provides the
tasks, templates, configuration and any utilities used to provide the Build System.

+ $ROOT
  + src
    + gulp
      + tasks
        - **Inividual Tasks**
      + templates
        - taskLoaderTemplate.js
      - abstractTaskLoader.js
      - config.js
      - utils.js
    + tests
    - index.js

> The code in `$ROOT/gulp` is the Build System for this project only, users never see this. The content of this may be a future Blog post.


## Build System

At it's heart, the build system is a collection of **Gulp Tasks**, it is these tasks that do the work, they combine to handle the life-cycle of
an Angular 2 project. Many projects have one big *Gulpfile.js*, whose job is to define every task available. This works and for very simple
system is probably best, but most systems are not that simple, they cover many disparate tasks. If we combine them into one file it can get
unwieldy and difficult to maintain or extend. To that end you see more and more Build Systems broken up into modular tasks, each with their own
*separation of concern*. All this means is that each modular task does one thing and one thing only. Tasks are what make the Build System work.

but lets take a step back, how are all these disparate tasks brought together?

### Task Loader

We need a way to load all the available tasks, hence the *Task Loader* (see `$ROOT/src/index.js`), it is this modules responsibility to ensure
that all tasks in the specified directory(s) are loaded and available to users.

The *TaskLoader* module itself is not very complicated, it provides one function *registerTasks*, this function takes 2 parameters:

* **Gulp** object
* **Options** object

Firstly it it checks if these parameters have been provided and if not sets sensible defaults i.e. *require* Gulp and define an empty options
object. It then adds the option as a variable of the Gulp object, which will be supplied to each Task. The function then loads each
task and asks each to *Register* themselves, providing the Gulp object as a parameter. If the task doesn't provide a *registerTask* function an
error is thrown as it is not a valid task.

**What if we want to extend the Build System?**

It would be pretty arogant ot think that this system is perfect, everyone I'm sure would be able to come up with a corner case that is not
handled by the out-of-the-box system presented here. To that extent, we need a means of permitting users to augment it. This will be discussed
later in the post.

That's it, not exactly rocket science, so on to the tasks.


### Tasks

There are many tasks provided by the system (In no real order):

* Check JavaScript Quality
* Check JavaScript Style
* Clean all generated files
* Copy all files except HTML/CSS/JavaScript to the destination directory
* What to do when the user just type `gulp` i.e. the Default tasks to run
* Optimize HTML and ouput to the HTML destination directory.
* Optimize Images and ouput to the Images destination directory.
* Lint SASS files
* Transpile JavaScript code using [Babel](https://babeljs.io/), generate *Source Maps* and copy files to the Javascript destination directory
* Package all JavaScript code for production
* Transpile all TypeScript to ESx (determined by configuration), generate *Source Maps* and output to the TypeScript destination directory
* Run **Development Server**, most should be common with running `gulp serve`, this is the purpose of this task. It sets up **BrowserSync** and
configures the **Stub API Proxy**, if it has been defined, otherwise it is ignored.
* Run **Production Server**, this enables us to view the client as it would be running in production, all code has been combined and minified
to reduce the payload (Be careful, things can look fine when running the development server but I recommend running the distributed code
frequently as many problems can arise by combining and minimizing code (I've found that out the hard way)
* Compile SASS into CSS, add vendor prefixes, generate *Source Maps* and output to the CSS destination directory
* Optimize and minimize project CSS for production
* Optimize and minimize vendor CSS for production
* Run Unit tests
* Lint TypeScript files.
* Validate project *package.json* file

Each task extends the *AbstractTaskLoader* class, this provides one function *registerTask*. This function takes the **Gulp** object as a parameter,
so the class can decorate the **Gulp** object with the required functionality. Obviously some tasks are more complicated than others, for instance,
the *CleanTaskLoader* class is very simplistic and I advise looking at it first, all it does is deletes all generated files.

### Using the System

**How do I know what tasks are available?**

Each task provides it's own description, if you type `gulp help` in your root project directory, a list of the task name and it's description
is displayed to the user.

**What is the run order of these tasks, surely some must come before others?**

If you look at `$ROOT/src/gulp/tasks/DefaultTaskLoader.js`, this provides the public API of tasks, the run order and which can be done in
parallel:

+ default
  + validate-package-json
    + Run in parallel
      - clean
      - ts-lint
      - check-js-style
      - check-ts-quality
    + Run in parallel
      - scripts-typescript
      - scripts-javascript
    + Run in parallel
      + copy
        - styles-vendor-dist
        - styles-dist
        - scripts-javascript-dist
        - html
        - images

This doesn't mean you cannot run individual tasks and it may be that the task itself requires other tasks as dependencies, meaning they must
be completed before this task starts. More than likely these will be private tasks, these are tasks that are only useful in providing the
environment for the public task to work, they are not intended to be run manually.

I have only given a high-level description of each task so far, I think it is important to understand the functionality provided before jumping
into the how the tasks provide it. I'm only going to discuss what I consider to be the most important tasks i.e the ones I think will be run
manually or that highlight important features.

### Serve Task

This task is the one that will be run the most, you want to be able to see changes made straight-away and it is this task that provides this
feature. It provides a number of sub-tasks:

* serve-scripts-typescript
* prepare-serve-scripts-typescript
* serve-scripts-javascript
* prepare-serve-scripts-javascript
* serve
* prepare-serve

These sub-tasks use each other and other tasks provided to run the **Development Server** and possibly a **Proxy API Server**. The development
server enables developers to see what changes they make to the code in Browsers. The Browsers reload themselves when changes are made to give
meaningful feedback to the developer. To provide this, the code has to be checked and compiled, no point reloading of the code is just plain
wrong. The **Proxy API Server** stubs back-end server calls with canned responses, enabling developers to vary responses i.e. success/error. If
code changes, depending on what file-type was changed, the applicable task is run to handle the change and the browser reloads.

Typical output from `gulp serve`:

```
[16:29:32] Starting 'serve'...
[16:29:32] Starting 'prepare-serve'...
[16:29:32] Starting 'clean'...
[16:29:32] Finished 'clean' after 3.54 ms
[16:29:32] Starting 'ts-lint'...
[16:29:32] Starting 'check-js-style'...
[16:29:32] Starting 'check-js-quality'...
[16:29:32] Starting 'proxy'...
Starting Proxy API Server!
[16:29:32] API Stub listening on port: 8000
[16:29:32] Finished 'proxy' after 9.43 ms
[16:29:32] Finished 'prepare-serve' after 155 ms
[16:29:32] Finished 'serve' after 208 ms
[16:29:32] check-js-style all files 46 B
[16:29:32] Finished 'check-js-style' after 248 ms
[16:29:32] Finished 'check-js-quality' after 143 ms
[16:29:32] ts-lint all files 3.18 kB
[16:29:32] Finished 'ts-lint' after 410 ms
[16:29:32] Starting 'scripts-typescript'...
[16:29:32] Starting 'scripts-javascript'...
[16:29:32] Starting 'sass-lint'...
[16:29:32] Starting 'styles'...
[16:29:32] Starting 'validate-package-json'...
[16:29:33] package.json is valid
[16:29:33] Finished 'validate-package-json' after 404 ms
[MWD] Access URLs:
 -------------------------------------
       Local: http://localhost:3000
    External: http://192.168.0.70:3000
 -------------------------------------
          UI: http://localhost:3001
 UI External: http://192.168.0.70:3001
 -------------------------------------
[MWD] Serving files from: .
[MWD] Serving files from: ./.tmp
[MWD] Serving files from: ./app
[16:29:36] scripts-javascript all files 152 B
[16:29:36] Finished 'scripts-javascript' after 3.45 s
[16:29:38] sass-lint all files 16.24 kB
[16:29:38] Finished 'sass-lint' after 5.47 s
[16:29:38] styles all files 14.78 kB
[16:29:38] Finished 'styles' after 5.48 s
[16:29:38] scripts-typescript all files 7.73 kB
[16:29:38] Finished 'scripts-typescript' after 5.5 s
```

This output may be interspersed with warning/error messages so be careful to check, especially if it scrolls off-screen. The above shows the
order in which tasks are run, not all are provided by the **serve** task, but are dependencies the task needs to work. When this task is run
the development server uses all the source files individually, making isolating errors easier. The source is compiled to JavaScript and it is
the JavaScript under `$ROOT/.tmp` that is used, images and other static media are taken from `$ROOT/app` or wherever you have configured the
source of your application (this is done via a src override in the project **options** object).


### Serve Distributed Code Task

As I said before, it is advisable to run the distributed code regularly as many problems can arise from the combination and minification of
code, the earlier you see the problem the cheaper it is to fix.



Typical output from `gulp serve-dist`:

```
[16:35:52] Starting 'serve-dist'...
[16:35:52] Starting 'default'...
[16:35:52] Starting 'validate-package-json'...
[16:35:52] Finished 'default' after 8.43 ms
[16:35:52] Finished 'serve-dist' after 21 ms
[16:35:52] package.json is valid
[16:35:52] Finished 'validate-package-json' after 36 ms
[16:35:52] Starting 'clean'...
[16:35:52] Finished 'clean' after 3.05 ms
[16:35:52] Starting 'ts-lint'...
[16:35:52] Starting 'check-js-style'...
[16:35:52] Starting 'check-js-quality'...
[MWD] Access URLs:
 -------------------------------------
       Local: http://localhost:3000
    External: http://192.168.0.70:3000
 -------------------------------------
          UI: http://localhost:3001
 UI External: http://192.168.0.70:3001
 -------------------------------------
[MWD] Serving files from: ./dist
[16:35:53] check-js-style all files 46 B
[16:35:53] Finished 'check-js-style' after 241 ms
[16:35:53] Finished 'check-js-quality' after 132 ms
[16:35:53] ts-lint all files 3.18 kB
[16:35:53] Finished 'ts-lint' after 435 ms
[16:35:53] Starting 'scripts-typescript'...
[16:35:53] Starting 'scripts-javascript'...
[16:35:56] scripts-javascript all files 152 B
[16:35:56] Finished 'scripts-javascript' after 3.09 s
[16:35:57] scripts-typescript all files 7.73 kB
[16:35:57] Finished 'scripts-typescript' after 4.33 s
[16:35:57] Starting 'copy'...
[16:35:57] copy all files 39.93 kB
[16:35:57] Finished 'copy' after 45 ms
[16:35:57] Starting 'styles-vendor-dist'...
[16:35:57] Starting 'styles-dist'...
[16:35:57] Starting 'scripts-javascript-dist'...
[16:35:57] The production JS bundle will NOT be mangled!
[16:35:58] Starting 'html'...
[16:35:58] The HTML will NOT be minified!
[16:35:58] Starting 'images'...
[16:35:58] Stream contents: app/styles/vendor.scss
[16:35:58] Stream contents: 1 item
[16:35:59] styles-vendor-dist all files 1.87 kB
[16:35:59] Finished 'styles-vendor-dist' after 1.87 s
[16:35:59] html all files 52.88 kB
[16:35:59] Finished 'html' after 1.32 s
[16:35:59] images all files 7.28 kB
[16:35:59] Finished 'images' after 1.48 s
[16:36:00] styles-dist all files 3.86 kB
[16:36:00] Finished 'styles-dist' after 2.53 s
[16:36:32] Finished 'scripts-javascript-dist' after 35 s
```

This does everything the *serve* task does as well as combining all application code and CSS into single files. It creates a separate vendor
bundled CSS file for good separation of styles. All files are copied to the `$ROOT/dist` directory and it is from there the project is served
from, this enacts what would happen in production.


## Summary

I hope this gets you up-to-speed with how this Build System works, the features it provides and how the important ones work, CIAO.
