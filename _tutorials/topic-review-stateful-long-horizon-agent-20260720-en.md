---
layout: article-sky
article_variant: research-review
lang: en
title: "Stateful Long-Horizon Agents: 10 Key Papers"
seo_title: "Stateful Long-Horizon Agents: 10 Key Papers"
description: "A review of 10 recent papers on stateful long-horizon agents, covering memory operations, execution continuity, verified recovery, and delayed actions."
keywords: "stateful agents, long-horizon agents, AI agent memory, ContinuityBench, MemOps, StructAgent, PM-Bench"
tags: [agents, memory, long-horizon, surveys]
categories: [frontier-research]
permalink: /tutorials/stateful-long-horizon-agents-review/
thumbnail: "/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.15899v1__architecture1.jpg"
og_image: "/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.15899v1__architecture1.jpg"
date: 2026-07-20
last_modified_at: 2026-07-23
author_name: "AgentsPulse Editorial Team"
cover_alt: "ContinuityBench architecture for preserving state across LLM provider failover"
cover_width: 1200
cover_height: 800
paper_count: 10
research_scope: "Memory · Recovery · Continuity"
dek: "How recent agent systems preserve state, manage memory operations, recover from failure, and execute reliably over long time horizons."
key_takeaways:
  - "Reliable long-horizon behavior depends on explicit state, not a longer prompt alone."
  - "Memory works best as a lifecycle of operations: ingest, organize, retrieve, update, and forget."
  - "Recovery and prospective memory must be evaluated as first-class agent capabilities."
article_toc:
  - id: "the-core-problem-why-long-horizon-agents-are-brittle"
    label: "Why Long-Horizon Agents Are Brittle"
  - id: "a-modern-taxonomy-memory-is-a-lifecycle-not-a-database"
    label: "Memory as a Lifecycle"
  - id: "architectural-blueprints-building-for-state-recovery-and-evolution"
    label: "Architectural Blueprints"
  - id: "measuring-what-matters-benchmarking-for-continuity-fidelity-and-budget-pressure"
    label: "Benchmarks That Matter"
  - id: "conclusion-the-stateful-agent-as-an-integrated-system"
    label: "Conclusion"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/self-evolving-agents-review-en/"
    title: "Self-Evolving Agents: Model, Harness, and Artifact Evolution"
    description: "A foundation-first taxonomy for persistent improvement across the agent stack."
  - url: "/tutorials/measuring-reward-seeking-contrastive-beliefs/"
    title: "Measuring Reward-Seeking in RL-Trained Models"
    description: "A causal evaluation of whether RL-trained models follow intent or inferred grader preferences."
---
The industry's focus is shifting from single-turn, stateless models to long-horizon agents that must maintain state, memory, and execution continuity across hours or days. This transition introduces critical engineering challenges in context management, state verification, and infrastructure resilience.

This review synthesizes 10 representative papers, covering major research routes over more than a year, to provide a clear framework for understanding and building these next-generation agents. These papers—*ContinuityBench*, *MemOps*, *KnowAct-GUIClaw*, *PM-Bench*, *RCWT*, *StructAgent*, *Memory Agents<sup>[1]</sup>*, *LongMemEval*, *MemGPT*, and *Generative Agents*—are organized not by chronology, but by the problems they solve, from conceptual frameworks to production-grade engineering.

This review will provide an at-a-glance overview of the 10 papers, categorizing their primary contribution to illustrate the landscape of research into stateful agents.

| Paper Short Name | Primary Contribution | Core Concept |
| :--- | :--- | :--- |
| **ContinuityBench** | Engineering Analysis & Benchmark | Quantifying context loss during infrastructure failover. |
| **MemOps** | Benchmark | Evaluating memory as a lifecycle of explicit operations. |
| **KnowAct-GUIClaw** | System Architecture | A self-evolving agent that learns from its execution history. |
| **PM-Bench** | Benchmark | Measuring an agent's ability to perform delayed actions. |
| **RCWT** | Engineering Analysis & Benchmark | Measuring context budget pressure from coordination overhead. |
| **StructAgent** | System Architecture | Using a unified causal state for verifiable, recoverable execution. |
| **Memory Agents<sup>[1]</sup>** | Conceptual Framework | A modern taxonomy for agent memory (form, function, dynamics). |
| **LongMemEval** | Benchmark | Evaluating core long-term memory abilities in chat assistants. |
| **MemGPT** | System Architecture | Managing context windows like an OS manages memory. |
| **Generative Agents** | Conceptual Framework | A cognitive architecture for memory, reflection, and planning. |

## The Core Problem: Why Long-Horizon Agents Are Brittle

The fundamental engineering challenges that make long-horizon agents unreliable often stem not from model reasoning errors, but from unmanaged state, silent context loss, and the physical limits of context windows. Failures in these systems are frequently engineering problems disguised as intelligence problems.


A pervasive and under-measured failure occurs during infrastructure outages. When a primary model provider fails, stateless failover logic may successfully route a request to a secondary provider, maintaining system availability. However, this process often silently discards the conversational history, creating a "continuity gap."

The system appears healthy, but the user experiences an abrupt and frustrating reset. The *ContinuityBench* paper introduces a framework to quantify this specific failure, proposing metrics like Continuity Preservation Rate (CPR) to measure how much state is successfully transferred during a failover event.

![StructAgent: Harness Long-horizon Digital Agents with Unified Causal Structure](/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.11388v1__p04_StructAgent_framework_page_1.jpg){: loading="lazy" width="1200" height="671" }
*StructAgent architecture*

Even without infrastructure failures, the fixed context window of a transformer model is a hard physical constraint. As a conversation or task progresses, new information competes with historical context for limited space in the prompt. This forces a constant trade-off between retaining past details and processing current instructions.

*MemGPT* frames this as an operating system-level memory management problem. It proposes a "virtual context management" system where the LLM itself, guided by OS-like principles, pages information between the fast, limited memory of the context window and slower, external storage.

The way most agents handle history—as an unstructured, append-only log of interactions—exacerbates this problem. This makes it difficult to verify progress, recover from errors, or maintain a clear causal understanding of the task.

*StructAgent* argues that the solution is to replace raw history with a "unified causal state." This structured representation tracks requirements, verified evidence, and discovered values, making the agent's progress auditable and recoverable.

![Generative Agents: Interactive Simulacra of Human Behavior](/images/topic-review-stateful-long-horizon-agent-20260720-en/2304.03442v2__p01.jpg){: loading="lazy" width="1200" height="635" }
*Generative Agents figure*

Finally, long-term coherence requires more than just a large memory store; it demands a cognitive architecture that operates on that memory. The *Generative Agents* paper pioneered a foundational architecture for this.

By implementing a loop where agents record experiences to a "memory stream," synthesize these memories into higher-level "reflections," and use those reflections to generate future "plans," it demonstrated how raw experience can be transformed into coherent, long-term behavior.

## A Modern Taxonomy: Memory Is a Lifecycle, Not a Database

To build better agents, we need a more nuanced vocabulary for memory that moves beyond simple long-term versus short-term distinctions. A modern view reframes memory as a set of dynamic operations, functional roles, and future-directed intentions.

![Memory Agents](/images/topic-review-stateful-long-horizon-agent-20260720-en/2512.13564v1__p05_comparison_page_1.jpg){: loading="lazy" width="1200" height="577" }
*Memory Agents results*

The *Memory Agents<sup>[1]</sup>* survey provides a comprehensive taxonomy for understanding agent memory through three lenses: its form, its function, and its dynamics.

Memory can exist in different forms, such as token-level (in-context), parametric (in model weights), or latent (in hidden states). It also serves distinct functions, such as factual (storing knowledge), experiential (recording events), and working (holding task-relevant information). Finally, its dynamics describe how memory is formed, evolves, and is retrieved over time.

![MemOps: Benchmarking Lifecycle Memory Operations in Long-Horizon Conversations](/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.12893v1__p02_generation_pipeline_page_1.jpg){: loading="lazy" width="910" height="371" }
*MemOps workflow*

This dynamic view is critical. Memory is not a static collection of facts but a lifecycle of explicit operations.

The *MemOps* paper argues that benchmarks must evaluate these operations—remember, forget, update, reflect—directly to correctly diagnose failures. Existing benchmarks that only score the final answer of a QA task can credit a correct response even if the agent's internal memory state is inconsistent or relies on outdated information.

*MemOps* introduces a benchmark that evaluates the fidelity of each memory operation, providing a more interpretable, diagnostic approach.

One of the most critical and under-evaluated memory capabilities is "prospective memory"—the ability to remember to perform a delayed action at a future cue. The *PM-Bench* paper isolates and measures this capability using a paradigm adapted from cognitive science.

An agent must not only recall *what* it needs to do but also act at the *right time*, often while engaged in other activities. This is distinct from simple retrospective recall and is essential for reliable personal assistants.

The cognitive architecture from *Generative Agents* provides a foundational blueprint for implementing these advanced memory dynamics. The proposed loop—where a continuous stream of observations is periodically synthesized into higher-level reflections, which in turn inform future plans—is a concrete example of how an agent can transform raw, unstructured experience into actionable, long-term goals.

## Architectural Blueprints: Building for State, Recovery, and Evolution

Several concrete architectural patterns have emerged for building stateful agents that can manage state, structure workflows, and enable advanced capabilities like verified recovery and skill acquisition.

The *StructAgent* framework centralizes a "unified causal state" and a "structured workflow." In this model, progress is only committed after passing through a verifier. This ensures that the agent's state is always auditable and grounded in evidence, rather than relying on the model's self-reported claims of success.

This structure directly supports robust recovery; if a task is interrupted, the agent can resume from the last verified checkpoint, without needing to replay a long and noisy interaction history.

![MemGPT: Towards LLMs as Operating Systems](/images/topic-review-stateful-long-horizon-agent-20260720-en/2310.08560v2__page_2_Figure_1.jpg){: loading="lazy" width="1143" height="414" }
*MemGPT figure*

In contrast, *MemGPT* implements "virtual context management" inspired by operating systems. It uses an explicit memory hierarchy with function calls that allow the LLM to "page" context between a fast tier (the prompt) and a slow tier (external storage).

This gives the illusion of an infinite context window while using a standard, fixed-context model. Control is managed through interrupts, allowing the system to pause, manage memory, and then resume its task.

![KnowAct-GUIClaw: Know Deeply, Act Perfectly, Personal GUI Assistant with Self-Evolving Memory and Skill](/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.12625v2__know-route-act-reflect.jpg){: loading="lazy" width="1200" height="821" }
*KnowAct-GUIClaw workflow*

The *KnowAct-GUIClaw* framework demonstrates how agents can learn and generalize from past trajectories. Its "Know-Route-Act-Reflect" loop is designed for complex GUI tasks. After executing a task, the "Reflect" stage distills the successful (or unsuccessful) trajectory into an evolving library of skills and memories.

This allows the agent to improve over time, finding more efficient paths and reusing successful sub-routines in future tasks.

Even a tightly focused system like the stateful proxy proposed in *ContinuityBench* offers an architectural blueprint. It uses a "History-Forwarding" strategy to intercept requests, persist conversational state, and reconstruct that state for a fallback provider during a failover, ensuring continuity is preserved across different LLM services.

These architectures can be contrasted across several key dimensions, revealing different philosophies for building robust agents.

| Architecture | State Representation | Workflow Control | Recovery Mechanism |
| :--- | :--- | :--- | :--- |
| **StructAgent** | Unified Causal Graph (requirements, values, evidence) | Verifier-backed state transitions | Restore from last verified checkpoint |
| **MemGPT** | Hierarchical Memory (main context vs. external storage) | LLM-managed via function calls and interrupts | Re-synthesis of context from external memory |
| **KnowAct-GUIClaw** | Experience-attributable memory and skill library | "Know-Route-Act-Reflect" loop | Reuse of learned skills and past trajectories |
| **ContinuityBench** | Persisted Conversation Log | History-forwarding proxy | Reconstruct and forward full history on failover |

## Measuring What Matters: Benchmarking for Continuity, Fidelity, and Budget Pressure

Evaluating long-horizon agents requires moving beyond simple task success rates. A new generation of benchmarks measures specific operational capabilities, such as state preservation during failures, memory operation fidelity, and performance under context budget pressure.

![LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory](/images/topic-review-stateful-long-horizon-agent-20260720-en/2410.10813v2__p03_mem_system_unified_view_page_1.jpg){: loading="lazy" width="1200" height="298" }
*LongMemEval architecture*

Memory evaluation must go beyond final-answer accuracy. *LongMemEval* tests five core abilities needed for long-term interaction, such as multi-session reasoning and knowledge updates, using questions embedded in extensive chat histories.

*MemOps* takes a more granular approach, diagnosing failures at the level of individual memory operations like *remember*, *forget*, and *update*. It can detect, for example, when an agent correctly answers a question but relies on a stale value that should have been updated, a failure mode invisible to outcome-only evaluation.

System robustness must be measured under stress. *ContinuityBench* introduces metrics like the Continuity Preservation Rate (CPR) to explicitly quantify context loss during infrastructure failover events.

This provides a clear, measurable target for building resilient multi-provider systems, moving beyond the simple assumption that a 200 OK status code means the conversation is intact.

![RCWT: Measuring Task-Budget Displacement from Coordination Content in LLM Calls](/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.12216v1__p01.jpg){: loading="lazy" width="1200" height="720" }
*RCWT figure*

Context is a finite resource with measurable costs. In multi-agent or memory-augmented systems, coordination content like role instructions, memory summaries, and tool outputs compete with task-critical evidence for space in the prompt.

The *RCWT* paper isolates and measures this "task-budget displacement," showing how adding coordination data can push essential task information out of the prompt, causing sharp performance cliffs. This work demonstrates that context budget is an engineering resource that must be actively managed, not just expanded.

![PM-Bench: Evaluating Prospective Memory in LLM Agents](/images/topic-review-stateful-long-horizon-agent-20260720-en/2607.12385v1__x1.jpg){: loading="lazy" width="996" height="823" }
*PM-Bench figure*

Finally, specific cognitive capabilities like prospective memory require dedicated evaluation. *PM-Bench* provides a controlled testbed to assess an agent's ability to execute delayed intentions, a capability missed by standard QA benchmarks.

By forcing the agent to maintain an ongoing activity while monitoring for cues to perform a deferred task, it tests a crucial aspect of reliable, long-term autonomy.

## Conclusion: The Stateful Agent as an Integrated System

A truly robust, long-horizon agent is not just a powerful LLM. It is an integrated system that combines a structured causal state, a lifecycle-aware memory, and resilient failover mechanisms, all while actively managing a finite context budget.

The research reviewed here provides the conceptual tools and architectural blueprints for building such systems.

The path forward is to move away from treating agents as a monolithic model and instead architect them as integrated systems with distinct, well-defined components. A structured and verifiable state, as proposed by *StructAgent*, provides the foundation for reliable and auditable execution.

Memory must be treated as a dynamic lifecycle of operations, as diagnosed by *MemOps*, and managed with OS-like discipline, as demonstrated by *MemGPT*. The physical constraints of the context window must be acknowledged and budgeted for, an effect quantified by *RCWT*.

Finally, the entire system must be resilient to real-world infrastructure failures, with state continuity explicitly preserved, as shown by *ContinuityBench*.

By combining these principles, the industry can move from building brittle, stateless tools to engineering reliable, stateful companions capable of maintaining context, recovering from failure, and executing complex tasks over the long horizons required for true partnership.

## References

1. Memory in the Age of AI Agents. arXiv:2512.13564v1. 2025. <http://arxiv.org/abs/2512.13564v1>.
2. ContinuityBench: A Benchmark and Systems Study of Stateful Failover in Multi-Provider LLM Routing. arXiv:2607.15899v1. 2026. <http://arxiv.org/abs/2607.15899v1>.
3. MemOps: Benchmarking Lifecycle Memory Operations in Long-Horizon Conversations. arXiv:2607.12893v1. 2026. <http://arxiv.org/abs/2607.12893v1>.
4. KnowAct-GUIClaw: Know Deeply, Act Perfectly, Personal GUI Assistant with Self-Evolving Memory and Skill. arXiv:2607.12625v2. 2026. <http://arxiv.org/abs/2607.12625v2>.
5. PM-Bench: Evaluating Prospective Memory in LLM Agents. arXiv:2607.12385v1. 2026. <http://arxiv.org/abs/2607.12385v1>.
6. RCWT: Measuring Task-Budget Displacement from Coordination Content in LLM Calls. arXiv:2607.12216v1. 2026. <http://arxiv.org/abs/2607.12216v1>.
7. StructAgent: Harness Long-horizon Digital Agents with Unified Causal Structure. arXiv:2607.11388v1. 2026. <http://arxiv.org/abs/2607.11388v1>.
8. LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory. arXiv:2410.10813v2. 2024. <http://arxiv.org/abs/2410.10813v2>.
9. MemGPT: Towards LLMs as Operating Systems. arXiv:2310.08560v2. 2023. <http://arxiv.org/abs/2310.08560v2>.
10. Generative Agents: Interactive Simulacra of Human Behavior. arXiv:2304.03442v2. 2023. <http://arxiv.org/abs/2304.03442v2>.
