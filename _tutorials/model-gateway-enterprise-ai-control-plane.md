---
layout: article-sky
article_variant: research-review
lang: en
title: "The Model Gateway Is Becoming the Control Plane for Enterprise AI"
seo_title: "The Model Gateway Is Becoming the Control Plane for Enterprise AI"
description: "Why model gateways are becoming the enterprise control plane for AI routing, budgets, quality, policy, and audit."
keywords: "model gateway, enterprise AI, LLM routing, AI governance, AI cost control"
tags: [agent-infrastructure, frontier-research]
categories: [frontier-research]
permalink: /tutorials/model-gateway-enterprise-ai-control-plane/
thumbnail: "/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_00_architecture.jpg"
og_image: "/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_00_architecture.jpg"
date: 2026-08-05
last_modified_at: 2026-08-05
author_name: "AgentsPulse Editorial Team"
cover_alt: "The Model Gateway Is Becoming the Control Plane for Enterprise AI"
cover_width: 1200
cover_height: 685
paper_count: 1
research_scope: "Model gateways · Enterprise AI · Governance"
dek: "Why model gateways are becoming the enterprise control plane for AI routing, budgets, quality, policy, and audit."
key_takeaways:
  - "Evidence-led analysis of the architecture, operational constraints, and production implications."
  - "Separates vendor-reported results from claims supported by broader evidence."
  - "Focuses on implementation decisions practitioners can evaluate today."
article_toc:
  - id: "tl-dr"
    label: "TL;DR"
  - id: "from-proxy-to-control-plane-what-changed"
    label: "From Proxy to Control Plane: What Changed"
  - id: "routing-as-a-quality-and-cost-decision-not-a-load-balancing-decision"
    label: "Routing as a Quality and Cost Decision, Not a Load-Balancing Decision"
  - id: "the-quality-problem-routing-assumes-away"
    label: "The Quality Problem Routing Assumes Away"
  - id: "evaluation-as-a-gateway-input-not-an-afterthought"
    label: "Evaluation as a Gateway Input, Not an Afterthought"
  - id: "governance-audit-and-the-line-between-model-and-tool-access"
    label: "Governance, Audit, and the Line Between Model and Tool Access"
  - id: "what-a-control-plane-gateway-actually-has-to-do"
    label: "What a Control-Plane Gateway Actually Has to Do"
  - id: "what-to-do-now"
    label: "What to Do Now"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/stateless-mcp-agent-gateway/"
    title: "Stateless MCP and the Rise of the Agent Gateway"
    description: "How MCP gateways centralize policy and authorization for agent tools."
  - url: "/tutorials/coding-agents-finops-cost-per-successful-task/"
    title: "Coding Agents Enter the FinOps Era"
    description: "Why production agents need budgets, routing, and verification."
---
<img src="/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_00_architecture.jpg" decoding="async" loading="lazy" width="1200" height="685" alt="The Enterprise Model Gateway" />

*The Enterprise Model Gateway.*

The proxy layer for LLM traffic used to be a solved problem: a thin translation shim letting a client speak one dialect while a provider spoke another. That framing is now visibly out of date. In the space of a few days in early August 2026, Databricks took its Unity AI Gateway to general availability with hard spend caps, per-user cost attribution, and a beta routing engine [1], LiteLLM shipped conversation-aware routing with benchmarked quality and cost tradeoffs [2], OpenRouter launched an evaluation product that treats model choice as a per-application empirical question rather than a leaderboard lookup [3], and Google Cloud moved multi-model routing into a serverless API Gateway feature [5]. None of these are proxies in the old sense. They are converging on the same set of responsibilities: who gets to call which model, at what cost, with what guarantees about quality, and with what record afterward.

The trigger is not architectural elegance but the collapse of the assumptions the early proxy pattern was built on. Teams no longer call one model from one provider; they call dozens of models across labs and hosting arrangements, often from the same application or request. Inference spend has grown large enough that finance and platform teams demand the kind of controls they already have for cloud compute, not the tokenmaxxing free-for-all Databricks describes in its own launch post [1]. Separately, measurement work now shows that calling the same model by name does not guarantee the same behavior across providers, because hosting-side choices like quantization and token limits change what the model actually does [4]. Together these pressures are pushing the gateway from an integration convenience into something closer to a control plane, where routing, budget, quality assurance, policy, and audit have to live together because none can be reasoned about correctly in isolation.

It is worth being precise about scope, because "gateway" now covers two genuinely different things in adjacent parts of the stack. A model gateway, the subject of this article, sits between an application and the LLM providers it calls, and governs inference: which model answers a request, at what price, under what data-handling rules, and with what record kept. An MCP gateway sits between an agent and the tools or systems it can invoke through the Model Context Protocol, and governs action: which tool a given identity may call, with what arguments, against which backend. Databricks' own materials gesture at both concerns living inside one platform, since Unity Catalog is described as governing "AI assets" including MCP servers, skills, and coding agents alongside models [1]. That consolidation is a vendor design choice, not evidence the two concerns are the same problem. A gateway deciding whether GPT-5.5 or a cheaper open-weight model answers a prompt is solving a routing and spend problem. A gateway deciding whether an agent may call `delete_file` or `issue_refund` is solving an authorization problem. This article is about the former.

## TL;DR

- Databricks' Unity AI Gateway reached general availability with hard spend caps, per-user and per-team cost attribution, and a beta routing feature that picks models by quality, cost, and budget, reporting over a quadrillion tokens processed in the prior year [1].
- LiteLLM published paired before/after measurements showing that giving its LLM-based router two prior conversation turns raises follow-up classification agreement from 14% to 78%, with latency differences whose 95% confidence intervals contain zero [2].
- Endpoint-level accuracy is not uniform across providers hosting the same named model: Artificial Analysis, as reported by AlphaSignal, found some providers scoring roughly half the reference accuracy on hard reasoning tasks due to output token limits, and others varying from 22% to 37% on a tool-calling benchmark for the same model [4]. This is secondary reporting on a newly launched benchmark methodology, not an independently reproduced result.
- OpenRouter's Ori Eval reframes "which model is best" as a per-application empirical question, generating harness-pinned evals from a codebase rather than relying on published leaderboards [3].
- Google Cloud moved multi-provider request routing into a managed, serverless API Gateway feature, removing the need to run and scale a proxy like LiteLLM as a standalone service for simple routing cases [5].
- A model gateway governs inference (which model, at what cost, under what rules); an MCP gateway governs tool and action access. Vendors increasingly bundle both under one console, but the enforcement logic and risk surface differ.

## From Proxy to Control Plane: What Changed

The earliest LLM gateways solved a narrow problem: normalize request and response formats across providers so application code did not need a different SDK per vendor. Google Cloud's newly shipped API Gateway feature is, by its own description, still largely this layer — it intercepts an OpenAI-compatible request, inspects the `model` field, matches it against routing rules in an OpenAPI spec, and transcodes the payload into each provider's native schema before dispatching it [5]. That is real and useful, and its serverless packaging removes an operational burden: per Google's announcement as reported by AlphaSignal, teams previously had to deploy and scale something like a LiteLLM sidecar just to get multi-provider routing [5]. But format translation and static routing rules do not by themselves address cost governance, per-request quality assurance, or auditability, and Google's documented limits are explicit about scope: same-host backends only, text modality only, no VPC Service Controls, and no mixed routing configurations in a single spec [5].

Databricks' Unity AI Gateway announcement describes a different order of problem, framed in three terms — cost, control, and choice — each mapping to a capability a stateless proxy cannot provide alone [1]. Cost control requires knowing, in near real time, how much is being spent by whom, with the authority to stop a request before completion; Databricks describes "proactive budgets" and "hard spend caps" enforced at the gateway, plus dashboards built on data centralized in Unity Catalog [1]. Control requires identity, permissioning, and an audit trail that survives across whichever model or tool served a given request, framed as Unity Catalog providing "identity, permissions, lineage, and auditing" while the gateway "enforces runtime guardrails and contextual policies" at the moment of the call [1]. Choice requires swapping models and providers without rewriting application code or losing governance continuity, framed as a single-query API across Anthropic, OpenAI, Gemini, Kimi, and GLM among others [1].

These are properties of a control plane, not a proxy. The distinction matters operationally: a proxy failure mode is "wrong endpoint" or "malformed payload," while a control plane failure mode is "an agent silently exceeded budget for three days before anyone noticed," or "a change in a downstream provider's serving configuration degraded output quality without anyone changing code." Databricks' customer quotations reinforce this: Rivian and Volkswagen Group Technologies' tech lead describes the value as "one governed control plane means we're watching one door, not a dozen," and Zepto's engineering lead cites production-scale token volume alongside user-level cost visibility as the operative benefit, rather than routing or translation per se [1]. These are vendor and customer claims reported at face value, not independently audited outcomes — they describe what the product is designed to do and what named customers report finding useful, not a controlled comparison against alternatives.

## Routing as a Quality and Cost Decision, Not a Load-Balancing Decision

"Routing" covers at least two different mechanisms that are easy to conflate. One is load-based or availability-based routing: send a request to whichever healthy backend can serve it, independent of content. The other is content-based routing: classify what the request actually needs, sending simple work to a cheap model while reserving expensive models for work that requires them. Databricks' Smart Routing beta and LiteLLM's Auto Router are both instances of the second kind, and the mechanism only works if the classification step is reliable.

<img src="/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_01_auto-router-uses-conversation-context-to-select-model-ti.jpg" decoding="async" loading="lazy" width="1200" height="627" alt="Auto Router uses conversation context to select model tiers" />

*Auto Router uses conversation context to select model tiers.*

LiteLLM's own benchmarking on its v1.97 release quantifies exactly where an LLM-based classifier fails and what fixes it. The stated problem is multi-turn conversations where a short follow-up like "yes, go ahead" authorizes substantial prior work but reads, in isolation, as trivial [2]. Classifying that turn alone produced 14% agreement with a reference tier on a dataset of 36 such follow-ups; one prior turn of context raised agreement to 47%, and two prior turns brought it to 78%, with no further gain out to a window of ten turns [2]. This is a single vendor's internal benchmark of 5,600 live classifier calls across three datasets, so the exact percentages characterize LiteLLM's own classifier and datasets rather than a general law — but the sharp-early-gain-then-plateau shape is mechanistically plausible rather than a cherry-picked anomaly, since the paper also reports a matched control set of self-describing follow-ups where the same windowing produces smaller, more uniform gains (80% at zero context rising to 91–95% with one turn) [2].

The cost implication cuts in a direction that is easy to miss if "smarter routing" is assumed to mean "always cheaper." LiteLLM's numbers show routed cost on the short-reply dataset rising from $2.87 to roughly $6.50 per 1,000 requests once context is added, because the classifier stops mis-pricing those follow-ups as SIMPLE (66% of that tier at zero context versus 30% with two turns of context) [2]. The correct characterization is that context corrects mispricing, not that it reduces cost — mispricing can run in either direction depending on traffic. On the two other datasets LiteLLM measured, routed cost fell instead, because added context resolved ambiguous follow-ups toward the medium tier rather than the more expensive reasoning tier [2]. LiteLLM is explicit that whether a deployment gets cheaper or more expensive routing depends on its actual traffic mix, which is why it also shipped a Benchmarks view comparing routed spend against an all-frontier baseline priced from the customer's own usage rather than a synthetic dataset [2].

The table below summarizes how the routing mechanism differs across the primary sources, and what each measures its effect against.

| System | Routing basis | What is measured | Reported effect | Evidence type |
|---|---|---|---|---|
| Databricks Smart Routing (beta) | Quality, cost, performance, availability, budget | Not independently quantified in source | Vendor claim of "better value... without compromise" | Vendor claim |
| LiteLLM Auto Router v1.97 | LLM classifier reading last N conversation turns | Agreement vs. reference tier, paired latency, modelled cost | 14% to 78% agreement gain (N=0 to N=2) on follow-ups; latency CIs include zero | Vendor benchmark, single classifier model, 5,600 calls |
| OpenRouter Ori Eval | Not a router; a per-application evaluation harness feeding routing/model decisions | Tool-call assertions plus LLM-judge scoring on the application's own prompts | Example table shows catch rate, latency, $/PR across five models | Vendor product description with illustrative example |
| Google Cloud API Gateway | Static rule match on `model` field in OpenAPI spec | Not a quality mechanism; a transcoding and dispatch layer | N/A — routing is deterministic by config, not adaptive | Secondary reporting on vendor announcement |

## The Quality Problem Routing Assumes Away

Every content-based routing scheme rests on an assumption rarely stated out loud: that calling "Claude Opus" or "GLM-5.2" by name gets a consistent, known quantity regardless of which provider actually serves the request. Artificial Analysis's newly launched Endpoint Accuracy Index, as reported secondhand by AlphaSignal, tests that assumption directly, and the reported findings suggest it does not hold uniformly [4]. The methodology compares each provider's hosted endpoint for a given open-weight model against a self-hosted reference deployment of the same weights, across three equally weighted categories: tool calling, hard reasoning, and long-context recall [4]. A score of 100% means the endpoint matches the reference deployment; anything lower represents accuracy given up somewhere in the serving stack — quantization, altered sampling defaults, output token caps, or context-handling differences [4].

<img src="/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_03_artificial-analysis-exposes-how-api-providers-quietly-de.jpg" decoding="async" loading="lazy" width="959" height="599" alt="Model quality can vary across API providers" />

*Reported model quality variation across API providers.*

The specific figures reported warrant caution about over-generalizing. For GLM-5.2, the most restrictive provider endpoints reportedly scored around half the reference accuracy or lower on the hard reasoning benchmark, attributed to output token limits truncating reasoning mid-chain [4]. For gpt-oss-120b, tool-calling accuracy on the same benchmark reportedly ranged from 22% to 37% depending on which endpoint served the request [4]. For DeepSeek V4 Pro, by contrast, most endpoints reportedly matched the reference, with the model's own first-party API scoring slightly above it [4]. Two qualifications matter. First, this is AlphaSignal's secondary reporting on a benchmark it did not run, so the numbers should be attributed to Artificial Analysis's methodology and treated as a single benchmark snapshot rather than an audited, reproducible finding; the underlying source reportedly attaches a 95% confidence interval and a statistical flag for whether an endpoint sits significantly below reference, a meaningfully more rigorous framing than a bare leaderboard, but that rigor lives in the primary methodology page, not in the secondary summary [4]. Second, the pattern varies by model — DeepSeek at parity, GLM and gpt-oss with meaningful gaps — so the correct inference is not "all hosted endpoints degrade quality" but that endpoint-level variance exists and differs by model and provider, traceable to specific serving choices like token limits.

For a gateway acting as a control plane, this has a direct operational consequence: routing decisions that assume a model name is a stable unit of quality are routing on an incomplete signal. A gateway that picks "cheapest provider serving GLM-5.2" without accounting for that provider's output token cap could be silently trading away exactly the reasoning depth the routing decision was supposed to preserve. OpenRouter's Ori Eval and Artificial Analysis's index address adjacent but distinct problems: one measures whether a specific endpoint preserves the accuracy of the model it claims to serve, the other whether a given model, run through your own harness, is the right choice for your workload at all. Neither substitutes for the other, and a gateway optimizing only for lowest listed price per token, without either signal, is optimizing blind.

## Evaluation as a Gateway Input, Not an Afterthought

OpenRouter's positioning of Ori Eval is explicit that static leaderboards and social-media recommendations are insufficient inputs for a routing decision, because "a benchmark measures a fixed task set, and a recommendation reflects someone else's application" [3]. The product generates an evaluation harness from a customer's own codebase: it scans for every place a model is called, asks the developer what matters (accuracy, speed, cost), and writes eval files that assert on tool calls and grade open-ended answers with an LLM judge [3]. The illustrative table OpenRouter publishes shows five models compared on catch rate, p50 latency, and cost per pull request, with one candidate marked as failing purely on cost despite a competitive catch rate — a concrete demonstration that "best" is a function of the constraint set, not a single ranking [3]. This is vendor material describing product behavior, and the specific numbers in that table are illustrative rather than independently verifiable, but the underlying argument — that model selection should be pinned to the application's own harness and re-run as new models ship — is a defensible response to the endpoint variance problem described above.

<img src="/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_02_ori-eval-prove-the-best-model-for-what-you-re-building.jpg" decoding="async" loading="lazy" width="1200" height="509" alt="Ori Eval compares models on application-specific tasks" />

*Ori Eval compares models against application-specific tasks and constraints.*

The operational link to gateways is direct: an evaluation harness like this is meaningless unless its output feeds a routing or procurement decision, and a gateway is the natural place for that decision to be enforced. OpenRouter frames the connection loosely, noting one early user "runs model comparisons monthly" and that a passing new model can trigger an automated pull request to swap it in [3]. That workflow describes evaluation informing configuration, a lighter coupling than the request-time routing Databricks and LiteLLM implement, but the direction is the same: quality assurance is becoming an ongoing input a gateway consumes, not a one-time model selection exercise done before a project ships.

## Governance, Audit, and the Line Between Model and Tool Access

The governance language across the vendor sources is where the model-gateway/MCP-gateway distinction gets blurred in marketing even as it stays sharp in mechanism. Databricks explicitly bundles "external agent, an MCP, a skill, or a model" as things Unity AI Gateway can govern, with Unity Catalog as the substrate providing identity and audit for all of them [1]. That bundling is a reasonable product strategy — enterprises want one place to see identity, spend, and audit trail across everything an agent touches, and Rivian's tech lead frames the value explicitly in those terms — "one governed control plane means we're watching one door, not a dozen" [1]. But the enforcement logic underneath is not identical for the two cases. Governing model access means answering: is this identity authorized to call this model tier, what will it cost, has budget been exceeded, and what was the input and output for audit purposes. Governing tool or MCP access means answering: is this identity authorized to invoke this specific action against this specific backend system, with what arguments, and what side effects resulted on a system of record.

<img src="/images/model-gateway-enterprise-ai-control-plane/githubio_model_gateway_04_google-cloud-api-gateway-ships-serverless-multi-model-ro.jpg" decoding="async" loading="lazy" width="1200" height="600" alt="Rule-based multi-model routing through Google Cloud API Gateway" />

*Rule-based multi-model routing through Google Cloud API Gateway.*

The risk profiles differ accordingly. A misrouted model call, in the worst case, produces a wrong or lower-quality answer, or an unexpected cost. A miscontrolled tool call can delete data, issue a refund, or exfiltrate information from a connected system. Databricks' own post gestures at this distinction, listing prompt injection and supply-chain attacks against MCP servers alongside cost overruns as separate risk categories, even while proposing a unified governance layer for both [1]. The practical recommendation for teams evaluating these platforms is to check whether "unified governance" means a shared identity and audit substrate with distinct, purpose-built policy engines underneath — defensible — or whether the same policy mechanism is being stretched to cover both model routing and tool authorization, which is more likely to produce gaps, since the two require different context (cost and quality signals versus the specific action and its blast radius) to evaluate correctly.

## What a Control-Plane Gateway Actually Has to Do

A model gateway operating as a control plane needs to satisfy roughly five functions simultaneously, and the evidence in this set maps onto each unevenly — some well covered by shipped, measured functionality, others covered mostly by vendor claim or by adjacent tooling not yet integrated into the gateway itself.

Routing needs to be quality-aware and cost-aware together, not cost-aware alone. LiteLLM's benchmarking shows this concretely: a classifier that ignores conversational context routes cheaply but wrong, and fixing that costs more in some traffic patterns and less in others, knowable only by measuring actual traffic rather than assuming a direction [2]. Spend control needs to be enforceable, not just observable — Databricks describes hard caps rather than only dashboards, the meaningful distinction between a monitoring tool and a control plane [1]. Quality assurance needs to attach to the specific endpoint actually serving a request, not just the model name, given the endpoint-level variance Artificial Analysis's index reports [4]. Evaluation needs to be tied to the application's own workload and re-run as new models ship, the gap OpenRouter's Ori Eval is built to close, albeit as a distinct product rather than a gateway feature in the sources reviewed here [3]. And audit needs to produce a record tying a specific output back to a specific model, provider, cost, and identity, the baseline Unity Catalog is positioned to provide across model and non-model assets alike [1].

No single source here demonstrates all five functions operating together in one deployed system with independently verified outcomes; what exists is a set of vendor claims (Databricks), a vendor's own rigorous but self-reported benchmark (LiteLLM), a vendor product for a related but distinct evaluation problem (OpenRouter), a secondary report on a new third-party accuracy benchmark (Artificial Analysis via AlphaSignal), and a narrower infrastructure feature (Google Cloud). The thesis that the gateway is becoming a control plane is best read as a direction the market is converging on from multiple independent angles, rather than a fully proven architecture with one vendor demonstrating best-in-class performance across every dimension.

## What to Do Now

Treat model gateway selection as a control-plane decision, not an SDK-compatibility decision. Ask whether the candidate enforces spend limits at request time or only reports spend after the fact, since the difference determines whether a runaway agent gets stopped or merely logged [1].

If content-based routing is in scope, measure it against your own traffic before trusting a vendor's aggregate savings claim. LiteLLM's own data shows routed cost moving in opposite directions across different conversational datasets, and the only reliable check is a benchmark against your own workload — exactly why LiteLLM ships a Benchmarks view rather than a single savings number [2].

Do not assume a model name is a stable unit of quality across providers. If your gateway lets you pin a provider, do so for accuracy-sensitive workloads until you have endpoint-level evidence, and treat newly launched cross-provider accuracy benchmarks like the one AlphaSignal describes as an emerging signal worth tracking rather than a settled ranking [4].

Build or buy an evaluation harness that runs against your own prompts and tool calls, and wire its output into your routing configuration on a recurring cadence rather than a one-time launch decision, following the pattern OpenRouter describes of monthly re-evaluation triggering a configuration change [3].

Keep model-gateway and MCP-gateway policy engines conceptually separate even if they share an identity and audit substrate. A unified console for visibility is reasonable; a single undifferentiated policy mechanism for both cost-and-quality routing decisions and tool-authorization decisions is more likely to under-serve one of the two.

Reassess default configuration options after any vendor upgrade. LiteLLM's own release changed two defaults, classifier context window and session affinity, in a way that silently changes both quality and spend for any deployment that never set those fields explicitly — a reminder that gateway defaults are load-bearing [2].

## Evidence and Limits

The primary sources here are vendor blog posts and vendor product documentation: Databricks announcing general availability of Unity AI Gateway [1], LiteLLM publishing its own benchmark methodology and results for its Auto Router [2], and OpenRouter describing its Ori Eval product [3]. Each carries the limits inherent to vendor self-reporting: Databricks' customer quotations and adoption figures (over a quadrillion tokens processed) are vendor-supplied claims not independently audited here [1]; LiteLLM's benchmark, while unusually transparent about methodology, sample sizes (5,600 classifier calls, 4,684 cache switch-backs), and confidence intervals, was run by the vendor on its own product across three datasets and one classifier model, so the specific percentages describe that setup rather than a general law [2]; OpenRouter's illustrative evaluation table is a product demonstration rather than an independently run comparison [3].

Two sources are secondary reporting from AlphaSignal, summarizing announcements or research it did not conduct: the Artificial Analysis Endpoint Accuracy Index findings [4] and the Google Cloud API Gateway routing feature [5]. The accuracy index numbers should be attributed to Artificial Analysis's methodology, and the specific percentage findings for GLM-5.2, gpt-oss-120b, and DeepSeek V4 Pro are as reported secondhand; the underlying methodology page is cited but not independently reviewed in depth here. The Google Cloud feature description is likewise a secondhand summary of a vendor announcement, and its stated limitations (same-host backends only, text modality only, no VPC Service Controls) come from that same secondary source.

No source in this set provides a controlled, independently audited comparison of gateway platforms against each other, and none demonstrates a causal link between adopting a control-plane gateway and a specific business outcome such as reduced incident rate or improved margin; what is available is vendor-reported adoption and satisfaction, a vendor's own benchmark of one routing mechanism, and one newly launched third-party accuracy benchmark reported secondhand. Readers should treat the thesis of this article as an interpretation of a consistent directional signal across five sources published within days of each other, not as a settled architectural conclusion.

## References

1. Databricks. "Unity AI Gateway is Generally Available." https://www.databricks.com/blog/unity-ai-gateway-generally-available
2. LiteLLM. "Auto Router v1.97: usage benchmarks and better quality for lower cost." https://docs.litellm.ai/blog/auto-router-context-and-benchmarks
3. OpenRouter. "Ori Eval: Prove the Best Model for What You're Building." https://openrouter.ai/blog/announcements/ori-eval/
4. AlphaSignal. "Artificial Analysis Exposes How API Providers Quietly Degrade Model Accuracy." https://alphasignal.ai/news/artificial-analysis-exposes-how-api-providers-quietly-degrade-model-accuracy
5. AlphaSignal. "Google Cloud API Gateway Ships Serverless Multi-Model Routing for Gemini and Claude." https://alphasignal.ai/news/google-cloud-api-gateway-ships-serverless-multi-model-routing-for-gemini-and
