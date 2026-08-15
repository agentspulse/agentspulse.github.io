---
layout: article-sky
article_variant: research-review
lang: en
title: "The Agent Framework Is Not the Runtime: Why Harnesses Are Taking Over Production"
seo_title: "The Agent Framework Is Not the Runtime: Why Harnesses Are Taking Over Production"
description: "Why production agent systems separate framework APIs from a harness that owns state, tool boundaries, control loops, and observability."
keywords: "agent harness, agent runtime, production agents, observability, agent framework"
tags: [agent-infrastructure, frontier-research]
categories: [frontier-research]
permalink: /tutorials/agent-framework-harness-runtime-production/
thumbnail: "/images/agent-framework-harness-runtime-production/githubio_harness_runtime_00_architecture.jpg"
og_image: "/images/agent-framework-harness-runtime-production/githubio_harness_runtime_00_architecture.jpg"
date: 2026-08-05
last_modified_at: 2026-08-05
author_name: "AgentsPulse Editorial Team"
cover_alt: "The Agent Framework Is Not the Runtime: Why Harnesses Are Taking Over Production"
cover_width: 1200
cover_height: 685
paper_count: 1
research_scope: "Agent harnesses · Runtime · Observability"
dek: "Why production agent systems separate framework APIs from a harness that owns state, tool boundaries, control loops, and observability."
key_takeaways:
  - "Evidence-led analysis of the architecture, operational constraints, and production implications."
  - "Separates vendor-reported results from claims supported by broader evidence."
  - "Focuses on implementation decisions practitioners can evaluate today."
article_toc:
  - id: "tl-dr"
    label: "TL;DR"
  - id: "what-harness-means-concretely"
    label: "What \"Harness\" Means, Concretely"
  - id: "why-frameworks-alone-stopped-being-enough"
    label: "Why Frameworks Alone Stopped Being Enough"
  - id: "the-isolation-boundary-is-where-security-lives"
    label: "The Isolation Boundary Is Where Security Lives"
  - id: "training-and-runtime-are-converging-on-the-same-substrate"
    label: "Training and Runtime Are Converging on the Same Substrate"
  - id: "a-comparison-across-the-four-harness-implementations"
    label: "A Comparison Across the Four Harness Implementations"
  - id: "retries-compaction-and-the-boring-work-that-actually-matters"
    label: "Retries, Compaction, and the Boring Work That Actually Matters"
  - id: "observability-has-to-live-inside-the-loop-not-beside-it"
    label: "Observability Has to Live Inside the Loop, Not Beside It"
  - id: "a-composite-control-layer-table"
    label: "A Composite Control-Layer Table"
  - id: "what-to-do-now"
    label: "What to Do Now"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/"
    title: "DeepSeek Harness Architecture"
    description: "How DeepSeek applies an everything-is-a-plugin architecture to models, tools, sessions, approvals, and sandboxes."
  - url: "/tutorials/self-evolving-agents-review-en/"
    title: "Self-Evolving Agents"
    description: "A survey of agents that improve models, harnesses, and artifacts."
  - url: "/tutorials/real-time-voice-agents-distributed-systems/"
    title: "Real-Time Voice Agents Are Distributed Systems"
    description: "How continuous voice systems change runtime requirements."
---
<img src="/images/agent-framework-harness-runtime-production/githubio_harness_runtime_00_architecture.jpg" decoding="async" loading="lazy" width="1200" height="685" alt="The Production Agent Harness" />

*The Production Agent Harness.*

Observability for agents is not an add-on to the framework. It is a property of the harness — because the harness is the only layer with visibility into every model call, tool invocation, and delegation across a session's full lifetime.

---

Four separate engineering organizations published, within roughly the same week, accounts of the same architectural decision: pull agent execution out of the framework layer and into a dedicated harness that owns state, tools, and control. Microsoft shipped a GitHub Copilot integration for Agent Framework in which "Copilot owns the agent loop... while Agent Framework gives you a consistent surface" for everything around it — instructions, middleware, approvals, telemetry ([Microsoft Agent Framework](https://devblogs.microsoft.com/agent-framework/build-production-ready-agents-with-the-github-copilot-harness-and-agent-framework/)). Kiro's engineering team described collapsing three independent, language-specific agent implementations — TypeScript, Rust, Python — into a single standalone harness process reachable over a protocol, because "shared libraries don't enforce a strong enough boundary" ([Kiro](https://kiro.dev/blog/one-agent/)). Stripe's AI platform team built their company-wide agent, Kai, on LangChain's Deep Agents harness, explicitly to avoid re-solving "the non-Stripey problems" of tool-calling loops, middleware, and state management ([LangChain](https://www.langchain.com/blog/how-stripe-built-their-knowledge-ai-platform-on-deep-agents)). And a CNCF blog post on production observability described why standard APM cannot answer the questions that matter for agents, converging on trace-and-audit infrastructure that has to live below the framework, inside the execution path itself ([CNCF](https://www.cncf.io/blog/2026/08/04/you-cant-debug-what-you-cant-see-observability-for-ai-agents/)).

None of these four teams cite each other. They are not describing a trend they read about; they each ran into the same problem independently, at different companies, with different stacks, and arrived at structurally similar answers. That convergence — not any single vendor's roadmap — is the evidence worth taking seriously here, precisely because it did not come from a shared playbook.

## TL;DR

- Four independent engineering teams (Microsoft, Kiro, Stripe/LangChain, and a CNCF-affiliated operator) each separated agent frameworks from a dedicated execution runtime — a harness — that owns state, tool boundaries, retries, and telemetry.
- The harness pattern recurs across languages and stacks: Kiro's is a standalone process behind Agent Client Protocol; Stripe's is a layer on top of Deep Agents; Microsoft's Copilot integration keeps the agent loop inside Copilot's own CLI/SDK.
- Vendor-reported production numbers are notable but scoped to single deployments: Stripe reports current weekly usage of 83% across more than 60,000 sessions, following 16x user growth from 296 to more than 5,000 over roughly four weeks of open preview, per LangChain's account of Stripe's own reporting.
- Microsoft's Orchard research shows that training agents inside the actual deployment harness — rather than a simplified training stand-in — materially changed one benchmark result (18.6% to 51.5% success under the Codex harness), a single-system finding, not a general law.
- Observability practice is shifting from generic APM toward harness-embedded tracing, cost-per-session accounting, and loop detection, because standard monitoring cannot see inside a multi-turn agent loop.
- Framework APIs (Agent Framework, LangGraph/Deep Agents, Mini-SWE-Agent) remain the way engineers write agent logic, but the runtime that actually executes, isolates, and observes that logic is increasingly a separate, reusable layer.

## What "Harness" Means, Concretely

The word harness gets used loosely across the industry, so it is worth being precise about what these four sources mean by it, because the definitions converge even though the vocabulary varies.

Kiro's post gives the tightest definition: "the agent harness is the orchestration layer that manages the agent loop, tool execution, sub-agent delegation, session management, configuration loading, and communication with the model" ([Kiro](https://kiro.dev/blog/one-agent/)). Stripe's engineers describe Deep Agents in nearly identical terms — "the tool-calling loop, middleware composition, streaming, and state management" — as the layer that took Kai from zero to a working production agent in one engineer-week ([LangChain](https://www.langchain.com/blog/how-stripe-built-their-knowledge-ai-platform-on-deep-agents)). Microsoft's Copilot integration draws the same boundary from the other direction: "Copilot owns the agent loop (model calls, tool invocation, planning, and session state) while Agent Framework gives you a consistent surface for instructions, tools, streaming, middleware, observability, and human-in-the-loop approval" ([Microsoft Agent Framework](https://devblogs.microsoft.com/agent-framework/build-production-ready-agents-with-the-github-copilot-harness-and-agent-framework/)).

What is notable is what falls on the harness side of that line in every account: execution state, tool invocation and permissioning, retries and error recovery, sandboxing or isolation, and telemetry. What falls on the framework side is closer to developer ergonomics — how you declare tools, write prompts, wire middleware, and consume the agent's output. The framework is a programming model. The harness is a runtime.

This distinction is not new to software generally — it echoes the separation between an application framework and the operating system or container runtime underneath it. What is new is that agent systems accumulated enough operational surface area (session state, permission systems, sandboxed execution, cost accounting) that this separation became necessary rather than optional, within roughly a year of agentic coding tools reaching broad developer use.

## Why Frameworks Alone Stopped Being Enough

Kiro's account is the most direct evidence of what happens when a harness does not exist as a distinct layer. Their IDE, CLI, and web clients each built their own agent implementation — in TypeScript, Rust, and Python respectively — optimizing for speed within each team. The consequence, as they describe it, was compounding: "session storage worked differently across clients," permission systems used "incompatible syntax," compaction strategies diverged, and "every new capability had to be built and maintained three times, sometimes resulting in slightly varying agent behaviors" ([Kiro](https://kiro.dev/blog/one-agent/)).

This is a single company's account of its own architecture, not a controlled study, but the mechanism it describes is generalizable: when agent logic is embedded separately inside each client rather than factored into a shared runtime, the surface area that needs independent implementation — state handling, permission evaluation, retry and compaction logic — grows linearly with the number of clients, while the cost of keeping those implementations behaviorally consistent grows faster still. Kiro's team explicitly considered the alternative of writing shared behavior contracts and implementing them three times, and rejected it because "interface alignment also introduces coordination overhead that grows with every new feature."

Stripe's account illustrates the inverse case: what a harness buys you when it already exists. Anupam Upadhyay built Kai's first working version in one week on top of Deep Agents, and the LangChain writeup attributes that speed specifically to middleware Stripe did not have to build — filesystem middleware backed by S3 for cross-turn context, sandbox middleware that keeps code execution outside the agent's own execution boundary, and summarization middleware for long sessions ([LangChain](https://www.langchain.com/blog/how-stripe-built-their-knowledge-ai-platform-on-deep-agents)). This is a vendor-adjacent account — LangChain is describing a customer's use of its own product — so the one-week figure should be read as a specific, attributed claim about a specific build, not a general estimate of harness ROI. But the architectural detail underneath it is verifiable independent of the framing: Stripe layered a company-specific harness on top of Deep Agents, and a configuration layer on top of that, rather than writing tool-calling and session logic from scratch.

## The Isolation Boundary Is Where Security Lives

A recurring, specific mechanism across three of the four sources is that execution isolation is not incidental to the harness design — it is close to the reason the harness exists as a separate process or sandbox in the first place.

<img src="/images/agent-framework-harness-runtime-production/githubio_harness_runtime_02_stripe-s-kai-architecture-built-on-deep-agents.jpg" decoding="async" loading="lazy" width="1200" height="675" alt="Stripe's Kai architecture built on Deep Agents" />

*Stripe's Kai architecture built on Deep Agents.*

Stripe's sandbox middleware is described explicitly in security terms: "the sandbox is exposed to the agent as a tool, not as the execution environment for the agent itself. The agent runs outside the sandbox and calls into it, keeping execution boundaries clean and preventing a class of security concerns with LLM generated code" ([LangChain](https://www.langchain.com/blog/how-stripe-built-their-knowledge-ai-platform-on-deep-agents)). Microsoft's Copilot integration makes the same boundary explicit through permissioning rather than process separation: every shell command, file write, URL fetch, and MCP call is gated by a permission handler, and by default "nothing runs without oversight" ([Microsoft Agent Framework](https://devblogs.microsoft.com/agent-framework/build-production-ready-agents-with-the-github-copilot-harness-and-agent-framework/)).

Kiro went furthest architecturally, replacing per-tool, per-client permission syntax with a capability-based policy model built on Cedar, a formally verified policy language, where "a deny on `fs_read` blocks every tool that reads files... without enumerating them individually" ([Kiro](https://kiro.dev/blog/one-agent/)). The problem they describe solving — that a single intent like denying reads to a `.env` file previously had to be configured separately for every tool capable of reading files, and missing one left a bypass — is a concrete, named security gap, not a hypothetical. It is also fixable only at the harness layer, because only the harness has visibility into every tool that could serve as a read path.

None of these sources claim their isolation approach eliminates security risk; they describe it as reducing a specific, named class of exposure. Orchard's release notes similarly frame its Kubernetes-based environment isolation as an infrastructure property — thousands of isolated components created and torn down in parallel — without claiming this makes training safe in any absolute sense, only that it makes scaled, reproducible experimentation possible ([Microsoft Research](https://www.microsoft.com/en-us/research/blog/orchard-an-open-framework-for-scalable-agentic-ai/)).

## Training and Runtime Are Converging on the Same Substrate

Orchard is a research artifact, not a production system, and it comes from Microsoft Research rather than a product team, but it supplies a mechanism the other three sources only gesture at: harnesses are becoming the substrate for training agents, not just running them.

<img src="/images/agent-framework-harness-runtime-production/githubio_harness_runtime_01_orchard-s-scalable-agent-environment-architecture.jpg" decoding="async" loading="lazy" width="1200" height="578" alt="Orchard agent benchmark results across model scales" />

*Orchard-SWE and Orchard-GUI benchmark results across model scales.*

The specific claim is that "open training tools usually cannot handle... stateful, multi-process harnesses, forcing researchers to train on a simplified stand-in and then deploy in the real setting, which creates a mismatch," and that Orchard closes this gap with "a lightweight proxy" that records a harness's own model calls as training data while each rollout runs in its own container ([Microsoft Research](https://www.microsoft.com/en-us/research/blog/orchard-an-open-framework-for-scalable-agentic-ai/)). The reported effect, specific to Orchard-Claw evaluated on the Claw-Eval benchmark, is that under the Codex harness, success rate rose from 18.6% for the untrained model to 51.5% after training directly inside that harness. This is a single benchmark result on a single training recipe; it does not establish that harness-native training generally outperforms simplified training environments across other tasks or model families, and Microsoft's own writeup does not make that broader claim.

What it does establish, credibly, is that the harness is not just a deployment convenience — it is close enough to the model's actual operating conditions that training against a different, simplified environment measurably changes downstream behavior in at least this one case. That is a mechanism worth flagging for any team doing reinforcement learning or fine-tuning against agent traces: if your training environment does not reproduce the harness's tool-call format, retry behavior, and state handling, the resulting policy may transfer worse to production than benchmark numbers suggest.

## A Comparison Across the Four Harness Implementations

The four sources describe different products solving overlapping problems in different ways. Laid side by side, the differences are as informative as the similarities.

| Dimension | Kiro | Stripe / Deep Agents | Microsoft / GitHub Copilot Agent | Orchard (research) |
|---|---|---|---|---|
| Harness form | Standalone server process, protocol boundary (ACP) | Library/middleware layer inside a Python service | Vendor CLI/SDK (Copilot) wrapped by a framework adapter | Kubernetes-based environment service plus training proxy |
| State ownership | Harness owns session, tool set, config; client owns presentation | Deep Agents owns tool loop and middleware state; Stripe layer adds domain state | Copilot SDK owns agent loop and session state | Environment owns isolated rollout containers; harness proxy owns replayable trace |
| Isolation model | Capability-based policy (Cedar), deny-always-wins | Sandbox exposed as a tool, agent runs outside it | Per-action permission handler, default-deny | Per-rollout container isolation at Kubernetes scale |
| Cross-surface reuse | Same harness across IDE, CLI, web, iOS via ACP/WebSocket | Same Deep Agents base across Stripe's internal Kai variants | Same Agent Framework surface across multiple agent providers | Same environment across SWE, GUI, and assistant task domains |
| Evidence type | Primary engineering account, single company | Primary/vendor-adjacent account, single customer | Primary vendor documentation, released feature | Primary research release, benchmark results |

<img src="/images/agent-framework-harness-runtime-production/githubio_harness_runtime_03_orchard-ecosystem.jpg" decoding="async" loading="lazy" width="1200" height="650" alt="Orchard environment and training ecosystem" />

*Orchard connects domain-specific benchmarks to a shared environment service and training pipeline.*

The table understates one point worth stating directly: three of the four are describing production systems already serving real users, while Orchard is a research framework whose benchmark numbers describe held-out evaluation sets, not live traffic. Treat the Orchard results as evidence about mechanism — harness-native training changes agent behavior — rather than evidence about production reliability.

## Retries, Compaction, and the Boring Work That Actually Matters

It is tempting to focus on the more visible harness features — permissions, sandboxing, multi-client protocols — because they are architecturally interesting. But two of the sources are explicit that a large share of the harness's practical value comes from unglamorous reliability work that only makes sense to do once, centrally.

<img src="/images/agent-framework-harness-runtime-production/githubio_harness_runtime_04_control-loop.jpg" decoding="async" loading="lazy" width="1200" height="675" alt="Inside the Harness Control Loop" />

*The harness owns the repeated control path between request context, execution policy, and evaluated outcomes.*

Kiro's team reports that after consolidating three separate compaction implementations into one, they "shipped improved compaction prompts in the harness for better context retention," along with "improved retry logic for model inference requests, faster permission evaluation, and more resilient MCP server connections" — and that "every client benefits from these changes" without client-side code ([Kiro](https://kiro.dev/blog/one-agent/)). This is the clearest illustration of the durability argument for a harness layer: retry logic, compaction strategy, and connection resilience are the kind of code that degrades when reimplemented three times under time pressure, and improves when there is exactly one implementation that all surfaces depend on.

The CNCF observability post supplies a different angle on the same theme: it describes agent failure modes that do not resemble traditional service failures at all. "Agents don't crash with stack traces. They loop, hallucinate, burn tokens, and produce plausible-looking output that's subtly wrong" ([CNCF](https://www.cncf.io/blog/2026/08/04/you-cant-debug-what-you-cant-see-observability-for-ai-agents/)). This is a first-person operational account from an unnamed team ("we've been running AI agents in production for months"), not a named case study, so its claims should be read as one team's practitioner experience rather than an industry-wide statistic. But the specific failure mechanism it describes — geometric token burn from a tool-calling loop that a traditional APM system would report as normal request volume — is mechanically plausible given how agent loops are structured, and it is precisely the kind of failure that only a harness sitting inside the execution path can detect, because detecting it requires seeing consecutive identical tool calls within a single session, not aggregate service metrics.

## Observability Has to Live Inside the Loop, Not Beside It

The CNCF post's argument is narrower and more mechanical than a general claim that "agents need observability" — it is specifically that the unit of analysis for agent monitoring is the session trace, not the request, and that this changes what infrastructure you need.

Their recommended architecture has three components: traces that capture "the full decision history: each model call, each tool invocation, each sub-agent delegation, with timing and cost attached"; cost accounting at both the per-session and per-agent-over-time level, because "an agent that loops... burns tokens geometrically" and reactive alerting is "not fast enough" against a tight loop that can exhaust budget in seconds; and an append-only audit log with PII redaction applied before logging, not after ([CNCF](https://www.cncf.io/blog/2026/08/04/you-cant-debug-what-you-cant-see-observability-for-ai-agents/)).

The specific engineering detail that ties this back to the harness argument is about where trace delivery has to sit in the execution path: "tool execution should never wait on a synchronous HTTP POST to a tracing backend," so spans must buffer and flush asynchronously, with the property that "if the trace backend is temporarily unreachable, you lose telemetry — not availability." That is a harness-level guarantee. A framework that merely exposes an event hook cannot make that promise on its own; something has to own the buffering and the flush lifecycle, and that something is, in every account here, the execution layer that sits between the model and the tools — the harness, not the framework's public API.

The post's cardinality warning is worth preserving with its own qualification, because it is a specific operational failure mode rather than general advice: putting unique session IDs into Prometheus labels causes a cardinality explosion "that crashes the metrics server" at the scale of "thousands of agent sessions daily." That is a stated consequence for high-cardinality label use at that specific scale, not a universal threshold, and teams running fewer concurrent sessions may not hit it the same way.

## A Composite Control-Layer Table

Pulling the responsibilities across all four sources into one place clarifies which concerns are converging onto the harness and which remain genuinely in the framework's domain.

| Concern | Owned by harness (per these sources) | Owned by framework/API |
|---|---|---|
| Agent loop / model call sequencing | Yes — Copilot SDK, Deep Agents, Kiro harness all cited as loop owners | No — frameworks compose around the loop, don't drive it |
| Tool permissioning | Yes — Cedar policies (Kiro), permission handlers (Microsoft), sandbox boundary (Stripe) | Framework defines tool schema, not enforcement |
| Session/state persistence | Yes — session resumption, virtual filesystem, ACP session lifecycle | Framework may expose session objects but doesn't persist them independently |
| Retries and resilience | Yes — Kiro reports centralizing retry logic and MCP connection resilience | Framework middleware can wrap retries but harness owns the underlying calls |
| Telemetry/tracing | Yes — must sit inside execution path for non-blocking span capture | Framework can integrate with OpenTelemetry but doesn't generate the spans itself |
| Prompt authoring, tool schema declaration | Partial | Yes — this remains squarely a framework/developer-facing concern |
| Multi-agent composition patterns | Partial | Yes — frameworks like Agent Framework and Deep Agents provide these abstractions |

The rightmost column is smaller than it would have looked eighteen months ago, and that shrinkage is the empirical substance behind this article's thesis. It does not mean frameworks are becoming unimportant — every source here still treats framework-level abstractions (middleware composition, tool schemas, streaming APIs) as necessary developer surface. It means the durable, hard-to-replicate engineering — the part that takes a team months to harden, in Stripe's own framing — has moved to a layer beneath the framework's public API.

## What to Do Now

Teams building or operating production agents should treat the harness/framework split as an actual design decision rather than an implementation detail, and make it early enough that retrofitting is cheap rather than expensive.

Draw the state and isolation boundary explicitly before writing agent logic. Decide, in writing, what owns session persistence, what owns tool execution and sandboxing, and what owns permission evaluation — and make that a single component per concern, not one per client or feature team. Kiro's experience with three divergent permission syntaxes is the cautionary case; the fix required a rewrite, not a patch.

Treat retries, compaction, and context management as harness-level infrastructure, not per-feature code. If your agent runs across more than one client or surface, centralize this logic even if it means an initial rewrite, because the cost of maintaining divergent implementations compounds with every new capability, per Kiro's account.

Build tracing and cost accounting into the execution path itself, not as a downstream analytics job. The CNCF account is specific that trace delivery must be non-blocking and that cost anomalies are usually the first visible symptom of a bug — loop detection and per-session cost alerting should exist before you need them, not after an unexpected invoice.

If you train or fine-tune against agent traces, verify that your training environment reproduces the deployment harness's tool-call format and state handling. Orchard's Codex-harness result is a single data point, not a general rule, but the direction of the effect is a reasonable prior to test against your own harness before assuming a simplified training loop will transfer.

Do not conflate harness maturity with model capability. None of the four sources claim their harness improves the underlying model's reasoning; they claim it improves reliability, consistency, and operability of whatever model sits behind it. Evaluate harness changes and model changes separately.

## Evidence and Limits

All five sources are primary: two are vendor product documentation (Microsoft Agent Framework, CNCF blog reflecting one team's operational account), one is a company engineering blog describing its own architecture (Kiro), one is a vendor blog describing a customer's implementation (LangChain on Stripe), and one is a primary research release with benchmark results (Microsoft Research's Orchard). None is independent third-party analysis, and none of the four "harness" accounts cite or reference each other — the convergence described in this article is an observation about parallel, independently reported architecture decisions, not a claim that these teams coordinated or that one caused another.

Quantitative claims in this article are scoped to their original context and should not be generalized. Stripe's 83% weekly usage and 60,000-plus session figures are current reported values for one company's internal deployment; the roughly four-week period applies to the separate 16x growth from 296 to more than 5,000 users after open preview. These figures, reported by LangChain, are not evidence about typical enterprise agent adoption rates. Orchard's 18.6%-to-51.5% improvement is a single benchmark (Claw-Eval) under a single harness (Codex) for a single training recipe (Orchard-Claw); it demonstrates a mechanism, not a generalizable multiplier. The CNCF post's operational claims come from an unnamed team's first-person account of "months" of production experience and should be read as practitioner testimony rather than a controlled study.

No source in this evidence pack provides a controlled comparison between harness-based and framework-only architectures on identical workloads, so the article's thesis — that harnesses are becoming the durable runtime — rests on convergent, independently reported design decisions rather than a benchmark showing harness architectures outperform alternatives. Readers should treat the case as strong directional evidence from practitioners solving real production problems, not as a settled, quantified result.

## References

1. Microsoft Research. "Orchard: An open framework for scalable agentic AI." https://www.microsoft.com/en-us/research/blog/orchard-an-open-framework-for-scalable-agentic-ai/
2. Microsoft Agent Framework. "Build Production-Ready Agents with the GitHub Copilot Harness and Agent Framework." https://devblogs.microsoft.com/agent-framework/build-production-ready-agents-with-the-github-copilot-harness-and-agent-framework/
3. Kiro. "One agent, every surface: how we built the Kiro agent harness." https://kiro.dev/blog/one-agent/
4. LangChain. "How Stripe Built Kai on Deep Agents in 1 Week." https://www.langchain.com/blog/how-stripe-built-their-knowledge-ai-platform-on-deep-agents
5. CNCF. "You can't debug what you can't see — Observability for AI Agents." https://www.cncf.io/blog/2026/08/04/you-cant-debug-what-you-cant-see-observability-for-ai-agents/
