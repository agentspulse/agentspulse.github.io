---
layout: article-sky
article_variant: research-review
lang: en
title: "Agents Enter the Physical World: From VLA Policies to World Action Models"
seo_title: "Agents Enter the Physical World: From VLA Policies to World Action Models"
description: "Why physical agents need world action models alongside vision-language-action policies—and what current robotics results do and do not show."
keywords: "physical agents, VLA, world action models, embodied AI, robotics"
tags: [agent-infrastructure, frontier-research]
categories: [frontier-research]
permalink: /tutorials/physical-agents-world-action-models/
thumbnail: "/images/physical-agents-world-action-models/githubio_physical_agents_00_architecture.jpg"
og_image: "/images/physical-agents-world-action-models/githubio_physical_agents_00_architecture.jpg"
date: 2026-08-05
last_modified_at: 2026-08-05
author_name: "AgentsPulse Editorial Team"
cover_alt: "Agents Enter the Physical World: From VLA Policies to World Action Models"
cover_width: 1200
cover_height: 685
paper_count: 1
research_scope: "Embodied agents · Robotics · World models"
dek: "Why physical agents need world action models alongside vision-language-action policies—and what current robotics results do and do not show."
key_takeaways:
  - "Evidence-led analysis of the architecture, operational constraints, and production implications."
  - "Separates vendor-reported results from claims supported by broader evidence."
  - "Focuses on implementation decisions practitioners can evaluate today."
article_toc:
  - id: "tl-dr"
    label: "TL;DR"
  - id: "why-direct-vision-to-action-mapping-hits-a-ceiling"
    label: "Why Direct Vision-to-Action Mapping Hits a Ceiling"
  - id: "the-architecture-in-practice-two-layers-different-jobs"
    label: "The Architecture in Practice: Two Layers, Different Jobs"
  - id: "whole-body-control-and-the-limits-of-a-single-checkpoint"
    label: "Whole-Body Control and the Limits of a Single Checkpoint"
  - id: "multi-robot-coordination-and-multi-minute-task-sequences"
    label: "Multi-Robot Coordination and Multi-Minute Task Sequences"
  - id: "the-world-action-model-argument-in-autonomous-driving"
    label: "The World Action Model Argument in Autonomous Driving"
  - id: "distinguishing-vendor-framing-from-established-fact"
    label: "Distinguishing Vendor Framing From Established Fact"
  - id: "safety-as-a-structural-requirement-not-an-afterthought"
    label: "Safety as a Structural Requirement, Not an Afterthought"
  - id: "what-to-do-now"
    label: "What to Do Now"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "Why production agents need a runtime that controls state and tools."
  - url: "/tutorials/self-evolving-agents-review-en/"
    title: "Self-Evolving Agents"
    description: "A survey of agents that improve models, harnesses, and artifacts."
---
<img src="/images/physical-agents-world-action-models/githubio_physical_agents_00_architecture.jpg" decoding="async" loading="lazy" width="1200" height="685" alt="The Physical Agent Loop" />

*The Physical Agent Loop.*

In late July 2026, Google DeepMind published success-rate charts for an Apollo 2 humanoid with Inspire hands picking objects off a table, floor, and shelf — 68.4%, 45.7%, and 76.3% respectively, with visible error bars. The broader release reports that one Gemini Robotics 2 checkpoint controlled three hardware embodiments: Apollo 2 with SharpaWave hands, Apollo 2 with Inspire hands, and Franka Duo with a Robotiq gripper. A week later, NVIDIA published a technical comparison showing that swapping a robot policy's pretraining checkpoint from a base model to an omni checkpoint trained on multi-domain action data raised a benchmark success rate from 28.1% to 36.8%, holding data, recipe, and compute constant. Neither result describes a robot that works reliably in an uncontrolled home. Both describe something more specific and useful: two of the field's most resourced labs are reporting where their systems fail, by task category, and attributing gains to identifiable architectural choices rather than to scale alone.

That specificity matters because embodied AI has spent the last three years absorbing a template built for a different problem. The vision-language-action model, or VLA, takes an image and an instruction and outputs a motor command, following the same input-output shape that made large language models useful for text. It worked well enough to become the default architecture for generalist robot policies, and still underlies most production robot arms today. But an instruction-following model that has learned to describe scenes is not the same as a model that has learned how those scenes change under force, contact, and time. The gap between describing and predicting is where current research is concentrated, producing a second architectural layer — sometimes called a world action model, sometimes folded into an "embodied reasoning" model sitting above a VLA — whose job is to represent dynamics, predict consequences of candidate actions, and plan before handing control back down to a low-level policy.

This is a real architectural shift, documented in primary technical reports from two of the largest robotics and autonomous-driving efforts in the industry. It is not, on the evidence available, a demonstration that generalist embodied agents work outside curated tasks, calibrated benchmarks, and safety-constrained environments. The rest of this article works through the mechanism, the evidence, and what is and is not yet supported by it.

## TL;DR

- Google DeepMind's Gemini Robotics 2 separates a high-level embodied-reasoning model (ER 2) from a lower-level vision-language-action model, letting the system track multi-minute task progress and coordinate multiple robots, per DeepMind's own benchmark charts, which also show wide performance gaps between whole-body tasks (45–76% success) and multi-finger dexterity tasks (32–92% success), per [DeepMind](https://deepmind.google/blog/gemini-robotics-2-brings-whole-body-intelligence-to-robots/).
- NVIDIA's technical blog and accompanying paper argue for a video world-model backbone — a "world action model" or WAM — that learns physical dynamics alongside semantics. In one controlled ablation, an omni checkpoint pretrained on multi-domain action data raised success from 28.1% to 36.8% over a base checkpoint under the same data, recipe, and compute, per [NVIDIA](https://developer.nvidia.com/blog/beyond-vlas-how-world-action-models-reshape-robot-manipulation/).
- In autonomous driving, NVIDIA's Alpamayo 2 Super produces a trajectory alongside an explicit "chain-of-causation" trace and an intent label, an architecture built to make reasoning auditable against safety standards such as ISO/PAS 8800, according to NVIDIA's own release, an approach that is vendor-reported and not independently audited in this evidence set, per [NVIDIA](https://blogs.nvidia.com/blog/alpamayo-2-super-open-model-now-available/).
- Secondary analysis from Eventual AI, summarizing a conference talk by NVIDIA researcher Jim Fan, frames this shift as robotics repeating the large-language-model trajectory of pretraining, fine-tuning, and reinforcement learning — a framing and prediction, not an established empirical result, per [Eventual AI](https://www.eventual.ai/blog/vlas-are-dead-long-live-world-action-models).
- Independent, secondary reporting from Ars Technica confirms the Gemini Robotics 2 release and highlights that DeepMind's own reported metric for video-progress classification is close to 60% accuracy, underscoring that the reasoning layer itself is still an unreliable component, per [Ars Technica](https://arstechnica.com/ai/2026/07/google-reveals-gemini-robotics-2-0-promising-improved-dexterity-and-safety/).
- Every reported capability gain in this evidence set comes bundled with an explicit safety layer — refusal benchmarks, proximity-based stopping, auditable causation traces — suggesting vendors treat expanded autonomy and expanded constraint as inseparable, not that the underlying policies are safe by default.

## Why Direct Vision-to-Action Mapping Hits a Ceiling

The VLA architecture inherits its backbone from a vision-language model pretrained to produce accurate captions and answers about images, then fine-tuned with an action head to output motor commands. NVIDIA's developer blog makes the mechanism explicit: a VLM backbone is optimized to produce text about images, not to model how a scene evolves physically. It does not, by construction, learn what happens to a mug when a gripper closes around it, how fabric folds, or where a dropped object lands. Those are dynamics questions, not description questions, and a model trained only on the latter cannot be expected to answer the former just because it has been fine-tuned with more action-labeled demonstrations, according to [NVIDIA's technical blog](https://developer.nvidia.com/blog/beyond-vlas-how-world-action-models-reshape-robot-manipulation/).

<img src="/images/physical-agents-world-action-models/githubio_physical_agents_03_world-action-models-jointly-predict-future-observations-.jpg" decoding="async" loading="lazy" width="1200" height="631" alt="World Action Models jointly predict future observations and actions" />

*World Action Models jointly predict future observations and actions.*

This shows up empirically as a generalization problem rather than a training-data problem. A VLA that has seen a task performed with one mug in one lighting condition tends to need near-identical demonstrations to repeat it reliably with a different mug or a shifted camera angle, because its training signal maps instructions to trajectories rather than teaching transferable physics. NVIDIA's post argues this is why VLA-based generalist policies often need very close-to-identical demonstration coverage to perform well — a claim grounded in their internal comparison, not an industry-wide audit of all VLA deployments.

The proposed fix is architectural: instead of grafting an action head onto a language-and-vision backbone, build the policy on top of a video world model that has already learned to predict how visual scenes evolve over time, then post-train that model to also emit actions. NVIDIA calls the resulting class a world action model, and states that its Cosmos 3 foundation model was pretrained on roughly 767 million images, 348 million videos of real-world dynamics, and 8 million action samples spanning driving, manipulation, and egocentric motion, per the same NVIDIA source. The scale of that pretraining corpus is a vendor-reported figure, not independently re-verified in this evidence set, but it is a specific, falsifiable number rather than a marketing abstraction.

## The Architecture in Practice: Two Layers, Different Jobs

Both DeepMind's and NVIDIA's current systems converge on a similar two-layer control pattern, even though they were built for different domains — humanoid manipulation and autonomous driving, respectively.

<img src="/images/physical-agents-world-action-models/githubio_physical_agents_01_gemini-robotics-2-combines-embodied-reasoning-and-whole-.jpg" decoding="async" loading="lazy" width="1200" height="675" alt="Gemini Robotics 2 combines embodied reasoning and whole-body control" />

*Gemini Robotics 2 combines embodied reasoning and whole-body control.*

| Layer | Role | Google DeepMind implementation | NVIDIA implementation |
|---|---|---|---|
| High-level reasoning | Interprets instructions, tracks multi-step or multi-minute progress, predicts feasibility, coordinates with other agents | Gemini Robotics ER 2, a vision-language model that observes the scene, plans multi-step tasks, and can call safety tools, per [DeepMind](https://deepmind.google/blog/gemini-robotics-2-brings-whole-body-intelligence-to-robots/) | Alpamayo 2 Super's chain-of-causation trace plus meta-action output, explaining and labeling driving intent, per [NVIDIA](https://blogs.nvidia.com/blog/alpamayo-2-super-open-model-now-available/) |
| Dynamics / world model | Predicts how the scene will evolve under candidate actions | Not explicitly named as a separate world model in DeepMind's release; ER 2's video-progress tracking is the closest analog | Cosmos 3, a video world model backbone jointly predicting future frames and actions, per [NVIDIA](https://developer.nvidia.com/blog/beyond-vlas-how-world-action-models-reshape-robot-manipulation/) |
| Low-level control | Converts plan/prediction into motor commands | Gemini Robotics 2 (VLA) and Gemini Robotics On-Device 2, controlling full humanoid bodies and grippers, per DeepMind | Cosmos3-Nano-Policy-DROID and Cosmos3-Edge-Policy-DROID, post-trained action policies for a Franka arm, per NVIDIA |
| Safety layer | Constrains or halts action given uncertainty or proximity risk | ASIMOV-Agentic benchmark; proximity-based stop behavior in ER 2, per DeepMind's safety technical report | Chain-of-causation traces integrated with NVIDIA Halos safety validation, aligned to ISO/PAS 8800, per NVIDIA |

The pattern in this table is worth naming directly: none of these systems ship a single end-to-end model that goes straight from pixels to torque without an intermediate reasoning or prediction stage. That is the structural claim behind this article's thesis, supported by primary technical documentation from both organizations. What the table does not show — because the evidence does not support it — is a validated claim that this layering produces safe or reliable behavior outside the tested task set. DeepMind's own charts show multi-finger dexterity tasks such as "screw bulb" and "dustpan" succeeding at 36% and 32% respectively, alongside "unscrew bulb" at 92%, a spread wide enough that no single adjective like "dexterous" fairly characterizes the system's real capability.

## Whole-Body Control and the Limits of a Single Checkpoint

DeepMind's headline claim for Gemini Robotics 2 is that one model checkpoint controls three different physical embodiments — the Apptronik Apollo 2 humanoid with two different hand types, and a Franka Duo arm with a parallel gripper — across whole-body, gripper, and multi-finger manipulation tasks. This is a meaningful engineering result if accurate: cross-embodiment transfer without per-robot retraining has been a persistent bottleneck in robotics, and DeepMind explicitly frames prior systems as unable to transfer learned skills between robot bodies easily, per [DeepMind's release](https://deepmind.google/blog/gemini-robotics-2-brings-whole-body-intelligence-to-robots/).

The reported numbers back a qualified version of that claim. Whole-body pick tasks succeed in a 45–76% range depending on where the object starts (floor pickup is markedly harder than shelf pickup), and gripper-based dexterity on the Franka Duo ranges from 74% to nearly 90% depending on task type, with precise insertion tasks scoring highest. Multi-finger dexterity is the weakest category by a wide margin, and the variance within it — from 32% to 92% — suggests the model's competence is task-specific rather than a general dexterity capability transferring smoothly across manipulation primitives. DeepMind is transparent about this in its own materials, stating explicitly that "multi-finger dexterous manipulation remains challenging." That is a vendor's self-reported limitation, and should be read as such — a lab publishing its own benchmark numbers with the framing it chooses — but it is also a more specific and falsifiable acknowledgment than most industry announcements offer.

Independent reporting from Ars Technica adds a useful check on the reasoning layer specifically. The outlet notes that Gemini Robotics ER 2's progress-classification accuracy on video frames is close to 60%, which Ars Technica frames as an improvement over the prior model version but still "far from perfect." This is secondary reporting quoting a DeepMind-provided figure, not an independently reproduced measurement, but the framing is useful discipline against reading "our reasoning model tracks task progress" as a solved problem. A model that classifies frame completeness correctly a little better than half the time is a real component of a working pipeline; it is not yet a component on which safety guarantees can be built without additional redundancy.

## Multi-Robot Coordination and Multi-Minute Task Sequences

The other capability DeepMind foregrounds is task duration and multi-agent coordination: Gemini Robotics ER 2 is described as understanding when tasks begin and end, tracking hundreds of decisions across sequences lasting several minutes, and enabling different robot types to communicate and divide a workflow. This addresses a specific, previously acknowledged limitation — earlier VLA-only systems executed short, narrow instruction sequences and could not self-correct mid-task or coordinate with other agents, according to DeepMind's own framing of its predecessor systems.

It is worth being precise about what is demonstrated here versus what is claimed. DeepMind's blog post describes an example interaction — an instruction to place a watering can into a bin, executed across walking, picking, and placing steps — as an illustration of the capability, not as an aggregate statistic. The multi-robot collaboration feature is introduced with a description of what it "enables," without an accompanying success-rate table in the source material provided. This is a case where the primary source itself distinguishes between benchmarked capability (whole-body pick success rates, dexterity success rates) and narratively illustrated capability (the watering-can example, multi-robot teamwork), and a careful reader should preserve that distinction rather than treating the illustrative example as benchmark-backed.

## The World Action Model Argument in Autonomous Driving

NVIDIA's Alpamayo 2 Super applies a structurally similar idea to a different domain: instead of outputting only a driving trajectory, the model produces five coupled outputs — trajectory, chain-of-causation trace, meta-action label, auto-generated reasoning labels for training data, and grounded visual question answering — from a single foundation model built on the Cosmos 3 world model, according to [NVIDIA's release](https://blogs.nvidia.com/blog/alpamayo-2-super-open-model-now-available/). NVIDIA reports that Alpamayo 2 Super ranks first on the LingoQA driving-reasoning benchmark among roughly 40 evaluated models, outperforming Qwen2.5-VL 72B by 17.0 points, Gemini 2.5 Pro by 15.1 points, and GPT-4o by 23.2 points using NVIDIA's own Lingo-Judge metric. These are vendor-reported benchmark results on a single evaluation suite; they establish relative standing on that specific benchmark, not a general claim that Alpamayo 2 Super drives more safely than competing systems in deployment.

The reasoning-and-action coupling here serves a distinct and pragmatic purpose beyond raw capability: auditability. NVIDIA states that chain-of-causation traces integrate with its Halos safety-validation workflow and are built to support alignment with ISO/PAS 8800, an automotive AI-safety standard. This is the clearest example in the evidence set of a structural argument for the two-layer approach that has nothing to do with task success rate: an auditable reasoning trace lets developers "tie what the model observed to the action it selected," which matters for regulatory and engineering review independent of whether it improves raw driving performance. Whether that auditability reduces incident rates in deployed fleets is not addressed by anything in this evidence set — NVIDIA's claims here concern model architecture and benchmark standing, not deployment safety outcomes.

NVIDIA also reports a specific ablation that is the strongest piece of evidence in this pack for the "world model backbone beats language model backbone" argument: two DROID policies trained with identical data, recipe, and compute, differing only in whether the starting checkpoint came from a base model or an omni checkpoint pretrained on multi-domain action data, showed RoboLab success rates of 28.1% versus 36.8%. NVIDIA states this isolates the improvement to architecture rather than scale, per the [Cosmos 3 technical report](https://research.nvidia.com/labs/cosmos-lab/cosmos3/technical-report.pdf) as summarized in NVIDIA's own blog. This is one controlled comparison on one benchmark and one robot platform; it is meaningful evidence for the mechanism, not proof that the effect generalizes across all manipulation tasks or embodiments.

## Distinguishing Vendor Framing From Established Fact

The strongest formulation of the "world action model" thesis in this evidence pack comes not from either primary source but from secondary analysis: Eventual AI's summary of a conference talk by NVIDIA researcher Jim Fan, delivered at Sequoia's AI Ascent conference. That summary frames robotics as following "the exact same trajectory" as large language models — pretraining, supervised fine-tuning, reasoning-based reinforcement learning, then automated research — and predicts, per Fan, "95% certainty that we reach the end of the robotics technology tree by 2040." This is a named individual's stated confidence level in a talk, reported by a third party summarizing that talk; it is a prediction and a rhetorical framing, not a measured result, and should not be read alongside DeepMind's success-rate charts or NVIDIA's ablation study as evidence of the same epistemic weight.

<img src="/images/physical-agents-world-action-models/githubio_physical_agents_04_vlas-are-dead-long-live-world-action-models-a-summary-of.jpg" decoding="async" loading="lazy" width="1200" height="675" alt="The proposed shift from VLA policies to World Action Models" />

*The proposed shift from direct VLA policies to World Action Models.*

The same secondary source describes a system called Dream Zero that jointly decodes predicted video frames and robot actions, reportedly achieving "zero-shot generalization to tasks and verbs never seen in training," and reports a claimed scaling law relating egocentric pretraining hours to validation loss for dexterity tasks. These are attributed to the talk and are not corroborated by a primary paper or dataset description in this evidence pack. They illustrate where the field's research agenda is heading — toward reducing reliance on teleoperation and toward neural simulation for reinforcement learning — but the specific numeric and qualitative claims trace back to a single conference talk as relayed by a secondary blog, and a technical reader should hold them at that level of confidence, distinct from the benchmarked figures published directly by DeepMind and NVIDIA.

## Safety as a Structural Requirement, Not an Afterthought

Across both primary sources, expanded autonomy is released alongside an explicit constraint mechanism, and this pairing appears consistent enough to be a structural pattern rather than a coincidence. DeepMind introduces ASIMOV-Agentic, a benchmark measuring whether an embodied reasoning model will refuse unsafe tool calls from its own VLA and whether it can predict task infeasibility and request human intervention, alongside claims that Gemini Robotics ER 2 is DeepMind's "safest robotics model to date" on constraint-following and human-proximity benchmarks, with the ability to trigger a safe stop if a human approaches too closely, according to DeepMind's safety technical report referenced in its release. NVIDIA's Alpamayo pairs expanded reasoning output with integration into its Halos safety-validation product and explicit alignment with an automotive safety standard.

<img src="/images/physical-agents-world-action-models/githubio_physical_agents_02_independent-reporting-on-gemini-robotics-2-capabilities-.jpg" decoding="async" loading="lazy" width="1152" height="648" alt="Independent reporting on Gemini Robotics 2 capabilities and safety claims" />

*Independent reporting on Gemini Robotics 2 capabilities and safety claims.*

Both of these are vendor-authored safety claims, evaluated on vendor-designed or vendor-administered benchmarks, and neither source in this evidence pack includes third-party safety audits, incident data from deployed fleets, or independent replication of the safety benchmark results. That does not make the claims false; it means they should be read as reported capability on a stated test, not as a general safety guarantee. The practical implication for engineering teams evaluating these systems is to treat the safety benchmark scores the same way they would treat the task success rates: as domain-specific measurements under conditions the vendor controlled, useful for comparison and diligence, not as a substitute for independent validation before deployment in an environment with different risk exposure than the one tested.

## What to Do Now

Teams evaluating whether to adopt a world-action-model-style architecture over a conventional VLA should start by identifying which failure mode actually limits their current system: if the bottleneck is semantic (the model misunderstands instructions or novel object categories), a language-heavy VLA backbone may already be adequate, and the marginal benefit of a video world model backbone is unproven for that failure mode in this evidence pack. If the bottleneck is physical generalization — brittle performance when object geometry, contact dynamics, or lighting shift from training conditions — the NVIDIA ablation result (28.1% to 36.8% success from an architecture change alone) is a concrete, if single-benchmark, reason to pilot a world-model-backed policy on a held-out task set before committing engineering resources.

Where a two-layer reasoning-plus-control architecture is adopted, instrument the reasoning layer's own accuracy separately from end-to-end task success. Ars Technica's report that a DeepMind reasoning model's video-progress classification sits near 60% is a reminder that the "brain" coordinating a robot can itself be an unreliable component even when downstream manipulation succeeds most of the time on individual sub-tasks; teams should track this layer's calibration, not just aggregate task completion.

For any deployment touching physical safety, treat published safety benchmark numbers as a starting checklist for independent validation, not as a certification. Both DeepMind's ASIMOV-Agentic results and NVIDIA's ISO/PAS 8800 alignment claims are vendor-reported; procurement and safety review processes should request underlying evaluation methodology and, where feasible, run independent stress tests against proximity, refusal, and interruption scenarios relevant to the specific deployment environment.

Finally, distinguish conference-talk framing from benchmarked engineering results when briefing stakeholders. The "VLAs are dead" framing is a useful shorthand for an architectural trend genuinely visible in primary technical documentation from two major labs, but the specific numeric claims attached to that framing in secondary sources — scaling laws, zero-shot generalization figures, timeline predictions — have not been corroborated by a primary paper in this evidence pack and should be labeled as such in any internal or external communication.

## Evidence and Limits

The evidence supporting this article's thesis is real but narrow in scope. DeepMind's benchmark charts cover a specific set of manipulation and locomotion tasks on named robot platforms (Apptronik Apollo 2, Franka Duo), evaluated by DeepMind itself, without a described third-party replication in this evidence pack. NVIDIA's ablation study isolating the effect of a world-model-pretrained backbone is a single controlled comparison on the RoboLab benchmark using the DROID platform; it is a strong piece of mechanistic evidence but a single data point, not a demonstrated effect across manipulation tasks broadly. Alpamayo 2 Super's benchmark leadership is reported on LingoQA and NVIDIA's internal evaluation suite, using NVIDIA's own Lingo-Judge metric — informative for relative standing among evaluated models, not a general claim about deployed-fleet safety performance.

The secondary reporting in this pack (Ars Technica) independently corroborates that the Gemini Robotics 2 release occurred and adds a useful skeptical data point on reasoning-layer accuracy, but does not independently re-measure DeepMind's manipulation success rates. The secondary analysis (Eventual AI's summary of Jim Fan's talk) is valuable for understanding how researchers at NVIDIA are framing the field's trajectory, including specific system names and claimed results (Dream Zero, Ego-Scale, Dream Dojo) that do not appear in this pack's primary sources and should not be treated as independently confirmed. Predictions about timelines to "physical Turing test" or full automation of physical research are stated confidence levels from an individual, not measured outcomes.

Taken together, the evidence supports a specific, bounded claim: leading labs are architecturally separating world-dynamics prediction and multi-step reasoning from low-level motor control, and at least one controlled experiment shows this separation improving a manipulation benchmark score when other variables are held constant. It does not support a claim that generalist embodied agents are close to reliable, safe operation outside the demonstrated task sets, robot platforms, and safety-constrained conditions described in the primary sources.

## References

1. Google DeepMind. "Gemini Robotics 2 brings whole body intelligence to robots." https://deepmind.google/blog/gemini-robotics-2-brings-whole-body-intelligence-to-robots/
2. Ars Technica. "Google reveals Gemini Robotics 2.0, promising improved dexterity and safety." https://arstechnica.com/ai/2026/07/google-reveals-gemini-robotics-2-0-promising-improved-dexterity-and-safety/
3. NVIDIA. "NVIDIA Alpamayo 2 Super, the Frontier Open Model for Robotaxis and Autonomous Vehicles, Now Available for Commercial Use." https://blogs.nvidia.com/blog/alpamayo-2-super-open-model-now-available/
4. NVIDIA Technical Blog. "Beyond VLAs: How World Action Models Reshape Robot Manipulation." https://developer.nvidia.com/blog/beyond-vlas-how-world-action-models-reshape-robot-manipulation/
5. Eventual AI. "VLAs are dead, long live World Action Models - a summary of Jim Fan's Robotics End Game talk." https://www.eventual.ai/blog/vlas-are-dead-long-live-world-action-models
