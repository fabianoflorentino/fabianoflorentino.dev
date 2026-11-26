---
date: '2026-11-26T00:00:00Z'
draft: true
title: "Site Reliability Engineering: What We've Covered So Far"
translationKey: sre_series_review_chapters_1_7
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-review.png
translation:
  url: /posts/sre-series-review-chapters-1-7/
  text: Versão em português
---

Seven chapters in, it's worth looking back before moving on. This post is a pause between chapter 7 and chapter 8: a chance to revisit the path, organize what stayed, and reach **Release Engineering** on firmer ground.

The continuation is **Chapter 8: Release Engineering**. Here, the idea isn't to repeat what was already said, but to see the connections that only show up after reading everything in sequence.

## What we've covered so far

[Chapter 1](/en/posts/sre-chapter-01-introduction/) asked the question that holds the series together: what changes when operations is treated as engineering? The answer didn't come as a job title or a tool, but as a stance — stop fighting fires and start designing. The goal of keeping toil below 50% appeared as a consequence of that.

[Chapter 2](/en/posts/sre-chapter-02-production-environment/) showed the stage. Borg, storage, networking, locks, and monitoring stopped being loose names and became layers of the same design. Reliability wasn't in the hardware; it was in the architecture that assumes failure.

Chapters 3 and 4 gave us the vocabulary of risk. [Chapter 3](/en/posts/sre-chapter-03-embracing-risk/) took down the idea that 100% is the goal: reliability costs money, has diminishing returns, and the error budget turns that tension into a decision.

[Chapter 4](/en/posts/sre-chapter-04-service-level-objectives/) gave names to the pieces — SLI, SLO, and SLA — and reminded us that measuring the user, watching the tail, and choosing a few indicators is worth more than a wall of dashboards. The Chubby story stayed as a warning that being too good can also be a problem.

The next three chapters looked at the work. [Chapter 5](/en/posts/sre-chapter-05-eliminating-toil/) defined toil: it isn't boring work, it's the work that leaves the system no better once you're done. [Chapter 6](/en/posts/sre-chapter-06-monitoring-distributed-systems/) brought the four golden signals, the difference between symptom and cause, and the question worth carrying: does this deserve to wake someone up at 3 a.m.? [Chapter 7](/en/posts/sre-chapter-07-evolution-of-automation/) showed that automation is a force multiplier, not a panacea — and that the horizon is autonomy, not just scripts.

**Read together, the chapters form one cycle: define risk, measure, reduce work, automate, observe, and learn.**

## Continuous engineering

Maybe the chapters seem like separate subjects. But they fit into one cycle.

Risk appears at the beginning and keeps coming back. Without an SLO, "availability" is an opinion. With an SLO, it becomes a budget, a priority, and a conversation between product and operations.

Visibility enters in the middle. Monitoring isn't dashboard decoration; it's the nervous system that lets you decide whether a problem is a symptom, a cause, or noise.

And work closes the cycle. Reducing toil and evolving automation are two sides of the same coin: one says why to improve, the other shows how.

No chapter solves everything alone. **An SLO without monitoring is intention; monitoring without an SLO is noise; automation without an SLO is speed in the wrong direction.**

## What I take from these seven chapters

I started as an infrastructure analyst, taking care of servers one by one. At **Soluti**, the first turning point was virtualizing and creating a cluster: nearly **200 services and virtual machines** stopped being isolated boxes and became a manageable fleet. Then came **Zabbix**, **Puppet**, and the automation of configuration and release.

At **2Com Consulting**, the turning point was scale and process: Shell scripts became Ansible roles, monitoring delivery dropped from days to **30–40 minutes**, the ticket queue shrank by **more than 60%**, and the backlog was wiped out. It was the first time I saw automation change the game in a measurable way.

At **IBM** and **Kyndryl**, the same pattern appeared in critical environments for large clients, with monitoring, automation, and operations platforms. But the series also forced me to be honest about what I **didn't** have: I never defined a formal SLO, never documented a blameless postmortem, and never reached level 5 autonomy.

Looking back, the change wasn't from tool to tool. It was from "keep it up" to "understand what 'up' means." From incident hero to a system that learns.

**The market turned SRE into a job title. To me, it's a discipline: keep learning, apply the principles, and treat operations as engineering.**

## Continuous learning

Not everything I want to practice fits into the day-to-day work. So a good part of my study became a lab: small projects, built to make mistakes without consequences and to understand how the pieces actually fit together.

In [**srectl**](https://github.com/fabianoflorentino/srectl), for example, I put together a local SRE, DevOps, and Platform Engineering environment in Go, with Kubernetes, Argo CD, and the LGTM stack. It's where I test SLIs, SLOs, and error budgets without pretending I'm in production.

[**seraph**](https://github.com/fabianoflorentino/seraph) came from the wish to have a status board that reads official status pages — the natural place to publish availability. [**certificate-validate**](https://github.com/fabianoflorentino/certificate-validate) turns a concrete SLI into a tool: an expired certificate is an unavailable service. And [**fraudctl**](https://github.com/fabianoflorentino/fraudctl) is a test bed for latency, errors, and availability in a real API.

None of them is a finished product. They're study projects, made to keep knowledge moving and force me to apply SRE principles to something concrete.

I still have a lot to learn — and that's what keeps the study alive. **Theory only becomes discipline when it meets a system to practice on.**

## Follow the series

In the next post, I'll cover **Chapter 8: Release Engineering**. It's the chapter that shows why "it works on my machine" isn't a delivery process — and what separates a deploy from a reliable release.

Follow the series at [/en/series/sre/](/en/series/sre/).
