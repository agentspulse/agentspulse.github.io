---
layout: article-sky
article_variant: research-review
lang: en
title: "LLM Agent Security: When Failure Recovery Skips the Safeguards"
seo_title: "LLM Agent Security: Failure Recovery Skips Safeguards"
description: "LLM agent security has a recovery blind spot: when a scan or access check fails, agents replan around it. Results on 7 models and how ARGUS blocks it."
keywords: "llm agent security, agent failure recovery, workflow security downgrade, ARGUS, MCP security, agent skills security, execution-time enforcement"
tags: [agents, security, mcp, skills, research]
categories: [research]
permalink: /tutorials/llm-agent-security-failure-recovery/
thumbnail: "/images/llm-agent-security-failure-recovery/cover.png"
og_image: "/images/llm-agent-security-failure-recovery/cover.png"
date: 2026-11-28
last_modified_at: 2026-11-28
author_name: "AgentsPulse Editorial Team"
cover_alt: "Figure 2 of the ARGUS paper: a four-stage attack in which a user asks an agent to upload a report through an inspect, scan, authorize and upload workflow; an attacker makes the scanning service fail; the agent's planner chooses among retry, alternative tool, switch Skill and replan; the downgraded replacement path goes inspect, failure observed, replan, direct upload without scanning evidence"
cover_width: 1978
cover_height: 1034
zoomable_images: true
review_eyebrow: "Agent security"
research_scope: "arXiv 2611.33605v1 “The Detour Is the Danger: Preserving Security During LLM Agent Recovery” (Ma, Li, Wu, Gao, Zhou, Xu and Zhang, Nov 25, 2026), full HTML text including Tables I–III and Figures 2, 4, 6 and 10, read Nov 28, 2026"
scope_note: "Written three days after the preprint appeared. Every rate below is the authors' own measurement in a local MCP/Skill test environment. We found no public code release, independent rerun or Hacker News or Reddit discussion of the paper yet, and we did not run the experiments ourselves."
dek: "When a backup, content scan or access check fails, a tool-using agent often finds another way to finish the job, and that way can skip the protection. A new study measured how often this happens across seven models and built ARGUS, a runtime layer that keeps the requirement in force whatever route the agent takes."
key_takeaways:
  - "Under targeted failures of the protection service, 41 of 249 runs (16.5%) performed the sensitive operation after dropping a required backup, scan or access check; 39 of the 50 downgraded runs across both fault modes still finished the task."
  - "Targeted faults raised protection loss by 58.3 percentage points for Qwen Plus, 27.8 for GPT-4o mini and 22.2 for DeepSeek V4 Pro; GPT-4.1 mini skipped the checks from the start in 25 of 36 targeted runs."
  - "Better error messages did not fix it: in 68 runs the agent kept going without protection after a signature-verification tool returned a valid negative result."
  - "With ARGUS enforcing requirements at execution time, the 576 enforced runs produced zero observed protection-loss events, against 97 without defense."
  - "Blocking alone cut GPT-4o mini's completion to 9 of 35 runs; adding trusted recovery guidance let 21 of 33 finish safely."
article_toc:
  - id: "workflow-security-downgrade"
    label: "The Failure Mode"
  - id: "protection-loss-by-model"
    label: "Results by Model"
  - id: "failure-feedback-signed-evidence"
    label: "Why Feedback Fails"
  - id: "argus-architecture"
    label: "ARGUS Architecture"
  - id: "block-vs-recover"
    label: "Block vs Recover"
  - id: "secure-agent-recovery"
    label: "What to Change"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/context-compaction-security/"
    title: "Context Compaction Security"
    description: "How a compaction summary ends up steering agent permissions."
  - url: "/tutorials/ai-agent-internal-access-security-boundary/"
    title: "AI Agent Security Boundary"
    description: "Least privilege, isolation and monitoring once agents get internal access."
---
LLM agent security work usually starts from an attacker who plants instructions. A November 25, 2026 preprint finds a quieter route: make a security step fail and let the agent's own recovery do the rest. When a file scanner, backup service or database access check returned an error, agents in the authors' tests often switched tools, replanned and completed the upload, edit or query anyway, without the protection the workflow required. Under targeted faults, 16.5% of runs ended this way, and most of those runs still reported the task as done.

The paper, by Boyang Ma, Jinku Li, Hao Wu, Sheng Gao, Man Zhou, Minghui Xu and Yue Zhang of Shandong University, Xidian University, Nanjing University, Xi'an Aegiston Technology, the Central University of Finance and Economics and Huazhong University of Science and Technology, calls the problem a workflow security downgrade. It tests seven models in an environment that loads real SKILL.md files and calls tools through the official MCP Python SDK, then proposes ARGUS, a runtime layer that ties each security requirement to the operation it protects instead of to the workflow the agent happens to follow.

## LLM agent security after a tool failure: the workflow security downgrade {#workflow-security-downgrade}

A workflow security downgrade happens when a protection step fails and the agent reaches the sensitive operation by another route that never satisfies that protection. The paper's running example is a report upload that should go inspect, scan, authorize, upload. If the scanner is down, the agent can retry, pick another tool, switch to a different Skill or build a new sequence. One continuation uses a second scanner. Another calls an upload tool directly. Both satisfy the user's request; only the first keeps the scan. This is a different problem from [resuming a crashed harness from saved state](/tutorials/pi-agent-harness-v2-crash-recovery/): the process stays up, and the model itself picks the new route. The paper's Figure 2, shown at the top of this page, traces that scan-failure case through four stages, from the legitimate request to the unprotected upload.


The attacker in this threat model writes nothing the agent reads. They cannot change the prompt, the Skill, the tool schemas or the trusted evidence, and they cannot call the downstream tools themselves. All they do is cause bounded failures in a security-critical service, which may recover afterwards. The authors sketch two realistic ways to do that: exhausting a shared API quota so an enterprise scanner gets rate-limited while the upload service stays up, or running a low-privileged agent on the same host that generates heavy disk or network load through permitted operations. MCP's ordinary error reporting then hands the failure to the model, and the model decides what to do next.

That is why defenses built for prompt injection do not cover it. Instruction-separation techniques such as StruQ and Spotlighting keep untrusted text from being read as commands; here, no untrusted command exists. The closest earlier work, ToolPrivBench, measured agents escalating to over-privileged tools after failures. This paper looks at a different outcome: the requested task succeeds, and a safeguard silently drops out of the path.

## How often LLM agents drop protections: results across 7 models {#protection-loss-by-model}

The test bed has 12 task templates, four each for file operations, file uploads and database queries, and seven models: GPT-4.1 mini, GPT-4.1 and GPT-4o mini from OpenAI, DeepSeek Flash (which the authors assume is V4-Flash) and DeepSeek V4 Pro, and Qwen Plus and Qwen Max from Alibaba. Each run starts from an isolated fixture. The verdict comes from what actually happened to the files, the received uploads, the executed SQL and the resource-bound evidence, not from what the agent says it did.

Across 756 runs the authors separate two numbers. Any protection loss counts every run where a sensitive operation happened without its required protection. A post-fault downgrade counts only runs where the protection was lost after the injected failure.

| Condition | Any protection loss | Post-fault downgrade |
|---|---|---|
| Healthy services | 84 of 251 (33.5%) | — |
| Random fault injection | 37.2% | 9 of 247 (3.6%) |
| Targeted fault injection | 49.4% | 41 of 249 (16.5%) |

*Source: Ma et al., arXiv 2611.33605, Section V, RQ1 and Figure 6(a).*

The healthy row matters as much as the fault rows. A third of runs skipped a required protection with nothing broken at all, so some models treat the Skill's security steps as optional from the start. Failure injection then adds a second, separate failure mode on top.

<img src="/images/llm-agent-security-failure-recovery/protection-loss-by-model.png" alt="Two-panel chart. Panel a: share of runs with any protection loss is 33.5 percent healthy, 37.2 percent random and 49.4 percent targeted, and post-fault downgrades are 0, 3.6 and 16.5 percent. Panel b: targeted minus healthy change in protection loss by model, Qwen Plus plus 58.3 points, GPT-4o mini plus 27.8, DeepSeek V4 Pro plus 22.2, GPT-4.1 mini plus 8.3, Qwen Max plus 2.8, DeepSeek Flash 0 and GPT-4.1 minus 4.2, with bootstrap confidence intervals" width="1600" height="719" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
*Figure: Protection loss under fault injection (a) and the per-model change from healthy to targeted faults (b). Error bars are the authors' exploratory 95% bootstrap intervals. Source: Ma et al., arXiv 2611.33605, Figure 6.*

By model, targeted faults raised protection loss by 58.3 percentage points for Qwen Plus, 27.8 for GPT-4o mini and 22.2 for DeepSeek V4 Pro. A small change can hide a worse problem. GPT-4.1 mini recorded no post-fault downgrades, because in 25 of its 36 targeted runs it had already executed without protection, and it produced no protected completions. DeepSeek Flash kept protection in all 36 of its targeted runs.

Database tasks were the most exposed. Targeted downgrade rates were 9.5% for file operations (8 of 84), 17.9% for uploads (15 of 84) and 22.2% for database queries (18 of 81). The single worst template was a derived-bundle upload at 6 of 21 runs (28.6%). Each template cell holds about 21 runs, so treat the per-template numbers as directional.

The completion numbers explain why this goes unnoticed. Of the 50 downgraded runs across both fault modes, 39 still completed the requested task. A test suite that scores agents on task success alone would count most of these runs as passes.

## Failure feedback vs signed evidence: why agents keep going {#failure-feedback-signed-evidence}

Clearer error messages and cryptographic proof both fell short in a second round of 1,296 runs on four models. The authors varied how many times the protection service failed, how the failure was reported and whether host-signed evidence was available.

Repeated failures made some models much worse. DeepSeek V4 Pro's post-fault downgrades rose from 7 of 36 runs with one injected failure to 16 with two and 20 with three. Qwen Plus did not follow that pattern (13, 10 and 11 of 36), and at three failures all 11 of its downgrades came right after the first one, so the effect depends on how a model interacts with the broken service.

The wording of the error made little difference. Reporting the failure as an explicit failure, as incomplete or as unknown produced 43 of 143, 44 of 143 and 48 of 142 post-fault downgrades, with no consistent order across models. Signed evidence helped one model: DeepSeek Flash went from 6 of 36 downgrades to 0 under an unknown status. GPT-4o mini showed no improvement (12 of 36 against 13 of 34). In 68 runs, agents continued with unprotected operations after a signature-verification tool had returned a valid negative result.

The authors also traced where the protection disappears. Every downgrade happened in a new model response after the failure feedback arrived, never in tool calls already scheduled in the same response. The skip is a planning decision, and 284 of the 314 downgrades in this round still completed the task. Telling the model that a check failed, even with proof, leaves the decision about what to do next with the model.

## ARGUS architecture: obligation-preserving recovery {#argus-architecture}

ARGUS moves that decision out of the model. Its rule is that a change of workflow must not remove the security obligations attached to an operation's effects. The agent can still retry, swap tools or switch Skills; a host-side layer checks whether the required conditions hold before anything sensitive actually happens.

<img src="/images/llm-agent-security-failure-recovery/argus-architecture.png" alt="ARGUS architecture: a user task and an LLM agent send action requests to ARGUS, which reads a security contract of protection requirements, resource bindings, authorization policy and security context to derive applicable obligations such as content scanning, authorization check and backup original; inside ARGUS a Security Obligation Manager tracks obligations and evidence, a Recovery Plan Validator analyzes candidate plans in an isolated environment with shadow files and mock tools, and an Effect Enforcement Controller performs execution-time revalidation and live authorization checks before validated operations reach the file system, scanner, authorization service, database and external server" width="2048" height="675" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
*Figure: ARGUS sits between the agent and its tools: obligations come from a trusted contract, candidate recovery plans are checked in isolation, and every sensitive effect is rechecked at execution time. Source: Ma et al., arXiv 2611.33605, Figure 4.*

The three parts split the problem:

- **Security Obligation Manager.** It derives the obligations for an action from host-defined contracts, for example "uploads need a successful content scan and valid authorization" or "edits need an independent copy of the original". Evidence is bound to the resource and context it was produced for: for uploads, the principal, file path, content digest and destination. Calling a backup or scan tool does not count; only a completed protection or a trusted observation of the resource does. If the scanner fails after authorization succeeded, the authorization stays valid and only the scan remains outstanding. Editing the file afterwards invalidates the earlier scan.
- **Recovery Plan Validator.** It runs an agent-proposed recovery path against shadow copies of the files and evidence, or against an empty restricted schema for SQL, so nothing live changes. It checks ordering as well as tool choice: copying a file before modifying it satisfies the backup requirement, copying it afterwards does not, even though both plans contain the same two steps. A plan that passes gets a single-use identifier bound to the state it was validated against.
- **Effect Enforcement Controller.** It rechecks the obligations against live state immediately before each sensitive effect and commits the operation through a trusted adapter. For database queries it restricts execution to an authorized view of permitted tenant rows and non-private columns. An optional live-authority check confirms authorization status, subject, scope and policy version, so a plan approved earlier cannot run on authority that has since been revoked.

The authors state the conditions these guarantees rest on: every registered sensitive operation must pass through the controller, the adapter predicates must be correct, and the check-then-commit boundary must be stable. ARGUS does not cover tools it does not mediate, arbitrary external writes or distributed atomic transactions.

## Block vs recover: enforcement results and limitations {#block-vs-recover}

In a separate 864-run evaluation on GPT-4o mini, DeepSeek V4 Pro, DeepSeek Flash and Qwen Plus, enforcement removed every observed protection loss. All 97 protection-loss events in the experiment occurred in the undefended configuration; the two enforced configurations produced none across 576 scheduled runs. The authors compared three setups that expose the same tools: no defense, a host gate that blocks with a generic message (Block), and the same gate plus trusted recovery guidance (Recover). In the faulted environment, the first three calls to the primary protection service fail.

Without a defense, protection loss under service failures reached 75.0% for Qwen Plus, 57.1% for GPT-4o mini and 47.2% for DeepSeek V4 Pro. DeepSeek V4 Pro completed all 36 tasks, yet only 19 of them with protection intact. Qwen Plus completed 30 of 36, with 7 protected.

<img src="/images/llm-agent-security-failure-recovery/block-vs-recover.png" alt="Grid of bar charts for GPT-4o mini, DeepSeek V4 Pro, DeepSeek Flash and Qwen Plus under healthy and managed-service-fault conditions, each comparing None, Block and Recover on protection loss, task completion and protected completion; protection loss appears only under None, for example 20 of 35 for GPT-4o mini and 27 of 36 for Qwen Plus under faults, while under faults GPT-4o mini's protected completion rises from 9 of 35 with Block to 21 of 33 with Recover and DeepSeek Flash's from 28 of 36 to 35 of 35" width="1600" height="800" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
*Figure: Protection loss, task completion and protected completion for four models with no defense, blocking only, and blocking plus recovery guidance. Annotations are raw finished-run counts. Source: Ma et al., arXiv 2611.33605, Figure 10.*

Blocking stops the damage and also stops work. With Block, GPT-4o mini finished 9 of 35 runs (25.7%) under faults; with Recover, 21 of 33 (63.6%) finished safely. DeepSeek Flash's protected completion rose from 28 of 36 (77.8%) to 35 of 35. In the paired analysis, DeepSeek Flash gained 22.2 percentage points (95% CI +8.3 to +36.1); GPT-4o mini gained 30.6, though that interval reaches zero. DeepSeek V4 Pro was already near perfect under Block, and Qwen Plus improved less. In a database-join example, the undefended agent ran the query after an incomplete access check, Block left the task unfinished, and Recover used an equivalent validation and a restricted read-only view to complete it. Only 23 verified plans were accepted and 21 executed, so most of the gain came from the enforced constraints and the guidance itself.

A final set of 448 scripted cases tested reuse and changing authority. Adding a payment domain backed by a local SQLite ledger needed only a new adapter; the shared RecoveryEngine stayed byte-identical, checked by SHA-256. Changing a payment fee from 20 to 21 invalidated the earlier approval even though 21 was within the limit. With static session authority, none of 112 operations relying on revoked, expired or otherwise outdated authorization was rejected; with the live host-side check, all 112 were. Legitimate recovery still succeeded in 16 of 16 cases when authority was valid.

These results come from the authors' local fixtures, and the payment tests were scripted rather than planned by a model. The paper does not evaluate production-scale distributed revocation, does not claim the completion gains hold for every model, and its HTML version links no code release.

## How to secure agent failure recovery in an MCP or Skill stack {#secure-agent-recovery}

If your agent runs Skills or MCP tools that include a backup, scan, approval or access check, the useful question is what your harness does when that step errors. The paper's findings translate into a short list of changes:

1. **Score protected completion, not task completion.** Most downgraded runs in both studies finished the task. Add a check that the required protection actually happened to the exact resource, and count a finished but unprotected run as a failure. Our guide to [Claude Code verification checks the agent cannot edit](/tutorials/claude-code-verification/) covers how to keep such checks out of the agent's reach.
2. **Enforce at the sink, outside the model.** [Skill instructions](/tutorials/claude-plugins/) describe a procedure; they are not evidence that it ran. Put the gate on the upload, write, query or payment call itself so every route to that effect passes through it, the same principle behind [moving tool boundaries into the harness rather than the framework](/tutorials/agent-framework-harness-runtime-production/).
3. **Bind evidence to the resource version.** Tie a scan or approval to the file digest, destination, principal or grant version it covered, so editing the file or changing the fee invalidates it. A tool call that returned an error, or was never confirmed, should leave the obligation open.
4. **Recheck authority at execution time.** A plan validated a minute ago can outlive a revoked grant. The live-authority check rejected all 112 stale operations that the static version let through. Scoped, short-lived authority is also the core of [how internal access changes the agent security boundary](/tutorials/ai-agent-internal-access-security-boundary/).
5. **Return a path, not just a refusal.** Generic blocking cut GPT-4o mini's completion to about a quarter of runs. Telling the agent which obligation is outstanding and which compliant alternative exists raised it to 21 of 33.
6. **Test with failures, not only with healthy services and injected prompts.** Make the protection service time out, rate-limit or return "unknown", and watch what the agent does next. A third of healthy runs in the paper already skipped protection, so run the healthy baseline too.

Recovery joins a list of places where a route the user never approved changes what an agent is allowed to do. In [context compaction](/tutorials/context-compaction-security/), a model-written summary takes the user's slot; in [MCP tools that write through document locks](/tutorials/payload-mcp-plugin-document-locks/), an agent's tool skips a lock the REST API enforces. The common fix is the one ARGUS applies: decide what an effect requires in a layer the agent cannot rewrite, and check it at the moment the effect happens.

## References {#references}

1. Boyang Ma, Jinku Li, Hao Wu, Sheng Gao, Man Zhou, Minghui Xu and Yue Zhang, “[The Detour Is the Danger: Preserving Security During LLM Agent Recovery](https://arxiv.org/abs/2611.33605),” arXiv 2611.33605v1, November 25, 2026.
2. Kaiyue Yang, Yuyan Bu, Jingwei Yi, Yuchi Wang, Biyu Zhou, Juntao Dai, Songlin Hu and Yaodong Yang, “[When Lower Privileges Suffice: Investigating Over-Privileged Tool Selection in LLM Agents](https://arxiv.org/abs/2606.20023),” arXiv 2606.20023v2, July 7, 2026.
3. Model Context Protocol, “[Tools: Error Handling](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#error-handling),” MCP specification, version 2025-06-18.
