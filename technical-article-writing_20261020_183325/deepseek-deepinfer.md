---
layout: article-sky
article_variant: research-review
review_eyebrow: "Release analysis"
zoomable_images: true
lang: en
title: "DeepInfer: DeepSeek's Open-Source Inference Engine for V4.1 Flash, Explained"
seo_title: "DeepInfer: DeepSeek's Open Inference Engine"
description: "DeepInfer is the engine behind DeepSeek's production serving, now open source. See what it runs, the hardware it needs, what was left out and how to try it."
keywords: "DeepInfer, DeepSeek DeepInfer, DeepSeek inference engine, deepseek v4 flash, DeepSeek-V4.1-Flash, deepseek self host, run deepseek locally, DeepEP, expert parallelism, deepseek-recipe"
tags: [deepseek, open-source, inference, agent-infrastructure]
categories: [frontier-research]
permalink: /tutorials/deepseek-deepinfer/
thumbnail: "/technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-1280.webp"
og_image: "/technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-1280.webp"
cover_alt: "Illustration of a glowing layered engine core resting on a pedestal in front of a faint wireframe server rack with an empty slot, representing a production inference engine released on its own"
cover_width: 1280
cover_height: 720
cover_srcset: "/technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-640.webp 640w, /technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-1280.webp 1280w, /technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-1536.webp 1536w"
date: 2026-10-20
last_modified_at: 2026-10-20
author_name: "AgentsPulse Editorial Team"
research_scope: "Release scope · Hardware · Engine features · Benchmarks · Getting started"
scope_note: "Based on the DeepInfer repository at commit 8b16149, DeepSeek's deployment Q&A and Zhihu post, the deepseek-recipe README and DeepSeek's 2025 open-sourcing note. We did not run DeepInfer; chart values are read from DeepSeek's published plots."
dek: "In 2025 DeepSeek said its inference engine was too tied to internal systems to open-source. DeepInfer is that engine, released as an offline runtime for one model on two chip families. The parts that turn it into a service stay inside DeepSeek."
key_takeaways:
  - "DeepInfer is the inference framework behind DeepSeek's production services. The open release runs offline inference for DeepSeek-V4.1-Flash only, on NVIDIA SM100 (Blackwell B200/GB200-class) GPUs or Huawei Ascend 950 NPUs, under Apache-2.0."
  - "It is not a drop-in server. The README lists three things a full service still needs: a KV cache system, vision-encoder/prefill/decode disaggregation and load balancing across data-parallel replicas."
  - "Inside are DeepSeek's kernel libraries (FlashMLA, DeepGEMM, DeepEP and others), attention data parallelism with MoE expert parallelism, DSpark speculative decoding with confidence-scheduled verification, SWA bounded replay, an asynchronous scheduler, batch-invariant inference and structured outputs."
  - "DeepSeek's charts show roughly 89K prefill tokens/s per GPU on 4 GPUs and about 26K decode tokens/s per GPU on 64 GPUs at 131K context. The decode figure assumes a fixed 75% draft acceptance rate rather than measuring it."
article_toc:
  - id: from-wont-open-source-to-deepinfer
    label: "Why it matters"
  - id: what-ships-and-what-stays-inside-deepseek
    label: "Release scope"
  - id: hardware-and-model-one-model-two-chip-families
    label: "Hardware & model"
  - id: inside-the-engine
    label: "Engine features"
  - id: performance-deepseeks-charts-and-production-claims
    label: "Performance"
  - id: trying-it-build-first-run-and-checks
    label: "Getting started"
  - id: deepinfer-vs-vllm-and-sglang
    label: "vs vLLM & SGLang"
  - id: deepinfer-faq
    label: "FAQ"
  - id: references
    label: "References"
related_research:
  - url: /tutorials/deepseek-v4-1-flash-1017/
    title: "DeepSeek V4.1 Flash 1017"
    description: "The model DeepInfer serves: benchmarks, pricing and the Search/Fetch API."
  - url: /tutorials/deepseek-harness-modes-explained/
    title: "DeepSeek Harness Modes Explained"
    description: "Standard, PTC, Minimal and Creator modes compared by tools and boundaries."
faq_schema:
  - question: "What is DeepInfer?"
    answer: "DeepInfer is DeepSeek's high-performance inference framework, the one behind its large-scale production services. The open-source release, under Apache-2.0, provides offline inference for DeepSeek-V4.1-Flash on NVIDIA SM100 GPUs and Huawei Ascend 950 NPUs."
  - question: "Can I use DeepInfer to self-host a DeepSeek API server?"
    answer: "Not on its own. The release is offline inference only. DeepSeek lists three missing pieces for a complete service: a KV cache system, vision-encoder/prefill/decode disaggregation, and load balancing across data-parallel replicas. deepseek-recipe handles API-protocol-to-token conversion, but you still provide HTTP serving and routing."
  - question: "What hardware does DeepInfer need?"
    answer: "NVIDIA SM100 GPUs (compute capability 10.0, the B200 and GB200 class) with CUDA 13, or Huawei Ascend 950 NPUs with CANN 9.2. It also needs Linux, GCC 13 or newer and Python 3.12. Earlier GPUs such as the H100 are not listed as supported."
  - question: "Which models does DeepInfer support?"
    answer: "Only DeepSeek-V4.1-Flash at release. The default checkpoint is deepseek-ai/DeepSeek-V4.1-Flash-1017. DeepSeek says inference code for future DeepSeek models will also be released in DeepInfer."
  - question: "Is DeepInfer based on vLLM?"
    answer: "Partly. The README says it was originally built primarily on vLLM, with inspiration from SGLang and TensorRT-LLM, and files such as the LLM entry point are marked as derived from vLLM. It is a separate engine, not a vLLM plugin."
---
**DeepInfer** is the inference framework that powers DeepSeek's large-scale production services, now released as open source under Apache-2.0. The public version runs **offline inference for DeepSeek-V4.1-Flash** on NVIDIA SM100 GPUs and Huawei Ascend 950 NPUs. It bundles DeepSeek's kernel libraries, parallelism, speculative decoding and scheduler into one engine. [<a href="#reference-1">1</a>] The repository was created on October 16, 2026 and had 4,320 GitHub stars four days later. [<a href="#reference-3">3</a>]

DeepSeek says this is the same framework behind its V4.1 Flash production serving. It reports one cluster processing 155 trillion tokens a day, with revenue of $38 per GPU-hour at off-peak (valley) prices. [<a href="#reference-2">2</a>] Those are DeepSeek's figures, not independent measurements. The repository is narrower than a full serving stack: you get the engine, not the cache, routing and disaggregation layer around it.

## From "we won't open-source it" to DeepInfer {#from-wont-open-source-to-deepinfer}

In April 2025, DeepSeek explained why it would not release its internal inference engine. The engine was an early fork of vLLM, heavily customized for DeepSeek models. It was tightly coupled to internal cluster tools, and a small research team lacked the bandwidth to maintain it. DeepSeek said it would contribute standalone libraries and optimizations to existing projects instead. [<a href="#reference-4">4</a>]

DeepInfer reverses the headline decision while keeping the original reasoning. The README still credits vLLM as the original base, with ideas from SGLang and TensorRT-LLM. Files like the `LLM` entry point carry a "Derived from vLLM; modified by DeepSeek" header. [<a href="#reference-1">1</a>] The parts most tied to internal infrastructure, KV cache management and load balancing, are exactly the parts left out. DeepSeek's deployment Q&A says this directly: those components are "tightly coupled to our internal infrastructure" and not yet fully open-sourced. [<a href="#reference-2">2</a>]

The libraries DeepSeek released in 2025 now plug into this engine. They include FlashMLA for attention, DeepGEMM for matrix multiplication and DeepEP for expert-parallel communication. With DeepInfer, you can see how DeepSeek wires them together for a real model.

## What ships, and what stays inside DeepSeek {#what-ships-and-what-stays-inside-deepseek}

DeepSeek's production system for V4.1 Flash splits each request into three stages on separate machines. A vision encoder handles images, prefill processes the prompt, and decode generates tokens. A separate storage tier keeps KV cache for reuse. [<a href="#reference-2">2</a>] Four load balancers spread work across replicas and experts: one each for prefill, decode, the vision encoder and expert parallelism. The KV cache lives on DeepSeek's 3FS file system, about 100 PiB of SSD, with a three-day TTL for agent traffic. [<a href="#reference-2">2</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261020_183325/figures/deepinfer-architecture-mobile.webp" width="840" height="2160">
  <img src="/technical-article-writing_20261020_183325/figures/deepinfer-architecture.webp" width="2000" height="1080" alt="Serving stack for DeepSeek V4.1 Flash: an API request goes through deepseek-recipe, which is open, then through prefill, decode, vision-encoder and expert-parallel load balancers, which are not released, to the open DeepInfer engine. The engine calls open kernel libraries FlashMLA, DeepGEMM and DeepEP on NVIDIA SM100 or Ascend 950 hardware, and reads KV cache from a 3FS store kept 72 hours or more, which is not released" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 1. Solid boxes are open source; dashed links lead to parts DeepSeek kept internal.* [<a href="#reference-1">1</a>][<a href="#reference-2">2</a>][<a href="#reference-5">5</a>]

The open release covers the middle of that picture. The README lists what a complete inference service still needs: [<a href="#reference-1">1</a>]

- **A KV cache system.** There is no equivalent of the 3FS-backed store, so prefix reuse across requests over hours or days is up to you.
- **Vision-encoder/prefill/decode disaggregation.** The README notes that "most required engine functionality is already implemented," but the orchestration that moves requests and KV cache between stages is not included.
- **Load balancing across data-parallel replicas** for both prefill and decode. In DeepSeek's production setup, attention uses DP with `#DP=#EP`, so imbalance across replicas directly hurts effective utilization. DeepSeek reports that its balancers reach about 80% of a perfectly balanced offline benchmark. [<a href="#reference-2">2</a>]

The other half of the release is **deepseek-recipe**, a Rust library with Python bindings. It converts Messages, Chat Completions and Responses requests into a conversation and renders V4/V4.1 prompts to token IDs, then parses the output back. The caller supplies inference, tool execution and HTTP. [<a href="#reference-5">5</a>] It is the piece to use if you want a self-hosted endpoint to format prompts the same way DeepSeek's API does. HTTP serving, routing and caching are still yours to build.

## Hardware and model: one model, two chip families {#hardware-and-model-one-model-two-chip-families}

DeepInfer supports exactly one model, DeepSeek-V4.1-Flash. The default checkpoint is `deepseek-ai/DeepSeek-V4.1-Flash-1017`, the October 17 update covered in our [V4.1 Flash 1017 analysis](/tutorials/deepseek-v4-1-flash-1017/). [<a href="#reference-1">1</a>][<a href="#reference-10">10</a>] It supports two hardware targets:

| | NVIDIA | Huawei |
|---|---|---|
| Accelerator | SM100 GPUs | Ascend 950 NPUs |
| Toolkit | CUDA 13 | CANN 9.2 |
| Kernel libraries | FlashMLA, DeepGEMM, DeepEP, TileKernels, DeepSelect, TileLang | Ascend variants of DeepEP and DeepGEMM, plus TileLang ops |
| Batch-invariant mode and deterministic sampling | Yes | No |

SM100 is NVIDIA's compute capability 10.0, the B200 and GB200 class of Blackwell data-center GPUs. [<a href="#reference-9">9</a>] Hopper GPUs such as the H100 are not on the list. Both platforms need Linux, GCC 13 or newer and Python 3.12. [<a href="#reference-1">1</a>]

So if you searched for a way to "run DeepSeek locally," DeepInfer is not a desktop tool. DeepSeek's own deployment guidance puts prefill on 8-accelerator machines and decode on 64- to 128-card scale-up domains. It also says that 1 prefill plus 1 decode instance works, but that the efficient minimum is 64 cards for prefill plus 64 for decode. [<a href="#reference-2">2</a>] The examples do run on a single 8-GPU node with `--ep 8`, which is the realistic starting point for evaluation. [<a href="#reference-6">6</a>]

## Inside the engine {#inside-the-engine}

DeepInfer is easiest to read as layers. deepseek-recipe sits above it. The engine handles scheduling, sampling and parallelism, and DeepSeek's kernel libraries sit below on the two chip families.

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261020_183325/figures/deepinfer-layers-mobile.webp" width="840" height="1598">
  <img src="/technical-article-writing_20261020_183325/figures/deepinfer-layers.webp" width="2000" height="1120" alt="Layer diagram of DeepInfer. Top layer, not released: load balancing, KV cache store and E/P/D orchestration. Then deepseek-recipe for API protocol to tokens; the engine runtime with async scheduler, sampler, DSpark verification and structured outputs; model and parallelism with V4.1 Flash, attention DP and CP, MoE EP plus EPLB and SWA bounded replay; kernel libraries FlashMLA, DeepGEMM, DeepEP, TileKernels, DeepSelect and TileLang; and hardware, NVIDIA SM100 with CUDA 13 or Huawei Ascend 950 with CANN 9.2" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 2. What each layer of the release contains, from the parts left out down to the chips.* [<a href="#reference-1">1</a>][<a href="#reference-5">5</a>]

### Parallelism: data-parallel attention, wide expert parallelism

Attention runs data-parallel, and the MoE experts are sharded with expert parallelism (EP) and rebalanced by EPLB. For long prompts there is an option for balanced context parallelism (CP). [<a href="#reference-1">1</a>] In DeepSeek's production deployment the data-parallel size equals the expert-parallel size (`#DP=#EP`). [<a href="#reference-2">2</a>] In production, DeepSeek uses EP2–8 for prefill, choosing the smallest that fits in memory. For decode it uses "Wide-EP" at EP64–128, as large as the hardware allows, because spreading experts over more GPUs cuts per-step memory traffic for the MoE layers. Tensor parallelism and context parallelism are not used in production. [<a href="#reference-2">2</a>] The examples show the knobs: `--ep 8`, `--ep 2 --dp 8` and `--ep 2 --cp 8`. [<a href="#reference-6">6</a>]

### DSpark and confidence-scheduled verification

DSpark is V4.1 Flash's speculative decoding: a draft proposes several tokens and the main model verifies them. Verifying a fixed number of draft tokens wastes work on tokens likely to be rejected. DeepInfer adds a confidence head that predicts the chance each draft token will be accepted. The scheduler then verifies only the prefix of draft tokens that maximizes expected throughput on the measured hardware curve. [<a href="#reference-2">2</a>] DeepSeek reports that this cuts verified tokens per step by about 30%, from 5.00 to 3.2–4.4. Mean accepted length barely moves (3.29 vs 3.20). DeepSeek estimates this is worth 4–7% more throughput at its production operating point of about 60 concurrent requests per rank on EP64. [<a href="#reference-2">2</a>] Enable it with `DEEPINFER_ENABLE_MTP_VARLEN=1`. `DEEPINFER_USE_NEXTN_DECODE` caps the draft length, which defaults to 5. [<a href="#reference-1">1</a>]

### SWA bounded replay

V4.1 Flash keeps a sliding-window attention (SWA) cache alongside its main KV cache. Rebuilding that window exactly after a cache hit would mean rerunning thousands of tokens through every decoder layer. Bounded replay recomputes only the last 128 tokens of the prompt, so the cost is constant regardless of context length. DeepSeek says this nearly halves total prefill compute on the decoder side. [<a href="#reference-2">2</a>] The default V4.1 setting keeps 140 tokens: the window plus room for speculative backtracking. Set it with `DEEPINFER_YOCO_PREFILL_TRUNCATION_MODE=compact` and `DEEPINFER_YOCO_PREFILL_KEEP_TOKENS=140`. [<a href="#reference-1">1</a>] The repository includes a script that checks the compact mode against the exact mask mode, down to logprobs. [<a href="#reference-11">11</a>]

### Zero-overhead asynchronous scheduling

A plain decode loop leaves the GPU idle while the CPU post-processes one step and schedules the next. DeepInfer overlaps the two. While the GPU runs forward and sampling for step N, the CPU schedules and launches step N+1 and post-processes step N−1. DeepSeek credits SGLang and NanoFlow for the approach. [<a href="#reference-2">2</a>] The scheduler is on by default. [<a href="#reference-1">1</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261020_183325/figures/deepinfer-async-scheduling-mobile.webp" width="840" height="2052">
  <img src="/technical-article-writing_20261020_183325/figures/deepinfer-async-scheduling.webp" width="2000" height="1120" alt="Timeline comparing a synchronous decode loop, where the GPU sits idle while the CPU post-processes step N and schedules step N+1, with DeepInfer's asynchronous scheduling, where the CPU schedules step N+1 and post-processes step N-1 while the GPU runs step N, so GPU steps run back to back" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 3. Asynchronous scheduling hides CPU work behind GPU work. Schematic, not to scale.* [<a href="#reference-2">2</a>]

This interacts with DSpark. When the CPU schedules step N+1, the confidence scores from step N are not back yet. So the CPU sets only a total verification budget, and a TileLang kernel on the GPU decides each request's length. [<a href="#reference-2">2</a>]

### Reproducibility and structured outputs

Two options target reproducible results, both NVIDIA-only. `DEEPINFER_BATCH_INVARIANT=1` keeps a request's results identical no matter what else is in the batch. Adding `DEEPINFER_ENABLE_MTP_VARLEN=0` and a fixed `seq_seed` in `SamplingParams` makes sampling deterministic for identical inputs. [<a href="#reference-1">1</a>] Structured outputs constrain generation to a regex, JSON schema or EBNF grammar through `so_args`. In production, DeepSeek compiles those grammars on separate machines so compilation never blocks the engine. [<a href="#reference-1">1</a>][<a href="#reference-2">2</a>]

## Performance: DeepSeek's charts and production claims {#performance-deepseeks-charts-and-production-claims}

The README publishes two throughput-versus-latency curves for V4.1 Flash at a 131,072-token context. Both were measured inside one scale-up domain: 4 SM100 GPUs for prefill and 64 for decode. [<a href="#reference-1">1</a>] The values below are read from those charts, so treat them as approximate.

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261020_183325/figures/deepinfer-pareto-mobile.webp" width="840" height="2290">
  <img src="/technical-article-writing_20261020_183325/figures/deepinfer-pareto.webp" width="2000" height="1120" alt="Two charts redrawn from DeepSeek's README. Prefill on 4 GPUs: throughput rises from about 60K to 89K tokens per second per GPU as step latency grows from about 70 to 730 milliseconds. Decode on 64 GPUs: per-GPU throughput falls from about 26K to 2.6K tokens per second as per-user speed rises from about 100 to 325 tokens per second" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 4. Approximate values redrawn from DeepSeek's [prefill](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/images/prefill_pareto.png) and [decode](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/images/decode_pareto.png) charts. Decode axes assume 3.25 tokens per step.* [<a href="#reference-1">1</a>][<a href="#reference-8">8</a>]

- **Prefill (EP4, DP4).** Throughput rises from about 60K to about 89K non-cached tokens per second per GPU as the batch grows from 4,096 to 65,536 tokens per rank. Step latency grows from about 70 ms to about 730 ms over the same range.
- **Decode (EP64, DP64).** At 256 requests per rank, the chart shows about 26K tokens per second per GPU, at roughly 100 tokens per second per user. At 8 requests per rank, per-user speed rises to about 325 tokens per second, while per-GPU throughput falls to about 2.6K.

The decode axes come from a model, not a token count. The plotting script scales both axes by an expected tokens-per-step factor of 1 + nextn × acceptance. The published chart uses three draft tokens and an assumed 75% acceptance rate, a factor of 3.25. [<a href="#reference-8">8</a>] Real throughput depends on how often drafts are actually accepted on your traffic.

Two more caveats come from DeepSeek. Its internal FlashMLA includes a hand-tuned SASS optimization that the public version lacks. That makes the open decoding kernel 5–10% slower, and end-to-end performance can differ by up to 5%. The internal draft model is also slightly newer, though DeepSeek says the performance gap is small. [<a href="#reference-2">2</a>]

For accuracy, the `eval/` directory reproduces Pass@1 on three benchmarks. The reference scores are 99.9% on AIME 2026, 93.4% on GPQA Diamond and 42.6% on HLE-Full. The README calls them "indicative rather than exact": a sanity check that a deployment is configured correctly, not a leaderboard claim. [<a href="#reference-7">7</a>]

## Trying it: build, first run and checks {#trying-it-build-first-run-and-checks}

On a supported machine, the README path is short. Create an empty Python 3.12 environment, then run: [<a href="#reference-1">1</a>]

```bash
export DEEPINFER_ACCELERATOR=nvidia   # or: ascend
./build.sh
python examples/offline_inference.py
```

The first run downloads `DeepSeek-V4.1-Flash-1017` into the Hugging Face cache. Set `DEEPINFER_HF_MODEL_DIR` to use a local copy instead. [<a href="#reference-1">1</a>] Some useful next steps from the examples: [<a href="#reference-6">6</a>]

1. **Pick a parallel layout.** Try `--ep 8` on one 8-GPU node, or `--ep 2 --dp 8` and `--ep 2 --cp 8` to compare data and context parallelism.
2. **Check outputs, not just speed.** `--check_structured_output` runs regex, JSON and EBNF checks after the sample generations. The test suite compares perplexity against stored baselines.
3. **Benchmark your own curve.** `examples/benchmark.py` prints prefill and decode throughput. `examples/sweep/run_sweep.sh` reproduces the Pareto charts. Pass the draft acceptance rate you actually observe instead of 0.75.
4. **Validate accuracy.** Run the `eval/` scripts and compare with the reference Pass@1 scores.

The API surface is vLLM-style. You create an `LLM` object and call `generate()` with `SamplingParams`, offline and in-process. [<a href="#reference-1">1</a>] Serving it over HTTP is your job, with deepseek-recipe handling the protocol-to-token step.

## DeepInfer vs vLLM and SGLang {#deepinfer-vs-vllm-and-sglang}

DeepInfer shares ancestry with vLLM, but it serves a different purpose than general serving frameworks.

| | DeepInfer | vLLM / SGLang |
|---|---|---|
| Models | DeepSeek-V4.1-Flash only | Many model families |
| Mode | Offline inference engine | Engine plus OpenAI-compatible server |
| Hardware | NVIDIA SM100, Ascend 950 | Broad GPU support |
| Strength | DeepSeek's production kernels and parallel layout for this model | Breadth, serving features, community |
| Missing for production | KV cache system, E/P/D orchestration, DP load balancing | Depends on deployment |

If you need an API endpoint for V4.1 Flash today on hardware DeepInfer doesn't list, a general framework is the practical route. DeepInfer is most useful to teams that run Blackwell or Ascend 950 at scale and want DeepSeek's reference configuration. It also helps framework maintainers who want to port DeepSeek's choices, from DSpark scheduling to bounded replay, into their own stacks. DeepSeek also says inference code for future models will ship in DeepInfer, which makes the repository worth watching as a reference even if you never deploy it directly. [<a href="#reference-2">2</a>]

## DeepInfer FAQ {#deepinfer-faq}

### What is DeepInfer?

DeepInfer is DeepSeek's high-performance inference framework, the one behind its large-scale production services. The open-source release, under Apache-2.0, provides offline inference for DeepSeek-V4.1-Flash on NVIDIA SM100 GPUs and Huawei Ascend 950 NPUs.

### Can I use DeepInfer to self-host a DeepSeek API server?

Not on its own. The release is offline inference only. DeepSeek lists three missing pieces for a complete service: a KV cache system, vision-encoder/prefill/decode disaggregation, and load balancing across data-parallel replicas. deepseek-recipe handles API-protocol-to-token conversion, but you still provide HTTP serving and routing.

### What hardware does DeepInfer need?

NVIDIA SM100 GPUs (compute capability 10.0, the B200 and GB200 class) with CUDA 13, or Huawei Ascend 950 NPUs with CANN 9.2. It also needs Linux, GCC 13 or newer and Python 3.12. Earlier GPUs such as the H100 are not listed as supported.

### Which models does DeepInfer support?

Only DeepSeek-V4.1-Flash at release. The default checkpoint is `deepseek-ai/DeepSeek-V4.1-Flash-1017`. DeepSeek says inference code for future DeepSeek models will also be released in DeepInfer.

### Is DeepInfer based on vLLM?

Partly. The README says it was originally built primarily on vLLM, with inspiration from SGLang and TensorRT-LLM, and files such as the `LLM` entry point are marked as derived from vLLM. It is a separate engine, not a vLLM plugin.

## References

1. <span id="reference-1"></span>deepseek-ai/DeepInfer. [README](https://github.com/deepseek-ai/DeepInfer) and [`deepinfer/entrypoints/llm.py`](https://github.com/deepseek-ai/DeepInfer/blob/main/deepinfer/entrypoints/llm.py). GitHub, commit 8b16149, accessed 20 October 2026.
2. <span id="reference-2"></span>DeepSeek. [“DeepSeek V4.1 Flash Inference Deployment Q&A”](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/inference_deployment_qa.md) in the DeepInfer repository (English edition, commit 774ce24), and [“DeepSeek V4.1 Flash 大规模推理部署实践”](https://zhuanlan.zhihu.com/p/2095560295930508953). Zhihu, October 2026. In Chinese.
3. <span id="reference-3"></span>deepseek-ai/DeepInfer. [Repository metadata](https://github.com/deepseek-ai/DeepInfer): Apache-2.0, 4,320 stars and 329 forks as of 20 October 2026, 10:40 UTC.
4. <span id="reference-4"></span>DeepSeek. [“The Path to Open-Sourcing the DeepSeek Inference Engine.”](https://github.com/deepseek-ai/open-infra-index/blob/main/OpenSourcing_DeepSeek_Inference_Engine/README.md) open-infra-index, GitHub, April 2025.
5. <span id="reference-5"></span>deepseek-ai/deepseek-recipe. [README](https://github.com/deepseek-ai/deepseek-recipe). GitHub, accessed 20 October 2026.
6. <span id="reference-6"></span>deepseek-ai/DeepInfer. [`examples/README.md`](https://github.com/deepseek-ai/DeepInfer/blob/main/examples/README.md). GitHub, commit 8b16149.
7. <span id="reference-7"></span>deepseek-ai/DeepInfer. [`eval/README.md`](https://github.com/deepseek-ai/DeepInfer/blob/main/eval/README.md). GitHub, commit 8b16149.
8. <span id="reference-8"></span>deepseek-ai/DeepInfer. [`examples/sweep/plot_pareto.py`](https://github.com/deepseek-ai/DeepInfer/blob/main/examples/sweep/plot_pareto.py) and [`run_sweep.sh`](https://github.com/deepseek-ai/DeepInfer/blob/main/examples/sweep/run_sweep.sh). GitHub, commit 8b16149.
9. <span id="reference-9"></span>NVIDIA. [“CUDA GPU Compute Capability.”](https://developer.nvidia.com/cuda/gpus) Accessed 20 October 2026.
10. <span id="reference-10"></span>AgentsPulse. [“DeepSeek V4.1 Flash 1017: What Changed, Benchmarks, Pricing and the New Search API.”](/tutorials/deepseek-v4-1-flash-1017/)
11. <span id="reference-11"></span>deepseek-ai/DeepInfer. [`examples/yoco/README.md`](https://github.com/deepseek-ai/DeepInfer/blob/main/examples/yoco/README.md). GitHub, commit 8b16149.
