---
layout: article-sky
article_variant: research-review
lang: en
title: "Claude Opus 5.5 Pricing: What Each Effort Level Costs per Task"
seo_title: "Claude Opus 5.5 Pricing: Cost per Task by Effort Level"
description: "Claude Opus 5.5 pricing is $4/$20 per million tokens, but effort sets the bill: cost per task by level, medium vs high, and Sonnet, GPT-6.2 Sol, Neon."
keywords: "claude opus 5.5 pricing, claude opus 5.5 token cost, opus 5.5 medium vs high, opus 5.5 vs sonnet 5.5"
tags: [anthropic, claude, pricing, benchmarks, ai-agents]
categories: [frontier-research]
permalink: /tutorials/claude-opus-5-5-pricing/
thumbnail: "/images/claude-opus-5-5-pricing/cover.jpg"
og_image: "/images/claude-opus-5-5-pricing/cover.jpg"
date: 2026-11-27
last_modified_at: 2026-11-27
author_name: "AgentsPulse Editorial Team"
cover_alt: "Screenshot of Andrej Karpathy's USA Civilization-style map built with Claude Opus 5.5: a hex-grid map of the United States with terrain colors and city banners such as Seattle, San Francisco, Denver, Chicago, New York, Houston and Miami, plus headline stats for population and GDP"
cover_width: 1200
cover_height: 544
zoomable_images: true
review_eyebrow: "Cost review"
research_scope: "Anthropic's Claude Opus 5.5 launch post, Claude pricing and effort documentation and Claude Code model configuration docs · Artificial Analysis model and comparison pages for Opus 5.5, Sonnet 5.5, GPT-6.2 Sol and Gemini 4 Neon · TokenSave's effort-level test · Andrej Karpathy's November 26 post, all read November 27, 2026"
scope_note: "Per-token prices are list prices from Anthropic, OpenAI and Google. Cost per task comes from Artificial Analysis's Intelligence Index runs and from one small independent Claude Code test; Anthropic's effort charts and customer quotes are the company's own measurements. We did not run our own benchmark. Cover: screenshot of karpathy.ai/usaciv; charts: Anthropic."
dek: "Claude Opus 5.5 lists at $4 per million input tokens and $20 per million output tokens, but its bill is set mostly by the effort level, because thinking is always on. On Artificial Analysis's index a task costs $0.98 at low and $10.04 at max. Here is what each level buys, when medium is enough, and where Sonnet 5.5, GPT-6.2 Sol or Gemini 4 Neon do the same work for less."
key_takeaways:
  - "List price: $4 input, $20 output, $0.20 cache reads per million tokens, 20% below Opus 5, with the full 1M context at the same rate. Batch halves it; fast mode doubles it."
  - "Effort sets the bill. On Artificial Analysis's index, Opus 5.5 costs $0.98 per task at low, $2.45 at the default medium, $3.46 at high, $6.05 at xhigh and $10.04 at max."
  - "Medium vs high: high costs about 40% more per task and scores 4 points higher (52 vs 48). Claude Code's docs put medium on clear-scope work and high on bug fixes and edge cases."
  - "Opus 5.5 at high beats Sonnet 5.5 at xhigh on the index for less money ($3.46 vs $4.09), so stepping down a model is not always cheaper than stepping down a level."
  - "Against GPT-6.2 Sol and Gemini 4 Neon, Opus 5.5 is the most expensive per index point: Sol at medium matches Opus at high for $0.41 instead of $3.46."
article_toc:
  - id: "opus-5-5-pricing"
    label: "Price per Token"
  - id: "opus-5-5-cost-per-task"
    label: "Cost per Task by Effort"
  - id: "opus-5-5-medium-vs-high"
    label: "Medium vs High"
  - id: "opus-5-5-vs-sonnet-5-5"
    label: "vs Sonnet 5.5"
  - id: "opus-5-5-vs-gpt-6-2-sol-gemini-4-neon"
    label: "vs GPT-6.2 Sol and Neon"
  - id: "lower-opus-5-5-cost"
    label: "Lowering the Bill"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/claude-fable-5-2/"
    title: "Claude Fable 5.2"
    description: "The model above Opus 5.5 at twice the token price."
  - url: "/tutorials/gemini-4-neon-benchmarks/"
    title: "Gemini 4 Neon benchmarks"
    description: "Google's middle model, scored and costed by Artificial Analysis."
  - url: "/tutorials/gpt-6-2-benchmarks/"
    title: "GPT-6.2 benchmarks"
    description: "Astra and Sol in official and independent tests."
---

Claude Opus 5.5 pricing starts at $4 per million input tokens and $20 per million output tokens, but the cost of a task is set more by the effort level you choose than by that rate. On November 26, Andrej Karpathy [posted](https://x.com/karpathy/status/2125779541952246039) a Civilization-style map of the United States that Claude Opus 5.5 built from 31 public data sources in about seven hours and 45,000 lines of code. He ran it in the Claude Code desktop app at medium effort, the default, with ultracode on, and said afterward that he had half of his weekly Claude quota left. The same model run at max effort on Artificial Analysis's benchmark costs about four times as much per task as it does at medium.

Anthropic released Claude Opus 5.5 on September 22, 2026 at a token price 20% below Opus 5, and made thinking permanent. Effort is now the main control over how many tokens Opus 5.5 spends, and those tokens are what you pay for. This guide covers the list prices, the measured cost per task at each effort level, medium vs high, and how Opus 5.5 compares on cost with Sonnet 5.5, GPT-6.2 Sol and Gemini 4 Neon.

## Opus 5.5 pricing per million tokens {#opus-5-5-pricing}

Opus 5.5 pricing is $4 per million input tokens and $20 per million output tokens on the Claude API, 20% below Opus 5's $5 and $25. Cache reads cost $0.20 per million, 60% below Opus 5, and Anthropic's launch post notes that cache reads make up most of the cost of agentic and coding work.

| Opus 5.5 price per 1M tokens | Standard | Opus 5 |
|---|---|---|
| Input | $4 | $5 |
| Output (includes thinking) | $20 | $25 |
| Cache write, 5 minutes | $5 | $6.25 |
| Cache write, 1 hour | $8 | $10 |
| Cache read | $0.20 | $0.50 |
| Batch API input / output | $2 / $10 | $2.50 / $12.50 |
| Fast mode input / output | $8 / $40 | $10 / $50 (research preview) |

*Source: [Claude pricing documentation](https://platform.claude.com/docs/en/about-claude/pricing) and Anthropic's launch post, read November 27, 2026.*

Three details in the price sheet change the bill. The full 1M-token context is billed at the same per-token rate, so a 900,000-token prompt costs the same per token as a short one. Fast mode, which Anthropic says runs up to 2.5 times faster, doubles both rates and cannot be combined with the Batch API. US-only inference adds 10% to every line.

Older Claude bills are also a poor guide. Anthropic's pricing page says Claude 4.7 and later models use a tokenizer that produces about 30% more tokens for the same text than Sonnet 4.6 and earlier, so the same prompt counts as more tokens on Opus 5.5 than it did on a 4.6-era model.

On a subscription the price shows up as usage limits rather than dollars. With the launch Anthropic raised five-hour limits on Pro, Max, Team and seat-based Enterprise plans; after Karpathy's seven-hour build he had about half of his weekly allowance left, by his own account.

## Opus 5.5 cost per task by effort level {#opus-5-5-cost-per-task}

Opus 5.5 cost per task ranges from about $1 to $10 on Artificial Analysis's Intelligence Index, depending only on the effort setting. The index runs nine agentic and reasoning evaluations, and Artificial Analysis reports the weighted average cost and time of one task at each level:

| Opus 5.5 effort | Intelligence Index | Cost per task | Time per task |
|---|---|---|---|
| low | 35 | $0.98 | 2.9 min |
| medium (default) | 48 | $2.45 | 6.8 min |
| high | 52 | $3.46 | 9.1 min |
| xhigh | 58 | $6.05 | 15.5 min |
| max | 59 | $10.04 | 24.8 min |

*Source: [Artificial Analysis](https://artificialanalysis.ai/models/claude-opus-5-5) model and comparison pages, Intelligence Index v5.0.2, read November 27, 2026.*

The spread comes from how Opus 5.5 handles thinking. Adaptive thinking is always on and cannot be disabled; Anthropic's [effort documentation](https://platform.claude.com/docs/en/build-with-claude/effort) says a request that sets thinking to disabled returns an error. The effort parameter then governs every output token: thinking, the reply text and tool calls, and lower effort makes fewer and terser tool calls. Thinking is billed as output at $20 per million, so at max Opus 5.5 produced 218 million output tokens across the whole index, against a median of 65.4 million for the models Artificial Analysis compares it with.

The jump from xhigh to max is the expensive one: one more index point for 66% more money and 60% more time. On Anthropic's own Terminal-Bench 4.0 chart, max scores slightly below xhigh, and Anthropic reports xhigh as the model's best result there.

<img src="/images/claude-opus-5-5-pricing/terminal-bench-cost-by-effort.webp" alt="Anthropic line chart titled Terminal-Bench 4.0, Accuracy vs Cost, plotting score in percent against cost per attempt in US dollars on a log scale for five models at each effort level. Opus 5.5 rises from about 38% at low near $1.40 to about 57% at medium near $3, about 64% at high near $4, a peak near 66% at xhigh around $7, and about 65% at max near $11. GPT-6 Astra sits between about 50% and 58% at $5 to $10, Fable 5.1 and Opus 5 climb from about 28% to 56% at $4 to $19, and GPT-5.6 Sol runs from about 8% to 37%" width="868" height="591" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*Terminal-Bench 4.0 score against cost per attempt at each effort level, as measured by Anthropic. The rival points are GPT-6 Astra and GPT-5.6 Sol, the OpenAI models available at launch. Source: [Anthropic](https://www.anthropic.com/news/claude-opus-5-5).*

A small independent test shows the same shape on a single coding job. TokenSave ran one prompt, a two-level brick-breaker browser game, through Claude Code at each level and converted token use to API prices with ccusage. In its October 23 rerun, three runs per level on Claude Code 2.1.295, the average cost was $0.17 at low, $0.26 at medium, $0.35 at high, $0.82 at xhigh and $5.33 at max, and every game in the rerun worked. On that task max cost about 20 times as much as medium. In TokenSave's earlier single runs, max took 22 minutes and 160,033 output tokens against 52 seconds and 6,299 for medium, and added sound effects, screen shake and named levels that the prompt did not request.

## Opus 5.5 medium vs high {#opus-5-5-medium-vs-high}

Opus 5.5 at medium costs about 30% less per task than at high and scores 4 points lower on Artificial Analysis's index (48 vs 52, $2.45 vs $3.46). Medium is the default in the API and in Claude Code, and setting medium explicitly behaves the same as sending no effort value.

Anthropic made medium the default because, in its testing, Opus 5.5 at medium matches or exceeds Opus 5 at high on coding and knowledge-work evaluations. The [Claude Code model configuration docs](https://code.claude.com/docs/en/model-config) split the two levels by the kind of work:

- **Medium:** day-to-day engineering work with a clear scope, such as implementing a new feature.
- **High:** work where verification matters or edge cases are likely, such as fixing a bug in an existing codebase.
- **xhigh and max:** long-running agentic jobs and hard problems left to run unattended; the docs add that max "may show diminishing returns and is prone to overthinking".

The same docs describe what the extra tokens buy: at higher levels Claude tested more edge cases and verified more of its work before answering, and at lower levels it returned a starting point sooner. TokenSave saw the same pattern in its game test, where high and xhigh tried to syntax-check their own code and low and medium did not.

<img src="/images/claude-opus-5-5-pricing/gdpval-cost-by-effort.webp" alt="Anthropic line chart titled GDPval-AA v2.1, Elo vs Cost, plotting Elo against estimated cost per task in US dollars on a log scale. Opus 5.5 rises from about 1230 at low near $0.22 to about 1575 at medium near $0.85, about 1690 at high near $1.55, about 1820 at xhigh near $4 and about 1846 at max near $9. GPT-5.6 Sol runs from about 1290 to 1590, Opus 5 and Fable 5.1 from about 1295 to 1735 at higher cost, and GPT-6 Astra from about 1365 to 1540" width="868" height="591" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*Elo on GDPval-AA v2.1, a test of professional work across 44 occupations, against estimated cost per task at each effort level, as published by Anthropic. Source: [Anthropic](https://www.anthropic.com/news/claude-opus-5-5).*

On knowledge work the curve flattens later than on coding. Anthropic's chart shows each step up to xhigh still adding about 100 Elo or more, and the company says Opus 5.5 at medium beats GPT-6 Astra at max for about a fifth of the cost per task. Customer quotes in the launch post point the other way for routine work: Deloitte says Opus 5.5 at its lowest setting caught 72% of known bugs in its code reviews, against 56% for Opus 5 at high, and another tester said medium matched Opus 5 on high with 20% to 25% fewer output tokens.

Karpathy's map is a useful reference point for medium. He ran a seven-hour, 45,000-line build at medium and paired it with ultracode, a Claude Code setting that has Claude plan a dynamic workflow of subagents for each substantive task while keeping the session's effort level. Claude Code's [workflow documentation](https://code.claude.com/docs/en/workflows) warns that each request then uses more tokens and takes longer than it would without a workflow, and that on a subscription the session reaches its usage limits sooner. Karpathy kept the per-turn thinking at medium and let the workflow handle the scale. We covered a smaller version of the same setup in [how Karpathy built HackerTube](/tutorials/how-karpathy-built-hackertube/), which also ran Opus 5.5 at medium.

## Opus 5.5 vs Sonnet 5.5 cost {#opus-5-5-vs-sonnet-5-5}

Sonnet 5.5 costs half as much per token as Opus 5.5, $2 and $10 per million, but it is not cheaper per task at every quality level. On Artificial Analysis's index, Opus 5.5 at high scores 52 for $3.46 a task, while Sonnet 5.5 at xhigh scores 50 for $4.09.

| Model and effort | Intelligence Index | Cost per task | Time per task |
|---|---|---|---|
| Sonnet 5.5 medium | 31 | $0.78 | 3.7 min |
| Sonnet 5.5 high | 41 | $1.64 | 6.9 min |
| Opus 5.5 medium | 48 | $2.45 | 6.8 min |
| Sonnet 5.5 xhigh | 50 | $4.09 | 13.8 min |
| Opus 5.5 high | 52 | $3.46 | 9.1 min |
| Sonnet 5.5 max | 55 | $10.02 | 31.1 min |
| Opus 5.5 xhigh | 58 | $6.05 | 15.5 min |

*Source: [Artificial Analysis](https://artificialanalysis.ai/models/comparisons/claude-sonnet-5-5-vs-claude-opus-5-5), read November 27, 2026.*

Above Sonnet's high setting, raising Sonnet's effort costs more than switching to Opus at a lower level. Sonnet 5.5 at max costs as much as Opus 5.5 at max, about $10 a task, and scores 3 points below Opus at xhigh, which costs $6.05. Sonnet stays cheaper for light work: at medium it costs a third of Opus at medium, and in TokenSave's brick-breaker rerun Sonnet 5.5 averaged $0.10 at medium against $0.26 for Opus.

Sonnet 5.5 also starts at a different default. Anthropic's API defaults Sonnet 5.5 to high and Opus 5.5 to medium, and the effort scale is calibrated per model, so the same level name does not mean the same amount of thinking on both.

## Opus 5.5 vs GPT-6.2 Sol and Gemini 4 Neon {#opus-5-5-vs-gpt-6-2-sol-gemini-4-neon}

Against the newest models from OpenAI and Google, Opus 5.5 is the most expensive per index point on Artificial Analysis's measurements. GPT-6.2 Sol at medium scores 52 for $0.41 a task, the same score Opus 5.5 reaches at high for $3.46, and Gemini 4 Neon at high scores 60 for $3.74, above Opus 5.5 at xhigh for less money.

| Model and effort | Price per 1M tokens (in / out) | Intelligence Index | Cost per task | Time per task |
|---|---|---|---|---|
| GPT-6.2 Sol medium | $2 / $10 | 52 | $0.41 | 4.0 min |
| Opus 5.5 high | $4 / $20 | 52 | $3.46 | 9.1 min |
| GPT-6.2 Sol max | $2 / $10 | 57 | $1.01 | 11.5 min |
| Opus 5.5 xhigh | $4 / $20 | 58 | $6.05 | 15.5 min |
| Gemini 4 Neon high | $3 / $15 | 60 | $3.74 | 14.9 min |
| Gemini 4 Neon xhigh | $3 / $15 | 62 | $6.44 | 27.1 min |

*Index, cost and time from Artificial Analysis's [Opus 5.5 vs GPT-6.2 Sol](https://artificialanalysis.ai/models/comparisons/claude-opus-5-5-vs-gpt-6-2-sol) and [Opus 5.5 vs Gemini 4 Neon](https://artificialanalysis.ai/models/comparisons/claude-opus-5-5-vs-gemini-4-neon) pages, read November 27, 2026; token prices from OpenAI, Google and Anthropic list prices.*

Per-token price explains only part of the gap. Sol's tokens cost half of Opus's, yet at matched scores its tasks cost about an eighth as much, so most of the difference is how many tokens each model spends. Anthropic's launch charts tell a different story because they compare Opus 5.5 with GPT-6 Astra and GPT-5.6 Sol, the OpenAI models on sale in September; GPT-6.2 and Gemini 4 Neon arrived later. Our [GPT-6.2 benchmarks](/tutorials/gpt-6-2-benchmarks/) and [Gemini 4 Neon benchmarks](/tutorials/gemini-4-neon-benchmarks/) cover those models' own results.

The index is one mix of tasks, and developers still pay the premium for some work. Even Google's launch table for Neon shows Opus 5.5 ahead on Terminal-Bench 4.1 and FrontierCode 2.0, two agentic coding tests, and on November 26 Yuchen Jin, who builds AI systems at Databricks, [wrote](https://x.com/yuchenj_uw/status/2125818170611298346) that Gemini Neon is "winning developers' hearts" while "Opus 5.5 remaining the king". If your work looks like long agentic coding sessions, measure on your own tasks; if it looks like the index's reasoning and knowledge tasks, Sol and Neon deliver the same score for less.

## How to lower Opus 5.5 cost {#lower-opus-5-5-cost}

The cheapest change is to set effort per task instead of per account. Anthropic's docs recommend running an effort sweep on your own evaluations rather than carrying over the level you used on Opus 5, because at a given level Opus 5.5 thinks more per turn than Opus 5 did.

- **Keep medium as the base and raise it per route.** Send high for bug fixes and edge-case-heavy changes, and reserve xhigh for runs that last more than 30 minutes, which is how Anthropic describes that level. Use low for simple tasks such as subagents.
- **Change effort per message, not per request, in cached sessions.** Changing the top-level effort between requests can invalidate the prompt cache; Opus 5.5 accepts a per-message effort change that keeps it. With cache reads at $0.20 against $4 for fresh input, a lost cache can cost more than the effort saving.
- **Set a large max_tokens at xhigh and max.** It is a hard limit on thinking plus reply, so a small cap can cut a long answer off mid-task.
- **Use the Batch API for jobs that can wait.** It halves both rates to $2 and $10 per million. Fast mode does the opposite, doubling the price for speed.
- **Treat ultracode as a budget decision.** In Claude Code it can turn one request into several workflows; the /workflows view shows each agent's token usage, and Claude Code's docs suggest running a workflow on a small slice first to gauge the spend.
- **Route easy work to a cheaper model.** Per the index numbers above, Sonnet 5.5 at medium or GPT-6.2 Sol cover routine tasks for a fraction of the cost, and a [model gateway](/tutorials/model-gateway-enterprise-ai-control-plane/) can do that routing without code changes.

For agent teams that already track spend, [cost per successful task](/tutorials/coding-agents-finops-cost-per-successful-task/) is a better yardstick than price per token, and the gap between Opus 5.5's effort levels is a good place to start measuring it. If you need more capability than Opus 5.5 at max, [Claude Fable 5.2](/tutorials/claude-fable-5-2/) costs twice as much per token.

## References {#references}

1. Anthropic, [Introducing Claude Opus 5.5](https://www.anthropic.com/news/claude-opus-5-5), September 22, 2026.
2. Anthropic, [Pricing](https://platform.claude.com/docs/en/about-claude/pricing) and [Effort](https://platform.claude.com/docs/en/build-with-claude/effort), Claude Platform documentation, read November 27, 2026.
3. Anthropic, [Model configuration](https://code.claude.com/docs/en/model-config) and [Dynamic workflows](https://code.claude.com/docs/en/workflows), Claude Code documentation, read November 27, 2026.
4. Artificial Analysis, [Claude Opus 5.5: Intelligence, Performance & Price Analysis](https://artificialanalysis.ai/models/claude-opus-5-5) and model comparison pages, read November 27, 2026.
5. Jonhisking, TokenSave, [Claude Opus 5.5 Effort Levels Tested: Low to Max](https://tokensave.app/blog/claude-opus-5-5-effort), October 9, 2026, updated October 23, 2026.
