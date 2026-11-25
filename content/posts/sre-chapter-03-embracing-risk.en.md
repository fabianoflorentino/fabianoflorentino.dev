---
date: '2026-11-20T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Embracing Risk'
translationKey: sre_chapter_03_embracing_risk
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-03.png
translation:
  url: /posts/sre-chapter-03-embracing-risk/
  text: Versão em português
---

This is the third post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). After understanding the production environment, the book now introduces one of SRE's most counterintuitive — and most important — ideas: **why 100% availability is the wrong goal**.

## Why 100% is not the goal

It sounds absurd at first. Why wouldn't Google try to build services that never fail?

The chapter answers with a simple observation: **past a certain point, more reliability makes a service worse, not better**. Extreme reliability is expensive — it limits how fast new features ship, drives up cost, and reduces the number of features a team can afford.

And there's an even stronger point: **users can't tell the difference**. Someone on a smartphone that is already 99% reliable can't distinguish a 99.99% service from a 99.999% one — the experience is dominated by less reliable components like the cellular network.

The conclusion is the essence of the chapter: **SRE doesn't try to maximize uptime, but to balance the risk of unavailability against fast innovation**. What gets optimized is the user's overall happiness — features, service, and performance together.

## Reliability has a cost and isn't linear

The book makes an uncomfortable claim: **cost doesn't grow linearly with reliability**. Adding one more "nine" of availability can cost 100x more than the previous increment.

That cost has two dimensions:

- **Redundant resources** — extra machines and equipment that let you take systems down for maintenance, or store parity blocks for durability.
- **Opportunity cost** — engineers allocated to reducing risk instead of building user-visible features. Every engineer dedicated to reliability is one who isn't shipping new product.

SRE treats risk as a **continuum**. The goal is to make a service **reliable enough — but no more reliable than it needs to be**. The availability target becomes, at once, a minimum and a maximum.

## Measuring risk

How do you turn "risk" into something measurable? The book focuses on **unplanned downtime**, expressed in "nines" of availability: 99.9%, 99.99%, 99.999%. Each additional nine is an order of magnitude.

For reference: a 99.99% target allows **52.56 minutes of downtime per year**. The full table is in the [book's appendix](https://sre.google/sre-book/availability-table/).

But Google rarely uses a time-based metric. Because services are globally distributed, being "partially up" is the norm. That's why availability is measured by **request success rate** over a window: a service serving 2.5 million requests a day with a 99.99% target can fail up to 250 requests.

## How much risk each service can tolerate

Risk tolerance isn't a magic number — it depends on the service. The book splits the analysis between consumer and infrastructure services.

**Consumer services** have a product team that translates business goals into objectives. The availability target depends on: what users expect, whether the service ties to revenue, whether it's paid or free, and what competitors offer. Examples: **Google Apps for Work** targets 99.9% (enterprise users who depend on it to work); **YouTube**, right after the acquisition, got a lower target — at that moment, speed of evolution mattered more than extreme stability.

The **type of failure** also matters. A constant low rate of failure is different from an occasional full outage. The chapter's example is striking: in a contacts app, profile pictures that fail to load are annoying; **exposing one user's private data to another** is serious enough to take the whole service down during the investigation.

And then there's **cost**. For Ads, the trade-off is direct: every request translates to revenue. The book does the math — for a $1M service, going from 99.9% to 99.99% is worth $900; it only pays off if the cost is lower than that. A useful shortcut: the background error rate of ISPs sits between 0.01% and 1%; failing below that means "disappearing into the noise".

**Infrastructure services** are trickier, because they have multiple clients with opposite needs. The **Bigtable** example is perfect: those serving data in the request path want low latency and empty queues; those doing offline analysis want throughput and never-empty queues. The solution is to **partition the service into levels**: low-latency clusters (expensive) and throughput clusters (far cheaper, sometimes 10–50% of the cost). At Google+, privacy-critical data went to **Spanner** (consistent and global), and optional data to a cheaper datastore. ([Bigtable and Spanner descriptions in chapter 2](/posts/sre-chapter-02-production-environment/))

The general lesson: **expose the cost and let clients choose their level of service**. Constraints that seem incompatible resolve themselves when each service level has an explicit price.

## Error budget: risk that becomes a decision

This is the most practical part of the chapter. There's a natural tension between the product team (wants velocity) and SRE (wants reliability). Each sees half the problem — and without an objective criterion, the negotiation becomes politics. SRE's unofficial motto sums it up: **"hope is not a strategy"**.

The **error budget** solves this. Here's how it works:

1. The product team defines an **SLO** — how much uptime the service should have per quarter.
2. Monitoring measures actual uptime, as a neutral third party.
3. The difference between the two is the **error budget** — how much "unreliability" is left in the quarter.

In practice: an SLO of 99.999% gives an error budget of 0.001% failures. If a problem causes 0.0002% failures, it spent **20% of the quarter's budget**.

The magic is that the error budget **aligns incentives**. While budget remains, the team can ship fast. When it's nearly drained, the product team itself starts asking for more testing and less haste — because nobody wants to blow the budget and stall the launch. The team becomes **self-policing**. And if the team is struggling to launch, they can loosen the SLO — increasing the budget — to gain speed.

## What I take from this chapter

What struck me most in this chapter was seeing the book name a tension I lived constantly, without ever having a clear criterion to resolve it.

At **Soluti**, where I worked, the conversation between development and operations was always the same: **one side wanted to ship, the other wanted to stabilize** — and there was no number to arbitrate it. It was only when I started adopting **DevOps**, bringing the teams together, that I understood the problem wasn't the people — it was the **lack of a shared objective**. The error budget is exactly that: an objective both sides accept, taking the decision out of politics.

The idea of "reliable enough" also changed how I saw a project. At a major Brazilian retailer, **production and development shared the same Kubernetes cluster** — meaning the business was taking on a risk nobody had quantified. Separating them into dedicated clusters wasn't just a technical improvement: it was **aligning the accepted risk with the business's real tolerance**. Production got high availability, and development gained the freedom to fail without taking the customer down.

And the opportunity cost is, to me, the most honest part. Every hour I spent delivering servers by hand or fighting fires was time **not invested** in improving the environment. When I automated with Puppet and Ansible — from **days to minutes**, with the ticket queue dropping by **over 60%** — what I gained wasn't just speed: it was giving that time back to real engineering.

In the end, the idea that stays with me is this: **reliability isn't an end in itself**. It's a currency you trade for speed, cost, and features. Those who treat availability as dogma pay dearly; those who treat it as a budget make conscious choices.

## Next chapters

In the next post, I'll cover **Chapter 4: Service Level Objectives**. That's where the book formalizes what the error budget assumes: how to define SLOs, SLIs, and SLAs — and why choosing the right indicators is half the work.

Follow the series at [/series/sre/](/series/sre/).
