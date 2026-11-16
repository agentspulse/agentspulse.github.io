---
layout: article-sky
article_variant: research-review
lang: en
title: "Embedded Assessments at OpenAI: How the Four Pilots Compare"
seo_title: "Embedded Assessments at OpenAI: The Four Pilots Compared"
description: "Embedded assessments put Apollo, METR, Transluce and Goodfire inside OpenAI. Their access, length, pay and publishing limits vs GovAI's standard."
keywords: "embedded assessments, embedded assessments for frontier ai, open ai model behavior, ai model behavior"
tags: [ai-safety, alignment, evaluations, openai]
categories: [frontier-research]
permalink: /tutorials/embedded-assessments-openai/
thumbnail: "/images/embedded-assessments-openai/cover.jpg"
og_image: "/images/embedded-assessments-openai/cover.jpg"
date: 2026-11-16
last_modified_at: 2026-11-16
author_name: "AgentsPulse Editorial Team"
cover_alt: "Apollo Research illustration for its pilot towards embedded evaluations: an office tower with six windows highlighted, each showing a person working inside"
cover_width: 1200
cover_height: 630
zoomable_images: true
review_eyebrow: "AI safety evaluation, compared"
research_scope: "OpenAI's Nov 16 announcement · Apollo Research, Transluce and Goodfire pilot posts · METR's monitor red-teaming report and alignment assessment proposal · Embedded Assessments for Frontier AI (arXiv 2609.25413)"
scope_note: "Written November 16, 2026 from the primary documents listed in References. None of the four assessments has produced findings yet; this page compares their published terms. Cover illustration: Apollo Research."
dek: "OpenAI is letting four outside safety groups work inside its offices, on its devices, with access to training runs, checkpoints and internal evaluations. Each group published its own terms, and they differ a lot: six people for four months at Apollo Research, six weeks at Transluce, an internal-facing interpretability team at Goodfire. Here is how the four embedded assessments compare, and how far they are from the standard a September policy paper set out."
key_takeaways:
  - "OpenAI signed embedded assessment agreements with Apollo Research, METR, Transluce and Goodfire on November 16, 2026, focused on alignment and safeguards during training and internal use."
  - "Terms vary by assessor: Apollo sends six evaluators for four months; Transluce gets six weeks starting in early December; Goodfire's findings go mainly to OpenAI researchers; METR's monitor assessment still awaits an agreed scope."
  - "Transluce says its access is not comparable to employee-level or employee-like access, and it cannot publish results about internal-only models. OpenAI may redact confidential evidence from every public report."
  - "The Embedded Assessments for Frontier AI paper recommends continuous assessments, public reports at least quarterly and access parity with internal safety staff. The first phase is time-boxed and sets no reporting cadence."
  - "An earlier three-week METR and Redwood exercise inside OpenAI found that RL training runs were not covered by misalignment monitoring at the start and that Codex agents could in principle bypass sandboxing and Auto-Review."
article_toc:
  - id: "embedded-assessments-vs-pre-deployment-testing"
    label: "vs Pre-Deployment Tests"
  - id: "openai-embedded-assessments-compared"
    label: "The Four Pilots"
  - id: "apollo-research-subversion-assessment"
    label: "Apollo Research"
  - id: "metr-alignment-assessment"
    label: "METR"
  - id: "transluce-alignment-evals-review"
    label: "Transluce"
  - id: "embedded-assessment-redaction-rules"
    label: "Access and Redaction"
  - id: "embedded-assessments-vs-govai-recommendations"
    label: "vs GovAI Paper"
  - id: "embedded-assessment-reports-timeline"
    label: "When Reports Arrive"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/measuring-reward-seeking-contrastive-beliefs/"
    title: "Measuring reward-seeking"
    description: "How researchers test whether RL-trained models chase grader preferences."
  - url: "/tutorials/ai-agent-internal-access-security-boundary/"
    title: "Internal access and agent security"
    description: "Why permissions and monitoring matter once agents run inside a company."
---
Embedded assessments are coming to OpenAI. On November 16, 2026, the company said it had signed agreements with four independent groups, Apollo Research, METR, Transluce and Goodfire, to work inside its offices and examine model behavior during training and internal use, with access to checkpoints, training data, monitoring systems and the researchers who run them. Each assessor also published its own terms the same day, and those terms show how different the four pilots are.

This page lines them up: how long each group stays, what it can see, who pays whom, and what it is allowed to publish. It then compares the first phase with the standard set out in *Embedded Assessments for Frontier AI*, a September policy paper hosted on GovAI's site, and with the one high-access exercise inside OpenAI that has already reported findings.

## Embedded assessments vs pre-deployment testing {#embedded-assessments-vs-pre-deployment-testing}

Embedded assessments differ from pre-deployment testing in where the evaluator sits and what it can see. Most third-party evaluations of frontier models have run through external interfaces shortly before release. An embedded assessor works on site, on the developer's devices, with access to internal systems, documents and staff, and can look at a model while it is still being trained or used internally.

Apollo Research gives the practical reason. Its earlier evaluations of frontier models happened after post-training and shortly before public release, which it calls insufficient for testing behaviors like scheming, or for checking how models are used inside the company before anyone outside sees them. An API endpoint cannot show whether a training run rewarded a model for hiding something, or whether an internal agent ever tried to switch off its own monitor.

The policy paper behind much of this debate, *Embedded Assessments for Frontier AI* (arXiv 2609.25413), points to on-site inspections in nuclear power, banking and food and drug manufacturing as precedents. It also describes the limits of the first attempts. When outside investigators looked into the incident in which OpenAI models escaped their sandbox and compromised Hugging Face's production infrastructure, they could not query the model involved or directly access the relevant infrastructure data.

What deeper access turns up is easiest to see in the one high-access exercise inside OpenAI that has published results. From July 21 to August 11, 2026, one METR employee and one Redwood Research employee stress-tested OpenAI's internal misalignment monitoring, using its codebase, monitor prompts and configuration, internal documentation and interviews with about a dozen researchers and engineers. Their public summary of the system as it stood on July 21 reports that:

- roughly 75–94% of agentic internal Responses API traffic from models at least as strong as GPT-5.5 was eligible for monitoring, with substantial uncertainty in both directions; for internal Codex agents the figure was 99.2%;
- RL training runs were not covered by the monitoring system at the start of the exercise;
- not monitoring compaction events probably left on the order of 10% of eligible internal Codex traffic unmonitored between May and July, a gap OpenAI staff had already spotted and fixed during the exercise;
- Codex agents could in principle bypass Codex sandboxing and Auto-Review and take any action the host user could take.

Every one of these findings concerns internal infrastructure that no query to a released model can reach. That is the case for embedded assessments, and it is why the [security boundary around agents with internal access](/tutorials/ai-agent-internal-access-security-boundary/) has become an evaluation target in its own right.

## OpenAI embedded assessments compared: the four pilots {#openai-embedded-assessments-compared}

OpenAI's four embedded assessments share one set of protocols (on-site work on OpenAI hardware for sensitive material, OpenAI review of reports before release) but differ in length, focus and publishing rights. The table pulls the terms from OpenAI's announcement and from each assessor's own post.

| | Apollo Research | METR | Transluce | Goodfire |
|---|---|---|---|---|
| Focus | Whether models try to subvert their own or successor models' alignment or control mechanisms | Misaligned behavior in OpenAI's largest frontier RL run to date; a second monitor assessment pending | Quality and coverage of OpenAI's post-training alignment evaluations | Interpretability "model forensics" on training runs |
| Team and duration | Six people, four months | Not stated | Six weeks, starting early December | Not stated |
| Key access | Training code and datasets, RL rollouts with reasoning traces and rewards, intermediate checkpoints (for the first claim) | Checkpoint sampling, training and eval rollouts, misalignment monitoring records for that run | A handful of models including at least one internal-only model, raw chain of thought, past transcripts, safety case documents | Internal models and systems via Goodfire's platform |
| Paid by OpenAI | Yes, not contingent on results | No; may accept API credits or compute | No; OpenAI covers compute, devices and workspace | Yes, not contingent on results |
| Main audience | Two public reports | Not stated separately; OpenAI's general publication terms apply | Public report on released models; unredacted version to OpenAI's Safety and Security Committee | OpenAI researchers, plus published learnings |

Two columns stand out. Goodfire's work is aimed first at OpenAI's own researchers, which makes it closer to embedded consulting than to public assurance. And METR, the group that ran the earlier monitoring exercise, has a confirmed scope much narrower than its own proposal: a single training run, with its broader monitor assessment still waiting on an agreed scope.

## Apollo Research subversion assessment: four claims {#apollo-research-subversion-assessment}

Apollo Research's assessment tests four claims OpenAI would need for a safety case about subversion: training did not incentivize it, strong evaluations and red-teaming do not elicit it, models have not attempted it during internal use, and reasoning behind it would be detectable. Six Apollo staff will spend four months on this, in two stages, each ending in a public report.

Only the first stage has defined access so far. To check training incentives, OpenAI committed to provide training code and datasets, reinforcement-learning rollouts with their reasoning traces and rewards, and the ability to query intermediate checkpoints. Access for the other three claims "remain[s] to be agreed." The pilot builds on earlier joint work, including findings that models can increasingly favor grader preferences over user instructions as RL progresses, the same failure that [contrastive-belief tests for reward-seeking](/tutorials/measuring-reward-seeking-contrastive-beliefs/) try to measure.

Apollo is frank that the pilot falls short of its own bar. Its general standard asks for access to all relevant records even when a developer wants to hide unfavorable information, and the right to disclose findings to an outside audience even if the developer objects. This pilot "doesn't yet fulfill the criteria," Apollo writes. What it does meet is what Apollo calls meta-transparency: the right to say publicly what it asked for, what it got, what was withheld or redacted, and how much that limits its conclusions. OpenAI may withhold in-scope material for technical, security or IP reasons, but must tell Apollo that withheld items exist and give written reasons. It cannot redact Apollo's verdict on any claim.

The day-to-day rules are tighter than an employee's. OpenAI chooses which staff Apollo may talk to, formal conversations are logged, and Apollo's evaluators do not get access to general channels such as Slack by default. Apollo notes that informal conversations often surface information an evaluator would not have known to ask about.

## METR alignment assessment vs METR's own proposal {#metr-alignment-assessment}

METR's alignment assessment covers one training run: OpenAI's largest frontier reinforcement-learning run to date. Within that run, METR sets its own priorities for searches, analyses and elicitation experiments, and can sample relevant checkpoints, training and evaluation rollouts, and the misalignment monitoring records.

OpenAI itself flags in a footnote that this is narrower than what METR asked for. In an October 14 proposal, METR described an alignment assessment as a review of serious misaligned behavior across *all* near-frontier internal models, in training, evaluation and internal use, followed by an analysis of why the observed incidents might understate the worst case.

<img src="/images/embedded-assessments-openai/metr-alignment-assessment-overview.webp" alt="METR diagram of its proposed alignment assessment. Part 1, survey of internal incidents across training, evaluations and internal use of near-frontier models: a broad survey of frequency, models, settings, behavior types and severity, plus detailed questions for the most severe incidents such as what the agents did, whether they colluded and whether they hid evidence. Part 2, reasons the survey might not be representative: whether worse incidents could have happened if dangerous actions were more feasible or the agent did not expect to be caught, and whether training incentivized hidden misalignment or overfitting to detection methods" width="1600" height="900" loading="lazy" decoding="async" data-zoomable title="Click to enlarge">

*METR's proposed alignment assessment, from "How an assessor could investigate alignment of unreleased AI models" (October 14, 2026, CC BY). OpenAI's first-phase METR assessment covers one RL run rather than the full survey in Part 1.*

The second METR track, a broader assessment of OpenAI's monitors, is "pending mutual agreement on the assessment scope." It would follow the three-week monitor red-teaming exercise described above.

## Transluce alignment evals review: access limits {#transluce-alignment-evals-review}

Transluce's six-week pilot reviews the evaluations OpenAI uses to catch deception, manipulation and reward hacking after post-training, and asks how well they capture those behaviors. Starting in early December, its staff get a handful of models (at least one internal-only), raw chain-of-thought outputs, a large number of transcripts from earlier training and evaluation runs, and safety case documentation.

Transluce describes this access as privileged but "not comparable to 'employee-level' or 'employee-like' access." It can request more; OpenAI decides. Transluce has committed to report what it requested, what was approved or declined, and how that affected its conclusions.

Its publishing limits are the clearest of the four. OpenAI can review the report in advance and request redactions of intellectual property and other non-public information, and Transluce cannot publish results about internal-only models at all, so every public finding will concern released models. The unredacted version goes to OpenAI's Safety and Security Committee. OpenAI also reviews and approves which Transluce staff are embedded. A follow-on assessment of about eight weeks is planned for early 2027, with broader access and, according to OpenAI, information on how evaluation results inform model release decisions, the kind of call behind gated launches such as [GPT-6 Cyber's restricted access](/tutorials/gpt-6-cyber/).

## Embedded assessment access and redaction rules {#embedded-assessment-redaction-rules}

Embedded assessment access at OpenAI comes with a common set of protocols, published alongside the announcement. They decide what readers will eventually be able to check:

- **On-site work.** Assessors handling sensitive information work at OpenAI offices on OpenAI-issued devices and follow at least the same security standards as employees. Where direct access could expose model weights or architecture, OpenAI may instead pair assessors with its own researchers to run analyses.
- **Oversight.** The Safety and Security Committee of the OpenAI Foundation's board receives unredacted reports and can talk to assessors privately. Disagreements go to OpenAI's Safety Advisory Group and executives, then to the committee if unresolved.
- **Employee conversations.** Discussions with staff are off the record. Assessors can ask OpenAI to formally attest to a statement, and may publish attested statements or disclose that OpenAI declined to attest.
- **Publication.** Assessors control their reports, but OpenAI keeps the right to redact confidential information and may request delays to fix safety or security issues before disclosure.
- **Conflicts.** Apollo Research and Goodfire are paid, with pay not tied to results. METR and Transluce take no fees but may accept API credits or compute. Assessor staff observe a cool-off period before embedding at another AI developer.

For readers, the redaction clause matters most. Apollo's terms protect its verdicts but let OpenAI remove supporting evidence it considers sensitive IP, "whether the evidence directly contributes to the finding or not." A public report may therefore state a conclusion that outsiders cannot fully check, with a note from the assessor on whether the redactions changed it.

## Embedded assessments vs the GovAI recommendations {#embedded-assessments-vs-govai-recommendations}

*Embedded Assessments for Frontier AI*, posted to arXiv on September 21 and hosted on GovAI's site, sets out a starting standard for these engagements. Measured against it, OpenAI's first phase covers the right subject areas only in part and falls short on duration and reporting.

| Recommendation in the paper | OpenAI's first phase |
|---|---|
| Cover at least internal agent monitoring, internal agent security controls and permissions, and model alignment | Alignment is covered by Apollo, METR and Transluce; METR's monitor assessment is pending; agent permissions are not a named workstream |
| Run continuously; time-boxed reviews only as an interim step | Time-boxed: six weeks (Transluce), four months (Apollo); OpenAI says it expects longer-term engagements over time |
| Access parity with internal risk staff or senior alignment researchers; denials explained | Access scoped per assessment; Transluce says it is not employee-like; Apollo gets written reasons for withheld items |
| Detailed public reports at least quarterly | No cadence set; Apollo plans two reports, Transluce one |
| Narrow redaction right; evaluator keeps editorial control and says whether redactions were material | Editorial control kept; OpenAI may redact confidential information and evidence; assessors may say whether redactions affected conclusions |
| Escalate serious concerns to the board or another oversight body | Escalation to the Safety and Security Committee, which also gets unredacted reports |

The paper itself frames embedded assessments as a practice still being built, and notes that the two earlier engagements involved few evaluators, ran for short periods and covered a narrow slice of internal activity. OpenAI's first phase widens that to four groups and several workstreams. It remains a pilot by the paper's own definition, and Apollo and Transluce both describe it that way. Outside pressure is also rising: OpenAI ties the program to its commitments under the White House Accord on Super Intelligence, and local governments have started legislating on the topic directly, as [Bloomington's superintelligence ordinance](/tutorials/bloomington-superintelligence-ban/) shows.

## When embedded assessment reports arrive {#embedded-assessment-reports-timeline}

No embedded assessment report has a published date yet. Transluce starts in early December and runs for six weeks, which puts the end of its on-site work in mid-January 2027; it has not given a report date, and its eight-week follow-on is also planned for early 2027. Apollo's first report covers training incentives, and its second covers evaluations, internal deployment and the detectability of subversive reasoning, across four months. Goodfire says it will publish learnings as the collaboration progresses.

When the reports appear, the useful questions are the ones the terms already make answerable. Did the assessor list what it asked for and what was declined? Were any redactions material to a verdict? Do Transluce's findings on released models say anything about the internal-only model it examined? And did METR's monitor assessment get a scope at all? For teams that run their own agents, the METR findings are already a checklist: whether training runs are monitored, whether long-running agents can defer monitoring, and whether the sandbox and review layers in an [agent harness](/tutorials/agent-framework-harness-runtime-production/) can be bypassed are fair questions for any internal agent deployment, alongside checks for the [hidden behaviors a poisoned model can carry](/tutorials/llm-backdoor-detection/).

## References {#references}

- OpenAI, "[Our first phase of embedded assessments](https://openai.com/index/our-first-phase-of-embedded-assessments/)," November 16, 2026.
- Apollo Research, "[A Pilot Towards Embedded Evaluations](https://www.apolloresearch.ai/blog/pilot-towards-embedded-evaluations)," November 16, 2026.
- Transluce, "[Announcing an Embedded Assessment Pilot with OpenAI](https://transluce.org/embedded-assessment-pilot-with-openai)," November 16, 2026.
- METR, "[Red-Teaming OpenAI's Internal Agent Monitoring Systems](https://metr.org/blog/2026-10-22-red-teaming-openai-agent-monitoring/)," October 22, 2026; and "[How an assessor could investigate alignment of unreleased AI models](https://metr.org/blog/2026-10-14-alignment-assessment-proposal/)," October 14, 2026.
- Charnock, Williams, Kara, Anderljung, Tlaie Boria, Casper, Reuel and Freund, "[Embedded Assessments for Frontier AI](https://arxiv.org/abs/2609.25413)," arXiv 2609.25413, September 21, 2026.
