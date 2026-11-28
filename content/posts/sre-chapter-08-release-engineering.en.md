---
date: '2026-11-29T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Release Engineering at Google'
translationKey: sre_chapter_08_release_engineering
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-08.png
translation:
  url: /posts/sre-chapter-08-release-engineering/
  text: Versão em português
---

This is the eighth post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). In the previous chapter, we saw automation as a force multiplier. Now [Chapter 8](https://sre.google/sre-book/release-engineering/) applies that idea to putting software into production: **release engineering** is the discipline of building and delivering software in a repeatable way — without "unique snowflakes."

## The Role of a Release Engineer

A release engineer needs to understand, end to end, the path from code to production: source control, compilers, build configuration, packaging tools, and installers. They aren't just "the person who does the deploy"; they define **how** software leaves the repository and becomes a runnable binary.

At Google, the role is data-driven: the tools measure **release velocity** — how long a code change takes to reach production — and which features are used in build files. Best practices (compiler flags, build ID formats, required steps) exist so any team can release with a consistent and repeatable method.

Release engineers work alongside SREs to define **canarying, uninterrupted rollouts, and rollback**. The goal is that nobody has to reinvent the wheel — poorly — at release time.

**Reliable releases start with a reliable process: from source code to deployment.**

## The Philosophy: Four Principles

The chapter sums up Google's release engineering in four principles:

- **Self-service**: teams must be self-sufficient. With thousands of engineers and products, high velocity only happens because each team decides when and how to release — with a process automated to the point of requiring very little human involvement.
- **High velocity**: frequent releases mean fewer changes between versions, which makes testing and debugging easier. Some teams build hourly; others adopt **"push on green"**, shipping every build that passes its tests.
- **Hermetic builds**: two people building the same revision on different machines must get identical results. The build doesn't depend on libraries installed on the machine or on external services; dependencies and compilers have known, versioned versions.
- **Policy enforcement**: layers of security and access control define who can approve changes, create a release, approve cherry picks, or change a build configuration. Almost every change goes through code review, and the system generates a report of everything in the release.

The **hermetic build** concept is the heart of this: if you can't reconstruct the exact binary that's running, fixing a production bug becomes a lottery. Google solves this by rebuilding at the same revision and applying targeted changes via **cherry pick**.

**A release isn't an action; it's a reproducible, auditable artifact.**

## The Pipeline: Blaze, Rapid, and MPM

Google's release system is called **Rapid**. It combines several internal technologies to deliver scalable, hermetic, and reliable releases.

- **[Blaze](https://sre.google/sre-book/release-engineering/#building-lqsAI1uM)** is the build tool (open-sourced as **Bazel**). It supports C++, Java, Python, Go, and JavaScript, defining targets and dependencies. Each binary carries a build date, revision, and identifier — so you can trace exactly how it was produced.
- **Branching**: almost nothing ships directly from the mainline. A release comes from a branch at a specific revision; fixes go to the mainline and are pulled in via **cherry pick**, so unrelated changes aren't dragged along.
- **[Midas Package Manager (MPM)](https://sre.google/sre-book/release-engineering/#packaging-8ksQTeum)**: packages and distributes software, with a name, a version hash, and a signature. Labels like `dev`, `canary`, and `production` indicate where a package is in the process.
- **[Rapid](https://sre.google/sre-book/release-engineering/#rapid-m8sJcDux)**: configured via *blueprints* that define build, test, deployment rules, and project owners. Workflows run as **Borg** jobs ([full description in the book](https://sre.google/sre-book/production-environment/#managing-machines-XQsKIBTq)) and dispatch thousands of releases in parallel.
- **[Sisyphus](https://sre.google/sre-book/release-engineering/#deployment-dbsMi8um)**: a rollout framework built by SRE. It controls staged deployment — updating everything at once or scaling from one cluster to all of them over hours.

Deployment is designed around a service's **risk profile**: in development, hourly builds with automatic push; for large services, progressive expansion; for sensitive infrastructure, a rollout spread over days.

**Deployment speed isn't uniform — it adjusts to each service's risk.**

## Configuration Management

Configuration changes are a classic source of instability. The chapter shows four models for distributing configuration, always versioned and under code review:

1. **Mainline**: configuration at the head of the mainline; simple, but it creates *skew* between what's checked in and what's running.
2. **Same package**: binary and configuration together; simpler to deploy, but it couples the two.
3. **Separate packages**: applies the hermetic principle to configuration. You can change a single flag without rebuilding the binary.
4. **External store**: configuration that changes frequently lives in **Chubby** ([lock service](https://sre.google/sre-book/production-environment/#lock-service-jWsjIlcM)) or **Bigtable** ([storage](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM)).

The point is that configuration is first-class code, with its own versioning, review, and rollout.

**Poorly managed configuration takes down systems just as well as bad code.**

## It's Not Just for Googlers

The chapter closes with a reminder: with the right tools, automation, and well-defined policies, releasing software should be **as simple as pressing a button**. Companies of any size face the same questions: how do you version packages? Continuous or periodic builds? How often do you release? What configuration policy do you use?

And, more importantly, release engineering needs to be considered **from the beginning** — not bolted on afterward. It's cheaper to put good practices and process in place early than to retrofit a legacy system later.

**Release engineering is foundation investment, not an end-of-project patch.**

## What I take from this chapter

When I read about release engineering, I go straight back to the **Puppet** module I wrote at **Soluti**. The digital certificate issuance system was written in **PHP** and ran on **Apache**. Versions were kept in **Git** (GitLab), and I developed a Puppet module that fetched the application files by version number, compared the differences against what was on the server, and replaced only what changed.

The module also codified the steps of every update: restart the service, apply configuration changes. In other words, the *what* (which version to distribute) and the *how* (what to do after distributing) became code — and any server could be provisioned the same way.

But, honestly, that was a fraction of what the chapter describes. I had **practical reproducibility** (the same Git version produced the same environment), but without Google's hermetic rigor, without staged canarying, and without the policy controls Rapid and MPM provide. The rollout was "apply and pray," not a Sisyphus rollout tuned to the risk profile.

What stuck was the seed of the right idea: **release is an engineering process, not a manual step**. Delivery went from days to minutes because the path from code to production stopped depending on a person following a mental script.

**I learned the essentials the hard way: without process, "it works on my machine" becomes the deploy plan.**

## Next chapters

In the next post, I'll cover **Chapter 9: Simplicity**. It's the chapter that defends the "boring and predictable" against needless complexity — and shows why, in operations, less is almost always more.

Follow the series at [/series/sre/](/en/series/sre/).
