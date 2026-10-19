---
layout: article-sky
article_variant: research-review
zoomable_images: true
lang: en
title: "What Is REA? AI Reverse Engineering with MCP, Explained"
seo_title: "What Is REA? AI Reverse Engineering with MCP"
description: "REA (Reverse Engineer Anything) lets AI agents investigate apps and binaries over MCP: scope a target, query retained evidence, and see what it proves."
keywords: "REA, Reverse Engineer Anything, AI reverse engineering, reverse engineering MCP, Ghidra MCP, IDA MCP, rea-agents"
tags: [agents, reverse-engineering, MCP, agent-infrastructure]
categories: [frontier-research]
permalink: /tutorials/rea-reverse-engineer-anything-mcp/
thumbnail: "/image-gen_20261013_132100/cover/rea-cover-1280.webp"
og_image: "/image-gen_20261013_132100/cover/rea-cover-1280.webp"
cover_alt: "A partially opened software artifact reveals inspectable layers while one corner remains opaque"
cover_width: 1280
cover_height: 720
cover_srcset: "/image-gen_20261013_132100/cover/rea-cover-640.webp 640w, /image-gen_20261013_132100/cover/rea-cover-1280.webp 1280w, /image-gen_20261013_132100/cover/rea-cover-1536.webp 1536w"
date: 2026-10-13
last_modified_at: 2026-10-19
author_name: "AgentsPulse Editorial Team"
review_eyebrow: "Explainer / Agent tooling"
research_scope: "Scope · Retained evidence · Proof limits"
scope_note: "Updated for rea-agents 6.7.0. Based on the official repository, docs, and upstream verification records."
dek: "REA connects a coding agent to local reverse-engineering tools over MCP. Its real value is the investigation loop: scope a question, analyze once, query what you need, and keep track of what the evidence does not cover."
key_takeaways:
  - "REA is a local MCP server and CLI, not a model or a new decompiler. Your agent plans; REA drives Ghidra, IDA, Hopper, Kuna, and built-in analyzers."
  - "Results come back as Evidence: each fact keeps its source, its kind of authority, and the coverage it did or did not reach. 'Not analyzed' is never reported as 'not there'."
  - "Since 6.6 (shipped to npm in 6.7.0), an agent can query exact files and fields from an analysis it already ran, instead of repeating the analysis or pulling the whole result."
article_toc:
  - id: a-bridge-not-a-model-or-a-new-decompiler
    label: "What REA is"
  - id: start-with-a-question-and-a-scope
    label: "Question and scope"
  - id: ask-the-analysis-you-already-have
    label: "Follow-up queries"
  - id: match-the-tool-to-the-layer
    label: "Choosing a tool"
  - id: what-a-result-proves-and-what-it-doesnt
    label: "What results prove"
  - id: a-reproducible-first-investigation
    label: "Try it"
  - id: rea-faq
    label: "REA FAQ"
  - id: references
    label: "References"
related_research:
  - url: /tutorials/agent-framework-harness-runtime-production/
    title: "The Agent Framework Is Not the Runtime"
    description: "Where execution state, tool boundaries, and verification belong."
  - url: /tutorials/ai-agent-internal-access-security-boundary/
    title: "When AI Agents Get Internal Access"
    description: "Why having a tool or credential is not the same as having authority."
faq_schema:
  - question: "What is REA (Reverse Engineer Anything)?"
    answer: "REA is an open-source MCP server and CLI that connects AI agents to local reverse-engineering tools. The agent asks questions about an app or binary; REA runs analyzers such as Ghidra, IDA, Hopper, Kuna, or its built-in JavaScript and .NET readers and returns Evidence: findings with their source locations, coverage, and unknowns."
  - question: "Is REA the same thing as MCP?"
    answer: "No. MCP (Model Context Protocol) is the standard way an agent calls external tools. REA is one MCP server that exposes reverse-engineering tools over that protocol; the same workflows are also available from its rea CLI."
  - question: "Do I need Ghidra, IDA, Hopper, or Kuna?"
    answer: "Only for native machine-code analysis. Static JavaScript/Electron and .NET inspection need no native engine. Setup can install Hopper after approval; Ghidra, IDA, and Kuna use installations you supply. Kuna currently covers ELF and thin Mach-O targets, not Windows PE."
  - question: "Do I have to rerun the analysis to ask a follow-up question?"
    answer: "Usually not. Within the same MCP connection, inspect_analysis_view reads exact files, fields, or module references from Evidence that REA already retained. Rerun the analysis when you need files you did not select, a newer analyzer, or Evidence saved by a release before 6.6."
  - question: "Does REA upload my app?"
    answer: "REA analyzes targets locally, but its results go to your agent, and the model provider behind that agent has its own data policy. Review sensitive results before sharing them with a cloud model."
---
REA (**Reverse Engineer Anything**) is an open-source tool that lets an AI agent investigate software you are allowed to inspect. You ask a question about a feature, such as "where does this desktop app store its credentials?" The agent then uses REA to read the app's shipped files or compiled machine code and explains what it found, with the evidence behind each step. [<a href="#reference-1">1</a>]

It is tempting to call it "a decompiler your agent can drive," but that misses the useful part. REA is built around an investigation loop: decide what to look at, get results that say where each fact came from and what was not covered, then query those results, trace across layers, or check behavior at runtime. Decompiler output is one input to that loop, not the answer.

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_104219/figures/rea-investigation-flow-mobile.webp" width="840" height="1340">
  <img src="/technical-article-writing_20261019_104219/figures/rea-investigation-flow.webp" width="2000" height="1000" alt="REA's own investigation-flow figure: 1. Ask, with your agent and a local app, binary, or browser target; 2. Inspect and trace with REA over CLI or MCP, backed by local analysis adapters; 3. Read the evidence: code, references, unknowns; 4. Use what you learn, as your agent explains, implements, and tests; a follow-up question loops back to step 2" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 1. REA's investigation loop: ask about a local target, let REA inspect and trace it, read the evidence, then explain, implement, or test, with follow-up questions looping back to REA.* [<a href="#reference-1">1</a>]

This explainer was first published for REA 6.4.0 and has been rewritten for **rea-agents 6.7.0**, released on 18 October 2026. [<a href="#reference-2">2</a>]

## A bridge, not a model or a new decompiler

REA is a **local MCP server and command-line tool**, distributed on npm as `rea-agents` under the MIT license. It is not a language model and not a new decompiler. It connects an AI agent to analysis tools that already exist. [<a href="#reference-1">1</a>]

Three roles are worth keeping apart:

- **The agent** (Claude Code, Codex, Cursor, and others) decides what to inspect next, reads the results, and writes the explanation or code.
- **MCP** (Model Context Protocol) is the plug. It is how the agent discovers and calls REA's tools. MCP itself does no analysis. (For how the protocol itself is changing, see our explainer on [stateless MCP and agent gateways](/tutorials/stateless-mcp-agent-gateway/).)
- **REA** turns each tool call into analysis work. It drives a native engine such as Ghidra, IDA, Hopper, or Kuna, or uses built-in readers for JavaScript, .NET, Android packages, and websites. It sends back a structured record the project calls **Evidence**.

<picture>
  <source media="(max-width: 760px)" srcset="/archify_20261019_105653/rea-architecture-v2.webp" width="840" height="1810">
  <img src="/archify_20261019_105653/rea-architecture-wide.webp" width="2000" height="1040" alt="REA architecture: an AI agent sends MCP calls to the REA MCP server; new analysis goes to analyzers (static, native, runtime) that read or run the local target and record Evidence in a per-connection Evidence ledger; follow-up views query or trace that retained Evidence; the ledger can be exported as an Evidence bundle for a later session" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 2. Results do not just flow back to the agent. REA keeps each one as Evidence for the current connection, so later questions can reuse it without rerunning the analyzer.*

Evidence is what separates REA from piping decompiler text into a chat. A record names its target by content hash, keeps source locations for its facts, and states which parts of the target were covered and which were not. [<a href="#reference-3">3</a>] The MCP server keeps these records for the life of one connection; `close_binary` clears them, and an exported Evidence bundle carries them to another session. The `rea` CLI runs the same workflows but, as a one-shot process, reads and writes Evidence as files. [<a href="#reference-3">3</a>, <a href="#reference-4">4</a>]

REA suits developers who want to understand a feature in a product they did not build, security researchers and CTF players, and preservation or interoperability work. It is meant for lawful research and for software you own or are authorized to examine; commercial tools such as IDA and Hopper must also be properly licensed. [<a href="#reference-1">1</a>, <a href="#reference-5">5</a>]

## Start with a question and a scope

A good REA session starts narrower than "reverse engineer this app." Three choices shape everything after:

1. **The question.** "Which native modules does this app ship, and which version of the app is this?" is answerable. "How does it work?" is not.
2. **The exact target.** Record the app version and file you analyze. REA binds its results to a hash of the bytes it read, so a later question can confirm it is still talking about the same artifact. [<a href="#reference-3">3</a>]
3. **The analysis scope.** Decide which files to analyze and whether the work is static (reading files) or runtime (running or attaching to the target).

For JavaScript and Electron apps, scope is explicit. You can pass exact file paths with `--source-path` on the CLI or `source_paths` over MCP. REA still inventories and hashes the whole archive, but it reads and analyzes only the selected files. [<a href="#reference-6">6</a>]

That choice has a consequence that matters more than any feature: **"not selected" is different from "not found."** Unselected files are marked `outside-analysis-scope`, their relationships stay unknown, and the application's coverage is reported as partial. A result with partial coverage cannot tell you that something is absent from the app, only that it was not seen in the part that was analyzed. [<a href="#reference-6">6</a>]

Static and runtime work differ in risk as well as in what they can show. Reading JavaScript or .NET files does not run anything. Runtime capture runs or attaches to the target with your user permissions, so it can change files or accounts; an agent holding those permissions is a security boundary in its own right, as we discuss in [When AI Agents Get Internal Access](/tutorials/ai-agent-internal-access-security-boundary/). Start static, and move to an isolated runtime environment only when the question is about behavior. [<a href="#reference-1">1</a>]

## Ask the analysis you already have

Once an analysis finishes, most follow-up questions do not need another one. REA's `inspect_analysis_view` tool reads views out of Evidence the connection already holds. It does not reopen the files, execute code, or start a native provider. [<a href="#reference-4">4</a>]

This is not new in 6.7. REA 6.4 already offered retained views: summaries, single sections or modules, and stable pages, plus a ready-made continuation when a native result was too large for one reply. [<a href="#reference-7">7</a>] What 6.6 added, and 6.7 shipped to npm, is a more precise way to ask: [<a href="#reference-2">2</a>, <a href="#reference-4">4</a>]

- **Exact files and fields.** A `javascript-facts` view takes a list of exact file paths and the property names you want, such as `name`, `version`, or `analysis_status`. Paths are matched literally; nothing is normalized or re-read. Missing properties stay missing rather than turning into `null`.
- **Filtered module references.** A typed `references` projection lists modules matching an exact path and kind, with their canonical identities and source-range counts.
- **Paging that does not overclaim.** Pages start at offset 0 with a default limit of 64 rows; follow `coverage.next_offset` for more. Each response keeps the source selection and unknown counts of the parent analysis, so reaching the last page means "no more matching rows in what was analyzed," not "nothing else exists."
- **Field discovery on request.** If you do not know the property names, `include_available_property_keys: true` lists them without sending their values. It is off by default because even the names cost context.

`inspect_analysis_view` returns rows; it does not follow relationships. When the question is "what does this call reach?", use a trace tool such as `trace_application_feature` on the same retained Evidence. [<a href="#reference-4">4</a>]

### A worked example: what Joplin ships

REA's maintainers recorded how the new view behaves on a real application: the official Joplin 3.7.21 Linux AppImage. The following summarizes that upstream verification record; it is not a test AgentsPulse ran. [<a href="#reference-8">8</a>]

**The question:** given a few known paths in the app, what are the package identity, the native credential module's identity, and the processing status of each file?

<picture>
  <source media="(max-width: 760px)" srcset="/archify_20261019_105653/rea-joplin-retained-facts.webp" width="840" height="1790">
  <img src="/archify_20261019_105653/rea-joplin-wide.webp" width="2000" height="840" alt="Joplin verification in two lanes: the Joplin 3.7.21 ASAR with five selected sources is analyzed normally (6,324 files inventoried, partial coverage) and with a 1 ms timeout control; both results are retained as Evidence and queried with the same facts view; the normal lane returns 12 observations including app-desktop 3.7.21 and the keytar hash, which shows identity, not execution; the control returns 11 observations, keeps the native identity, and reports three phases as not-started" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 3. Two analyses of the same five sources, one normal and one cut short on purpose, queried the same way. Each answer keeps its original source, and the interrupted run says which phases never started.*

1. **Scope the analysis.** The app's 233,575,014-byte ASAR archive was analyzed with five selected sources: `ElectronAppWrapper.js`, its source map, `index.html`, `package.json`, and the native module `node_modules/keytar/build/Release/keytar.node`. The inventory covered 6,324 files. Whole-application analysis stayed partial, as it should with five files selected.
2. **Query exact facts.** A `javascript-facts` view asked for four of those paths and fields such as `name`, `version`, `availability`, and `analysis_status`. It returned 12 observations, each with its original Evidence.
3. **Read the answers with their limits.** The package is `@joplin/app-desktop`, version `3.7.21`. The `keytar.node` bytes hash to `0700016b…a413373a`. The record is explicit that this hash identifies the file, and does not show the module was ever loaded or run.
4. **Check what did not finish.** In a control run with `analysis_timeout_ms: 1`, the same query returned 11 observations. The native module's identity was still there, and three phases were reported as unavailable and `not-started`: `parse-local-source-map`, `parse-html-script-references`, and `parse-package-json`. The record also distinguishes a source map whose original content is missing from a source map that failed to parse.

Why not just run a full feature trace? In the development issue, a trace of the real Joplin package exceeded REA's 10 MiB reply limit twice. [<a href="#reference-8">8</a>] A narrow view answers a narrow question without sending the whole graph.

The record is equally careful about costs. Retrieving the selected facts took 0.157 s through the view versus 2.981 s for exporting the Evidence and projecting it locally. But the view's request and reply used more tokens (17,289 versus 8,887 by a `cl100k_base` count), because its general contract and Evidence wrapper are larger than a small custom script. Small trials with Codex CLI agents gave mixed results. The maintainers' conclusion: this is a precise interface for clients that know their question, **not** an established token saving. [<a href="#reference-8">8</a>]

### Query, re-analyze, or observe at runtime

Retained Evidence changes the first decision in every follow-up step: do you need new analysis at all?

<picture>
  <source media="(max-width: 760px)" srcset="/archify_20261019_105653/rea-next-step.webp" width="840" height="1520">
  <img src="/archify_20261019_105653/rea-next-step-wide.webp" width="2000" height="940" alt="Decision flow for a follow-up question: behavior questions go to runtime capture in an isolated environment; file-fact questions check whether retained Evidence covers them; if yes, query a view, and trace relations on the same Evidence when links are needed; if not, re-analyze, which reads the target again and then feeds a new view query" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 4. Three different next steps. Only re-analysis reads the target again, and only runtime capture runs it. Re-analysis produces new Evidence, which you then query the same way.*

- **Query** when the answer is a fact or a page of facts from files you already analyzed.
- **Re-analyze** when the files were outside the selected scope, when Evidence came from a different connection that was not exported, when it was saved by a release before 6.6 (see below), or when the question needs a different provider.
- **Observe at runtime** when the question is about what the app does, not what its files contain. Static results cannot show that a path executed. [<a href="#reference-4">4</a>]

## Match the tool to the layer

A single feature can span several layers: a button triggers JavaScript, which sends a message to a main process, which may call native code. The useful question is less "what can REA read?" than "which layer does my question live in, and what does the tool for that layer leave unresolved?" The list below maps common questions to REA routes, including what 6.6 and 6.7 added.

- **How does this Electron or web feature work in code?** Route: `analyze_javascript_application`, then views and traces. Reads files without running them. Dynamic channel names and computed members remain explicit unknowns. [<a href="#reference-4">4</a>, <a href="#reference-6">6</a>]
- **What does this native function do?** Route: Hopper, Ghidra, or IDA. Returns pseudocode and assembly, not original source. Formats and host support vary by provider. [<a href="#reference-1">1</a>]
- **Can I use Kuna, a single-executable decompiler, on Linux or macOS?** Route: the **Kuna** provider (`--provider kuna`). You install Kuna; REA verified version 1.833, with real-provider runs on Linux. ELF and thin Mach-O only: no Windows host, PE files, or universal Mach-O. No typed references, basic blocks, or type recovery, so not a Ghidra or IDA replacement. Completed exports are cached and reused. [<a href="#reference-9">9</a>]
- **Which strings does the Android app show in each language?** Route: `decode_android_resources` with repeated `--locales`. Uses an Apktool you supply (2.7.0 or newer). One decode projects several locale tables, each with its own status (`present`, `missing`, `oversized`, `malformed`, `skipped`) and coverage. It does not simulate Android's runtime resource matching. [<a href="#reference-10">10</a>]
- **What is inside this Windows ARM app or DLL?** Route: Ghidra on a **Windows x64 host** (experimental). Admits ARMNT (Thumb-2) and ARM64 PE files. ARM64EC and ARM64X are not admitted, and this is not support for running REA on Windows-on-Arm. Verification disabled one resource analyzer and raised startup budgets; one cold first query took about 434 s on a constrained host. [<a href="#reference-11">11</a>]
- **What does this headerless 68000 ROM do?** Route: Ghidra's raw-binary import with `--architecture m68k`. You supply the load address and an even entry point. REA does not read reset vectors or parse Amiga or Atari ST headers. Verified with Ghidra 12.1.4 on macOS; Linux is untested, and Windows does not admit m68k. [<a href="#reference-12">12</a>]
- **What does the app actually do when used?** Route: browser, Electron, or process capture. Runs or attaches to the target with your permissions. Use an isolated environment. Observations hold for the version and environment observed. [<a href="#reference-1">1</a>, <a href="#reference-4">4</a>]

Two habits follow from this list. Check host and format support before you plan an investigation, since "anything" means many formats, not every format on every host. And when Kuna and another provider are both configured for the same target, REA's automatic selection reports `ambiguous` instead of choosing, so name the provider you mean. [<a href="#reference-9">9</a>]

## What a result proves, and what it doesn't

REA's results are careful about the kind of claim each fact supports. For application analysis, static observations of files, passive runtime observations, inferred relationships, and unknown or unavailable facts each keep their original authority; tracing and comparison do not promote one into another. A relationship marked `resolved` means the static target was unique within the analysis. It does not mean the code path executed. [<a href="#reference-4">4</a>]

Coverage works the same way. An empty list of callers with partial or unknown coverage is not proof that a function has no callers, and an empty or exhausted page cannot prove absence from an app that was only partly analyzed. [<a href="#reference-3">3</a>, <a href="#reference-4">4</a>] When work fails or is cancelled, 6.6 keeps the observations that did complete along with the exact cancellation reason and the original failure, so a partial run still says what it learned. [<a href="#reference-2">2</a>]

### The Notion case: where REA stopped and reading began

The project's Notion clipboard case shows these boundaries on a real app. It used REA **4.1.0** on Notion Desktop 7.6.1, not 6.7. [<a href="#reference-13">13</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_104219/figures/notion-findings-mobile.webp" width="768" height="1704">
  <img src="/technical-article-writing_20261019_104219/figures/notion-findings.webp" width="1180" height="610" alt="REA findings from the Notion case: the exposed page API with api_key __electronApi, api_status dynamic, at preload.js line 1 columns 22764 to 22828; and the renderer IPC call with operation invoke, channel_expression e, at preload.js line 1 columns 6486 to 6522" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 5. REA's two findings in the Notion case: the exposed page API and the renderer IPC call, each with an exact source range and both marked dynamic.* [<a href="#reference-17">17</a>]

- REA's JavaScript analysis of the tab preload script found a context bridge exposed as `__electronApi` and an IPC `invoke` call, with exact line and column ranges. It marked both as dynamic: one API member and the channel name could not be resolved statically.
- The rest of the path came from reading the packaged code: the API object's `clipboard.write` member, its literal `notion:clipboard:write` channel, and the main-process receiver that checks the sender and calls Electron's clipboard.
- A feature trace seeded with that channel name found no match in REA's graph.

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_104219/figures/notion-bridge-mobile.webp" width="768" height="2883">
  <img src="/technical-article-writing_20261019_104219/figures/notion-bridge.webp" width="1688" height="752" alt="The bridge inside Notion's desktop package in four steps: 01 page-facing API clipboard.write(data); 02 preload wrapper ipcRenderer.invoke; 03 main-process handler ipcMain.handle, which checks which page sent the message; 04 Electron's system clipboard.write(data); one channel, notion:clipboard:write, joins the two sides" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 6. The complete clipboard path in Notion's desktop package. REA located the bridge and the invoke call; the clipboard.write member, the channel name, and the main-process receiver came from reading the packaged code.* [<a href="#reference-17">17</a>]

The case notes say plainly that the four-step path is not an automatically paired IPC graph or a recording of the app running. [<a href="#reference-13">13</a>] That is what good use looks like: REA located the bridge and named the gaps, and the reading closed them. The same goes for the project's DX-Ball case, where the claim that a rewritten sound-panning function matches the original rests on 3,205 test cases against the original x86 code, not on decompiler output alone. [<a href="#reference-1">1</a>, <a href="#reference-14">14</a>]

<picture>
  <source media="(max-width: 760px)" srcset="/technical-article-writing_20261019_104219/figures/dx-ball-sound-pan-mobile.webp" width="840" height="1760">
  <img src="/technical-article-writing_20261019_104219/figures/dx-ball-sound-pan.webp" width="2000" height="1000" alt="DX-Ball sound-pan investigation: DXBALL.EXE at 0x00406400; REA follows a stack input x, set by the brick-hit caller as 20 + 30 × tile_x, through × 1.5625, − 500.0, × pan_scale, and an integer return; the reconstructed function is maintained C, checked by an original-code comparison of 3,205 cases and a VC4.0 build comparison of 63 matching bytes" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
</picture>

*Figure 7. The DX-Ball sound-pan case: the function's input, its arithmetic steps, and the two checks on the rebuilt C, 3,205 original-code cases and a 63-byte build comparison.* [<a href="#reference-14">14</a>]

### Upgrading from 6.4

Several 6.6 changes, delivered in 6.7.0, are breaking. The one most users will hit concerns saved results: **Evidence and analysis snapshots made with older releases must be regenerated.** Their identity now requires an explicit relationship-coverage field; old files are not migrated, and missing facts are not filled with guessed defaults. [<a href="#reference-2">2</a>]

Other changes affect scripts. `inspect_adb_package.version_code` is now a decimal string, and failed native UI scenarios return a typed error with the collected report in `partial_observation`. MCP registrations are pinned to the version that ran setup, so after upgrading, run setup again and restart your agent. [<a href="#reference-2">2</a>, <a href="#reference-15">15</a>]

## A reproducible first investigation

You need Node.js 22.19+, 24.11+, or 26+, plus npm. On Linux, static JavaScript analysis also needs a procps-compatible `ps`. [<a href="#reference-1">1</a>]

**1. Register a pinned version with your agent.**

```bash
npx rea-agents@6.7.0 setup
```

Setup shows the configuration changes, asks for approval, backs up existing settings, and installs matching workflow instructions. Restart the agent afterward. Pinning the version makes the investigation repeatable. [<a href="#reference-1">1</a>, <a href="#reference-15">15</a>]

**2. Ask a scoped question that follows the loop.**

```text
I am authorized to inspect the Electron app at /path/to/app.asar.
Static analysis only. Analyze package.json, main.js and preload.js.
Then query only what you need from that result to answer:
which IPC channels does preload.js expose, and which native modules ship?
For every answer, cite the source location and say what was outside
the analyzed scope or left unknown.
```

**3. Or run the same loop from a terminal.** Analyze selected files once, then query the saved Evidence:

```bash
npx -y rea-agents@6.7.0 analyze-javascript-application /absolute/path/to/app.asar \
  --source-path package.json --source-path main.js --json > app-evidence.json
jq -c '{source: {kind: "inline", evidence: .}, view: {kind: "summary"}}' \
  app-evidence.json > app-view.json
npx -y rea-agents@6.7.0 inspect-analysis-view app-view.json
```

A CLI process has no connection ledger, so it passes the complete Evidence inline. Swap the summary view for a `javascript-facts` or module-reference view to ask narrower questions of the same file. [<a href="#reference-4">4</a>, <a href="#reference-16">16</a>]

**4. Check before you build.** Before acting on an explanation, confirm three things: each claim points to a source location, the coverage covers the files the claim is about, and anything about behavior has a runtime observation or a test behind it.

## REA FAQ

### What is REA (Reverse Engineer Anything)?

REA is an open-source MCP server and CLI that connects AI agents to local reverse-engineering tools. The agent asks questions about an app or binary; REA runs analyzers such as Ghidra, IDA, Hopper, Kuna, or its built-in JavaScript and .NET readers and returns Evidence: findings with their source locations, coverage, and unknowns.

### Is REA the same thing as MCP?

No. MCP (Model Context Protocol) is the standard way an agent calls external tools. REA is one MCP server that exposes reverse-engineering tools over that protocol; the same workflows are also available from its rea CLI.

### Do I need Ghidra, IDA, Hopper, or Kuna?

Only for native machine-code analysis. Static JavaScript/Electron and .NET inspection need no native engine. Setup can install Hopper after approval; Ghidra, IDA, and Kuna use installations you supply. Kuna currently covers ELF and thin Mach-O targets, not Windows PE.

### Do I have to rerun the analysis to ask a follow-up question?

Usually not. Within the same MCP connection, inspect_analysis_view reads exact files, fields, or module references from Evidence that REA already retained. Rerun the analysis when you need files you did not select, a newer analyzer, or Evidence saved by a release before 6.6.

### Does REA upload my app?

REA analyzes targets locally, but its results go to your agent, and the model provider behind that agent has its own data policy. Review sensitive results before sharing them with a cloud model.

## References

1. <span id="reference-1"></span>morluto/rea. [“README.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/README.md) GitHub, v6.7.0.
2. <span id="reference-2"></span>morluto/rea. [“rea-agents v6.7.0 release notes”](https://github.com/morluto/rea/releases/tag/rea-agents-6.7.0) (including the 6.6.0 changes and breaking changes). GitHub, 18 October 2026.
3. <span id="reference-3"></span>morluto/rea. [“MCP contracts.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/mcp-contracts.md) GitHub, v6.7.0.
4. <span id="reference-4"></span>morluto/rea. [“Cross-layer JavaScript application workflows.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/javascript-application-workflows.md) GitHub, v6.7.0.
5. <span id="reference-5"></span>morluto/rea. [“Disclaimer.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/DISCLAIMER.md) GitHub, v6.7.0.
6. <span id="reference-6"></span>morluto/rea. [“JavaScript artifact reconstruction.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/javascript-artifact-reconstruction.md) GitHub, v6.7.0.
7. <span id="reference-7"></span>morluto/rea. [“MCP contracts.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/docs/mcp-contracts.md) GitHub, v6.4.0.
8. <span id="reference-8"></span>morluto/rea. [“Selected retained JavaScript observations”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/verification/javascript-retained-facts-2026-10-15.md) (verification record, 15–16 October 2026). GitHub, v6.7.0.
9. <span id="reference-9"></span>morluto/rea. [“Kuna provider.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/kuna-provider.md) GitHub, v6.7.0.
10. <span id="reference-10"></span>morluto/rea. [“Apktool resource decoding.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/apktool-resource-analysis.md) GitHub, v6.7.0.
11. <span id="reference-11"></span>morluto/rea. [“Windows Ghidra P0.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/windows-ghidra-p0.md) GitHub, v6.7.0.
12. <span id="reference-12"></span>morluto/rea. [“Headerless raw-binary analysis with Ghidra.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/raw-binary.md) GitHub, v6.7.0.
13. <span id="reference-13"></span>morluto/rea. [“Notion clipboard case: sources and scope.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/website/evidence/notion-clipboard.md) GitHub, v6.7.0.
14. <span id="reference-14"></span>morluto/rea. [“DX-Ball sound-panning case notes.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/website/evidence/dx-ball-sound-pan.md) GitHub, v6.7.0.
15. <span id="reference-15"></span>morluto/rea. [“Installation and setup.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/installation.md) GitHub, v6.7.0.
16. <span id="reference-16"></span>morluto/rea. [“CLI and Evidence.”](https://github.com/morluto/rea/blob/rea-agents-6.7.0/docs/cli.md) GitHub, v6.7.0.
17. <span id="reference-17"></span>REA. [“Notion Electron Reverse Engineering: Clipboard.”](https://rea.tools/showcase/notion/) rea.tools showcase, accessed 19 October 2026.
