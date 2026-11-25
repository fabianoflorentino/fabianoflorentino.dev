---
date: '2026-11-24T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Monitoring Distributed Systems'
translationKey: sre_chapter_06_monitoring_distributed_systems
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-06.png
translation:
  url: /posts/sre-chapter-06-monitoring-distributed-systems/
  text: Versão em português
---

This is the sixth post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). After covering toil, the book reaches the chapter that turns signal into a decision. [Chapter 6](https://sre.google/sre-book/monitoring-distributed-systems/) starts with a simple, uncomfortable question: **what deserves to wake someone up at 3 a.m.?**

## Monitoring isn't staring at a graph

The chapter starts by separating vocabulary that many people use as synonyms:

- **Monitoring**: collecting, processing, aggregating, and displaying real-time quantitative data about the system.
- **White-box**: metrics exposed by the system's internals — logs, endpoints, internal statistics.
- **Black-box**: testing externally visible behavior, as a user would see it.
- **Dashboard**: a summary view of the service's most important signals.
- **Alert**: a notification for a human, which may become a ticket, an email, or a **page**.

That last distinction matters. A **page** is the alert that actually interrupts someone. Email and tickets can wait; a page cannot. And pages are expensive: they interrupt work, rest, and sleep. When they become routine, people start ignoring them, skimming them, or silencing them — including the page that mattered.

The chapter also reminds us why we monitor: to see long-term trends, compare periods or experiments, alert, build dashboards, and investigate incidents after they happen. Monitoring is engineering work: a team of 10–12 SREs usually has one or two people dedicated to it — and nobody should be "staring at a screen" waiting for a problem.

**A dashboard isn't monitoring; it's a window into it. If nobody watches and nothing fires, the system is on its own.**

## The four golden signals

If you can only measure four things about a user-facing system, measure these: **latency, traffic, errors, and saturation**.

- **Latency**: the time it takes to serve a request. Separate the latency of successful requests from the latency of failed ones. A fast error isn't good, but a slow error is even worse.
- **Traffic**: how much demand the system is receiving. It can be requests per second, concurrent sessions, I/O, or transactions.
- **Errors**: the rate of requests that fail — explicitly, implicitly, or by policy. An HTTP 200 with the wrong content is still an error.
- **Saturation**: how full the service is. Look at the most constrained resource and remember that many systems degrade before reaching 100%.

The chapter also notes that latency is often the first sign of saturation. And saturation isn't only about the present: "the disk will fill up in four hours" is as useful as "the disk is full."

**Four well-measured signals cover the service better than two hundred ownerless graphs.**

## Averages lie; watch the tail

The average is comfortable and almost always misleading. A service with 100 ms average latency may have 1% of requests taking 5 seconds. If the user depends on several services to render a page, one backend's 99th percentile easily becomes the median of the final experience.

That's why the chapter recommends latency histograms, not just averages. Instead of asking "what was the average latency?", ask "how many requests fell into each bucket?". Roughly exponential buckets — 0–10 ms, 10–30 ms, 30–100 ms, 100–300 ms — show the distribution without hiding the tail.

Measurement resolution matters too. CPU measured once a minute may miss short spikes that destroy latency. An availability probe every second is overkill for a service targeting 99.9% availability. Collection, storage, and analysis cost money; sometimes it's worth sampling on the server and aggregating later.

**If you only look at the average, you're monitoring a user who doesn't exist.**

## Pages are expensive; alerts are a contract

The chapter draws a distinction that belongs in every runbook: a **symptom** is what's broken; a **cause** is why. Monitoring needs to answer both questions, but with different roles.

For **paging**, prioritize **black-box**: the problem is already happening and affecting users. White-box is excellent for detecting imminent problems, failures masked by retries, and for debugging. But white-box also creates noise: high CPU doesn't always mean users are suffering.

Before creating an alert, the chapter suggests asking:

- Does it detect an urgent, actionable condition that is visible to users?
- Will I ever be able to ignore it, knowing it's benign? If so, why does it exist?
- Does it indicate real impact, or just a busy resource?
- Is there an action I can take? Can that action be automated?
- Is someone else already being paged for the same problem?

The philosophy is strict: **every page should be urgent, actionable, require intelligence, and address a novel problem**. If the response is always the same, that isn't a page — it's missing automation. Email alerts, in this context, have limited value and quickly become noise; better to put them on a dashboard of subcritical problems.

**If a page doesn't require thought, it should be automation; if it doesn't require action, it shouldn't be a page.**

## Simple enough

Monitoring is easy to complicate. The chapter warns against too many rules, too many dependencies, and too many dashboards. Complex dependency hierarchies ("if the database is slow, don't alert on the website") age badly in systems that change all the time.

The recommendation is to keep the critical path simple and understandable:

- The rules that catch real incidents most often should be the simplest and most predictable.
- Collection, aggregation, and alerting that are rarely used are candidates for removal.
- Metrics that appear in no dashboard and trigger no alert are also candidates.
- Monitoring shouldn't become a mix of profiling, process debugging, logs, tracing, and load testing. Integrate through clear APIs, not one giant system.

The [**Bigtable**](https://sre.google/sre-book/monitoring-distributed-systems/#bigtable-sre-a-tale-of-over-alerting-dbsXtjSM) case — Google's distributed database — shows the cost of excess. The team received alerts in volume, spent time triaging noise, and sometimes missed the problem that actually affected users. The fix was to temporarily lower the SLO target, disable email alerts, and use the breathing room to fix the root cause. The [**Gmail**](https://sre.google/sre-book/monitoring-distributed-systems/#gmail-predictable-scriptable-responses-from-humans-BVs1h4SD) case — Google's email service — shows the other side: pages with rote responses are a red flag for technical debt. If the team neither automates nor fixes them, the page is just hiding the problem.

**Good monitoring is boring: simple, predictable, and low-noise.**

## What I take from this chapter

At **Soluti**, monitoring was done directly on the virtualization console. It showed the basics, but not a broad view of what was happening. As the environment grew, I implemented **Zabbix** with a **Puppet** module, tracking CPU, memory, and disk. That improved visibility into resources, supported capacity planning, and made it faster to act before a larger failure — in an environment that reached nearly **200 virtualized services and servers**.

At a large client, I helped build a **Zabbix + Grafana** dashboard in containers, covering **AIX, Linux, and Windows** environments, IIS, Oracle, SQL Server, and DB2 databases, and digital certificate expiration. The goal was a live view of the environment and action before a problem became an alert or a ticket. It worked: there was a case where an Oracle issue was identified before the support queue was triggered.

But, looking through the chapter's lens, I had plenty of **white-box** and little **black-box**. I could say how CPU, memory, and disk were doing; I couldn't say, with the same clarity, how the user experience was doing. My monitoring was infrastructure monitoring, not service monitoring in the sense the book uses.

The four golden signals give me the order I was missing: start with the symptom — latency, traffic, errors, and saturation — and only then drill into the cause. And remember that an alert isn't an email: if nobody needs to wake up, it isn't a page.

**My monitoring looked at the machine; the chapter teaches me to look at the service.**

## Next chapters

In the next post, I'll cover **Chapter 7: The Evolution of Automation at Google**. It's the chapter that shows how automation matures — and why the right tool depends on the problem, the team, and the context.

Follow the series at [/series/sre/](/en/series/sre/).
