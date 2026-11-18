---
layout: article-sky
article_variant: research-review
lang: en
title: "Superpowers for Claude Code: How the Workflow Works and What It Costs"
seo_title: "Superpowers for Claude Code: Workflow, Cost and Plan Mode"
description: "How Superpowers for Claude Code runs brainstorm, plan, subagent or native execution and TDD, what the release notes say it costs, and how it compares."
keywords: "superpowers claude, superpowers claude code, superpowers skills, obra superpowers, codex superpowers, openspec superpowers"
tags: [claude-code, coding-agents, agent-skills, ai-agents, code-review]
categories: [ai-coding-agents]
permalink: /tutorials/superpowers-claude-code/
thumbnail: "/images/superpowers-claude-code/cover.jpg"
og_image: "/images/superpowers-claude-code/cover.jpg"
date: 2026-11-18
last_modified_at: 2026-11-18
author_name: "AgentsPulse Editorial Team"
cover_alt: "Diagram comparing two ways Superpowers runs a plan: subagent-driven execution gives each task its own implementer and reviewer context before a final branch review, while native execution runs every task in one session context and adds one final branch review"
cover_width: 1200
cover_height: 660
zoomable_images: true
review_eyebrow: "Workflow breakdown"
research_scope: "obra/superpowers README, skill files (using-superpowers, brainstorming, writing-plans, subagent-driven-development, executing-plans, test-driven-development) and RELEASE-NOTES through v7.0.2 (Nov 3, 2026) · Jesse Vincent's launch post (Oct 9, 2025) · GitHub issue #750 on token use · the emschwartz.me review and its Hacker News thread · the OpenSpec README, all read Nov 18, 2026"
scope_note: "Speed, token and quality figures come from Superpowers' own release notes and evals, or from individual users in GitHub issues; none is an independent benchmark, and we did not run Superpowers ourselves. A Reddit thread that ranks for this topic was blocked when we tried to read it and is not cited."
dek: "Superpowers is a set of skills for Claude Code and 14 other coding agents that stops the agent from coding straight away: it brainstorms a design with you, writes a plan, then executes it test-first with built-in review. Here is how each stage works in a session, how subagent-driven and native execution differ in cost, what the project's own measurements and its users' token complaints show, and how it compares with plan mode and OpenSpec."
key_takeaways:
  - "A session-start hook injects a bootstrap that tells Claude to invoke any skill with even a 1% chance of applying, before it answers. Your CLAUDE.md or AGENTS.md instructions still take precedence."
  - "The flow is brainstorming, a git worktree, a written plan, execution, test-driven development, review and branch finishing. You approve twice: the design doc, then the plan."
  - "Subagent-driven execution gives every task a fresh implementer and reviewer; native execution does all tasks in your session with one final review and is the cheapest mode the project offers."
  - "Superpowers' own evals credit version 6.0 with similar quality at roughly twice the speed and almost 50% fewer tokens than the previous review flow. Users in issue #750 still report hitting session limits on small tasks."
  - "Compared with plan mode, you review a short sketch before a full design doc that lives in your repo. OpenSpec decides what to build; Superpowers governs how the agent builds it."
article_toc:
  - id: "how-superpowers-works-in-claude-code"
    label: "How it works"
  - id: "superpowers-workflow-stages"
    label: "Workflow stages"
  - id: "subagent-driven-development-vs-native-execution"
    label: "Subagent vs native"
  - id: "superpowers-token-cost"
    label: "Token cost"
  - id: "superpowers-vs-claude-code-plan-mode"
    label: "vs plan mode"
  - id: "superpowers-vs-openspec"
    label: "vs OpenSpec"
  - id: "superpowers-codex-cursor-other-agents"
    label: "Codex, Cursor, others"
  - id: "install-superpowers-claude-code"
    label: "Install and tune"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/claude-code-verification/"
    title: "Claude Code verification"
    description: "How the Claude Code team makes agents prove a change works before handing it back."
  - url: "/tutorials/coding-agents-finops-cost-per-successful-task/"
    title: "Coding agent FinOps"
    description: "Why cost per successful task beats cost per token."
  - url: "/tutorials/antigravity-teamwork/"
    title: "Antigravity Teamwork"
    description: "A milestone-gated agent team with audit gates, for comparison."
---

Superpowers for Claude Code changes what happens after you type "let's build X": instead of writing code, Claude asks why you want it, proposes two or three approaches, and writes a design document you approve before anything gets built. Jesse Vincent released it on October 9, 2025, the day Anthropic shipped Claude Code's plugin system, and his company Prime Radiant now maintains it for 15 coding agents. Version 7.0.2, released November 3, 2026, is current.

What decides whether it is worth installing sits in its skill files and release notes more than in the README: two approval gates, a choice between a thorough and a cheap execution mode, and token use that the maintainers have cut repeatedly and users still complain about.

## How Superpowers works in Claude Code {#how-superpowers-works-in-claude-code}

Superpowers works in Claude Code through one hook and one rule. When a session starts, a `SessionStart` hook injects the `using-superpowers` skill as a bootstrap. That skill tells Claude that if there is "even a 1% chance a skill might apply" to what it is doing, it must invoke the skill, and it must do so before any response, including a clarifying question or a quick look at the codebase.

Everything else follows from that rule. The skills are Markdown files with a description and instructions, the same packaging as single-purpose add-ons such as the [Claude Code bug bounty skills](/tutorials/claude-code-bug-bounty/); what Superpowers adds is a bootstrap that makes them fire in sequence. Once it is in context, "let's build X" routes to the `brainstorming` skill and "fix this bug" routes to `systematic-debugging` before any domain skill runs. The bootstrap also lists a table of excuses Claude might use to skip a skill ("The skill is overkill", "I'll just do this one thing first") and tells it to treat each as a red flag. The README sums it up as "Mandatory workflows, not suggestions."

Two details matter in practice:

- **Your instructions win.** The same bootstrap says instructions in CLAUDE.md, AGENTS.md or a direct request take precedence over skills. When a user in [GitHub issue #750](https://github.com/obra/superpowers/issues/750) asked for a config file to skip steps, Vincent replied that putting those preferences in AGENTS.md already does it.
- **Subagents opt out.** A subagent dispatched for a specific task is told to ignore the bootstrap, so implementers and reviewers spend their context on the task rather than on skill discovery.

The bootstrap is paid for in every session. Version 6.1.0 trimmed it for that reason, and the Codex build dropped its session-start hook entirely because, the release notes say, Codex triggers skills reliably on its own.

## Superpowers workflow stages, from brainstorm to merged branch {#superpowers-workflow-stages}

A Superpowers workflow has seven stages, each run by its own skill, and two points where it waits for you. Each stage leaves a file or a branch behind, which is what lets a long run survive context compaction and lets you edit the plan in your own editor.

<img src="/images/superpowers-claude-code/superpowers-workflow.webp" alt="Flow of one Superpowers session in Claude Code: a session-start hook injects the bootstrap; brainstorming produces a design doc in docs/superpowers/specs; gate one, you approve the design; using-git-worktrees and writing-plans create an isolated branch and a plan in docs/superpowers/plans; gate two, you approve the plan and pick subagent-driven or native execution; every task runs test-driven development with a progress ledger; a final whole-branch review runs on the most capable model; finishing-a-development-branch merges, opens a PR, keeps or discards the branch" width="1200" height="1620" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*One Superpowers session, from the session-start hook to a finished branch. Based on the Superpowers v7.0.2 README and skill files; diagram by AgentsPulse.*

1. **brainstorming.** Claude asks why you want the change, plays back what it heard, and sizes the work. A small change gets a short design agreed in chat; a project gets a full design document with an Approaches section covering two or three options and their trade-offs, committed to `docs/superpowers/specs/`. For projects, a fresh subagent then reads the design as the person who will build it and lists what it would still need to ask. Nothing is built until you approve the design.
2. **using-git-worktrees.** Superpowers creates an isolated worktree on a new branch, runs project setup and checks that the tests pass before work starts.
3. **writing-plans.** The plan goes to `docs/superpowers/plans/`. Since version 6.4.2 it records decisions rather than full code: exact signatures, test assertions and the spec's values, one checkable action per step, plus a Review Focus section for failure modes the spec implies but no test covers. You review the saved plan and choose an execution mode.
4. **subagent-driven-development or executing-plans.** The two modes are compared in the next section. Either way, the run doesn't stop to ask "should I continue?" between tasks; it stops only for irreversible or security-sensitive actions, side effects outside the worktree such as a push or merge, or a plan too broken to follow.
5. **test-driven-development.** Every task writes a failing test, watches it fail, writes the minimum code to pass and commits. Code written before its test is deleted.
6. **requesting-code-review.** Reviews check work against the plan and report issues by severity; critical issues block progress.
7. **finishing-a-development-branch.** After the tests pass, you choose to merge, open a pull request, keep the branch or discard it, and the worktree is cleaned up.

Version 7.0.2 retuned the first stage. In Prime Radiant's blind-graded test conversations, filler questions fell from 41 with 7.0.1 to 23, Claude drew out the reason behind the request before proposing an approach in 33 of 33 conversations (28 of 33 before), and nothing was built before approval, which had happened four times with the previous version.

## Superpowers subagent-driven development vs native execution {#subagent-driven-development-vs-native-execution}

Subagent-driven development buys a clean context and a review for every task; native execution buys a lower bill. At the plan handoff, Superpowers states what each mode costs and recommends one for your plan, with a reason taken from how much the tasks depend on each other, how many there are and what a shipped mistake would cost.

| | Subagent-driven | Native (inline) |
|---|---|---|
| Who writes the code | A fresh implementer subagent per task | Your current session, task by task |
| Review | A task reviewer after each task (spec compliance and code quality), then one whole-branch review | One fresh whole-branch review at the end |
| What you pay | A new context per task and per review, each re-reading the codebase | One context plus one reviewer |
| What it protects against | Context pollution across tasks; mistakes caught task by task | Relies on the brief as spec, the ledger as memory and TDD as the per-task gate |
| Skill | `subagent-driven-development` | `executing-plans` |

Native execution only became a real option in version 6.4.1. Before that, `executing-plans` was a 64-line stub that, by the project's own measurement, behaved the same as running with no plugin at all. The rebuilt version is described in the release notes as "the cheapest way to run a plan" and runs well on a mid-tier session model.

The subagent mode carries most of the engineering. Each plan gets a workspace under `.superpowers/sdd/<plan-name>/` with a `progress.md` ledger, because a controller that loses its place after compaction tends to re-dispatch tasks it already finished, which the skill calls "the single most expensive failure observed". Task text and diffs are handed to subagents as files rather than pasted into prompts; in one real session a single dispatch reached 42,000 characters, 99% of it pasted history. Every dispatch must name a model: cheap models for tasks whose plan already contains the code, mid-tier as the floor for reviewers, and the most capable model for the final review. The skill notes that the cheapest models often take two to three times as many turns on multi-step work, which can make them more expensive overall.

On Claude Code there is a third setting. Since 6.4.1 you can ask the controller itself to run one level down as a nested subagent on a mid-tier model, which the maintainers measured at about half the cost and wall-clock time. It is off unless you ask for it.

## Superpowers token cost: release notes vs user reports {#superpowers-token-cost}

Superpowers token cost comes from the brainstorming, planning and review turns it adds to every change, and how large it gets depends on the execution mode and the version you run. The maintainers have published several before-and-after measurements; users have published complaints. Neither side has run an independent benchmark against plain Claude Code.

### What the Superpowers release notes measured

- **Version 6.0.0 (June 16, 2026).** After rewriting subagent review to one reviewer per task, with diffs passed as files, the release notes say that "in our evals, Claude Code and Codex produce similar high-quality results roughly twice as fast and while spending almost 50% fewer tokens", with the caveat that the numbers won't hold on every harness or workload. The release notes frame this against the earlier Superpowers review flow; they do not compare it with running Claude Code without the plugin. The same release explains why model choice became mandatory: one run had placed all 26 of its reviewers on the top-tier model.
- **Version 6.4.2 (September 25, 2026).** Plans now record decisions instead of transcribing code. Some frontier models, Opus 5.5 among them, had sometimes started implementing the whole project while writing the plan; in the reproduced case, plans took a quarter of the time and about a third of the tokens after the change.
- **Version 6.4.1 (September 18, 2026).** The nested mid-tier controller on Claude Code measured at about half the cost and wall clock.

### What Superpowers users report

[Issue #750](https://github.com/obra/superpowers/issues/750), opened in March 2026, collects the complaints. One Claude Code Pro user hit the session limit on a relatively simple task without finishing it, then reran it with the brainstorming spec review skipped and saw roughly half the usage. Two Codex users said they burned a five-hour quota on one unfinished task, or a week's credits in a single day, and another reported a cleared Claude Code session starting at 78,000 tokens of context, which they attributed to Superpowers. In August, a Codex user on version 6.2.0 described skill checks before nearly every reply and worktrees, specs and plans that were out of proportion to small tasks.

Several of those reports predate fixes. The OpenCode bootstrap was moved out of a system message that repeated every turn in version 5.0.7, the subagent mode was made optional again, and the bootstrap was trimmed in 6.1.0. The underlying trade-off remains: brainstorming, a written plan and per-task review are extra model calls. For cost per finished task rather than per token, see our [coding agent FinOps breakdown](/tutorials/coding-agents-finops-cost-per-successful-task/).

## Superpowers vs Claude Code plan mode {#superpowers-vs-claude-code-plan-mode}

Superpowers and Claude Code's plan mode both make Claude plan before it codes; the difference is how much you review at once and where the plan lives. The Superpowers bootstrap even tells Claude to run brainstorming before entering plan mode.

The clearest account comes from a [review on emschwartz.me](https://web.archive.org/web/20260929183143/https://emschwartz.me/a-rave-review-of-superpowers-for-claude-code/) published in April 2026 by a user with no connection to the project. In plan mode, the author wrote, Claude produced a multi-page plan and answered feedback with a whole new multi-page plan. With Superpowers the sequence ran brainstorming, options with trade-offs, a short plan sketch, then the full design doc and implementation plan, so by the time the long document arrived the direction was already agreed. The plan is also a Markdown file in the repository that you can edit in your own editor.

The [Hacker News discussion](https://news.ycombinator.com/item?id=47623101) added counterpoints:

- One commenter agreed plan mode's accept-or-cancel choices were rigid, but said Superpowers "too lacks flexibility" and only improves things by adding the sketch stage.
- Others pointed out that the Claude Code VS Code extension now lets you comment on specific parts of a plan, which narrows the gap.
- One user liked the brainstorming and the adversarial subagent review of the spec but found the separate implementation plan often ended up as code blocks in Markdown, a problem version 6.4.2 later addressed.
- Another said Claude made more mistakes with Superpowers than without and warned others not to treat it as "a silver bullet".

If your tasks are small and you already ask Claude to list its questions before planning, plan mode plus a [verification loop](/tutorials/claude-code-verification/) covers much of the same ground with fewer turns. Superpowers earns its overhead on multi-hour features where a wrong direction is expensive and you want the design, plan and review trail written down.

## Superpowers vs OpenSpec {#superpowers-vs-openspec}

OpenSpec and Superpowers sit at different layers: OpenSpec decides what gets built, and Superpowers controls how the agent builds it. They come up together because both start with a spec.

| | OpenSpec | Superpowers |
|---|---|---|
| Purpose | A lightweight spec layer so you and the agent agree on what to build | A methodology that changes how the agent works through a change |
| Main commands or triggers | `/openspec-explore`, `/openspec-propose`, `/openspec-apply-change`, `/openspec-archive-change` | Skills trigger automatically from the bootstrap |
| Artifacts | `openspec/changes/<name>/` with a proposal, specs, design and tasks, archived when done | Design doc in `docs/superpowers/specs/`, plan in `docs/superpowers/plans/`, a worktree branch |
| Strictness | "Update any artifact anytime, no rigid phase gates" | Approval gates, mandatory TDD, per-task or final review |

Because OpenSpec leaves implementation discipline to the agent and Superpowers keeps no living spec after a branch is finished, the two can in principle be combined, with an OpenSpec proposal as the input Superpowers' brainstorming starts from. Neither project documents that combination, so treat it as a workflow to test rather than a supported setup.

## Superpowers on Codex, Cursor and other agents {#superpowers-codex-cursor-other-agents}

Superpowers runs on Codex, Cursor and 13 other harnesses, and you install it separately in each one. The README lists Claude Code, Antigravity, the Codex app and CLI, Cursor, Devin CLI, Factory Droid, Gemini CLI, GitHub Copilot CLI, Grok Build CLI, Kimi Code, OpenCode, Pi, Qwen Code, Hermes Agent and Muse. Codex users install it from the official Codex plugin marketplace through `/plugins`, and Cursor users with `/add-plugin superpowers`.

The bootstrap does not load the same way everywhere, and that changes behaviour:

- **Codex** ships without a session-start hook because it triggers skills on its own.
- **Antigravity** has no session-start event; the bootstrap loads because the `using-superpowers` description says to use it at the start of any conversation. Prime Radiant verified this across 12 runs on agy 1.3.1. If you use Antigravity's own multi-agent mode, our [Antigravity Teamwork guide](/tutorials/antigravity-teamwork/) covers how its audit gates differ.
- **Hermes Agent** has no post-compaction hook, so a very long session can lose the bootstrap; the README advises starting a fresh session when skills stop triggering.
- **OpenCode and Codex** used to install by telling the agent to fetch and follow a remote INSTALL.md, which one Hacker News commenter compared to `curl | bash` with an LLM in the loop. Codex now has a marketplace entry; OpenCode still uses that method.

Pi loads the skills natively and re-injects the bootstrap after compaction; our [DeepSeek Harness vs Pi comparison](/tutorials/deepseek-harness-vs-pi-agent/) covers that harness. The one-install-per-harness rule also applies when you drive several agents from one interface such as [T3 Code](/tutorials/t3-code/): each underlying agent needs its own copy.

## How to install Superpowers in Claude Code and tune it {#install-superpowers-claude-code}

To install Superpowers in Claude Code, run one command from Anthropic's official plugin marketplace, restart, and check that brainstorming fires before any code:

```bash
/plugin install superpowers@claude-plugins-official
```

The project's own marketplace works too: `/plugin marketplace add obra/superpowers-marketplace`, then `/plugin install superpowers@superpowers-marketplace`. To confirm the install, start a fresh session and send "Let's make a react todo list"; a working install starts the `brainstorming` skill instead of writing code.

Then decide how much of the process you want:

1. **Write your preferences into CLAUDE.md or AGENTS.md.** Superpowers follows your instructions over its own. Use this to skip the design write-up for small changes, default to native execution, or keep worktrees out of a repo.
2. **Pick native execution for tightly coupled or cost-sensitive plans.** Choose subagent-driven when tasks are independent and a mistake reaching main would be costly.
3. **Ask for the nested controller on Claude Code** if your session runs on an expensive model and you use subagent-driven mode.
4. **Diagnose a bad session.** If a skill fires when it shouldn't, the agent repeats work or the bill surprises you, ask Claude to "figure out what went wrong with superpowers in this session". The `diagnosing-superpowers` skill reads the transcript and reports what happened with line-level evidence.
5. **Turn off the telemetry ping if you need to.** The optional visual companion in brainstorming loads a logo from Prime Radiant's site that includes your Superpowers version; set `SUPERPOWERS_DISABLE_TELEMETRY`, or Claude Code's `DISABLE_TELEMETRY`, to stop it.

Superpowers is MIT-licensed and free. It pays off on features that take hours, where the design doc and plan replace a long back-and-forth and per-task review catches problems before they compound. For quick fixes, the brainstorming and review turns cost more than they save, and plan mode or a direct prompt is the better tool.

## References {#references}

1. Jesse Vincent and Prime Radiant. "Superpowers" README and skill files, v7.0.2. GitHub, read November 18, 2026. [github.com/obra/superpowers](https://github.com/obra/superpowers)
2. Prime Radiant. "Superpowers Release Notes," full changelog through v7.0.2 (November 3, 2026). [RELEASE-NOTES.md on GitHub](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
3. Jesse Vincent. "Superpowers: How I'm using coding agents in October 2025." October 9, 2025. [blog.fsck.com](https://blog.fsck.com/2025/10/09/superpowers/)
4. GitHub issue #750, "Superpowers consume a lot of tokens in Opencode with Codex," opened March 15, 2026. [Issue #750 on GitHub](https://github.com/obra/superpowers/issues/750)
5. "A Rave Review of Superpowers (for Claude Code)," emschwartz.me, April 2, 2026 (archived copy), and Hacker News discussion. [web.archive.org snapshot](https://web.archive.org/web/20260929183143/https://emschwartz.me/a-rave-review-of-superpowers-for-claude-code/) · [Hacker News thread](https://news.ycombinator.com/item?id=47623101)
