---
title:  "Automated Build and Deploy Java Webapps"
date:   2016-05-15 22:25:06
categories: [Autmation, Java, Webapp, Build, Deploy]
tags: [Autmation, Java, Webapp, Build, Deploy]
comments: true
---

## Development Automation

1. What steps are involved in Software Development?
1. What is involved in getting development code from your machine to the server?
1. Why do things manually?
1. Why automate?


## Steps involved

> Q. What steps are involved in Software Development?

1. compile
1. Unit Test
1. Code Analysis
1. Integration Test
1. Package
1. Deploy
1. Functionality Test
1. Stress Test
1. Build Release
1. Peer Review

These steps combine to ensure that code is well written, tested, packaged and conforms to style guides etc. This is normally done via a 
**Build System** e.g. Maven, Gradle, NPM etc. Not every step in absolutely necessary, some are omitted due to good reasons, but most are omitted due to 
laziness, fear and cost. Laziness is contentious but we are all guilty of laziness from time-to-time, take **Peer Reviews**, unless you 
are the sole developer, this is an often omitted, but really valuable step, why wouldn't a team peer review code? How else do we grow as 
a team, increase knowledge, prevent feature silos. 

> Q. Why do we use **Build Systems**?

The reasons are various but a few are:

* Well defined code structures.
* Repeatability.
* Out-of-the-box solution.

## Principles of scripting build and deploy

> Q. What is involved in getting development code from your machine to the server?

### Build and Deployment example

1. compile
1. Unit Test
1. Code Analysis Test
1. Integration Test
1. Package
1. Deploy

This is probably the ideal, most projects will have a subset, especially the testing steps. The **Deploy** can be misleading, what this means
is, deploy the **Artifact**, the thing that will eventually end up on a server somewhere, not to the server, but to a location where it can be
retrieved and (sorry) *deployed* on the server. The tool you choose may vary, suffice to say, whatever the tool, it should provide the ability
to do the above steps.

## Continuous Integration

> Q. What is Continuous Integration?

> Continuous Integration (CI) is a development practice that requires developers to integrate code into a shared repository several times 
> a day. Each check-in is then verified by an automated build, allowing teams to detect problems early.

**Jenkins** is one of the most commonly used CI servers, it can integrate with a number of tools e.g. GitHub/GitLab, so that when code is updated,
Jenkins is informed and it will run the applicable build job. 

### Case-study Delivery Pipeline

A previous service I was responsible for had 11 Tomcat applications, each uses Maven so there is already a level of conformity, it guarantee the
code structure is the same between all apps.

The Jenkins jobs covered:

* Build (one per application/library)
* Deploy (Shared between all applications)
* Release
* Notify New Relic (Monitoring)
* Notify Relevant Parties

Each application has a **Build** job e.g. *dm-build-roam*, *dm-build-logger* etc. This takes care of the first tenet of **Continous Delivery**, 
*build once, deploy everywhere*. It has to be said, every instance you come across of a **Build Pipeline** will be implemented differently.
It would be great to have a repeatable system but there are none I'm aware of. The next step, **deploy** is where you will find the most 
variance. This is a **Parameterized Job**, based on these parameters, the job:

* Retrieves the deployable artifact
* Copies it to an environment e.g. testing|staging|production
* Runs a deploy script
* Restarts the Tomcat server (this could easily be a web server, or something else entirely)

All our distributions are held in an **Artifact Repository**. Jenkins has a plugin to retrieve a specific distribution, it then scp's the 
distribution to a remote machine. Once the file(s) are copied, Jenkins runs a script on the remote machine, the script knows how to unpack 
the code and restart the Application Container. So, now we have the code running on a server, all this is automated.

**NOTE:** If you where to use **Docker**, this could be made even simpler, you remove the need for a deploy script, or restarting a server,
          you would:

1. Retrieve the deployable artifact (Docker image)
1. Deploy it to an environment
1. Start up the image container

Lets recap:

1. We use a **Build System**, this provides sensible defaults for code structure, a task life-cycle such as Compile, Unit Test,
Package and eventually build a **Release** (we'll talk more about that later).
1. Once the developer is satisfied with the feature/bug they are working on, they push the **Feature Branch** (GitHub/GitLab) and create a
**Code Review**.
1. A discussion between the developer(s)/reviewer(s) is had until they are satisfied, then the code is merged.
1. The **Repository Host (GitHub|GitLab) informs the CI Server (Jenkins) there is new code in **master** branch.
1. The CI Server builds the code and deploys the distribution to the **Artifact Repository**.
1. The CI Server build job calls the deploy job to get the distribution and deploy to the **testing** environment.

Once the **master** branch is updated, there is no further human involvement, the application is updated in **testing** automatically, leaving
the developer free to concentrate on more interesting stuff.

At set times, the distribution is deployed to **staging**, this requires a developer to kick-off the **Deploy** job, providing the appropriate 
parameters. We could automate this to happen after the deploy to **testing**, but we want a certain level of stability in **staging**, this is our
**QA** environment after all. You don't want to update **staging** while QA testing is happening. 

A deploy to **staging** calls the **notify** job to notify relevant parties, the notification reports what has changed, to help target testing. 
Once the QA testing is complete and we are satisfied the code is ready to deploy to **production**, we therefore build a **Release**. It can be
argued that this breaks the first tenet of **Continuous Delivery**, *build once, deploy everywhere*, but we have found the benefits outway this. The 
release increments the version, tags it and commits the changes, at it's heart, it is a snapshot in time that can be rolled back to at any point.
The **release** job calls the **deploy** job to update **testing** and **staging**, which runs the **notify** job to inform relevant parties.
You can see why it is called a **Pipeline**, jobs calling jobs, sometimes based on parameters supplied.

Not all steps in the **Delivery Pipeline** are automated, some need manual intervention to start, but these jobs will still call other jobs
to complete the whole process. A good example is the **Deploy** to **production**, it is doubtful you want this automated, you may want to
go further and state that only **privileged** users can **deploy** to **production**.

### Complete Delivery Pipeline

<a href="http://marksmall.github.io/images/dm-deployment.png">
   <img src="http://marksmall.github.io/images/dm-deployment.png">
</a>

## What isn't so good about this setup?

Jenkins is okay, but in my opinion it is a glorified task runner, yes it has many plugins, some better than others, but it can be difficult 
to configure things, such as notifications. We prefer to have other tools do the work, but use Jenkins jobs to run them. The Jenkins build 
jobs actually don't do any work, that is left up to the **Build System** or some bespoke scripts. A good reason for this is the knowledge is
kept close to the code, not split across Jenkins, meaning your not **locked-in** to any particular tool. The notification jobs are actually
parameterized Node scripts.

Another issue we have encountered is that collecting parameter values for the parameterized jobs can be a pain. For instance, you have to 
supply the version of the distribution to **deploy**, usually it is the **latest**, but the developer has to go and find out what that is. 
It's not difficult, just cumbersome, this is where **Gort**, our Hubot Chatbot comes in.

## ChatOps

> Q. What does ChatOps give us? 

The primary reason for us using a ChatBot is to simplify interacting with the **Delivery Pipeline**, it integrates well with various 
**Messaging Services**, in our case **Slack**. New developers can learn the operations by watching others use the ChatBot. So it gives
us a bit of **Knowledge Transfer** for no cost.

The main operations carried out in ChatOps are:

* Deploy
* Release

I said before that completing the parameterized forms in Jenkins is cumbersome. Take the **deploy** job, getting the version is a pain.
The majority of times we want the **latest**, so if no version is supplied, the ChatBot discovers what the latest is and uses it. We do 
have the ability to choose which version and the same with environment, but usually we want to deploy to **staging**. Deploying to **testing**
is already automated. So, if no environment is supplied, **staging** is assumed. The Jenkins job to deploy takes parameters:

* GroupId
* ArtifactId
* Version
* Environment

This is simplified using the bot, in slack channel `gort ci deploy roam`, the only parameter really is **roam**, the **artifactId** or 
name in actuality. This is a big time saver. 

Command explaination: 

* **gort** is the name of the bot, it listens out for messages.
* **ci** is the command, this is an arbitrary name we've chosen, it stands for **Continous Integration**.
* **deploy** is the sub-command to **ci**, there are others e.g. **release**.
* **roam** is the application we want to deploy.

The other parameters are discovered by the bot and filled in for you. The full command, with optional parameters is 
`gort ci deploy roam 1.1 staging`.

A full list of of sub-commands are:

* hubot: ci deploy **app** *version* *site* - Deploy an  app (defaults: *version*=latest, *site*=staging).
* hubot: ci release **app** - Tell Jenkins what to **app** to run the Release job for.
* hubot: ci update **days** - Update staging with apps deployed in last **days** (default 1 day).
* hubot: ci start update **days** **cron** - Deploy to **staging**, apps deployed **days** ago using cron syntax
* hubot: ci stop update - Stop any regular deploys to **staging**, if one has been set
* hubot: ci show update - Display information on a regular update to **staging**, if one has been set

The ChatOps are limited to a whitelist of developers, so it is protected.

## Summary

So, what was the point of all this? Hopefully you've seen that removing humans from the mundane aspects of Software Development is a
good thing. One, it improves repeatability, if it's automated, you guarantee it will happen in exactly the same way always, something
that can't be guaranteed with humans. As said, this is the mundane stuff, why would you want to waste your time copying and deploying 
files from *A to B*. Build and Deployment is faster as we build once and deploy everywhere, we also guarantee the version is the same
in each environment, reducing areas where errors can occur to environmental factors. Sharing knowledge by executing operations in a 
shared environment i.e. Slack, developers learn by watching others. You don't have to be in the office or have a configured system to 
be able to work, access Jenkins or Slack and you can build, deploy, release applications.
