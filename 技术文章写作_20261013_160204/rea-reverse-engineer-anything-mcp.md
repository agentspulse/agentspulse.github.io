---
layout: article-sky
article_variant: research-review
zoomable_images: true
lang: en
title: "What Is REA? AI Reverse Engineering with MCP, Explained"
seo_title: "What Is REA? AI Reverse Engineering with MCP"
description: "REA (Reverse Engineer Anything) lets AI agents inspect apps and binaries through MCP. Learn what it analyzes, how it works with Ghidra and IDA, and its limits."
keywords: "REA, Reverse Engineer Anything, AI reverse engineering, reverse engineering MCP, Ghidra MCP, Electron reverse engineering"
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
last_modified_at: 2026-10-13
author_name: "AgentsPulse Editorial Team"
review_eyebrow: "Explainer / Agent tooling"
research_scope: "Positioning · Targets · Workflow"
scope_note: "Based on the official repository, docs, and published case notes."
dek: "REA gives an AI agent one MCP connection to decompilers, app analyzers, and runtime capture, so it can trace a feature from what you see on screen down to the code that implements it."
key_takeaways:
  - "REA is a local MCP server and CLI. Your agent plans the investigation; REA drives Ghidra, IDA, Hopper, and built-in analyzers for it."
  - "It covers several layers of the same software: runtime behavior, packaged JavaScript and .NET code, Android packages, and native machine code."
  - "Its main use is feature dissection: understand how one feature works, then let the agent explain it or build and test a similar version."
article_toc:
  - id: a-bridge-not-a-new-decompiler
    label: "What it is"
  - id: too-many-tools-nothing-connecting-them
    label: "The problem"
  - id: who-gets-the-most-out-of-it
    label: "Who it suits"
  - id: from-the-screen-down-to-machine-code
    label: "What it can read"
  - id: good-fits-and-poor-fits
    label: "Fits and limits"
  - id: following-one-feature-notions-copy-path
    label: "One feature, traced"
  - id: trying-it-on-your-own-app
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
    answer: "REA is an open-source MCP server and CLI that connects AI agents to local reverse-engineering tools. The agent asks questions about an app or binary; REA runs analyzers such as Ghidra, IDA, Hopper, or its built-in JavaScript and .NET readers and returns code, locations, and open questions."
  - question: "Is REA the same thing as MCP?"
    answer: "No. MCP (Model Context Protocol) is the standard way an agent calls external tools. REA is one MCP server: it exposes reverse-engineering tools over that protocol, and the same workflows are also available from its rea CLI."
  - question: "Do I need Ghidra, IDA, or Hopper?"
    answer: "Only for deep native analysis of compiled binaries. Static JavaScript/Electron and .NET inspection work without a native analysis engine. Setup can install Hopper after approval; Ghidra and IDA use your existing installations."
  - question: "Does REA upload my app?"
    answer: "REA analyzes targets locally, but its results go to your agent, and the model provider behind that agent has its own data policy. Review sensitive results before sharing them with a cloud model."
---
REA (**Reverse Engineer Anything**) is an open-source tool that lets an AI agent take apart software you are allowed to inspect. You ask a question about a feature, such as "how does copy and paste work in this desktop app?" The agent then uses REA to look through the app's shipped files or compiled machine code, and explains what it found. [<a href="#reference-1">1</a>]

The project calls itself "one MCP for reverse engineering across binaries, applications, and runtime behavior." In plain terms: one connection gives your agent decompilers, app unpackers, and runtime capture, so it can follow a feature from the button you click down to the code behind it.

## A bridge, not a new decompiler

REA is a **local MCP server and command-line tool**, distributed on npm as `rea-agents` under the MIT license. It is not a model and not a new decompiler. It is the connector between an AI agent and the analysis tools that already exist. [<a href="#reference-1">1</a>, <a href="#reference-2">2</a>]

Three roles are worth separating:

- **The agent** (Claude Code, Codex, Cursor, and others) decides what to look at next, reads the results, and writes the explanation or code.
- **MCP** (Model Context Protocol) is the plug. It is the standard way the agent discovers and calls REA's tools. MCP itself does no analysis.
- **REA** turns each tool call into real analysis work. It drives a native engine such as Ghidra, IDA, or Hopper, or uses built-in readers for JavaScript, .NET, Android packages, and websites. Then it sends back structured results.

<img src="/archify_20261013_160204/rea-architecture.webp" width="1720" height="1640" alt="Architecture of REA: a developer prompts an AI agent, which calls the REA MCP server; the rea CLI shares the same workflows; REA routes work to native engines (Hopper, Ghidra, IDA), static analyzers (JavaScript/Electron, .NET, APK) and runtime capture, all reading a local target" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Figure 1. How the pieces fit. The agent talks to REA over MCP; the CLI reaches the same core workflows from a terminal. Analysis runs locally. Dashed paths run or attach to the target, so they can have side effects; solid paths read files.*

The MCP server and the `rea` CLI share the same core workflows and result format, so you can repeat or script an investigation from a terminal. [<a href="#reference-1">1</a>, <a href="#reference-3">3</a>]

## Too many tools, nothing connecting them

Reverse engineering usually means switching between many tools. You open a disassembler for native code, unpack an Electron archive by hand, run a browser debugger for network traffic, and keep notes about which function talked to which. Every tool has its own interface, and none of them explains what it shows.

An AI agent is good at the reasoning part: forming a guess, choosing the next thing to inspect, and turning low-level code into a plain-language explanation. Without a connector, though, it can only see what you paste into the chat. REA gives the agent direct, structured access to those tools, so it can follow a feature across files and layers by itself. [<a href="#reference-1">1</a>]

REA's results also include where each finding came from (file, address, or source range) and what is still unknown. An agent can then say "this handler is likely called here, but the channel name is computed at runtime" instead of guessing. The project calls these records Evidence. In practice, they let you check the agent's explanation against the code. [<a href="#reference-4">4</a>]

## Who gets the most out of it

REA suits people who need to understand software they did not write and who already work with a coding agent:

- **Developers** who see a feature in another product and want to understand how it works before building their own version.
- **Security researchers and CTF players** who analyze binaries, Android packages, firmware, or network captures.
- **Preservation and interoperability work**, such as recovering the logic of an old game or file format. The project's showcases include a 1990s Windows game and a PC-98 DOS game. [<a href="#reference-5">5</a>]

It works with any agent that supports local MCP servers. Setup can configure Claude Code, Claude Desktop, Codex, Cursor, Gemini CLI, Windsurf, GitHub Copilot CLI, VS Code, and many others; other clients can register the server manually. [<a href="#reference-2">2</a>]

It is **not** for analyzing software you have no right to examine. The project's disclaimer limits intended use to lawful research, education, interoperability, preservation, and software you own or are authorized to inspect. [<a href="#reference-6">6</a>] The README adds that users must legally obtain and be authorized to use commercial tools such as IDA and Hopper. [<a href="#reference-1">1</a>]

## From the screen down to machine code

A single feature can live in several layers at once. Take a desktop app: a button in the interface triggers JavaScript, which sends a message to a main process, which may call native code. REA's coverage is designed to follow that stack downward. Figure 2 shows the idea; the table after it groups the official target list by layer. [<a href="#reference-1">1</a>]

<img src="/archify_20261013_160204/rea-layers.webp" width="1720" height="1400" alt="One feature spans four layers: what you see triggers runtime behavior, which runs application code, which calls a native binary; REA reads each layer with runtime capture, static readers, or native engines" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Figure 2. The same feature at different depths. Each layer has a matching kind of REA tool; only runtime capture actually runs the target.*

| Layer | Example targets | What REA returns | Extra tools needed |
|---|---|---|---|
| Runtime behavior | Websites, running processes, Android devices, saved HAR/SAZ network captures | Page structure, scripts, network requests, terminal output, file effects | A Chrome-family browser; adb for devices |
| Application code | JavaScript and Electron apps, .NET assemblies, Android APKs, Flutter and WASM artifacts | Modules, imports, IPC channels, routes, classes, decompiled methods, IL | None for JS and .NET; JADX and a JDK for APKs |
| Native binaries | Windows, macOS, and Linux executables, Go binaries, 16-bit DOS programs | Pseudocode, assembly, strings, symbols, calls, and references | Hopper, Ghidra, or IDA |
| Data and artifacts | SQLite databases, firmware images, packet captures, EVM bytecode, app bundles | Tables, extracted regions, protocol fields, contract selectors, file inventories | Depends on format, e.g. Binwalk or TShark on Linux |

Two practical points follow from this table:

1. **"Anything" means many formats, not every format on every host.** Some targets are Linux-only, some need tools you install yourself, and native coverage depends on which engine you use. Check the requirement column for your target first. [<a href="#reference-1">1</a>]
2. **Static and runtime analysis behave differently.** Reading JavaScript or .NET files does not run the app. Runtime capture does run or attach to it, using your user permissions, so it can change files or accounts. Use an isolated environment for anything untrusted. [<a href="#reference-1">1</a>, <a href="#reference-4">4</a>]

## Good fits and poor fits

**Good fits:**

- You want to know *how* a specific feature works in a product, without source code.
- You need to trace a path across layers, such as from a UI action through Electron IPC into a main-process handler.
- You are recovering the behavior of an old or undocumented binary and can test your reconstruction against it.
- You already use Ghidra, IDA, or Hopper and want an agent to do the repetitive navigation.

**Poor fits:**

- You need the exact original source code. Native analysis returns pseudocode and assembly. JavaScript analysis recovers the shipped modules. Your agent writes the reimplementation, and you still have to test it. [<a href="#reference-1">1</a>]
- You do not have rights to the target, or the task would bypass protections or licensing.
- The sensitive contents of the target must never reach a cloud model. REA runs locally, but its results go to your agent and its model provider. [<a href="#reference-1">1</a>]

REA is also changing quickly. The repository's version at the time of writing was 6.4.0, and the README advises updating before reporting bugs. Record the version you used so you can repeat an investigation. [<a href="#reference-1">1</a>]

## Following one feature: Notion’s copy path

The README summarizes the loop in four steps. You ask about a local target. REA inspects and traces it with its analysis tools. It returns code, references, and unknowns. The agent then explains, implements, or tests, and asks follow-up questions as needed. [<a href="#reference-1">1</a>]

A published case from the project shows what that loop looks like on a real app. [<a href="#reference-7">7</a>]

**The question:** how does Notion Desktop write rich content to the system clipboard?

<img src="/archify_20261013_160204/rea-feature-trace.webp" width="1720" height="1200" alt="Sequence of the Notion clipboard trace: the developer asks, the agent calls REA's JavaScript analyzer on the preload script, REA reports the bridge and an unresolved channel, the agent reads the API object and the main bundle to find the receiver, then explains the chain" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Figure 3. Who does what in the Notion trace. REA finds the bridge and flags what it cannot resolve; the agent reads the code to close those gaps.*

1. **Locate the bridge.** REA's `analyze_javascript_application` tool inspected the desktop app's tab preload script without running the app. It reported a context bridge exposed as `__electronApi` and an IPC `invoke` call. For each, it gave the exact line and column range. It also flagged both as partly dynamic: the API members and the channel name could not be resolved statically.
2. **Follow the gap.** Because REA marked those parts as unresolved, the next step was clear. Reading the packaged API object revealed a `clipboard.write` member. That member sends a literal `notion:clipboard:write` channel.
3. **Cross into the main process.** Reading the main-process bundle connected that channel to a receiver. The receiver checks which page sent the message and then calls Electron's `clipboard.write`.
4. **Explain or rebuild.** With that chain mapped, an agent can explain the design: renderer API, IPC channel, sender check, native clipboard call. It can also implement a similar bridge in your own Electron app and test it.

The case notes are explicit about scope. The four-step path combines REA's static result with manual reading of the wrapper code; it is not an automatically paired IPC graph or a recording of the app running. [<a href="#reference-7">7</a>] That is a fair picture of normal use: REA narrows the search and marks the gaps, and the agent (or you) closes them.

The same loop works at the native layer. In the project's DX-Ball case, Ghidra's decompiler output for a 63-byte sound-panning function missed the input parameter and the floating-point math. The agent read the assembly, the calling code, and the constants in memory to recover the formula. The project reports that its rewritten C passes 3,205 test cases against the original x86 code and compiles back to the same 63 bytes. [<a href="#reference-1">1</a>, <a href="#reference-5">5</a>] That result covers one function, not the whole game, and like the Notion trace it comes from the project’s own write-up rather than a rerun on our side.

## Trying it on your own app

You need Node.js 22.19+, 24.11+, or 26+, plus npm. [<a href="#reference-1">1</a>]

**1. Register REA with your agent.**

```bash
npx rea-agents setup
```

Setup shows the configuration changes it will make, asks for approval, backs up existing settings, and installs matching workflow instructions for your agent. Restart the agent afterward. [<a href="#reference-1">1</a>, <a href="#reference-2">2</a>]

**2. Ask a scoped question.** For example:

```text
I am authorized to inspect this Electron app at /path/to/app.
Using static analysis only, find how the "Export report" feature works.
Show the relevant modules, IPC channels, and source locations,
and list anything you could not resolve.
```

Starting with static analysis keeps the first pass read-only. Move to runtime capture only when a question needs it, and do that in an isolated environment.

**3. Or use the terminal directly.** The same JavaScript analysis is available as a one-off command:

```bash
npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json
```

For native binaries, configure Ghidra, IDA, or Hopper first; the CLI guide covers provider selection. [<a href="#reference-3">3</a>]

## REA FAQ

### What is REA (Reverse Engineer Anything)?

REA is an open-source MCP server and CLI that connects AI agents to local reverse-engineering tools. The agent asks questions about an app or binary; REA runs analyzers such as Ghidra, IDA, Hopper, or its built-in JavaScript and .NET readers and returns code, locations, and open questions.

### Is REA the same thing as MCP?

No. MCP (Model Context Protocol) is the standard way an agent calls external tools. REA is one MCP server: it exposes reverse-engineering tools over that protocol, and the same workflows are also available from its rea CLI.

### Do I need Ghidra, IDA, or Hopper?

Only for deep native analysis of compiled binaries. Static JavaScript/Electron and .NET inspection work without a native analysis engine. Setup can install Hopper after approval; Ghidra and IDA use your existing installations.

### Does REA upload my app?

REA analyzes targets locally, but its results go to your agent, and the model provider behind that agent has its own data policy. Review sensitive results before sharing them with a cloud model.

## References

1. <span id="reference-1"></span>morluto/rea. [“README.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/README.md) GitHub, v6.4.0.
2. <span id="reference-2"></span>morluto/rea. [“Installation guide.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/docs/installation.md) GitHub, v6.4.0.
3. <span id="reference-3"></span>morluto/rea. [“CLI guide.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/docs/cli.md) GitHub, v6.4.0.
4. <span id="reference-4"></span>morluto/rea. [“MCP contracts.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/docs/mcp-contracts.md) GitHub, v6.4.0.
5. <span id="reference-5"></span>morluto/rea. [“DX-Ball sound-panning case notes.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/website/evidence/dx-ball-sound-pan.md) GitHub, v6.4.0.
6. <span id="reference-6"></span>morluto/rea. [“Disclaimer.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/DISCLAIMER.md) GitHub, v6.4.0.
7. <span id="reference-7"></span>morluto/rea. [“Notion clipboard case notes.”](https://github.com/morluto/rea/blob/16f5ded4468d7100d3640f874f33ddbaa953a787/website/evidence/notion-clipboard.md) GitHub, v6.4.0.
