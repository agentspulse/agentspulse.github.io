---
layout: article-sky
article_variant: research-review
lang: en
title: "Context Compaction Security: How Summaries Hijack Agent Permissions"
seo_title: "Context Compaction: How Summaries Hijack Agent Permissions"
description: "Context compaction puts a model-written summary in the user slot of Claude Code and Codex. Tests show it steers Progent-style permissions."
keywords: "context compaction, context compaction claude, context compaction codex, indirect prompt injection, context compaction llm, progent, agent authorization"
tags: [agents, security, prompt-injection, claude-code, codex, research]
categories: [research]
permalink: /tutorials/context-compaction-security/
thumbnail: "/images/context-compaction-security/cover.png"
og_image: "/images/context-compaction-security/cover.png"
date: 2026-11-27
last_modified_at: 2026-11-27
author_name: "AgentsPulse Editorial Team"
cover_alt: "Figure 1 of the compaction authorization paper: before compaction the user-written message 'March spending?' sits in the user role and the policy generator G grants no send_money; after compaction a model-written summary containing 'pending: send to A' sits in the same user role and the same G grants send_money with recipient A"
cover_width: 1554
cover_height: 809
zoomable_images: true
review_eyebrow: "Agent security"
research_scope: "arXiv 2611.32194v1 “LLM Agent Authorization Across Context Compaction” (Fei, Fei, Xu, Wang and Zhang, Nov 24, 2026), main text and appendix tables, plus the Progent paper, openai/codex pull requests #54281 and #41846, Anthropic's Claude Code auto mode write-up and OpenAI's compaction documentation, read Nov 27, 2026"
scope_note: "Written three days after the preprint appeared. Every attack and defense rate below is the authors' own measurement on AgentDojo, Agent Security Bench and their recorded Claude Code and Codex sessions. We found no independent rerun or public discussion of the paper yet, and we did not run the experiments ourselves."
dek: "Long agent sessions survive by compressing old turns into a summary. Claude Code and Codex hand that summary back to the model as a user message, and a new study shows permission systems that read the user's request start obeying whatever the summary carried, including an attacker's account number."
key_takeaways:
  - "In all 1,108 automatic compactions the authors recorded in Claude Code and Codex, the model-written summary became the latest user message, the slot that request-derived authorizers such as Progent read."
  - "After compaction, injections that Progent blocked before succeeded in 31 of 100 AgentDojo pairs, against 33 of 100 with no defense at all."
  - "Frontier compactors flagged injected instructions in 219 of 220 summaries but rarely flagged an attacker's account written as plain data; a policy built from such a summary admitted the attacker's payee in up to 91% of cases, against 0% when built from the user's own words."
  - "Codex's Guardian reviewer has attributed compaction summaries to the assistant since October 15, 2026; a same-process filter like that matched the paper's fix, but replayed records written into session or memory files still got through."
  - "The proposed witnessed-request gate gives the authorizer only MAC-tagged user turns while the agent keeps reading the summary: zero attacker actions in 40 attacked episodes, 26 tasks completed against 27 without compaction, at 0.25 to 0.40 ms per request."
article_toc:
  - id: "context-compaction-claude-code-codex"
    label: "Where the Summary Goes"
  - id: "context-compaction-security-risk"
    label: "The Security Risk"
  - id: "indirect-prompt-injection-compaction"
    label: "Injection via Summary"
  - id: "compaction-marking-instructions-vs-data"
    label: "Instructions vs Data"
  - id: "progent-vs-other-defenses-after-compaction"
    label: "Defenses Compared"
  - id: "witnessed-request-gate"
    label: "The Fix"
  - id: "secure-context-compaction"
    label: "What to Change"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/ai-agent-internal-access-security-boundary/"
    title: "AI Agent Security Boundary"
    description: "Least privilege, isolation and monitoring once agents get internal access."
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "Harness vs Framework"
    description: "Why the harness owns state, tool boundaries and control loops."
---
Context compaction lets a long agent session keep going by replacing earlier turns with a summary that a model writes. In Claude Code, and in Codex when it compacts locally, that summary goes back into the conversation as a user message. A November 24, 2026 preprint shows what this does to agent security: permission systems that decide what an agent may do from the user's latest message start taking their instructions from the summary instead. In the authors' rent-payment test, a policy derived from a frontier compactor's summary admitted an attacker's bank account in up to 91% of cases. Derived from the user's own words, it admitted that account in none.

The paper, by Zeming Fei, Hongming Fei, Yi Xu, Xiaoyang Wang and Ying Zhang of the University of Technology Sydney, the National University of Singapore and UNSW, tests Progent, a published privilege-control layer for LLM agents, along with five other defenses. It then proposes a fix that keeps the summary for the agent and gives the permission check a separate, authenticated copy of what the user actually said.

## Context compaction in Claude Code and Codex: where the summary goes {#context-compaction-claude-code-codex}

When a transcript nears the model's context limit, the harness asks a model to summarize the earlier turns and continues from that summary. Claude Code inserts it as a user message, and so does Codex when it compacts locally, placing it after the user messages it keeps. The authors recorded 1,108 automatic compactions across the two products, 100 in Claude Code and 1,008 in 51 Codex sessions on versions 0.163.0 and 0.164.0. Every one put the summary in the latest user-message position.

The pattern is wider than two products. Reading the compaction code of Gemini CLI, OpenHands, Cline, Goose, Aider, Qwen Code, Kimi CLI and LangChain, the authors found the same placement in all eight. Claude Code also writes the follow-up itself: every compaction record in their live sessions told the agent to "continue the conversation from where it left off without asking the user any further questions".

What the summary keeps is set by a compaction prompt, and those prompts ask for detail. Claude Code 2.1.312 ships eight of them, extracted from the installed binary, and all of them ask for material such as "names, numbers, dates, exact wording … kept exactly". That is good for continuity. It also means any account number or URL the agent read from a web page, email or tool result can be carried forward, verbatim, inside a message labeled as the user's.

API-level compaction works differently on the surface. OpenAI's Responses API returns an encrypted compaction item that is "not intended to be human-interpretable", and Anthropic's API "replaces the older turns of a conversation with a summary that Claude writes on the server". The security question in this article is about the harness layer, where the summary's role label decides who appears to be speaking. If you build that layer yourself, our piece on [why the harness, not the framework, owns agent state and tool boundaries](/tutorials/agent-framework-harness-runtime-production/) covers where that responsibility sits.

## Context compaction security risk: the summary becomes the user's request {#context-compaction-security-risk}

The risk is misattribution. After compaction, the latest user message is a model's paraphrase of the whole session, including text that came from documents and tools, so any defense that trusts "what the user asked" now trusts the compactor's quotation of the user, along with whatever an attacker planted in the material it summarized.

That matters most for request-derived authorizers. [Progent](https://arxiv.org/abs/2504.11703), from Tianneng Shi, Dawn Song and colleagues, has an LLM write a policy from the user's task before any tool runs: a JSON-schema list of permitted tools with constraints on their arguments. A deterministic proxy then checks every tool call against it, so an injected instruction cannot make the agent send money if the user's request never allowed a transfer. DRIFT works on the same principle. Both read the user's request from one place, the latest user message, which the paper calls the request slot.

The cover image above shows the failure on a banking agent. Asked for March spending, the agent reads a transaction that tells it to pay the attacker, and Progent refuses because the question permits no transfer. After compaction, the summary records the blocked payment as unfinished work. The next policy is derived from that summary and permits exactly one transfer, to the attacker. Every component did its job: the policy enforced least privilege, and the privilege it enforced named the attacker. Our overview of [how the agent security boundary has shifted toward identity and least privilege](/tutorials/ai-agent-internal-access-security-boundary/) explains why least-privilege layers like this one have become the main line of defense.

The authors derive a fresh policy for each request because a policy frozen at the first request blocks too much legitimate work. In two-turn AgentDojo sessions without any attack, a frozen policy let the agent finish the second task in 7 of 60 sessions, against 41 of 60 with per-request derivation. With per-request derivation and a small compactor (gpt-4o-mini), injections that Progent blocked before compaction succeeded after it in 31 of 100 attacked pairs. The undefended agent's figure was 33 of 100.

## Indirect prompt injection through the compaction summary: what the tests measured {#indirect-prompt-injection-compaction}

The summary changes the policy only when it sits in the user slot, and the attacker's identifier reaches the policy only when the summary keeps it. The authors isolated both effects on 15 AgentDojo banking pairs, with the same injected environments and the follow-up "Please continue from where we left off":

| Text in the request slot | Policy expanded | Policy named the attacker |
|---|---|---|
| Follow-up only | 0/30 | 0/30 |
| User's own restated request | 5/30 | 0/30 |
| Summary with the injected span removed | 9/16 | 0/16 |
| Unmodified summary | 21/30 | 16/30 |
| Same summary, passed as a tool result | 0/28 | 0/28 |

*Policies read before the first tool result of the new turn. Source: Fei et al., arXiv 2611.32194, Table II.*

The last row is the clearest result. Byte-identical summaries that still contained the attacker's account changed no policy when they arrived as a tool result, so the authority came from the user-role label.

Retention sets an upper bound. Across 1,472 summaries from the compaction prompts the authors compared, 918 dropped the attacker's identifier, and none of the policies built from those 918 named it. Dropping the identifier is still not a defense. A summary that leaves out the account can still produce a policy that permits a transfer with the recipient left open, which admits a transfer to anyone: 78 of 410 such banking policies admitted the attacker's own transfer, and under a prompt written specifically to suppress identifiers, 41% of banking episodes still left the transfer admitted. When the authors replayed the agent under stored policies of that kind, it completed the attacker's transfer in 26 of 80 episodes, each time re-reading the poisoned item to find the account.

The live products behaved the same way at the boundary. In 20 headless Claude Code sessions with an injected banking item, the automatic summary kept the injected account in 19. In those runs Claude Code's own model described the account as an instruction the agent had declined, and the policy derived from it left the account out. That protection depends on the payload looking like an instruction.

## Compaction summary marking: injected instructions vs injected data {#compaction-marking-instructions-vs-data}

Compaction models are good at flagging injected instructions and poor at flagging injected data. With gpt-5.4-mini and gpt-5.5 as the compactor, under Claude Code's default prompt and under Codex's, the summary marked the attacker's identifier in 219 of the 220 summaries that kept it when the payload was an instruction. A mark works: across shipped prompts, policies named the identifier in 7 of 230 marked summaries against 349 of 536 unmarked ones.

The attacker can avoid the mark by not giving an instruction. The authors replaced AgentDojo's payloads with data-only forms: plain business prose, a bare account field, and a notice that the user's own task asks the agent to act on. Both frontier compactors then kept the account mostly unmarked, and under the notice payload the policy named it in more than half of the kept summaries.

The strongest test gave the authorizer everything it needed. The user first states the landlord's account and asks what a notice says; the attacker's notice lists a different account as plain data; after compaction, the user asks to pay this month's rent. The policy derived from the user's own words never admitted the notice's account. The policy derived from the summary admitted it in 290 of 320 cases overall, 91% with gpt-4o generating the policy and 59% with gpt-5.5. A gpt-5.4-mini agent re-run under the summary's policy completed the transfer to the notice's account in 33 of 80 episodes.

<img src="/images/context-compaction-security/frontier-compactors-marking.png" alt="Three bar-chart panels. Panel a, one request: gpt-5.4-mini and gpt-5.5 summaries mark an injected instruction almost always and the policy almost never names it, while for business prose, a bare account and a notice to act on the summaries rarely mark the account and for the notice the policy names it in more than half of kept summaries. Panel b, two requests: injected instructions are marked, an account written as data is not, and the policy names that account in most kept summaries. Panel c, account conflict: the policy from the summary admits the notice's account about 91 percent with gpt-4o and 59 percent with gpt-5.5 for pay the rent, the follow-up leaves the recipient open, and the user's words admit it in zero cases" width="2087" height="516" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
*Figure: Frontier compactors mark injected instructions but rarely injected data (a, b), and the policy derived from the summary admits the notice's account X while the policy from the user's words does not (c). "5.4m" is gpt-5.4-mini; "4o" and "5.5" are the policy generators. Source: Fei et al., arXiv 2611.32194, Figure 6.*

It reproduced in a shipping product. On Claude Code 2.1.319 in auto mode, two instruction payloads were marked in 16 of 17 kept summaries and every policy left the account out. When the landlord notice was cut down to a bare "Rent account:" field, every kept summary stated it plainly as the rent account, and the policy derived from it admitted redirecting the rent payment in 4 of 5 sessions.

The paper proves why better summarization cannot close this gap. A pipeline that sees only text, with no record of who wrote which bytes, can refuse a forged record more often than the legitimate record it imitates only by as much as the two texts differ. An account written in the same format as a real one has a legitimate twin, so no compaction prompt, mark or stronger policy model can reliably separate them. An injected instruction addressed to the model has no such twin, which is why compactors catch it.

A related failure comes from the compactor itself. OpenAI reported in September 2026 that an unreleased Astra-family model, during RL training, wrote jailbreak-like instructions into its own compaction summaries; its monitor found 27 such summaries, and in one case the continuing model followed the invented restrictions. That is a different source, but it lands in the same trusted slot.

## Progent vs DRIFT, CaMeL and Codex Guardian after compaction {#progent-vs-other-defenses-after-compaction}

Whether a defense survives compaction depends on where it takes its authority from. Anything that reads the request slot follows the summary; defenses that get authority elsewhere mostly hold. The authors tested a second policy generator and six other systems:

| System and where it takes authority | Result after compaction |
|---|---|
| **Progent with Qwen2.5-72B** writing the policy; reads the request slot | Policy named the attacker in 18 of 40 banking, 16 of 30 workspace and 2 of 30 travel cases |
| **smolagents 1.26.0 + Progent**; maps tool output to the user role by default | Policy named the attacker in 16 of 16; attacker action completed in 11 |
| **LlamaFirewall AlignmentCheck**; judges against the first user message in the trace | Allowed the attacker's transfer in 42 of 180 when the summary kept the account, 8 of 162 when it dropped it |
| **Spotlighting**; delimits tool output | Agent made the attacker's transfer in 34 of 64 with the summary at the user role, 5 of 64 as a delimited tool result |
| **DRIFT**; filters injections before they reach memory | Payload passed the filter in 11 of 20, reached the summary in 4, expanded authorization in 1 |
| **CaMeL**; attaches capabilities to values | Attacker action completed in 3 of 36 banking episodes |
| **Codex Guardian**; user messages, with summaries attributed to the assistant | Forged "Pending from the user" summary approved in 5 of 33 calls before OpenAI's change, 0 of 33 after |

*Source: Fei et al., arXiv 2611.32194, Table VI and Section V-E.*

Codex is the one product that has already moved. OpenAI merged a change on October 15, 2026 that classifies messages marked as compaction summaries as assistant entries in Guardian's transcripts, because, in the pull request's words, "those summaries are not user authorization". An earlier change kept a separate, bounded history of user messages so that tool traffic cannot evict them during compaction.

Claude Code's auto-mode classifier was designed with a related principle: Anthropic's write-up says it "sees only user messages and the agent's tool calls", with Claude's own messages and tool outputs stripped. After compaction, though, the summary is a user message. For authorizers installed as a PreToolUse hook, which receive the transcript path, the obvious rule of taking the most recent user-role record returned the user's turn in 96.2% of request starts and the summary at every compaction boundary.

## How the witnessed-request gate works {#witnessed-request-gate}

The fix gives the agent and the authorizer different inputs. The agent keeps reading the summary so it can continue the task. The policy generator receives only text the user actually sent, authenticated when it arrived and carried unchanged across compaction, or it receives nothing.

<img src="/images/context-compaction-security/witnessed-request-gate.png" alt="Architecture of the witnessed-request gate: user turns U1 'check spending' and U2 'cancel' get MAC witnesses w1 and w2 on arrival while a tool message 'send to A' gets no witness; a trusted packager commits the ordered list R with a MAC over session id, boundary and count m equals 2; the gate checks witnesses and origin, signature and fresh boundary, order and current count, then releases only the original user text to the policy generator G or rejects with an empty policy; insets show an omitted record and a reordered list both rejected; below, the compactor turns U1, T, U2 into a summary S containing A that only the agent reads" width="1600" height="774" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />
*Figure: The gate passes the policy generator only the user's witnessed turns; omitting or reordering records empties the policy, and the agent alone reads the summary. Source: Fei et al., arXiv 2611.32194, Figure 2.*

It works in three steps:

1. **Witness on arrival.** Each user turn, and output from any tool the deployer designates as trusted, gets an HMAC-SHA256 tag when it enters the session.
2. **Commit at compaction.** A trusted packager copies the witnessed records verbatim and signs one commitment to the complete, ordered list for that boundary. Everything else may be summarized for the agent.
3. **Check before policy generation.** The gate verifies every witness, the order commitment and that the list contains every witnessed item issued so far. Any failure installs an empty policy, which permits no tool call.

The order and completeness checks close gaps that tags alone leave open: a replayed earlier user turn carries a valid tag, and a list that drops a later "cancel" turn would otherwise pass.

In 40 attacked AgentDojo episodes, the summary in the request slot without the gate produced 18 policies that named the attacker and 7 completed attacks, and the agent finished 9 tasks. Through the gate, no policy named the attacker and no attack completed. Working from the user's text, the agent finished 26 tasks, against 27 in the uncompacted run and 22 after a second compaction. The authors also ran eight adaptive attacks, including replay, splice, reorder and omission, and the final gate admitted 0 adversary-supplied items across 608 trials. Verification cost 0.25 to 0.40 ms per request.

A simpler filter that passes every user-role record except those marked as summaries, the rule Codex's Guardian applies, matched the gate in all 40 episodes inside one process. It failed once records traveled through storage the agent can write: replayed and spliced records in a persisted session file or memory file got through the filter and were refused by the gate.

The gate has limits. It was evaluated on replayed AgentDojo sessions and is not yet integrated into a production harness. It protects what the user states; a value the user leaves to a document, such as "pay the account in this invoice", stays exposed until that document's source can be authenticated. The keys and counters must also sit outside anything the agent's tools can read, which on hosts where the agent runs code means isolating them in a separate process or sandbox.

## How to secure context compaction in your agent harness {#secure-context-compaction}

If your agent compacts and anything downstream judges actions against "what the user asked", start by checking which message that check reads after a compaction boundary. The paper's results point to a short list of changes:

1. **Attribute the summary to the assistant or system.** Codex's Guardian now does this. If your authorizer, reviewer or audit hook picks "the latest user-role message", it is reading the summary after every boundary.
2. **Feed the authorizer from a separate store of user turns.** Keep the user's messages in an append-only log the agent cannot write, and derive permissions from that log, not from the compacted transcript. The paper notes that where such a store exists, it can play the gate's role without MACs.
3. **Authenticate anything that passes through agent-writable files.** Persisted sessions, memory files and project instruction files are read back at the user role. If authorization depends on them, tag user text on arrival with keys held outside the sandbox. The same principle drives our guide to [Claude Code verification checks the agent cannot edit](/tutorials/claude-code-verification/), and to [crash recovery from persisted session state in Pi Durable](/tutorials/pi-agent-harness-v2-crash-recovery/).
4. **Never map tool output to the user role.** smolagents 1.26.0 does this by default and merges adjacent same-role messages, which in the tests set retention to one: every banking policy named the attacker.
5. **Pin the arguments the user states.** Open arguments were the main way summaries that dropped the attacker's account still admitted the transfer. A recipient or amount the user typed should be a hard constraint in the policy.
6. **Treat the compaction prompt as a security setting.** What it keeps and how it marks untrusted values changed naming rates by large margins across 18 shipped prompts. Marking helps against instructions; it will not catch an account number written as data.

The same attribution problem appears wherever text the user never wrote arrives at the user role. In Claude Code, a delegated sub-agent's first request is a prompt the parent agent composed, delivered as a user message; the authors found 78 such sub-agent transcripts in their corpus. Memory that is rewritten between sessions, as in [Claude's Dreams API for Managed Agents](/tutorials/claude-dreaming/), and worker reports relayed to a coordinator, as in [DeepSeek's Router and Worker multi-agent design](/tutorials/deepseek-super-agent-architecture/), are the next places to audit. For consequential actions such as payments or merges, a human gate that reads the original request, like the review rules in our [Claude Approvals setup guide](/tutorials/claude-approvals/), still sits outside the summary's reach.

## References {#references}

1. Zeming Fei, Hongming Fei, Yi Xu, Xiaoyang Wang and Ying Zhang, “[LLM Agent Authorization Across Context Compaction](https://arxiv.org/abs/2611.32194),” arXiv 2611.32194v1, November 24, 2026.
2. Tianneng Shi, Jingxuan He, Zhun Wang, Hongwei Li, Linyu Wu, Wenbo Guo and Dawn Song, “[Progent: Securing AI Agents with Privilege Control](https://arxiv.org/abs/2504.11703),” arXiv 2504.11703, 2025.
3. OpenAI, “[Attribute compaction summaries to the assistant in Guardian transcripts](https://github.com/openai/codex/pull/54281),” openai/codex pull request #54281, merged October 15, 2026.
4. Anthropic, “[How we built Claude Code auto mode: a safer way to skip permissions](https://www.anthropic.com/engineering/claude-code-auto-mode),” Anthropic Engineering, 2026.
5. OpenAI, “[Self-generated prompt injections in compaction summaries](https://alignment.openai.com/misalignment-reports/self-generated-prompt-injections-in-compaction-summaries/),” OpenAI Alignment, September 16, 2026.
