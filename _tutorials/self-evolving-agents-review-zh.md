---
layout: article-sky
title: "Self-evolving Agents综述：8篇论文讲透Artifact 层演化、Harness 层演化与Model 层演化"
description: "系统梳理8篇Self-evolving Agents论文，从Artifact、Harness与Model三层理解智能体如何通过产出迭代、运行时自改与参数更新实现自我演化。"
tags: [agents, self-evolution, surveys]
categories: [frontier-research]
source_url: http://61.149.12.104:1684/api/v1/interpretations/359238/publish-preview?platform=universal
---

<hr />
<h2>引言</h2>
<p>"自我改进"这个词在 AI 领域已经被用滥了。有人用它描述提示词优化，有人用它指代持续微调，有人用它形容系统在运行中积累经验。这些说法并非错误，但混在一起使用时，会让读者完全失去方向感——究竟什么在改变？改变能持续多久？下次执行时还在吗？</p>
<p>这篇文章挑了过去一年多里8篇有代表性的工作，覆盖三条路线：改产物、改运行框架，以及改模型本身。具体场景从移动端GUI一直延伸到数学算法发现，也包括提示词优化和零数据强化学习。主题看起来很散，但都指向同一个问题：Agent究竟能改动自己的哪一部分？</p>
<p>这个框架只需要一个主轴：<strong>系统的哪一层发生了改变？</strong></p>
<hr />
<h2>核心概念与分类框架：Model、Harness、Artifact 三层定义</h2>
<p><img alt="Learning Agent Routing From Early Experience" src="/images/359238/figure-1.jpg" />
<em>图：Learning Agent Routing From Early Experience 的代表性流程图</em></p>
<p>先把术语说清楚，后面的讨论才不会跑偏。</p>
<p><strong>Model</strong> 是承载参数化知识的语言模型本体。它的"知识"以权重的形式固化，一次推理结束后不会自动改变。你可以把它想成一块写满了知识的黑板——运行时只能读，不能擦写（除非专门走训练流程）。</p>
<p><strong>Harness</strong> 是围绕 Model 构建的运行时结构，包括系统提示词、任务路由逻辑、记忆模块、工具调用协议、上下文管理策略等一切"让模型行为可配置"的组件。Harness 不修改模型权重，但它决定了模型在特定任务上的实际表现。一个同样的基础模型，套上不同的 Harness，表现可以天壤之别。</p>
<p>用一句话概括：<strong>Agent = Model + Harness</strong>。</p>
<p><strong>Artifact</strong> 是 Agent 执行任务后产出的外部可检验对象，包括代码、算法实现、研究论文、经验模板、工具协议等。Artifact 存在于 Agent 之外，可以被独立评估、复用或否定。它不是 Agent 的内部状态，而是 Agent 与外部世界交互的"留痕"。</p>
<p>有了这三个定义，"自我演化"的分类就变得直接：</p>
<table>
<thead>
<tr>
<th>演化层</th>
<th>什么在改变</th>
<th>是否跨会话持久</th>
<th>典型代表</th>
</tr>
</thead>
<tbody>
<tr>
<td>Artifact 层</td>
<td>外部产出物被迭代筛选和优化</td>
<td>是（外部存储）</td>
<td>AlphaEvolve、FARS</td>
</tr>
<tr>
<td>Harness 层</td>
<td>提示词、路由、记忆等运行时组件被修改</td>
<td>可选（依赖持久化设计）</td>
<td>GEPA、EEVEE、UI-Mem、Alita、BoundaryRouter</td>
</tr>
<tr>
<td>Model 层</td>
<td>模型权重通过训练被更新</td>
<td>是（写入参数）</td>
<td>Absolute Zero</td>
</tr>
</tbody>
</table>
<p>这个分类轴不是唯一可能的分类方式，但它有一个关键优势：它直接回答了"下次启动时系统还记得什么"这个最实际的工程问题。</p>
<p>Alita由Jiahao Qiu、Mengdi Wang等人完成，团队来自普林斯顿大学、清华大学等机构。Alita 是理解三层关系的好入口。它的设计原则是"最小预定义、最大自演化"：Agent 启动时只携带一个核心能力（Web Agent），在任务执行过程中动态生成 MCP（Model Context Protocol）工具协议。这些 MCP 协议是 Harness 层的产物，但一旦被验证有效，就可以被固化为可复用的 Artifact，供后续任务调用。这个流动的过程——Harness 动态生成，产出物固化为 Artifact——正好展示了三层之间的边界是流动的，而非僵硬的隔墙。</p>
<p>GEPA由Lakshya A Agrawal、Omar Khattab等人完成，团队来自斯坦福大学、麻省理工学院等机构。GEPA 和 AlphaEvolve 则提供了最干净的对照：GEPA 修改的是系统提示词（Harness），AlphaEvolve 迭代的是代码文件（Artifact）。两者都使用某种进化机制，但演化发生的位置完全不同——这正是为什么我们需要先把三层定义清楚，再去讨论具体系统。</p>
<hr />
<h2>Artifact 层演化：外部产出物的迭代优化</h2>
<p>最容易理解的演化形式：Agent 产出一个东西，评估它，改进它，再产出，再评估。Model 和 Harness 本身相对稳定，变化的是外部产出物。</p>
<p>这种模式的吸引力在于它天然支持并行化——你可以同时跑几十个变体，让评估器选出最好的，完全不需要梯度计算。它的瓶颈也同样明显：你必须有一个可靠的评估器。"可验证性"是 Artifact 层演化的根本前提。</p>
<p><img alt="AlphaEvolve: A coding agent for scientific and algorithmic discovery" src="/images/359238/figure-2.jpg" />
<em>图：AlphaEvolve: A coding agent for scientific and algorithmic discovery 的代表性结果图</em></p>
<p>AlphaEvolve由Alexander Novikov、Matej Balog等人完成，团队来自Google DeepMind、Google等机构。<strong>AlphaEvolve</strong> 是这一类型的极致案例。它来自 Google DeepMind，面向的是数学和算法发现问题。整个代码文件是演化单元，LLM 扮演变异算子的角色：给定当前代码和评估反馈，生成修改版本。评估器可以是数学验证器、性能测试套件或任何能自动打分的工具，支持多目标适应度，用 Pareto 前沿维护候选多样性。</p>
<p>这套机制已经取得了令人印象深刻的结果。AlphaEvolve 找到了 4×4 复数矩阵乘法只需 48 次标量乘法的算法，在 Strassen 算法基础上改进了 56 年来首次突破；优化了 Google 数据中心的调度算法；简化了硬件加速器的电路设计；甚至加速了训练 AlphaEvolve 自身所用的 LLM。这些不是 benchmark 上的数字，而是真实部署系统里的改进。</p>
<p>值得注意的是，AlphaEvolve 的"自我演化"完全发生在代码这个 Artifact 层面。它不更新 LLM 的权重，也不修改调用 LLM 的提示词模板——它只是把 LLM 当成一个很聪明的变异器，用来探索代码空间。这个区分很重要，因为它意味着 AlphaEvolve 的能力上限被锁定在基础 LLM 的理解力上，但它不需要任何训练基础设施，换一个更好的基础模型就能立刻受益。</p>
<p><img alt="FARS: A Fully Automated Research System Deployed at Scale" src="/images/359238/figure-3.jpg" />
<em>图：FARS: A Fully Automated Research System Deployed at Scale 的代表性架构图</em></p>
<p><strong>FARS</strong>（Fully Automated Research System）把 Artifact 从代码扩展到了研究论文。它来自 Analemma，设计目标是在无人工干预的情况下，持续产出涵盖 AI/ML 各子领域的完整研究论文。系统内部分四个阶段运作：Ideation（构想研究方向）、Planning（制定实验方案）、Experiment（执行实验并记录日志）、Writing（撰写论文）。每个阶段有专属 Agent，通过共享工作空间传递中间产物。</p>
<p>FARS 的第一次公开部署产出了 166 篇论文，覆盖 67 个细粒度的 AI/ML 主题。这个规模本身就是一个意义：它不是精选出来的几个成功案例，而是一次完整的大规模部署，包括成功的、勉强可用的、失败的，全部保留下来作为可审计的语料库。</p>
<p>这里需要澄清一个容易误解的点：<strong>FARS 的质量评估依赖人工招募的评审志愿者，不是系统内部已经自动闭合的训练反馈</strong>。282 份结构化评审覆盖了 140 篇论文，评审结果揭示了系统的问题——实验范围过窄、方法论局限、完整性问题——但这些反馈并没有被自动地反写回系统来改进下一批论文的质量。FARS 目前是一个产出规模的系统，而不是一个会从评审中学习的系统。这个区分很诚实，也很重要。</p>
<p>从这两个案例可以看出 Artifact 层演化的共同结构：评估器的质量决定了演化的方向，评估成本决定了演化的速度。AlphaEvolve 的评估可以完全自动化（程序验证），所以它可以跑几千次迭代；FARS 的评估需要真人，所以它目前只能观测而无法自动改进。这不是设计失误，而是 Artifact 层演化对"可验证性"这一根本依赖的直接体现。</p>
<hr />
<h2>Harness 层演化：提示词、路由与记忆的运行时自改</h2>
<p>Harness 层演化是当前工程实践中最活跃的方向，因为它不需要访问模型梯度，可以在推理期或少量交互后完成，部署门槛远低于 Model 层训练。这也是为什么这一类论文数量最多——它对应了最大量的真实需求。</p>
<p>Harness 层演化的核心机制很简单：新的执行轨迹触发某种更新（提示词反思、记忆抽象、路由策略调整），更新后的 Harness 立刻影响下一次执行。闭环在 Harness 内部完成，Model 权重全程不动。</p>
<p><img alt="GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning" src="/images/359238/figure-4.jpg" />
<em>图：GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning 的代表性结果图</em></p>
<p><strong>GEPA</strong>（Genetic-Pareto）是这一类型中最干净、结论最强的工作之一。它的核心观察是：LLM 的执行轨迹可以被序列化成自然语言，而 LLM 本身完全有能力阅读这些轨迹，诊断问题，提出改进方案，并把这些方案写成新的提示词规则——这整个过程比用策略梯度估计参数更新要信息丰富得多。</p>
<p>GEPA 把这个直觉系统化成了一个"遗传-帕累托"优化器。每一轮，它对当前提示词配置采样轨迹，用 LLM 对这些轨迹做自然语言反思，生成候选的提示词更新，然后在 Pareto 前沿上维护多个候选而不是只保留全局最优——这一步是避免贪婪更新陷入局部最优的关键。结果是：在 HotpotQA、HoVer、IFBench、PUPA 四个任务上，GEPA 平均超越 GRPO 基线 10%，在部分任务上超越 20%，而使用的 rollout 数量不到 GRPO 的 1/35。</p>
<p>样本效率的差距非常说明问题。GRPO 在这些任务上需要 24,000 次 rollout，GEPA 用不到 700 次就超过了它。根本原因在于信息密度：一条被语言化的失败轨迹携带了大量结构化信息，而一个标量奖励信号把这些信息几乎全部丢掉了。GEPA 的设计本质上是在利用 LLM 已有的语言推理能力来替代梯度估计，这个思路在 Harness 不可修改权重的约束下是理性的最优选择。</p>
<p><img alt="EEVEE: Towards Test-time Prompt Learning in the Real World for Self-Improving Agents" src="/images/359238/figure-5.jpg" />
<em>图：EEVEE: Towards Test-time Prompt Learning in the Real World for Self-Improving Agents 的代表性架构图</em></p>
<p><strong>EEVEE</strong> 解决了 GEPA 没有处理的一个问题：当任务流来自多个异构数据集时，一套统一的提示词会造成跨任务干扰——为 A 任务优化的提示词更新会破坏 B 任务的性能，反之亦然。这不是 GEPA 的设计缺陷，而是单一提示词在多分布场景下的内在局限。</p>
<p>EEVEE 的解法是引入一个路由器：把输入流分配到不同的任务簇，每个簇对应一套独立的提示词配置。但路由器和提示词是相互依赖的——路由决定了哪些样本用来更新哪套提示词，而提示词的行为又决定了什么样的路由策略最合理。EEVEE 用"路由器-提示词协同进化"策略打破这个死锁：交替训练路由器和提示词，让它们螺旋式共同收敛。</p>
<p>在四个基准测试的增量学习设置下，EEVEE 在所有任务引入后累计保留增益达到 +41.53，而 GEPA 和 ACE 分别是 -15.36 和 -18.58。负数意味着随着任务增加，早期任务的性能在持续下降——这正是跨任务干扰的直接表现。EEVEE 把这个现实问题定义清楚，并在 Harness 内部解决了它。</p>
<p><img alt="UI-Mem: Self-Evolving Experience Memory for Online Reinforcement Learning in Mobile GUI Agents" src="/images/359238/figure-6.jpg" />
<em>图：UI-Mem: Self-Evolving Experience Memory for Online Reinforcement Learning in Mobile GUI Agents 的代表性流程图</em></p>
<p><strong>UI-Mem</strong> 处理的是另一个真实痛点：移动端 GUI Agent 在线强化学习中的经验迁移问题。这类任务的特点是轨迹长、奖励稀疏、跨任务的重复性错误很多——你在 A 应用里学会处理确认弹窗，换一个应用后又得从头学一遍。</p>
<p>UI-Mem 的核心设计是分层经验记忆，分三个层次存储知识：高层工作流（整体任务规划）、子任务技能（可复用的操作序列）、失败模式（已知的错误类型及规避策略）。这些知识以参数化模板的形式存储，比原始轨迹更紧凑，也更容易跨任务迁移。面对新任务时，Agent 检索相关模板，用当前任务的具体参数实例化，得到初始规划，从而避免从零探索。</p>
<p>"自进化循环"是 UI-Mem 的关键机制：每次新的执行轨迹完成后，系统自动分析是否需要更新或补充记忆，把成功的新策略和新的失败模式抽象成模板写回记忆库。这个循环使得记忆库随使用而增长，而不是固定的静态知识库。跨任务和跨应用的泛化能力也随之提升。</p>
<p>Learning Agent Routing From Early Experience<sup>[1]</sup>由Yimin Wang、Mengdi Wang等人完成，团队来自普林斯顿大学、清华大学等机构。<strong>BoundaryRouter</strong> 处理的是一个不同维度的 Harness 问题：不是如何让 Agent 做得更好，而是如何决定一个查询到底需不需要完整 Agent 执行，还是直接用轻量 LLM 推理就够了。</p>
<p>这个路由决策本身也是 Harness 的一部分。BoundaryRouter 的方案是构建一个"早期行为记忆"：在一个共享种子集上同时运行 LLM 和 Agent，记录两者的行为差异，然后在推理时检索相似历史案例来指导路由决策。这个框架不需要训练，也不需要标注数据——它用行为差异作为路由信号，而非监督标签。</p>
<p>实验结果显示，BoundaryRouter 相比直接全走 Agent 减少了 60.6% 的推理时间，相比全走 LLM 提升了 28.6% 的性能。这个权衡在资源受限的实际部署场景中非常有意义：并非每个查询都需要最重的处理路径。</p>
<p><img alt="Alita: Generalist Agent Enabling Scalable Agentic Reasoning with Minimal Predefinition and Maximal Self-Evolution" src="/images/359238/figure-7.jpg" />
<em>图：Alita: Generalist Agent Enabling Scalable Agentic Reasoning with Minimal Predefinition and Maximal Self-Evolution 的代表性流程图</em></p>
<p><strong>Alita</strong> 在 Harness 层演化中代表了一种不同的风格：与其预先设计复杂的工具集，不如让 Agent 在任务执行时自己生成工具。Alita 的 Harness 极度简化——只有一个 Web Agent 作为核心能力，加上一组通用模块。当遇到需要特定工具的任务时，Alita 自主从开源资源中构建对应的 MCP 协议，验证有效后保存，供后续任务复用。</p>
<p>这个设计哲学值得单独拿出来说。传统 Agent 框架的工具集是工程师预先设计的，覆盖有限，且遇到框架外的需求就会失灵。Alita 把工具的创造权交给了 Agent 自身，代价是每次可能需要临时构建工具，收益是理论上覆盖任意需求。在 GAIA 基准上，Alita 以 75.15% pass@1 排名所有通用 Agent 的顶部，超过了工具集更庞大的 OpenAI Deep Research（67.36%）。简洁性不是限制，而是力量。</p>
<hr />
<h2>Model 层演化：无标准答案场景下的参数自更新</h2>
<p>Model 层演化和 Harness 层演化有一个根本区别：改变写入了权重，跨会话持续存在，而且无法在推理时撤销。这意味着 Model 层演化需要更谨慎的设计——错误的更新会永久损害模型能力。</p>
<p>现有 RLVR（Reinforcement Learning with Verifiable Rewards）方法在"零设定"下已经取消了对推理过程的人工标注，但仍然依赖人工整理的问题-答案集合。这个依赖看起来合理，但存在两个长期问题：高质量的人工标注数据是稀缺的，而且如果 AI 能力持续提升，人类提供的任务可能最终会低于模型的学习天花板。</p>
<p><img alt="Absolute Zero: Reinforced Self-play Reasoning with Zero Data" src="/images/359238/figure-8.jpg" />
<em>图：Absolute Zero: Reinforced Self-play Reasoning with Zero Data 的代表性结果图</em></p>
<p><strong>Absolute Zero</strong>（AZR）提出了一个更彻底的方案：<strong>单一模型同时扮演任务提议者（Proposer）和任务求解者（Solver）两个角色，完全不依赖外部数据。</strong></p>
<p>Proposer 负责提出新任务——这个任务不能太简单（没有学习价值），也不能太难（无法验证答案），要处于模型当前能力的"学习边界"上。Solver 尝试解决这些任务。代码执行器作为统一的可验证奖励源，承担两个职责：验证 Proposer 提出的任务是否合法（代码能跑通）；验证 Solver 给出的答案是否正确（执行结果匹配）。这个双重验证机制使得训练循环在完全没有人工监督的条件下自持运行。</p>
<p>实验结果出乎意料地强：在完全不使用外部数据的条件下，AZR 在编码和数学推理任务上超越了依赖数万条人工标注样本的 zero-setting 基线模型。更有意思的是，即使在它从未见过的任务分布上，AZR 也表现出了泛化能力——这表明自提议的课程确实在训练真实的推理能力，而不只是在记忆特定的解题模式。</p>
<p>AZR 与前面所有 Harness 层系统的本质区别在于：它的改进是持久的、参数级的。当一次训练结束后，下一次推理时，模型已经是一个不同的（更强的）模型——不是因为提示词改了，而是因为权重变了。这个特性使得 AZR 的收益可以在不携带任何上下文的情况下复现，但也意味着训练过程需要计算资源和训练基础设施，无法在推理时即兴完成。</p>
<p>AZR 目前的局限性也很明确：自提议机制依赖代码执行器作为验证工具，这把它限制在代码和数学这两个有程序化正确性验证的领域。如何把自提议能力扩展到开放域任务——在那里"正确答案"无法自动验证——是 Model 层自演化面临的最核心挑战。任务多样性的保障（避免 Proposer 总是提出相似的任务）是另一个未完全解决的问题。</p>
<hr />
<h2>结语</h2>
<p>三层框架给了我们一个清晰的提问方式，但现实系统很少只待在一层里。Alita 的 Harness 动态生成工具并固化为 Artifact；UI-Mem 的记忆抽象发生在 Harness 层，但驱动它的 RL 训练是在 Model 层发生的；AlphaEvolve 迭代代码（Artifact），但它所依赖的基础 LLM 如果被替换成更强的版本，Artifact 演化的质量上限就会跳变。层与层之间存在真实的相互作用，分类框架是为了看清楚这些相互作用，而不是假装它们不存在。</p>
<p>真实世界带来的三个问题值得持续追问：</p>
<p><strong>验证从哪里来？</strong> Artifact 层和 Model 层演化都依赖可自动化的验证信号。AlphaEvolve 需要问题具备可计算的评估指标，AZR 需要代码执行器，GEPA 和 UI-Mem 需要任务完成得分。当任务进入开放域——主观写作、科学发现、复杂决策——验证信号的构建难度会急剧上升，这是三层演化共同面对的瓶颈。</p>
<p><strong>改进能保留多久？</strong> Harness 层的改进依赖持久化设计，会话重启后可能归零；Model 层的改进写入权重，天然持久，但也意味着错误的更新更难撤销；Artifact 层的改进以外部文件形式存在，持久性最稳定，但也最容易积累"陈旧知识"。没有哪种持久化方式是免费的午餐。</p>
<p><strong>演化的边界在哪里？</strong> FARS 保留了失败案例和中间产物，体现了 Artifact 层演化在透明性上的独特价值——你可以事后审计系统做了什么。EEVEE 的跨任务干扰实验展示了 Harness 层演化在多任务场景下的系统性风险。AZR 则暗示了 Model 层自演化的一个假设极限：如果模型足够强，它可以自己设计学习课程，但"足够强"本身需要依赖外部验证才能确认。</p>
<p>三层框架不是终点，而是一把能让我们少说废话、多看清楚的工具。</p>
<h2>参考文献</h2>
<p>[1] Learning Agent Routing From Early Experience. arXiv:2605.07180. 2026. <a href="https://arxiv.org/abs/2605.07180">https://arxiv.org/abs/2605.07180</a>.
[2] FARS: A Fully Automated Research System Deployed at Scale. arXiv:2606.31651v1. 2026. <a href="http://arxiv.org/abs/2606.31651v1">http://arxiv.org/abs/2606.31651v1</a>.
[3] EEVEE: Towards Test-time Prompt Learning in the Real World for Self-Improving Agents. arXiv:2606.11182v1. 2026. <a href="http://arxiv.org/abs/2606.11182v1">http://arxiv.org/abs/2606.11182v1</a>.
[4] UI-Mem: Self-Evolving Experience Memory for Online Reinforcement Learning in Mobile GUI Agents. arXiv:2602.05832v1. 2026. <a href="http://arxiv.org/abs/2602.05832v1">http://arxiv.org/abs/2602.05832v1</a>.
[5] GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning. arXiv:2507.19457v1. 2025. <a href="http://arxiv.org/abs/2507.19457v1">http://arxiv.org/abs/2507.19457v1</a>.
[6] AlphaEvolve: A coding agent for scientific and algorithmic discovery. arXiv:2506.13131v1. 2025. <a href="http://arxiv.org/abs/2506.13131v1">http://arxiv.org/abs/2506.13131v1</a>.
[7] Alita: Generalist Agent Enabling Scalable Agentic Reasoning with Minimal Predefinition and Maximal Self-Evolution. arXiv:2505.20286v1. 2025. <a href="http://arxiv.org/abs/2505.20286v1">http://arxiv.org/abs/2505.20286v1</a>.
[8] Absolute Zero: Reinforced Self-play Reasoning with Zero Data. arXiv:2505.03335v2. 2025. <a href="http://arxiv.org/abs/2505.03335v2">http://arxiv.org/abs/2505.03335v2</a>.</p>
