---
layout: article-sky
article_variant: research-review
lang: en
title: "HarnessDev Benchmark: Can LLMs Improve Their Harnesses?"
seo_title: "HarnessDev Benchmark: Can LLMs Improve Their Harnesses?"
description: "How HarnessDev tests LLM-built agent harnesses: creation results, executor transfer, held-out evolution gains, and the cost of running the generated systems."
keywords: "HarnessDev, HarnessDev benchmark, LLM agent harness, harness evolution"
tags: [agent-infrastructure, evaluation, frontier-research]
categories: [frontier-research]
permalink: /tutorials/harnessdev-agent-harness-benchmark/
thumbnail: "/images/harnessdev-agent-harness-benchmark/creation-runtime-cover.jpg"
og_image: "/images/harnessdev-agent-harness-benchmark/creation-runtime-cover.jpg"
date: 2026-09-08
last_modified_at: 2026-09-08
author_name: "AgentsPulse Editorial Team"
cover_alt: "Creator develops a harness above a freeze boundary; a separate executor runs inside the frozen harness"
cover_width: 1200
cover_height: 675
paper_count: 1
research_scope: "HarnessDev · Creation · Evolution"
dek: "How HarnessDev tests whether a model can build a reusable agent harness, and whether later edits help on tasks the creator never saw."
key_takeaways:
  - "Creation quality depends on the domain: writing and ML experimentation approach selected references, while code and browsing still lag."
  - "A frozen harness can collapse when the executor changes; portability is a property of the harness–model pair."
  - "Evolution gains on visible feedback often fail to hold out, and version selection is part of the loss."
article_toc:
  - id: "the-artifact-between-the-model-and-the-task"
    label: "The Artifact Between Model and Task"
  - id: "what-does-the-creator-have-to-build"
    label: "What the Creator Has to Build"
  - id: "creation-quality-depends-on-the-domain"
    label: "Creation Quality Depends on Domain"
  - id: "a-model-switch-tests-the-whole-control-policy"
    label: "A Model Switch Tests Control Policy"
  - id: "evolution-needs-a-way-to-choose-what-survives"
    label: "Evolution Needs a Survival Rule"
  - id: "capability-and-execution-cost-are-separate-outcomes"
    label: "Capability and Cost Are Separate"
  - id: "what-to-carry-into-a-harness-development-loop"
    label: "What to Carry Into a Dev Loop"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/self-evolving-agents-review-en/"
    title: "Self-evolving agents: survey and taxonomy"
    description: "Place harness-code evolution within the broader set of mechanisms agents can change."
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "How production systems separate framework APIs from the execution harness."
---
<p class="sky-direct-answer"><strong>HarnessDev is a benchmark for whether LLMs can create and improve reusable agent harnesses.</strong> An agent harness is the software that coordinates tool use, context, failure recovery, and completion around a model. Creation tests building that software; Evolution tests whether later edits help on unseen tasks. The reported benefits depend on the domain, the executor, and how revisions are selected.</p>

The harness itself is the submitted artifact. A model builds an execution system, the system is frozen, and it is reused on downstream tasks. Understanding those dependencies is more useful than treating the results as a single model leaderboard. [Wu et al., 2026](https://arxiv.org/html/2609.01437v1)

## The artifact between the model and the task

A tool definition does not decide when to call the tool. A transcript does not decide which parts of history to retain. A successful command does not establish that the user's task is finished. These decisions belong to the harness's execution and control logic. LangChain's [account of agent harnesses](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness) similarly includes tool execution, state, orchestration, and deterministic hooks around the model.

HarnessDev separates three roles:

- The **creator** develops the harness.
- The **executor** runs inside the frozen harness to perform a task.
- The **evaluator** scores the resulting task output.

Let H denote the harness, C the creator, E the executor, and x a downstream task. The paper's evaluation structure can be written compactly as:

<blockquote>
<p>(C, development environment) → H<br />
(H, E, x) → output → evaluator score</p>
</blockquote>

This separation makes it possible to hold the software fixed while changing the model that uses it. The diagram below places that boundary before execution.

<figure><a aria-label="Open Figure 1 at full size" class="figure-link" href="/images/harnessdev-agent-harness-benchmark/creation-runtime.png" rel="noopener" target="_blank"><img alt="Creator develops a harness above a freeze boundary; a separate executor runs inside the frozen harness below it." height="1536" loading="lazy" src="/images/harnessdev-agent-harness-benchmark/creation-runtime.png" width="1024"/><span class="image-hint">Select diagram to enlarge</span></a><p class="caption"><em>Figure 1. Original schematic of the creation protocol. Development produces a frozen harness; evaluation varies which model executes it. Based on <a href="https://arxiv.org/html/2609.01437v1#S3">HarnessDev, Equation 1 and Section 3</a>.</em></p></figure>

**Self-Eval** uses the creator model as the executor. **Unified-Eval** runs the generated harnesses with the same executor, Gemini 3.1 Pro. The first measures the creator–harness–executor combination; the second exposes differences in the generated software and its compatibility with a common runtime model. Neither makes compatibility disappear.

## What does the creator have to build?

Creation begins with a runnable but deliberately weak seed. It accepts inputs, exposes passive tools, and writes the expected audit files. It does not contain an agent loop, context management, recovery policy, verifier, or stopping rule. Unmodified, it scores zero on all five downstream benchmarks. The creator receives a specification and one to three development cases, then implements the behavior that turns this shell into an agent. [Section 3.2](https://arxiv.org/html/2609.01437v1#S3.SS2)

The interface describes six responsibilities: execution, tools, context, state, lifecycle, and evaluation. These responsibilities matter together. Context compression can preserve room for another turn but remove information that a later tool call needs. A recovery routine can retry an action but must preserve the state required to interpret its result. Anthropic's [context-engineering discussion](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) describes this tension: compaction reduces history while risking the loss of details whose importance becomes apparent later.

The difference between an interface and working behavior is visible in HarnessDev's state-management results. Appendix C gives this interface fragment:

```text
state.py       — save(checkpoint) -> None
                 load(id) -> State
                 resume() -> State
```

*Short interface excerpt from [Appendix C, arXiv v1](https://arxiv.org/html/2609.01437v1#A3), CC BY-NC-ND 4.0. It specifies responsibilities rather than executable Python.*

Eleven of the eighteen generated Code artifacts defined a State class, but only one exposed a state-saving interface and only one implemented periodic checkpointing. Across 26,679 recorded task trajectories, the authors observed no checkpoint event. A component name in the repository therefore provides much weaker evidence than a path that runs and preserves useful information. [Section 4.2](https://arxiv.org/html/2609.01437v1#S4.SS2)

This also explains why the scorer reads authoritative task artifacts. For coding tasks, success comes from the repository changes or final environment state. The harness's own claim that it succeeded is not a scoring input.

## Creation quality depends on the domain

Creation covers six creator models and 2,207 unique tasks across five benchmarks: SWE-bench Pro, Terminal-Bench 2.1, MLE-bench, EQ-Bench3, and BrowseComp. The reported creation scores average three independently built and evaluated harnesses for each creator–benchmark pair. [Sections 3.3 and 4.1](https://arxiv.org/html/2609.01437v1#S3.SS3)

The strongest generated result in each benchmark gives a useful first picture:

| Benchmark | Best generated Self-Eval result | Selected human-engineered system reference |
|---|---|---|
| SWE-bench Pro | Opus 4.8: 69.3% success | 80.0% |
| Terminal-Bench 2.1 | Gemini 3.1 Pro: 68.8% success | 88.8% |
| MLE-bench | Opus 4.8: 32.9% medal rate | 24.0% |
| EQ-Bench3 | Opus 4.8: 84.6 rubric score | 83.7 |
| BrowseComp | GPT-5.5: 52.6% accuracy | 92.2% |

*Selected values from [Table 3](https://arxiv.org/html/2609.01437v1#S4.T3). Each reference pairs a human-engineered harness with its own model; these are system-level comparisons, not matched experiments isolating human versus model-written code. The metrics differ across rows.*

Generated harnesses approach or exceed the selected reference in writing and machine-learning experimentation, while the code and research gaps remain substantial. That pattern narrows the engineering question. Producing a runnable loop is feasible; making it coordinate a long sequence of useful observations, edits, and checks remains difficult.

The implementation analysis supplies a concrete example. In Data tasks, 441 of 2,325 executed runs produced degenerate submissions that no harness detected. Validating that an output file exists is a different operation from checking whether it contains a meaningful submission. The distinction becomes consequential when a long run can finish cleanly while producing an unusable artifact. [Section 4.2](https://arxiv.org/html/2609.01437v1#S4.SS2)

## A model switch tests the whole control policy

For Opus-created Code harnesses, the reported average SWE-Pro score falls from 69.3 in Self-Eval to 33.0 under the fixed Gemini executor. The latter average includes one collapsed replica among three artifacts; the authors report 49.1 as a post-hoc sensitivity mean after excluding that replica. The failed artifact hard-coded a 120-step limit around its original executor. Keeping the failure in the main result matters: an automatically built harness should not need a successful replica chosen after the fact to appear portable. [Tables 3–4 and Section 4.2](https://arxiv.org/html/2609.01437v1#S4.SS2)

Search provides a second view. In the Opus Search harness, the duplicate-query rate rises from 10.1% to 88.2% when the executor changes. A policy that relies on the model to interpret review instructions, avoid repeated searches, and stop at the right time can change behavior even when its source code remains identical.

Other harnesses move in the opposite direction. Qwen's BrowseComp score improves by 17.6 points under Gemini. The result is not a universal portability penalty. It is evidence that the harness and executor form an interacting system: tool protocols, prompts, budgets, and termination rules need to work with the model actually deployed.

## Evolution needs a way to choose what survives

In the Evolution stage, the creator starts from its own frozen Creation code harness, H₀. It receives feedback from 100 SWE-Pro tasks and all 89 Terminal-Bench tasks. Each official candidate must complete both evaluations on the same frozen commit. The controller allows ten post-H₀ evaluation pairs, with at most two small diagnostic probes between charged pairs. [Section 3.2](https://arxiv.org/html/2609.01437v1#S3.SS2)

The visible pair score gives equal weight to the two benchmark percentages:

> Pair score = ½ × (SWE-Pro-100 score + Terminal-Bench-89 score)

Equal weighting here is per benchmark, rather than per task. These evaluations guide development and final-version selection. After the trajectories end, every official version is evaluated on 630 separate SWE-Pro instances whose scores are never shown to the creator.

This distinction defines what “improvement” means. The feedback set measures adaptation to the signal available during editing. The held-out set tests whether the resulting behavior helps on tasks outside that editing loop.

### From a completion claim to a completion check

One of the clearest diagnoses concerns premature completion. Opus found that 99 of 100 runs reported success while only 48 actually passed. It traced this discrepancy to finishing too early and added a completion check. [Section 4.3](https://arxiv.org/html/2609.01437v1#S4.SS3)

The mechanism changes where the execution path may terminate:

<figure><a aria-label="Open Figure 2 at full size" class="figure-link" href="/images/harnessdev-agent-harness-benchmark/completion-check.png" rel="noopener" target="_blank"><img alt="Before: work leads from a done assertion to stopping. With a check: passing permits stopping; failing leads through repair back to work." height="1536" loading="lazy" src="/images/harnessdev-agent-harness-benchmark/completion-check.png" width="1024"/><span class="image-hint">Select diagram to enlarge</span></a><p class="caption"><em>Figure 2. A completion check changes the exit path. The study reports the diagnosis and added check; this original schematic illustrates that control-flow distinction.</em></p></figure>

The useful information was the mismatch between an assertion and the evaluated artifact. It identified a place in the control flow where another check could change future behavior. More code, more tests, or more revisions alone would not identify that location.

Other edits damaged behavior. Qwen's message sanitizer broke valid Gemini tool-result sequences; DeepSeek rolled back much of a fixed-Gemini rewrite after context compression broke tool-message pairing. Recovery and compression routines need validation against the protocol they are intended to preserve.

### Feedback gains and held-out gains diverge

The study reports nine evolution lineages: five using each creator's own runtime and four using fixed Gemini. Figure 3 compares the change from H₀ to the creator-declared final version on the same held-out SWE-Pro set.

<figure><a aria-label="Open Figure 3 at full size" class="figure-link" href="/images/harnessdev-agent-harness-benchmark/heldout-gains.png" rel="noopener" target="_blank"><img alt="Held-out score changes: all five self-runtime lineages improve; with fixed Gemini, Opus improves while Qwen, DeepSeek and GPT regress." height="1800" loading="lazy" src="/images/harnessdev-agent-harness-benchmark/heldout-gains.png" width="1260"/><span class="image-hint">Select diagram to enlarge</span></a><p class="caption"><em>Figure 3. Percentage-point change on 630 held-out SWE-Pro tasks, using the deltas reported in <a href="https://arxiv.org/html/2609.01437v1#S4.T6">Table 6</a>. Each creator–runtime cell has one trajectory. Gemini's self-runtime result is the shared control, shown once.</em></p></figure>

All five self-runtime declarations improve, by 1.43 to 4.44 points. Under fixed Gemini, Opus improves by 2.70 points, while Qwen, DeepSeek, and GPT regress by 1.11, 2.38, and 10.32 points respectively. These observations show that the same broad editing procedure can produce a different generalization outcome under a different executor.

Version selection is another source of loss. Across 64 comparable switches, visible feedback and held-out scores move in the same direction only 34 times, or 53.1%. Only two of the nine declared versions achieve their lineage's best held-out score. A useful intermediate revision can therefore be followed by a worse revision that looks preferable on the feedback available to the creator.

Run variability makes small changes harder to interpret. The authors observe about ±4.75 pair-score points of variation for the same commit; only two of the 64 official switches have clear positive evidence beyond the repeated-run noise band. This is a study-specific observation, not a universal significance threshold. The evolution experiment has one trajectory per creator–runtime cell and held-out evaluation only on SWE-Pro, so it does not establish population-level success rates for automatic harness improvement. [Sections 4.3 and 6.1](https://arxiv.org/html/2609.01437v1#S4.SS3)

## Capability and execution cost are separate outcomes

MLE-bench illustrates why a score alone is insufficient. The GPT-5.5-created harness reaches a 19.1 medal rate using 29.3 million execution tokens; DeepSeek V4 Pro reaches 19.6 using 208.4 million. The second uses approximately 7.1 times as many tokens for a similar reported result. These are mean totals per harness over the benchmark evaluation, not tokens per task. [Table 3 and Appendix B.3](https://arxiv.org/html/2609.01437v1#A2.SS3)

The paper's execution accounting excludes the creator's cost of building or editing the harness. Token counts also do not convert directly into dollar costs across different models. For an engineering decision, the comparison needs both downstream quality and the resources needed to obtain it, with development and deployment costs kept distinguishable.

## What to carry into a harness-development loop

HarnessDev suggests a concrete way to assess an automatically proposed change: identify the failed behavior, locate the execution path responsible for it, modify that path, and check the frozen revision on tasks that did not guide the edit. Repeat the compatibility check for the executor that will actually run it. This is an engineering interpretation of the study's diagnosis, transfer, and selection results.

The distinction between declared and active mechanisms is especially useful. A state class needs an exercised save-and-resume path. A completion check needs a failure case that keeps the agent working. A context sanitizer needs valid tool sequences that survive it. Each turns a component name into observable behavior.

An open question is whether this process can sustain improvements over repeated generations. HarnessDev keeps the development environment fixed; it does not test whether an evolved harness can itself become the environment for the next round of evolution. Its evidence supports useful local program improvements, with substantial work remaining in diagnosis, compatibility, and selecting revisions that retain their benefit.

For the broader taxonomy of what agents can change, see the [self-evolving agents survey](/tutorials/self-evolving-agents-review-en/#harness-layer-evolution). For production responsibilities around this execution layer, see [why harnesses are taking over production](/tutorials/agent-framework-harness-runtime-production/).

## References

1. Wu et al. [HarnessDev: Can LLMs Create and Evolve Their Own Agent Harness?](https://arxiv.org/html/2609.01437v1) arXiv:2609.01437v1, September 2026. [Author project page](https://self-developing-agents.github.io/).
2. Vivek Trivedy. [The Anatomy of an Agent Harness](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness). LangChain, March 2026.
3. Anthropic. [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents). September 2025.
