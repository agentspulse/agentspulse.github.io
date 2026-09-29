---
layout: article-sky
article_variant: research-review
zoomable_images: true
lang: en
title: "Jev Ultrafast Explained: How Indexed DOM Actions Speed Up Browser Agents"
seo_title: "Jev Ultrafast: AI Browser Agent Speed & Limits"
description: "How Jev Ultrafast speeds up AI browser agents with indexed DOM actions and speculative targets, plus benchmark results, cost estimates, and limits."
keywords: "Jev Ultrafast, AI browser agent, Browser Use agent, browser agent, TypeSafe Jev, indexed DOM actions, browser automation"
tags: [browser-agents, computer-use, agent-infrastructure, evaluations]
categories: [frontier-research]
permalink: /tutorials/jev-ultrafast-browser-agent/
thumbnail: "/images/jev-ultrafast-browser-agent/professional-architecture.png"
og_image: "/images/jev-ultrafast-browser-agent/professional-architecture.png"
cover_alt: "Jev Ultrafast indexed browser-agent control loop"
cover_width: 5072
cover_height: 2720
date: 2026-09-28
last_modified_at: 2026-09-29
author_name: "AgentsPulse Editorial Team"
paper_count: 1
research_scope: "Browser agents · Dynamic action spaces · Runtime evaluation"
dek: "Jev Ultrafast is fast because it turns open-ended browser control into a constrained decision problem, then removes most of the browser round trips around that decision."
key_takeaways:
  - "Jev does not generate browser commands or text; it chooses typed operations and indexed targets from the current page state."
  - "The optimized runtime cut median browser protocol calls from 1,092 to 101 and median task time from 9.450 to 7.092 seconds in three matched Google Flights pairs."
  - "The evidence supports a narrow architecture claim, not a general benchmark: frames, shadow roots, canvas, uploads, new tabs, and several interaction classes remain unsupported."
article_toc:
  - id: "tldr"
    label: "TL;DR"
  - id: "jev-is-a-decision-model-not-a-browser-llm"
    label: "Jev Is a Decision Model"
  - id: "the-action-space-is-rebuilt-at-every-step"
    label: "A Dynamic Indexed Action Space"
  - id: "speculative-targets-collapse-two-decisions-into-one-request"
    label: "Speculative Target Heads"
  - id: "the-runtime-not-just-the-model-created-the-speedup"
    label: "The Runtime Created the Speedup"
  - id: "what-the-seven-second-result-actually-measures"
    label: "What the 7-Second Result Measures"
  - id: "the-half-cent-cost-is-an-estimate-not-a-complete-bill"
    label: "The Half-Cent Cost Claim"
  - id: "constrained-output-does-not-make-actions-safe"
    label: "Execution Safety"
  - id: "where-jev-ultrafast-does-not-work-yet"
    label: "Current Limits"
  - id: "what-browser-agent-builders-should-take-from-it"
    label: "Engineering Lessons"
  - id: "jev-ultrafast-faq"
    label: "Jev Ultrafast FAQ"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "Why execution state, tool boundaries, retries, and observability increasingly belong to the harness."
  - url: "/tutorials/coding-agents-finops-cost-per-successful-task/"
    title: "Coding Agents Enter the FinOps Era"
    description: "Why agent economics must include failures, verification, routing, and the full cost of a successful task."
---
Jev Ultrafast is Browser Use's experimental AI browser-agent runtime. It uses TypeSafe Jev to choose typed operations and indexed DOM targets instead of generating selectors, coordinates, or prose for every step. Its speed comes from giving the policy less freedom and making the surrounding browser loop do less work.

At each step, the runtime turns the live page into a numbered table of controls. TypeSafe's Jev chooses an operation and a compatible target from that table. A separate language model generates text only when Jev selects `TYPE_TEXT`. The executor then resolves the original DOM node, checks for page changes and target occlusion, and performs the input.

That division of labor matters more than the seven-second demo. It recasts browser control as a constrained decision problem rather than an open-ended generation task. It also shows why model speed alone does not determine browser-agent latency. The surrounding loop can be dominated by observation design, browser round trips, invalidation policy, waiting behavior, and outcome verification.

Browser Use's matched Google Flights comparison reports 25% lower median task time and a drop in median browser protocol calls from 1,092 to 101, or about 91%. Those results are real but narrow: three alternating pairs, one task, one existing Chrome profile, and live Google and network behavior. The repository explicitly says the experiment is not a broad agent benchmark.

<img src="/images/jev-ultrafast-browser-agent/professional-architecture.png" decoding="async" loading="lazy" width="5072" height="2720" alt="Jev Ultrafast indexed browser-agent control loop" data-zoomable title="Click to enlarge" />

*Jev Ultrafast narrows browser control into a typed decision over a fresh table of compatible actions, then validates the chosen target at execution time.*

## TL;DR

- **Jev is a structured decision model, not a text-generating LLM.** It receives page state and typed questions, then returns choices with probabilities. It does not write selectors, coordinates, JavaScript, or form text.
- **The action space is rebuilt after every observation.** Only controls visible and compatible with an operation are offered. `CLICK` targets are buttons and other clickable elements; `TYPE_TEXT` targets are editable fields; native dropdown choices carry observed element and option indexes.
- **Operation and target selection share one model request.** Jev evaluates the operation and speculative target questions over the same state. The runtime keeps only the target corresponding to the chosen operation.
- **The measured improvement came primarily from runtime work.** The optimized implementation replaced repeated accessibility-tree reads and hundreds of node resolutions with one atomic DOM snapshot, narrower freshness guards, current-geometry checks, and brief event-based waits.
- **The headline result is limited.** Three matched pairs all passed, but the sample is too small for a strong statistical claim. The repository reports a two-sided sign-test value of `p = 0.25`.
- **The often-repeated `$0.0039` cost is a list-price estimate for model calls, not a complete browser-agent bill.** It excludes browser infrastructure and post-run verification.
- **The MVP is not a universal web agent.** It does not yet traverse frames or shadow roots and does not support canvas, uploads, new tabs, nested scrolling, or arbitrary keyboard widgets.

## Jev is a decision model, not a browser LLM

Calling Jev the model behind a browser agent can suggest the wrong mental picture. Jev does not inspect a screenshot and narrate what to do, generate an action plan, or write text into a form.

TypeSafe describes Jev 1.13 as a System One model that evaluates multiple questions against one text state. It returns typed decisions, not generated prose. According to the official model documentation, Jev ingests the state once and evaluates every question against it in parallel. The [Pydantic AI integration](https://pydantic.dev/docs/ai/models/typesafe/) states the distinction plainly: "Jev is not a language model." Each field in a typed output becomes a question, and Jev returns the selected value and confidence without producing free-form text.

Jev Ultrafast uses this contract as its policy layer. The runtime serializes browser state into structured text, then asks which operation to run and which element should serve as the target for each operation that needs one. The vocabulary is deliberately small:

<ul class="sky-operation-set" aria-label="Jev Ultrafast operation vocabulary">
  <li><code>CLICK</code><span>activate an observed control</span></li>
  <li><code>TYPE_TEXT</code><span>generate and enter a value</span></li>
  <li><code>SELECT</code><span>choose an observed option</span></li>
  <li><code>SCROLL_UP</code><span>move the viewport upward</span></li>
  <li><code>SCROLL_DOWN</code><span>move the viewport downward</span></li>
  <li><code>WAIT</code><span>pause for a useful state</span></li>
  <li><code>DONE</code><span>request task completion</span></li>
  <li><code>BLOCKED</code><span>report no valid next action</span></li>
</ul>

Only `TYPE_TEXT` invokes a generative model. In the measured configuration, `inception/mercury-2.5` receives a small JSON-shaped prompt and returns the value to type. Before that value reaches the browser, the runtime requires the output to parse as a small JSON object. Every other step is either a typed choice from Jev or a programmatic action performed by the executor.

The architecture rests on a simple premise: browser control involves many decisions but relatively little language generation. If the page can expose a closed set of valid choices, there is no need to pay the latency and output-token cost of a general-purpose LLM for every click.

## The action space is rebuilt at every step

Many browser agents expose a stable tool such as `click(selector)` or ask a model to return coordinates. Jev Ultrafast does neither. Each observation produces a new table derived from the current DOM:

```text
[1] button    Change ticket type · Round trip
[2] combobox  Where from? · San Francisco
[3] combobox  Where to? · empty
[4] textbox   Departure · empty
...
```

The indexes are temporary and meaningful only for the page state that produced them. The model chooses among observed elements instead of inventing a locator.

This changes the failure surface. A generated CSS selector can be malformed, select the wrong duplicate element, or refer to a structure that no longer exists. A coordinate can land on an overlay or move with the viewport. An indexed target can still be semantically wrong, but it cannot name an element that the runtime never offered. The executor also retains references to the observed DOM nodes, so model output never becomes executable JavaScript or a new selector language.

The action table is dynamic in two ways. The runtime rebuilds it after every interaction, and it filters the options for compatibility with each operation. A click-target question receives clickable controls; a text-target question receives editable fields; a select-target question appears only when native selection is available. This does more than trim tokens. It encodes part of the browser semantics before the model decides.

A useful way to understand the design is as an action compiler:

<ol class="sky-compiler-flow" aria-label="Jev Ultrafast action compiler stages">
  <li><span>01</span><strong>Observe</strong><small>live page</small></li>
  <li><span>02</span><strong>Snapshot</strong><small>atomic controls</small></li>
  <li><span>03</span><strong>Index</strong><small>compatible candidates</small></li>
  <li><span>04</span><strong>Decide</strong><small>typed operation</small></li>
  <li><span>05</span><strong>Execute</strong><small>guarded command</small></li>
</ol>
<p class="sky-compiler-loop"><i class="ti ti-refresh" aria-hidden="true"></i> Fresh observation rebuilds the action space for the next step.</p>

The model does not need to know how Chrome represents a node, how to construct a CDP command, or how to hit-test the final coordinates. The runtime does not need a semantic understanding of the user's goal. Each handles the work it is suited to do.

## Speculative targets collapse two decisions into one request

A straightforward implementation would first ask which operation to perform, wait for the answer, and then ask which element should receive that operation. Jev Ultrafast asks both questions at once.

The request contains one operation question and separate target questions such as `click_target`, `type_text_target`, and `select_target`. These questions are speculative because the runtime will discard most of their answers. If Jev chooses `CLICK`, only `click_target` can execute. If it chooses `TYPE_TEXT`, the runtime keeps `type_text_target` and asks the small helper model to generate the text.

<div class="sky-decision-flow" role="img" aria-label="The page state enters one Jev request. Jev evaluates the operation plus click, text, and select target heads in parallel. The runtime keeps only the head matching the chosen operation and executes a guarded browser action.">
  <div class="sky-flow-endpoint sky-flow-input">
    <span>Observed state</span>
    <strong>Page state</strong>
    <small>indexed controls</small>
  </div>
  <i class="ti ti-arrow-right sky-flow-arrow" aria-hidden="true"></i>
  <div class="sky-flow-request">
    <header>
      <span>One Jev request</span>
      <strong>Parallel decision heads</strong>
    </header>
    <div class="sky-flow-heads">
      <div><code>operation</code><span>CLICK · TYPE_TEXT · SELECT</span></div>
      <div><code>click_target</code><span>clickable elements</span></div>
      <div><code>type_text_target</code><span>editable elements</span></div>
      <div><code>select_target</code><span>element + option</span></div>
    </div>
  </div>
  <i class="ti ti-arrow-right sky-flow-arrow" aria-hidden="true"></i>
  <div class="sky-flow-endpoint sky-flow-output">
    <span>Selected route</span>
    <strong>Matching head only</strong>
    <small>guarded browser action</small>
  </div>
</div>

This works because Jev evaluates multiple typed questions against the same state in parallel. The target questions do not have to wait for the operation answer. Browser Use describes the result as "two decisions, one network round trip."

The discarded work is cheap compared with another remote request. Speculation also keeps the questions independent: each target head sees only candidates compatible with its operation, not one large mixed catalog. The runtime, rather than the model, enforces the link between the chosen operation and the only target allowed to execute.

The approach has a clear boundary. It works when the next decision can be expressed as several closed questions over the same state. It does not replace open-ended planning, text composition, or tasks in which the second question depends on new information returned by the first action.

## The runtime, not just the model, created the speedup

The matched comparison did not introduce a new decision model. Both arms used TypeSafe `jev-1.13.0`, Mercury 2.5 for text, the same goal and viewport, and the same request and action budgets. The main measured change was in the runtime.

The original loop invalidated a decision after every DOM mutation, including animation. It repeatedly read the accessibility tree and resolved hundreds of nodes through the browser protocol. That approach is conservative, but expensive on a page such as Google Flights, where autocomplete popups, loading indicators, and animated transitions produce frequent state changes.

### What changed in the runtime

The optimized runtime changed five parts of the loop:

1. **One browser call per snapshot.** Common HTML and ARIA controls, names, values, and visible text are collected atomically rather than assembled through repeated accessibility-tree and node-resolution calls.
2. **Scoped freshness checks.** Click guards compare the selected target, nearby context, and document or form state. Unrelated visible changes do not automatically invalidate a decision.
3. **Geometry is resolved at execution time.** The executor checks current position and hit-testing immediately before input, rejecting covered controls without forcing the model to reason about coordinates.
4. **Waiting is interaction-specific.** Typing into a combobox triggers a brief event-based wait for visible suggestions, capped at 200 milliseconds. Other interactions wait for at most two animation frames or 50 milliseconds.
5. **Background rendering is preserved.** Focus emulation prevents hidden-tab animation throttling without switching the user's visible tab.

### Why browser work mattered more than model work

These are browser-runtime optimizations, not model capabilities. They explain why browser protocol calls fell much more sharply than model requests. Median TypeSafe requests fell from 22 to 17, or about 23%. Median browser protocol calls fell from 1,092 to 101, or about 91%.

The gap matters. A faster policy helps, but an inefficient observation and execution loop can erase the benefit. The [browser harness determines how much work surrounds each model decision](/tutorials/agent-framework-harness-runtime-production/), including observation, permissions, retries, and verification.

## What the seven-second result actually measures

The repository provides unusually specific measurement boundaries. The current video finishes the Google Flights task in 7.073 seconds at normal playback. The goal is to find one-way flights from Zürich to London for one adult in economy on September 20, 2026, stopping when matching flight options are visible.

### Measurement boundary

The timer starts with the first prediction after the initial homepage observation and ends when the runtime accepts `DONE`.

<div class="sky-timing-boundary">
  <section>
    <span><i class="ti ti-player-play" aria-hidden="true"></i> Inside the timer</span>
    <ul>
      <li>Jev requests and Mercury text generation</li>
      <li>Browser execution and stale decisions</li>
      <li>Loading waits and the final completion decision</li>
    </ul>
  </section>
  <section>
    <span><i class="ti ti-player-skip-forward" aria-hidden="true"></i> Outside the timer</span>
    <ul>
      <li>Browser setup</li>
      <li>Initial navigation</li>
      <li>Fresh independent post-run verification</li>
    </ul>
  </section>
</div>

The recorded run contains 17 Jev requests, ten interactions, one explicit `WAIT`, and two helper-model calls. Median Jev latency was 178 milliseconds. Mercury generated “Zurich” in 581 milliseconds and “London” in 346 milliseconds. Search executed at 5.217 seconds; the remaining interval includes Google loading results, subsequent state changes, and the completion decision.

### Matched benchmark results

The matched experiment alternated between the original and optimized runtimes across six runs:

<img src="/images/jev-ultrafast-browser-agent/matched-comparison-editorial.png" decoding="async" loading="lazy" width="5600" height="3040" alt="Matched Jev Ultrafast runtime comparison" data-zoomable title="Click to enlarge" />

*The optimized runtime reduced median task time by 25% and browser protocol calls by about 91% in three matched pairs; the sample is too small for a broad performance claim.*

| Pair | Original runtime | Optimized runtime | Verification |
|---|---:|---:|---|
| 1 | 11.214 s | 6.964 s | Both passed |
| 2 | 8.984 s | 7.913 s | Both passed |
| 3 | 9.450 s | 7.092 s | Both passed |
| **Median** | **9.450 s** | **7.092 s** | **3/3 each** |

The optimized runtime was faster in all three pairs. Median task time was 25.0% lower; median TypeSafe requests fell from 22 to 17; median browser protocol calls fell from 1,092 to 101.

The repository also reports two smoke checks: opening a requested Wikipedia article in 2.798 seconds and completing a local hotel search and filter task in 1.896 seconds. These runs show that the same policy can execute other tasks, but they are not matched speed comparisons. They do not support a general 25% improvement claim.

Three pairs are too few to establish a stable latency distribution. Browser Use reports a two-sided sign-test value of `p = 0.25` and identifies live Google behavior, network responses, routing, and browser caches as uncontrolled sources of variation. The result supports a mechanism: less observation work and fewer browser round trips can reduce end-to-end latency. It does not establish a general browser-agent leaderboard position.

## The half-cent cost is an estimate, not a complete bill

Secondary coverage often describes the Flights run as costing `$0.0039`. That figure is plausible, but its scope is narrow.

### What the $0.0039 estimate includes

The performance report records 90,558 TypeSafe input tokens and 6,325 output tokens across the run. TypeSafe's current Jev 1.13 documentation lists input at `$0.042` per million tokens and says output tokens are free. At that list price, the Jev input is approximately:

<div class="sky-cost-breakdown" aria-label="Estimated model call cost calculation">
  <div class="sky-cost-equation">
    <span>90,558 input tokens</span><i>×</i><span>$0.042 / Mtok</span><i>=</i><strong>$0.003803</strong>
  </div>
  <dl>
    <div><dt>Jev input at list price</dt><dd>$0.003803</dd></div>
    <div><dt>Two Mercury text calls</dt><dd>$0.000063</dd></div>
    <div class="sky-cost-total"><dt>Estimated model-call total</dt><dd>$0.003866</dd></div>
  </dl>
</div>

OpenRouter reported `$0.00006272` for the two Mercury text calls. Adding the two figures gives roughly `$0.003866`, which rounds to `$0.0039`.

### What the estimate excludes

This is not a complete cost per successful task. The Jev response contained token counts but no billed dollar amount, so its share is reconstructed from list price. The estimate excludes browser infrastructure. The fresh verifier runs after the timer, and its cost is not part of the headline figure. Engineering, retries outside the recorded run, proxy services, and any cloud-browser charge also fall outside the calculation.

The defensible claim is therefore narrower than "browser-agent costs fell 90%." The experiment measured about 91% fewer browser protocol calls and 25% lower median task time. It did not publish a matched original-versus-optimized dollar-cost comparison. This distinction is why browser-agent economics should be evaluated as [cost per successful task](/tutorials/coding-agents-finops-cost-per-successful-task/), including failures and verification, rather than as one recorded model bill.

## Constrained output does not make actions safe

Jev Ultrafast removes several dangerous output classes from the model contract. Jev cannot emit shell commands, executable JavaScript, arbitrary selectors, or coordinates. The text helper can return only a small JSON value, and it runs only after Jev has selected `TYPE_TEXT`. These constraints reduce the attack and error surface.

They do not make browser actions inherently safe.

A valid indexed element can still be the wrong element. A well-formed text value can still disclose sensitive information. A `CLICK` can still submit a form or confirm a purchase, and a `DONE` choice can still be premature. The repository states the last point plainly: "DONE is never independent evidence of success."

The runtime adds execution checks rather than trusting the model output directly. It retains observed node references, rechecks page freshness, resolves current geometry, and rejects covered targets. For clicks, it compares the target and nearby context along with document and form state. Interrupted or uncertain mutations stop rather than being blindly replayed in cases where another execution could duplicate an effect.

These guards answer a specific question: is this still the observed target, and can the intended browser command be applied now? They do not determine whether the user's real-world objective permits the action. Production use still needs permission policy, confirmation for consequential operations, domain restrictions, and independent outcome checks at the harness layer.

## Where Jev Ultrafast does not work yet

The repository calls the implementation an MVP, and the unsupported cases are substantial:

<ul class="sky-limit-grid" aria-label="Current Jev Ultrafast limitations">
  <li><i class="ti ti-accessible-off" aria-hidden="true"></i><span>No full accessible-name algorithm</span></li>
  <li><i class="ti ti-box-multiple" aria-hidden="true"></i><span>No shadow-root traversal</span></li>
  <li><i class="ti ti-layout-bottombar" aria-hidden="true"></i><span>No frame handling</span></li>
  <li><i class="ti ti-palette-off" aria-hidden="true"></i><span>No canvas interaction</span></li>
  <li><i class="ti ti-upload-off" aria-hidden="true"></i><span>No file uploads</span></li>
  <li><i class="ti ti-external-link-off" aria-hidden="true"></i><span>No newly opened tabs</span></li>
  <li><i class="ti ti-arrows-down-up" aria-hidden="true"></i><span>No nested scrolling</span></li>
  <li><i class="ti ti-keyboard-off" aria-hidden="true"></i><span>No arbitrary keyboard widgets</span></li>
</ul>

The default loop deliberately omits screenshots. On DOM-rich forms and navigation pages, this avoids image processing and coordinate prediction. It becomes a limitation when state exists mainly in pixels, a canvas, a remote desktop stream, or a custom widget whose semantics are not exposed through ordinary HTML and ARIA.

The architecture fits sites with visible, well-labeled controls and tasks that can be expressed as repeated local choices: click, type, select, wait, or stop. It is a poor fit for visually rich or structurally opaque applications that require spatial understanding, cross-frame state, drag gestures, complex keyboard sequences, or uploads.

There is also a context-cost tradeoff. The recorded run sent 90,558 Jev input tokens across 17 requests. Typed outputs are cheap and fast, but rebuilding and resending page state still has a cost. A large page with many visible controls can expand both the state and the candidate questions. As the action space grows, the architecture still needs pruning, state compression, and model-specific evaluation.

## What browser-agent builders should take from it

**Treat action-space design as a first-class optimization.** A model choosing among ten compatible controls has a different problem from a model generating an unconstrained selector. Before upgrading the model, reduce the set of outputs the runtime is willing to accept.

**Separate decisions from generation.** Most browser steps are classifications or selections. Use a generative model only when the task requires new language. This can reduce latency and malformed-output handling while keeping the policy easier to inspect.

**Measure browser work independently from model work.** Jev Ultrafast's largest relative reduction was in protocol calls, not decision requests. Track snapshots, node resolutions, CDP calls, stale retries, waits, and page mutations alongside model latency and tokens.

**Make observation atomic where possible.** Names, roles, values, visibility, and node references should describe one page state. Assembling them through many sequential reads creates both latency and consistency problems.

**Validate at execution time.** A decision can be correct for an old page and unsafe for the current one. Recheck target identity, context, geometry, and occlusion immediately before mutation. Handle uncertain mutation outcomes differently from ordinary stale reads so a possibly completed action is not replayed.

**Keep completion separate from verification.** `DONE` is a policy prediction. Success is an externally checked property. The Flights example uses an independent checker for route, date, trip type, passenger class, and visible results; production systems need equally explicit success criteria.

**Benchmark the workload you actually have.** The current evidence covers one matched live-web task and two smoke checks. Teams should compare policies on their own mix of forms, search pages, custom components, authenticated workflows, and failure cases. Success rate and verification cost belong next to latency in those results.

The model is only one component of the control loop. The harness decides what the model can see, what it may choose, how output becomes an action, when a retry is safe, and how success is proved. Jev Ultrafast makes that division unusually visible in a small codebase.

## Jev Ultrafast FAQ

### What is Jev Ultrafast?

Jev Ultrafast is an experimental AI browser-agent runtime from Browser Use. It turns the live DOM into a numbered set of compatible controls, asks TypeSafe Jev to choose a typed operation and target, and validates that target immediately before execution.

### Is Jev an LLM?

No. Jev is a typed decision model: it evaluates closed questions over one text state and returns choices with probabilities. Jev Ultrafast calls a separate generative model only when the selected operation requires new text.

### How does Jev Ultrafast make AI browser agents faster?

It reduces both decision and browser overhead. Speculative target heads combine operation and target selection into one request, while the optimized runtime replaces repeated accessibility-tree reads with one atomic DOM snapshot and shorter, interaction-specific waits.

### How much does a Jev Ultrafast task cost?

The recorded Google Flights run has an estimated model-call cost of about `$0.0039`. That estimate excludes browser infrastructure, independent verification, retries outside the recorded run, and engineering costs, so it is not a complete cost per successful task.

### What are Jev Ultrafast's main limitations?

The MVP does not yet handle frames, shadow roots, canvas interfaces, uploads, new tabs, nested scrolling, or arbitrary keyboard widgets. It works best on pages with visible, well-labeled HTML and ARIA controls.

## Evidence and limits

The primary evidence comes from the Browser Use `jev-ultrafast` repository, including its README and `docs/performance.md`. The repository provides the task definition, measurement boundaries, paired timings, model versions, token counts, protocol-call counts, verification results, source hashes, and explicit limitations. This is stronger evidence than a demo video alone, but the experiment remains self-reported by the project authors.

The matched comparison contains three original/optimized pairs on one Google Flights task. All six runs passed independent verification, and the optimized runtime was faster in each pair. The sample is too small for a strong statistical claim, as the authors acknowledge. Initial navigation and fresh post-run verification are excluded from the timer. Live Google behavior, networking, routing, and browser caches are not controlled.

The `$0.0039` figure is reconstructed from the repository's token counts, OpenRouter's reported helper charge, and TypeSafe's current published Jev input price. It should be described as an estimated model-call cost for the recorded run, not as a full task cost or a measured 90% cost reduction.

The architecture claims are bounded by the checked repository version and Jev 1.13.0. The implementation handles common HTML and ARIA controls, not the full browser interaction surface. This article therefore treats Jev Ultrafast as evidence for a design direction, namely dynamic action spaces paired with a lean browser runtime. It is not evidence that DOM-only policies supersede multimodal browser agents across all websites.

## References

1. Browser Use. [`browser-use/jev-ultrafast`](https://github.com/browser-use/jev-ultrafast). GitHub repository and README.
2. Browser Use. [“Faster on the real web.”](https://github.com/browser-use/jev-ultrafast/blob/main/docs/performance.md) Matched runtime comparison and measurement notes.
3. TypeSafe AI. [“Models: Jev 1.13.”](https://docs.typesafe.ai/models) Model behavior, context, and pricing.
4. Pydantic AI. [“TypeSafe (Jev).”](https://pydantic.dev/docs/ai/models/typesafe/) Typed decision-model integration and contract.
5. AlphaSignal. [“Browser Use's Jev Ultrafast Cuts Browser Agent Costs 90% With Indexed DOM Actions.”](https://alphasignal.ai/news/browser-use-s-jev-ultrafast-cuts-browser-agent-costs-90-with-indexed-dom-actions) Secondary coverage used only for the circulated cost framing.
