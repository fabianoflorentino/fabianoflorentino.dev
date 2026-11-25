---
date: '2026-11-21T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Service Level Objectives'
translationKey: sre_chapter_04_service_level_objectives
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-04.png
translation:
  url: /posts/sre-chapter-04-service-level-objectives/
  text: Versão em português
---

This is the fourth post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). After introducing the error budget in chapter 3, the book now formalizes the vocabulary that underpins it all: **SLI, SLO, and SLA** — how to measure a service, what target to set, and what happens if the target is missed.

## The terminology: SLI, SLO, and SLA

Three acronyms people often treat as synonyms, and which the book insists on separating:

- **SLI** (service level indicator): the quantitative measure of some aspect of the service — request latency, error rate, throughput, availability.
- **SLO** (service level objective): the target the SLI must meet. E.g. "the average search request latency should be under 100 ms". The natural structure is `SLI ≤ target`.
- **SLA** (service level agreement): the contract with the user — and, above all, the **consequence** if the SLO isn't met (a rebate, a penalty, termination).

The quick test the book gives for telling an SLO from an SLA: **"what happens if the goal isn't met?"** If there's no explicit consequence, it's an SLO. And an honest observation: almost everyone who talks about an "SLA violation" is actually talking about a missed SLO.

The important detail: **SRE doesn't usually build SLAs** — that's a business and legal decision. SRE's role is to define objective SLIs and help meet the SLOs so the consequence is never triggered.

**SLI is what you measure; SLO is the target; SLA is the promise with a price for breaking it.**

## What to measure: start with the user

The classic mistake is measuring everything the monitoring system can. The book inverts this: **start with what users care about and pick a few indicators**.

Services fall into categories:

- **User-facing serving systems** (like the Shakespeare search): **availability** (did the request get answered?), **latency** (how long did it take?), and **throughput** (how many requests per second?).
- **Storage systems**: **latency**, **availability**, and **durability** (is the data still there years later?).
- **Big data and pipelines**: **throughput** and **end-to-end latency**.
- **All** should care about **correctness**: was the right answer returned?

Availability, in practice, becomes **request success rate**: the fraction of well-formed requests that succeed. The chapter notes that 100% is impossible, and that "nines" is the common shorthand — 99% is "2 nines", 99.999% is "5 nines". Google Compute Engine, for example, publishes "three and a half nines": 99.95%.

**A handful of indicators that reflect the user beats a wall of dashboards.**

## Collecting: server, client, and the tail

Metrics seem simple until you think about how to collect them. Most are born on the **server side** (Borgmon, Prometheus, log analysis). But measuring only the server hides problems that affect users — heavy JavaScript on a page can make search feel slow to the client even when the backend is fast. That's why some SLIs need **client-side** collection.

The second concern is **aggregation**. The average hides the tail: it's entirely possible for most requests to be fast while 5% of them are **20 times slower**. The book recommends working with **percentiles** (p50, p99, p99.9) instead of averages, and treating metrics as **distributions**, not single numbers. A technical nuance: you can't assume your data is normal — and acting on outliers without checking the distribution can make you restart servers for nothing.

**The average is a comfortable way to lie about latency; use percentiles.**

## Choosing the target: less is more

Setting an SLO isn't purely technical — it has product and business implications. The book offers five rules:

1. **Don't copy current performance** — adopting today's value can lock you into a system that demands heroic effort.
2. **Keep it simple** — complicated aggregation hides change and is hard to reason about.
3. **Avoid absolutes** — "infinitely scalable" and "always available" don't exist, and cost dearly for nothing.
4. **Have as few SLOs as possible** — if you can't win a prioritization argument by quoting an SLO, it isn't worth having.
5. **Perfection can wait** — start with a loose target and tighten as you learn; loosening later is painful.

In practice, the SLO is the lever that prioritizes the work of both SRE and product. **A well-thought-out SLO is a legitimate forcing function; a poorly-thought-out one generates wasted work.**

## Chubby: when being too good becomes a problem

The most counterintuitive story in the chapter. **Chubby** — Google's distributed lock service, which already appeared in chapter 2 — is so reliable that teams started **depending on it, assuming it would never go down**. High availability became a false sense of security: when Chubby did go down (rarely), it took down a cascade of services that couldn't function without it.

Google's solution is brilliant and a little scary: **Chubby meets its SLO, but must not significantly exceed it**. If no real failure dropped availability below the target in a quarter, SRE **synthesizes a controlled outage** — deliberately takes the system down to flush out unreasonable dependencies shortly after they're added. ([full description in the book](https://sre.google/sre-book/service-level-objectives/#xref_risk-management_global-chubby-planned-outage))

This ties together two of the chapter's lessons: **don't overachieve** (users build on reality, not on what you promised) and **keep an internal safety margin** larger than the published one.

## What I take from this chapter

This is one of the chapters that put me most on the spot — and one of the reasons I'm writing this series.

**I've never defined a formal SLO in my career.** I operated nearly 200 services and virtual machines on a VMware cluster at **Soluti**, monitoring with Zabbix — CPU, memory, disk. The word "availability" was in my vocabulary the whole time, but it was **intuition, not an indicator**. Zabbix measured resource health, which is a proxy for health; it didn't measure what users feel — success rate, latency at the client's end. And with no published SLO, expectations stayed implicit, exactly the scenario the chapter warns about: everyone believes whatever they like.

In my more recent roles, defining SLIs, SLOs, and SLAs doesn't pass directly through me or the team either. We serve a range of clients with **very different compliance requirements**, and some require these metrics to be defined by **specific teams or regulatory bodies** — which limits how much we can influence those parameters. What stays in our hands is **monitoring and analyzing the data**: measuring whether the standard is being met and pursuing continuous improvement. **If the target is set elsewhere, measuring and improving is still engineering.**

For me, chapter 4 marks the shift **from operations to engineering**: from "keep it up" to "measure and negotiate what 'up' means". It's the bridge between what I used to do and what I want to do — which is why it goes on my continuous-learning list.

The idea that shifts my posture most: **you don't need to promise 100% — you need to promise a number and meet it, without exceeding it so much that you become a dependency.** Availability is a contract, not a virtue.

As part of my continuous learning, I've been building a few open source projects to practice and understand these disciplines — and to sharpen the knowledge so that, when I need to apply it, I can do it as correctly as possible.

That's the case with SLO. In **srectl**, I can define real SLIs (latency and error rate for a sample app), fix an SLO, and instrument an **error budget burn** to watch the budget drain — turning this chapter's theory into something I run, not just read.

If you want to check them out (and, why not, use them to practice too), they're all open on GitHub:

- [**srectl**](https://github.com/fabianoflorentino/srectl) — a local SRE, DevOps, and Platform Engineering training environment, in Go, with Kubernetes, Argo CD, and the LGTM stack (Loki, Grafana, Tempo, and Mimir).
- [**seraph**](https://github.com/fabianoflorentino/seraph) — an independent, ad-free status board that reads official status pages and publishes the state of your services; the natural place where an SLO becomes something published.
- [**certificate-validate**](https://github.com/fabianoflorentino/certificate-validate) — an SSL/TLS certificate validation tool, a concrete SLI in disguise: an expired certificate is an unavailable service for the user.
- [**fraudctl**](https://github.com/fabianoflorentino/fraudctl) — a Go API that receives payments and analyzes whether they're fraudulent or not; it competed in this year's **Rinha de Backend** and placed **19th**. A great testing ground for the chapter's SLIs (latency, error rate, availability) — [competition ranking](https://rinhadebackend.com.br/).

These projects were the way I've found to turn reading into skill.

## Next chapters

In the next post, I'll cover **Chapter 5: Eliminating Toil**. It's the chapter that names the manual, repetitive work that creates no value — and which, in my story, is what pushed me toward Puppet and Ansible.

Follow the series at [/series/sre/](/series/sre/).
