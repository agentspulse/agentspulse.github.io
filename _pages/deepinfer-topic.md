---
layout: topic-sky
permalink: /topics/deepinfer/
title: "DeepInfer Release Tracker: Versions, Hardware and Changelog (2026)"
display_title: "DeepInfer Release Tracker"
description: "DeepInfer releases so far: public since Oct 20 2026, V4.1-Flash on SM100 and Ascend 950, Apache-2.0, offline only, plus what each update changed."
lede: "Every DeepInfer update in one place: release dates, supported models and hardware, merged changes, and the community ports still waiting for review."
lang: en
sitemap: true
date: 2026-10-20
last_modified_at: 2026-10-30
topic_name: "DeepInfer"
topic_tag: deepinfer
parent_topic_title: "DeepSeek"
parent_topic_url: /topics/deepseek/
about_type: "SoftwareSourceCode"
about_url: "https://github.com/deepseek-ai/DeepInfer"
about_license: "https://www.apache.org/licenses/LICENSE-2.0"
og_image: "/technical-article-writing_20261020_183325/figures/cover/deepinfer-cover-1280.webp"
articles_title: "Deep dives"
compact_cards: true
card_labels:
  deepseek-deepinfer: "Architecture, serving scope and what stays internal"
  deepinfer-benchmarks: "Community benchmark reproductions and hardware ports"
facts:
  - label: "Latest state"
    value: "Main branch, no tagged versions"
  - label: "Supported model"
    value: "DeepSeek-V4.1-Flash"
    url: /tutorials/deepseek-v4-1-flash-1017/
  - label: "Hardware"
    value: "NVIDIA SM100 · Ascend 950"
  - label: "Release scope"
    value: "Offline inference"
---

*Status as of October 30, 2026. This page is updated when the main branch, supported hardware or release scope changes.*

## DeepInfer release history {#release-history}

DeepInfer has had one public release so far, on October 20, 2026, and no numbered versions since. The project ships from its main branch: as of October 30 there are no tags and no release entries, so "the latest version" means the latest commit on main.

| Date | Release | Model | Hardware | Scope | Repository / commit |
|---|---|---|---|---|---|
| Oct 20, 2026 | Initial public release, Apache-2.0 | DeepSeek-V4.1-Flash (default checkpoint `DeepSeek-V4.1-Flash-1017`) | NVIDIA SM100 (CUDA 13), Huawei Ascend 950 (CANN 9.2) | Offline inference | [deepseek-ai/DeepInfer](https://github.com/deepseek-ai/DeepInfer), `d585e65` |
| Oct 20, 2026 | Deployment Q&A, Chinese and English | — | — | Docs only | `8b16149`, `774ce24` |
| Oct 21, 2026 | Dependency update (#157) | unchanged | unchanged | unchanged | `9bd9cf2` |
| Oct 25, 2026 | Strict boolean env-var parsing (#218) | unchanged | unchanged | unchanged | `5537415` |

Two dates get mixed up in coverage. The repository was created on October 16, but its history starts with an "initial commit" on October 20, which is when the code became public. We use October 20 as the release date.

Only two community pull requests have been merged in the first ten days:

- **#157, merged Oct 21.** Moves the bundled DeepEP dependency to commit `f6aa38fe` and drops an SSH-to-HTTPS URL rewrite in the build. It does not change model or hardware support.
- **#218, merged Oct 25.** Boolean `DEEPINFER_*` environment variables are now parsed strictly. A value such as `yes` or a typo used to be read silently; it now raises an error. If a launch script that worked on October 20 fails after updating, check these variables first.

Main was last pushed on October 26. Anything you read about SM90, AMD, Apple silicon or an HTTP server refers to open pull requests, not to the release.

## Supported models and hardware {#supported-models-and-hardware}

The release supports one model on two accelerator families. Everything else in the table below is a community port in an open pull request, and maintainers have not merged any of them.

| Target | Status | Where it stands |
|---|---|---|
| DeepSeek-V4.1-Flash | **Supported** | The only model; default checkpoint `deepseek-ai/DeepSeek-V4.1-Flash-1017` |
| NVIDIA SM100 (B200, GB200) | **Supported** | CUDA 13; the only platform with batch-invariant mode and deterministic sampling |
| Huawei Ascend 950 | **Supported** | CANN 9.2 |
| NVIDIA SM90 (H100, H200, H20) | Open PRs #92, #148, #180 | A maintainer said on #92 that they "won't be merging" SM90 support |
| NVIDIA SM120 (RTX 50 series) | Open PRs #138, #210 | Experimental; #210 targets a single RTX 5090 with an FP8 adaptation |
| AMD MI350X / MI355X | Open PR #201 | ROCm backend for V4.1-Flash |
| Huawei Ascend 910B / 910C | Open PRs #46, #152, #190 | RFCs; #190 also adds groundwork for DeepSeek-V4-0731 |
| Intel XPU | Open PRs #67, #146 | RFC plus a platform skeleton |
| Apple silicon (MPS / Metal) | Open PRs #125, #168 | Scaffolding and first Metal kernels |
| MetaX MACA | Open PR #181 | Opt-in reference operators |

All supported setups need Linux, GCC 13 or newer and Python 3.12. The H100 is not supported, which surprises many readers because it is the most common data-center GPU. SM100 means compute capability 10.0, the Blackwell data-center class.

Scale also matters. The published benchmarks used 4 SM100 GPUs for prefill and 64 for decode. DeepSeek's deployment guide says one prefill plus one decode instance works, but the efficient minimum is about 64 cards for each stage. DeepInfer can run the example script on a single node; it is not a desktop tool.

Only DeepSeek-V4.1-Flash is listed. The README says future DeepSeek models will be supported, but gives no model names or dates.

## DeepInfer changelog {#changelog}

Dated entries, newest first. Pull request counts come from the repository's pull request list.

**Oct 27–30, 2026: bug-fix PRs, still unmerged.** New PRs are now mostly fixes rather than ports. #241 raises when the engine rejects a request in `LLM.generate`. #244 fails loudly when per-prompt list lengths do not match. #245 fixes the source distribution build. #249 reports a crash on short prompts in indexed attention. None were merged by October 30.

**Oct 28–29, 2026: Engram data-path tuning.** #246 adds an opt-in LocalEngram fetch over NVLink, and #248 lets users override the Engram RDMA queue-pair settings. Both follow #200 (Oct 22), which traced slow community reproductions to the Engram RDMA fallback.

**Oct 26, 2026: last push to main.** No commits landed on main between October 26 and October 30.

**Oct 25, 2026: #218 merged.** Strict parsing for boolean environment variables. This is the only change to engine code since release.

**Oct 23, 2026: serving work appears.** #214 adds a Mooncake Transfer Engine KV transport for a prefill/decode split, and #216 stacks a Mooncake Store L3 tier on the host prefix cache from #144. Together with #147 (a minimal OpenAI-compatible chat server) and #197 (prefill/decode across two hosts), they fill parts of the serving stack DeepSeek kept internal. All are open. Our [community benchmark reproductions](/tutorials/deepinfer-benchmarks/) cover their measured results.

**Oct 22, 2026: AMD and consumer GPUs.** #201 adds a ROCm backend for MI350X and MI355X, and #210 adapts the model for a single RTX 5090. #200 adds an opt-in UVA Engram fetch for single-node runs, aimed at community reproductions that reached only 59–81% of the official prefill curve.

**Oct 21, 2026: #157 merged, hardware ports flood in.** 73 new PRs in one day, including SM90 (#148, #180), SM120 (#138), Apple silicon (#168), Ascend 910B (#152, #190), Intel XPU (#146) and MACA (#181). #196 documents reproductions on 4× GB300 and 4× B200.

**Oct 20, 2026: public release.** Initial commit and the deployment Q&A in Chinese and English. 98 pull requests were opened on the first day, the first of them RFCs for Ascend 910C (#46), Intel XPU (#67) and SM90 (#92).

**Oct 16, 2026: repository created.** It stayed private until October 20.

### Activity snapshot {#activity-snapshot}

| Metric | Oct 20 | Oct 23 | Oct 30 |
|---|---|---|---|
| Stars | 4,320 | ~20,500 | 24,391 |
| Pull requests opened | 98 | 191 | 224 |
| Pull requests merged | 0 | 1 | 2 |
| Forks | 329 | — | 2,934 |

New PRs fell from 98 on day one to between one and eight a day after October 24. With 203 PRs still open, the backlog is now the main thing to watch: a merged hardware port or serving PR would be the first real change in scope.

## What is not in the open-source release {#not-in-the-release}

DeepInfer is the engine from DeepSeek's production stack, not the whole stack. Three pieces that a self-hosted API needs are missing:

- a KV cache system for prefix reuse across requests,
- orchestration that splits vision encoding, prefill and decode across machines,
- load balancing across data-parallel replicas.

There is also no HTTP server. Request formatting lives in a separate library, deepseek-recipe, which turns chat requests into token IDs and back but leaves inference and serving to you. For how these pieces fit together and why DeepSeek kept them out, see our [explainer on DeepInfer's architecture and open-source boundaries](/tutorials/deepseek-deepinfer/).

## What to watch next {#what-to-watch}

- **The first tagged version.** There are no tags yet; a tag would show which state of main DeepSeek considers stable.
- **A second model.** The README promises future DeepSeek models. A new checkpoint would most likely land as a model directory plus kernel changes.
- **A merged hardware port.** SM90 has been declined once. AMD, Ascend 910B/910C and RTX 50 PRs are the next candidates.
- **Serving pieces.** If #147 (OpenAI-compatible server) or the prefill/decode split PRs merge, the release scope changes from offline inference only.

Sources: DeepInfer README, commit log and pull request list (checked October 30, 2026); DeepSeek V4.1 Flash Inference Deployment Q&A.
