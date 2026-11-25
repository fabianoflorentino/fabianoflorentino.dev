---
date: '2026-11-25T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: The Evolution of Automation at Google'
translationKey: sre_chapter_07_evolution_of_automation
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-07.png
translation:
  url: /posts/sre-chapter-07-evolution-of-automation/
  text: Versão em português
---

This is the seventh post in the series on [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). After covering toil and monitoring, the book turns to the tool that promises to solve both: automation. [Chapter 7](https://sre.google/sre-book/automation-at-google/) starts with an important correction: **automation is a force multiplier, not a panacea**.

## Automation is a force multiplier, not a panacea

The chapter doesn't sell automation as a synonym for maturity. It shows the real value:

- **Consistency**: humans perform the same task in slightly different ways; machines don't.
- **A platform**: one fix in the code applies to everyone; a mistake is also centralized and visible.
- **Faster repairs**: automating common failures reduces MTTR and frees up time.
- **Faster action**: failover and traffic switching shouldn't wait for someone to press a button.
- **Time savings**: the gain isn't only for the person who wrote the automation; it's for everyone who can now execute the task without understanding its internals.

That last point is the most underrated. Automation **decouples the operator from the operation**. A task that required a person with access and context becomes executable by any authorized person — or by nobody, if the system can take care of itself.

But the chapter is also honest: automating without understanding just multiplies the error in the same direction. And the best solution isn't always to automate the manual task; sometimes it's to **redesign the system so the task no longer exists**.

**Automation without understanding is just a faster way to fail at scale.**

## The automation ladder

The chapter organizes the evolution into five levels:

1. **No automation**: the database master is failed over manually.
2. **Externally maintained, system-specific automation**: someone has a failover script in their home directory.
3. **Externally maintained, generic automation**: the team adds database support to a generic script.
4. **Internally maintained, system-specific automation**: the database ships with its own failover script.
5. **Systems that don't need automation**: the database detects the problem and fails over on its own.

Most companies stop at level 2 or 3. Level 4 already requires the team that operates the service to own the automation. Level 5 is the autonomous system: it monitors itself, repairs itself, and only calls a human when it really needs to.

The chapter calls this **autonomy**, not automation. The difference isn't semantic: automation executes a recipe; autonomy makes decisions within safe boundaries. And, as the text reminds us, autonomy is hard to retrofit into large systems. It's easier to design it from the start.

**The goal isn't to automate the manual task; it's to design the system so it doesn't need external glue.**

## Automation is software

Tools like Puppet, Chef, cfengine, and even Perl offer different levels of abstraction. The higher the abstraction, the easier it is to reason about — and the worse it is when it leaks. The chapter's example is simple: pushing a binary looks atomic, but the network can fail halfway, a machine can fail, and the cluster can end up with half the old version and half the new one.

Automation also **ages**. Scripts created for one scenario become debt when the system changes and nobody updates the script. The chapter shows **Prodtest**, which used production tests to detect inconsistent configurations. The natural evolution was to pair each test with an **idempotent** fix: running it again doesn't make the state worse, and the process can be repeated safely.

But that approach had traps too: flaky tests, fixes that weren't truly idempotent, and the temptation to centralize everything in a "turnup" team. When automation leaves the hands of the people who operate the service, the incentives go wrong: the turnup team wants speed now, but doesn't suffer the technical debt later. The lesson was to move automation to the service owners, with APIs, permissions, and auditing.

**Automation that isn't treated as software becomes technical debt with a cron job.**

## When automation becomes a risk

The chapter has an example that should haunt anyone who has ever written a cleanup script. An automation for decommissioning racks wiped the disks of the machines. After a failure, the process was restarted; the disk-erase step received an empty set of machines. But in that implementation, the empty set was interpreted as "everything." The result: the automation started wiping disks across practically the entire Google CDN.

The system survived because there was planned capacity and replication, but the episode shows the pattern: **automation can enable failure at scale**. The fix came with sanity checks, rate limiting, and idempotency.

There's another, less obvious cost: human atrophy. The more automation covers, the less people practice the manual operation. When it fails, nobody remembers how to act. That's why the chapter argues for introspection, visibility, and regular drills. Good automation doesn't hide the system; it makes the system easier to understand when something goes wrong.

**Reliability is the fundamental feature — and automation only helps if it doesn't remove the brake.**

## What I take from this chapter

At **Soluti**, administration started with **ShellScript and CronJobs**. It worked for a small environment, but not for a fleet that grew from just over **20 servers to 100 and then 150**. The delivery process followed the regulator's compliance requirements and was manual; each environment took days.

With **Puppet**, the process became code. I developed GitLab-versioned modules for configuration, compliance, and release of a PHP/Apache application, including file diff checks, server configuration, and service restarts. Delivery time dropped from days to minutes. But, looking at the chapter's ladder, that was **level 4 in parts**: system-specific automation, maintained internally, still dependent on a human to decide when to run it.

At **2Com Consulting**, the path was similar — and different. I started with Shell scripts to deliver monitoring. I tested **Puppet**, but the server-agent model, dedicated infrastructure, and dependence on stable connectivity weighed against it. The choice was **Ansible**: agentless, declarative, SSH/WinRM. With GitLab-versioned roles and playbooks, delivery dropped from days to **30–40 minutes**, the ticket queue shrank by **more than 60%**, and the delivery backlog was wiped out, serving a base of roughly **700 clients**.

What I didn't have was level 5. Not even close. I automated tasks; I didn't build systems that repaired themselves. And, at first, I didn't treat automation as software either: versioning, READMEs, idempotency, and testing came through pain, not method.

Today, working on an automation platform in Go, I see the same pattern at another scale: the hard part isn't executing the task. It's maintaining contracts, versions, observability, and security so that one change doesn't break everything.

**My next level isn't writing more playbooks; it's designing systems that need less glue.**

## Next chapters

In the next post, I'll cover **Chapter 8: Release Engineering**. It's the chapter that shows why "it works on my machine" isn't a delivery process — and what separates a deploy from a reliable release.

Follow the series at [/series/sre/](/en/series/sre/).
