---
date: '2026-11-26T00:00:00Z'
draft: false
title: "Site Reliability Engineering: What We've Covered So Far"
translationKey: sre_series_review_chapters_1_7
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-review.png
translation:
  url: /posts/sre-series-review-chapters-1-7/
  text: Versão em português
---

After seven chapters, it's worth looking back before moving on. This post is a pause between chapter 7 and chapter 8: an opportunity to revisit the path, connect the concepts, and understand what changed in my perception of Site Reliability Engineering.

Google's book [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/) was the basis for this series. Throughout the chapters, we covered the foundations presented in it: we started by understanding why SRE emerged, moved through the architecture of production environments, and arrived at topics such as risk management, service level objectives, toil, monitoring, and automation.

More than learning tools or memorizing concepts, the reading made me look at some professional experiences differently. Practices I already adopted gained a clearer foundation, while others revealed gaps I still need to develop.

Before moving into Release Engineering, it's worth understanding how these pieces fit together.

## What we've covered so far

[Chapter 1: Introduction](/en/posts/sre-chapter-01-introduction/) presented the idea that holds the whole series together: what changes when operations is treated as engineering?

Google proposed a change of approach. Instead of scaling operations simply by adding people, it began applying software engineering to operational problems. Reducing repetitive operational work — *toil* — and dedicating at least 50% of time to engineering are consequences of that philosophy.

[Chapter 2: The production environment](/en/posts/sre-chapter-02-production-environment/) showed where that philosophy happens. Borg, Colossus, Bigtable, Spanner, Jupiter, Chubby, and Borgmon aren't just isolated technologies. They're components of an architecture built to operate at large scale, considering that hardware, software, and network failures are part of reality.

The main lesson was understanding that reliability doesn't depend on machines that never fail, but on an architecture capable of assuming failures and continuing to work.

[Chapters 3 and 4](/en/posts/sre-chapter-03-embracing-risk/) deepened the relationship between reliability and risk.

In chapter 3, *Embracing Risk*, the book questions a fairly common idea: 100% availability isn't always the best goal. Reliability has a cost, and each new level of availability requires investments that can compromise development speed and feature delivery.

The *error budget* appears as an objective way to balance those needs, allowing product and operations to make decisions from the same indicator.

In chapter 4, [Service Level Objectives](/en/posts/sre-chapter-04-service-level-objectives/), that reasoning gains a clearer structure. SLI, SLO, and SLA stop being acronyms used interchangeably and start representing different things: what we measure, what goal we want to reach, and what commitment we make to the user.

Another important point was understanding that measuring everything doesn't mean measuring well. Indicators need to represent the user experience, and goals should be simple, relevant, and possible to track.

[Chapters 5 and 6](/en/posts/sre-chapter-05-eliminating-toil/) brought the discussion to the daily work of people who operate systems.

In *Eliminating Toil*, chapter 5, we learn that toil isn't simply repetitive or unpleasant work. It's operational work that tends to be manual, repetitive, automatable, tactical, devoid of enduring value, and that grows with the service.

Chapter 6, [Monitoring Distributed Systems](/en/posts/sre-chapter-06-monitoring-distributed-systems/), showed how to turn data into decisions. The four golden signals — latency, traffic, errors, and saturation — help understand service behavior, while the distinction between white-box and black-box shows why observing infrastructure isn't necessarily the same as observing the user experience.

It also left a question worth carrying into any production environment: does this really deserve to wake someone up at 3 a.m.?

Finally, [chapter 7: The Evolution of Automation at Google](/en/posts/sre-chapter-07-evolution-of-automation/) showed that automating doesn't necessarily mean reaching operational maturity.

The chapter presents an evolution that goes from manual execution to systems capable of identifying problems and recovering without human intervention. The difference between automation and autonomy is important: automating a task is different from building a system that no longer needs that task.

The reading also brought a warning: automation without understanding can multiply errors at scale. That's why it needs to be treated as software, with versioning, testing, idempotency, observability, and safety mechanisms.

## What connects these chapters

Reading the seven chapters in sequence makes it easier to see that SRE isn't a set of independent practices. There's a relationship between all of them.

Everything starts with understanding the environment and accepting that failures are part of distributed systems. From there, we need to define how much risk we're willing to take and turn that decision into measurable goals through SLIs, SLOs, and error budgets.

With the goals defined, monitoring lets us follow service behavior, identify problems, and understand whether the user experience is within expectations.

At the same time, we need to reduce repetitive operational work. A team that spends all its time keeping systems running can't dedicate the same effort to improving those systems.

That's where automation enters as an engineering tool. Not just to execute tasks faster, but to reduce human intervention, standardize processes, and build systems capable of handling failures predictably.

These practices complement each other:

- **Reliability** defines what we need to preserve.
- **SLIs and SLOs** establish how to measure and what goal to pursue.
- **Monitoring** lets us understand system behavior.
- **Toil reduction** gives time back to engineering work.
- **Automation** reduces interventions and standardizes operations.
- **Autonomy** represents the evolution of systems capable of operating and recovering within safe limits.

None of these elements solves everything alone.

An SLO without monitoring is just an intention. Monitoring without clear goals can generate an enormous amount of data without helping decisions. Automation without understanding can accelerate a failure. And a team without time for engineering ends up only sustaining existing problems.

**SRE connects these practices around one goal: building and operating reliable systems without turning operations into exclusively manual work.**

## What I take from these seven chapters

When I started reading the book, my identification with SRE came mainly from the experiences I already had with infrastructure, monitoring, and automation. Many of the problems presented weren't new to me. I had already faced similar situations in different environments and organizations.

The difference is that, throughout the chapters, I began to see those experiences from another perspective.

At **Soluti**, I started as an infrastructure analyst, taking care of physical servers one by one. The first major change was virtualizing that environment, which grew from just over 20 servers to approximately 150, later reaching nearly 200 services and virtual machines. Then came Zabbix, Puppet, and the automation of configuration and release.

At that moment, my goal was to improve environment administration, make better use of resources, and reduce manual work. Today I can identify in those decisions some of the foundations presented in the book: standardization, toil reduction, and treating infrastructure as something that can be managed by software.

At **2Com Consulting**, the evolution came mainly from the need to scale. Processes that depended on Shell scripts and manual configurations were structured into Ansible roles and playbooks. Monitoring delivery, which used to take days, began to happen in approximately **30–40 minutes**. The ticket queue dropped by **more than 60%**, and the delivery backlog was wiped out, serving a base of approximately **700 clients**.

It was an important experience for understanding that automation isn't just time savings. It changes a team's capacity to meet demands, standardize environments, and maintain delivery quality as operations grow.

At **IBM** and later at **Kyndryl**, I began working in critical environments for large clients, with different technologies, operational requirements, and reliability needs. Monitoring, automation, and operations platforms continued to be part of my work, but scale and complexity brought other challenges.

More recently, my work also moved closer to software engineering, working with Go, APIs, and distributed systems, including automation platforms that need to execute processes at large scale.

Looking at that trajectory, I realize the change didn't happen from one tool to another. It was an evolution in the way of thinking about systems: from keeping servers running to understanding services, their behavior, their dependencies, and the impact a failure can cause.

But the reading also left some gaps quite clear.

**I automated processes, but I didn't formally measure toil. I monitored infrastructure, but I couldn't always measure the user experience. I pursued availability, but I didn't work with formally defined SLOs.**

Those realizations don't diminish the value of previous experiences. On the contrary, they help understand what I was doing, why I was doing it, and how I could have done better.

It's one of the most important contributions of this reading: not only recognizing what we already practice, but identifying what we still need to develop.

**The market turned SRE into a professional role, but to me it represents mainly an engineering discipline: studying continuously, applying the principles, and taking responsibility for the reliability of systems.**

## Continuous learning

Not everything I want to practice fits into the day-to-day work. So a good part of my study also happens in a lab, through small projects developed to experiment, make mistakes without consequences in production, and understand how the concepts work in practice.

Some open source projects were born exactly from that need to turn reading into experience.

[**srectl**](https://github.com/fabianoflorentino/srectl) is a local training environment for SRE, DevOps, and Platform Engineering, developed in Go, with Kubernetes, Argo CD, and the LGTM stack. It's where I can experiment with SLIs, SLOs, error budgets, and observability in a controlled environment.

[**seraph**](https://github.com/fabianoflorentino/seraph) came from the idea of building an independent status board that queries official status pages and presents the state of services. It's a way to explore availability and communication of operational status.

[**certificate-validate**](https://github.com/fabianoflorentino/certificate-validate) works with a very concrete indicator: the validity of SSL/TLS certificates. An expired certificate can make a service unreachable, even when all its components seem to be working normally.

[**fraudctl**](https://github.com/fabianoflorentino/fraudctl) is a Go API that receives payments and analyzes possible fraud. The project took part in this year's Rinha de Backend, finishing in 19th place, and also works as a testing ground for latency, error rate, and availability in a real application.

Each project represents a different opportunity to put into practice concepts that appear throughout the series.

None of them is a finished product, and that was never the intention. They're study, experimentation, and continuous learning projects. The goal is to build something concrete, test hypotheses, and understand the problems that appear when we leave theory.

**Theory only becomes discipline when it meets a system to practice on.**

## What comes next

Seven chapters later, I have a more structured view of SRE, but also a longer list of things I want to learn and experiment with.

I still need to go deeper into defining and tracking SLOs, improve the instrumentation of my projects, explore incident response practices, and better understand how to build systems with greater operational autonomy.

And that's exactly why the reading continues to make sense.

In the next post, we'll enter **Chapter 8: Release Engineering**.

So far, we've talked about reliability, risk, monitoring, and automation. Now the book addresses how to organize the software delivery process so releases are predictable, reproducible, and reliable.

After all, deploying an application is only part of the process. Ensuring a new version reaches production safely requires engineering.

Follow the series at [/en/series/sre/](/en/series/sre/).
