---
layout: article-sky
article_variant: research-review
lang: en
title: "Pi Harness v2: Crash Recovery and Tool Replay"
seo_title: "Pi Harness v2: Crash Recovery and Tool Replay"
description: "How Pi Agent Harness v2 handles crash recovery, durable operations, safe tool replay, staged results, and the limits of exactly-once execution."
keywords: "Pi Harness v2, Pi Agent crash recovery, AgentHarness, tool replay, durable agent operations"
tags: [pi-agent, coding-agents, agent-infrastructure]
categories: [frontier-research]
permalink: /tutorials/pi-agent-harness-v2-crash-recovery/
thumbnail: "/images/pi-agent-harness-v2-crash-recovery/pi-harness-recovery-cover.jpg"
og_image: "/images/pi-agent-harness-v2-crash-recovery/pi-harness-recovery-cover.jpg"
date: 2026-09-07
last_modified_at: 2026-09-07
author_name: "AgentsPulse Editorial Team"
cover_alt: "Pi Agent Harness crash recovery across saved session state, effect boundaries, and parallel tool results"
cover_width: 1200
cover_height: 675
paper_count: 1
research_scope: "Pi Agent · AgentHarness · Crash recovery"
dek: "What Pi preserves across a crash, when tool calls can replay, and where exactly-once execution remains impossible."
key_takeaways:
  - "Persistent Sessions preserve conversation and operation state, but the process-local Drive must be recreated by the host."
  - "External effects can remain unknown after a crash; replay requires both the stored policy and current tool declaration to be safe."
  - "Completed parallel tool outcomes are staged durably and later enter the conversation in source order."
article_toc:
  - id: "what-survives-a-restart"
    label: "What Survives a Restart?"
  - id: "how-harness-v2-evolved"
    label: "How Harness v2 Evolved"
  - id: "between-intent-and-outcome"
    label: "Between Intent and Outcome"
  - id: "which-tools-can-run-again"
    label: "Which Tools Can Run Again?"
  - id: "when-completion-order-differs-from-conversation-order"
    label: "Parallel Result Ordering"
  - id: "an-interrupted-model-response"
    label: "Interrupted Model Responses"
  - id: "who-continues-the-work"
    label: "Who Continues the Work?"
  - id: "implementation-progress"
    label: "Implementation Progress"
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
Pi's historical Harness v2 proposal evolved into the current unified `AgentHarness`. This review uses **Harness v2** for the design lineage, while distinguishing the older operation-log proposal from the current durable operation-state implementation.

**Short answer:** Pi can preserve the conversation, branch position, operation state, staged tool outcomes, and settled usage when a persistent backend is used. It cannot always prove whether an external side effect happened during the gap between invoking a tool and committing its outcome. Recovery therefore replays only calls whose stored policy **and** current tool declaration are safe, unless the batch was cancelled.

| Recovery question | What the harness can say |
|---|---|
| What survives a process restart? | Persistent Session data: conversation entries, branch tips, operation state, pending outcomes, and settled usage. |
| What does not survive? | The process-local Drive; Memory-backed Sessions also disappear with the process. |
| Can an unfinished tool run again? | Only when both the stored replay policy and current declaration are `safe`, and the batch is not cancelled. |
| Can it guarantee exactly-once external effects? | No. A crash after the action but before outcome commit leaves the external result unknown. |
| Who resumes execution? | The host reopens the Session and schedules a new Drive. |

For the broader runtime boundary around state, tools, retries, and observability, see [The Agent Framework Is Not the Runtime](/tutorials/agent-framework-harness-runtime-production/).

<p>Suppose a coding agent is deleting a directory when its process crashes. After restarting, it can read the conversation and find the tool call. But did the deletion start? Did it finish? Would running the call again repeat an action that already happened?</p>
<p>These questions motivated Pi’s <strong>harness v2</strong> design: make ongoing agent work recoverable beyond the conversation itself. The design evolved into the current <code>AgentHarness</code>, which stores the state of an operation and uses it to decide how work can continue. We will follow a tool call through that process, from the first saved intent to the result that eventually appears in the conversation. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#05-worked-example--a-crash-mid-tool">1</a> </p>
<p>The difficult part is the interval between performing an external action and saving its outcome. A runtime can preserve the evidence around that interval. It cannot always determine what happened inside it.</p>
<h2 id="what-survives-a-restart">What survives a restart?</h2>
<p>Pi separates the history of a conversation from the state of the work being performed over it. Four objects make that separation easier to follow:</p>
<ul>
<li>A <strong>Session</strong> holds the shared conversation, execution data and usage records.</li>
<li>A <strong>Branch</strong> names a path through the conversation’s entry tree. Its tip identifies the current end of that path.</li>
<li>An <strong>AgentLane</strong> adds model and tool configuration, an inbox and at most one active operation to a branch.</li>
<li>An <strong>Operation</strong> represents accepted work, such as an agent run, with its own identity and current state.</li>
</ul>
<p>A <strong>Drive</strong> is the process-local execution pass that advances an operation. With a persistent storage backend, the operation can survive the loss of its Drive. Loading the Session restores the saved state; the host then schedules a new drive to continue it. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#23-branches-and-agentlanes">2</a> </p>
<p>Figure 1 shows two branches sharing the same prefix. The branch tips and operations are saved data. The Drives below them belong to the running process.</p>
<figure><a aria-label="Open Figure 1 at full size" class="figure-link" href="/images/pi-agent-harness-v2-crash-recovery/session-model.png" rel="noopener" target="_blank"><img alt="A tree with a shared prefix and two branch tips. Each branch has its own lane and operation inside the Session; a matching process-local Drive sits outside the saved state." height="1536" loading="lazy" src="/images/pi-agent-harness-v2-crash-recovery/session-model.png" width="1024"/><span class="image-hint">Select diagram to enlarge</span></a><p class="caption"><em>Figure 1. Branches share conversation entries while their lanes maintain separate operations. With persistent storage, the data inside the Session survives process loss; the Drives must be recreated. The host assigns one writable owner to the whole Session.</em></p></figure>

<p>The Session stores three kinds of data with different lifetimes. <strong>Conversation entries</strong> are immutable nodes linked to their parents. <strong>Bound values and lists</strong> hold changing information: branch tips, current operation state, pending output and inbox contents. The <strong>usage ledger</strong> retains settled accounting records independently of operation cleanup.</p>
<p>When an operation finishes, a terminal transaction removes its temporary state and retains an immutable result record. Conversation entries and usage remain. Conversation compaction changes the context presented to the model; it does not erase the underlying history. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#313-terminal-transactions-and-result-records">3</a> </p>
<h2 id="how-harness-v2-evolved">How Harness v2 evolved</h2>
<p>The original v2 proposal and the current harness recover work differently. In the <a href="https://github.com/earendil-works/pi/blob/a0014c1a83ea0b6fd98762a9bdaa90f517a73cbf/packages/agent/docs/harness-v2.md">early design</a>, each lane had an operation log. Recovery reduced those records and resolved unfinished intents.</p>
<p>The <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#32-operation-state--the-durable-restart-point">current design</a> saves the operation’s complete current state. Each durable transition replaces it atomically, along with the entries, values, lists and usage rows needed to make that new state true. After a restart, the driver reads the state’s <code>at</code> field and enters the corresponding procedure. </p>
<p>This makes the restart point explicit. If a transition publishes a response and advances execution, both changes commit together. Recovery does not have to guess which step follows from a partially updated transcript.</p>
<p>The JSONL backend still reads physical records to reconstruct its storage maps when opening a file. That is how it decodes the saved data; the harness then continues from the resulting operation state. The two uses of a log should not be confused. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#jsonl">4</a> </p>
<p>The implementation reached this point through several distinct stages. Dates below follow the 2026 commit history in UTC.</p>
<ul>
<li><p><strong>July 29 — The v2 design appears.</strong> The first <a href="https://github.com/earendil-works/pi/commit/4f0437e2d58d651dd934119ecabea2893975f62f">v2 document</a> organizes Sessions around a conversation tree, lanes and per-lane operation logs, with recovery expressed as reduction. </p></li>
<li><p><strong>August 3 — The effects design is selected.</strong> The project <a href="https://github.com/earendil-works/pi/commit/a0014c1a83ea0b6fd98762a9bdaa90f517a73cbf">chooses the effects variant</a> over the generator variant. Explicit intents, outcomes and crash-site behavior become the chosen basis for v2. </p></li>
<li><p><strong>August 4–5 — Storage and recovery foundations land.</strong> <a href="https://github.com/earendil-works/pi/commit/1d0c97471359a7c1dc6bfc9ac7ce5b4aa9afd705">In-memory sessions</a> arrive first, followed by a <a href="https://github.com/earendil-works/pi/commit/651d5d6a53690b3ec87b72fca0b3f993ac5ec748">JSONL v4 backend</a> and the <a href="https://github.com/earendil-works/pi/commit/2bb7ba49661e88e0c692facb537972287792af69">durable lane reducer</a>. These are early implementations of the log-based design. </p></li>
<li><p><strong>August 11 — The specification is consolidated.</strong> The design documents <a href="https://github.com/earendil-works/pi/commit/85a2060811a23f1580c13ab59a210b1409092837">merge into harness.md</a>, giving the storage, Session and runtime contracts a shared reference. </p></li>
<li><p><strong>August 14 — The first runtime gains execution.</strong> The earlier runtime gains a <a href="https://github.com/earendil-works/pi/commit/1d882a7eca12d07fec9468db0192d13d922bdb31">minimal model run</a> and <a href="https://github.com/earendil-works/pi/commit/d411d7b05e68aa45cde6e33658bd3f51ecb6bc8c">tool execution</a>. This is the implementation replaced by runtime2 in the next stage. </p></li>
<li><p><strong>August 17–18 — The runtime is replaced, then acceptance is rebuilt.</strong> <a href="https://github.com/earendil-works/pi/commit/877c2d0eaaa8a36d27eeeabf54430c863cf96303">WP00 switches the public factory to runtime2</a> and removes the old runtime while execution is still incomplete. <a href="https://github.com/earendil-works/pi/commit/beac75ecc2254713cc2d7f3ab682c015762cc481">Atomic acceptance and coherent observation</a> follow as a separate step. </p></li>
<li><p><strong>August 26 — The durable execution graph and public lane API land.</strong> The <a href="https://github.com/earendil-works/pi/commit/8b6910732992521bcf907ce39101f8a633a5ba8d">direct driver</a> advances saved state through generation, tools, waits, structural work and cancellation. The <a href="https://github.com/earendil-works/pi/commit/89356540fb7318e04e9599a1bc742f5e8f358fe2">public lane operations</a> expose that execution flow. </p></li>
<li><p><strong>August 31 — SQLite ownership moves to the host.</strong> <a href="https://github.com/earendil-works/pi/commit/ef11444b6e0c434bb72ff59a9b2944de0b5c5018">WP07</a> removes the backend ownership mechanism and adds read-only snapshots for forking live source Sessions. The host remains responsible for assigning the writable owner. </p></li>
<li><p><strong>September 1 — Forks gain explicit named-branch selection.</strong> The <a href="https://github.com/earendil-works/pi/commit/f8da63be590e14080dc06eed8c8986bc2eec8310">fork contract</a> requires a scope and source branch. This is the first slice of WP08; bounded-memory copies remain unfinished. </p></li>
<li><p><strong>September 2 — Settled tools stay visible until placement.</strong> <a href="https://github.com/earendil-works/pi/commit/e26afb63a46c374f4f482f4808317336790abb7a">WP09</a> closes a display gap: a completed tool result now remains in the lane snapshot while waiting for its position in the conversation. </p></li>
</ul>
<h2 id="between-intent-and-outcome">Between intent and outcome</h2>
<p>Atomic transactions can keep local state consistent, but a tool may act on a filesystem or remote service outside that transaction. Pi therefore separates an effect into four steps:</p>
<ol type="1">
<li>Prepare the inputs.</li>
<li>Commit the intent, including the arguments and reserved output identities.</li>
<li>Perform the external action.</li>
<li>Commit the outcome and the next operation state together.</li>
</ol>
<p>The intent survives a crash. So does a committed outcome. The gap between them can leave the external result unknown. Consider the two paths in Figure 2: one process dies before performing the action; another dies after the action but before saving its result. Both can reopen with the same saved intent. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#45-driving-and-crash-recovery">5</a> </p>
<figure><a aria-label="Open Figure 2 at full size" class="figure-link" href="/images/pi-agent-harness-v2-crash-recovery/effect-boundary.png" rel="noopener" target="_blank"><img alt="An intent forks into two possible histories: crash before the action, or action followed by crash. Both converge on the same saved state with an unknown outcome. A separately committed outcome can be kept." height="1536" loading="lazy" src="/images/pi-agent-harness-v2-crash-recovery/effect-boundary.png" width="1024"/><span class="image-hint">Select diagram to enlarge</span></a><p class="caption"><em>Figure 2. Different external histories can leave identical local evidence. A committed outcome removes this particular uncertainty; an intent alone does not.</em></p></figure>

<p>This is why the harness cannot promise exactly-once external effects. Saving a marker before a call does not prove the call happened, and saving one afterward leaves a window in which the action may have happened without that marker. Hooks with side effects face a related issue: if their consuming transaction did not commit, they may run again and need their own idempotency discipline. </p>
<h2 id="which-tools-can-run-again">Which tools can run again?</h2>
<p>Return to the directory deletion. Suppose the tool’s stored policy is <code>replay: "never"</code>. It starts work and may save progress, then crashes before committing a final result.</p>
<p>On recovery, the harness preserves the latest durable progress snapshot, if one exists, and synthesizes an interruption result. It leaves the external outcome unknown. This is useful information for the next agent step: some work may have completed, but the transcript cannot claim that the deletion succeeded. Skipping a second execution also does not undo the first one. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/src/harness/runtime/drive/tools.ts#L45">6</a> </p>
<p>For an orphaned call to run again, <strong>both its stored policy and the current tool declaration must be <code>safe</code></strong>, and the batch must not be cancelled. Checking the current declaration matters: the tool implementation or its replay policy may have changed since the original call was accepted. The <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/src/harness/runtime/drive/tools.ts#L527">recovery condition</a> checks all three conditions. </p>
<p>A <code>safe</code> declaration is the tool author’s contract. The harness does not prove that an arbitrary action is idempotent. If the declaration is unsafe or the implementation is missing, recovery records interruption rather than invoking the tool. A restored cancelled batch follows cancellation reconciliation instead of ordinary replay.</p>
<h2 id="when-completion-order-differs-from-conversation-order">When completion order differs from conversation order</h2>
<p>Now suppose the assistant requests tools A and B in that order, and the runtime executes them in parallel. B finishes first. Its result cannot yet appear as the next tool entry because A precedes it, but there is no reason to leave B’s completed work unsaved.</p>
<p>Pi first <strong>stages</strong> B’s outcome at a pending address and marks it <code>outcome_ready</code>. As earlier calls become ready, the runtime materializes the contiguous ready prefix into the conversation. Saving a result and placing it in conversation order are separate steps. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#38-tools">7</a> </p>
<p>Figure 3 adds a crash while A is still running. Assume A is eligible for safe replay: its stored and current declarations are safe, and the batch is not cancelled. After restart, A can run again while B’s saved outcome is retained.</p>
<figure><a aria-label="Open Figure 3 at full size" class="figure-link" href="/images/pi-agent-harness-v2-crash-recovery/parallel-staging.png" rel="noopener" target="_blank"><img alt="Before the crash, B finishes and is staged while A is still running. After restart, only A safely replays. A and the retained B result then enter the conversation in source order." height="1536" loading="lazy" src="/images/pi-agent-harness-v2-crash-recovery/parallel-staging.png" width="1024"/><span class="image-hint">Select diagram to enlarge</span></a><p class="caption"><em>Figure 3. B waits for its place in the conversation without losing its result. In this example only A is replayed; if A were unsafe to replay, its interruption result could instead settle that position. The trace illustrates ordering, not measured durations.</em></p></figure>

<p>The staging commit is the decisive boundary for B. Once its complete outcome is durable, recovery can place it without resolving or executing that tool again. The repository’s <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/test/harness/runtime/drive-tools.test.ts#L382">tool runtime tests</a> cover out-of-order staging and materializing already saved outcomes. </p>
<h2 id="an-interrupted-model-response">An interrupted model response</h2>
<p>A provider stream has a different recovery policy. If the process dies during generation, the harness reconstructs the latest committed assistant-frame prefix and settles a synthetic error response under the reserved identifiers. Partial tool calls from that response never execute. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/src/harness/runtime/drive/recovery.ts">8</a> </p>
<p>Recovery does not reconnect to the old stream. A retry policy may subsequently schedule a new numbered attempt, which is a new provider request. This separates preserving the partial response from deciding whether to try again.</p>
<p>The synthetic settlement records zero usage. That value cannot tell us what the provider charged for the interrupted request: the runtime may never have received the final accounting. The append-only ledger preserves settled usage and accepts caller-supplied adjustments so that accounting can be reconciled separately. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#16-usage-ledger">9</a> </p>
<h2 id="who-continues-the-work">Who continues the work?</h2>
<p>Saving work and running it are separate responsibilities in the API as well. <code>accept</code> persists an operation without invoking a hook, provider or tool. <code>drive</code> installs or joins the lane-owned execution pass. A host can therefore accept work before a worker is ready and schedule execution later. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#36-acceptance">10</a> </p>
<p>The separation is visible in these consecutive <code>AgentLane</code> declarations:</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode typescript"><code class="sourceCode typescript"><span id="cb1-1"><a aria-hidden="true" href="#cb1-1" tabindex="-1"></a><span class="fu">getResult</span>(operationId<span class="op">:</span> <span class="dt">string</span><span class="op">,</span> context<span class="op">:</span> Context)<span class="op">:</span> <span class="bu">Promise</span><span class="op">&lt;</span>OperationResultRecord <span class="op">|</span> <span class="dt">undefined</span><span class="op">&gt;;</span></span>
<span id="cb1-2"><a aria-hidden="true" href="#cb1-2" tabindex="-1"></a><span class="fu">accept</span>(request<span class="op">:</span> OperationRequest<span class="op">,</span> context<span class="op">:</span> Context)<span class="op">:</span> <span class="bu">Promise</span><span class="op">&lt;</span>OperationAdmissionResult<span class="op">&gt;;</span></span>
<span id="cb1-3"><a aria-hidden="true" href="#cb1-3" tabindex="-1"></a><span class="fu">drive</span>(options<span class="op">:</span> DriveOptions<span class="op">,</span> context<span class="op">:</span> Context)<span class="op">:</span> <span class="bu">Promise</span><span class="op">&lt;</span>DriveResult<span class="op">&gt;;</span></span>
<span id="cb1-4"><a aria-hidden="true" href="#cb1-4" tabindex="-1"></a><span class="fu">requestAbort</span>(operationId<span class="op">:</span> <span class="dt">string</span><span class="op">,</span> context<span class="op">:</span> Context)<span class="op">:</span> <span class="bu">Promise</span><span class="op">&lt;</span>AbortRequestResult<span class="op">&gt;;</span></span>
<span id="cb1-5"><a aria-hidden="true" href="#cb1-5" tabindex="-1"></a><span class="fu">inspectExecution</span>(context<span class="op">:</span> Context)<span class="op">:</span> <span class="bu">Promise</span><span class="op">&lt;</span>LaneExecutionInfo<span class="op">&gt;;</span></span></code></pre></div>
<p><em>TypeScript interface excerpt from <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/src/harness/agent-harness.ts#L545-L549">AgentLane</a>, MIT licensed.</em> </p>
<p>Several events that look like “stop” to a user have different effects:</p>
<ul>
<li><strong>A caller cancels its Context after Drive installation.</strong> That caller stops observing; the operation is not durably cancelled. Other callers can still observe the same pass.</li>
<li><strong>The host requests an abort.</strong> <code>requestAbort(operationId)</code> commits cancellation for the matching operation. A drive performs the remaining reconciliation; an old operation ID cannot cancel newer work.</li>
<li><strong>The harness closes.</strong> New mutations are sealed and admitted mutations drain. Close writes neither cancellation nor terminal state.</li>
<li><strong>The Session reopens.</strong> Saved state is restored, but execution waits for a later drive.</li>
</ul>
<p>Cancellation before Drive installation starts no work. These lifecycle rules let the host distinguish a lost connection from an explicit stop request. They also make restart scheduling and single-writer Session ownership part of the host’s job. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#46-abort-and-cancellation-reconciliation">11</a> </p>
<h2 id="implementation-progress">Implementation progress</h2>
<p>At the September 7, 2026 source snapshot, the <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#part-8--work-packages">work-package list</a> marks WP00–WP07 and WP09 complete. WP08 is still in progress. The numbers identify work packages; they do not imply a strict completion order. </p>
<div class="table-wrap"><table>
<thead>
<tr>
<th>Package</th>
<th>Status</th>
<th>Result or remaining goal</th>
</tr>
</thead>
<tbody>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/00-runtime1-removal.md">WP00</a></td>
<td>Complete</td>
<td>Replace runtime1 and switch the public factory to runtime2.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/01-bound-values-lists.md">WP01</a></td>
<td>Complete</td>
<td>Introduce bound values and lists across Session and storage backends.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/02-atomic-run-acceptance.md">WP02</a></td>
<td>Complete</td>
<td>Accept work atomically and capture coherent lane observations.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/03-remove-drive-deadlines.md">WP03</a></td>
<td>Complete</td>
<td>Remove wall-clock drive deadlines and the non-durable yielded outcome.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/04-mutation-publication.md">WP04</a></td>
<td>Complete</td>
<td>Publish committed mutations and their events through the Session.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/05-direct-durable-drive.md">WP05</a></td>
<td>Complete</td>
<td>Finish the durable operation graph, cancellation, results and public lane API.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/06-session-branch-lane-separation.md">WP06</a></td>
<td>Complete</td>
<td>Separate Session, Branch, AgentLane and AgentHarness responsibilities.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/07-sqlite-host-ownership-live-forks.md">WP07</a></td>
<td>Complete</td>
<td>Align SQLite with host ownership and support live-source forks.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/08-named-branch-streaming-forks.md">WP08</a></td>
<td>In progress</td>
<td>Add named-branch/tree semantics and bounded-memory fork copies.</td>
</tr>
<tr>
<td><a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/work-packages/09-lane-snapshot-settled-tools.md">WP09</a></td>
<td>Complete</td>
<td>Keep settled tool results visible until conversation placement.</td>
</tr>
</tbody>
</table></div>
<p>WP08 has already added explicit scope and branch selection, ancestry checks, configured-lane enforcement and scalar-value fork rules. List copying, sequence preservation, direct Memory construction and bounded JSONL/SQLite transfer still remain. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#09-implementation-status">Current slice</a>. </p>
<h3 id="work-still-open">Work still open</h3>
<p>The <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#09-implementation-status">implementation status</a> and <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/post-wp05-roadmap.md">roadmap</a> identify several remaining gaps: </p>
<ul>
<li><strong>JSONL storage cleanup.</strong> Snapshot compaction is specified but unimplemented, so superseded operation state and deleted pending payloads can remain in the file. Conversation compaction does not reclaim those physical bytes. </li>
<li><strong>Session-wide observation and search.</strong> Lane watches exist, but <code>watchSession</code> still throws <code>SliceNotImplemented</code>. Search has a design and a conflicting public API skeleton, with no implementation. </li>
<li><strong>Telemetry.</strong> The span vocabulary is declared, while production instrumentation starts only the tool-hook span. RPC trace propagation remains open. </li>
<li><strong>Remote Session access.</strong> The product uses process-local Sessions and routed semantic services. Some specification text still requires a raw remote mutation interface; that contract needs a decision before implementation. </li>
<li><strong>Contract and storage follow-up.</strong> Operation status and abort event ordering need reconciliation. SQLite branch divergence can still copy an entire uncompacted history. Format 4 remains in development, with schema migration machinery reserved for a future stabilized-format change. </li>
</ul>
<p>Recovery also depends on the chosen backend. Memory storage loses its state with the process. The JSONL contract gives resolved commits process-crash durability, with no <code>fsync</code> promise. <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md#jsonl">Storage contract</a>. </p>
<p>For an integration, start with one real interruption point. Identify what committed, which external outcome is still unknown, whether replay is permitted, and who schedules the next drive. Those four questions connect the saved data to the behavior the application will actually have after a restart.</p>
<p>For a broader comparison of the two tools, see <a href="/tutorials/deepseek-harness-vs-pi-agent/">DeepSeek Harness vs Pi Agent</a>. </p>
<section aria-label="Sources and version" class="source-notes"><h2 id="sources-and-version">Sources and version</h2>
<p>The mechanisms above follow Pi’s <a href="https://github.com/earendil-works/pi/blob/9767ba275f3e9a5ee0f5c5342249b629ab1b2282/packages/agent/docs/harness.md">AgentHarness specification and implementation at revision 9767ba2</a>, reviewed on September 7, 2026. The <a href="https://github.com/earendil-works/pi/blob/a0014c1a83ea0b6fd98762a9bdaa90f517a73cbf/packages/agent/docs/harness-v2.md">historical v2 proposal</a> uses the earlier log-based recovery model. For changes after this snapshot, consult the <a href="https://github.com/earendil-works/pi/blob/main/packages/agent/docs/harness.md">current harness documentation</a> and the <a href="https://github.com/earendil-works/pi">Pi repository</a>. Here, “v2” names a design stage in the project’s history, not a package release, and it does not refer to third-party packages that also use “harness” in their names. </p>
</section>
