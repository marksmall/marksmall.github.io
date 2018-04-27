---
title:  "Another GIT Flow"
date:   2018-04-27 19:23:00
categories: [GIT, Flow, Development life-cycle]
tags: [GIT, Flow]
comments: true
---

## Table of Contents

* [Overview](#overview)
* [Git Flow](#git-flow)
* [GitHub Flow](#github-flow)
* [Workflow for Continuous Delivery](#workflow-for-continuous-delivery)
* [GitLab Flow](#gitlab-flow)
* [Thoughts](#thoughts)
* [A Flow that works for me](#A-flow-that-works-for-me)
* [Automation](#automation)
* [Summary](#summary)

## Overview

Over the years I found [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) to be too heavy-weight and [GitHub Flow](https://guides.github.com/introduction/flow/) is too dependent on **GitHub**. I've also looked at Atlassian's [workflow for continuous delivery](https://www.atlassian.com/blog/archives/simple-git-workflow-simple) and [GitLab Flow](https://docs.gitlab.com/ee/workflow/gitlab_flow.html). None seemed to fit my needs, was I being unrealistic in my expectation? Anyway, the follow details what I think are good and bad about each, as well as defining what I have come to use.

## Git Flow

When **Git Flow** first came around, I was sold when I saw the first diagram. It seemed great at the time, took all situations I could think of into account and others I hadn't. Still experience proved, at least mine, it heavy-weight. The main development branch being `develop`, not `master` has been a frustration since day one. The need to keep `master` and `release` in sync, as well as the need for a `release` branch, when it also creates a **tag**. I used this flow until for a few years and it worked.

## GitHub Flow

Along came [GitHub Flow](https://guides.github.com/introduction/flow/), it streamlined **Git Flow** to the essentials, but with a few compromises:

1.  No concept of a **release**
1.  Reliant on GitHub **Pull Requests** as a source of a _release_.
1.  Merging **Pull Request** after deployment, WTF!!!

## Workflow for Continuous Delivery

Atlassian's [flow](https://www.atlassian.com/blog/archives/simple-git-workflow-simple) is the closest I've found that comes close to what I see as a good productive flow. If you team is small, the **rebasing** of the `master` branch into your **feature** branch may seem heavy-weight, but it becomes more and more useful, the larger your team becomes, then it is more likely there will be **merge conflicts**. The downside is, this flow ends when a **feature** has been merged into the `master` branch. What about **environment deployments** and **releases**.

## GitLab Flow

[GitLab's attempt](https://docs.gitlab.com/ee/workflow/gitlab_flow.html), details a bit about each of the previous flows (I strongly recommend reading that) and an attempt to manage the **deployments** and **releases**. Like **Git Flow**, they choose to do this via **branches**, this again is too heavy-weight.

## Thoughts

None of these **Flows** fit what I need (or think I need?). It is probably unrealistic to expect any of them to fit my or anyone's needs perfectly, so cherry-pick what you feel fits your needs and adapt/add where necessary.

## A Flow that works for me

The following is a flow I've been using over the last 2-3 years, it has proven to work and has been highly automated. The automation is a nice UX layer on top of the flow itself, it takes away the more repeatable mundane and aspects of the flow.

1.  Branch **Features** from `master`, using a meaningful name, optionally include the issue id e.g. `1-add-login-form-validation`.
1.  Add commits.
1.  **Rebase** `master` into your feature branch once feature complete, not before and fix any **merge conflicts**. This will become more common, the more developers work on the same code-base. The potential for conflicts depends on the what code has been changed. The rebasing effectively inserts any new code merged into `master` since you branched to start the feature, is placed before your commits in the **history**.
1.  Start a **Code Review**, using whatever tool you use e.g. GitHub **Pull Request**.
1.  Discuss, amend and commit any changes.
1.  Merge `feature` branch into `master`, using [non fast-forward](https://www.git-scm.com/docs/git-merge/1.7.4#git-merge---no-ff) merging.
1.  Deploy `master` to **testing** environment for review.
1.  Deploy daily to **staging**, keeping near-production environment realatively up-to-date (your free to vary the time period, but probably only up to a week).
1.  Build **release** from `master` (releases may vary, this is one scenario):
    1.  Tag **HEAD** of `master`, use a meaningful tag e.g. `<app name>-<timestamp>`, this bit is flexible, don't want to be dogmatic.
    1.  Build a **Docker image** from the **tag**
    1.  Push image to a **Container Registry**
    1.  (Optional) Create GitHub Release, or equivalent, there are tools to make this easy, but are interactive.
1.  Deploy **Docker image** to **testing** and **staging** environments for final pre-production test.
1.  After test, deploy **Docker image** to **production**.

As you can see, there are a quite a few steps, it may seem too many but count the steps you actually use, I'd be suprised if it where much different.

Each of the **Deploy** steps can be automated, reducing the need for developers to remember and do it, I've forgotten the number of times I've forgotten to do X. Automation removes the repeatable, mundane tasks in the development life-cycle and frees developers to focus on important matters, namely **developing code**.

If your a one person team, then obvious you can bypass the **Code review**, but most of us work in at least a 2 person team. Code reviews are essential for sharing knowledge about a code-base, unless it is trivially small.

Your **release** steps are likely to differ also, but they will likely follow a similar pattern, likely it will be the **deployable artifact** i.e. the **Docker image** that will differ, yours may be a Java **WAR** file, or a Python **egg** file for example.

## Automation

I cannot stress automation enough, automate whatever you can, the time spent developing your automation is dwarfed by the time saved and the happiness of developers, freed from mundane tasks.

I detailed the automation of our webapps in a [previous blog](http://marksmall.github.io/2016/automated-build-deploy-webapps/)

## Summary

This **flow** has served the teams I've worked with well over the last couple of years. We managed the development life-cycle of micro-services for UK Universities. We have experienced our share of **production disasters** and the flow has been instrumental in:

1.  Rolling-back to a proven release version.
1.  Getting any **hotfix** into **production** quickly.

Because so much of the mundane tasks have been automated, there are less mistakes. Its amazing how the simplest task are quite often the ones we get wrong. The automation ensures the steps are repeated in the same order. This is something humans are poor at, we're just not good at it, i've yet to see a process a human hasn't tried to subvert and rarely for good, usually expediancy.

The steps up to the completion of the **Code Review**, I would expect most teams to require. You may vary in specifics e.g. only **merges**, no **rebasing**, but the end state is still the same. It is the **environments** and whether to do **releases** that is likely to vary, as I said, choose what best suits you, there is no right answer.

If you got this far, thanks, you made it worth sitting in on a Friday night rambling, when I should have been in the pub.
