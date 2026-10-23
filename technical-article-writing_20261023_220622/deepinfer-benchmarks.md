---
layout: article-sky
article_variant: research-review
review_eyebrow: "Community analysis"
zoomable_images: true
lang: en
title: "DeepInfer Benchmarks: 2× Serving Throughput, 0.59 s TTFT and Hopper Support from Community PRs"
seo_title: "DeepInfer Benchmarks: 2× Throughput, Hopper & AMD Ports"
description: "We read 191 DeepInfer PRs. Turning off EPLB doubled serving throughput, a prefix cache cut TTFT from 8.9 s to 0.59 s, and Hopper, AMD and Ascend 910B ports run."
keywords: "DeepInfer benchmark, DeepInfer benchmarks, DeepInfer performance, DeepInfer, DeepInfer Hopper, DeepInfer H20, DeepInfer AMD MI355X, DeepInfer Ascend 910B, DeepInfer EPLB, DeepInfer OpenAI compatible server, DeepSeek V4.1 Flash benchmark, DeepSeek-V4.1-Flash requirements, EPLB"
tags: [deepseek, open-source, inference, agent-infrastructure, deepinfer]
categories: [frontier-research]
permalink: /tutorials/deepinfer-benchmarks/
thumbnail: "/technical-article-writing_20261023_220622/figures/cover/deepinfer-community-cover-1280.webp"
og_image: "/technical-article-writing_20261023_220622/figures/cover/deepinfer-community-cover-1280.webp"
cover_alt: "Collage of DeepInfer charts: DeepSeek's serving architecture diagram, community A/B bar charts, a GB300 benchmark plot, a bar chart of PR topics and DeepSeek's prefill throughput curve"
cover_width: 1280
cover_height: 720
cover_srcset: "/technical-article-writing_20261023_220622/figures/cover/deepinfer-community-cover-640.webp 640w, /technical-article-writing_20261023_220622/figures/cover/deepinfer-community-cover-1280.webp 1280w, /technical-article-writing_20261023_220622/figures/cover/deepinfer-community-cover-1536.webp 1536w"
date: 2026-10-23
last_modified_at: 2026-10-23
author_name: "AgentsPulse Editorial Team"
research_scope: "Official scope · Hardware ports · Online serving · KV cache · Reproducing DeepSeek's curves · Outlook"
scope_note: "Based on all 191 pull requests and their comments in deepseek-ai/DeepInfer up to October 23, 2026, plus the README, CONTRIBUTING guide and deployment Q&A. Community numbers are self-reported by PR authors and reviewers. Apart from #157, none of these PRs is merged. We did not run the code."
dek: "DeepSeek open-sourced DeepInfer as an offline engine for one model on two chip families. In its first week the community sent 191 pull requests. Only one was merged, but the rest show where the engine is slow, how to serve it, and how far it runs beyond Blackwell."
key_takeaways:
  - "Only one of 191 PRs was merged: #157, a DeepEP bump by a maintainer. A maintainer praised the Hopper port (#92) but said DeepSeek won't merge it and the author can maintain it."
  - "In an OpenAI-compatible server (#147) on 8× B200, EPLB rebalancing took 28–51% of wall time. Turning it off raised throughput from 79,675 to 161,557 tok/s per GPU at 128 concurrency. EPLB is now off by default in that PR."
  - "A host-memory prefix cache (#144) cut median time to first token from 8.9 s to 0.59 s on a multi-turn agent trace on 4× GB300."
  - "Prefill reproductions reached 59–81% of DeepSeek's curve. PR #200 traced a silent 5–10× slowdown to an RDMA fallback; reading the Engram table from host memory brought prefill back to or above the published curve."
  - "Community ports run end to end on Hopper/H20 (#92) and AMD MI350X/MI355X (#201). Ascend 910B, RTX 5090, Apple Silicon and Intel are at RFC or early-kernel stage."
article_toc:
  - id: official-scope
    label: "Official scope"
  - id: what-the-community-is-building
    label: "PR overview"
  - id: hardware-ports
    label: "Hardware ports"
  - id: online-serving-and-eplb
    label: "Serving & EPLB"
  - id: prefix-cache-and-pd-split
    label: "KV cache & PD split"
  - id: reproducing-deepseeks-curves
    label: "Reproducing curves"
  - id: where-deepinfer-is-heading
    label: "Outlook"
  - id: what-to-use-on-your-hardware
    label: "By hardware"
  - id: deepinfer-community-faq
    label: "FAQ"
  - id: references
    label: "References"
related_research:
  - url: /tutorials/deepseek-deepinfer/
    title: "DeepInfer, Explained"
    description: "What DeepSeek's open inference engine includes, what it leaves out and how to try it."
  - url: /topics/deepinfer/
    title: "DeepInfer topic hub"
    description: "Every AgentsPulse article and update on DeepInfer."
faq_schema:
  - question: "Does DeepInfer run on H100, H200 or H20?"
    answer: "Not officially. DeepSeek supports NVIDIA Blackwell SM100 and Huawei Ascend 950. Community PR #92 runs DeepSeek-V4.1-Flash end to end on 8× and 4× H20-3e, and the author maintains it outside the main branch. On H200, upgrade its Humming dependency to 0.1.13."
  - question: "Can DeepInfer serve an OpenAI-compatible API?"
    answer: "Not in the official release, which is offline only. Community PR #147 adds a minimal /v1/chat/completions server, and #197 adds a prefill/decode split on top of it. Neither is merged."
  - question: "Why is DeepInfer slower than DeepSeek's published benchmarks?"
    answer: "Reproductions on GB300 and B200 reached 59–81% of the official prefill curve. PR #200 found that GPU-initiated RDMA for the Engram table can silently fall back to a CPU proxy and run 5–10× slower. Reading the table from host memory restored the published numbers."
  - question: "Should I turn off EPLB when serving DeepInfer?"
    answer: "For online serving, community tests say yes. On 8× B200 at 128 concurrency, EPLB rebalancing used about half of wall time and turning it off doubled throughput. PR #147 now defaults EPLB to off."
---
DeepSeek open-sourced **DeepInfer** on October 20, 2026. It is the inference engine behind DeepSeek's production services, released as an offline runtime for DeepSeek-V4.1-Flash (see our [DeepInfer explainer](/tutorials/deepseek-deepinfer/)). By October 23 the repository had about 20,500 stars and 191 pull requests. [<a href="#reference-1">1</a>] We read every PR and its discussion to see what the community changed, what it measured, and where DeepInfer looks likely to go next.

The short version: turning off one default doubled serving throughput, a prefix cache cut time to first token from 8.9 s to 0.59 s, and the engine already runs on Hopper and AMD. Almost none of this is merged.

<img src="/technical-article-writing_20261023_220622/figures/deepinfer-official-architecture.webp" width="1727" height="911" alt="DeepSeek's serving architecture for V4.1 Flash: user requests go through DeepSeek Recipe to an entrypoint, then through vision encoder, prefill and decode load balancers to their services, with an expert-parallel load balancer inside prefill and decode, and KV cache stored in external 3FS storage" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Figure 1. DeepSeek's production serving architecture, from the repository's `doc/images/architecture_overview.png`. The open release covers the engine; the load balancers and KV cache store are not fully released.* [<a href="#reference-2">2</a>]

## Official scope: two chip families, one merged PR {#official-scope}

DeepInfer officially supports NVIDIA Blackwell (SM100) and Huawei Ascend 950. The contributing guide has a separate `ci_npu` test marker, so Ascend goes through the same process as GPUs. [<a href="#reference-3">3</a>]

Two lines in the deployment Q&A sum up the repository's role. DeepSeek says inference code and performance work for future DeepSeek models will keep being open-sourced in DeepInfer. It also says KV cache management and load balancing are tightly coupled to internal infrastructure and "not yet fully open-sourced." [<a href="#reference-2">2</a>]

Of the 191 PRs, the one merged is #157 from maintainer wx-csy, which bumps DeepEP. [<a href="#reference-4">4</a>] Among outside PRs, #92 got a reply from maintainer beginlner:

> Good job! But we won't be merging it — you can maintain the code yourself.

PR #92 ports DeepInfer to Hopper. The message is clear: DeepSeek values the work, and the author maintains it. [<a href="#reference-5">5</a>] Issues are disabled on the repository, so RFCs also arrive as PRs.

## What the community is building {#what-the-community-is-building}

<img src="/technical-article-writing_20261023_220622/figures/deepinfer-pr-topics.webp" width="1501" height="840" alt="Bar chart of 191 DeepInfer pull requests by topic: other fixes 78, hardware ports 32, eval fixes 21, PD split and KV cache 19, docs and build 15, EPLB and scheduling 13, online serving 8, structured output 5" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Figure 2. DeepInfer PRs by topic, grouped by title keywords, as of October 23, 2026.* [<a href="#reference-4">4</a>]

Grouped by title, 32 PRs port hardware, 21 fix evaluation, 19 add KV caching or prefill/decode (PD) disaggregation, and 8 add online serving. Those are the gaps the official release left open.

## Hardware ports: Hopper and AMD run end to end {#hardware-ports}

| Platform | Status | PRs |
|---|---|---|
| NVIDIA Blackwell SM100 | Official | — |
| Huawei Ascend 950 | Official | — |
| NVIDIA Hopper / H20 | Runs end to end | #92, #148, #180 |
| AMD MI350X / MI355X | Runs end to end | #201 (split into #202–#206) |
| Huawei Ascend 910B / 910C | RFC and reference code | #46, #143, #152, #190 |
| NVIDIA SM120 / RTX 5090 | Experimental | #138, #210 |
| Apple Silicon (MPS) | Scaffolding and first Metal kernels | #125, #168 |
| Intel XPU / MetaX MACA | Skeleton or some operators | #67, #146, #181 |

**Hopper (#92)** is the most complete port. The author ran DeepSeek-V4.1-Flash on 8× H20-3e (141 GB) and reports: [<a href="#reference-5">5</a>]

| 8× H20-3e | Result |
|---|---|
| Time to first token, 128K input (context parallel) | 2.11 s |
| Time to first token, ~1M input | 19.4 s |
| Decode, 64 concurrent, total throughput | 4,259 tok/s |
| GSM8K (8-shot) | 0.941 |

The PR changes 56 files and adds 9,159 lines. Weights are repacked at load time, and the author checked all 47,232 expert matrices bit for bit. A reviewer testing on H200 found an alignment bug in the pinned Humming 0.1.12 dependency, fixed upstream in 0.1.13. [<a href="#reference-5">5</a>]

**AMD (#201)** targets MI350X and MI355X with a full ROCm backend. The author split it into five smaller PRs, #202 to #206, for review, then reopened the main PR. [<a href="#reference-6">6</a>]

**Ascend 910B (#152)** is an RFC with measurements. Each 910B3 card has 60.96 GiB usable. The 510 GB checkpoint grows to about 770 GB after W8A8 quantization, so the author estimates at least two 8-card machines. [<a href="#reference-7">7</a>]

**Apple Silicon (#168)** adds the first native Metal kernels. The author notes that a Mac needs roughly 128 GB of unified memory or more before local inference is more than a demo. [<a href="#reference-8">8</a>]

## Online serving: EPLB was eating half the time {#online-serving-and-eplb}

The release is an offline engine. PR #147 wraps it in a minimal OpenAI-compatible `/v1/chat/completions` server. The PD split (#197) and the benchmark reproductions (#196) build on that server. [<a href="#reference-9">9</a>]

In #147's comments, user whn09 ran a one-hour multi-turn agent trace on 8× B200 and found the server hard-coded EPLB, the expert load-balancing rearrangement, to on. Rearrangement ran every 30 steps and after every prefill. Online, nearly every request has a prefill, so it ran almost constantly. Each rearrangement took about 0.34 s, while 30 decode steps took about 0.28 s. [<a href="#reference-9">9</a>]

| Concurrency | Rearrangement share of wall time |
|---|---|
| 1 | 28% |
| 16 | 48% |
| 128 | 51% |

He reran the same trace with EPLB off:

| Concurrency 128 | EPLB on | EPLB off |
|---|---|---|
| Total throughput, tok/s per GPU | 79,675 | 161,557 |
| Per-user speed p50, tok/s | 24.6 | 111.5 |
| Time to first token p50 | 0.79 s | 0.44 s |
| End-to-end latency p50 | 18.3 s | 5.2 s |

Throughput doubled. With EPLB off, the server matched vLLM's published InferenceX B200 point for the same workload (0.97× throughput, 0.96× interactivity). The PR author, kzjeef, confirmed the result the same day and made EPLB off by default. [<a href="#reference-9">9</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261023_220622/figures/deepinfer-community-ab.webp" width="1259" height="2180">
  <img src="/technical-article-writing_20261023_220622/figures/deepinfer-community-ab-wide.webp" width="2980" height="900" alt="Three community A/B results. Engram fetch on 8× B200 at batch 4,096: default RDMA 34,840 prefill tokens per second per GPU, PR 200 host memory 62,199, above the official curve at about 60,000. Online serving on 8× B200 at concurrency 128: EPLB on 79,675, EPLB off 161,557 total tokens per second per GPU. Multi-turn agent on 4× GB300 at concurrency 1: time to first token p50 8.9 seconds without prefix cache, 0.59 seconds with PR 144 HiCache" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 3. Three community A/B tests. Numbers are self-reported in PRs #200, #147 and #144.* [<a href="#reference-9">9</a>][<a href="#reference-10">10</a>][<a href="#reference-11">11</a>]

## Prefix cache and PD split {#prefix-cache-and-pd-split}

**#144** adds a host-memory prefix cache in the style of SGLang's HiCache. On 4× GB300 with a single-concurrency multi-turn agent trace, median time to first token fell from **8.9 s to 0.59 s**, and the server finished 224 requests in an hour instead of 99. [<a href="#reference-10">10</a>]

**#197** splits prefill and decode across two GB300 trays. From concurrency 8 to 256, p90 inter-token latency stayed between 8.6 and 15 ms, where a single tray ranged from 12 to 98 ms. [<a href="#reference-12">12</a>] **#214** adds Mooncake as the KV transport. On one host its outputs were byte-identical to the TCP path at the same latency. The author's point is that cross-host transfer can then use RDMA directly. [<a href="#reference-13">13</a>]

## Reproducing DeepSeek's curves {#reproducing-deepseeks-curves}

The README publishes prefill and decode Pareto curves at 131,072 context.

<img src="/technical-article-writing_20261023_220622/figures/deepinfer-official-prefill.webp" width="1350" height="930" alt="DeepSeek's official prefill chart for V4.1 Flash on EP4DP4: non-cached input throughput rises from about 60,000 to about 89,000 tokens per second per GPU as latency per prefill step grows from about 70 to 730 milliseconds" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Figure 4. DeepSeek's official prefill curve, from the DeepInfer README.* [<a href="#reference-14">14</a>]

**#196** reproduced those sweeps and reached 64–81% of the official prefill curve on 4× GB300 and 59–69% on 4× B200. [<a href="#reference-15">15</a>]

**#200** found one cause. The Engram table fetch relies on GPU-initiated RDMA. On many cloud hosts the driver rejects the required memory registration, and DOCA falls back to a CPU proxy mode. Nothing is logged at warning level, and the fetch runs 5–10× slower. In one profiled prefill step, the fetch took 394 ms of 1,133 ms (35%). [<a href="#reference-11">11</a>]

The author switched to reading the table from shared host memory (UVA). On 8× B200, prefill and decode came back close to the official curves:

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261023_220622/figures/deepinfer-pr200-b200-mobile.webp" width="715" height="1056">
  <img src="/technical-article-writing_20261023_220622/figures/deepinfer-pr200-b200.webp" width="1430" height="528" alt="PR 200 benchmark on B200. Prefill: default Engram over RDMA stays between about 35,000 and 57,000 tokens per second per GPU, while NVLink fetch and host-memory UVA fetch reach about 60,000 to 82,000, close to the official curve. Decode: the UVA line tracks the official EP8DP8 curve much more closely than the default RDMA line" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 5. Uploaded by the PR #200 author. Blue dashed: official curve. Red: #200.* [<a href="#reference-11">11</a>]

kzjeef retested the change on a GB300 tray whose ConnectX-8 links were down, leaving one 100 Gb/s bond. Prefill came in 10–20% above DeepSeek's published curve at every batch size: [<a href="#reference-11">11</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261023_220622/figures/deepinfer-pr200-gb300-mobile.webp" width="1245" height="1800">
  <img src="/technical-article-writing_20261023_220622/figures/deepinfer-pr200-gb300.webp" width="2250" height="960" alt="PR 200 retest on 4× GB300. Prefill: main with RDMA reaches about 46,000 to 60,000 tokens per second per GPU, DeepSeek's README curve about 60,000 to 89,500, and main plus PR 200 about 70,000 to 98,000. Decode: PR 200 improves on main at high concurrency but stays below DeepSeek's EP8 and EP64 curves" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 6. From PR #200's comments, uploaded by kzjeef.* [<a href="#reference-11">11</a>]

## Where DeepInfer is heading {#where-deepinfer-is-heading}

DeepSeek's statements and the first week of PRs point to a few likely directions:

| Prediction | Evidence | Confidence |
|---|---|---|
| Main stays focused on DeepSeek models and official hardware; other hardware lives in community forks | Reply on #92; README platform list | High |
| The next big update ships with a new DeepSeek model | Deployment Q&A | High |
| Performance work lands first in DeepGEMM, DeepEP and FlashMLA, then flows in | The only merged PR bumps DeepEP | Medium-high |
| The community fills KV cache and load balancing with Mooncake, HiCache and similar | Q&A says "not yet"; 19 related PRs | Medium |
| Hopper, AMD and Ascend 910 each get a long-lived community version | #92 maintained by its author; full PR sets for AMD and Ascend | Medium |

## What to use on your hardware {#what-to-use-on-your-hardware}

- **B200, GB300 or Ascend 950:** run the official offline engine. To serve it, start from #147 and #197, and keep EPLB off. If prefill is far below the curve, check for the CPU proxy fallback in #200.
- **H20, H100 or H200:** use the #92 branch and upgrade Humming to 0.1.13.
- **AMD, Ascend 910, RTX 5090 or Mac:** these ports are early. Follow and test them, but don't plan production on them yet.
- **Production online serving today:** vLLM and SGLang still have the more complete stack.

## DeepInfer community FAQ {#deepinfer-community-faq}

### Does DeepInfer run on H100, H200 or H20?

Not officially. DeepSeek supports NVIDIA Blackwell SM100 and Huawei Ascend 950. Community PR #92 runs DeepSeek-V4.1-Flash end to end on 8× and 4× H20-3e, and the author maintains it outside the main branch. On H200, upgrade its Humming dependency to 0.1.13.

### Can DeepInfer serve an OpenAI-compatible API?

Not in the official release, which is offline only. Community PR #147 adds a minimal `/v1/chat/completions` server, and #197 adds a prefill/decode split on top of it. Neither is merged.

### Why is DeepInfer slower than DeepSeek's published benchmarks?

Reproductions on GB300 and B200 reached 59–81% of the official prefill curve. PR #200 found that GPU-initiated RDMA for the Engram table can silently fall back to a CPU proxy and run 5–10× slower. Reading the table from host memory restored the published numbers.

### Should I turn off EPLB when serving DeepInfer?

For online serving, community tests say yes. On 8× B200 at 128 concurrency, EPLB rebalancing used about half of wall time and turning it off doubled throughput. PR #147 now defaults EPLB to off.

## References {#references}

1. <span id="reference-1"></span>deepseek-ai/DeepInfer. [Repository](https://github.com/deepseek-ai/DeepInfer): about 20,500 stars and 2,200 forks as of 23 October 2026.
2. <span id="reference-2"></span>deepseek-ai/DeepInfer. [`doc/inference_deployment_qa.md`](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/inference_deployment_qa.md) and [architecture diagram](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/images/architecture_overview.png). GitHub.
3. <span id="reference-3"></span>deepseek-ai/DeepInfer. [`CONTRIBUTING.md`](https://github.com/deepseek-ai/DeepInfer/blob/main/CONTRIBUTING.md). GitHub.
4. <span id="reference-4"></span>deepseek-ai/DeepInfer. [Pull requests](https://github.com/deepseek-ai/DeepInfer/pulls?q=is%3Apr), including [#157](https://github.com/deepseek-ai/DeepInfer/pull/157). Accessed 23 October 2026.
5. <span id="reference-5"></span>DarkraiHL. [#92: SM90 (Hopper) support](https://github.com/deepseek-ai/DeepInfer/pull/92), with comments. GitHub.
6. <span id="reference-6"></span>vivienfanghuagood. [#201: AMD ROCm backend for MI350X/MI355X](https://github.com/deepseek-ai/DeepInfer/pull/201). GitHub.
7. <span id="reference-7"></span>wangzhao-11a. [#152: RFC, Ascend 910B (A2) support](https://github.com/deepseek-ai/DeepInfer/pull/152). GitHub.
8. <span id="reference-8"></span>lucifer-holly. [#168: Apple Silicon (MPS) support](https://github.com/deepseek-ai/DeepInfer/pull/168). GitHub.
9. <span id="reference-9"></span>kzjeef. [#147: minimal OpenAI-compatible chat server](https://github.com/deepseek-ai/DeepInfer/pull/147), including whn09's EPLB measurements in the comments. GitHub.
10. <span id="reference-10"></span>kzjeef. [#144: host-memory prefix cache](https://github.com/deepseek-ai/DeepInfer/pull/144). GitHub.
11. <span id="reference-11"></span>JohnQin-llm. [#200: opt-in UVA Engram fetch](https://github.com/deepseek-ai/DeepInfer/pull/200), with kzjeef's GB300 retest in the comments. GitHub.
12. <span id="reference-12"></span>kzjeef. [#197: prefill/decode split over two hosts](https://github.com/deepseek-ai/DeepInfer/pull/197). GitHub.
13. <span id="reference-13"></span>whn09. [#214: Mooncake KV transport](https://github.com/deepseek-ai/DeepInfer/pull/214). GitHub.
14. <span id="reference-14"></span>deepseek-ai/DeepInfer. [README](https://github.com/deepseek-ai/DeepInfer) and [`prefill_pareto.png`](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/images/prefill_pareto.png). GitHub.
15. <span id="reference-15"></span>kzjeef. [#196: README benchmark reproductions on 4× GB300 and 4× B200](https://github.com/deepseek-ai/DeepInfer/pull/196). GitHub.
