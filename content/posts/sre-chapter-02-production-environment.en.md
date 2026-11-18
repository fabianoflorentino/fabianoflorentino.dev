---
date: '2026-11-19T00:00:00Z'
draft: true
title: 'Site Reliability Engineering: The Production Environment'
translationKey: sre_chapter_02_production_environment
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-02.png
translation:
  url: /posts/sre-chapter-02-production-environment/
  text: Versão em português
---

This is the second post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). After defining what SRE is in chapter 1, the book now goes down a level and describes the stage where everything happens: **the production environment**.

## Why understand the environment

It sounds obvious, but it's easy to skip: **you can't make something reliable if you don't understand it**. Before talking about SLOs, alerts, or incidents, an SRE needs a clear mental map of where services run and what each layer depends on.

Chapter 2 is, essentially, that map — from hardware all the way up to the infrastructure software that supports Google's services.

## Hardware: warehouse-scale computing

The first point of the chapter is a change of mindset. Google treats its datacenters as **warehouse-scale computers**: thousands of homogeneous machines that, together, work as a single giant computer.

The practical consequence is that **machines are not special**. They fail all the time, in large numbers. Reliability doesn't come from reliable hardware, but from software that **assumes failure and works around it** — replication, redundancy, and fault tolerance at every layer.

It's the philosophy the community summarized as "treat servers as cattle, not pets". Google uses another metaphor: it manages machines the way you manage a **herd**, not individuals.

## The software that organizes the hardware: Borg

Nobody manages thousands of machines by hand. Google built **Borg**, the cluster management system that schedules jobs, allocates resources, and decides where each one runs.

Why does this matter to an SRE? Because Borg is the layer that turns "a bunch of machines" into "a platform". And, more importantly: **Kubernetes is the open-source descendant of Borg**. Anyone working with Kubernetes today is, in a sense, using the same ideas Google consolidated years ago.

If you want to understand Borg in detail — how it spreads jobs across tasks, uses the Borg Naming Service (BNS), and *binpacks* resources — see the [full description in the book](https://sre.google/sre-book/production-environment/#managing-machines-XQsKIBTq).

## Storage: Colossus, Bigtable, and Spanner

Storage at Google is organized in layers, and the chapter presents three systems that build on one another:

**Colossus** is the cluster's distributed filesystem — successor to GFS — offering filesystem semantics, replication, and encryption. It's the base on which the databases are built. ([full description in the book](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM))

**Bigtable** is a distributed NoSQL database that can handle petabyte-scale databases, used for large-scale structured data (web indexes, YouTube, and many others), with cross-datacenter replication and eventual consistency. ([full description in the book](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM))

**Spanner** is the globally distributed SQL database, for those who need strong consistency and relational semantics at a worldwide scale. ([full description in the book](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM))

The lesson here isn't to memorize the names, but to notice the pattern: **every data layer is built to survive failure**. Durability is not an accident; it's a design requirement.

## Networking: Jupiter and GSLB

On the network side, the chapter describes **Jupiter**, the datacenter network fabric with high bandwidth, and **GSLB** (_Global Software Load Balancer_), which distributes traffic across datacenters and regions.

Again, the idea is the same: the network is treated as a programmable, redundant software resource, not fixed cables. ([full description in the book](https://sre.google/sre-book/production-environment/#networking-2ksZhrT8))

## Lock service: Chubby

A detail many find curious: Google has a **distributed lock service** called Chubby, used for leader election and coordination between systems. Built on Paxos, it solves the "who's in charge right now" problem in a distributed environment.

It seems niche, but it's the foundation for things like electing a cluster's leader — a problem that shows up in almost any distributed system. ([full description in the book](https://sre.google/sre-book/production-environment/#lock-service-jWsjIlcM))

## Monitoring: seeing the environment

Finally, the chapter talks about **monitoring and alerting** as an integral part of the environment — at Google, systems like Borgmon collect time-series metrics to provide visibility into what's happening.

The key point: **monitoring is not an accessory you add later**. It's part of the platform, just like storage and networking. ([full description in the book](https://sre.google/sre-book/production-environment/#monitoring-and-alerting-2ksLtBc8))

## What I take from this chapter

This chapter hit me because it describes, at planetary scale, a journey I went through at a much smaller scale.

I started by taking care of physical servers, one at a time — the opposite of a "herd". Working as an infrastructure analyst at a certificate authority, my first turning point was **virtualizing and creating a cluster**: isolated servers became a fleet of almost **200 virtual machines and services**, with better CPU and memory utilization and, above all, more availability. It was my first contact with the idea of treating resources as something you manage collectively, not as individual boxes.

Later, working with **Kubernetes**, I saw Borg's logic in action. In a project for a major Brazilian retailer, the problem was exactly one of those the chapter teaches you to avoid: **production and development shared the same cluster**. Creating separate clusters brought isolation, high availability, and stability to production. It was the modern — and much simpler — version of what Google does with Borg.

And then there's monitoring. I went from "looking at the virtualization console" to **Zabbix and Grafana**, monitoring critical environments for large clients (Linux, Windows, AIX, and databases). That's where I understood what the chapter says: **monitoring is part of the platform**. More than once, the team managed to spot a problem before it became an alert — the proactive behavior the chapter takes for granted.

The big lesson, for me, is this: **climbing the stack changes your relationship with reliability**. Someone who only sees the physical server thinks reliability means "buying better hardware". Someone who sees the environment as layers understands that reliability is **architecture** — replication, isolation, observability, and software that assumes failure.

## Next chapters

In the next post, I'll cover **Chapter 3: Embracing Risk**. That's where the book introduces one of SRE's most important ideas: the **error budget** and why 100% availability is not the goal.

Follow the series at [/series/sre/](/series/sre/).
