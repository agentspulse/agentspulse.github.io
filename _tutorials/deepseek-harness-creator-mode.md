---
layout: article-sky
article_variant: research-review
lang: en
title: "DeepSeek Harness Creator Mode: How It Works and Its Risks"
seo_title: "DeepSeek Harness Creator Mode: How It Works & Risks"
description: "DeepSeek Harness Creator Mode explained from source: runtime inspection, dynamic plugins, custom agent presets, process lifetime, and shell-level risks."
keywords: "DeepSeek Harness Creator Mode, DSH Creator Mode, Cordis runtime, agent presets, self-modifying agents"
tags: [deepseek-harness, agent-infrastructure, agent-security]
categories: [frontier-research]
permalink: /tutorials/deepseek-harness-creator-mode/
thumbnail: "/images/deepseek-harness-creator-mode/creator-planes.jpg"
og_image: "/images/deepseek-harness-creator-mode/creator-planes.jpg"
date: 2026-08-18
last_modified_at: 2026-08-18
author_name: "AgentsPulse Editorial Team"
cover_alt: "DeepSeek Harness Creator Mode host and agent planes"
cover_width: 1200
cover_height: 675
paper_count: 1
research_scope: "DeepSeek Harness · Creator Mode · Runtime Extension"
dek: "DeepSeek Harness Creator Mode explained from source: runtime inspection, dynamic plugins, custom agent presets, process lifetime, and shell-level risks."
key_takeaways:
  - "Creator Mode extends Standard with runtime inspection, dynamic-package lifecycle tools, and guidance for authoring custom agent presets."
  - "Dynamic packages are session-owned but execute in the shared process, remain ephemeral, and may affect other sessions."
  - "The official source treats Creator Mode as shell-equivalent access; its node:vm isolation is explicitly not a security boundary."
article_toc:
  - id: "what-is-deepseek-harness-creator-mode"
    label: "What Is DeepSeek Harness Creator Mode?"
  - id: "host-plane-boundary"
    label: "Host Plane Boundary"
  - id: "runtime-inspection"
    label: "Runtime Inspection"
  - id: "dynamic-package-lifecycle"
    label: "Dynamic Package Lifecycle"
  - id: "host-and-client-halves"
    label: "Host and Client Halves"
  - id: "version-identity"
    label: "Version Identity"
  - id: "process-lifetime"
    label: "Process Lifetime"
  - id: "security-boundary"
    label: "Security Boundary"
  - id: "api-naming-drift"
    label: "API Naming Drift"
  - id: "when-should-you-use-creator-mode"
    label: "When Should You Use Creator Mode?"
  - id: "creator-mode-faq"
    label: "Creator Mode FAQ"
  - id: "selected-sources"
    label: "Selected Sources"
related_research:
  - url: "/tutorials/deepseek-harness-modes-explained/"
    title: "DeepSeek Harness Modes Explained"
    description: "Where Creator sits relative to Standard, PTC, and Minimal."
  - url: "/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/"
    title: "DeepSeek Harness Architecture"
    description: "The Cordis plugin runtime and two-plane composition Creator modifies."
  - url: "/tutorials/cordis-spatiotemporal-composability/"
    title: "Cordis Spatiotemporal Composability"
    description: "The lifecycle and dependency model behind dynamic plugin composition."
---
DeepSeek Harness Creator Mode is the trusted preset for inspecting and modifying the live Cordis runtime. It extends Standard Mode with runtime-inspection tools, in-memory dynamic plugins, and guidance for authoring custom agent presets. It is not a creative-writing mode. Because `cordis_run` evaluates model-written JavaScript inside the shared DSH process, the official source tells operators to treat Creator Mode like shell access. This guide is verified against DSH `v0.1.0-rc.7` (`99f6f02`).

| Question | Short answer |
|---|---|
| What is Creator Mode for? | Inspecting the runtime, testing Cordis plugins, and authoring agent presets. |
| Are dynamic plugins permanent? | No. They live in process memory and disappear on stop, undefine, unload, or restart. |
| Are effects limited to one session? | Control is session-scoped, but runtime effects may reach the shared process. |
| Is the `node:vm` sandbox a security boundary? | No. The source explicitly treats the toolset as shell-equivalent access. |

For the broader runtime model, start with the [DeepSeek Harness architecture guide](/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/).

## What Is DeepSeek Harness Creator Mode?

The Creator preset begins from the full Standard composition and layers self-referential tooling on top. Its shipped directory identifier is `cordis`, and its display name translates to "Creator Mode".

The preset's declared purpose is to let an agent author or experiment with another agent composition. Concretely, the additions beyond Standard are the Cordis toolset (which can read and write the runtime the agent itself runs in), a skill teaching composition authoring (`editing-cordis-compositions`), and a persona extension that distinguishes which plane—agent or host—an edit belongs to. The preset metadata summarizes this as runtime inspection, plugin experimentation, and preset-authoring guidance.

Because `cordis_run` evaluates a defined package's model-written JavaScript against the live runtime, the current toolset equates a Creator session with shell access. Authored presets are written to `${DSH_HOME:-$HOME/.dsh}/.agent-presets/<id>/`, separate from the shipped install directory, which the persona explicitly forbids editing.

## Host Plane Boundary

The central distinction is between what exists once for the process and what exists once per session. The host composition owns the registries themselves—tools, systemPrompt, agents, agent-loop, sessions—along with everything that crosses sessions: persistence, sandbox and approval stack, model route, and the subagent registry with its spawn/fork backends. An agent preset contributes what one session adds to those registries: its tool plugins, persona, prompt sections, and compaction policy, mounted under that session's scope and unwound with it.

Resolution follows a parent-chain rule: an agent's views resolve `agent → preset → global`, nearest shadowing farthest. The preset's standing mount registers into the preset's scope layer, and every session parented under it inherits those registrations while sibling presets remain invisible.

A service whose consumer lives outside the agent plane cannot move into a preset. The subagent registry illustrates why: it answers cross-session queries for the host api-proxy, so a per-session copy both starves the host row and collides on the second session, since a provider name registers once. Conversely, a row that publishes a service without an `isolate` realm places it in the process-global realm; the second session mounting that preset collides with the first, and the mount rejects the configuration rather than letting the collision surface later.

![DeepSeek Harness Creator Mode host and agent planes](/images/deepseek-harness-creator-mode/creator-planes.jpg)

*Creator distinguishes shared host infrastructure from the scoped capabilities contributed by an agent preset.*

## Runtime Inspection

Runtime inspection in Creator Mode is a read-only discovery layer—it describes contracts but is not itself a business API and cannot mutate state. The toolset separates three concerns: a compact provider listing (`cordis_inspect_list`), targeted read-only queries (`cordis_inspect_query`), and session-scoped self-inspection (`cordis_inspect_self`).

The central mechanism lives in `src/inspect.ts`, which intersects a compile-time API catalog with the live service store. What is *running* comes from the store; what each service *can do* comes from the catalog. A live service the catalog does not cover is reported as reachable with no signatures rather than omitted. The catalog itself is generated by a lexical scan of slot declarations and registration call sites, gated by `pnpm run verify-client-catalog`; the generator fails loudly when a slot lacks registrant-facing prose or uses a non-literal kind/scope.

| Tool | Returns | Constraint |
|------|---------|-----------|
| `cordis_inspect_list` | Every known Host/Client provider with platform, purpose, methods, and schemas | Must be called before code generation; names must not be guessed |
| `cordis_inspect_query` | Exact service methods, event modes, slot trees, tool schemas, or theme tokens for one provider method | Cannot invoke business services or modify the runtime |
| `cordis_inspect_self` | Session-owned plugins, version pointers, package source, and diagnostics at increasing detail levels | Read-only; packageId requires pluginId |

A key boundary: the Service/Event catalog describes which interfaces a deployment version permits but does not guarantee a service is currently mounted. Because the catalog is a compile-time fact, a copied list and a freshly read one say the same thing within a single deployment.

## Dynamic Package Lifecycle

A package in the Cordis dynamic system is immutable once defined; execution, cessation, and deletion are separate operations with distinct permanence guarantees.

**Definition.** `cordis_define` creates a plugin's first version or appends an immutable package to an existing plugin. The host runner trims metadata, prechecks each half's syntax by compiling it (running nothing), mints an ID (`dyn-<n>`), and records the definition against the owning session. Unparseable code is refused before an ID exists. Definition does not execute `apply`, request approval, or update the current version pointer.

**Activation.** `cordis_run` activates an exact package. For host-only packages, the host half is evaluated in a `node:vm` sandbox under the `cordis-dynamic` group fiber. For packages with a browser half, `run` emits `cordis/request-run` and suspends until a connected page allows or declines it; there is no timer, only the caller's `AbortSignal` can cancel. User approval may therefore be required before effects begin.

**Stopping.** `cordis_stop` unwinds one live dispatch—handlers are dropped, the host-half fiber is disposed to quiescence, and a `dynamicCordisRunner/retract` broadcast is sent—while leaving the definition runnable and all version pointers intact.

**Deletion.** `cordis_undefine` stops a running definition first, then permanently removes the plugin and all its packages. It should not be called while rollback, inspection, or restart is still needed.

![DeepSeek Harness Creator Mode dynamic package lifecycle](/images/deepseek-harness-creator-mode/creator-lifecycle.jpg)

*The reviewed lifecycle separates inspection, immutable definition, activation, reversible stopping, and permanent removal.*

## Host and Client Halves

A dynamic package comprises up to two independent code halves: a **host half** that runs in the DSH Node process and a **client half** that runs in an open browser page. The split follows from process topology—host code has access to Cordis services while client code has access to declared UI slots—and a package may contain either half or both.

**Host half.** When `cordis_run` activates a package, the host half is evaluated inside a `node:vm` sandbox within the DSH process. It can register services, events, dynamic tools, and invoke handlers via the mounted plugin façade. The sandbox isolates globals (Node globals are absent or redirect to Cordis services such as `ctx.fs`, `ctx.web`, and `ctx.bash`) but is explicitly not a security boundary. The registry lives in process memory; nothing is written to disk, and a restarted process has no definitions.

**Client half.** The client half is delivered to every open browser page by the host runner. It acts on the slot surface—keys declared in `SlotMap` merges and `slots.register` call sites—and may call back to its own host half through private JSON methods registered with `harness.handle`; routing is client-to-host only, with no host-to-browser invoke direction. Acknowledgement is governed by `ackTimeoutMs` on the runner service.

**Activation asymmetry.** A host-only package completes activation when its fiber starts. A package with a client half also waits for page acknowledgement. If a page reloads, it holds no state until someone runs the package again, which re-fetches the client half and binds the live host half. Four forwarded events (`cordis/request-run`, `cordis/request-run-resolved`, `dynamicCordisRunner/package`, `dynamicCordisRunner/retract`) let the browser track run state without receiving code.

## Version Identity

A plugin's identity and its source code occupy separate, non-interchangeable layers. The `pluginId` (minted as `dyn-<n>` by `cordis_define`) is the stable handle for a plugin across its lifetime; each source revision attached to that plugin is an immutable package identified by its own `packageId`. Querying `cordis_inspect_self` with only a `pluginId` returns version pointers and every package summary, while adding a `packageId` returns that package's frozen source and diagnostics.

Updating a plugin appends a new immutable package rather than overwriting an earlier one. The `cordis_define` tool "creates a Plugin's first version or appends an immutable Package to an existing Plugin". Previous packages remain addressable for inspection or rollback via `cordis_run`.

A failed update does not automatically restart a previous package. The registry is process memory with no automatic restoration: "a restarted process legitimately has no definitions, and a card whose id no longer resolves says exactly that rather than pretending it can run. Nothing here is written to disk, and no definition is restored automatically". To recover, the caller must explicitly issue `cordis_run` targeting the desired `packageId`, or retry the failed definition. The skill guidance distinguishes `run` for "first activation, restart, or rollback" from `update` for switching versions, making the operator responsible for choosing the correct recovery path.

## Process Lifetime

Dynamic packages created through the self-referential Cordis toolset (`cordis_define`, `cordis_run`) exist exclusively in the shared DSH process memory. They persist across subsequent conversation turns and may affect other sessions within the same process, but they are not durable artifacts. A dynamic package disappears upon any of: `cordis_stop`, `cordis_undefine`, toolset unload, or DSH restart.

The boundary is strict: dynamic packages create no plugin file, install no package, change no `cordis.yml` or personal/project configuration, and cannot be promoted to persistent state automatically. Every verb is session-scoped—a package is visible and controllable only in the session that defined it.

To convert a runtime experiment into a lasting capability, the operator must follow the file-based preset workflow. The supplied documentation describes `ctx.agentPresets.copy(from, id, name?)` as the only authoring write for presets; it duplicates an existing preset's directory into the user root where it can then be edited freely. Shipped presets (`standard`, `code`, `minimal`, `cordis`) must never be modified in place—only copied and then amended. Discovery is unmemoized, so a newly authored preset is visible to subsequent `list()` or `resolve()` calls without restart.

This separation keeps runtime experiments ephemeral while ensuring that durable configuration changes pass through version-controllable files whose integrity survives process restarts and deployment upgrades.

## Security Boundary

The vm that executes mounted code isolates globals but is not a security boundary. Node globals are absent or redirect to Cordis services such as `ctx.fs`, `ctx.web`, and `ctx.bash`, and writes to `globalThis` stay local to the sandbox; however, host-realm helpers make escape possible. A mounted plugin receives a façade without framework internals, yet the services that façade exposes affect the live runtime directly.

Dynamic packages live in the shared DSH process memory. They remain active across later turns and may affect other sessions in that process until explicitly stopped, undefined, or the process restarts. Every verb is session-scoped for visibility and control, but the runtime effects are not isolated to one session.

The official source instructs operators to treat the toolset like shell access. The `cordis` agent preset header states: "Treat a session on this preset as shell access — the toolset's own documentation makes the same statement". The toolset README repeats: "Treat this toolset like bash access". A composition authored by this agent becomes a preset other sessions mount, compounding the trust surface.

Operators should therefore gate access to Creator Mode with the same controls applied to shell or root access on the host, and should not rely on the vm's global isolation as a containment mechanism.

![DeepSeek Harness Creator Mode security boundary](/images/deepseek-harness-creator-mode/creator-security.jpg)

*Session ownership limits who controls a package, not how far its effects can reach inside the shared runtime.*

## API Naming Drift

The current executable tool surface exposed by `@deepseek-ai/dsh-tool-cordis` comprises `cordis_define`, `cordis_run`, `cordis_stop`, and `cordis_undefine`, plus the inspection tools `cordis_inspect_list`, `cordis_inspect_query`, and `cordis_inspect_self`. No tool named `cordis_mount` appears in the registered tool definitions.

Two narrative passages still use the older `cordis_mount` wording. The checked comment block at the top of the Creator preset composition file states that "`cordis_mount` evaluates model-written JavaScript against the live runtime". The composition-editing skill document likewise describes `cordis_mount` as returning "only the mount acknowledgement". These are explanatory prose rather than tool registrations; the source that actually registers model-callable tools does not define a `cordis_mount` entry.

When the two conflict, readers should follow the generated tool catalog and the current tool definitions in `tool-cordis/src/index.ts`, not stale narrative names in skill documents or preset comments. The README explicitly directs users to the generated catalog for "exact model-facing schemas".

Because the Cordis toolset evaluates model-written code against the live runtime and dynamic packages may affect other sessions in the same process, enable the Creator preset only for trusted sessions that require runtime extension or preset authoring.

## When Should You Use Creator Mode?

Use Creator Mode only when the task genuinely requires changing the harness rather than the project being edited. Appropriate cases include inspecting a live Cordis service, testing an ephemeral plugin, or creating a custom preset from a shipped baseline.

Do not use it as the default coding mode. Standard Mode is the safer fit for ordinary repository work, while [PTC Mode](/tutorials/deepseek-harness-ptc-mode/) is the relevant alternative when the goal is programmatic multi-tool orchestration. Creator Mode expands privilege, not model intelligence.

Before enabling it, confirm that the session is trusted, the host process contains no unrelated sensitive workloads, and every dynamic package has an explicit stop or rollback plan.

## Creator Mode FAQ

### Is Creator Mode for creative writing?

No. It is for runtime inspection, Cordis plugin experiments, and custom agent-preset authoring.

### Can Creator Mode modify other sessions?

A session owns the dynamic package definitions it creates, but their effects execute in the shared process and may affect other sessions.

### Do Creator Mode plugins survive a DSH restart?

No. Dynamic packages are kept in process memory. Durable capabilities must be written into user-owned preset files.

### Is Creator Mode sandboxed?

It uses a `node:vm` execution environment, but the official source explicitly says this is not a security boundary and should be treated like shell access.

## Selected Sources

- [Creator preset metadata](https://github.com/deepseek-ai/deepseek-harness/blob/99f6f02fecdb7dff40c3fbc9470f5907c29f74ca/apps/cli/config/agent-presets/cordis/preset.yml)
- [Creator preset composition](https://github.com/deepseek-ai/deepseek-harness/blob/99f6f02fecdb7dff40c3fbc9470f5907c29f74ca/apps/cli/config/agent-presets/cordis/agent.cordis.yml)
- [Self-referential Cordis toolset](https://github.com/deepseek-ai/deepseek-harness/blob/99f6f02fecdb7dff40c3fbc9470f5907c29f74ca/packages/extensions/tool-cordis/README.md)
- [Creator tool definitions](https://github.com/deepseek-ai/deepseek-harness/blob/99f6f02fecdb7dff40c3fbc9470f5907c29f74ca/packages/extensions/tool-cordis/src/index.ts)
- [Cordis host runner](https://github.com/deepseek-ai/deepseek-harness/blob/99f6f02fecdb7dff40c3fbc9470f5907c29f74ca/packages/extensions/cordis-host-runner/README.md)
- [Cordis runner sandbox tests](https://github.com/deepseek-ai/deepseek-harness/blob/99f6f02fecdb7dff40c3fbc9470f5907c29f74ca/packages/extensions/cordis-host-runner/tests/sandbox.spec.ts)
