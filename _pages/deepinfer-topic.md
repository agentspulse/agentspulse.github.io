---
layout: topic-sky
permalink: /topics/deepinfer/
title: "DeepInfer Release Tracker: Versions, Hardware, and Ecosystem"
seo_title: "DeepInfer Release Tracker & Ecosystem Updates"
description: "Track DeepInfer releases, supported models and hardware, serving-scope changes, and noteworthy ecosystem implementations."
lede: "Release and ecosystem updates for DeepSeek's inference engine, including supported models, hardware, serving scope, and notable ports."
lang: en
sitemap: true
date: 2026-10-20
last_modified_at: 2026-10-27
topic_name: "DeepInfer"
topic_tag: deepinfer
parent_topic_title: "DeepSeek"
parent_topic_url: /topics/deepseek/
about_type: "SoftwareSourceCode"
about_url: "https://github.com/deepseek-ai/DeepInfer"
about_license: "https://www.apache.org/licenses/LICENSE-2.0"
repo_url: "https://github.com/deepseek-ai/DeepInfer"
repo_label: "deepseek-ai/DeepInfer"
og_image: "/technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-1280.webp"
facts:
  - label: "License"
    value: "Apache-2.0"
  - label: "Supported model"
    value: "DeepSeek-V4.1-Flash"
    url: /tutorials/deepseek-v4-1-flash-1017/
  - label: "Hardware"
    value: "NVIDIA SM100 · Ascend 950"
  - label: "Release scope"
    value: "Offline inference"
timeline:
  - date: 2026-10-16
    title: "Initial public release: V4.1 Flash, SM100 and Ascend 950, Apache-2.0"
    url: "https://github.com/deepseek-ai/DeepInfer"
sources:
  - name: "DeepInfer repository"
    url: "https://github.com/deepseek-ai/DeepInfer"
    description: "Code, README, examples, evaluation, and release history."
  - name: "Inference deployment Q&A"
    url: "https://github.com/deepseek-ai/DeepInfer/blob/main/doc/inference_deployment_qa.md"
    description: "Production architecture and open-source boundaries."
  - name: "deepseek-recipe"
    url: "https://github.com/deepseek-ai/deepseek-recipe"
    description: "Request-to-token formatting for DeepSeek models."
  - name: "FlashMLA"
    url: "https://github.com/deepseek-ai/FlashMLA"
    description: "Attention kernels used by the engine."
  - name: "DeepGEMM"
    url: "https://github.com/deepseek-ai/DeepGEMM"
    description: "GEMM kernels used by the engine."
  - name: "DeepEP"
    url: "https://github.com/deepseek-ai/DeepEP"
    description: "Expert-parallel communication library."
---
