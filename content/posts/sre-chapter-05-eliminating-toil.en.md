---
date: '2026-11-23T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Eliminating Toil'
translationKey: sre_chapter_05_eliminating_toil
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-05.png
translation:
  url: /posts/sre-chapter-05-eliminating-toil/
  text: Versão em português
---

This is the fifth post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). After covering SLOs, the book turns to the work that consumes an SRE's time. [Chapter 5](https://sre.google/sre-book/eliminating-toil/) opens with a line from Carla Geisser that is worth the whole post: **"If a human operator needs to touch your system during normal operations, you have a bug. The definition of normal changes as your systems grow."**

## What toil is — and what it isn't

*Toil* is not simply "work I don't like doing". Personal preference doesn't define it: some people even enjoy manual, repetitive tasks. Nor is it any administrative chore. The book separates three things:

- **Overhead**: administrative work not directly tied to running a service — meetings, goal setting, HR paperwork, weekly snippets.
- **Grungy work with enduring value**: cleaning up a messy alerting configuration can be tedious, but it leaves the service better. That's not toil.
- **Toil**: work tied to running a service that tends to be **manual, repetitive, automatable, tactical, devoid of enduring value, and linear with service growth**.

A task doesn't need to match every criterion to be toil. The closer it gets to that list, the more likely it is. One important detail: manually running a script is still toil — the human hands-on time counts, even if the script does the heavy lifting. And if a task requires human judgment, be careful: the real problem may be a poorly designed system that demands human judgment several times a day.

**Toil isn't the boring work; it's the work that leaves the system no better once you're done.**

## Why less toil is better

Google SRE's public goal is to keep toil **below 50% of each SRE's time**. At least the other half should go to engineering work that either reduces future toil or adds service features.

The reason is simple: **toil expands if no one sets a limit**. Without an explicit target, it fills 100% of everyone's time and the organization turns into operations. The work of reducing toil and scaling services is exactly the "Engineering" in *Site Reliability Engineering*.

The chapter does the math for on-call. In a 6-person rotation with one week of primary and one week of secondary on-call, at least 2 of every 6 weeks go to on-call and interrupts: **33% of the time**. In an 8-person rotation, the floor drops to **25%**. In Google's quarterly surveys, the average lands around **33%** — below the 50% target, but with outliers: some SREs report 0% and others 80%. When one person carries too much toil, it's a sign the load needs to be redistributed.

**You don't fight toil with good intentions; you fight it with limits, measurement, and engineering.**

## What counts as engineering

The chapter also draws the other side: **engineering work is novel, requires human judgment, produces permanent improvement, and is guided by strategy**. The more generalizable the solution, the better — it helps the team run more services with the same headcount.

An SRE's activities fall roughly into four boxes:

- **Software engineering**: writing or modifying code, building tools and frameworks, adding scalability and reliability features, improving infrastructure as code.
- **Systems engineering**: configuring production systems, tuning parameters, documenting in a way that turns one-time effort into lasting improvement; includes monitoring, load balancing, server configuration, and architecture consulting.
- **Toil**: repetitive, manual work directly tied to running the service.
- **Overhead**: administrative work not directly tied to the service.

The 50% goal is an average over a few quarters or a year, not a daily quota. Toil is spiky: some weeks concentrate more firefighting, and a team may temporarily dip below the 50% engineering floor. The problem is when **engineering time** stays persistently below 50% — meaning toil goes above 50% — because that's the moment to stop and figure out what's wrong.

**If all your time goes to firefighting, you aren't scaling the service; you're just paying its bill.**

## Toil isn't always the villain

The book is honest: **toil in small doses isn't necessarily bad**. Predictable, repetitive tasks can be calming, provide quick wins, and carry low risk. Everyone needs a bit of that now and then.

The problem is quantity. Too much toil causes **career stagnation** and **low morale** — burnout, boredom, discontent. And the effect isn't only individual:

- **It creates confusion**: if SRE teams do too much toil, it becomes less clear that SRE is an engineering organization.
- **It slows progress**: time spent on manual work is time not spent shipping features.
- **It sets precedent**: those who accept toil quietly attract even more toil — including work that should belong to development teams.
- **It increases attrition**: the best engineers look for more rewarding work.
- **It breaks faith**: people who join SRE expecting project work feel cheated.

**Acceptable toil is a dose; chronic toil is culture — and culture is fixed with engineering and limits.**

## What to do about toil

The chapter doesn't sell a silver bullet. The path is to **measure, classify, and attack**:

1. **Measure** how much time goes to toil, separating it from overhead and engineering.
2. **Classify** what is manual, repetitive, automatable, tactical, devoid of enduring value, and linear with growth.
3. **Eliminate, automate, or redesign** — sometimes the best automation is removing the need for the task.

Carla Geisser's line comes back here: if a human has to touch the system during normal operations, that's a bug. Today's "normal" won't be tomorrow's "normal", because the system grows. The discipline is to **eliminate a little toil every week** with real engineering, instead of waiting for the big automation project that never starts.

**Automation isn't the goal; it's the means to give human time back to what doesn't scale on its own.**

## What I take from this chapter

For a long time, I called toil "routine".

At a certificate authority, server provisioning followed the regulator's compliance requirements and was done by hand. Each environment took **days** to deliver. When the infrastructure grew from just over **20 servers to 100 and then 150**, it became obvious that routine wouldn't scale. With **Puppet**, the process became code and delivery time dropped from days to **minutes** — including the compliance and security checks that used to depend on a manual checklist.

At a database consultancy, the problem was monitoring delivery: manual configuration, no process, no documentation, taking **days** to reach the client. With **OMD + Ansible**, delivery time dropped to **30–40 minutes** (depending on the client's internet), the ticket queue shrank by **more than 60%**, and the delivery queue was **wiped out**, serving a base of roughly **700 clients**. Puppet was tested first, but its server-agent model and learning curve weighed against it; Ansible won by being agentless, declarative, and using SSH/WinRM.

What I wasn't doing — and the chapter makes clear — was **measuring toil**. No percentage, no 50% budget, no separation between toil and overhead. Automation came from the pressure of growth and the queue, not from a formal diagnosis. **I was treating the symptom; the chapter gives me the criterion.**

Today I'd look at it differently: measure what repeats, how much time it consumes, and what grows with the service. Because toil isn't just "manual work": it's the work that **scales with the service** and puts the team back in the same place. Automating what repeats is what turns operations into engineering.

## Next chapters

In the next post, I'll cover **Chapter 6: Monitoring Distributed Systems**. It's the chapter that connects the signals we measure to the question that matters: what deserves to wake someone up at 3 a.m.?

Follow the series at [/series/sre/](/series/sre/).
