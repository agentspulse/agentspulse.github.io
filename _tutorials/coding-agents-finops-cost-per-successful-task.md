---
layout: article-sky
article_variant: research-review
lang: en
title: "Coding Agents Enter the FinOps Era: Cost per Successful Task"
seo_title: "Coding Agent FinOps: Cost per Successful Task"
description: "Why coding-agent economics depend on cost per successful task, model routing, deterministic verification, two-tier budgets, and unified traces."
keywords: "coding agent cost, AI FinOps, cost per successful task, model routing, agent budgets, coding agents"
tags: [coding-agents, FinOps, evaluations, model-routing]
categories: [frontier-research]
permalink: /tutorials/coding-agents-finops-cost-per-successful-task/
thumbnail: "/images/coding-agents-finops-cost-per-successful-task/figure-1.jpg"
og_image: "/images/coding-agents-finops-cost-per-successful-task/figure-1.jpg"
date: 2026-07-29
last_modified_at: 2026-07-29
author_name: "AgentsPulse Editorial Team"
cover_alt: "Cost per successful task formula"
cover_width: 1022
cover_height: 550
paper_count: 5
research_scope: "Coding agents · FinOps · Evaluation"
dek: "Token price is not the bill: retries, failures, verification, routing, and runaway workflows determine the real cost of production coding agents."
key_takeaways:
  - "Cost per successful task captures retries and failures that token prices hide."
  - "Routing by task difficulty can improve both coverage and cost, but only when success can be verified."
  - "Production deployments need unified traffic controls, daily and monthly budgets, deterministic checks, and full traces."
article_toc:
  - id: "the-real-cost-of-building-with-agents"
    label: "The Real Cost of Building with Agents"
  - id: "tldr"
    label: "TL;DR"
  - id: "the-hidden-cost-of-success-rates-below-100"
    label: "The Hidden Cost of Success Rates Below 100%"
  - id: "where-the-frontier-premium-buys-nothing"
    label: "Where the Frontier Premium Buys Nothing"
  - id: "coverage-versus-cost-are-different-questions"
    label: "Coverage Versus Cost Are Different Questions"
  - id: "two-budgets-for-two-failure-modes"
    label: "Two Budgets for Two Failure Modes"
  - id: "the-165000-port-and-the-graph-that-ran-it"
    label: "The $165,000 Port and the Graph That Ran It"
  - id: "when-to-escalate-without-a-verifier"
    label: "When to Escalate Without a Verifier"
  - id: "knowledge-work-as-the-next-frontier"
    label: "Knowledge Work as the Next Frontier"
  - id: "what-to-do-now"
    label: "What to Do Now"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/stateless-mcp-agent-gateway/"
    title: "Stateless MCP and the Rise of the Agent Gateway"
    description: "How gateways centralize policy, authorization, routing, and observability for agent tools."
  - url: "/tutorials/measuring-reward-seeking-contrastive-beliefs/"
    title: "Measuring Reward-Seeking in RL-Trained Models"
    description: "A causal test of whether trained models follow user intent or inferred grader preferences."
---
## The Real Cost of Building with Agents

Large-scale coding agents crossed a visibility threshold in 2026. Bun spent [\$165,000 in API tokens](https://alphasignal.ai/news/buns-agent-graph-billed-165-000-over-11-days) porting a million-line runtime to a memory-safe language in eleven days, routing work through roughly 50 dynamic workflows peaking at 64 concurrent Claude instances. Databricks [published](https://www.databricks.com/blog/how-databricks-manages-its-own-coding-agent-spend-unity-ai-gateway-budgets) a detailed account of how it governs coding-agent spend internally across thousands of engineers, describing a two-budget system that catches runaway loops within hours while letting monthly spend scale with project priorities. Arize and Fireworks [measured](https://arize.com/blog/cost-per-successful-task-ai-model-benchmark/) cost per successful task across 2,400 runs of ten models on real command-line jobs, showing the metric diverges from token price by more than an order of magnitude and inverts the pricing-page ranking. [OpenAI reported](https://www.latent.space/p/chatgpt-work) ten million users for ChatGPT Work and Codex combined two weeks after launch in July, with knowledge workers already accounting for roughly 20% of Codex usage and growing more than three times as quickly as developers.

These are the first public accounts of coding agents operating at production scale with dollar figures and governance details attached. The pattern they show is consistent: the bottleneck is no longer whether a model *can* perform a task. The bottleneck is whether you can afford to run that model on every task, whether you can tell when it succeeded, and whether you can stop it when it goes off the rails. A frontier model writing code costs between \$0.32 and \$0.49 per attempt at list prices as of July 2026. A model out of its depth churns through its token budget, produces nothing, and costs you the same. The difference between a useful coding agent and an expensive one is not model capability. It is economic governance: budgets, routing, explicit success criteria, and the instrumentation to know when a run is burning money without making progress.

<img src="/images/coding-agents-finops-cost-per-successful-task/figure-1.jpg" decoding="async" loading="lazy" width="1022" height="550" alt="Cost per successful task formula" />

*Cost per successful task includes every failed, retried, or timed-out attempt instead of counting only the run that passed.*

## TL;DR

- **Cost per successful task**, not token price, is the productivity metric that matters: it captures retries, failed tool calls, verification overhead, and runs that never finish.
- Arize and Fireworks measured ten models across 2,400 runs and found cost per success diverges from token price by up to 23×, with the most cost-effective model (an open 120B parameter model) finishing tasks for \$0.054 while passing only 33% of the time.
- Routing by task difficulty beats any single-model strategy on both cost and coverage: oracle routing solved 36% more tasks than the best single model at roughly a third of the cost per success, because most work gets done by models costing under three cents per attempt.
- Databricks controls coding-agent spend across thousands of engineers with a two-budget system: a small daily limit that catches runaway spend with self-service acknowledgment to unblock, and a high monthly limit that requires manager approval and reverts when the project ends.
- Bun spent \$165,000 in API tokens (none of it paid, as an Anthropic subsidiary) porting a million-line runtime in eleven days using roughly 50 dynamic workflows, peaking at 64 concurrent Claude instances across four git worktrees.
- The shared lesson across all three deployments: coding-agent economics require a control layer that sees all traffic, enforces budgets, routes by task class, measures success deterministically, and distinguishes motion from progress.

## The Hidden Cost of Success Rates Below 100%

Token pricing tells you what one attempt costs. It does not tell you how many attempts you will pay for before the task finishes, or whether it finishes at all. [Arize and Fireworks](https://arize.com/blog/cost-per-successful-task-ai-model-benchmark/) tested ten models from four providers (OpenAI, Anthropic, Google, and Fireworks) on 40 real command-line tasks from Terminal-Bench, six trials per task-model cell, 2,400 runs total, \$626 of API spend. Every run was graded by the task's own deterministic test suite and fully traced to Arize AX with token counts, latency, and error states.

<img src="/images/coding-agents-finops-cost-per-successful-task/figure-2.jpg" decoding="async" loading="lazy" width="1200" height="924" alt="Arize and Fireworks benchmark setup" />

*The benchmark used 40 Terminal-Bench tasks, 10 models, and six trials per task-model pair, for 2,400 traced runs.*

The most cost-effective model per successful task was `gpt-oss-120b`, an open 120B-parameter model served by Fireworks, finishing work for \$0.054 on average. Its pass rate was 33%, the worst in the study. The "retry tax"—attempts needed per success—was 3.0×, meaning every success cost three attempts. Even paying that tax, the model was roughly 12× more cost-effective per success than GPT-5.5 (\$0.636) and 23× more cost-effective than `gemini-3.5-flash` (\$1.233). The second most cost-effective model was `gemini-3.1-flash-lite` (\$0.063), a closed model from Google with a 40% pass rate and a 2.5× retry tax.

At the other end, `gemini-3.5-flash` carried the worst cost per success in the study (\$1.233) and the worst retry tax (4.3×). Ninety-one percent of its failures (168 of 184) were token-budget exhaustion: the model churned against the limit without converging, burning its entire budget and producing nothing. Token price hides that failure mode completely.

| Model | Provider | Pass rate | Mean $/attempt | $/successful task | Retry tax |
| :--- | :--- | ---: | ---: | ---: | ---: |
| `gpt-oss-120b` | Fireworks (open) | 33% | $0.018 | $0.054 | 3.0× |
| `gemini-3.1-flash-lite` | Google (closed) | 40% | $0.026 | $0.063 | 2.5× |
| Kimi K2.6 | Fireworks (open) | 42% | $0.163 | $0.384 | 2.4× |
| GLM-5.2 | Fireworks (open) | 42% | $0.208 | $0.500 | 2.4× |
| DeepSeek V4 Pro | Fireworks (open) | 39% | $0.230 | $0.588 | 2.6× |
| GPT-5.5 | OpenAI (frontier) | 67% | $0.424 | $0.636 | 1.5× |
| Kimi K3 | Fireworks (open) | 66% | $0.441 | $0.670 | 1.5× |
| GPT-5 | OpenAI | 41% | $0.317 | $0.769 | 2.4× |
| Claude Sonnet 5 | Anthropic | 49% | $0.494 | $1.014 | 2.1× |
| `gemini-3.5-flash` | Google (closed) | 23% | $0.288 | $1.233 | 4.3× |

The study did not test GPT-5.6 Sol, which launched after the runs completed.

## Where the Frontier Premium Buys Nothing

Aggregates hide the most actionable result. When the same runs are split by task difficulty, the frontier premium disappears on easy work and becomes decisive on hard work.

| Model                   | Easy tasks | Medium tasks | Hard tasks |
|-------------------------|------------|--------------|------------|
| `gpt-oss-120b`          | 65%        | 32%          | 14%        |
| `gemini-3.1-flash-lite` | 69%        | 48%          | 8%         |
| Kimi K2.6               | 73%        | 43%          | 21%        |
| **GPT-5.5**             | **69%**    | **75%**      | **51%**    |
| **Kimi K3**             | **100%**   | **72%**      | **32%**    |

On easy tasks, GPT-5.5 passed 69% of the time. Kimi K2.6 passed 73% at roughly one twenty-fourth the cost per attempt. `gpt-oss-120b` passed 65% at one thirty-fifth the cost. Paying frontier prices for easy work does not make financial sense.

On hard tasks, only the frontier tier competed. The most cost-effective models fell far behind; solving the hardest problems took a frontier-class model, open or closed. Retrying is no substitute: a model that cannot do a task does not learn it on the fourth attempt, it just bills you four times.

But "frontier-class" is not one thing. GPT-5.5 (closed) and Kimi K3 (open) finished the study in a near-tie, 67% and 66% overall success at \$0.636 and \$0.670 per successful task, yet they are good at opposite work. Kimi K3 solved every easy task in the study, all six trials of all of them, where GPT-5.5 slipped to 69%. On the hardest tasks they swap: GPT-5.5 51%, Kimi K3 32%. Same tier, same price, same overall success, opposite strengths. One open, one closed.

## Coverage Versus Cost Are Different Questions

Cost per success and coverage are distinct. Counting tasks a model solves reliably (four of six trials or better):

- `gpt-oss-120b`: 8 of 40
- GPT-5.5: 25 of 40
- Kimi K3: 26 of 40

`gpt-oss-120b` is more cost-effective per success partly *because* it only wins the tasks it can win. If you swap your frontier model for it wholesale, your bill collapses and so does the set of things your product can do.

The right response is routing: send easy tasks to the cost-effective model, harder tasks to the frontier. Arize and Fireworks simulated that over the real runs.

| Policy | Reliably solves | \$/successful task |
|----|----|----|
| `gpt-oss-120b` alone | 8/40 | \$0.054 |
| GPT-5.5 alone (best single model) | 25/40 | \$0.636 |
| **Oracle routing** (most cost-effective model that reliably solves each task) | **34/40** | **\$0.228** |
| **Escalation** (`gpt-oss` → `flash-lite` → Kimi K2.6 → GPT-5.5, stop on first pass) | 32.3/40 | **\$0.525** |
| Naive escalation through all 10 models | 34.5/40 | \$1.319 |

Oracle routing solves 36% more tasks than GPT-5.5 alone at roughly a third of the cost per success. It needs hindsight to pick the right model per task, so treat it as the ceiling on what good routing buys.

Escalation is the deployable version: try the most cost-effective model, escalate on failure, stop on the first pass. It costs \$0.525 per success while solving more tasks than the frontier model alone, because most work gets done by a model costing under three cents an attempt and only the genuinely hard tasks ever reach the expensive rung. A bad escalation ladder is worse than no routing at all: naively escalating through all ten models costs \$1.319 per success, worse than every single model in the study, because you pay the entire ladder on the roughly six tasks nobody solves and you pay poor-value rungs on the way past.

## Two Budgets for Two Failure Modes

[Databricks](https://www.databricks.com/blog/how-databricks-manages-its-own-coding-agent-spend-unity-ai-gateway-budgets) governs coding-agent spend across thousands of engineers by routing every agent through Unity AI Gateway, enforcing budgets, visibility, and policies across every model and tool in one place. The system they describe balances innovation with cost control using two budgets that address two distinct failure modes.

Short-term waste is rapid expenditure that might be accidental: an automation loop unintentionally spawning a hundred agent sessions. Long-term waste is expenditure over days or weeks that suggests an excessively expensive technique, like running parallel frontier-model subagents for work that does not need them. No single limit can catch both.

Databricks implemented a daily limit to catch runaway spend and a monthly limit to govern extraordinary spend. The daily limit is deliberately small relative to monthly spend. When an engineer hits it, they get a Slack notification and a single button to acknowledge that the spend was intentional. Clicking it raises the daily limit by one increment immediately. No approval, no ticket, no waiting. If the spend was an accident, the notification is exactly the alarm they needed. The daily budget resets each evening at the lowest-usage hour and clears fully at the start of each month.

The monthly limit is set high enough that the typical engineer never encounters it. Crossing it means someone is asking to spend meaningfully more than their peers, which is fine, but should trace back to a specific business priority. These increases go through manager approval, come in a few coarse tiers rather than endless small bumps, and critically, are time-limited to the duration of the project. When the project ends, the limit reverts.

The two limits stay coupled through a fixed ratio. An engineer spending smoothly across the month will never trip the daily limit at all, because the monthly budget divided across working days sits comfortably under the daily threshold. If a manager raises someone's monthly limit for a big project, their daily limit and increment scale up proportionally, so the runaway protection stays meaningful without becoming a nuisance.

Under the old system, every limit increase was permanent. An engineer who made one expensive mistake, or worked on a high-spend project, kept a large limit indefinitely, quietly growing the share of the company susceptible to expensive mistakes. Under the new model, somewhere between 500 and 1,000 engineers were hitting the limit every month under the old system. That is hundreds of tickets, hundreds of interrupted work sessions, and a very grumpy Slack channel. Under the new model, Databricks expects only a small handful of the heaviest users to ever hit the daily limit in a given month, and each of those cases resolves with a single acknowledgment click.

The reason this works with almost no custom infrastructure is that Unity AI Gateway already sees everything. Every request from every coding agent, whether it is hitting Claude, GPT, Gemini, or open-source models, is attributed to a user identity and metered in one place. Budgets configured for the gateway apply across all tools an engineer uses. The daily and monthly tiers are implemented by assigning budget per-user threshold overrides to different groups. Tier promotion is achieved by making a user a member of the higher tier's group, through daily automation, self-acknowledgements, and manager approvals. Because the gateway lands all usage data in Unity Catalog, managers see team-level spend in the same tables where Databricks built its internal coding-agent benchmark, and finance sees one bill instead of five.

## The \$165,000 Port and the Graph That Ran It

In May 2026, [Bun](https://alphasignal.ai/news/buns-agent-graph-billed-165-000-over-11-days) ported a million-line JavaScript runtime from Zig to Rust in eleven days using roughly 50 Claude Code dynamic workflows, peaking at 64 concurrent Claude instances. The bill came to around \$165,000 at API list prices. None of it was paid: Bun was acquired by Anthropic in December 2025, so the tokens were drawn at internal cost.

The port had a reason. Bun mixes garbage-collected values from JavaScriptCore with memory it manages by hand, and Zig asks for every cleanup to be written out at each call site. That combination was Bun's main source of instability, down to leaks like a missing free in the TLS session path costing around 6.5 KB per call. Jarred Sumner, Bun's creator, wrote that the bugfix list felt bad and he was tired of going to sleep worrying about crashes. Safe Rust turns most of that class of bug into a compiler error.

| Metric | Value |
|----|----|
| Model | Pre-release Claude Fable 5, Mythos class |
| Duration | 11 days |
| Dynamic workflows | About 50 |
| Peak concurrency | 64 Claudes (4 worktrees × 16) |
| Uncached input tokens | 5.9 billion |
| Output tokens | 690 million |
| Cached input reads | 72 billion |
| Cost at API list price | About \$165,000 (none paid) |
| Source size | 535,496 lines of Zig excluding comments, across 1,448 files |
| Merged diff | +1,009,272 lines of Rust |
| Commits | 6,778 (6,502 excluding merges) |
| Peak throughput | About 1,300 lines per minute |
| Verification | Over 1 million test assertions, 0 tests skipped or deleted, green in CI on every supported platform |

The 64 came from stacking a limit. A single Claude Code dynamic workflow can spawn up to 1,000 agents, but only 16 run at once, and the rest queue. Fan 160 independent units out to one agent each and they drain through the 16-wide gate in 10 waves. Clock time tracks the width of a wave, so the fleet you provision and the throughput you get are different quantities. The spawn cap only tells you how many waves you are queuing. Sumner ran 4 workflow shards side by side, each in its own git worktree, each holding 16 Claudes. The widely repeated 64 is peak simultaneous instances across those shards, and the total across roughly 50 workflows over 11 days was far higher.

The port ran as a graph instead of a loop because Bun had the two properties that make parallelism worth the orchestration overhead. The 1,448 Zig files could be ported without waiting on each other, so the work split cleanly on the first pass. And Bun already carried a test suite with over a million assertions, which gave every one of those splits something to be checked against that no agent could talk its way past. A single agent could have worked through the same list. It would have taken months, and clock time was the whole point.

Two disclosures travel with the number. Bun was acquired by Anthropic in December 2025, so Sumner drew tokens at internal cost and no cash changed hands against the \$165,000. And he used a prerelease version of Claude Fable 5. Anyone pricing a similar run against the generally available lineup is pricing different machinery. Mitchell Hashimoto called it an incredible deal at that price, while noting he had not checked the figure himself. The Rust port now runs in Claude Code v2.1.181 and later, and Prisma launched Prisma Compute on it.

## When to Escalate Without a Verifier

"Escalate on failure" assumes you can tell that a run failed. The Arize and Fireworks study gets that for free, because every Terminal-Bench task ships its own test suite. Most production systems do not have one. Here is how to do it in production without an oracle.

Often you do not need to detect failure at all. The difficulty table above is already a routing policy, and it needs no runtime verification of anything. Measure once, offline, which class of work each model handles, then route by the class of the incoming request. "Simple requests to the more efficient model, complex ones to the frontier" needs a classifier, not a verifier.

More work is verifiable than people assume. Does the code compile? Do its tests pass? Does the JSON parse and validate against the schema? Does the SQL run and did the API call come back non-error? And do the cited quotes actually appear in the source document? Checking an answer is usually more cost-effective than producing one. Wherever a low-cost deterministic check exists, escalation is deployable today, and a lot of agentic work is exactly this shape.

When there is no verifier, escalate on distress rather than on failure. You do not need to know the right answer to notice a run going badly. Recall that 91% of `gemini-3.5-flash`'s failures were budget exhaustion: a model out of its depth churns, and churn is visible while it is happening. Tool calls exiting non-zero, the same command repeated three times, a run costing five times the median for its task type: all of these are live signals, none of them require ground truth, and all of them are sitting in the traces.

But the failure that actually costs you is the silent one. A test_failed run finishes confidently, every span green, every command clean, and the answer simply wrong. No distress signal fires, because from the inside nothing went wrong. For those you need a real check: a verifier, an LLM judge (whose calls are a genuine cost and belong in the same accounting), or a downstream signal like a thumbs-down, a retry, or a support ticket. There is no free lunch here, and a routing story that pretends otherwise is one you will pay for later. If you genuinely cannot tell success from failure anywhere in your system, model selection is not your biggest problem: you are shipping something you cannot evaluate.

## Knowledge Work as the Next Frontier

[OpenAI reported](https://www.latent.space/p/chatgpt-work) ten million users for ChatGPT Work and Codex combined two weeks after ChatGPT Work's July 9th launch. Codex now powers ChatGPT Work, so all ChatGPT Work users are users of the Codex harness, even if they are not traditional engineers. In June, OpenAI said knowledge workers already accounted for roughly 20% of Codex's user base and were growing more than three times as quickly as developers.

Akshay Nathan, who leads Core Product Engineering at OpenAI, described the shared agent harness behind Codex and ChatGPT Work in a Latent Space podcast interview. The two products share the same underlying infrastructure—persistent computers, artifacts, sandboxing, tool calls, and traces—but differ in UX, Git visibility, artifact defaults, and sandboxing behavior. Codex defaults to showing diffs and git commit detail; ChatGPT Work defaults to artifacts like interactive websites, spreadsheets, and documents. The reason they share a harness is that the distinction between "engineering work" and "knowledge work" is blurring: engineers need to draft documents and knowledge workers need to analyze data or script automations.

Nathan explained that OpenAI merged its agent experiences instead of building separate products because the boundary between coding and other work is artificial. Knowledge workers were already using Codex for work that did not look like traditional software development: performance reviews that gather context across Slack and documents, financial planning, budgeting, workouts, meals, and household management. The realization that led to ChatGPT Work was that roughly 100× more people use code than can write code, and as code that "just works" becomes easier to generate, this group may be the biggest opportunity.

Nathan described productivity measurement as a challenge the industry has not solved. Proxies like code commits, lines of code, or story points are falling apart when AI is involved, because the number of tokens used or the number of pull requests made are no longer hypercorrelated with whether a team is hitting its goals. The trap, he said, is conflating motion and progress. Motion is much easier now than ever before because of the tooling available. But progress requires being very prescriptive and deliberate about what you are trying to achieve. If you do not have that, it is very easy to conflate the two. Nathan's metric is "at-bats": is the team building the muscle to go all the way from generating an idea, building it out, getting the feedback, reacting to that feedback, validating or invalidating the hypothesis, and going on to the next idea efficiently?

## What to Do Now

**Measure cost per successful task, not token price.** Count all spend across every attempt, including runs that failed, retried, or timed out, divided by the number of times the agent actually completed the task. Report coverage next to cost, always. A model that reliably solves 8 of 40 tasks is not a drop-in replacement for one that solves 26, even if it costs less per success.

**Route by task difficulty instead of buying one model for every job.** Measure offline which class of work each model handles, then send easy tasks to the cost-effective model and harder tasks to the frontier. Escalation beats every single-model strategy on cost and coverage at once, but only with a deliberate ladder: start with the most cost-effective model, escalate on failure, stop on the first pass. A bad escalation ladder is worse than none.

**Implement two budgets for two failure modes.** A small daily limit catches runaway spend with self-service acknowledgment to unblock. A high monthly limit governs extraordinary spend through manager approval and reverts when the project ends. Keep the two coupled through a fixed ratio so the runaway protection stays meaningful without becoming a nuisance.

**Verify success deterministically wherever possible.** Does the code compile? Do tests pass? Does JSON parse? Does SQL run? Checking an answer is usually more cost-effective than producing one. When no verifier exists, escalate on distress (tool calls exiting non-zero, repeated commands, cost spikes) rather than on confirmed failure. If you cannot tell success from failure anywhere in your system, you are shipping something you cannot evaluate.

**Route all agent traffic through one control point.** A gateway or proxy that sees everything is what makes a single policy enforceable across every coding agent, regardless of tool or model. Without it, you have as many budget consoles as you have tools, and no unified view of where the money went.

**Instrument everything with traces.** Aggregates tell you that low-cost models are efficient. Traces tell you why, and where the invisible costs (silent failures, budget exhaustion, tool-call friction) become visible. Every run should emit a root agent span with nested LLM and tool-call spans, token counts, latency, and a clear error status when something goes wrong.

## Evidence and Limits

The Arize and Fireworks study tested ten models on 40 Terminal-Bench tasks, six trials per task-model cell, 2,400 runs total, \$626 of API spend, graded by each task's own deterministic test suite. Every task-model cell has exactly six trials; pass rates carry roughly a ±6 point 95% confidence interval. The results are directional, not a leaderboard score: 40 of Terminal-Bench's ~240 tasks, chosen to sit in the band where some models pass and some fail. The study did not test GPT-5.6 Sol, which launched after the runs completed. Claude Sonnet 5 is billed at its standard rate, not its introductory rate. Prices reflect July 2026 list rates.

The Databricks budget system is described from the perspective of a single customer deployment (Databricks's own internal use of Unity AI Gateway). Dollar figures in the Databricks post are illustrative, not actual internal numbers. The system is available to all Databricks customers through Unity AI Gateway Budgets, but the specific tier values, increment sizes, and reset schedules are configuration details that vary by deployment.

The Bun port is reported by Jarred Sumner, Bun's creator, in a public post. Every metric in the table above is verified against that post. Bun was acquired by Anthropic in December 2025, so the \$165,000 cost was incurred at internal pricing and no cash changed hands. Sumner used a prerelease version of Claude Fable 5. Anyone pricing a similar run against generally available models is pricing different machinery. Mitchell Hashimoto called it an incredible deal at that price while noting he had not checked the figure himself.

The OpenAI ten-million-user figure combines ChatGPT Work and Codex users two weeks after ChatGPT Work's July 9th launch, as reported by Tibo on X and discussed by Akshay Nathan in the Latent Space podcast. The figure for knowledge workers accounting for roughly 20% of Codex usage and growing more than 3× as quickly as developers is from OpenAI's June 2026 Codex report. The claim that roughly 100× more people use code than can write code is attributed to Akshay Nathan in the podcast interview.

AlphaSignal's report is secondary: it summarizes Jarred Sumner's original post with additional context and commentary. Every claim about Bun's port attributed to AlphaSignal in this article traces back to Sumner's original post or is marked as AlphaSignal's interpretation.

This article distinguishes observed events (Bun merged a million-line Rust port, Databricks deployed a two-budget system, Arize and Fireworks measured ten models across 2,400 runs) from interpretation and recommendations (route by task difficulty, implement two budgets, measure cost per successful task). The recommendations follow from the evidence but are not themselves measurements.

## References

1.  Databricks. "How Databricks manages its own coding agent spend with Unity AI Gateway Budgets." July 28, 2026. <https://www.databricks.com/blog/how-databricks-manages-its-own-coding-agent-spend-unity-ai-gateway-budgets>

2.  Arize. "Cost per successful task: Benchmarking Kimi K3, GPT-5.5, and 8 more AI models." July 23, 2026. <https://arize.com/blog/cost-per-successful-task-ai-model-benchmark/>

3.  AlphaSignal. "Bun's Agent Graph Billed \$165,000 over 11 days." July 28, 2026. (Secondary report summarizing Jarred Sumner's original post.) <https://alphasignal.ai/news/buns-agent-graph-billed-165-000-over-11-days>

4.  Latent Space. "Codex from 0 to 10M Users: Building ChatGPT Work — Akshay Nathan, OpenAI." July 28, 2026. <https://www.latent.space/p/chatgpt-work>
