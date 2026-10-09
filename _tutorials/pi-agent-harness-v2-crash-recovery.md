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
last_modified_at: 2026-10-08
author_name: "AgentsPulse Editorial Team"
cover_alt: "Conceptual illustration of layered durable records spanning an interruption, with two faint possible paths around an unknown effect"
cover_width: 1536
cover_height: 864
review_eyebrow: "Source-code analysis"
scope_note: "Pinned implementation, recovery-test assertions, and integration boundaries."
research_scope: "Pi Durable · Crash recovery · Tool replay"
dek: "The old AgentHarness API is gone. Understand how the current Pi Durable harness restores committed work, decides which tools may rerun, and keeps history distinct from model context."
key_takeaways:
  - "Current durable-agent integrations use experimental pi-durable, not the removed AgentHarness exports in pi-agent-core."
  - "Tool replay needs both stored and current safe declarations; an execute checkpoint alone cannot prove whether the external effect happened."
  - "Parallel results enter history in completion order but model context in call order; restart recovery reuses completed work."
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
Pi Harness v2 raised a question that still matters for agent applications: **after a crash, what can the runtime safely do again?** The answer now belongs to a different API. Since October 1, the experimental `AgentHarness` has been removed from `pi-agent-core`; new durable-agent integrations should inspect **Pi Durable**, the experimental `@earendil-works/pi-durable` package.

This is not just a renamed import. The current agent harness uses conversations, documents, and task checkpoints. It also handles parallel result ordering and interrupted model requests differently from the old design. This article follows the October 8 source snapshot and teaches one practical distinction: **recovering a committed local decision is not the same as knowing what happened in an external system.**

<h2 id="todays-api">Today’s API: Pi Durable, not the old AgentHarness</h2>

Earendil [introduced Pi Durable alongside Pi 1.0][announcement] on October 1. The announcement distinguishes it from the terminal coding agent: Pi Durable is a framework for building agent applications whose conversations and work need to survive restarts. It does **not** replace the coding-agent CLI or remove its separate session features.

The [agent-core changelog][agent-changelog] records the removal of the experimental harness and its public subpaths. The current [Pi Durable README][readme] explicitly warns that its API is experimental and can change without notice.

| Earlier v2/AgentHarness design | Current Pi Durable design |
|---|---|
| Session, AgentLane, Operation, and process-local Drive | Conversations, Entries, Documents, Submissions, and durable Tasks |
| Tool replay declarations `safe` / `never` | `safe` / `unsafe`; omission means `unsafe` |
| Save parallel results as `outcome_ready`, then place them in source order | Append tool results in completion order; order them for model context |
| Reopen a Session, then schedule `drive` | Open the Harness over storage, then start its task scheduler |

The left column is a [historical implementation][old-harness], not a list of current imports. Do not migrate an integration by changing only the package name.

The [October 7, 1.1.0 changelog][durable-changelog] adds integration-relevant details: explicit storage scan order and cursor direction, historical conversation-context lookup, task timestamps, and tool-attempt `durationMs`. These are API and observability changes, not measured speedups. Custom storage implementations should read the current scan contract rather than copy the older one.

<h2 id="state-and-execution">What survives: saved work, not the process running it</h2>

The current [concepts and resume contract][resume] separate stored state from the machinery that advances it:

| Record or component | Role after restart |
|---|---|
| **Entries** | Immutable transcript records, including user inputs, assistant messages, and committed tool results |
| **Documents** | Mutable committed state beside the transcript: agent choices, live work, inbox, usage, and provider-facing identity |
| **Tasks** | Saved state machines with checkpoints, outcomes, and ownership |
| **Submissions** | Accepted inputs or writes; a client can reacquire them and wait for their result |
| **Registry, model access, and execution environment** | Host-supplied code and dependencies that must be available again |

A commit can append an entry, change a document, and advance a task together. That atomic boundary keeps the local record coherent. It does not include a remote service’s transaction.

<img src="/archify_20261008_190824/restart-boundary.webp" decoding="async" loading="lazy" width="1720" height="900" alt="A host opens a Harness over durable storage and starts a task scheduler. The registry and model dependencies are recreated; external systems remain outside the persisted-state boundary." data-zoomable title="Click to enlarge" />

*Figure 1. Stored entries, documents, and tasks survive a process restart with a persistent backend. The host reconstructs execution dependencies. The small outline marks persisted state, not an autonomous scheduler.*

### Opening storage is not the instruction to run

The README’s minimal restart pattern is:

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

This is a restart fragment, not a complete setup program. `openNodeSqliteStorage` comes from `@earendil-works/pi-durable/storage/sqlite/node`; tools that need files or processes also require a suitable `env` factory. `resume()` starts the scheduler, and submitting or waiting starts it too. `MemoryStorage` is useful for tests but does not preserve work across process loss.

Conversations store extension names, not executable functions. Reinstall the relevant extensions before resuming. A tool that no longer resolves can change the recovery decision.

<h2 id="the-crash-window">The tool checkpoint cannot prove an external action happened</h2>

Consider an upload tool. The current [tool task][tool-task] validates its arguments, applies `beforeTool`, and commits an intent before calling `execute()`. The saved checkpoint contains `phase: "execute"`, the final arguments, and the tool’s replay policy.

That phase name is easy to misread. It means **execution is the next recovery boundary**, not “the upload completed.” Two different histories can leave the same checkpoint:

1. Pi saves the intent, then the process dies before the upload starts.
2. The upload succeeds, then the process dies before Pi saves its result.

<img src="/baoyu-article-illustrator_20261008_192341/crash-boundary.webp" decoding="async" loading="lazy" width="1536" height="1024" alt="A crash before an external action and a crash after the action but before result commit both leave phase execute and an unknown outcome." data-zoomable title="Click to enlarge" />

*Figure 2. The two external histories differ, but Pi reopens with the same `execute` checkpoint. A saved intent is not a completion receipt.*

### Predict recovery from the last committed boundary

| Where the process stops | What Pi can recover | Consequence |
|---|---|---|
| Before the execution intent commits | The earlier `call` phase | Preparation and hooks can run again before execution. |
| After intent, before the external action | An `execute` checkpoint without a final result | Apply replay policy; Pi cannot distinguish this from an action that already ran. |
| After the action, before result settlement commits | The same checkpoint | The external outcome remains unknown. |
| After final settlement commits | A terminal task and its tool-result entry | Reuse the saved result; do not rerun that completed task. |

The [recovery tests][tool-recovery] cover both an interrupted call and interruption before intent. They simulate close/reopen with persistent storage; reading these assertions is not a power-loss experiment.

<h2 id="safe-tool-replay">Safe tool replay requires two permissions</h2>

On recovery from an `execute` checkpoint, Pi checks **both** the policy stored before the original attempt and the tool’s current declaration:

| Stored policy | Current tool | Recovery of the unfinished call |
|---|---|---|
| `safe` | Resolves and declares `safe` | May rerun |
| `safe` | Declares `unsafe`, or is unavailable | Settle as interrupted |
| `unsafe` | Now declares `safe` | Still settle as interrupted |
| `unsafe` | Declares `unsafe` | Settle as interrupted |

This matrix follows the [implementation][tool-task] and the [policy-combination tests][tool-recovery]. Cancellation has its own abort path; marking a call safe does not override durable abort intent.

For an interrupted unsafe call, the model receives an error result with the output and details committed so far. The diagnostic says the tool may have partially run. That is deliberately weaker than either “nothing happened” or “the action succeeded.”

### What `safe` does not promise

`safe` permits recovery execution; it does not freeze the returned data, function implementation, or working directory. A read can be repeatable without returning the same contents. The recovery tests also show a safe call using the conversation’s **current** environment after a working-directory change.

Likewise, `unsafe` prevents automatic replay of this unfinished task. It does not undo the first action, and it does not prevent a later model turn from requesting a new invocation. Applications that must prohibit a duplicate upload or payment need an external operation identity and service-side idempotency or reconciliation.

### Memos help only when application code uses them

A durable task memo is a named, first-writer-wins value. The [runtime contract][memo-contract] lets tool code read it and return early. Here is an execution-body sketch, assuming `upload` returns a string receipt and the service actually enforces the supplied idempotency key:

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

The memo avoids calling `upload` once its receipt is committed. But a crash between the upload and the memo commit still leaves a gap. The external idempotency key addresses that gap only if the remote service honors it. A local memo alone is not exactly-once side-effect execution, and this sketch is not permission to declare an arbitrary upload tool `safe`.

<h2 id="parallel-result-order">Parallel tools have two different result orders</h2>

Suppose an assistant calls A, then B, and B finishes first. **Current Pi Durable appends B’s result first.** Its transcript records completion order; it does not use the old `outcome_ready` staging rule to hold B out of history.

When Pi builds the model’s context, [its projection][context-order] orders tool results by the assistant’s original tool-call order. The same saved results can therefore appear as B, A in history and A, B in model context.

<img src="/baoyu-article-illustrator_20261008_192341/result-order.webp" decoding="async" loading="lazy" width="1536" height="1024" alt="The transcript holds saved results B then A, while model context projects those same results as A then B." data-zoomable title="Click to enlarge" />

*Figure 3. Completion order and model-context order are different views of the same results, not two executions. This assumes the model called A before B and B completed first.*

Now place a crash between B’s commit and A’s settlement. B’s completed task and result remain saved. Only unfinished A needs recovery, and A reruns only if the replay gate allows it. Once the round is settled, the next model request can consume A, B in call order. This distinction matters for applications that show transcript entries directly: their visible history need not match the ordering of the model’s tool-result messages.

<h2 id="model-request-recovery">A cut-off model request is resent, not resumed token by token</h2>

Model recovery has a different boundary from tool replay. In the [request-recovery tests][model-recovery], an interrupted prepared request is sent again using its saved messages and options, without repeating preparation. If a partial answer was committed, recovery can turn it into an assistant entry marked `aborted` before resending the same request.

That preserves evidence of the interrupted attempt. It does not attach to the former stream and continue from the last displayed token, nor does it guarantee the same answer on the next attempt.

The README documents configurable partial/output commit intervals, with a 100 ms default. Treat those as progress-throttling settings, not a measured upper bound on data loss under arbitrary storage delays. Only committed progress is available after restart.

Each conversation also has a persisted provider-facing session identity. The [resume documentation][resume] describes its use for prompt-cache and session affinity, and the changelog records its addition in 1.0.2. **Affinity is not external request deduplication or a final billing receipt.** Do not infer exactly-once generation or known final provider cost from the existence of that UUID.

<h2 id="storage-boundaries">Durability depends on the backend and the failure being tested</h2>

Pi Durable supplies persistent SQLite and JSONL storage as well as memory storage. A consistent local commit is valuable, but “survives a process restart” and “every acknowledged tail commit survives sudden power loss” are different claims.

For JSONL, the reviewed [ordinary commit path][jsonl-commit] appends affected sidecar records, optionally syncs those files, and then appends a marker to the main journal. It does **not** sync that newly appended main marker in the ordinary path. Consequently, even `fsync: true` is not sufficient evidence that every newest acknowledged commit is protected against power loss. Do not generalize this observation to every backend; assess the actual adapter and storage settings.

The official announcement also specifies one owning process per storage. Multiple clients can attach to that owner; independent processes opening and writing the same state are not a substitute for an ownership strategy. This [framework-versus-runtime distinction](/tutorials/agent-framework-harness-runtime-production/) is why an application needs operational recovery rules as well as an SDK.

<h2 id="integration-checklist">An integration checklist you can actually test</h2>

Before relying on restart recovery:

- **Pin the API.** Use current Pi Durable documentation and a known package version. Keep old AgentLane/Drive examples out of new integrations.
- **Rebuild execution dependencies.** Reopen the same persistent storage, reinstall extensions, recreate model access and environments, and start the scheduler under one writable owner.
- **Retry admission with the same identity.** A submission’s `requestId` lets the conversation find the existing submission after a client retry. It does not deduplicate arbitrary tool effects.
- **Audit each safe tool.** Check both its external idempotency behavior and what happens if code, environment, or policy changes before recovery.
- **Inject failures around commits.** Check the execution-intent boundary, the side effect before settlement, and a completed parallel result before its sibling finishes. Count external calls and inspect both history and model context.
- **Test the deployment’s failure modes.** Graceful close/reopen is a useful test but does not establish behavior under power loss, broken disks, or multiple writers.

For a broader comparison of composition choices, see [DeepSeek Harness vs Pi Agent](/tutorials/deepseek-harness-vs-pi-agent/). That comparison is not evidence that the two runtimes have identical recovery guarantees.

<h2 id="check-your-understanding">Predict a restart before reading the answers</h2>

Assume a persistent backend, the same storage, correctly reinstalled dependencies, and a restarted scheduler:

1. An upload has an `execute` checkpoint with stored `unsafe`. The new tool declaration says `safe`. Will recovery run it?
2. A and B are called in that order. B’s final result commits; A is interrupted and has both policies `safe`. Which tool may rerun, and what are the two result orders if A finishes later?
3. A remote upload succeeds, but the process dies before its receipt memo commits. Does the memo API alone prevent another upload?
4. A partial model answer is committed before interruption. Does Pi reconnect to its last token?

<details markdown="1">
<summary>Show the recovery predictions</summary>

1. **No.** The stored `unsafe` policy cannot be upgraded by the current declaration. The model receives an interrupted result with an unknown external outcome.
2. **A may rerun; B’s committed result is reused.** History can contain B, A, while model context presents A, B. This is not replaying B to repair ordering.
3. **No.** There is no committed memo to read. Preventing the duplicate requires the remote service to honor the same operation key, or an application reconciliation path.
4. **No.** A saved partial can become an `aborted` entry, and the prepared model request is resent. Stream continuity and identical regenerated content are not promised.

</details>

<h2 id="sources-and-version">Sources and version scope</h2>

This article was substantively rebuilt on **October 8, 2026**, against Pi revision [`ce950d7`][snapshot]. The version dates come from the agent-core and Pi Durable changelogs, not from this page’s publication date. The original September 7 publication date remains preserved.

Primary sources are the [official Pi Durable announcement][announcement], [current README][readme], [tool task][tool-task], [context projection][context-order], and linked recovery tests. The earlier AgentHarness comparison uses the separate [`3e94512` snapshot][old-harness]. The current APIs and figures are not attributed to that old revision.

**Verification boundary:** the upstream test assertions were inspected, not executed for this article. They describe simulated provider responses and persistent close/reopen scenarios; no live provider, upload service, or power-loss test is claimed. Local site builds, page checks, and image interactions are verified separately.

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
