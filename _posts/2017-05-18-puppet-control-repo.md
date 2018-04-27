---
title:  "Puppet Control Repo with Hiera and r10k"
date:   2017-05-18 20:08:06
categories: [Autmation, Puppet, Hiera, R10k, Control Repo]
tags: [Autmation, Puppet, Hiera, R10k, Control Repo]
comments: true
---

# Puppet Control Repo with Hiera and r10k

Our existing Puppet manifests are starting to show their age, so I started reading the latest blogs and docs on managing your infrastrucure. I started by reading [managing environments with a control repository](https://docs.puppet.com/pe/latest/cmgmt_control_repo.html), Gary Larizza's [Building a Functional Puppet Workflow](http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-1/) and this [techpunch blog](https://techpunch.co.uk/development/how-to-build-a-puppet-repo-using-r10k-with-roles-and-profiles) among others.

## Table of Contents

* [Overview](#overview)
* [Setup](#setup)
* [Deploying Environments](#deploying-nvironments)
* [Roles and Profiles](#roles-and-profiles)
  * [Base Profile](#base-profile)
  * [Apache Web Server Profile](#apache-web-server-profile)
  * [Tomcat Application Server Profile](#tomcat-application-server-profile)
* [Hiera](#hiera)
* [Local Vagrant Development](#local-vagrant-development)
* [Remote Puppet Server Development](#remote-puppet-server-development)

## Overview

A **Control Repo** is just a a means to manage your infrastructure. They have become very popular over the last few years but there is not that much available that provide a working example or at least a real world example. The ones I've come across have been fairly simplistic, so I decided to work on one using a project use-case from work. What will be discussed here is the building of a control repo that will manage a single imaginary **mapuse** service. The service will consist of:

* 2 Tomcat Installations with bespoke application(s)
* Apache Web Server proxying requests to the tomcat application(s)
* Static website for the service
* Roles & Profiles defining the service's view of how to declare and manage tomcat, apache and the base setup for any node
* Environment deployment via r10k
* Development using Vagrant to emulate node(s)


## Setup

There are many seed projects you could start from but I recommend Puppet Labs [Control Repo](https://github.com/puppetlabs/control-repo). There are other e.g.

* [Vagrant/Puppet](https://github.com/jonlil/vagrant-puppet-4-seed)
* [Puppet r10k](https://github.com/lobsterdore/puppet-r10k-example.git)

Forking the Puppet Labs control repo as a starting point, I look to add **Vagrant** support, as I didn't have a Puppet 4 Server available to me at the time. Vagrant is very useful for developing puppet infrastructures, I've used it on many occasions, so feeling comfortable with that it seemed the sensible choice. The *Vagrantfile* I used was:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos/7"
  config.vm.box_url = "centos/7"
  config.vm.synced_folder ".", "/etc/puppetlabs/code"
  config.puppet_install.puppet_version = "4.9.2"

  config.vm.provision :puppet do |puppet|
    puppet.environment_path  = "environments"
    puppet.environment = "mapuse_production"
    puppet.options = "--debug --verbose"
    puppet.working_directory = "."
  end

  config.vm.define "mapuse-web" do |host|
    host.vm.network :private_network, ip: "192.168.60.10"
    host.vm.hostname = "mapuse-web-test.org"
  end

  # NOTE: This is only necessary due to a bug in Vagrant 1.9.x. The problem is
  #       the private_network ethernet interface is not visible, restarting the
  #       service is just a workaround.
  config.vm.provision "shell",
    inline: "/etc/init.d/network restart"
end
```

**NOTE:** You may notice the last provisioning statement, I found this got round a problem I was having using **Vagrant 1.9.1** and **Virtualbox 5.1.18** on **Debian**. The problem was the interface ethernet interface on the VM was not being setup, restarting the network service fixes the problem.


## Deploying Environments

Deployments of environments appears to be converging on **r10k** for Community Edition (CE) Puppet installations and **Code Manager** for Puppet Enterprise (PE). Since we will be using the **CE** version, **r10k** was the logical choice.

```ruby
---
#
# r10k config file for puppet dev environment
#
# This will source from an upstream repository over SSH and deploy
# environments to the relative 'environments/' directory, which is available
# to Vagrant hosts.
#
# Optionally, the remote option below can be changed to 'control' to use the
# locally cloned control repository as the source.  However, housekeeping of
# the local clone is up to you.
#
cachedir: '/tmp/r10k'

sources:
  mapuse:
    control: 'file:///home/user/mapuse-control'
    basedir: 'environments'
    prefix: true
```

With this I was able to use Vagrant to startup a Centos 7 VM and provision it using the using Puppet.

**NOTE:** The environment name is based on the GIT branch **production** prefixed with the **source** i.e. *mapuse*, separated by an underscore, hence **mapuse_production**. From here I was able to focus on the **Roles & Profiles** modules that will define how the service will work.


## Roles and Profiles

**Roles & Profiles** are just a *design pattern*, there is nothing special about them. We have some debate whether common **Roles & Profiles** module(s) should exist in their own repo or in the **control repo**, I found this [blog](http://garylarizza.com/blog/2017/01/17/roles-and-profiles-in-a-control-repo/) useful when I was deciding.

**Roles** describe the purpose of a host e.g. webserver, databaseserver, appserver. **Roles** are constructed from **Profiles**.

**Profiles** manage individual technologies e.g. tomcat, httpd, postgres. The point of the design pattern is the profile is **your** view on how **Component modules** e.g. puppetlabs-tomcat, puppetlabs-apache etc should be managed. Profiles can be configured for your individual service's requirements, but it is worth considering how much variability your services should have. If you are not the only one using Puppet, should you really be managing these technologies differently?

The more services|departments|organizations align, the easier it is for developers to support each other. Being opinionated is good but being entranchant is not, so services can still have **Roles & Profiles** specific to them. I would just say, discuss the level of interoperability you want, there is **no right answer**.

**NOTE:** Stick to one **role** per node, unless your using Puppet Enterprise, then you have the option to relax this rule but I'm still not sure that is a good idea, to me it just means you should split these **roles** into **profiles**.

**NOTE:** Limit **hiera** data lookups to **Profile**s.

There are many examples of how to write **Roles & Profiles**, [puppet labs](https://docs.puppet.com/pe/2017.1/r_n_p_full_example.html), [Gary Larizza](http://garylarizza.com/) to name but two. The technologies stated at the beginning of the post will be managed by our profiles, we only need one role I called **appserver**, the appserver role is constructed of a number of profiles:

* **base**
* **tomcat**
* **httpd**

### Base Profile

The base setup for any node, configure common packages|files|users anything you can think of that is common to any host.


### Tomcat Application Server Profile

A function to configure a single tomcat instance for each application. The application data will come from hiera. The config will be the properties necessary for a single application e.g. name port etc. The profile will repeatedly call the function with this application data to create the tomcat instances using the **create_resources** function e.g.

```ruby
  $instances = lookup('profiles::tomcat::instances', {})
  create_resources('profiles::tomcat::instance', $instances)
```


### Apache Web Server Profile

Configure a single apache installation with **Virtual Hosts**. The config data will again come from hiera, creating vhosts instances in the same way the tomcat profile does. It is the config that will determine what aspects of apache need to be setup e.g. if rewrite rules config exists, they are setup, otherwise they are skipped.


## Hiera

We used to only use **hiera** to manage basic node configuration, most of the **knowledge** was in the **manifest**s. Each node was defined in the **site.pp** file, each node would specify what modules they required. It appears recent thinking is to put much more into **hiera**, for instance **Roles & Profiles** used by a particular node e.g. **hieradata/nodes/mapuse-web-test.org.yaml**.

```yaml
---
classes:
  - roles::appserver
  - mapuse::init
```

The above will ensure that the **mapuse-web-test.org** node is provisioned with the **appserver role** and **mapuse** modules. The **manifests/site.pp** file just contains:

```ruby
lookup('classes', {merge => unique}).include
```

This tells Puppet to find and merge any unique **classes** in the **Hiera hierarchy**. The hierarchy is defined inside the hiera.yaml file, this file could exist in a few locations but I suggest you define your own, but really, whatever works best for you. The one I use is **Hiera version 5**.

**NOTE:** This is only available with the latest versions of Puppet CE.

```yaml
---
version: 5
defaults:  # Used for any hierarchy level that omits these keys.
  datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata         # This path is relative to hiera.yaml's directory.
  data_hash: yaml_data  # Use the built-in YAML backend.

hierarchy:
  - name: "Per-node data"                   # Human-readable name.
    path: "nodes/%{trusted.certname}.yaml"  # File path, relative to datadir.
                                   # ^^^ IMPORTANT: include the file extension!

  - name: "Per-service data"
    path: "services/%{facts.service}.yaml"

  - name: "Per-environment data"
    path: "environment/%{environment}.yaml"

  - name: "Per-datacenter business group data" # Uses custom facts.
    path: "location/%{facts.whereami}/%{facts.group}.yaml"

  - name: "Global business group data"
    path: "groups/%{facts.group}.yaml"

  - name: "Per-datacenter secret data (encrypted)"
    lookup_key: eyaml_lookup_key   # Uses non-default backend.
    path: "secrets/%{facts.whereami}.eyaml"
    options:
      pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/keys/private_key.pkcs7.pem
      pkcs7_public_key:  /etc/puppetlabs/puppet/eyaml/keys/public_key.pkcs7.pem

  - name: "Per-OS defaults"
    path: "os/%{facts.os.family}.yaml"

  - name: "Common data"
    path: "common.yaml"
```

The facts used, need to be setup on the **Puppet Server**, they can be defined in a number of ways, see the [Puppet docs](https://docs.puppet.com/facter/3.6/custom_facts.html) for how. Using my Vagrant setup, I'm able to add it to the VM provisioning (I'm only currently using the **facts.service** fact):

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos/7"
  config.vm.box_url = "centos/7"
  config.vm.synced_folder ".", "/etc/puppetlabs/code"
  config.puppet_install.puppet_version = "4.9.2"

  config.vm.provision :puppet do |puppet|
    puppet.environment_path  = "environments"
    puppet.environment = "mapuse_production"
    puppet.options = "--debug --verbose"
    puppet.working_directory = "."

    # Set facts
    puppet.facter = {
      "service" => "mapuse",
    }
  end

  config.vm.define "mapuse-web" do |host|
    host.vm.network :private_network, ip: "192.168.60.10"
    host.vm.hostname = "mapuse-web-test.org"
  end

  # NOTE: This is only necessary due to a bug in Vagrant 1.9.x. The problem is
  #       the private_network ethernet interface is not visible, restarting the
  #       service is just a workaround.
  config.vm.provision "shell",
    inline: "/etc/init.d/network restart"
end
```

With this, Puppet is able to configure Hiera to look for configuration data in the **hieradata/services/mapuse-web-test.org.yaml** file.


## Managing Puppet Environments


1. What steps are involved in Software Development?
1. What is involved in getting development code from your machine to the server?
1. Why do things manually?
1. Why automate?













## Integrating with automation systems

If we use the likes of a **control repo** and **r10k**, it makes integrating far easier. It is considered a good idea to keep all modules in a single **control repo** so pushes on that repo can trigger auto-deployment of the code to environments using **r10k**. This would be easy to integrate into our **Jenkins** Continuous Delivery pipeline and Chatbot.

## Summary

What you have read is heavily influenced by the likes of Puppet Labs themselves and [Gary Larizza](http://garylarizza.com/). The [techpunch blog](https://techpunch.co.uk/development/how-to-build-a-puppet-repo-using-r10k-with-roles-and-profiles) also massively helped my understanding as it provides a very good example repository with realistic **Roles & Profiles**.

My view is you should think beyond each service, to build a level of consistency that:

* reduces costs
* makes moving between services easier
* reduces effort


## Future thoughts

**A picture is worth a thousand words**, so it would be good to be able to easily visualize the infrastructure. No-one has the time to manually diagram the current state, it gets out of sync too quickly. It is possible to automate this:

* [Visualizing Puppet manifest resources and relationships](https://jansipke.nl/visualizing-puppet-manifest-resources-and-relationships/)
* [Puppet-graph](https://github.com/rodjek/puppet-graph)
* [Visualizing Puppet dependencies](http://www.terminalinflection.com/puppet-viz/)
* [Puppet Enterprise Node Graph](https://docs.puppet.com/pe/latest/CM_graph.html)

I've not gone through the process of generating a diagram but I've heard they aren't the easiest to read. Puppet PE has a [visualisation tool](https://puppet.com/blog/visualize-your-infrastructure-models), I've not used it either so can't comment really.
