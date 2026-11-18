---
date: '2026-11-18T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Introduction'
translationKey: sre_chapter_01_introduction
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-01.png
translation:
  url: /posts/sre-chapter-01-introduction/
  text: Versão em português
---

This is the first post in a series where I'll walk through [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/), chapter by chapter, connecting its ideas to the day-to-day reality of running systems.

## Why start here

Chapter 1 is short, but it may be the most important one of all. It's where the book defines what SRE actually means — and, more importantly, **why Google felt the need to create the role in the first place**.

Before talking about SLOs, alerts, or postmortems, it's worth understanding the problem SRE tries to solve. Without that context, everything else becomes a set of disconnected recipes.

## The traditional way of operating

For a long time, running systems was treated as essentially manual work: sysadmin teams took care of servers, responded to incidents, shipped deploys, and applied fixes "by hand".

The book calls this the _sysadmin approach_. It points out two very concrete costs of that model:

- **Direct cost:** as the system grows, you need more people to operate it. Scaling operations becomes a hiring race — and cost grows almost linearly.
- **Indirect cost:** there is natural friction between the development team (which wants to ship fast) and the operations team (which wants stability). When goals diverge, blame circulates and trust erodes.

In that model, operational work is seen as something **separate from engineering** — and, worse, as something that doesn't improve through code. You solve the same incident over and over, always by hand.

## Google's bet

Google proposed a different path. Instead of hiring more operators, it hired **software engineers to run operations** — and called that team Site Reliability Engineering.

The sentence that opens the book captures the inversion of logic:

> SRE is what happens when you ask a software engineer to design an operations team.

Attributed to Ben Treynor Sloss (who coined the term), this definition changes everything. Operations stops being a "necessary evil" and becomes an **engineering problem**.

In practice, that means:

- treating operational work as software: automate, version, and test it;
- applying the same good engineering practices to infrastructure;
- reducing repetitive work (**toil**) to free up time for projects that actually improve reliability.

The book also mentions a time split that became a reference: SREs ideally spend **at most 50% of their time on operational work** (on-call, incidents, changes) and the rest on **engineering** — tools, automation, and structural improvements. If toil starts swallowing the team, something is wrong and needs fixing.

## The principles that hold everything together

The chapter lists the core goals of SRE. They're worth memorizing, because almost the entire rest of the book is an expansion of them:

1. **Ensuring a durable focus on engineering** — operations can't swallow the team; time must remain for building.
2. **Pursuing maximum change velocity without violating a service's SLO** — ship fast, but within an agreed reliability limit (the _error budget_).
3. **Monitoring** — understand system behavior through signals, not just binary "checks".
4. **Emergency response** — have a clear process for when things go badly.
5. **Change management** — change safely and predictably.
6. **Demand forecasting and capacity planning** — know where the system is headed before it breaks.
7. **Provisioning** — deliver resources consistently and automatically.
8. **Efficiency and performance** — do more with less, without sacrificing reliability.

Notice that almost all of this is **engineering work**, not "firefighting work". That's the essence of the proposal.

## What I take from this chapter

I didn't know the term SRE when I first started practicing it. It was at **Soluti**, still working as an infrastructure analyst, that I took my first steps — without realizing it: by implementing configuration management with Puppet, plus automation and monitoring with Zabbix and Rundeck, I was, in practice, reducing toil and treating operations as an engineering problem.

At **2Com**, during a brief stint, came the most concrete proof that this works: I automated a costly process that used to take about **three days** to complete, down to **a few minutes**, as long as the client's environment was prepared. It was the first time I truly eliminated toil — and the first time I felt the discipline's impact firsthand.

I carried those lessons into **IBM** and, later, **Kyndryl**, managing critical environments for large clients. There, the pattern repeated itself: improving processes and automating repetitive (or time-intensive) operations, turning days into minutes.

Traditional operations taught me to react. SRE taught me to **design**. It's not about being faster during the incident; it's about reducing the chance it happens — and, when it does, having a system that recovers with minimal intervention.

I also appreciate the honesty of the model: nobody promises 100% availability. What's negotiated is **how much unavailability is acceptable** and, from there, how much delivery velocity you "buy". It's an explicit trade-off, not a vague wish.

## Next chapters

In the next post, I'll cover **Chapter 2: The Production Environment at Google, from the Viewpoint of an SRE**. That's where the book describes the ecosystem (Borg, Chubby, Bigtable, and friends) and starts naming the pieces that support reliability.

Follow the series at [/series/sre/](/series/sre/).
