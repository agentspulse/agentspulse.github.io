---
layout: article-sky
article_variant: research-review
review_eyebrow: "Release analysis"
zoomable_images: true
lang: en
title: "DeepSeek V4.1 Flash 1017: What Changed, Benchmarks, Pricing and the New Search API"
seo_title: "DeepSeek V4.1 Flash 1017: Benchmarks & Pricing"
description: "DeepSeek V4.1 Flash 1017 replaces the model behind deepseek-flash at the same price. See the benchmark gains, peak pricing, Search/Fetch API and weights."
keywords: "DeepSeek V4.1 Flash 1017, DeepSeek-V4.1-Flash-1017, deepseek-flash, deepseek v4 flash, deepseek api pricing, deepseek search api, DeepSeek Fetch API"
tags: [deepseek, model-releases, agent-infrastructure, evaluations]
categories: [frontier-research]
permalink: /tutorials/deepseek-v4-1-flash-1017/
thumbnail: "/technical-article-writing_20261019_145705/figures/cover/deepseek-1017-cover-1280.webp"
og_image: "/technical-article-writing_20261019_145705/figures/cover/deepseek-1017-cover-1280.webp"
cover_alt: "Illustration of a glowing new core module seated in an unchanged hardware socket, with a faint outline of the previous module behind it and two thin lines reaching to floating cards, representing a new model behind the same name and new web tools"
cover_width: 1280
cover_height: 720
cover_srcset: "/technical-article-writing_20261019_145705/figures/cover/deepseek-1017-cover-640.webp 640w, /technical-article-writing_20261019_145705/figures/cover/deepseek-1017-cover-1280.webp 1280w, /technical-article-writing_20261019_145705/figures/cover/deepseek-1017-cover-1536.webp 1536w"
date: 2026-10-19
last_modified_at: 2026-10-19
author_name: "AgentsPulse Editorial Team"
research_scope: "Model routing · Benchmarks · Pricing · Search & Fetch · Open weights"
scope_note: "Based on DeepSeek's API docs, change log and release note, the Hugging Face model card, and independent results from Artificial Analysis and Vals AI. We did not run the model ourselves."
dek: "DeepSeek swapped a new checkpoint in behind the deepseek-flash model name on October 17. Per-token prices did not move. What changed is how much work the model does per token, plus a pair of pay-per-call web tools that agents can now use directly."
key_takeaways:
  - "DeepSeek-V4.1-Flash-1017 now serves every deepseek-flash request on the web, the app and the API. The model name, calling method and prices are unchanged, so existing code picks it up without edits."
  - "DeepSeek reports gains on all 11 benchmarks in its table, the largest on Terminal-Bench 4.0 (31.2 to 42.3). It still trails Claude Opus 5 on seven of the eleven, including HLE, ProgramBench and NL2Repo-Bench."
  - "Any saving comes from fewer tokens per task, not a lower rate. Artificial Analysis measured 210M output tokens on its index versus 250M for the September model, and a cost per task of $0.26 versus $0.49."
  - "The new Search and Fetch APIs cost $0.75 per 1,000 successful requests each. Calls made through server-side tools in DeepSeek Harness, Claude Code and Codex are free until October 31, 2026, 16:00 UTC."
article_toc:
  - id: one-model-name-a-new-checkpoint
    label: "What 1017 replaces"
  - id: what-the-benchmarks-say
    label: "Benchmarks"
  - id: same-price-fewer-tokens-per-task
    label: "Pricing"
  - id: search-and-fetch-web-access-as-two-plain-apis
    label: "Search & Fetch API"
  - id: open-weights-and-the-parameter-count-question
    label: "Open weights"
  - id: should-you-change-anything
    label: "What to change"
  - id: deepseek-v4-1-flash-1017-faq
    label: "FAQ"
  - id: references
    label: "References"
related_research:
  - url: /tutorials/deepseek-harness-modes-explained/
    title: "DeepSeek Harness Modes Explained"
    description: "Standard, PTC, Minimal and Creator modes compared by tools and boundaries."
  - url: /tutorials/coding-agents-finops-cost-per-successful-task/
    title: "Coding Agents Enter the FinOps Era"
    description: "Why cost per successful task matters more than price per token."
faq_schema:
  - question: "What is DeepSeek V4.1 Flash 1017?"
    answer: "It is an October 17, 2026 checkpoint of DeepSeek-V4.1-Flash that DeepSeek calls a minor update. It now serves the deepseek-flash model on DeepSeek's website, app and API, with higher reported benchmark scores and shorter outputs than the September release."
  - question: "Do I need to change my code to use DeepSeek V4.1 Flash 1017?"
    answer: "No. The model name deepseek-flash and the API calling method are unchanged, so requests are served by 1017 automatically. The legacy names deepseek-v4-flash and deepseek-v4-flash-vision-exp are also served by 1017 at the Flash price. Requests to deepseek-v4-pro still go to a different model, DeepSeek-V4-Pro-0813."
  - question: "How much does DeepSeek V4.1 Flash 1017 cost?"
    answer: "Per million tokens at peak rates: $0.006 for cache-hit input, $0.30 for cache-miss input and $1.20 for output. Off-peak rates are half. Peak hours are 01:00 to 04:00 and 06:00 to 10:00 UTC, Monday through Friday, excluding Chinese public holidays."
  - question: "What are the DeepSeek Search and Fetch APIs?"
    answer: "Two standalone JSON endpoints. POST /v1/tools/search returns web results for a query, optionally with page content, and POST /v1/tools/fetch returns one page's title and content as Markdown. Each costs $0.75 per 1,000 successful requests."
  - question: "Are the DeepSeek V4.1 Flash 1017 weights open?"
    answer: "Yes. The weights are on Hugging Face and ModelScope under the MIT license. The release has no Jinja chat template; DeepSeek ships a Python reference encoder and the deepseek-recipe toolkit for prompt formatting instead."
---
**DeepSeek V4.1 Flash 1017** (full name DeepSeek-V4.1-Flash-1017) is a new checkpoint of DeepSeek's V4.1 Flash model, released on October 17, 2026. It now answers every request sent to the `deepseek-flash` model on the DeepSeek website, app and API. DeepSeek calls it a minor update and reports higher scores, faster task completion and shorter outputs than the September release, at the same per-token price. [<a href="#reference-1">1</a>][<a href="#reference-2">2</a>]

That combination is why this release deserves a close read. You do not opt in to 1017; if you call `deepseek-flash`, you are already on it. So the practical questions are what changed under the same name, how much of the improvement signal holds outside DeepSeek's own table, and what "cheaper per task" means on a real bill. The same announcement also opened two web tools, Search and Fetch, as paid APIs any developer can call.

## One model name, a new checkpoint

The October 17 change log entry is short: V4.1 Flash "has been upgraded to DeepSeek-V4.1-Flash-1017," the web and app models were updated at the same time, and "the API calling method and pricing remain unchanged." [<a href="#reference-1">1</a>] Nothing new is added to the model list. The Models & Pricing page now shows `DeepSeek-V4.1-Flash-1017` as the version behind `deepseek-flash`, with a 1M-token context window, up to 384K output tokens, thinking mode on by default and a non-thinking mode available. [<a href="#reference-3">3</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_145705/figures/deepseek-model-routing-mobile.webp" width="840" height="1810">
  <img src="/technical-article-writing_20261019_145705/figures/deepseek-model-routing.webp" width="2000" height="1040" alt="Model-name routing on the DeepSeek API: calls in OpenAI or Anthropic format to deepseek-flash and to the legacy names deepseek-v4-flash and deepseek-v4-flash-vision-exp are all served by DeepSeek-V4.1-Flash-1017 at the Flash price, which also powers web and app chat; deepseek-v4-pro stays on DeepSeek-V4-Pro-0813 at the Pro price, without vision" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 1. After October 17, every Flash name, current or legacy, lands on 1017. Only `deepseek-v4-pro` reaches a different model.* [<a href="#reference-1">1</a>][<a href="#reference-3">3</a>]

### Old names still work, but not all of them reach 1017

The September V4.1 Flash launch retired V4 Flash and V4 Flash Vision Exp. Their names were kept for compatibility, and the pricing page now says requests to `deepseek-v4-flash` and `deepseek-v4-flash-vision-exp` "are served by the DeepSeek-V4.1-Flash-1017 model and billed at the Flash price." [<a href="#reference-3">3</a>] DeepSeek describes these as accepted legacy names, so new code should use `deepseek-flash`.

`deepseek-v4-pro` is different. It maps to DeepSeek-V4-Pro-0813, a separate model with its own, higher price, and the pricing page marks it as not supporting vision. [<a href="#reference-3">3</a>] In September DeepSeek had announced that V4 Pro traffic would be routed to V4.1 Flash from September 14; the change log for the same release says V4 Pro continues to be served after that date with billing unchanged, and the current pricing page lists it as its own model. [<a href="#reference-4">4</a>][<a href="#reference-1">1</a>] If you pinned `deepseek-v4-pro`, 1017 does not reach you.

Both API formats are unchanged: `https://api.deepseek.com` for OpenAI-style calls and `https://api.deepseek.com/anthropic` for Anthropic-style calls. JSON output, tool calls, the Responses API and vision are all listed for `deepseek-flash`. [<a href="#reference-3">3</a>]

## What the benchmarks say

DeepSeek's model card compares 1017 with the September V4.1 Flash and four other models on 11 benchmarks. Every row goes up, by 2.0 to 11.1 points. The same table is the first image in DeepSeek's launch post on X. [<a href="#reference-2">2</a>][<a href="#reference-13">13</a>]

| Benchmark | 1017 | V4.1 Flash (Sept) | Claude Opus 5 | GPT-5.6 Sol |
|---|---:|---:|---:|---:|
| Terminal-Bench 4.0 | 42.3 | 31.2 | 51.8 | 39.9 |
| DeepSWE v1.1 | 77.0 | 74.2 | 74.0 | 73.0 |
| ProgramBench | 29.1 | 20.3 | 37.0 | 23.0 |
| NL2Repo-Bench | 68.2 | 65.4 | 75.3 | 56.8 |
| Automation-Bench v1.0.6 | 60.5 | 54.8 | 50.3 | 45.8 |
| Agents' Last Exam | 35.4 | 31.8 | 28.6 | 26.7 |
| Apex Bench v1.1 | 72.1 | 64.6 | 65.8 | 54.3 |
| HLE (no tools) | 42.6 | 36.8 | 56.3 | 44.5 |
| Chartography (with tools) | 83.0 | 78.9 | 84.0 | 79.9 |
| BabyVision (with tools) | 92.5 | 89.6 | 94.1 | 88.9 |
| ZeroBench-main (with tools) | 51.0 | 49.0 | 52.0 | 53.0 |

*Scores as reported by DeepSeek. The card also lists Kimi K3 and GLM-5.3. HLE text-only subset: 44.0 for 1017 and 39.1 for the September model.* [<a href="#reference-2">2</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_145705/figures/deepseek-1017-benchmarks-mobile.webp" width="840" height="1810">
  <img src="/technical-article-writing_20261019_145705/figures/deepseek-1017-benchmarks.webp" width="2000" height="1040" alt="Dot plot of eleven benchmarks on a 0 to 100 scale comparing DeepSeek-V4.1-Flash-1017, the September V4.1 Flash and Claude Opus 5; 1017 is above the September model on every row and above Opus 5 on DeepSWE, Automation-Bench, Agents' Last Exam and Apex Bench" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 2. DeepSeek's benchmark table redrawn as dots so it stays readable on a phone. 1017 (blue) moves right of the September model (gray) on every row, but Opus 5 (amber) is still further right on seven of eleven. DeepSeek-reported scores; the original image is in the launch post.* [<a href="#reference-2">2</a>][<a href="#reference-13">13</a>]

The biggest jumps are on agentic coding and long tasks: Terminal-Bench 4.0 (+11.1), ProgramBench (+8.8) and Apex Bench (+7.5). Against Claude Opus 5, the picture is mixed. 1017 leads on DeepSWE, Automation-Bench, Agents' Last Exam and Apex Bench, and trails on the other seven, by wide margins on HLE (42.6 vs 56.3), Terminal-Bench 4.0 and ProgramBench. "Beats Opus 5" is true for some rows, not for the model.

### Harness choices matter

DeepSeek ran Terminal-Bench 4.0 with the Claude Code harness and DeepSWE v1.1 with the Mini-SWE-V2 harness. [<a href="#reference-2">2</a>] Agent benchmarks measure model and scaffold together, so a different harness can produce a different number. Vals AI, which runs its own setup with DeepSeek as the provider and maximum reasoning effort, lists 1017 at 31.82% on Terminal-Bench 4.0 and 56.58% on its composite Vals Index, ranked 14th of 50. [<a href="#reference-5">5</a>] The two Terminal-Bench numbers are not a contradiction to resolve; they are a reminder to test the model inside the agent you actually run.

### What independent testing confirms

The clearest independent signal here is output length. Artificial Analysis scores 1017 (Max reasoning) at 45 on its Intelligence Index, up from 39 for the September V4.1 Flash. Running the index took 210M output tokens, down from 250M, and the average cost per task fell from $0.49 to $0.26 at the same $0.30 / $1.20 token prices. [<a href="#reference-6">6</a>][<a href="#reference-7">7</a>] That supports DeepSeek's shorter-output claim on one independent workload. It does not mean your agent will see the same reduction, and Artificial Analysis still rates 1017 as "very verbose" against a 140M median.

## Same price, fewer tokens per task

1017 is billed exactly like the model it replaced. Prices are per million tokens, and off-peak rates are half of peak. [<a href="#reference-3">3</a>]

| `deepseek-flash` (1017) | Off-peak | Peak |
|---|---:|---:|
| Input, cache hit | $0.003 | $0.006 |
| Input, cache miss | $0.15 | $0.30 |
| Output | $0.60 | $1.20 |

For comparison, `deepseek-v4-pro` costs $0.66 / $1.32 for cache-miss input and $1.98 / $3.96 for output (off-peak / peak). Concurrency limits are 2,500 for `deepseek-flash` and 500 for `deepseek-v4-pro`. [<a href="#reference-3">3</a>]

### When peak pricing applies

Peak hours are 01:00 to 04:00 and 06:00 to 10:00 UTC, Monday through Friday. Everything else is off-peak, including weekends and Chinese public holidays in full. [<a href="#reference-3">3</a>] In Beijing time that is 09:00 to 12:00 and 14:00 to 18:00 on working days, which is why batch jobs scheduled for evenings or weekends cost half as much.

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_145705/figures/deepseek-peak-hours-mobile.webp" width="840" height="1810">
  <img src="/technical-article-writing_20261019_145705/figures/deepseek-peak-hours.webp" width="2000" height="1040" alt="Weekly grid of DeepSeek API pricing by UTC hour: peak, full-price blocks fall Monday to Friday from 01:00 to 04:00 and 06:00 to 10:00 UTC; all other hours, weekends and Chinese public holidays are off-peak at half price" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 3. Peak pricing covers 35 of the 168 hours in a week without public holidays. A batch job that runs outside those blocks pays half.* [<a href="#reference-3">3</a>]

### A worked example

Take an agent run that reads 2M input tokens, 90% of them cache hits, and writes 200K output tokens. At peak rates that is 1.8M × $0.006 + 0.2M × $0.30 + 0.2M × $1.20 = **$0.31**, and output is about three quarters of it. Off-peak, the same run costs **$0.16**. Because output dominates, a model that finishes the same task in fewer output tokens lowers the bill even when the rate card does not change. That is the mechanism behind the Artificial Analysis cost drop above, and why cost per completed task is a better comparison than price per token. [<a href="#reference-8">8</a>]

## Search and Fetch: web access as two plain APIs

Alongside 1017, DeepSeek opened two web tools to all API users, powered by its in-house search engine. Both are raw JSON APIs with the same bearer-token authentication as the chat API. [<a href="#reference-9">9</a>]

- **Search**: `POST https://api.deepseek.com/v1/tools/search`. The `query` field is required (1 to 128 characters) and supports operators such as `site:` and `-site:`. `count` sets the number of results, from 1 to 50 (default 10). `need_content` returns page content with each result (default `false`). Optional `ori_question` passes the user's original question, and `localization` takes an IP address to localize results.
- **Fetch**: `POST https://api.deepseek.com/v1/tools/fetch`. The body has one field, `url`, which must be an HTTP or HTTPS URL of at most 8,192 characters without a username or password. The response holds the page `title` and its `content` as Markdown. [<a href="#reference-10">10</a>]

```bash
curl https://api.deepseek.com/v1/tools/search \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "DeepSeek V4 release", "count": 5, "need_content": true}'
```

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_145705/figures/deepseek-search-fetch-mobile.webp" width="840" height="1810">
  <img src="/technical-article-writing_20261019_145705/figures/deepseek-search-fetch.webp" width="2000" height="1040" alt="Search and Fetch in an agent loop: the agent sends a query to POST /v1/tools/search and gets results with title, url and summary, sends a url to POST /v1/tools/fetch and gets the page as Markdown, then passes that text to deepseek-flash; each endpoint is billed at $0.75 per 1,000 successful requests" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 4. Search and Fetch are separate tools your agent calls; the model only sees the text you pass back. Each endpoint bills per successful request.* [<a href="#reference-9">9</a>][<a href="#reference-10">10</a>]

### What it costs, and the free window

Search and Fetch are billed per successful request: $0.75 per 1,000 for each endpoint. [<a href="#reference-3">3</a>] When you use the DeepSeek API through DeepSeek Harness, Claude Code or Codex, their server-side tool calls are currently free; billing starts on October 31, 2026, at 16:00 UTC (00:00 on November 1, Beijing time). [<a href="#reference-1">1</a>][<a href="#reference-3">3</a>] Calls you make to the endpoints yourself are billed from day one.

DeepSeek's launch post says 1017 is optimized for DeepSeek Harness, Tencent CodeBuddy, WorkBuddy and other tools, and recommends DeepSeek Harness v0.2.1-rc.1 or later. [<a href="#reference-13">13</a>] The follow-up pre-release, v0.2.1-rc.2, lists support for 1017 and for the Search and Fetch APIs, which can be switched on in Harness's web search settings. [<a href="#reference-1">1</a>][<a href="#reference-11">11</a>] Both are release candidates. For how Harness modes differ in which tools they expose, see our [DeepSeek Harness modes explainer](/tutorials/deepseek-harness-modes-explained/).

## Open weights and the parameter-count question

The 1017 weights are on Hugging Face and ModelScope under the MIT license, tagged for image and text input. [<a href="#reference-2">2</a>] DeepSeek attributes the gains to reinforcement learning with self-feedback on end-to-end projects, and its release note shows demos from a 3D model of the Forbidden City to a Portal 2 recreation in Godot. [<a href="#reference-1">1</a>]

Running it yourself takes more than a `from_pretrained` call. The release has no Jinja chat template. Prompt formatting lives in a Python reference implementation (`encoding/encoding.py`) and in deepseek-recipe, a set of Rust libraries with Python bindings that convert Messages, Chat Completions and Responses requests into DeepSeek's prompt format and parse the output back. Inference itself is documented in the repository's `inference` folder. DeepSeek recommends `temperature` 1.0, `top_p` 1.0 and `max_tokens` of at least 256K. [<a href="#reference-2">2</a>]

### 552B or 763B?

The size depends on which source you read. DeepSeek's September launch post describes V4.1 Flash as a 552B-parameter MoE with 8B active parameters for input and 16B for output. [<a href="#reference-4">4</a>] The Hugging Face metadata for the 1017 repository counts 763.2B parameters across its safetensors files, most of them stored as 8-bit integers (557.2B) and FP8 (204.0B). [<a href="#reference-12">12</a>] DeepSeek has not explained the gap, and file-level counts can include components that a headline figure leaves out. Plan hardware from the files you will actually load.

## Should you change anything?

| If you… | What 1017 means for you |
|---|---|
| Call `deepseek-flash` | Already on 1017. Re-run your own evals, since output length and behavior changed. |
| Use `deepseek-v4-flash` or `-vision-exp` | Also on 1017 at the Flash price. Move to `deepseek-flash` before the legacy names go away. |
| Pinned `deepseek-v4-pro` | Still on V4-Pro-0813 at Pro prices. Compare 1017 on your tasks before switching. |
| Run DeepSeek Harness | Upgrade to v0.2.1-rc.1 or later; rc.2 adds the Search/Fetch setting. |
| Build your own agent | Search and Fetch are $0.75 per 1,000 calls each, billed from the first call. |
| Self-host | MIT weights; use the reference encoder or deepseek-recipe, not a chat template. |

There is no version pin for the September checkpoint in the API model list, so teams that need reproducible behavior should log the model version their requests ran on and keep an eval set they can rerun when DeepSeek swaps the model again.

## DeepSeek V4.1 Flash 1017 FAQ {#deepseek-v4-1-flash-1017-faq}

### What is DeepSeek V4.1 Flash 1017?

It is an October 17, 2026 checkpoint of DeepSeek-V4.1-Flash that DeepSeek calls a minor update. It now serves the deepseek-flash model on DeepSeek's website, app and API, with higher reported benchmark scores and shorter outputs than the September release.

### Do I need to change my code to use DeepSeek V4.1 Flash 1017?

No. The model name deepseek-flash and the API calling method are unchanged, so requests are served by 1017 automatically. The legacy names deepseek-v4-flash and deepseek-v4-flash-vision-exp are also served by 1017 at the Flash price. Requests to deepseek-v4-pro still go to a different model, DeepSeek-V4-Pro-0813.

### How much does DeepSeek V4.1 Flash 1017 cost?

Per million tokens at peak rates: $0.006 for cache-hit input, $0.30 for cache-miss input and $1.20 for output. Off-peak rates are half. Peak hours are 01:00 to 04:00 and 06:00 to 10:00 UTC, Monday through Friday, excluding Chinese public holidays.

### What are the DeepSeek Search and Fetch APIs?

Two standalone JSON endpoints. POST /v1/tools/search returns web results for a query, optionally with page content, and POST /v1/tools/fetch returns one page's title and content as Markdown. Each costs $0.75 per 1,000 successful requests.

### Are the DeepSeek V4.1 Flash 1017 weights open?

Yes. The weights are on Hugging Face and ModelScope under the MIT license. The release has no Jinja chat template; DeepSeek ships a Python reference encoder and the deepseek-recipe toolkit for prompt formatting instead.

## References

1. <span id="reference-1"></span>DeepSeek. [“Change Log”](https://api-docs.deepseek.com/updates/) (entries of 10 September and 17 October 2026) and [“DeepSeek-V4.1-Flash-1017: Wish-Driven Programming Made Real”](https://api-docs.deepseek.com/news/news261017/). DeepSeek API Docs, 17 October 2026.
2. <span id="reference-2"></span>DeepSeek-AI. [“DeepSeek-V4.1-Flash-1017” model card](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017). Hugging Face, 17 October 2026.
3. <span id="reference-3"></span>DeepSeek. [“Models & Pricing.”](https://api-docs.deepseek.com/quick_start/pricing/) DeepSeek API Docs, accessed 19 October 2026.
4. <span id="reference-4"></span>DeepSeek. [“Introducing DeepSeek-V4.1-Flash: smarter, faster, more efficient.”](https://www.deepseek.com/en/news/deepseek-v4-1-flash/) DeepSeek news, 9 September 2026.
5. <span id="reference-5"></span>Vals AI. [“DeepSeek V4.1 Flash 1017” model results](https://www.vals.ai/models/deepseek_deepseek-v4.1-flash-1017). Accessed 19 October 2026.
6. <span id="reference-6"></span>Artificial Analysis. [“DeepSeek V4.1 Flash 1017 (Max): Intelligence, Performance & Price Analysis.”](https://artificialanalysis.ai/models/deepseek-v4-1-flash-1017) Accessed 19 October 2026.
7. <span id="reference-7"></span>Artificial Analysis. [“DeepSeek V4.1 Flash (Max): Intelligence, Performance & Price Analysis.”](https://artificialanalysis.ai/models/deepseek-v4-1-flash) Accessed 19 October 2026.
8. <span id="reference-8"></span>AgentsPulse. [“Coding Agents Enter the FinOps Era: Cost per Successful Task.”](/tutorials/coding-agents-finops-cost-per-successful-task/)
9. <span id="reference-9"></span>DeepSeek. [“Search & Fetch” guide](https://api-docs.deepseek.com/guides/search/). DeepSeek API Docs, accessed 19 October 2026.
10. <span id="reference-10"></span>DeepSeek. [“Fetch” API reference](https://api-docs.deepseek.com/api/fetch/). DeepSeek API Docs, accessed 19 October 2026.
11. <span id="reference-11"></span>deepseek-ai/deepseek-harness. [Releases: dsh-v0.2.1-rc.1 and dsh-v0.2.1-rc.2](https://github.com/deepseek-ai/deepseek-harness/releases). GitHub, October 2026.
12. <span id="reference-12"></span>Hugging Face. [Model API metadata for deepseek-ai/DeepSeek-V4.1-Flash-1017](https://huggingface.co/api/models/deepseek-ai/DeepSeek-V4.1-Flash-1017) (safetensors parameter counts). Accessed 19 October 2026.
13. <span id="reference-13"></span>DeepSeek (@deepseek_ai). [“DeepSeek-V4.1-Flash-1017 is here!”](https://x.com/deepseek_ai/status/2111375640717033777) X, 17 October 2026. Launch thread; includes the benchmark table and a DeepSWE v1.1 cost chart.
