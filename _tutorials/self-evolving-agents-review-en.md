---
layout: article-sky
article_variant: research-review
lang: en
title: "Self-Evolving Agents: Survey, Taxonomy, and How Self-Improving AI Agents Work"
seo_title: "Self-Evolving Agents: Survey, Taxonomy & How They Improve"
description: "A self-evolving agents survey and taxonomy: how self-improving AI agents update memory, tools, workflows, and weights, with papers and a build guide."
keywords: "self-evolving agents, self-evolving agent, self-improving AI agents, self-evolving agents survey, a taxonomy of self-evolving agents, self-evolving AI agents"
tags: [agents, self-evolution, surveys]
categories: [frontier-research]
thumbnail: "/images/359239/overview.jpg"
og_image: "/images/359239/overview.jpg"
cover_alt: "Three routes to agent self-evolution across models, harnesses, and artifacts"
cover_width: 1200
cover_height: 697
date: 2026-07-14
last_modified_at: 2026-09-03
author_name: "AgentsPulse Editorial Team"
paper_count: 8
research_scope: "Taxonomy · Papers · Implementation"
dek: "A survey and taxonomy of self-evolving agents, plus a practical map of how self-improving AI agents persist changes in memory, tools, workflows, and weights."
key_takeaways:
  - "Self-evolving agents persist a change in a named layer; self-improving AI agents is the broader overlapping label."
  - "A useful taxonomy names the write target: memory, tools, policy, workflow, model weights, or environment."
  - "A working loop needs feedback, evaluation, safety gates, and rollback—not just another prompt rewrite."
article_toc:
  - id: "what-are-self-evolving-agents"
    label: "What Are Self-Evolving Agents?"
  - id: "self-evolving-vs-self-improving"
    label: "Self-Evolving vs Self-Improving"
  - id: "taxonomy-of-self-evolving-agents"
    label: "A Taxonomy of Self-Evolving Agents"
  - id: "survey-of-self-evolving-agents"
    label: "Survey of Self-Evolving Agents"
  - id: "papers-at-a-glance"
    label: "8 Papers at a Glance"
  - id: "conceptual-foundations"
    label: "Conceptual Foundations"
  - id: "artifact-layer-evolution"
    label: "Artifact-Layer Evolution"
  - id: "harness-layer-evolution"
    label: "Harness-Layer Evolution"
  - id: "model-layer-evolution"
    label: "Model-Layer Evolution"
  - id: "representative-systems"
    label: "Representative Systems"
  - id: "how-to-build"
    label: "How to Build a Framework"
  - id: "open-problems"
    label: "Open Problems"
  - id: "conclusion"
    label: "Conclusion"
  - id: "awesome-self-evolving-agents"
    label: "Awesome Self-Evolving Agents"
  - id: "data-and-citation"
    label: "Data and Citation"
  - id: "references"
    label: "Original Papers"
related_research:
  - url: "/tutorials/stateful-long-horizon-agents-review/"
    title: "Stateful Long-Horizon Agents: 10 Key Papers"
    description: "See how memory, causal state, failover, and recovery support reliable long-running agents."
  - url: "/tutorials/measuring-reward-seeking-contrastive-beliefs/"
    title: "Measuring Reward-Seeking in RL-Trained Models"
    description: "See how causal interventions can reveal whether a model follows intent or inferred grader preferences."
---
<h2 id="what-are-self-evolving-agents">What Are Self-Evolving Agents?</h2>
<p class="sky-direct-answer"><strong>Self-evolving agents are AI systems that persistently improve part of themselves using feedback from their own prior execution.</strong> Depending on the architecture, the change can land in model weights, in the surrounding harness of prompts, memory, routing, and tools, or in external artifacts such as code and research outputs. Unlike temporary in-context adaptation, self evolution in AI agents produces changes that persist across tasks, sessions, or iterations, so the next run starts from a genuinely different system.</p>
<p>This self-evolving agents survey reviews eight representative systems and sorts them by a single question: <em>which layer of the agent actually changes?</em> The answer separates papers that share the "self-improving" label but do fundamentally different things. The comparison and taxonomy below make that split explicit before the paper-by-paper review.</p>
<p>Three nearby labels are easy to mix up. An <strong>autonomous agent</strong> can act without a human in the loop, but it need not change itself. An <strong>adaptive agent</strong> may change behavior within a session—retrieving extra context, switching tools, or rewriting a plan—without leaving a durable update. A <strong>self-improving AI agent</strong> is the overlapping commercial and research label for systems that get better over time. This review treats self-evolving agents as the stricter case: some component of the agent is updated from feedback, and that update is still there on the next run.</p>
<h2 id="self-evolving-vs-self-improving">Self-Evolving Agents vs Self-Improving AI Agents</h2>
<p>In papers and product copy the two phrases are often treated as synonyms. They overlap, but they are not identical. <strong>Self-improving AI agents</strong> is the broader search and marketing term: any agent that claims to get better from experience. <strong>Self-evolving agents</strong> is the more specific research term: the system runs a closed loop that writes a persistent change into memory, tools, policy, workflow, model weights, or the environment.</p>
<p>The practical test is persistence. If the next session starts from the same persistent state—including memory, prompts, tools, policies, workflows, and weights—the system adapted once; it did not evolve.</p>
<table>
<thead>
<tr>
<th></th>
<th>Self-evolving agents</th>
<th>Self-improving AI agents</th>
</tr>
</thead>
<tbody>
<tr>
<td>What is learned</td>
<td>A named layer: memory, tools, policy, workflow, weights, or environment</td>
<td>Any claimed gain over time; the write target is often left unspecified</td>
</tr>
<tr>
<td>Where feedback comes from</td>
<td>Stored traces, evaluators, or self-play that close a loop</td>
<td>Task outcomes, human ratings, or informal "it got better"</td>
</tr>
<tr>
<td>How the update is written</td>
<td>A persistent write to the harness, artifacts, or model weights</td>
<td>Prompt edits, logs, fine-tunes, or no durable write at all</td>
</tr>
<tr>
<td>Main risk</td>
<td>Drift, unsafe self-modification, irreversible tool or weight updates</td>
<td>The label outruns the mechanism</td>
</tr>
</tbody>
</table>
<h2 id="taxonomy-of-self-evolving-agents">A Taxonomy of Self-Evolving Agents</h2>
<p>Readers looking for a taxonomy of self-evolving agents usually want the evolution target, not a paper-by-paper recap. Gao et al. organize the field by <em>what</em>, <em>when</em>, and <em>how</em> to evolve. This review keeps a complementary cut: <em>which layer changes</em> (Model, Harness, Artifact), then names the write target inside that layer.</p>
<table>
<thead>
<tr>
<th>Evolution target</th>
<th>Layer in this review</th>
<th>What actually changes</th>
<th>Typical feedback</th>
<th>Examples</th>
</tr>
</thead>
<tbody>
<tr>
<td>Memory</td>
<td>Harness or Hybrid</td>
<td>Experience stores, templates, retrieved strategies, or trained memory modules</td>
<td>Task success or failure, contrastive traces</td>
<td>UI-Mem, BoundaryRouter, ReasoningBank, MemGen</td>
</tr>
<tr>
<td>Tools</td>
<td>Harness</td>
<td>MCP inventory, generated tools, dispatch rules</td>
<td>Tool tests and task success</td>
<td>Alita</td>
</tr>
<tr>
<td>Policy</td>
<td>Harness or Model</td>
<td>Routing, prompt choice, or a parametric policy</td>
<td>Retention, latency, execution reward</td>
<td>EEVEE, BoundaryRouter, AZR, AgentEvolver</td>
</tr>
<tr>
<td>Workflow</td>
<td>Harness or Artifact</td>
<td>Prompts, pipelines, experiment plans, research stages</td>
<td>Benchmark scores or structured human review</td>
<td>GEPA, FARS</td>
</tr>
<tr>
<td>Model weights</td>
<td>Model or Hybrid</td>
<td>Full weights, LoRA adapters, or trained memory modules</td>
<td>Verifiable execution or task reward</td>
<td>AZR, UI-Mem (hybrid), MemGen (hybrid), AgentEvolver</td>
</tr>
<tr>
<td>Environment</td>
<td>Artifact</td>
<td>Code, algorithms, or the tasks the agent trains on</td>
<td>Executable evaluators; self-questioning</td>
<td>AlphaEvolve, AZR proposer, AgentEvolver</td>
</tr>
</tbody>
</table>
<p>A system can occupy more than one row. UI-Mem updates memory and weights. MemGen trains memory modules without a full backbone fine-tune. AgentEvolver generates tasks, reuses experience, and trains a policy. The taxonomy locates the write; it does not claim that each paper occupies a single cell.</p>
<h2 id="survey-of-self-evolving-agents">Survey of Self-Evolving Agents</h2>
<p>Two recent surveys map the broader literature. Gao, Geng, Hua, Wang and colleagues organize self-evolving agents by what, when, how, and where to evolve (<a href="https://arxiv.org/abs/2507.21046">arXiv:2507.21046</a>). Fang, Peng, Zhang and colleagues review self-evolving AI agents as a bridge from static foundation models to lifelong agentic systems, with a feedback loop over system inputs, the agent, the environment, and optimisers (<a href="https://arxiv.org/abs/2508.07407">arXiv:2508.07407</a>).</p>
<p>This page is a narrower self-evolving agents survey: eight systems scored by a single question—which layer changes?—then three additional representative systems that engineers now search for by name. The eight-paper table below is the reading cut; the surveys above are the map of the field.</p>
<h2 id="papers-at-a-glance">8 Papers at a Glance</h2>
<p>The table below compares all eight systems on the layer they evolve, the feedback signal that drives evolution, whether model weights are updated, and the headline result reported by the authors.</p>
<table>
<thead>
<tr>
<th>Paper</th>
<th>Year</th>
<th>Primary layer</th>
<th>What evolves</th>
<th>Feedback signal</th>
<th>Weight update</th>
<th>Headline result</th>
</tr>
</thead>
<tbody>
<tr>
<td><a href="https://arxiv.org/abs/2506.13131">AlphaEvolve</a></td>
<td>2025</td>
<td>Artifact</td>
<td>Population of code files and algorithms</td>
<td>Automated executable evaluators</td>
<td>No</td>
<td>First improvement to Strassen-style 4×4 complex matrix multiplication in 56 years (49 → 48 multiplications)</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2606.31651">FARS</a></td>
<td>2026</td>
<td>Artifact</td>
<td>Research manuscripts and experiment plans</td>
<td>Shared workspace plus structured human review</td>
<td>No</td>
<td>166 complete papers across 67 topics, audited by 282 volunteer reviews</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2507.19457">GEPA</a></td>
<td>2025</td>
<td>Harness</td>
<td>System prompts on a Pareto frontier</td>
<td>Natural-language reflection on trajectories</td>
<td>No</td>
<td>Beats GRPO by ~10% on average with up to 35× fewer rollouts</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2606.11182">EEVEE</a></td>
<td>2026</td>
<td>Harness</td>
<td>Router assignments and per-cluster prompts</td>
<td>Test-time outcomes on heterogeneous streams</td>
<td>No</td>
<td>+41.53 cumulative retention in the incremental setting where GEPA and ACE go negative</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2602.05832">UI-Mem</a></td>
<td>2026</td>
<td>Harness + Model (hybrid)</td>
<td>Hierarchical experience memory alongside online RL</td>
<td>Online GUI task rewards</td>
<td>Yes (online GRPO)</td>
<td>Reusable workflow, skill, and failure-pattern templates transfer across mobile apps</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2505.20286">Alita</a></td>
<td>2025</td>
<td>Harness</td>
<td>On-demand MCP tool inventory</td>
<td>Tool testing and task success</td>
<td>No</td>
<td>75.15% pass@1 on GAIA validation, above OpenAI Deep Research at 67.36%</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2605.07180">BoundaryRouter</a></td>
<td>2026</td>
<td>Harness</td>
<td>Early-experience memory and routing policy</td>
<td>Paired LLM-versus-agent behavioral reference</td>
<td>No</td>
<td>60.6% less average inference time than always-agent, 28.6% better than always-LLM</td>
</tr>
<tr>
<td><a href="https://arxiv.org/abs/2505.03335">Absolute Zero (AZR)</a></td>
<td>2025</td>
<td>Model</td>
<td>Parametric weights via proposer–solver self-play</td>
<td>Code execution verification (RLVR)</td>
<td>Yes</td>
<td>State-of-the-art coding and math reasoning with zero external training data</td>
</tr>
</tbody>
</table>
<p>UI-Mem is the one hybrid case: its memory component is a harness artifact, but it is trained jointly with online reinforcement learning, so weights move as well.</p>
<hr />
<h2 id="conceptual-foundations">Conceptual Foundations: Model, Harness, Artifact, and the Agent Identity</h2>
<p>The eight-paper cut covers three primary loci of evolution—changing the artifact, the harness, or the model. They range from a zero-data reinforcement learning paradigm (Absolute Zero) to a fully automated research system deployed across 166 papers and 67 topics (FARS), from prompt evolution that outperforms gradient-based optimization (GEPA) to an evolutionary coding agent that discovered improvements to Strassen's algorithm after 56 years (AlphaEvolve). Model, Harness, and Artifact are analytical lenses for locating the write, not mutually exclusive buckets. Hybrid systems such as UI-Mem can change more than one layer.</p>
<p><strong>Model</strong> denotes the parametric language model whose weights encode compressed knowledge. Those weights may be frozen or trainable; when the Model changes, gradient updates flow into it and weights shift.</p>
<p><strong>Harness</strong> denotes everything surrounding the Model at inference time without requiring weight updates: prompts, system instructions, routing logic, memory stores, tool dispatchers, workflow scaffolds, MCP libraries. The Harness is software, not learned parameters; it can be rewritten between calls with no gradient involved.</p>
<p><img alt="Alita: Generalist Agent Enabling Scalable Agentic Reasoning with Minimal Predefinition and Maximal Self-Evolution" src="/images/359239/figure-1.jpg" loading="lazy" width="1200" height="409" />
<em>Alita workflow</em></p>
<p><strong>Artifact</strong> denotes any persistent output the Agent produces as the residue of task execution: code files, algorithm implementations, research manuscripts, experience templates, MCP definitions. Artifacts live outside the agent loop and can be stored, versioned, evaluated, and fed back in.</p>
<p>The key architectural claim is: <strong>Agent = Model + Harness</strong>. Observable behavior is a joint function of what the Model knows and how the Harness directs it. Neither layer alone constitutes the agent, and conflating the two is a primary source of terminology confusion in this literature.</p>
<p>Artifacts are the connective tissue of all self-evolution. A code solution scored by an evaluator feeds the Artifact-layer loop. A trajectory trace reflected upon to update a prompt feeds the Harness-layer loop. A set of self-proposed tasks with verified solutions feeds the Model-layer loop.</p>
<table>
<thead>
<tr>
<th>Category</th>
<th>What changes</th>
<th>What stays fixed</th>
<th>Feedback closes at</th>
</tr>
</thead>
<tbody>
<tr>
<td>Artifact-Layer Evolution</td>
<td>The Artifact population</td>
<td>Model weights, Harness config</td>
<td>Artifact store</td>
</tr>
<tr>
<td>Harness-Layer Evolution</td>
<td>Prompts, routing, memory, tools</td>
<td>Model weights</td>
<td>Harness components</td>
</tr>
<tr>
<td>Model-Layer Evolution</td>
<td>Parametric weights</td>
<td>Harness config, external data</td>
<td>Training loop (internal)</td>
</tr>
</tbody>
</table>
<p><img alt="GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning" src="/images/359239/figure-2.jpg" loading="lazy" width="1200" height="929" />
<em>GEPA results</em></p>
<p>Three papers concisely illustrate the distinctions. Alita generates MCP tools on demand and accumulates them in the Harness inventory—Harness-layer evolution. GEPA reflects on trajectories and rewrites system prompts—Harness-layer evolution by a different mechanism. AZR proposes code-reasoning tasks, solves them, and updates weights via verifiable execution rewards—Model-layer evolution. All three call their systems "self-evolving"; the taxonomy makes clear they operate on three different layers.</p>
<hr />
<h2 id="artifact-layer-evolution">Artifact-Layer Evolution: Iterative Refinement of What the Agent Produces</h2>
<p>In Artifact-layer evolution, neither Model weights nor Harness configuration are permanently altered. What evolves is the population of Artifacts—code files, algorithms, research manuscripts—through iterative generation, evaluation, and selection. The Model and Harness serve as fixed generators; an automated evaluator provides scores; highest-scoring Artifacts seed the next generation. The loop closes at the Artifact store.</p>
<h3 id="alphaevolve">AlphaEvolve <a class="sky-paper-source" href="https://arxiv.org/abs/2506.13131" aria-label="Read the AlphaEvolve paper on arXiv">Original paper ↗</a></h3>
<p><img alt="AlphaEvolve: A coding agent for scientific and algorithmic discovery" src="/images/359239/figure-3.jpg" loading="lazy" width="1200" height="498" />
<em>AlphaEvolve results</em></p>
<p>AlphaEvolve was developed by Alexander Novikov, Matej Balog and colleagues, with participating institutions including Google DeepMind, Google. AlphaEvolve, from Google DeepMind, is the cleanest instantiation of this category. The system orchestrates a pipeline of LLMs—Gemini Flash for rapid generation, Gemini Pro for higher-quality proposals—to evolve entire code files. Each candidate is scored by automated evaluators (correctness verifiers, benchmark metrics, resource monitors), and a program database maintains a diverse evolutionary population, sampling from past candidates weighted by recency and quality to prevent premature convergence.</p>
<p>AlphaEvolve discovered the first improvement over Strassen's algorithm for multiplying two 4×4 complex-valued matrices in 56 years, reducing required scalar multiplications from 49 to 48. It also optimized data-center scheduling heuristics at Google and accelerated training of the LLM that powers AlphaEvolve itself. Automated executable evaluation is a structural prerequisite: without reliable selection pressure, the evolutionary population degenerates. The program database's diversity management—retaining candidates across performance levels rather than only the global best—enables discovery of structurally novel algorithms.</p>
<h3 id="fars">FARS <a class="sky-paper-source" href="https://arxiv.org/abs/2606.31651" aria-label="Read the FARS paper on arXiv">Original paper ↗</a></h3>
<p><img alt="FARS: A Fully Automated Research System Deployed at Scale" src="/images/359239/figure-4.jpg" loading="lazy" width="1200" height="669" />
<em>FARS architecture</em></p>
<p>FARS (Fully Automated Research System) extends Artifact-layer evolution to the full scientific research pipeline. Stage-specific agents handle Ideation, Planning, Experimentation, and Writing, coordinated through a shared workspace that functions as both project memory and auditable artifact store. In its first public deployment, FARS produced 166 complete papers spanning 67 AI/ML topics. Volunteer reviewers provided 282 structured reviews covering 140 of the 166 papers, including overall ratings, sub-scores for soundness and contribution, integrity checks, and disclosure of LLM-assisted review. Recurring weaknesses include narrow experimental scope, overclaiming, and insufficient experimental validation.</p>
<p>The human review process is an external audit of the Artifact population, not a self-evolution feedback loop—the system does not automatically update from reviewer feedback. FARS demonstrates that Artifact-layer evolution at scale surfaces failure modes that curated demonstrations systematically suppress. AlphaEvolve achieves high-fidelity evolution by restricting scope to problems with executable automated evaluators; FARS achieves broad scope by expanding to full research pipelines, compensating with structured human review. The tension between scope and evaluability is a structural constraint.</p>
<hr />
<h2 id="harness-layer-evolution">Harness-Layer Evolution: Self-Improvement Without Touching Model Weights</h2>
<p>Most self-improving AI agents that are practical to deploy today operate at this layer. Harness-layer evolution requires no gradient computation and no weight update, making it applicable to any Model including black-box APIs. What evolves is the Harness configuration: prompt text, routing assignments, memory structures, and tool inventories. Feedback comes from task outcomes consumed by a meta-level optimizer operating entirely on Harness components. The loop closes inside the Harness. Five papers instantiate this category through distinct mechanisms.</p>
<h3 id="gepa">GEPA <a class="sky-paper-source" href="https://arxiv.org/abs/2507.19457" aria-label="Read the GEPA paper on arXiv">Original paper ↗</a></h3>
<p>GEPA was developed by Lakshya A Agrawal, Omar Khattab and colleagues, with participating institutions including Stanford University, MIT. GEPA (Genetic-Pareto) argues directly against gradient-based RL as the right tool for adapting LLM agents. A trajectory contains nothing but language—instructions, reasoning chains, tool calls, compiler messages, reward signals—which is precisely what LLMs are best at understanding. Rather than compress that richness into a scalar reward and run policy gradient ascent, GEPA reflects on trajectories in natural language to diagnose problems and propose prompt mutations, then maintains a Pareto frontier of top-performing prompts to avoid greedy convergence.</p>
<p>On HotpotQA, HoVer, IFBench, and PUPA, GEPA outperforms GRPO (with 24,000 rollouts and LoRA fine-tuning) by an average of 10% and up to 20%, while requiring up to 35× fewer rollouts. It also outperforms MIPROv2 by over 10% across two LLMs. GEPA never updates Model weights. The information-efficiency asymmetry is the key insight: prompt optimization operates in language space, where each rollout carries a full natural-language explanation of what went wrong, whereas RL operates in weight space via scalar rewards.</p>
<h3 id="eevee">EEVEE <a class="sky-paper-source" href="https://arxiv.org/abs/2606.11182" aria-label="Read the EEVEE paper on arXiv">Original paper ↗</a></h3>
<p><img alt="EEVEE: Towards Test-time Prompt Learning in the Real World for Self-Improving Agents" src="/images/359239/figure-5.jpg" loading="lazy" width="1200" height="453" />
<em>EEVEE architecture</em></p>
<p>GEPA assumes a single-benchmark setting. Real-world deployment breaks this: queries arrive from heterogeneous domains, and optimizing a prompt for one domain degrades performance on another. EEVEE extends test-time prompt learning to heterogeneous multi-dataset streams by adding a router that partitions incoming inputs into task clusters and assigns each cluster a suitable prompt configuration. The router and prompt learner are mutually dependent; EEVEE resolves this coupling through interleaved router and prompt learning phases.</p>
<p>EEVEE improves average multi-benchmark scores by 10.38 points over Qwen3-4B-Instruct and 24.32 points over DeepSeek-V3.2, surpassing GEPA and ACE by up to 37.2% and 48.2% respectively. In the incremental setting—benchmarks introduced one at a time—EEVEE ends at a cumulative +41.53 retention gain while GEPA and ACE end at −15.36 and −18.58. The negative numbers reveal the cross-dataset interference problem: optimizing for a new task destroys the Harness configuration that worked for prior tasks.</p>
<h3 id="ui-mem">UI-Mem <a class="sky-paper-source" href="https://arxiv.org/abs/2602.05832" aria-label="Read the UI-Mem paper on arXiv">Original paper ↗</a></h3>
<p><img alt="UI-Mem: Self-Evolving Experience Memory for Online Reinforcement Learning in Mobile GUI Agents" src="/images/359239/figure-6.jpg" loading="lazy" width="1200" height="596" />
<em>UI-Mem workflow</em></p>
<p>UI-Mem addresses how a mobile GUI agent should accumulate experience across multiple tasks and applications where online RL must contend with sparse rewards and long-horizon credit assignment. The solution is a hierarchical experience memory with three levels: high-level workflows for planning, subtask skills for execution, and failure patterns to prevent repetitive errors. Experiences are stored as parameterized templates that abstract away task-specific details, enabling reuse across applications sharing structural similarities.</p>
<p>UI-Mem's Stratified Group Sampling injects varying levels of memory guidance across trajectories within each rollout group. Without unguided trajectories the agent would follow memory rather than internalize it; the mix drives the unguided policy toward reproducing guided behaviors—imitation-through-contrast that makes the RL signal more informative. Model weights are updated via online RL (GRPO), but the memory component evolves independently of and in addition to the weight updates; the memory itself is a Harness-layer artifact.</p>
<h3 id="alita">Alita <a class="sky-paper-source" href="https://arxiv.org/abs/2505.20286" aria-label="Read the Alita paper on arXiv">Original paper ↗</a></h3>
<p>Alita was developed by Jiahao Qiu, Mengdi Wang and colleagues, with participating institutions including Princeton University, Tsinghua University. Alita generates new Harness components on demand rather than optimizing existing ones. When Alita encounters a task requiring a capability it lacks, it generates an MCP implementing that capability, tests it, refines it, and adds it to its reusable library. The design philosophy is minimalist: Alita ships with only a single core capability (a web agent) and a small set of general-purpose modules; everything else is generated and accumulated on demand.</p>
<p>On the GAIA benchmark validation set, Alita achieves 75.15% pass@1 and 87.27% pass@3, outperforming OpenAI Deep Research (67.36% pass@1). A system with fewer prebuilt components outperforms systems with more, because dynamic generation constructs precisely the right tool for each task. MCPs are generated as Artifacts—persistent, versioned outputs of task execution—but stored as Harness components that alter future agent behavior without any Model weight update.</p>
<h3 id="boundaryrouter">BoundaryRouter <a class="sky-paper-source" href="https://arxiv.org/abs/2605.07180" aria-label="Read the BoundaryRouter paper on arXiv">Original paper ↗</a></h3>
<p>Learning Agent Routing From Early Experience<sup>[1]</sup> was developed by Yimin Wang, Mengdi Wang and colleagues, with participating institutions including Princeton University, Tsinghua University. BoundaryRouter addresses a routing problem: should the system route a query to lightweight direct LLM inference or escalate to full agent execution? The cold-start constraint is central—in real deployment there is no labeled training set of queries with known correct routing decisions. BoundaryRouter builds an early experience memory from a small seed set of queries executed by both the LLM and the full agent. Comparing their outputs creates a behavioral reference capturing systematic differences between the two systems. At inference time, BoundaryRouter retrieves similar past experiences and uses rubric-guided reasoning to make routing decisions.</p>
<p>BoundaryRouter reduces average inference time by 60.6% compared to always using the agent, while improving performance by 28.6% over always using direct LLM inference. The rubric-guided reasoning encodes structural knowledge about task difficulty rather than surface-level similarity matching, enabling generalization to out-of-domain scenarios in the RouteBench evaluation.</p>
<hr />
<h2 id="model-layer-evolution">Model-Layer Evolution: Learning Without Ground-Truth Answer Labels</h2>
<p><img alt="Absolute Zero: Reinforced Self-play Reasoning with Zero Data" src="/images/359239/figure-7.jpg" loading="lazy" width="1200" height="929" />
<em>Absolute Zero results</em></p>
<p>Model-layer evolution is the most fundamental form: weights change through signal generated by the agent itself, with no external dataset of (question, answer) pairs. The defining constraint is <strong>verifiability</strong>—there must be a reliable automated mechanism to determine whether a proposed solution is correct, because the loop must close thousands of times during training with no human in the critical path. This restricts the category to domains where correctness has an executable definition: code that runs or doesn't, proofs that check out or don't.</p>
<h3 id="absolute-zero-reasoner">Absolute Zero Reasoner (AZR) <a class="sky-paper-source" href="https://arxiv.org/abs/2505.03335" aria-label="Read the Absolute Zero Reasoner paper on arXiv">Original paper ↗</a></h3>
<p>AZR is the paradigmatic instance. A single language model both proposes coding and reasoning tasks and solves them, using a code executor as the sole source of verifiable reward, with no external data whatsoever.</p>
<p>The technical mechanism separates proposer and solver roles within the same model. In the proposer role, the model generates tasks parameterized by three types: deduction (predict output from code and input), abduction (infer input from code and output), and induction (infer code from input-output pairs). In the solver role, the model receives a proposed task, generates a solution, and receives a binary reward based on execution verification. Policy gradient (RLVR) updates the weights, and the updated model then proposes harder tasks—a curriculum co-evolving with capability. AZR achieves state-of-the-art performance on coding and mathematical reasoning benchmarks, outperforming models trained on tens of thousands of in-domain human-curated examples.</p>
<p>The separation of proposer and solver roles within a single model prevents reward collapse. Tasks the model already solves trivially produce no gradient signal, pushing the proposer toward tasks at the boundary of current capability. The three task types provide structural diversity preventing collapse to a narrow class of easily-generated tasks.</p>
<p>The scope limitation is equally important: AZR is bounded by the verifiable domain. Open-ended dialogue, subjective judgment, and aesthetic evaluation cannot be automatically verified. This is an honest boundary condition on the entire Model-layer self-evolution paradigm as it currently exists.</p>
<hr />
<h2 id="representative-systems">Representative Systems: ReasoningBank, MemGen, and AgentEvolver</h2>
<p>The eight-paper cut above is organized by layer. Three later systems extend the taxonomy with memory, latent recall, and an end-to-end training stack. They do not replace AlphaEvolve, GEPA, or AZR.</p>
<h3 id="reasoningbank">ReasoningBank <a class="sky-paper-source" href="https://arxiv.org/abs/2509.25140" aria-label="Read the ReasoningBank paper on arXiv">Original paper ↗</a></h3>
<p>ReasoningBank, from Ouyang, Yan, Hsu and colleagues at UIUC, Google Cloud AI Research, and Yale, distills generalizable reasoning strategies from an agent's self-judged successes <em>and</em> failures. At test time the agent retrieves relevant memories, acts, then writes new learnings back. Memory-aware test-time scaling (MaTTS) spends extra compute on each task to produce diverse traces, which in turn yield higher-quality memory. On web browsing and software engineering benchmarks the authors report better success and fewer steps than memory that stores raw trajectories or only successful routines. Code: <a href="https://github.com/google-research/reasoning-bank">google-research/reasoning-bank</a>.</p>
<p>In this taxonomy ReasoningBank is harness-layer memory evolution. Weights stay frozen; what persists is a structured strategy bank, not a transcript dump.</p>
<h3 id="memgen">MemGen <a class="sky-paper-source" href="https://arxiv.org/abs/2509.24704" aria-label="Read the MemGen paper on arXiv">Original paper ↗</a></h3>
<p>MemGen, from Zhang, Fu, and Yan at the National University of Singapore, argues that neither full weight updates nor an external retrieval database captures how memory and reasoning interleave. A <em>memory trigger</em> decides when to invoke memory; a <em>memory weaver</em> turns the current state into a latent token sequence that is woven into ongoing reasoning. The backbone is not fully fine-tuned; the trigger and weaver are trained modules, typically as LoRA adapters, so some parameters do move. Across eight benchmarks the authors report gains of up to 38.22% over external memory systems such as ExpeL and AWM, and up to 13.44% over GRPO, with unplanned emergence of planning, procedural, and working-memory behaviors.</p>
<p>MemGen is hybrid. The write lands in trained memory modules rather than a document store or a full backbone update, which is why it appears in both the memory and model-weights rows.</p>
<h3 id="agentevolver">AgentEvolver <a class="sky-paper-source" href="https://arxiv.org/abs/2511.10395" aria-label="Read the AgentEvolver paper on arXiv">Original paper ↗</a></h3>
<p>AgentEvolver, from Zhai, Tao, Chen and colleagues, is a self-evolving agent system aimed at the cost of RL for tool-using agents. It combines three mechanisms: <em>self-questioning</em> (curiosity-driven task generation, so novel environments do not require a hand-built dataset), <em>self-navigating</em> (experience reuse and hybrid policy guidance), and <em>self-attributing</em> (credit that distinguishes which states and actions actually contributed). The authors report more efficient exploration and better sample use than standard RL baselines. Code: <a href="https://github.com/modelscope/AgentEvolver">modelscope/AgentEvolver</a>.</p>
<p>AgentEvolver is the closest of the three to a full training stack: it evolves the task distribution, the exploration policy, and the learned policy together. That is why it appears under environment, policy, and model weights in the taxonomy table.</p>
<h2 id="how-to-build">How to Build a Self-Evolving Agent Framework</h2>
<p>A self-evolving agent framework is not "add memory." It is a write path with an evaluation gate. The papers above disagree on <em>where</em> the write lands; they converge on five engineering pieces.</p>
<pre><code>collect trace
  -&gt; evaluate against a frozen holdout
  -&gt; propose one update to a named layer
  -&gt; regression-test the candidate
  -&gt; promote a versioned snapshot
  -&gt; monitor live metrics
  -&gt; roll back if retention or safety drops</code></pre>
<p>Keep a versioned record for every promoted change, for example:</p>
<pre><code>UpdateRecord
  id: mem-0142
  layer: memory | tools | policy | workflow | weights | environment
  parent: mem-0141
  evidence: eval-suite-v3 score, trace ids
  gate: pass | reject
  rollback_to: mem-0141</code></pre>
<h3 id="feedback-collection">1. Feedback collection</h3>
<p>Log the trajectory, the outcome, and the evaluator that scored it. Prefer executable checks (unit tests, sandbox traces, structured graders) over a single LLM-as-judge scalar. GEPA shows that natural-language reflection is useful <em>in addition to</em> a score, not instead of one. If you cannot say what counted as success, you cannot say the agent evolved.</p>
<h3 id="memory-update-loop">2. Memory and update loop</h3>
<p>Decide the write target before you store anything: strategy memory (ReasoningBank), tool inventory (Alita), prompt population (GEPA), or weights (AZR, AgentEvolver). Retrieve before acting, write after judging, and keep failed traces—success-only memory repeats the same blind spots. Version every write. A memory store with no schema is a log, not a loop.</p>
<h3 id="evaluation-harness">3. Evaluation harness</h3>
<p>Hold out tasks the updater cannot see. Measure retention across domains, not only the latest benchmark; EEVEE exists because prompt evolution on one stream destroys another. Separate <em>automation</em> (the agent finished) from <em>durable improvement</em> (the next run starts better). If the only eval is the training distribution, you are overfitting a loop.</p>
<h3 id="safety-gates">4. Safety gates</h3>
<p>Do not let the agent promote a change that failed evaluation, changed permissions, or cannot be explained. Put a gate in front of tool installation, prompt replacement, and any weight update. Self-play and self-questioning can invent tasks that are easy to reward-hack; treat proposer output as untrusted data.</p>
<h3 id="rollback-versioning">5. Rollback and versioning</h3>
<p>Every promoted prompt, memory item, tool, and checkpoint needs an ID and a rollback command. Artifact-layer systems already do this with program databases; harness-layer systems often skip it and then cannot undo a bad prompt. Without rollback, a bad write is hard to undo; treat versioning as part of the loop, not an afterthought.</p>
<p>A minimal production skeleton: collect traces → judge with a frozen eval set → write to one named layer → promote only behind a gate → keep the previous version. That is the implementation counterpart of the taxonomy.</p>
<h2 id="open-problems">Boundaries, Open Problems, and Real-World Deployment Constraints</h2>
<p><strong>Verifiability is the master constraint.</strong> Both Artifact-layer and Model-layer evolution require automated correctness signals: AlphaEvolve's code executor, AZR's verification environment. When such signals are unavailable, neither category can function without human evaluation in the loop. FARS demonstrates what happens at the boundary: automated metrics for research quality are insufficient, so evaluation relies on 282 volunteer reviews—an honest acknowledgment that automated verifiability for open-ended scientific writing does not yet exist at acceptable quality. Harness-layer evolution remains the most broadly applicable category for domains where verification is soft or subjective.</p>
<p><img alt="Learning Agent Routing From Early Experience" src="/images/359239/figure-8.jpg" loading="lazy" width="1200" height="581" />
<em>Learning Agent Routing workflow</em></p>
<p><strong>Cold-start scarcity affects all categories differently.</strong> BoundaryRouter confronts routing cold-start—no prior routing labels exist for new deployments—and builds a behavioral reference from a seed set. EEVEE confronts prompt cold-start under domain shift—as new benchmark domains enter the stream, existing configurations have no experience with them. FARS confronts quality cold-start at scale—in early deployment, there is no evidence about which experimental configurations produce strong papers. Each paper develops a specific mitigation, but none eliminates the cold-start problem; they manage it.</p>
<p><strong>Proxy optimization and faithfulness failures are structurally analogous.</strong> AZR faces reward hacking risk: a sufficiently powerful proposer could generate tasks that are technically executable-verifiable but solved by surface pattern matching rather than actual reasoning. FARS faces faithfulness failures: the writing agent occasionally overclaims or inadequately represents experimental evidence, optimizing for plausible-sounding language rather than accurate scientific description. Both represent the same structural issue—optimizing a measurable proxy at the expense of the intended objective.</p>
<p><strong>The Model ceiling limits Harness evolution.</strong> Most Harness-layer approaches in this survey operate on a frozen Model with a capability ceiling: there are tasks it cannot solve regardless of prompt quality or memory richness. UI-Mem is the hybrid exception, because it also updates weights. Once Harness optimization saturates, further gains require Model-layer updates. This motivates co-evolution architectures in which Harness improvements generate training data for Model updates, which in turn enable further Harness optimization. No paper in this survey implements full three-layer co-evolution, but the taxonomy points toward it as the natural next step.</p>
<p><strong>Evaluation methodology is itself an open problem.</strong> A central difficulty for self evolution in AI agents is showing that a reported gain is durable improvement rather than automation, one-off adaptation, or benchmark overfitting. FARS's structured volunteer reviews, AlphaEvolve's formal correctness proofs, and AZR's out-of-distribution benchmark transfer are not interchangeable. Formal proofs are available only for well-specified mathematical problems. Volunteer reviews require significant human effort and carry inter-reviewer variance. Benchmark transfer measures a specific proxy for generalization but says nothing about real-world utility. FARS's decision to publish all 166 papers with all 282 reviews—including failures—is a methodological commitment that the field would benefit from adopting more broadly.</p>
<p><strong>Multi-domain heterogeneity requires explicit architectural accommodation.</strong> EEVEE prevents prompt specialization for one domain from destroying performance on others; BoundaryRouter prevents routing experience from failing to transfer to out-of-domain queries. In both cases the solution involves explicit structure in the Harness—a router partitioning the input space, rubric-guided reasoning encoding structural knowledge—rather than hoping a single configuration generalizes.</p>
<hr />
<h2 id="conclusion">Conclusion</h2>
<p>What evolves, where feedback comes from, and where the loop closes each have a clean answer per category.</p>
<p>In Artifact-layer evolution (AlphaEvolve, FARS), the Artifact population evolves while the agent stays fixed. Feedback comes from automated evaluators—code executors, benchmark scores—or structured human review when automation is insufficient. The loop closes at the Artifact store: surviving Artifacts seed the next generation, and neither Model weights nor Harness configuration are modified. The power of this category—genuine discovery at scale—is inseparable from its prerequisite: reliable evaluation.</p>
<p>In Harness-layer evolution (GEPA, EEVEE, Alita, BoundaryRouter), the Harness configuration evolves while Model weights remain frozen. Feedback comes from task outcomes consumed by meta-level optimizers operating in language space (GEPA, EEVEE), converted into reusable tools (Alita), or encoded as behavioral reference (BoundaryRouter). The loop closes inside the Harness: updated prompts, memory entries, routing policies, and tool libraries alter future behavior without any gradient flowing into the Model. This is the most broadly applicable category because it requires no weight access. UI-Mem is hybrid: its memory store is a harness artifact, but online RL also moves weights.</p>
<p>In Model-layer evolution (AZR), parametric weights evolve through a fully internal self-play circuit. Feedback comes exclusively from verifiable execution outcomes—compiler results, test-case pass rates—that substitute for human annotation. The loop closes inside the training process: the Model proposes tasks, solves them, receives execution-verified rewards, updates its own weights, and proposes harder tasks aligned with its new capability level. The result matches curated supervised training in well-verifiable domains with zero external data, bounded precisely by what can be automatically verified.</p>
<h2 id="awesome-self-evolving-agents">Awesome Self-Evolving Agents: Papers, Repos, and Tools</h2>
<p>A short reading and tooling list, not a second bibliography. Use it when you want the survey papers, the named systems, or a repo to clone.</p>
<h3 id="surveys-and-taxonomies">Surveys and taxonomies</h3>
<ul>
<li><a href="https://arxiv.org/abs/2507.21046">A Survey of Self-Evolving Agents</a> (Gao et al., arXiv:2507.21046) — what / when / how / where to evolve. Companion list: <a href="https://github.com/CharlesQ9/Self-Evolving-Agents">CharlesQ9/Self-Evolving-Agents</a>.</li>
<li><a href="https://arxiv.org/abs/2508.07407">A Comprehensive Survey of Self-Evolving AI Agents</a> (Fang et al., arXiv:2508.07407) — lifelong agentic systems and the input–agent–environment–optimiser loop. Companion list: <a href="https://github.com/EvoAgentX/Awesome-Self-Evolving-Agents">EvoAgentX/Awesome-Self-Evolving-Agents</a>.</li>
<li><a href="https://lsl.zone/blog/2026/a-taxonomy-of-self-evolving-agents/">A Taxonomy of Self-evolving Agents</a> — a short public taxonomy organized by what the agent changes.</li>
</ul>
<h3 id="named-systems">Named systems</h3>
<ul>
<li>ReasoningBank — <a href="https://arxiv.org/abs/2509.25140">paper</a>, <a href="https://github.com/google-research/reasoning-bank">code</a></li>
<li>MemGen — <a href="https://arxiv.org/abs/2509.24704">paper</a>, <a href="https://github.com/bingreeky/MemGen">code</a></li>
<li>AgentEvolver — <a href="https://arxiv.org/abs/2511.10395">paper</a>, <a href="https://github.com/modelscope/AgentEvolver">code</a></li>
<li>The eight systems in the table above — AlphaEvolve, FARS, GEPA, EEVEE, UI-Mem, Alita, BoundaryRouter, Absolute Zero</li>
</ul>
<h3 id="implementation-guides">Implementation guides</h3>
<ul>
<li><a href="https://developers.openai.com/cookbook/examples/partners/self_evolving_agents/autonomous_agent_retraining">OpenAI Cookbook: Autonomous Agent Retraining</a> — evals, a retraining loop, and LLM-as-a-judge in an executable notebook.</li>
<li>This page's <a href="#how-to-build">build checklist</a> — feedback, memory writes, eval harness, safety gates, rollback.</li>
</ul>
<h2 id="data-and-citation">Data and Citation</h2>
<p>The comparison table above and the full reference list are available as downloadable files for reuse in your own reading notes, slides, or literature reviews.</p>
<ul class="sky-resource-links">
<li><a href="/assets/data/self-evolving-agents-survey.csv" download>Comparison table (CSV, 8 papers)</a></li>
<li><a href="/assets/bibliography/self-evolving-agents-survey.bib" download>All references (BibTeX, 13 entries)</a></li>
</ul>
<p><strong>Suggested citation</strong></p>
<blockquote class="sky-citation">
<p>AgentsPulse Editorial Team. "Self-Evolving Agents: Survey, Taxonomy, and How Self-Improving AI Agents Work." <em>AgentsPulse</em>, September 3, 2026. https://agentspulse.github.io/tutorials/self-evolving-agents-review-en/</p>
</blockquote>
<p><strong>BibTeX for this survey</strong></p>
{% raw %}<pre><code>@misc{agentspulse2026selfevolving,
  title        = {Self-Evolving Agents: Survey, Taxonomy, and How Self-Improving AI Agents Work},
  author       = {{AgentsPulse Editorial Team}},
  year         = {2026},
  howpublished = {AgentsPulse},
  note         = {Survey, taxonomy, and implementation guide for self-evolving agents},
  url          = {https://agentspulse.github.io/tutorials/self-evolving-agents-review-en/}
}</code></pre>{% endraw %}
<h2 id="references">Original Papers</h2>
<ol class="sky-paper-references">
<li>Learning Agent Routing From Early Experience. arXiv:2605.07180. 2026. <a href="https://arxiv.org/abs/2605.07180">View on arXiv</a>.</li>
<li>FARS: A Fully Automated Research System Deployed at Scale. arXiv:2606.31651v1. 2026. <a href="https://arxiv.org/abs/2606.31651">View on arXiv</a>.</li>
<li>EEVEE: Towards Test-time Prompt Learning in the Real World for Self-Improving Agents. arXiv:2606.11182v1. 2026. <a href="https://arxiv.org/abs/2606.11182">View on arXiv</a>.</li>
<li>UI-Mem: Self-Evolving Experience Memory for Online Reinforcement Learning in Mobile GUI Agents. arXiv:2602.05832v1. 2026. <a href="https://arxiv.org/abs/2602.05832">View on arXiv</a>.</li>
<li>GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning. arXiv:2507.19457v1. 2025. <a href="https://arxiv.org/abs/2507.19457">View on arXiv</a>.</li>
<li>AlphaEvolve: A coding agent for scientific and algorithmic discovery. arXiv:2506.13131v1. 2025. <a href="https://arxiv.org/abs/2506.13131">View on arXiv</a>.</li>
<li>Alita: Generalist Agent Enabling Scalable Agentic Reasoning with Minimal Predefinition and Maximal Self-Evolution. arXiv:2505.20286v1. 2025. <a href="https://arxiv.org/abs/2505.20286">View on arXiv</a>.</li>
<li>Absolute Zero: Reinforced Self-play Reasoning with Zero Data. arXiv:2505.03335v2. 2025. <a href="https://arxiv.org/abs/2505.03335">View on arXiv</a>.</li>
<li>A Survey of Self-Evolving Agents: What, When, How, and Where to Evolve on the Path to Artificial Super Intelligence. arXiv:2507.21046. 2025. <a href="https://arxiv.org/abs/2507.21046">View on arXiv</a>.</li>
<li>A Comprehensive Survey of Self-Evolving AI Agents: A New Paradigm Bridging Foundation Models and Lifelong Agentic Systems. arXiv:2508.07407. 2025. <a href="https://arxiv.org/abs/2508.07407">View on arXiv</a>.</li>
<li>ReasoningBank: Scaling Agent Self-Evolving with Reasoning Memory. arXiv:2509.25140. 2025. <a href="https://arxiv.org/abs/2509.25140">View on arXiv</a>.</li>
<li>MemGen: Weaving Generative Latent Memory for Self-Evolving Agents. arXiv:2509.24704. 2025. <a href="https://arxiv.org/abs/2509.24704">View on arXiv</a>.</li>
<li>AgentEvolver: Towards Efficient Self-Evolving Agent System. arXiv:2511.10395. 2025. <a href="https://arxiv.org/abs/2511.10395">View on arXiv</a>.</li>
</ol>
