---
layout: article-sky
article_variant: research-review
lang: en
title: "Claude Dreaming: How Dreams Rewrites Agent Memory in Managed Agents"
seo_title: "Claude Dreaming: How Anthropic's Dreams Fixes Agent Memory"
description: "Claude dreaming explained: the Managed Agents Dreams API rewrites a memory store from past sessions. How to call it, limits, cost and test results."
keywords: "claude dreaming, anthropic dreaming, claude dreams, claude managed agents, claude memory, agent memory, claude code memory, sleep-time compute"
tags: [anthropic, claude, ai-agents, agent-memory]
categories: [ai-agents]
permalink: /tutorials/claude-dreaming/
thumbnail: "/images/claude-dreaming/cover.jpg"
og_image: "/images/claude-dreaming/cover.jpg"
date: 2026-11-07
last_modified_at: 2026-11-07
author_name: "AgentsPulse Editorial Team"
cover_alt: "Two offset half circles with a grid pattern, one green and one pink, facing each other across a gap on a light blue background, the artwork for Anthropic's agent memory post"
cover_width: 1600
cover_height: 900
zoomable_images: true
review_eyebrow: "Research guide"
research_scope: "Claude Dreams · research preview, Nov 2026"
scope_note: "Anthropic's research post of Nov 6, 2026, the Claude Platform Dreams documentation, and the Claude Cookbook recipe of Nov 2, 2026, plus the Hacker News discussion of the post. All benchmark numbers are Anthropic's own runs; we did not run Dreams."
dek: "Anthropic has opened Dreams, a research-preview job in Claude Managed Agents that reads up to 100 past sessions and an existing memory store, then writes a cleaned-up new store. Its research post shows where this helps: stale notes get corrected against transcripts, and wikis built over many sessions answer cross-document questions better than search alone."
key_takeaways:
  - "Dreams is an asynchronous Managed Agents job. It takes one memory store plus 1 to 100 sessions and writes a new store; the input store is never modified."
  - "It is a research preview behind an access request, available only on the Claude API, and not eligible for ZDR or HIPAA."
  - "Billing follows the chosen model's standard token rates and grows roughly linearly with the number and length of sessions."
  - "In Anthropic's tests, a wiki built by dreaming over 128 sessions lifted wiki-only answers from 13% to 48%, and wiki plus search reached 61% against 53% for search alone."
  - "A Claude Cookbook recipe builds the same idea yourself as a nightly dynamic workflow; Anthropic reports about $8 and ten minutes for 50 long transcripts."
article_toc:
  - id: "what-is-claude-dreaming"
    label: "What Is Claude Dreaming"
  - id: "how-agent-memory-layers-work"
    label: "Agent Memory Layers"
  - id: "claude-managed-agents-dreams-api-how-to-use-it"
    label: "Dreams API"
  - id: "claude-dreaming-pricing-limits-and-access"
    label: "Pricing and Limits"
  - id: "diy-claude-dreaming-with-a-dynamic-workflow"
    label: "DIY Workflow"
  - id: "claude-memory-results-from-anthropics-tests"
    label: "Test Results"
  - id: "when-claude-dreaming-does-not-help"
    label: "When It Doesn't Help"
  - id: "claude-dreams-vs-claude-code-auto-memory"
    label: "vs Claude Code Memory"
---

Anthropic has added **Claude dreaming** to Claude Managed Agents. The new Dreams endpoint takes an agent's memory store and up to 100 of its past sessions, and writes a reorganized memory store with duplicates merged, contradictions resolved and stale entries replaced. Agents that run for weeks can start each new session from cleaner notes. On November 6, 2026, Anthropic published the research behind it, "The components of agent memory," with test results on benchmarks, Pokémon Red and document wikis.

Dreams is a research preview. You request access, and it runs only on the Claude API.

## What Is Claude Dreaming

Claude dreaming is an offline pass in which Claude reads its own session transcripts and rewrites its memory: fixing wrong notes, writing new ones, and building larger structures such as linked wikis. Anthropic's post borrows the name from how sleep is thought to consolidate memory in the brain, and credits sleep-time compute, proposed by researchers at Letta and UC Berkeley, as the starting idea.

Anthropic defines agent memory narrowly. It is knowledge Claude gains from experience and keeps between sessions as context it can read later. Weight updates, in-context learning within one conversation and compaction (summaries that replace older turns) fall outside that definition.

The problem Dreams targets is described in the Claude Platform docs. When an agent writes to memory a little at a time, the store collects duplicate entries, contradictions and facts that have gone out of date. A note that was wrong when written, or that drifted as the environment changed, is still read and trusted in later sessions.

## How Agent Memory Layers Work

Anthropic describes agent memory as four layers, and dreaming can write to each of them.

<img src="/images/claude-dreaming/memory-hierarchy-dreaming.webp" alt="Diagram of Anthropic's agent memory hierarchy between a session and the next session: transcripts as a searchable event log at the bottom, memory notes written by Claude, memory representations such as wikis, and injected context loaded into every session, all inside a box labeled Dreaming" width="1600" height="731" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*The memory hierarchy from Anthropic's research post. Dreaming reads transcripts and writes to the layers above them. Source: Anthropic.*

| Layer | What it holds | Who writes it |
|---|---|---|
| Transcripts | Full, searchable log of each session | The harness |
| Memory notes | Salient observations, rules, warnings | Claude, during a session |
| Memory representations | Linked structures such as wikis | Claude, mostly while dreaming |
| Injected context | A small set of notes loaded into every session | Promoted by dreaming or by Claude |

The transcripts act as ground truth. In-session notes reflect what Claude judged important at the time, before it knew what would come next. Dreaming checks those notes against what actually happened. For a wider survey of how agents learn across runs, see our [guide to self-evolving agents](/tutorials/self-evolving-agents-review-en/), which places memory beside weight updates and prompt optimization.

## Claude Managed Agents Dreams API: How to Use It

In Claude Managed Agents, a dream is an asynchronous job: you pass a memory store and a list of sessions, and you get back the ID of a new memory store when it finishes. The documented call uses the Python SDK:

```python
dream = client.beta.dreams.create(
    inputs=[
        {"type": "memory_store", "memory_store_id": store_id},
        {"type": "sessions", "session_ids": [session_a, session_b]},  # 1 to 100 sessions
    ],
    model="claude-opus-5-5",
    instructions="Focus on coding-style preferences; ignore one-off debugging notes.",
)
```

Requests need two beta headers, `managed-agents-2026-04-01` and `dreaming-2026-04-21`. The first one alone does not unlock dreams. If the agent has no memory store yet, create an empty one and pass it as the input.

The three parameters do different jobs:

- **inputs**: one existing memory store and between 1 and 100 sessions. The input store is never changed; the output is always a new store.
- **model**: only some models are supported. The docs list Haiku 5.5, Haiku 4.5, Opus 4.6, Opus 4.5, Sonnet 4.5 and the Mythos models as unsupported.
- **instructions**: guidance on what to focus on. Line-level edit commands in this field generally have no effect; the docs point to the Memory Stores API for direct edits.

A dream moves through `pending`, `running`, `completed`, `failed` or `canceled`. The docs say it can take from a few minutes to a few hours, depending mostly on how many transcripts it reads. A failed or canceled dream still leaves a partial output store. When it completes, you attach the output store to new sessions as a `memory_store` resource, or archive and delete it if you prefer the old one. Because the input is untouched, rolling back means pointing your agents at the previous store.

Deleting the input store or a source session during a run fails the job with `input_memory_store_unavailable` or `input_session_unavailable`.

## Claude Dreaming Pricing, Limits and Access

Dreams has no separate fee. According to the docs, it bills at the standard token rates of the model you choose, and cost scales roughly linearly with the number and length of sessions. Anthropic's advice is to start with a small batch.

Other limits from the documentation:

- Research preview; access is by request.
- Claude API only.
- Not eligible for Zero Data Retention or HIPAA.
- Standard rate limits apply; listing dreams returns 20 by default and at most 100.
- Errors include `timeout`, `memory_store_org_limit_exceeded` and `input_memory_store_too_large`.

For teams that already track agent spend per task, as in our piece on [cost per successful task for coding agents](/tutorials/coding-agents-finops-cost-per-successful-task/), a dream is one more line item: a periodic job whose cost follows transcript volume.

## DIY Claude Dreaming with a Dynamic Workflow

The Dreams docs link to a Claude Cookbook recipe by Brad Abrams, published November 2, 2026, for teams that want to control the prompts, models and schedule themselves. It builds a dream from Managed Agents parts.

<img src="/images/claude-dreaming/cookbook-dreaming-workflow.webp" alt="Three-step flow: load your sessions as transcript files, dream over them in one session where a lead agent writes a workflow of one analyzer per file followed by one organizer, then the agent mounts the memory store read-only; a cron job runs dreaming_nightly.py every night at 1 AM on sessions since the last run" width="1600" height="500" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*The cookbook's do-it-yourself dream. Source: Claude Cookbook.*

The recipe works in three steps:

1. **Export sessions** as transcript files, one per session. By default it reads the last 14 days for a given agent ID.
2. **Dream over them** in one session. A lead agent (Sonnet 5.5 by default) writes a dynamic workflow and starts it: one analyzer agent per transcript distills it into small linked Markdown files, then an organizer agent merges duplicates, fixes links and completes an index. Analyzers and organizer default to Haiku 5.5.
3. **Use the result.** The production agent mounts the memory store read-only. A cron job runs the script every night at 1 AM over sessions since the last run.

Anthropic's cookbook gives these costs at list price:

| Input | Cost | Time |
|---|---|---|
| 11 example transcripts (283 KB) | $0.36 | ~2.5 min |
| 50 long transcripts (~12 MB), cost-saving settings | ~$8 | ~10 min |
| Same 50, without those settings | ~$10 | ~9 min |

The recipe reports that stores built with and without the cost-saving settings held about the same share of a fixed list of facts. Its default budget ceiling is $40 per run.

The recipe also treats transcripts as untrusted input. Analyzers get file tools only, with no shell, no web and an empty network allowlist, and the dreaming session is the only place the store is mounted read-write. The cookbook notes that, at worst, an injected instruction in a transcript could change what the store says and spend up to the budget, so it suggests reading the store after the first run. Our article on [what changes when AI agents get internal access](/tutorials/ai-agent-internal-access-security-boundary/) covers why that boundary matters once agents act on what they read.

## Claude Memory Results from Anthropic's Tests

Anthropic's post reports results in two groups: plain memory folders written during sessions, and dreaming on top of them. All numbers below are Anthropic's internal runs.

### Memory alone on CL-Bench

On a database task from Continual Learning Bench 1.0, run on Claude Managed Agents, Claude started each question in a fresh session and could read a memory directory that persisted between sessions.

<img src="/images/claude-dreaming/cl-bench-memory-scores.webp" alt="Bar and line charts of mean reward on the CL-Bench database task with a memory store versus a stateless baseline: Opus 5.5 0.838 vs 0.655, Sonnet 5.5 0.833 vs 0.644, Opus 5 0.828 vs 0.564, Opus 4.7 0.700 vs 0.383, Sonnet 5 0.610 vs 0.306, Sonnet 4.6 0.364 vs 0.330" width="1600" height="900" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*CL-Bench database task, memory store versus stateless baseline. This chart measures memory notes, not dreaming. Source: Anthropic.*

Newer models gained most. Opus 5 rose from 0.564 to 0.828 and was the first to "close the loop," writing rules together with how it had verified them. Sonnet 4.6 barely moved (0.330 to 0.364) until it was prompted to read its memory and test its theories, which took it to 0.641.

Anthropic also found that fixed rules can hurt. Telling models to "record only failures" cut the gain from memory by 0.234 for Opus 5 and 0.150 for Opus 4.7. Its guidance is to tell Claude what memory is for, and leave the choice of what to save to the model.

### Dreaming corrects a wrong note

In a Pokémon Red run on Managed Agents, Claude wrote down the wrong side of Mt. Moon for a landmark, declared "Mt Moon DONE" and walked off a one-way ledge.

<img src="/images/claude-dreaming/pokemon-mt-moon-dreaming.webp" alt="Line chart of progress toward Cerulean City over 3,000 actions: the memory plus dreaming run reaches Cerulean at action 1,935, the raw memory run falls off the ledge and backtracks to Pewter, and the no-memory run never reaches Cerulean" width="1600" height="1098" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*Progress toward Cerulean City with corrected memory, raw memory and no memory. Source: Anthropic.*

Anthropic then ran dreaming on that memory folder. Claude checked the note against the session transcript, found the error and rewrote it. With the corrected note, it went back into the cave and reached Cerulean City at action 1,935. The run with the uncorrected note fell off the ledge three times and ended back in Pewter City. These are single runs, so they show the mechanism rather than a success rate.

### Dreaming builds wikis

Anthropic tested wikis on about 350,000 internal files (roughly 420M tokens) from Stainless, a company it acquired, using 25 questions. Opus 5 agents dreamed over 128 sessions, writing and correcting linked pages and checking claims against sources.

<img src="/images/claude-dreaming/wiki-growth-search.webp" alt="Center chart of graded criteria met as wiki generation grows from 2M to 128M dreaming tokens: wiki plus search tool rises from 54% to 61%, wiki alone from 13% to 48%, search tool with no wiki flat at 53%; side panels show the example wiki at 103 pages and 766 links after 2 sessions and 222 pages and 12,893 links after 128 sessions" width="1600" height="731" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*Wiki quality as dreaming continues. The x-axis is a budget of 1M tokens per session, not measured spend. Source: Anthropic.*

| Setup | Graded criteria met |
|---|---|
| Wiki alone, after 2 sessions | 13% |
| Wiki alone, after 128 sessions | 48% |
| Search tool, no wiki | 53% |
| Wiki + search, after 128 sessions | 61% |

Anthropic reports that wiki plus search also used about 20,000 fewer tokens per question. On 24 questions about a merger, most of which needed information from several documents, Claude scored 87% with the wiki against 73% with search alone.

### Instructions decide what survives

On a legal-brief task built from contracts, several agents wrote to one shared table at the same time and overwrote each other. The brief built from that wiki met 41 of 57 graded facts.

<img src="/images/claude-dreaming/contract-wiki-41-57.webp" alt="Two diagrams: before, four agents write to one shared provisions.md page and overwrite each other, leaving 41 of 57 graded facts; after, each agent writes its own contract page quoting terms word for word, and 57 of 57 facts survive" width="1600" height="759" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*Graded contract facts before and after the wiki-building instructions changed. Source: Anthropic.*

Claude then ran a loop of reflecting on failures and rewriting its own build instructions. The new version gave each contract its own page, written by one agent and quoting terms word for word, and the brief met all 57. This is the kind of focus the Dreams `instructions` parameter is meant to carry.

## When Claude Dreaming Does Not Help

Anthropic's post lists cases where the wiki added little or cost too much:

- **Single-document answers.** On a task where most criteria came from one memo, the wiki showed no clear gain over text search.
- **Over-detailed wikis.** On another task the wiki reached 203 KB from a 115 KB corpus, 1.77 times its source, and abstracted nothing.
- **Compute cost.** Every dream spends tokens. Anthropic suggests focusing dreaming on information likely to change, or tuning how often it runs.
- **Error build-up.** Representations such as wikis need upkeep so they do not accumulate errors or hallucinations, and the post names plain transcript search as a reasonable foundation.

The Hacker News thread on the post (about 90 points when we read it) pushed in the same direction. Several commenters read the term "dreaming" as a label for rewriting Markdown notes. One said they delete about 95% of Claude Code memories as task-specific, and another read the wiki chart as showing that search does most of the work. For long-running systems, the design question is where memory sits in the harness, a theme in our piece on [why harnesses are taking over production agents](/tutorials/agent-framework-harness-runtime-production/) and in our [review of stateful long-horizon agents](/tutorials/stateful-long-horizon-agents-review/).

## Claude Dreams vs Claude Code Auto Memory

Claude Dreams and Claude Code auto memory handle the same problem at different times. Claude Code maintains its memory during the session; Dreams reorganizes a Managed Agents memory store afterwards, from transcripts.

| | Claude Dreams | Claude Code auto memory |
|---|---|---|
| Where | Claude Managed Agents (Claude API) | Claude Code |
| When it runs | Offline job after sessions | During the session |
| Input | Memory store + 1 to 100 sessions | The current session |
| Output | A new memory store | Updates to memory files, indexed by MEMORY.md |
| Status | Research preview, access by request | Part of Claude Code |

Both keep the always-loaded layer small. Anthropic's post says Claude Code loads only the first 200 lines or 25 KB of MEMORY.md, which works as an index pointing to the rest, and its Claude Code docs warn that longer instruction files reduce adherence. The sources reviewed here do not describe a dream command for Claude Code itself.

For agents on Managed Agents, the practical path is to keep writing memory during sessions, run a small Dreams batch on a copy of the store, read the output, and only then point production sessions at it.

## References

- Anthropic, ["The components of agent memory"](https://www.anthropic.com/research/components-of-agent-memory), Lance Martin, Nov 6, 2026
- Claude Platform docs, ["Dreams"](https://platform.claude.com/docs/en/managed-agents/dreams), Managed Agents, checked Nov 7, 2026
- Claude Cookbook, ["Dreaming with a dynamic workflow"](https://platform.claude.com/cookbook/managed-agents-cma-dreaming-with-a-dynamic-workflow), Brad Abrams, Nov 2, 2026
- Hacker News, ["The Components of Agent Memory"](https://news.ycombinator.com/item?id=50402212), discussion, read Nov 7, 2026
