---
layout: article-sky
article_variant: research-review
zoomable_images: true
lang: en
title: "Pi Harness v2 to Pi Durable: Crash Recovery Explained"
seo_title: "Pi Harness v2 to Pi Durable: Crash Recovery"
description: "Follow Pi Harness v2 into Pi Durable: understand safe tool replay, interrupted model requests, result ordering, and what survives a process restart."
keywords: "Pi Harness v2, Pi Durable, pi-durable, agent harness architecture, agent crash recovery, safe tool replay"
tags: [pi-agent, coding-agents, agent-infrastructure]
categories: [frontier-research]
permalink: /tutorials/pi-agent-harness-v2-crash-recovery/
thumbnail: "/baoyu-cover-image_20261001_213950/首图.webp"
og_image: "/baoyu-cover-image_20261001_213950/首图.webp"
date: 2026-09-07
last_modified_at: 2026-10-09
author_name: "AgentsPulse Editorial Team"
cover_alt: "Conceptual illustration of layered durable records spanning an interruption, with two faint possible paths around an unknown effect"
cover_width: 1536
cover_height: 864
review_eyebrow: "Source-code analysis"
scope_note: "Pinned implementation, recovery-test assertions, and integration boundaries."
research_scope: "Pi Durable · Crash recovery · Tool replay"
dek: "The old AgentHarness API is gone. Here is how the current Pi Durable harness restores committed work, decides which tools may run again, and keeps history separate from model context."
key_takeaways:
  - "Current durable-agent integrations use experimental pi-durable, not the removed AgentHarness exports in pi-agent-core."
  - "A tool reruns only if both its stored and its current declaration say safe. An execute checkpoint cannot tell whether the external effect already happened."
  - "Parallel results enter history in completion order and model context in call order. After a restart, completed work is reused."
article_toc:
  - id: "todays-api"
    label: "Today’s API"
  - id: "state-and-execution"
    label: "State and Execution"
  - id: "the-crash-window"
    label: "The Crash Window"
  - id: "safe-tool-replay"
    label: "Safe Tool Replay"
  - id: "parallel-result-order"
    label: "Two Result Orders"
  - id: "model-request-recovery"
    label: "Model Request Recovery"
  - id: "storage-boundaries"
    label: "Storage Boundaries"
  - id: "integration-checklist"
    label: "Integration Checklist"
  - id: "check-your-understanding"
    label: "Predict a Restart"
  - id: "sources-and-version"
    label: "Sources and Version"
related_research:
  - url: "/tutorials/deepseek-harness-vs-pi-agent/"
    title: "DeepSeek Harness vs Pi Agent"
    description: "A practical comparison of plugin composition, tools, MCP, sandboxing, sessions, and deployment."
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "Why production agent systems separate framework APIs from the execution harness."
  - url: "/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/"
    title: "DeepSeek Harness Architecture"
    description: "How a plugin-runtime approach differs from Pi's minimal coding harness."
---
Pi Harness v2 raised a question that still matters for anyone building agent applications: after a crash, what can the runtime safely do again? The answer now lives in a different API. On October 1 the experimental `AgentHarness` was removed from `pi-agent-core`, and new durable-agent integrations should look at **Pi Durable**, the experimental `@earendil-works/pi-durable` package.

The change goes deeper than an import path. The current harness is built around conversations, documents, and task checkpoints, and it handles parallel result ordering and interrupted model requests differently from the old design. This article reads the October 8 source snapshot with one distinction in mind: Pi can restore a decision it committed locally, but that record cannot tell it what happened in an external system.

<h2 id="todays-api">Today’s API: Pi Durable, not the old AgentHarness</h2>

Earendil [introduced Pi Durable alongside Pi 1.0][announcement] on October 1. The announcement keeps it separate from the terminal coding agent: Pi Durable is a framework for agent applications whose conversations and work have to survive restarts. The coding-agent CLI stays, and so do its own session features.

The [agent-core changelog][agent-changelog] records the removal of the experimental harness and its public subpaths. The current [Pi Durable README][readme] warns that the API is experimental and may change without notice.

| Earlier v2/AgentHarness design | Current Pi Durable design |
|---|---|
| Session, AgentLane, Operation, and process-local Drive | Conversations, Entries, Documents, Submissions, and durable Tasks |
| Tool replay declarations `safe` / `never` | `safe` / `unsafe`; omission means `unsafe` |
| Save parallel results as `outcome_ready`, then place them in source order | Append tool results in completion order; order them for model context |
| Reopen a Session, then schedule `drive` | Open the Harness over storage, then start its task scheduler |

The left column describes a [historical implementation][old-harness]. Those names are gone, so changing the package name will not migrate an integration.

The [1.1.0 changelog][durable-changelog] (October 7) adds a few details integrators will care about: explicit storage scan order and cursor direction, lookup of historical conversation context, task timestamps, and `durationMs` on tool attempts. These change the API and what you can observe; none of them is a measured speedup. If you maintain a custom storage backend, work from the current scan contract rather than the older one.

<h2 id="state-and-execution">What survives: saved work, not the process running it</h2>

The current [concepts and resume contract][resume] keeps stored state apart from the machinery that advances it:

| Record or component | Role after restart |
|---|---|
| **Entries** | Immutable transcript records, including user inputs, assistant messages, and committed tool results |
| **Documents** | Mutable committed state beside the transcript: agent choices, live work, inbox, usage, and provider-facing identity |
| **Tasks** | Saved state machines with checkpoints, outcomes, and ownership |
| **Submissions** | Accepted inputs or writes; a client can reacquire them and wait for their result |
| **Registry, model access, and execution environment** | Host-supplied code and dependencies that must be available again |

One commit can append an entry, change a document, and advance a task together. That keeps the local record consistent. A remote service’s transaction sits outside that boundary.

<img src="/archify_20261008_190824/restart-boundary.webp" decoding="async" loading="lazy" width="1720" height="900" alt="A host opens a Harness over durable storage and starts a task scheduler. The registry and model dependencies are recreated; external systems remain outside the persisted-state boundary." data-zoomable title="Click to enlarge" />

*Figure 1. With a persistent backend, entries, documents, and tasks survive a process restart, and the host rebuilds the execution dependencies. The small outline marks persisted state; it is not a scheduler that runs on its own.*

### Opening storage does not start work

The README’s minimal restart pattern:

```typescript
// Recreate models and registry before this point.
const harness = await Harness.open(
  await openNodeSqliteStorage("./session.sqlite"),
  { models, registry },
  context,
);
const root = await harness.root(context);
harness.resume();
```

This covers only the restart step. `openNodeSqliteStorage` comes from `@earendil-works/pi-durable/storage/sqlite/node`, and tools that touch files or processes also need a suitable `env` factory. Calling `resume()` starts the scheduler; so does submitting or waiting. `MemoryStorage` is fine for tests, but its contents disappear with the process.

A conversation stores extension names, not the functions behind them, so reinstall the extensions before resuming. If a tool no longer resolves, the recovery decision can change.

<h2 id="the-crash-window">The tool checkpoint cannot prove an external action happened</h2>

Take an upload tool. The current [tool task][tool-task] validates the arguments, runs `beforeTool`, and commits an intent before it calls `execute()`. The saved checkpoint holds `phase: "execute"`, the final arguments, and the tool’s replay policy.

The phase name is easy to misread. It marks execution as the next recovery boundary and says nothing about whether the upload finished. Two different histories leave the same checkpoint:

1. Pi saves the intent, then the process dies before the upload starts.
2. The upload succeeds, then the process dies before Pi saves its result.

<img src="/baoyu-article-illustrator_20261008_192341/crash-boundary.webp" decoding="async" loading="lazy" width="1536" height="1024" alt="A crash before an external action and a crash after the action but before result commit both leave phase execute and an unknown outcome." data-zoomable title="Click to enlarge" />

*Figure 2. Two different external histories, one `execute` checkpoint on reopen. A saved intent records what Pi meant to do, not what happened.*

### Predict recovery from the last committed boundary

| Where the process stops | What Pi can recover | Consequence |
|---|---|---|
| Before the execution intent commits | The earlier `call` phase | Preparation and hooks can run again before execution. |
| After intent, before the external action | An `execute` checkpoint without a final result | Apply replay policy; Pi cannot distinguish this from an action that already ran. |
| After the action, before result settlement commits | The same checkpoint | The external outcome remains unknown. |
| After final settlement commits | A terminal task and its tool-result entry | Reuse the saved result; do not rerun that completed task. |

The [recovery tests][tool-recovery] cover an interrupted call and an interruption before the intent commits. They simulate close and reopen on persistent storage. Reading them tells you how the code is meant to behave, not how it fares under power loss.

<h2 id="safe-tool-replay">Safe tool replay requires two permissions</h2>

When Pi recovers from an `execute` checkpoint, it checks the policy stored before the original attempt and the tool’s current declaration. Both have to agree:

| Stored policy | Current tool | Recovery of the unfinished call |
|---|---|---|
| `safe` | Resolves and declares `safe` | May rerun |
| `safe` | Declares `unsafe`, or is unavailable | Settle as interrupted |
| `unsafe` | Now declares `safe` | Still settle as interrupted |
| `unsafe` | Declares `unsafe` | Settle as interrupted |

The matrix follows the [implementation][tool-task] and the [policy-combination tests][tool-recovery]. Cancellation takes a separate abort path, and marking a call `safe` does not override a durable abort intent.

For an interrupted unsafe call, the model gets an error result carrying whatever output and details were committed, plus a diagnostic that the tool may have partially run. The diagnostic claims neither that nothing happened nor that the action succeeded, because Pi cannot know which.

### What `safe` does not promise

`safe` allows the call to run again during recovery. It does not pin the returned data, the function’s implementation, or the working directory, so a read can be safe to repeat and still return different contents. One recovery test shows a safe call running in the conversation’s current environment after the working directory changed.

`unsafe` stops automatic replay of this one unfinished task. It does not undo an action that already happened, and the model can still request a fresh invocation on a later turn. If your application must never upload or charge twice, it needs an external operation ID plus idempotency or reconciliation on the service side.

### Memos help only when application code uses them

A durable task memo is a named value where the first write wins. The [runtime contract][memo-contract] lets tool code read it and return early. Here is a sketch of an execution body, assuming `upload` returns a string receipt and the service really enforces the idempotency key:

```typescript
const previous = await api.memo<string>("upload", context);
if (previous !== undefined) {
  return { content: [{ type: "text", text: previous }] };
}

// storeKey must be a stable application namespace.
const key = `${storeKey}:${api.taskId}:upload`;
const receipt = await upload(args, { idempotencyKey: key });
const saved = await api.memo("upload", receipt, context);
return { content: [{ type: "text", text: saved }] };
```

Once the receipt is committed, the memo keeps `upload` from running again. A crash between the upload and the memo commit still leaves a gap, and the idempotency key closes it only if the remote service honors the key. A local memo on its own does not give you exactly-once side effects, and this sketch is no reason to declare an arbitrary upload tool `safe`.

<h2 id="parallel-result-order">Parallel tools have two different result orders</h2>

Say the assistant calls A, then B, and B finishes first. Current Pi Durable appends B’s result first. The transcript follows completion order; the old `outcome_ready` staging that held B back is gone.

When Pi builds the model’s context, [its projection][context-order] sorts tool results back into the assistant’s call order. The same saved results read B, A in history and A, B in the model context.

<img src="/baoyu-article-illustrator_20261008_192341/result-order.webp" decoding="async" loading="lazy" width="1536" height="1024" alt="The transcript holds saved results B then A, while model context projects those same results as A then B." data-zoomable title="Click to enlarge" />

*Figure 3. Completion order and model-context order are two views of one set of results; nothing ran twice. Assumes the model called A before B and B finished first.*

Now put a crash after B commits and before A settles. B’s finished task and result stay saved. Only A needs recovery, and A reruns only if the replay gate allows it. Once the round settles, the next model request sees A, B in call order. If your UI renders transcript entries directly, expect that order to differ from the order of tool-result messages the model receives.

<h2 id="model-request-recovery">A cut-off model request is resent, not resumed token by token</h2>

Model recovery uses a different boundary from tool replay. In the [request-recovery tests][model-recovery], an interrupted prepared request is sent again with its saved messages and options, and preparation does not run a second time. If a partial answer was committed, recovery can first save it as an assistant entry marked `aborted`, then resend the same request.

You keep a record of the interrupted attempt. You do not get the old stream back from its last token, and the retry may produce a different answer.

The README documents configurable commit intervals for partial output, with a 100 ms default. These throttle how often progress is written. They do not cap how much you can lose when storage is slow. After a restart, only committed progress is there.

Each conversation also persists a provider-facing session identity. The [resume documentation][resume] says it is used for prompt-cache and session affinity, and the changelog shows it arrived in 1.0.2. Affinity does not deduplicate requests at the provider and is not a final billing receipt. The UUID tells you neither that generation happened exactly once nor what it finally cost.

<h2 id="storage-boundaries">Durability depends on the backend and the failure being tested</h2>

Pi Durable ships persistent SQLite and JSONL storage alongside memory storage. A consistent local commit is valuable, but surviving a process restart is a weaker property than surviving sudden power loss with every acknowledged commit intact.

In the [ordinary JSONL commit path][jsonl-commit] we reviewed, the storage appends the affected sidecar records, optionally syncs those files, then appends a marker to the main journal without syncing that new marker. So `fsync: true` alone does not show that the newest acknowledged commit survives power loss. That finding covers this one adapter; check the adapter and storage settings you actually run.

The announcement also calls for one owning process per storage. Several clients can attach to that owner, but separate processes opening and writing the same state are no substitute for an ownership strategy. This is the [framework-versus-runtime gap](/tutorials/agent-framework-harness-runtime-production/) in practice: the SDK supplies recovery primitives, and the application still needs operational rules around them.

<h2 id="integration-checklist">An integration checklist you can actually test</h2>

Before relying on restart recovery:

- **Pin the API.** Work from current Pi Durable docs and a known package version, and keep old AgentLane/Drive examples out of new code.
- **Rebuild execution dependencies.** Reopen the same persistent storage, reinstall extensions, recreate model access and environments, and start the scheduler under a single writable owner.
- **Retry admission with the same identity.** A submission’s `requestId` lets the conversation find the existing submission when a client retries. It does nothing for tool side effects.
- **Audit each safe tool.** Check its external idempotency, and what happens if the code, environment, or policy changes before recovery.
- **Inject failures around commits.** Crash at the execution-intent boundary, after a side effect but before settlement, and after one parallel result commits while its sibling is still running. Count external calls and inspect both history and model context.
- **Test the failures your deployment can have.** A clean close and reopen is worth testing, but it says nothing about power loss, broken disks, or multiple writers.

[DeepSeek Harness vs Pi Agent](/tutorials/deepseek-harness-vs-pi-agent/) compares composition choices more broadly. It does not show that the two runtimes offer the same recovery guarantees.

<h2 id="check-your-understanding">Predict a restart before reading the answers</h2>

Assume a persistent backend, the same storage, dependencies reinstalled correctly, and a restarted scheduler:

1. An upload has an `execute` checkpoint with stored `unsafe`. The new tool declaration says `safe`. Will recovery run it?
2. A and B are called in that order. B’s final result commits; A is interrupted and both its policies are `safe`. Which tool may rerun, and what are the two result orders if A finishes later?
3. A remote upload succeeds, but the process dies before its receipt memo commits. Does the memo API alone prevent another upload?
4. A partial model answer is committed before interruption. Does Pi reconnect to its last token?

<details markdown="1">
<summary>Show the recovery predictions</summary>

1. **No.** The current declaration cannot upgrade a stored `unsafe`. The model gets an interrupted result, and the external outcome stays unknown.
2. **A may rerun; B’s committed result is reused.** History can read B, A while model context shows A, B. B is not replayed to fix the order.
3. **No.** No memo was committed, so there is nothing to read. Only the remote service honoring the same operation key, or an application reconciliation step, prevents the duplicate.
4. **No.** The saved partial can become an `aborted` entry, and the prepared request is sent again. Pi does not continue the old stream, and the new answer may differ.

</details>

<h2 id="sources-and-version">Sources and version scope</h2>

This article was substantially rebuilt on **October 8, 2026**, against Pi revision [`ce950d7`][snapshot]. It was first published on September 7. Wording was edited on October 9; the source verification remains tied to the October 8 snapshot. Version dates come from the agent-core and Pi Durable changelogs, not from this page.

Primary sources are the [official Pi Durable announcement][announcement], the [current README][readme], the [tool task][tool-task], the [context projection][context-order], and the linked recovery tests. The AgentHarness comparison draws on a separate [`3e94512` snapshot][old-harness]; nothing about the current API or the figures comes from that revision.

**What we verified:** we read the upstream test assertions but did not run them for this article. They use simulated provider responses and persistent close/reopen, and we make no claims based on a live provider, an upload service, or a power-loss test. Site builds, page checks, and image interactions were verified separately.

[announcement]: https://earendil.com/posts/pi-durable
[snapshot]: https://github.com/earendil-works/pi/tree/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d
[readme]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/README.md
[resume]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/README.md#persist-and-resume
[agent-changelog]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/agent/CHANGELOG.md#100---2026-10-01
[durable-changelog]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/CHANGELOG.md
[old-harness]: https://github.com/earendil-works/pi/blob/3e9451238337071b74ba5cdd53f1ab7cf4100ae8/packages/agent/docs/harness.md
[tool-task]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/src/harness/tool.ts#L38-L119
[tool-recovery]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/test/harness-tools-recovery.test.ts#L112-L207
[memo-contract]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/src/types.ts#L203-L206
[context-order]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/src/harness/context.ts
[model-recovery]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/test/harness-generation-recovery.test.ts#L74-L160
[jsonl-commit]: https://github.com/earendil-works/pi/blob/ce950d78f424dcaf9f5d6a03ce80ab141130eb1d/packages/durable/src/storage/jsonl/storage.ts#L277-L305
