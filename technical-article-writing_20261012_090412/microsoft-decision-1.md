---
{
  "layout": "article-sky",
  "article_variant": "research-review",
  "zoomable_images": true,
  "lang": "en",
  "title": "Microsoft-Decision-1: A Decision Model, Not a Chatbot",
  "seo_title": "Microsoft-Decision-1: Pricing, API & Limits",
  "description": "How Microsoft-Decision-1 scores fixed options: question types, confidence, token pricing, and a Foundry API example for agent routing.",
  "keywords": "Microsoft-Decision-1, decision model, AI model routing, Microsoft Foundry, probability calibration",
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
  "author_name": "AgentsPulse Editorial Team",
  "cover_alt": "An abstract routing device sends incoming information into three predefined paths",
  "cover_width": 1536,
  "cover_height": 864,
  "cover_srcset": "/technical-article-writing_20261012_090412/资源/封面-640.webp 640w, /technical-article-writing_20261012_090412/资源/封面-1280.webp 1280w, /technical-article-writing_20261012_090412/资源/封面-1536.webp 1536w",
  "review_eyebrow": "Decision model analysis",
  "research_scope": "Fixed-option scoring · Calibration · Agent routing",
  "scope_note": "How bounded decisions fit into applications without replacing permissions or human review.",
  "dek": "It scores the answers you provide rather than writing a new one. Understand the API, token costs, and the boundary between confidence and permission.",
  "read_time_minutes": 11,
  "date_format": "%B %-d, %Y",
  "key_takeaways": [
    "Use a decision scorer for bounded classification, routing and grading—not open-ended writing or explanations.",
    "noul returns a condition probability; choice selects an option; score averages the indexes of an ordered rubric.",
    "Confidence is not permission. Validate thresholds against representative data and the cost of errors."
  ],
  "article_toc": [
    {
      "id": "decision-model-vs-llm",
      "label": "Decision model vs. LLM"
    },
    {
      "id": "question-types",
      "label": "Three question types"
    },
    {
      "id": "probability-calibration",
      "label": "Probability and permission"
    },
    {
      "id": "pricing",
      "label": "Pricing"
    },
    {
      "id": "benchmarks",
      "label": "Benchmark limits"
    },
    {
      "id": "foundry-quickstart",
      "label": "Foundry API example"
    },
    {
      "id": "faq",
      "label": "FAQ"
    }
  ],
  "faq_schema": [
    {
      "question": "Can free output make Microsoft-Decision-1 a free chatbot?",
      "answer": "No. The output is a numerical decision, not free-form text, translation, summarization or a written rationale. Free output refers to billing for this decision interface, not to all generation tasks."
    },
    {
      "question": "Can its probabilities replace human review?",
      "answer": "No. Validate thresholds on representative business data and set them according to the cost of errors. Consequential decisions still need meaningful human review, with abstention or escalation when evidence is insufficient."
    },
    {
      "question": "Should it replace the agent's main LLM?",
      "answer": "Start with one bounded, low-risk judgment that you can measure, not the whole agent. Keep a generative model for creating answers and explaining results; if the options and rules are unclear, define the task first."
    }
  ],
  "related_research": [
    {
      "url": "/tutorials/model-gateway-enterprise-ai-control-plane/",
      "title": "The Enterprise Model Gateway",
      "description": "How model routing, budgets and governance become a control plane."
    },
    {
      "url": "/tutorials/coding-agents-finops-cost-per-successful-task/",
      "title": "Cost per Successful Task",
      "description": "Include failed attempts, retries and verification in agent economics."
    },
    {
      "url": "/tutorials/stateless-mcp-agent-gateway/",
      "title": "Stateless MCP and the Agent Gateway",
      "description": "Authorization, versioning and observability at the tool boundary."
    }
  ],
  "minimal_head": true
}
---
**Microsoft-Decision-1 is a decision-scoring model for choosing among fixed options.** Give it a situation, a question and a bounded set of answers; it returns numerical judgments and option probabilities, not a paragraph of generated text. Its intended jobs include classification, model routing, prioritization and response grading. [Microsoft announcement](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

That distinction matters in an agent workflow. A support ticket may need a queue name, not an explanation. A proposed tool call may need a risk assessment before it proceeds. Repeatedly asking a large generative model to write these small judgments adds work that the application does not necessarily need.

Microsoft introduced the model on October 9, 2026. It is post-trained from Qwen3.5-9B for single-pass decision scoring, with access through Microsoft Foundry and [OpenRouter](https://openrouter.ai/microsoft/microsoft-decision-1). The useful starting point is narrow: replace a well-defined judgment, not the entire agent.

**The model estimates which option fits. Your application decides what that estimate is allowed to do.**

<h2 id="decision-model-vs-llm">Decision model vs. LLM: the difference is not just JSON</h2>

A generative LLM can already return `{"team": "engineering"}`. Structured formatting alone does not make a model a decision scorer.

Microsoft-Decision-1 is designed to score fixed answers in a single pass rather than generate a free-form answer or written rationale. It still has to process the input and evaluate the question. The saving is in avoiding an output-generation path that the task does not need—not in making judgment computationally free. [Microsoft: How it works](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

Consider a ticket that says, “Every API call returns a 500 error.” The application defines three destinations: billing handles charges and invoices, engineering handles errors and outages, and support handles how-to questions. The model scores those choices. It does not discover a new department or move the ticket by itself.

A bounded output is easier to use in software. The selected option can drive routing, while its probability can trigger another evaluation or human review. But a fixed answer set has an equally important limitation: the right answer must be represented in it.

If none of the three teams fits, the model can still choose one. A tidy response does not prove the categories cover the situation. Microsoft's guidance recommends an abstention option such as “cannot tell” when a forced choice would be inappropriate. [Microsoft Learn: Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#best-practices)

Use a generative model when the task is to draft a reply, propose a repair or explain a conclusion. Use a decision scorer when the application already knows the possible answers and needs a judgment between them.

<h2 id="question-types">noul, choice and score: three different decisions</h2>

The Foundry API accepts a `state`, which can be text or JSON, and named entries in `questions`. Each question specifies a type, instructions and, where appropriate, criteria. The documentation defines three question types. [Microsoft Learn: Choose a question type](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#choose-a-question-type)

| Type | Question | Meaning of the result | Example |
|---|---|---|---|
| `noul` | Does a condition hold? | A probability from 0 to 1 | Does this reply promise a refund? |
| `choice` | Which fixed option fits? | One selected option and probabilities for every option | Which team should handle this ticket? |
| `score` | Where does it fall on an ordered scale? | A probability-weighted average of level indexes, with probabilities for the levels | How severe is this incident under a defined rubric? |

<picture>
  <source media="(max-width: 640px)" srcset="/image-gen_20261012_103040/decision-types-mobile/article.webp" width="1024" height="1536">
  <img src="/image-gen_20261012_103040/decision-types/article.webp" width="1536" height="1024" loading="lazy" decoding="async" alt="The noul, choice and score question types, with illustrative probabilities and a weighted score of 2.40" data-zoomable title="Click to enlarge">
</picture>

*Figure 1. Each type answers a different question. The probabilities are illustrative; the score example uses level indexes 0–3 and yields 2.40.*

`noul` does not set the application's threshold. A high probability that a reply promises a refund might send the reply for review. It does not approve the refund. The condition being assessed and the action taken afterward are separate decisions.

`choice` selects one label. If a ticket mentions both a duplicate charge and a failed login, the instructions need to say whether to route by the primary issue or split the ticket. A predictable response shape cannot repair an ambiguous task definition.

`score` is easy to misread. Suppose the ordered levels are Cosmetic, Minor, Major and Critical, indexed 0, 1, 2 and 3. With illustrative probabilities of 0.05, 0.10, 0.25 and 0.60, the weighted score is:

```text
0 × 0.05 + 1 × 0.10 + 2 × 0.25 + 3 × 0.60 = 2.40
```

The result sits on a 0–3 scale. It is not a percentage, and it has no meaning apart from the ordered rubric. Change the levels or their order and you change what the number represents. Microsoft recommends using these scores for relative ordering and thresholds rather than treating them as absolute, calibrated ratings. [Microsoft Learn: Use Score](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#use-score-for-ranking-and-grading)

The practical rule is simple: use `noul` for a condition, `choice` for a known set of alternatives and `score` for an ordered rubric. If you cannot yet define what counts as a good answer, improve the task definition before changing models.

<h2 id="probability-calibration">A 90% probability is not permission to act</h2>

Calibration means that confidence should correspond to observed outcomes. Across representative cases assigned about 90% probability of being correct, roughly 90% should actually be correct. It is a group-level relationship, not a guarantee about one decision. [Microsoft: Probability and confidence calibration](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

<picture>
  <source media="(max-width: 640px)" srcset="/image-gen_20261012_103040/calibration-mobile/article.webp" width="1024" height="1536">
  <img src="/image-gen_20261012_103040/calibration/article.webp" width="1536" height="1024" loading="lazy" decoding="async" alt="Nine correct and one incorrect outcome illustrate calibration; a new workload needs data, error-cost and review-threshold checks" data-zoomable title="Click to enlarge">
</picture>

*Figure 2. Nine correct outcomes out of ten illustrate the idea of calibration; ten observations are not enough to establish it. A new workload still needs validation and application-level controls.*

The first question is whether the evaluated cases resemble your workload. Microsoft's documentation says calibration is strongest on familiar task types and warns that wording and option order can affect scores. A threshold tuned for ordinary support tickets should not be carried unchanged into security-alert triage. [Microsoft Learn: Known limitations and risks](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#known-limitations-and-risks)

The second question is what a wrong decision costs. Sending a harmless ticket to the wrong queue may require a manual transfer. Allowing a harmful operation can have a very different consequence. The same confidence level can therefore justify automatic routing in one workflow and mandatory review in another.

Keep the responsibilities separate:

- The model supplies a score or selected option.
- Business rules decide whether to proceed, defer or stop.
- The permission system determines whether the caller may execute the action.
- Logs record what actually happened.

This is an application design pattern, not a complete control system supplied by the model. For the broader distinction between inference routing and governance, see [the enterprise model gateway as a control plane](/tutorials/model-gateway-enterprise-ai-control-plane/).

For consequential decisions involving credit, employment, housing, healthcare or legal matters, Microsoft explicitly calls for meaningful human review and says not to use the model as the sole decision-maker. [Microsoft Learn: Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#best-practices)

<h2 id="pricing">Microsoft-Decision-1 pricing: estimate the whole input</h2>

Microsoft lists **$0.042 per million input tokens, with free output tokens**. That is pricing for the decision interface, not an offer of free long-form generation. [Microsoft: Pricing](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

A first estimate is:

```text
Input cost = calls × billed input tokens per call ÷ 1,000,000 × $0.042
```

For a hypothetical one million calls with 1,000 input tokens each, the input charge is $42. That calculation excludes other models, storage, network costs, retries and human review, as well as any channel-specific discounts.

“Input” includes more than the ticket itself. Instructions, context and option descriptions all contribute to the request. Repeating another 1,000 tokens of policy on every call adds another $42 over the same million calls. A low token price is still a reason to write clear, compact rules rather than paste an entire operations manual into every request.

Several questions about the same `state` can share a request—for example, team, severity and whether the customer has contacted support before. Microsoft's documentation says this reduces request count and keeps the context consistent. It does not establish a fixed token saving; use the returned token usage to measure the actual input. [Microsoft Learn: Combine decisions](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#combine-decisions-in-one-request)

For the complete agent workflow, include failed attempts and verification as well. [Cost per successful task](/tutorials/coding-agents-finops-cost-per-successful-task/) is a more useful operating metric than token price alone.

<h2 id="benchmarks">What “35 times faster” does—and does not—tell you</h2>

Microsoft reports the highest accuracy in its 36-benchmark comparison, covering nearly 150,000 questions kept blind from training. In its speed comparison, the company reports Microsoft-Decision-1 as 2.5 times quicker than H2O-Lightning-4B v1.1 and 35 times quicker than GPT-6 Sol. These are results from Microsoft's evaluation, not universal performance guarantees. [Microsoft announcement](https://commandline.microsoft.com/microsoft-decision-1-model-foundry/)

The figures make a case for testing a dedicated scorer in high-volume judgment tasks. They do not mean an entire agent becomes 35 times faster. Retrieval, network traffic, tool execution, generation and review remain in the critical path. The end-to-end benefit depends on how much time scoring consumed in the first place.

Microsoft also reports an average decision-flip rate of 1.3% across eight forms of request perturbation. That is not a promise that rewriting your rules, changing your categories or moving to another domain will leave every decision unchanged. Its deployment guidance still recommends representative labeled examples and tests of wording and option order. [Microsoft Learn: Best practices](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#best-practices)

Broad benchmarks answer “Is this worth trying?” Your own workload answers “Is this ready to use?”

<h2 id="foundry-quickstart">Foundry API example: start with read-only routing</h2>

The request below adapts Microsoft's Foundry `choice` example to support routing and adds an `unknown` option. Start by recording recommendations without moving tickets; evaluate the decisions before connecting them to a write operation.

You need a paid Azure subscription, a Foundry project, deployment permissions and an authentication method. Deploy Microsoft-Decision-1 from the model catalog, then copy the resource endpoint and deployment name. In the request, **`model` is your deployment name**, not necessarily the underlying model's name. [Microsoft Learn: Deploy and call the decision API](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#call-the-decision-api)

```bash
# Use the endpoint and deployment name from your deployment details.
export AZURE_ENDPOINT="https://<your-resource-host>"
export DEPLOYMENT_NAME="<your-deployment-name>"
# Supply AZURE_API_KEY through your secure environment, not source control.

curl "${AZURE_ENDPOINT%/}/providers/microsoft/v1/systemone" \
  -H "Content-Type: application/json" \
  -H "api-key: $AZURE_API_KEY" \
  -d "$(python3 - <<'PY'
import json
import os

print(json.dumps({
    "model": os.environ["DEPLOYMENT_NAME"],
    "state": "Every API call returns a 500 error. It started yesterday.",
    "questions": {
        "team": {
            "type": "choice",
            "instructions": "Choose a team for the primary issue; choose unknown if the evidence is insufficient.",
            "criteria": {
                "billing": "Charges, invoices, and refunds",
                "engineering": "Software errors, API failures, and outages",
                "support": "How-to and general usage questions",
                "unknown": "Not enough information to determine the team"
            }
        }
    }
}))
PY
)"
```

Validate the response before using it. Check that `answers.team` has the expected type, that its selected option belongs to the allowed set and that probability fields satisfy the documented contract. HTTP 200 alone does not establish a valid business decision. The response also includes the model name and token usage, which help track the deployed model and cost. [Microsoft Learn: Classify support tickets](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#classify-support-tickets)

Before enabling automatic routing, test four things:

1. **Representative accuracy.** Include routine, ambiguous, multi-issue and information-poor tickets—not just three easy examples.
2. **The kinds of failure.** Separate wrong routes, forced choices that should have abstained and unnecessary escalations. One accuracy number hides different operational costs.
3. **Sensitivity to task definition.** Rephrase instructions, reorder options and compare labels and probabilities. Check relevant languages and workload groups too.
4. **End-to-end cost and latency.** Measure requests, retries, input usage and review rates at realistic concurrency and in your deployment region. A deployment type alone does not guarantee lower latency. [Microsoft Learn: Deployment guidance](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision#microsoft-decision-1-at-a-glance)

### Two boundary cases

A user asks, “The system crashed. Explain the cause and write a repair plan.” A `choice` question with Frontend, Backend and Network can route the issue, but it cannot produce the explanation or repair. Route first, then send the evidence to a generative model or engineer.

A proposed tool call would delete production records. Even a low estimated risk does not override permission checks or approval requirements. A score can inform workflow control; it cannot grant authority. For the tool layer, see [stateless MCP and the agent gateway](/tutorials/stateless-mcp-agent-gateway/).

<h2 id="faq">Microsoft-Decision-1 FAQ</h2>

### Can free output make Microsoft-Decision-1 a free chatbot?

No. The output is a numerical decision, not free-form text, translation, summarization or a written rationale. Free output refers to billing for this decision interface, not to all generation tasks.

### Can its probabilities replace human review?

No. Validate thresholds on representative business data and set them according to the cost of errors. Consequential decisions still need meaningful human review, with abstention or escalation when evidence is insufficient.

### Should it replace the agent's main LLM?

Start with one bounded, low-risk judgment that you can measure, not the whole agent. Keep a generative model for creating answers and explaining results; if the options and rules are unclear, define the task first.

Microsoft-Decision-1 makes “ask a large model at every step” a choice rather than a default. Its strongest starting point is a small judgment you already understand—made cheaper and easier to measure, with execution authority kept in the application.
