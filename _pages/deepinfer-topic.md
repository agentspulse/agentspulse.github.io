---
layout: topic-sky
permalink: /topics/deepinfer/
title: "DeepInfer Updates, Releases, GitHub Activity, and Resources"
seo_title: "DeepInfer Updates, GitHub & Resources"
description: "Track DeepInfer releases, important GitHub changes, official deployment sources, ecosystem projects, and carefully selected technical analysis."
lang: en
sitemap: true
topic_name: "DeepInfer"
topic_tag: deepinfer
parent_topic_title: "DeepSeek"
parent_topic_url: /topics/deepseek/
---

## Current project boundary

[DeepInfer](https://github.com/deepseek-ai/DeepInfer) is DeepSeek's open-source inference framework. The initial public scope supports offline inference for DeepSeek-V4.1-Flash on NVIDIA SM100 GPUs and Huawei Ascend 950 NPUs. It is not a complete serving stack: the public release does not include a KV-cache service, vision-encoder/prefill/decode orchestration, or data-parallel load balancing.

For the architecture, hardware requirements, benchmark caveats, and first-run path, start with [our complete DeepInfer explainer](/tutorials/deepseek-deepinfer/).

## Update log

### October 2026 — DeepInfer becomes public

DeepSeek released the engine code under Apache-2.0 with V4.1 Flash support, optimized kernels, attention and expert parallelism, DSpark verification, bounded replay, asynchronous scheduling, deterministic options, and structured outputs. The release also documents which production-serving components remain internal.

Primary sources: [DeepInfer repository](https://github.com/deepseek-ai/DeepInfer), [deployment Q&A](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/inference_deployment_qa.md), and [examples](https://github.com/deepseek-ai/DeepInfer/tree/main/examples).

## Sources we follow

- [DeepInfer GitHub repository](https://github.com/deepseek-ai/DeepInfer): code, README, examples, evaluation, and release history.
- [DeepSeek inference deployment Q&A](https://github.com/deepseek-ai/DeepInfer/blob/main/doc/inference_deployment_qa.md): production architecture and open-source boundaries.
- [deepseek-recipe](https://github.com/deepseek-ai/deepseek-recipe): request-to-token formatting for DeepSeek models.
- DeepSeek kernel projects including [FlashMLA](https://github.com/deepseek-ai/FlashMLA), [DeepGEMM](https://github.com/deepseek-ai/DeepGEMM), and [DeepEP](https://github.com/deepseek-ai/DeepEP).

## What we are watching

- Support for additional DeepSeek models and accelerator generations.
- Public equivalents for KV-cache storage, stage disaggregation, and load balancing.
- Measured differences between the public engine and DeepSeek's production deployment.
- Independent implementation reports and technically substantive comparisons with vLLM, SGLang, and TensorRT-LLM.

External analysis is added only when it contributes evidence beyond the official documentation. Routine commits remain in the source history rather than being repeated here.
