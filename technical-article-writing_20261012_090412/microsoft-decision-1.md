---
{
  "layout": "article-sky",
  "article_variant": "research-review",
  "zoomable_images": true,
  "lang": "zh-CN",
  "title": "Microsoft-Decision-1 解析：决策评分、价格与接入",
  "seo_title": "Microsoft-Decision-1：决策模型原理、价格与接入",
  "description": "Microsoft-Decision-1 是什么？解析固定选项评分、noul/choice/score 题型、概率校准与输入价格，并给出 Microsoft Foundry 接入示例和智能体路由边界。",
  "keywords": "Microsoft-Decision-1, 决策模型, AI model routing, Microsoft Foundry, 概率校准",
  "tags": [
    "model-routing",
    "evaluations",
    "agent-infrastructure"
  ],
  "categories": [
    "frontier-research"
  ],
  "permalink": "/tutorials/microsoft-decision-1/",
  "slug": "microsoft-decision-1",
  "thumbnail": "/technical-article-writing_20261012_090412/资源/封面-1536.webp",
  "og_image": "/technical-article-writing_20261012_090412/资源/封面-1280.webp",
  "date": "2026-10-12",
  "last_modified_at": "2026-10-12",
  "author_name": "Eureka",
  "cover_alt": "抽象分流装置把复杂输入导向三组固定候选项；概念插画，不表示模型架构或实测",
  "cover_width": 1536,
  "cover_height": 864,
  "cover_srcset": "/technical-article-writing_20261012_090412/资源/封面-640.webp 640w, /technical-article-writing_20261012_090412/资源/封面-1280.webp 1280w, /technical-article-writing_20261012_090412/资源/封面-1536.webp 1536w",
  "review_eyebrow": "决策模型解析",
  "research_scope": "固定选项评分 · 概率校准 · 智能体路由",
  "scope_note": "基于官方发布页与使用文档，区分厂商自评、教学假设和应用设计建议。",
  "dek": "不写一段答案，只为已有选项评分。理解它能降低哪些判断开销，以及为何概率、业务阈值与执行权限必须分开。",
  "read_time_minutes": 12,
  "date_format": "%Y年%m月%d日",
  "ui_labels": {
    "skip": "跳到正文",
    "home": "研究文章",
    "review": "技术解析",
    "by": "作者",
    "minutes": "分钟阅读",
    "published": "文章日期",
    "updated": "编辑日期",
    "scope": "解读范围",
    "toc": "本文目录",
    "takeaways": "先记住三点",
    "related": "延伸阅读"
  },
  "key_takeaways": [
    "固定候选项的分类、路由和验收适合决策评分；开放式写作和解释仍需要生成模型。",
    "noul 返回条件概率，choice 选择一个候选项，score 返回有序等级索引的概率加权平均。",
    "概率不等于授权；阈值应按代表性数据与误判代价验证，重要决策保留人工复核。"
  ],
  "article_toc": [
    {
      "id": "decision-model-vs-llm",
      "label": "决策模型与 LLM"
    },
    {
      "id": "question-types",
      "label": "noul、choice、score"
    },
    {
      "id": "probability-calibration",
      "label": "概率校准"
    },
    {
      "id": "pricing",
      "label": "Microsoft-Decision-1 价格"
    },
    {
      "id": "benchmarks",
      "label": "性能与限制"
    },
    {
      "id": "foundry-quickstart",
      "label": "Microsoft Foundry 接入"
    },
    {
      "id": "faq",
      "label": "Microsoft-Decision-1 常见问题"
    }
  ],
  "faq_schema": [
    {
      "question": "Microsoft-Decision-1 输出免费，能当免费聊天模型吗？",
      "answer": "不能。官方定义的输出是数值化决策，不是自由文本、翻译、摘要或书面理由。免费的是该决策接口的输出计费，不是所有生成任务。"
    },
    {
      "question": "Microsoft-Decision-1 返回概率，可以不用人工复核吗？",
      "answer": "不是。阈值要在代表性业务数据上验证，并按误判后果设置。影响人的重要决策仍需要实质性的人工复核，证据不足时应保留弃答或升级路径。"
    },
    {
      "question": "Microsoft-Decision-1 应该替换智能体的大模型吗？",
      "answer": "先替换一个边界清楚、低风险、可测量的判断环节，而不是整个智能体。若需要创造答案或解释理由，继续使用生成式模型；若候选项和规则尚不明确，先把任务定义清楚。"
    }
  ],
  "related_research": [
    {
      "url": "/tutorials/model-gateway-enterprise-ai-control-plane/",
      "title": "模型网关与企业 AI 控制平面",
      "description": "模型路由、预算与治理为什么需要分开验证。"
    },
    {
      "url": "/tutorials/coding-agents-finops-cost-per-successful-task/",
      "title": "Coding Agent 的成功任务成本",
      "description": "把失败、重试、验证和人工处理纳入总账单。"
    },
    {
      "url": "/tutorials/stateless-mcp-agent-gateway/",
      "title": "无状态 MCP 与 Agent Gateway",
      "description": "工具执行的权限、版本管理和可观测性边界。"
    }
  ],
  "minimal_head": true
}
---
**Microsoft-Decision-1 是微软用于固定选项判断的决策评分模型**：输入情境、问题与候选项，输出各选项概率，不生成自由文本或书面理由。它面向分类、模型路由、优先级排序和回答验收，而不是聊天写作。[微软发布原文](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

假如每张客服工单都要先问一次大模型“该转给谁”，你真正需要的往往只是一个队列名，而不是一段解释。当智能体的每一步都要分流、验收或决定是否重试，反复生成判断文字就会成为持续开销。

微软在2026年10月9日发布的文章说明，它基于 Qwen3.5-9B 后训练。目前官方列出的接入渠道是 Microsoft Foundry 与 OpenRouter。[微软发布原文](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

它最值得考虑的用法，是给现有工作流加一层便宜的分流或评分。需要起草回复、提出新方案、解释原因，仍交给生成式模型；需要退款、改生产数据或处理影响人的重要决策，也不能把一个高概率当成执行许可。

**先记住这个分工：模型估计哪个选项更合适，应用决定这个判断能触发什么。**

<h2 id="decision-model-vs-llm">决策模型与 LLM：从生成答案到固定选项评分</h2>

普通生成模型也能按 JSON 格式回答“engineering”。因此，区别不只是结果有没有大括号。

Microsoft-Decision-1 的目标是单次前向评分：围绕给定的选项返回概率，不生成一串说明文字。它仍要读取上下文、理解问题并完成计算；省掉的是这种任务不需要的自由文本生成路径，而不是把判断变成零成本运算。[发布原文：How Microsoft-Decision-1 works](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

例如，一张工单写着：“每次调用 API 都返回500。”应用先定义三类：账务负责扣款和发票，工程负责错误与故障，支持负责操作指引。模型的工作是在这些选项之间评分。它不会替你发现公司刚成立了一个新部门，也不会自动把工单发出去。

这个限制恰好给接口带来可预测性。候选项由应用约束，返回值可以直接用于排序、阈值判断或下一步路由。但如果三类都不适合，又没有“无法判断”，接口仍然可以返回一个看起来很确定的选项。**固定选项限制了输出空间，却不保证选项覆盖了现实。** 官方建议在不该强制选择时加入弃答选项。[Learn：Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#best-practices)

<h2 id="question-types">noul、choice、score：三种决策题型怎么选？</h2>

Foundry 接口把输入叫作 `state`，它可以是文本或 JSON；判断放在 `questions` 中，每个问题有自己的名字、类型和规则。当前文档列出三种题型。[Learn：Choose a question type](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#choose-a-question-type)

| 题型 | 回答什么 | 返回的含义 | 适合的例子 |
|---|---|---|---|
| `noul` | 某个条件是否成立？ | 0到1的概率 | 回复是否承诺退款？ |
| `choice` | 固定候选项中选哪个？ | 一个选项及各选项的概率 | 工单该转哪个团队？ |
| `score` | 落在有序尺度的哪里？ | 等级索引的概率加权平均，并提供各等级概率 | 按既定规则排事件严重程度 |

<picture>
  <source media="(max-width: 640px)" srcset="/technical-article-writing_20261012_090412/资源/题型-手机.webp" width="510" height="2192">
  <img src="/technical-article-writing_20261012_090412/资源/题型-1536.webp" width="1536" height="1024" loading="lazy" decoding="async" alt="noul 条件概率、choice 固定选项概率与 score 四等级概率加权；全部数值为教学假设" data-zoomable title="Click to enlarge">
</picture>

*图1｜三种题型回答不同的问题。所有概率为教学假设；score示例采用0到3的等级索引，加权结果为2.40。*

`noul` 不替你决定阈值。比如“回复是否承诺退款”返回较高概率后，应用可以把回复送去审核，而不是据此批准退款。问题的真假定义和后续动作是两件事。

`choice` 要选一个标签。如果一张工单同时提到重复扣款和登录失败，问题应说明按“主要问题”分流，或者先拆分处理；含糊的规则不会因为输出结构整齐就变清楚。

`score` 尤其容易误读。假设你按从低到高列出四级：外观问题、轻微问题、重大问题、严重问题。文档规定索引为0、1、2、3。若各级概率分别为0.05、0.10、0.25、0.60，则返回的加权分是：

```text
0×0.05 + 1×0.10 + 2×0.25 + 3×0.60 = 2.40
```

这是教学假设，不是本次模型输出。2.40位于0到3的尺度上，不是百分制成绩，也不是未经定义的“质量2.4分”。换一套等级或换等级顺序，分数的含义也变了。官方建议把这类分数优先用于相对排序与阈值，而不是当作绝对、已校准的评级。[Learn：Use Score for ranking and grading](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#use-score-for-ranking-and-grading)

这给出一个简单的选型判断：能列清候选项，就考虑 `choice`；只检查一个条件，就考虑 `noul`；需要相对排队且能定义等级，就考虑 `score`。如果连“好答案是什么”都还不能定义，先改任务，不要先换模型。

<h2 id="probability-calibration">概率校准：90%的判断为什么仍需复核？</h2>

“校准”不是让模型说话更有信心。它要求概率与实际表现对应：在代表性案例中，预测正确概率约90%的那一组，实际应有接近90%答对。微软发布原文也是这样解释的。[发布原文：Probability and confidence calibration](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

<picture>
  <source media="(max-width: 640px)" srcset="/technical-article-writing_20261012_090412/资源/校准-手机.webp" width="600" height="1274">
  <img src="/technical-article-writing_20261012_090412/资源/校准-1536.webp" width="1536" height="1024" loading="lazy" decoding="async" alt="九个蓝勾与一个黄叉说明校准的统计意义；新业务仍需核验，概率不等于授权" data-zoomable title="Click to enlarge">
</picture>

*图2｜校准描述同类案例的统计关系，不是单次正确保证。十个圆点仅作教学示意，不能用来证明模型已校准。*

图中十次答对九次只是帮助理解的示意，不能拿十个样本证明校准，更不能把一次90%的判断理解为“已经确认”。还要问：这一组案例是否与你的新业务相似？

官方文档明确提醒，校准在熟悉的任务类型上最强，措辞与选项顺序也可能改变评分。一个通用客服分类器转去处理内部安全告警，不能直接继承原来的阈值。[Learn：Known limitations and risks](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#known-limitations-and-risks)

阈值应从误判后果倒推。把普通工单转错队列，可能只是多一次人工转派；把可能有害的操作误判为安全，后果完全不同。因此，同样的概率可以对应不同的工作流：低风险任务自动分流，高风险动作请求人工审核，证据不足则弃答。

如果需要管理多个模型，先看[模型网关如何区分路由、预算与治理](/tutorials/model-gateway-enterprise-ai-control-plane/)；模型选型和工具授权是不同层面的控制。

更稳妥的应用会把职责分开：模型提供评分；业务规则决定通过、复核或停止；权限系统检查调用者是否有权执行；执行日志保留实际发生了什么。这里的分层是应用设计建议，不是 Microsoft-Decision-1 自动提供的一整套保障。

对于信用、就业、住房、医疗和法律等涉及人的重要决策，Learn 明确要求有实质意义的人工复核，不能让模型成为唯一决策者。[Learn：Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#best-practices)

<h2 id="pricing">Microsoft-Decision-1 价格：如何估算输入费用？</h2>

微软当前公布的价格是 **每百万输入token 0.042美元，输出token免费**。这描述的是决策接口的计费，不是免费生成长文。[发布原文：Pricing](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

可以先用一个简单公式估算：

```text
输入费用 = 调用次数 × 每次计费输入token ÷ 1,000,000 × 0.042美元
```

假设100万次调用，每次总输入恰好1000 tokens，输入费用就是42美元。这是按公布单价做的假设计算，未调用API；不包括其他模型、存储、网络、重试和人工复核等费用，也未计入渠道可能有的折扣。

关键在“总输入”。工单正文很短，不代表请求很短：规则、情境和选项描述都要算进去。如果每次又重复1000 tokens的审核规则，同样100万次调用就再增加42美元。模型输入便宜，仍值得把规则写清楚、写精简，而不是把整本操作手册都塞进每次请求。要评估完整智能体工作流，应该连失败、重试和验证一起看，参见[每个成功任务的成本，而不只是 token 单价](/tutorials/coding-agents-finops-cost-per-successful-task/)。

同一份 `state` 的几个问题可以放进一个请求，例如一起判断团队、严重程度与是否重复联系。官方文档指出，这能减少请求数量并保持上下文一致；但不能据此保证计费输入减少多少，具体仍应看返回的 token usage。[Learn：Combine decisions in one request](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#combine-decisions-in-one-request)

<h2 id="benchmarks">性能与限制：“快35倍”不是整套智能体快35倍</h2>

微软报告，模型在36项、接近15万道题的比较中准确率最高；其测试中，比 H2O-Lightning-4B v1.1 快2.5倍，比 GPT-6 Sol 快35倍。这些是微软自评的特定比较，不是本次独立跑分。[发布原文](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

它解释了为什么高频判断值得独立选模型，却不能直接成为应用的速度承诺。端到端任务还要等待检索、网络、工具执行、生成模型和人工审核；只加速其中一个评分环节，整个任务的收益取决于这一环节原来占了多少时间。

同样，微软报告八类输入扰动测试中平均只有1.3%发生决策翻转，不等于你的规则改写、类别调整或业务迁移永远不会改变结果。Learn 仍建议用代表性标注样本测试措辞、顺序和错误类型。宽泛跑分适合决定“要不要试”，本地工作负载才决定“能不能上线”。[Learn：Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#best-practices)

<h2 id="foundry-quickstart">Microsoft Foundry 接入：先做一个只读分流器</h2>

下面沿用官方 Foundry 请求格式，把一个 `choice` 问题改成中文工单分流，并加入“无法判断”。**格式与脚本只做静态检查，本次没有部署模型、调用付费API或验证返回值。**

前提是已有付费 Azure 订阅、Foundry 项目、部署权限以及相应身份或API密钥。按官方文档从 Model catalog 部署后，复制资源 endpoint 和部署名。注意：请求里的 `model` 是你设置的**部署名**，不是直接填写底层模型名。[Learn：Deploy Microsoft-Decision-1 / Call the decision API](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#call-the-decision-api)

```bash
# 使用部署详情页的真实值；不要把密钥写进文章或版本库。
export AZURE_ENDPOINT="https://<你的资源域名>"
export DEPLOYMENT_NAME="<你的部署名>"
# AZURE_API_KEY 由你的安全环境提供。

curl "${AZURE_ENDPOINT%/}/providers/microsoft/v1/systemone" \
  -H "Content-Type: application/json" \
  -H "api-key: $AZURE_API_KEY" \
  -d "$(python3 - <<'PY'
import json
import os

print(json.dumps({
    "model": os.environ["DEPLOYMENT_NAME"],
    "state": "每次调用 API 都返回500，昨天开始出现。",
    "questions": {
        "team": {
            "type": "choice",
            "instructions": "根据主要问题选择一个团队；证据不足时选unknown。",
            "criteria": {
                "billing": "扣款、发票、退款等账务问题",
                "engineering": "程序错误、接口失败或服务故障",
                "support": "使用方法和一般操作问题",
                "unknown": "现有信息不足，无法确定团队"
            }
        }
    }
}, ensure_ascii=False))
PY
)"
```

先只记录建议，不让它触发工单修改。处理响应时，检查 `answers.team` 的类型、选项是否在允许集合内，以及概率字段是否满足文档约定；不要仅凭 HTTP 200 就当作有效业务判断。响应还包含模型名与 token usage，可用于记录版本和成本。[Learn：Choose a question type / Classify support tickets](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#classify-support-tickets)

上线前至少验证四件事：

1. **能否分对真实样本。** 包含常规、边界、跨类别与信息不足的工单，不只用三个容易的例子。
2. **失败发生在哪。** 分开看错派、该弃答却强选、该自动处理却过度复核；总准确率会掩盖不同代价。
3. **规则变化是否稳定。** 改写问题、调换选项顺序，观察标签和概率变化；也检查不同语言或业务群体的表现。
4. **整条链是否划算。** 在实际资源区域与并发下测请求时延、重试、输入用量，以及人工复核比例。地域部署本身不保证更低时延。[Learn：Model at a glance / Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#microsoft-decision-1-at-a-glance)

### 一个边界案例，检查你是否选对了工具

用户问：“系统崩溃了，请解释原因并帮我写修复方案。”把 `choice` 设置成“前端、后端、网络”只能得到分流判断，不能完成解释与修复。更合理的组合是先决定该由谁处理，再把证据交给生成模型或工程师。

如果用户问：“这次工具调用要删除生产记录，是否继续？”即使模型判断风险很低，也不该跳过权限与审批。评分能辅助控制流程，不能凭空赋予权限。关于工具层的授权、版本和审计，可以继续阅读[无状态 MCP 与 Agent Gateway 的控制边界](/tutorials/stateless-mcp-agent-gateway/)。

<h2 id="faq">Microsoft-Decision-1 常见问题</h2>

### Microsoft-Decision-1 输出免费，能当免费聊天模型吗？

不能。官方定义的输出是数值化决策，不是自由文本、翻译、摘要或书面理由。免费的是该决策接口的输出计费，不是所有生成任务。

### Microsoft-Decision-1 返回概率，可以不用人工复核吗？

不是。阈值要在代表性业务数据上验证，并按误判后果设置。影响人的重要决策仍需要实质性的人工复核，证据不足时应保留弃答或升级路径。

### Microsoft-Decision-1 应该替换智能体的大模型吗？

先替换一个边界清楚、低风险、可测量的判断环节，而不是整个智能体。若需要创造答案或解释理由，继续使用生成式模型；若候选项和规则尚不明确，先把任务定义清楚。

Microsoft-Decision-1 的价值，在于让“每一步都问大模型”不再是唯一选择。最好的起点不是让它自主做更多事，而是让一个已经定义清楚的判断更便宜、更可测量，同时把执行权稳稳留在应用里。

---

*本文由 Eureka 整理；资料读取于2026年10月11日，SEO 与站点版本编辑于10月12日。基于当前微软发布页、Microsoft Learn 与 [OpenRouter 渠道页面](https://openrouter.ai/microsoft/microsoft-decision-1)；发布页已注明后续更新。本次未运行模型，教学数字不代表实测。*
