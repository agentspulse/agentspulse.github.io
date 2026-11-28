---
layout: article-sky
article_variant: research-review
lang: en
title: "Claude Opus 5.6: How to Tell If Claude Code Is Routing You to It"
seo_title: "Claude Opus 5.6: Status, Routing Test and Release Date"
description: "Claude Opus 5.6 is unannounced, but testers say Opus 5.5 requests reach it. How to run the knowledge-cutoff test properly, what demos show, launch signals."
keywords: "claude opus 5.6, opus 5.6, opus 5.6 release date, claude code opus 5.6, sonnet 5.6"
tags: [anthropic, claude, claude-code, model-releases]
categories: [frontier-research]
permalink: /tutorials/claude-opus-5-6/
thumbnail: "/images/claude-opus-5-6/cover.jpg"
og_image: "/images/claude-opus-5-6/cover.jpg"
date: 2026-11-28
last_modified_at: 2026-11-28
author_name: "AgentsPulse Editorial Team"
cover_alt: "Video frame posted on X by @notjazii on November 24, 2026 and labelled as Opus 5.6 output: a photorealistic white pelican riding a red bicycle with a basket of baguettes along a seaside promenade, with the caption Home with breakfast"
cover_width: 1200
cover_height: 675
zoomable_images: true
review_eyebrow: "Status check"
research_scope: "Claude Platform Docs models overview and Anthropic's Claude Opus 5.5 launch post · @notjazii's November 24 post on X · MindStudio (Nov 25), Emergent (Nov 27) and Medium (Nov 27) write-ups of the testing reports, with TestingCatalog's reporting as relayed by them · Memeburn and Crypto Briefing (Nov 25–26) read via search excerpts, all read November 28, 2026"
scope_note: "Anthropic has said nothing about Opus 5.6. Every capability claim here comes from testers' posts and third-party write-ups, and no demo can prove which model produced it. The Opus 5.5 specs come from Anthropic's docs. We did not get routed to a new model ourselves and ran no tests. Cover: frame from @notjazii's post on X."
dek: "Since November 24, some Claude Code and claude.ai users say their Opus 5.5 requests come back from a stronger, unannounced model they call Opus 5.6. Anthropic has published no name, model ID, price or system card. Here is what is confirmed, how to run the knowledge-cutoff test that people use to check, why its most-shared example can't separate the two models, and which signals will mark a real launch."
key_takeaways:
  - "Claude Opus 5.6 is not released. Anthropic's docs still list Claude Opus 5.5 (claude-opus-5-5, $4/$20 per million tokens) as the newest Opus, and no 5.6 model ID exists."
  - "The reports started on November 24: testers say a stronger model answers some Opus 5.5 requests in Claude Code and claude.ai, reportedly via an 'Opus 5.5 Extra' route. Access is patchy."
  - "The common check is a knowledge-cutoff test with search and tools off. Opus 5.5's reliable knowledge cutoff is June 2026, so only facts from after June 2026 can tell the models apart; the widely cited May 2026 example cannot."
  - "Demos (three.js scenes, SVG animations) look stronger than same-prompt Opus 5.5 runs, but at least one viral 'Opus 5.6' video was fake, and a demo never proves which model made it."
  - "The rumored $2/$10 price matches Sonnet 5.5's list price and has no source. A real launch will bring an announcement, model ID, system card and pricing together."
article_toc:
  - id: "is-claude-opus-5-6-released"
    label: "Is it released?"
  - id: "claude-opus-5-6-rumors"
    label: "What testers report"
  - id: "claude-code-opus-5-6-test"
    label: "The routing test"
  - id: "opus-5-6-vs-opus-5-5"
    label: "vs Opus 5.5"
  - id: "sonnet-5-6"
    label: "Sonnet 5.6 and price"
  - id: "opus-5-6-release-date"
    label: "Release date"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/claude-opus-5-5-pricing/"
    title: "Claude Opus 5.5 pricing"
    description: "What each effort level costs per task on the current Opus."
  - url: "/tutorials/claude-fable-5-2/"
    title: "Claude Fable 5.2"
    description: "Anthropic's most recent launch, priced above Opus 5.5."
  - url: "/tutorials/gemini-4-neon-benchmarks/"
    title: "Gemini 4 Neon benchmarks"
    description: "The Google model Opus 5.5 is measured against this month."
---

Claude Opus 5.6 has not been announced, yet since November 24 a growing number of Claude Code and claude.ai users say some of their Opus 5.5 requests are being answered by a stronger model. The posts that started it show code-generated 3D scenes and animations labelled "opus 5.6", and the most common way people check is a one-line knowledge-cutoff question. Anthropic has published no name, model ID, price or system card for an Opus 5.6.

This guide separates what is confirmed from what testers report, walks through the knowledge-cutoff test so it actually distinguishes Opus 5.6 from Opus 5.5 (the most-shared example does not), compares the claimed outputs with Opus 5.5, and lists the signals that will mark a real Opus 5.6 release date.

## Is Claude Opus 5.6 released? {#is-claude-opus-5-6-released}

No. As of November 28, 2026, Claude Opus 5.6 has no announcement, model ID, price or system card, and the [Claude Platform models overview](https://platform.claude.com/docs/en/models/overview) still lists Claude Opus 5.5 as the newest Opus. Anthropic's most recent launch was Claude Fable 5.2 and Mythos 5.2 on November 9, which did not include a new Opus.

| | Claude Opus 5.5 | Claude Opus 5.6 |
|---|---|---|
| Status | Released September 22, 2026 | Reported in limited testing since November 24, 2026 |
| Model ID | `claude-opus-5-5` | None published |
| API price per 1M tokens | $4 input, $20 output | Not announced |
| Context / max output | 1M / 128K tokens | Not announced |
| Reliable knowledge cutoff | June 2026 | Not announced |
| System card and benchmarks | Published | None |

The Opus 5.5 column comes from Anthropic's docs and [launch post](https://www.anthropic.com/claude-opus-5-5); the Opus 5.6 column reflects the testing reports covered below. If you build on Claude today, the model you can pin, price and evaluate is still Opus 5.5, and our [Opus 5.5 pricing guide](/tutorials/claude-opus-5-5-pricing/) covers what it costs per task at each effort level.

<p><strong>Keeping a named baseline.</strong> The only Opus you can request by name today is the documented <code>claude-opus-5-5</code> ID, so any side-by-side test against a future Opus 5.6 starts there. You can call it directly from Anthropic or through a shared gateway such as
<a href="https://www.packyapi.ai/register?aff=5W73&amp;utm_source=agentspulse&amp;utm_medium=affiliate&amp;utm_campaign=claude-opus-5-6"
rel="sponsored nofollow noopener" target="_blank">PackyAPI</a>, which lists Opus 5.5 in its model catalog.</p>

## Claude Opus 5.6 rumors: what testers report {#claude-opus-5-6-rumors}

The Claude Opus 5.6 rumors rest on testers who say a newer model answers some of their Opus 5.5 requests in Claude Code and the Claude chat app, starting on November 24. On that day @notjazii [posted](https://x.com/notjazii/status/2125235869716287677) a clip of a pelican riding a bicycle, labelled "opus 5.6", and wrote that "some users are getting routed since last night." The post passed 117,000 views. A frame from that clip is this article's cover; which model made it is the poster's claim and has not been verified.

Over the next three days the reports converged on a few details:

- **Where it shows up.** TestingCatalog reported that testers believe they reach the model through an "Opus 5.5 Extra" route in Claude Code, according to [Emergent's summary](https://emergent.sh/news/claude-opus-5-6-release-date) and Mehul Gupta's [write-up on Medium](https://medium.com/data-science-in-your-pocket/claude-opus-5-6-leaked-ad95b1a222fd). Others say it appears in the chat app.
- **What changed.** Most evidence is creative coding: three.js scenes with a pelican in a market street or a pirate ship, animated SVG short films, and SVG illustrations. Some testers label the outputs "Opus-next" instead of a version number.
- **Who gets it.** Access is inconsistent. One estimate cited by [MindStudio](https://www.mindstudio.ai/blog/claude-opus-5-6-stealth-testing) puts any live test at a single-digit to low double-digit share of users, and some users report not seeing a new model anywhere.

The pushback started just as quickly. AI YouTuber Matthew Berman publicly called the Opus 5.6 claims false, and MindStudio reports that at least one widely shared "Opus 5.6" video was an AI-generated clip made from a still image, with garbled text and artifacts, not code output from a language model.

## How to test whether Claude Code is routing you to Opus 5.6 {#claude-code-opus-5-6-test}

To test whether Claude Code is routing you to Opus 5.6, ask a question only a newer model could answer from memory: a fact from after Opus 5.5's training data ends, with web search and every other tool turned off. A correct answer points to newer training data. That is the method testers rely on, and Memeburn's write-up calls the viral "Karpathy question" exactly that: a knowledge-cutoff test.

The test only works if the fact sits after the right date. Anthropic's models overview lists a **reliable knowledge cutoff of June 2026** for Opus 5.5, and for Fable 5.2, Sonnet 5.5 and Haiku 5.5 as well.

<img src="/images/claude-opus-5-6/claude-models-overview.webp" alt="Screenshot of the Latest models table in Claude Platform Docs: Claude Fable 5.2, Claude Opus 5.5, Claude Sonnet 5.5 and Claude Haiku 5.5, with pricing of $8/$40, $4/$20, $2/$10 and from $0.10/$0.50 per million input/output tokens, API IDs claude-fable-5-2, claude-opus-5-5, claude-sonnet-5-5 and claude-haiku-5-5, 1M token context windows, 128K max output and a reliable knowledge cutoff of Jun 2026 for all four" width="1125" height="747" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">
*Claude Platform Docs, Models overview, captured November 28, 2026. No Opus 5.6 or Sonnet 5.6 appears, and all four current models share a June 2026 reliable knowledge cutoff.*

That date undercuts the example people share most. In the case MindStudio describes, a chat about Andrej Karpathy's whereabouts led the model to reference something from May 2026. May falls before Opus 5.5's documented cutoff, so Opus 5.5 can plausibly know it too, and the answer cannot separate the two models.

A version of the test that can tell them apart:

1. **Turn off search and tools.** In claude.ai, disable web search for the chat. In Claude Code, tell the model not to use tools, then read the transcript and confirm no search or fetch call ran. MindStudio flags a hidden tool call as the biggest way the test goes wrong.
2. **Pick facts from after June 2026.** Use events that were widely covered and easy to check, such as Anthropic's own Opus 5.5 launch on September 22, 2026. Ask for specifics (date, name, numbers) so a guess is easy to spot.
3. **Run a control.** Ask the same questions of `claude-opus-5-5` through the API, where the model ID is explicit, and compare the answers.
4. **Repeat it.** Ask in several fresh sessions. Access appears to vary by account and by request, and a single correct answer can be a lucky guess.

Read the result narrowly. A model that consistently recalls post-June 2026 events without tools was trained on newer data than Opus 5.5's reliable cutoff, and that is all it shows. It does not tell you the model's name, size or price. Memeburn makes the same point: a correct answer points to newer training data, not to "Opus 5.6" specifically.

## Opus 5.6 vs Opus 5.5: what the demos can and can't show {#opus-5-6-vs-opus-5-5}

In the side-by-side demos testers have shared, the outputs labelled Opus 5.6 are more coherent than Opus 5.5 on the same prompt, mostly in creative coding: 3D scenes, SVG animation and illustration. No benchmark, coding eval or cost figure for Opus 5.6 has come from Anthropic.

The comparisons that circulated most:

- **three.js scenes.** In a pelican scene set in a festival street, lamps were sized to the ropes holding them, fabric flapped and water splashed when the bird landed. The same prompt on Opus 5.5 produced a flatter, simpler scene, according to MindStudio's review of the posts. A pirate-ship scene showed curved hull geometry and patched sails.
- **An animated SVG film.** A tester named Marcel ran one prompt, an animated short called *The Last Page*, on both models. The output labelled Opus 5.6 held together as an animation; the Opus 5.5 version produced glitchy shapes, as Mehul Gupta describes it.
- **A mixed result.** A BMW M4 render labelled Opus 5.6 got the wheels, brakes and materials right, but the car's overall geometry still fell short, which MindStudio notes is hard for every model tested.

These are useful signals and weak evidence. Each demo is chosen by the person who posts it, the prompts and settings are rarely shared in full, and the label is the poster's own guess. Gupta calls his examples anecdotal, with no verified model identity or controlled benchmark behind them. The faked "Opus 5.6" video shows how little a clip proves on its own. For coding work, the comparison that matters will be the one Anthropic publishes with test conditions, as it did for Opus 5.5's results on Terminal-Bench 4.0 and FrontierCode, plus independent runs like the ones in our [Gemini 4 Neon benchmarks](/tutorials/gemini-4-neon-benchmarks/) and [GPT-6.2 benchmarks](/tutorials/gpt-6-2-benchmarks/) pieces.

## Sonnet 5.6 and the rumored $2/$10 price {#sonnet-5-6}

Sonnet 5.6 is the second name in the same reports: testers say a newer Sonnet is in the test as well. A tester going by Rez AI, quoted by MindStudio, said it felt like Opus 5.5-level quality with finer attention to detail, coming from what should be the cheaper Sonnet tier. Like Opus 5.6, it has no ID, price or announcement.

The price is the weakest part of the story. A figure of $2 per million input tokens and $10 per million output tokens has been attached to Opus 5.6 online, but Memeburn found no source for it and pointed out that it is exactly the current list price of Claude Sonnet 5.5 in Anthropic's docs. If you are budgeting, the documented prices are $4/$20 for Opus 5.5, $2/$10 for Sonnet 5.5 and $8/$40 for [Claude Fable 5.2](/tutorials/claude-fable-5-2/).

## Claude Opus 5.6 release date: what Anthropic's pace suggests {#opus-5-6-release-date}

There is no Claude Opus 5.6 release date. Anthropic's recent pace makes a launch in the coming weeks plausible, but the name testers use is a guess, and an earlier round of "Opus 5.6" sightings ended in a different launch.

Three data points from the past five months, as compiled by Emergent from Anthropic's releases and TestingCatalog's reporting:

- **Pace.** Opus 5 shipped on July 24 and Opus 5.5 on September 22, 60 days apart. November 28 is day 67 since Opus 5.5.
- **Testing lead time varies.** TestingCatalog relayed a tip on September 21 that Opus 5.5 was being stealth-tested under a codename, and it launched the next day. Early Fable 5.2 outputs circulated from September 18, but Fable 5.2 shipped on November 9.
- **Names can be wrong.** On October 11 and 12, users reported Opus 5.5 requests landing on a newer checkpoint and speculated it was Opus 5.6 or Fable 5.5. What shipped next was Fable 5.2 and Mythos 5.2, and no Fable 5.5 ever appeared.

A real launch is easy to recognize. When Opus 5.5 shipped, Anthropic published the announcement, system card, pricing and model ID together, and the model went live on Amazon Web Services, Google Cloud and Microsoft Azure the same day. Watch for:

- an announcement on Anthropic's news page
- a new model ID on the Claude Platform models overview
- a system card with benchmark tables and test conditions
- the new model in the Claude app's model picker and in [Claude Code](/tutorials/claude-code-code-mode/)

Until those appear, keep production work on `claude-opus-5-5`, treat any "Opus 5.6" model string from a screenshot as unverified, and use the knowledge-cutoff test above if you want to know whether your own sessions are already reaching something newer.

## References {#references}

- Anthropic. "[Introducing Claude Opus 5.5](https://www.anthropic.com/claude-opus-5-5)." September 22, 2026.
- Anthropic. "[Models overview](https://platform.claude.com/docs/en/models/overview)." Claude Platform Docs, read November 28, 2026.
- @notjazii. "[opus 5.6: pelican riding bike](https://x.com/notjazii/status/2125235869716287677)." X, November 24, 2026.
- Luis Chavez-Mattos, MindStudio. "[Is Claude Opus 5.6 Already Being Tested in Secret?](https://www.mindstudio.ai/blog/claude-opus-5-6-stealth-testing)" November 25, 2026.
- Bhavyadeep, Emergent. "[Claude Opus 5.6 Release Date: Testing Reports, Timeline, and What's Confirmed](https://emergent.sh/news/claude-opus-5-6-release-date)." November 27, 2026.
