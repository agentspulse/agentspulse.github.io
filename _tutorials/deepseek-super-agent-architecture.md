---
layout: article-sky
article_variant: research-review
lang: en
title: "DeepSeek Super-agent: A Router and Worker Multi-Agent Architecture"
seo_title: "DeepSeek Super-agent: Router–Worker Multi-Agent Architecture"
description: "How DeepSeek's Super-agent design splits a resident Router from parallel Workers, routes events by thread, and what its synthetic experiments show."
keywords: "DeepSeek Super-agent, multi agent architecture, DeepSeek agent, proactive agents, router worker agent architecture"
tags: [deepseek-harness, deepseek, multi-agent, coding-agents, agent-infrastructure]
categories: [frontier-research]
permalink: /tutorials/deepseek-super-agent-architecture/
thumbnail: "/images/deepseek-super-agent-architecture/cover.jpg"
og_image: "/images/deepseek-super-agent-architecture/cover.jpg"
date: 2026-10-31
last_modified_at: 2026-10-31
author_name: "AgentsPulse Editorial Team"
cover_alt: "DeepSeek Super-agent system architecture with Router layer, Worker sessions, triggers, session database, and Watchdog"
cover_width: 1200
cover_height: 675
paper_count: 1
research_scope: "DeepSeek Harness team · Super-agent design exploration · dsh-superagent-prototype"
dek: "DeepSeek's Harness team published a design exploration for an agent that runs many tasks at once: one resident Router talks to people and dispatches work, isolated Workers do it in parallel."
key_takeaways:
  - "The bottleneck the design targets is human attention: the team observes that one person can usually follow only 3–5 active agent sessions."
  - "A lightweight resident Router handles interaction and dispatch; context-isolated Workers with full tools and the strongest model do the work and report back through the Router."
  - "In synthetic tests, Super-agent finished tasks faster and more consistently (p50/p95 12.4/15.7 min) than a single session with a Subagent tool, at the cost of more cache-read tokens."
  - "This is an architecture exploration, not a shipped DeepSeek Harness feature; the open-source prototype is a reference implementation only."
article_toc:
  - id: "deepseek-super-agent-at-a-glance"
    label: "Super-agent at a Glance"
  - id: "why-single-session-agents-hit-a-human-limit"
    label: "Why Single Sessions Hit a Limit"
  - id: "router-and-worker-layers"
    label: "Router and Worker Layers"
  - id: "event-driven-triggers-threads-and-subscriptions"
    label: "Triggers, Threads, Subscriptions"
  - id: "non-blocking-interaction-and-channel-specific-replies"
    label: "Non-blocking Interaction"
  - id: "cloud-agent-loop-local-execution"
    label: "Cloud Loop, Local Execution"
  - id: "what-the-experiments-show"
    label: "What the Experiments Show"
  - id: "the-open-source-prototype"
    label: "The Open-source Prototype"
  - id: "open-problems"
    label: "Open Problems"
  - id: "deepseek-super-agent-faq"
    label: "Super-agent FAQ"
  - id: "selected-sources"
    label: "Selected Sources"
related_research:
  - url: "/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/"
    title: "DeepSeek Harness Architecture"
    description: "How profiles, presets, bundles, and plugins compose the runtime that Super-agent builds on."
  - url: "/tutorials/deepseek-harness-modes-explained/"
    title: "DeepSeek Harness Modes Explained"
    description: "Standard, PTC, Minimal, and Creator modes compared by tools, execution, and trust."
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "Why harnesses, not frameworks, are becoming the production layer for agents."
---
On October 31, 2026, the DeepSeek Harness team published a long design essay, *Super-agent Design Exploration: Toward More Autonomous Agent Systems*, about letting one agent system move many pieces of work forward at the same time. Its answer is a two-layer multi-agent architecture: a resident **Router** that talks to people and dispatches work, and parallel **Worker** sessions that do the work. The team also open-sourced a reference prototype, [dsh-superagent-prototype](https://github.com/deepseek-ai/dsh-superagent-prototype). The essay states plainly that these designs are an architecture exploration, **not existing DeepSeek Harness product features**.

![DeepSeek Super-agent system architecture: triggers, two-level filter, Router layer, Worker sessions, multi-channel output, session database, execution environment, and Watchdog](/images/deepseek-super-agent-architecture/system-architecture.jpg)

*Overall Super-agent architecture. Labels 2–6 correspond to sections 2–6 of the original essay. Figure: DeepSeek Harness team (Chinese labels in the original).*

## DeepSeek Super-agent at a Glance

| Module | What it does | Key design choice |
|---|---|---|
| Two-layer architecture | Router dispatches; Workers execute | Router may run a lighter model with no Bash; Workers get full tools and the strongest model |
| Event-driven input | IM, email and calendar, code review comments, CI results become **Triggers** | Two-level filter: programmatic Fast Path, then LLM Slow Path |
| Human-facing interaction | Asynchronous tool calls; replies shaped per channel | IM replies capped at 100 words; GitHub and email get structured delivery |
| Compute / state / environment separation | Agent Loop in stateless cloud containers, sessions in a database | A lightweight local daemon executes commands on the user's own machine |
| Watchdog | Independent session driven by timed messages | External control loop for failures and stalled Workers |

**Short take:** Super-agent is a dispatch pattern for many concurrent, loosely related tasks, not a better way to solve one hard task. Its measured gains come from synthetic workloads and are labelled preliminary by the authors.

## Why Single-Session Agents Hit a Human Limit

Most agents today treat one **session** as the unit of work. Sessions do not share context, so a person running several tasks in parallel has to switch between them and remember what each one knows. The team observes that a person can usually keep up with only **3 to 5 active sessions**. In that setup, the model decides how well a single task goes, but human attention decides how many tasks can move at once.

Super-agent is meant to remember context across conversations and push several tasks forward together. The essay's example: a group agrees on plan A in an IM chat, then switches to plan B in a GitHub PR comment. Super-agent should recognize both as the same piece of work and change course. The team names four target properties: **continuous, efficient, proactive, and persistent**.

![An internal Super-agent instance moving a font-setting request from an IM group chat through GitHub review to merge](/images/deepseek-super-agent-architecture/im-to-github-thread.jpg)

*In an internal instance, a font-setting request moves from an IM group chat to GitHub review and merge. Figure: DeepSeek Harness team.*

## Router and Worker Layers

The essay starts from two extremes. Sending every event into one session gives the most continuous context, but a single ReAct loop runs serially and throughput is low. Opening a new session per event maximizes concurrency, but the results are fragmented and several sessions may each answer the user. DeepSeek splits these two jobs across two layers.

**Router layer.** A resident session receives human interaction from every entry point and aggregates cross-task information and decisions. It acts as the global ordering point, coordination point, and memory. It only interacts and dispatches; it can run without even a Bash tool. In the team's experience the Router's job is simpler than expected, and a lighter model often balances speed and quality well.

**Worker layer.** Each Worker session has isolated context, mounts the full set of execution tools, and focuses on one task. Because Workers directly determine code quality, they usually run the strongest model. Workers do not talk to users. They report status to the Router, which replies on their behalf. Inside a complex task, a Worker can open Subagents or form an Agent Team; that is invisible to the Router.

The essay separates this from a typical **Agent Team**. A Team Lead decomposes one complex task and coordinates members frequently, which is reasoning-heavy. The Super-agent Router handles only the relationships between tasks and their dispatch; it does not decompose work inside a single task.

## Event-Driven Triggers, Threads, and Subscriptions

Super-agent is driven by semi-structured events from its environment, which the essay calls **Triggers**: group chat messages, email and calendar reminders, code review comments, and CI results. Real group chats are noisy and rarely actionable, so events pass a two-level filter. A programmatic layer admits events deterministically by source, group, and allowlist (the **Fast Path**). Candidates that pass are then judged by an LLM against a prompt policy (the **Slow Path**).

Consecutive events in the same PR, IM topic, or email chain form a **Thread**. After the Router creates a Worker from the first event, the Worker subscribes to that Thread, and later events are delivered to it directly without passing through the Router. Subscriptions are many-to-many: if two Workers touch the same PR, both receive new events and can notice the conflict themselves, without point-to-point messaging.

![Thread subscription: the first event goes through the Router to create a Worker; later events in the same Thread go straight to that Worker](/images/deepseek-super-agent-architecture/thread-subscription.jpg)

*Subscription and direct delivery. The initial event takes the Slow Path through the Router; follow-up events in the same Thread take the Fast Path to the subscribed Worker. Figure: DeepSeek Harness team.*

### Context as a cache: Inline & Spill and Chain of Recall

The team manages the context window like a cache with two operations. **Inline** puts likely-needed information directly into context, such as the first 50 characters of a message or adjacent IM messages. **Spill** truncates whatever exceeds the budget and leaves a pointer for reading more. Triggers, Threads, and Worker sessions all have unique IDs, and injected content carries the IDs of related objects, so the model can follow them hop by hop from the current message. The essay calls this **Chain of Recall**. It lets the Router recover context when a user brings up an old task on a different channel, without stuffing all history into the window.

![Chain of Recall: each recalled object inlines the IDs of the next related objects](/images/deepseek-super-agent-architecture/chain-of-recall.jpg)

*Chain of Recall: every recalled object includes IDs for the next hop. Figure: DeepSeek Harness team.*

### Speculative execution

Proactivity also shows up as speculative work. In DeepSeek's internal DeepSeek Harness user group, the team configured a "silently reproduce and fix" policy. When someone reports a problem, the agent tries to reproduce and fix it in the background. It only speaks up once it has confirmed the issue and found a simple fix; otherwise it stays silent. In the essay's example, while group members were still discussing a bug where tildes rendered as strikethrough, Super-agent had already opened a fix PR.

## Non-blocking Interaction and Channel-Specific Replies

In a classic ReAct loop, calling `run()` blocks until the tool returns. Super-agent turns long commands and subtasks into asynchronous `start()` and `stop()` calls. The call returns `Started` immediately; when the background work finishes, its result is delivered back to the session as a new event, and the model can stop a command that runs too long. The essay says this asynchronous mechanism is already implemented in DeepSeek Harness but **not enabled by default**.

![Classic ReAct loop that blocks on tool calls compared with an asynchronous ReAct loop that returns Started and receives results as new events](/images/deepseek-super-agent-architecture/async-react-loop.jpg)

*Classic vs. asynchronous ReAct loop. Figure: DeepSeek Harness team.*

Output depends on the channel. In IM, the agent behaves like a colleague and only notifies people when a decision or sign-off is needed; the team validated a hard rule that a single reply stays **under 100 words**. GitHub, email, and documents get structured delivery: a PR description follows project conventions and states background, changes, and verification.

## Cloud Agent Loop, Local Execution

To stay online, DeepSeek borrows compute–storage separation. The computation that advances the Agent Loop runs in **stateless cloud containers**, and session state lives in a database, so containers can scale or restart at any time. The execution environment stays where it is: each endpoint runs only a lightweight daemon that holds no session state and just executes commands and returns results.

That makes **BYOM (Bring Your Own Machine)** possible: a developer machine with uncommitted changes and local credentials can connect directly, and when an intermittently online personal device comes back, the cloud agent can catch up on tasks that must run there. The essay notes this matches Anthropic's "brain and hands" separation idea; the difference is the target. Anthropic's write-up concerns a hosted service, while this design prioritizes the personal machines users already work on.

![Compute, persisted state, and execution environment decoupled: cloud Agent Loop and session database above, local daemons on developer machines, cloud environments, and intermittent devices below](/images/deepseek-super-agent-architecture/compute-storage-separation.jpg)

*Compute, persistent state, and execution environments are decoupled in two layers. Figure: DeepSeek Harness team.*

Outside the system runs an independent **Watchdog** session driven by timed messages, forming an external control loop. It handles infrastructure failures such as API errors and failed state recovery, and it asks the model whether each Worker is making real progress or drifting off course. Maintainers can ask it in natural language why something failed, and have it edit prompts or trigger rules online.

## What the Experiments Show

The team ran an ablation study on a stream of group chat and GitHub CI messages. Each run had about **300 messages**, of which about **20 were work requests**; the rest were chatter, follow-ups, stop requests, and CI messages. Coding work was replaced by a tool that only consumes time, so the experiment measures scheduling and coordination, not code quality. Message intervals and work durations were scaled to 1/4, model call latency was real, and each setup ran 5 times. **The authors note that the experiments use a synthetic load and a simplified environment, and the results are only a preliminary reference.**

![Ablation results: task completion time p50/p95 and cache-read tokens for Super-agent, Super-agent without direct delivery, and single session plus Subagent tool with neutral and delegate-first prompts](/images/deepseek-super-agent-architecture/ablation-results.jpg)

*Completion time and cache-read tokens across four setups. Figure: DeepSeek Harness team.*

| Setup | Task completion p50 / p95 (min) | Cache-read tokens per run (all sessions) |
|---|---|---|
| Super-agent | 12.4 / 15.7 | 23.23M |
| Super-agent, no direct delivery | 12.6 / 15.5 | 31.77M |
| Single session + Subagent tool, neutral prompt | 20.4 / 29.5 | 6.05M |
| Single session + Subagent tool, delegate-first prompt | 13.8 / 29.0 | 10.82M |

How to read it:

- **Neutral prompt:** across 5 runs the model never called the Subagent tool. All work stayed in the main session, which kept getting interrupted by new messages.
- **Delegate-first prompt:** the model delegated in 4 of 5 runs. In the remaining run it judged the work "small" and did it itself, which produced the long tail in p95.
- **Trade-off:** Super-agent bought shorter and more stable completion times with more tokens: 23.23M cache reads versus 6.05M and 10.82M for the single-session setups.
- **Without thread subscription (no direct delivery):** completion time barely changed (12.6/15.5 min), but the Router had to make about 30% more decisions and cache reads rose to 31.77M, roughly 37% more.

### Router batching under load

To stress the Router alone, the team used a real model for the Router and mock models for Workers. As the Trigger arrival rate rose from about 1 to about 40 per minute, average batch size grew from 1.0 to 2.8, single-request latency rose from 2.5 s to 3.9 s, and amortized inference time per decision fell from **6.4 s to 1.6 s**. Backlogged Triggers are merged into the next LLM call and computed in parallel during prefill. On that basis the team concludes that, at its current team size, one resident Router session is enough and horizontal partitioning is not yet needed.

![Router batch size and per-request latency versus trigger arrival rate, and amortized inference time per decision versus arrival rate](/images/deepseek-super-agent-architecture/router-batching.jpg)

*Router batch size, request latency, and amortized time per decision at different Trigger arrival rates. Figure: DeepSeek Harness team.*

## The Open-source Prototype

[dsh-superagent-prototype](https://github.com/deepseek-ai/dsh-superagent-prototype) is released under the MIT license. According to its README, it is a proactive coding agent for a single GitHub repository, packaged as a DeepSeek Harness bundle. It listens to GitHub and can optionally connect to Feishu. Each request becomes a work item with its own session and directory, the agent replies in the original conversation (for example by opening a PR), and a web dashboard lists only the items that need a human. The design doc sums up the principle in one line: "Take as little human attention as possible, and give as much value as possible."

The README is equally clear about limits. It is a research prototype for reference only, not an official DeepSeek product. Much of the code was written by a coding agent, it differs from both the internal version and the essay, and some designs in the essay are not implemented. The essay says internal Super-agent instances based on these ideas are already running continuously, reproducing and fixing issues, responding to code review, and contributing to DeepSeek Harness's own development.

## Open Problems

The essay closes with problems it has not solved:

- **Scaling coordination:** when the Router needs partitioning, and when Workers need to talk to each other directly.
- **Long-term memory** for agents that run for months.
- **Visibility:** how to present tasks to users once sessions are hidden.
- **Organizational boundaries:** context boundaries between multiple instances in one organization, and agent-to-agent (A2A) collaboration.
- **Security**, the most concrete item: if the cloud Agent Loop is compromised through a server breach or prompt injection, every connected endpoint could be controlled. The team still needs a mechanism that lets the agent use credentials without ever seeing them.

For how DeepSeek Harness bundles and presets fit together underneath, see [DeepSeek Harness Architecture](/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/) and [DeepSeek Harness Modes Explained](/tutorials/deepseek-harness-modes-explained/).

## DeepSeek Super-agent FAQ

### Is Super-agent a DeepSeek Harness feature I can turn on?

No. The essay describes it as an architecture exploration, not an existing product feature. The asynchronous `start()`/`stop()` loop is implemented in DeepSeek Harness but off by default, and the public prototype is a research reference.

### How is the Router different from an Agent Team lead?

A Team Lead breaks one complex task into parts and coordinates members closely. The Super-agent Router only tracks how separate tasks relate and dispatches them; decomposition inside a task stays with the Worker.

### Does Super-agent use fewer tokens?

Not in the published experiment. It used more cache-read tokens than single-session setups (23.23M vs. 6.05M or 10.82M) in exchange for shorter, more stable completion times. Thread subscription is what kept its token use from rising further.

### Can the experiment results be generalized?

Only cautiously. The load was synthetic, coding was simulated by a time-consuming tool, timing was scaled to 1/4, and each setup ran 5 times. The authors call the results preliminary.

## Selected Sources

- [DeepSeek Harness team, *Super-agent Design Exploration: Toward More Autonomous Agent Systems* (Chinese, WeChat)](https://mp.weixin.qq.com/s/zoS7GlReWPhfCjENGxXCdg)
- [dsh-superagent-prototype repository](https://github.com/deepseek-ai/dsh-superagent-prototype)
- [Prototype design philosophy](https://github.com/deepseek-ai/dsh-superagent-prototype/blob/main/docs/000-philosophy.md)
- [DeepSeek Harness](https://www.deepseek.com/en/harness/)
