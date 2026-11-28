---
layout: article-sky
article_variant: research-review
lang: en
title: "OpenAI Private Inference vs ZDR: What Confidential Computing Covers"
seo_title: "OpenAI Private Inference vs ZDR: What It Covers"
description: "OpenAI Private Inference runs prompts in confidential computing. How it differs from ZDR and Private Safety Processing, what the alpha covers, vs rivals."
keywords: "openai private inference, private inference api, confidential inference anthropic, confidential llm inference, private inference providers, openai zero data retention"
tags: [openai, ai-security, confidential-computing, data-retention, enterprise-ai]
categories: [ai-security]
permalink: /tutorials/openai-private-inference/
thumbnail: "/images/openai-private-inference/cover.jpg"
og_image: "/images/openai-private-inference/cover.jpg"
date: 2026-11-28
last_modified_at: 2026-11-28
author_name: "AgentsPulse Editorial Team"
cover_alt: "OpenAI Private Intelligence diagram: in the customer environment your application sends an encrypted prompt across the network to the OpenAI environment, which runs under Zero Data Retention; the prompt passes real-time safeguards, then Private Inference, labeled confidential computing with strict verifiable controls and API Preview, and the response returns encrypted to the customer"
cover_width: 1600
cover_height: 840
zoomable_images: true
review_eyebrow: "Security explainer"
research_scope: "OpenAI's Private Intelligence product page and Zero Data Retention announcement, the ZDR with Private Safety Processing API guide and technical white paper (October 26, 2026), Sam Altman's and Greg Brockman's November 25 posts, Anthropic's Confidential Inference report and Apple's Private Cloud Compute design, all read November 28, 2026"
scope_note: "Written three days after OpenAI started the alpha. OpenAI has published no API reference, attestation format or eligibility list for Private Inference yet, so scope statements come from its product page and the Private Safety Processing white paper. We have not used Private Inference and found no independent test or substantial community discussion. Cover diagram: OpenAI product page; pipeline diagram: OpenAI API docs."
dek: "OpenAI is testing Private Inference with a small group of business customers: prompts and responses are processed inside hardware-isolated confidential computing designed to keep OpenAI's own operators out. It is layered on top of Zero Data Retention. Here is what each layer protects, what OpenAI's own white paper says the protection does not yet cover, and how the design compares with Anthropic, Apple and Azure."
key_takeaways:
  - "Private Inference protects prompts and responses while the model is processing them, using confidential computing with what OpenAI calls strict verifiable controls. It is an alpha, tested with a small group of customers since November 25, 2026."
  - "Zero Data Retention answers a different question: whether OpenAI keeps your prompts and responses after the request. Private Safety Processing adds misuse detection across requests while keeping ZDR."
  - "OpenAI's October white paper says Private Inference extends operator-access protection and attestation to eligible safety-inference workloads and does not automatically cover the initial API request."
  - "OpenAI offers it only to customers that meet eligibility and capacity requirements, and says it is lining up more compute for a wider rollout without giving a date."
  - "Anthropic has described a similar trusted-loader design but not shipped it as a product; Apple's Private Cloud Compute publishes every production software image for researchers, a level of transparency OpenAI has not announced."
article_toc:
  - id: "how-private-inference-works"
    label: "How Private Inference Works"
  - id: "private-inference-vs-zdr"
    label: "Private Inference vs ZDR and PSP"
  - id: "private-inference-scope"
    label: "What the Alpha Covers"
  - id: "confidential-inference-comparison"
    label: "vs Anthropic, Apple and Azure"
  - id: "private-inference-api-access"
    label: "Access and Evaluation"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/enterprise-frontier-safeguards/"
    title: "Enterprise Frontier Safeguards for Claude"
    description: "Anthropic's answer to the same retention-versus-safety problem, using a bucket in your own cloud account."
  - url: "/tutorials/model-gateway-enterprise-ai-control-plane/"
    title: "Model Gateways as the Enterprise AI Control Plane"
    description: "Where routing, audit and data policy sit when a company calls several model vendors."
  - url: "/tutorials/openai-shirudo/"
    title: "OpenAI Shirudo Architecture"
    description: "Another OpenAI system that relies on signed, TPM-measured code to prove what is running."
---
OpenAI Private Inference keeps a company's prompts and model responses sealed inside hardware-isolated machines while the model works on them, a setup designed to keep OpenAI's own engineers and infrastructure operators from reading them mid-request. Sam Altman said on November 25, 2026 that OpenAI is now testing it "with a small group of customers," and OpenAI's product page lists it as an alpha with an API preview.

The feature targets a gap that OpenAI's existing privacy promise leaves open. Zero Data Retention (ZDR) already means OpenAI does not keep prompts or responses after a request is processed; Private Inference is about the seconds in between, when plaintext has to exist somewhere for the model to read it. Greg Brockman described it as "confidential computing, with strict controls over prompts and responses while they're being processed by a model." OpenAI first previewed it at DevDay 2026 in September as part of an umbrella it calls Private Intelligence.

## How OpenAI Private Inference works: where confidential computing sits {#how-private-inference-works}

OpenAI Private Inference runs the model-processing step inside a trusted execution environment (TEE), a hardware-isolated area whose memory the host operating system, the hypervisor and the people running the servers cannot read. In the diagram at the top of this page, taken from OpenAI's Private Intelligence page, your prompt is encrypted in transit, passes OpenAI's real-time safeguards under Zero Data Retention, and is processed inside that environment before the response travels back encrypted.

OpenAI has not published a Private Inference architecture document yet. The closest description of the "strict verifiable controls" is in the technical white paper for Private Safety Processing, published October 26, 2026, which sets out the confidential-computing controls OpenAI uses for its safety-review runtime:

- **Attestation.** The hardware produces cryptographic evidence of what is running. OpenAI's evidence names a confidential computing enforcement (CCE) policy that fixes the permitted container contents and configuration, and the policy's hash is baked into the attestation.
- **Secure Key Release.** Decryption keys sit in a hardware-backed key vault and are released only when two conditions hold: the workload is authorized, and its attestation matches an approved CCE policy hash. No human access group holds the key-release role.
- **Transparency log.** Each authorized policy is recorded in a tamper-evident log that authorized auditors can inspect, and the runtime refuses to run a reviewer prompt whose hash is missing from the log.

The white paper's glossary names the guarantee that results Zero Operator Access (ZOA): infrastructure operators cannot reach protected customer content on the covered systems. Private Inference is how OpenAI extends that guarantee, in its words "operator access protections and attestation," beyond the safety-review runtime.

## OpenAI Private Inference vs ZDR and Private Safety Processing {#private-inference-vs-zdr}

Zero Data Retention, Private Safety Processing (PSP) and Private Inference each answer a different question about the same API request: what is kept afterwards, how misuse is caught without keeping it, and who can see the plaintext while it is being processed.

| | Zero Data Retention | ZDR with Private Safety Processing | Private Inference |
|---|---|---|---|
| Question it answers | Does OpenAI keep my prompts and responses? | How does OpenAI catch misuse across requests if it keeps nothing? | Who can read my data while the model processes it? |
| What it does | OpenAI does not retain prompts or responses after processing; personnel cannot review them | Selected interactions are encrypted into a bucket in your cloud account for 30 days; an attested runtime reviews them and returns only bounded safety signals | Processing happens inside confidential computing with attestation-gated keys |
| Where data sits | Not retained after the response | Your AWS, Azure, Google Cloud or OCI storage, doubly encrypted with OpenAI's key and your EKM key | In protected memory during processing |
| Status (Nov 28, 2026) | Available for eligible API workflows | Rolling out to API customers in phases since September 22 | Alpha, small group of customers |

The three are layered. ZDR on its own checks each interaction separately, and OpenAI's August announcement says some frontier-model deployments had required customers to let the provider retain content for safety monitoring. PSP was built so ZDR could continue on those models: a classifier referral or sampling policy picks an interaction, the record is encrypted to your bucket, and OpenAI keeps only an index of metadata and a storage reference. If you revoke your EKM authorization, OpenAI can no longer decrypt the records, though they are not deleted. One carve-out applies across all three: images flagged as potential child sexual abuse material are still retained for manual review, because the law requires it.

<img src="/images/openai-private-inference/safety-pipeline.webp" alt="OpenAI Private Safety Processing asynchronous safety pipeline: the safety review scheduler reads the OpenAI metadata index and fetches encrypted safety records from the customer-owned bucket through the customer storage gateway; a hardware-backed key vault performs secure key release to the attested safety review runtime, which decrypts with customer EKM plus OpenAI HPKE, sends safety inference to ZDR inference, and passes only bounded safety signals to safety enforcement; events go to the Compliance API" width="1600" height="714" loading="lazy" decoding="async" data-zoomable title="Click to enlarge" />

*Private Safety Processing's review pipeline. The "safety inference" hop into ZDR inference is the workload the white paper says Private Inference covers first. Diagram: OpenAI, "ZDR with Private Safety Processing," API documentation.*

Anthropic solved the same retention-versus-safety conflict differently with [Enterprise Frontier Safeguards for Claude](/tutorials/enterprise-frontier-safeguards/), which also stores sealed safety data in the customer's bucket but leaves case review to the customer's team. Neither vendor's monitoring layer, by itself, says anything about who can read plaintext during inference, which is the gap Private Inference targets.

<p><strong>While the alpha is closed.</strong> Most teams will not get Private Inference soon, and much prototyping involves no confidential data at all. For that kind of non-sensitive work, a shared gateway such as
<a href="https://www.packyapi.ai/register?aff=5W73&amp;utm_source=agentspulse&amp;utm_medium=affiliate&amp;utm_campaign=openai-private-inference" rel="sponsored nofollow noopener" target="_blank">PackyAPI</a> is one option for calling several vendors' models through one key. A gateway adds another party to the data path, so keep anything covered by ZDR or confidentiality commitments on your direct, contracted endpoint.</p>
<p><small>Disclosure: this page contains an affiliate link. If you sign up through it, we may earn a commission at no extra cost to you.</small></p>

## Private Inference scope: safety inference first, the full API path later {#private-inference-scope}

Per OpenAI's white paper, Private Inference currently extends operator-access protection and attestation to "eligible safety-inference workloads," and it "does not automatically cover the initial API request, which keeps its configured data retention protections, or every OpenAI system." The product page's diagram draws Private Inference around the processing of your prompt; the October white paper describes a narrower starting point.

The reason is in the white paper's boundary section. PSP's review runtime is already sealed off from human access, but the inference path it calls out to, the "safety inference" step in the diagram above, has no inference-wide ZOA guarantee. Private Inference is the optional layer that closes that hop. OpenAI then says it expects to "extend confidential-computing protection beyond the protected safety-inference stack when necessary technology, capacity, and product commitments are met."

Three conditions shape who gets what today:

- **Eligibility and capacity.** The white paper lists "optional Private Inference only for customers that meet the applicable eligibility and capacity requirements." OpenAI has not published those requirements.
- **First-party traffic only.** The white paper covers requests to OpenAI directly. Amazon Bedrock and other third-party distribution of OpenAI models are outside its scope.
- **Compute.** The OpenAI lead for the project, Shekar, called the November test a first step and said the company is lining up more computing power for a much larger rollout, according to The Next Web. No date was given.

The November alpha may already reach further than the October document describes; OpenAI has not said. Until it publishes a Private Inference specification, the safe reading is that the white paper's boundary still applies, and that any contract or security review should ask which hops of your own traffic are covered.

The white paper also flags a limit on the safety side: PSP does not yet cap how much information repeated reviews of the same content can disclose in total, though OpenAI says it plans to add that protection. Teams that already think of agent access in terms of [least privilege and isolation boundaries](/tutorials/ai-agent-internal-access-security-boundary/) will recognize the question: each new hop that sees plaintext is a boundary to audit.

## Private Inference vs Anthropic Confidential Inference, Apple PCC and Azure {#confidential-inference-comparison}

Set against Anthropic's Confidential Inference design, Apple's Private Cloud Compute and Azure's confidential inferencing, OpenAI's alpha is the only one of the four offered on a general-purpose text-model API, and Apple's design goes furthest in letting outsiders verify the claim. The differences come down to how much of the request path sits inside the protected boundary and who can check it.

| | OpenAI Private Inference | Anthropic Confidential Inference | Apple Private Cloud Compute | Azure confidential inferencing |
|---|---|---|---|---|
| Status | Alpha with a small group of API customers (Nov 2026) | Research design published June 2025; Anthropic said it was too early to forecast product features | Design published June 2024 for Apple Intelligence server requests | [Preview announced September 2024](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/azure-ai-confidential-inferencing-preview/4248181) for the Azure OpenAI Whisper model |
| What is protected | Prompts and responses during processing; per the white paper, eligible safety-inference workloads first | User data and model weights at a small trusted loader in front of the accelerator | The whole request on the server node, which keeps no data after responding | Audio prompts and transcripts inside confidential GPU VMs |
| Root of trust | Hardware TEE with attestation-gated key release (details unpublished) | TPM-measured boot; a keyserver releases keys only to attested loaders | Apple silicon servers with Secure Enclave and Secure Boot | AMD SEV-SNP CPUs with NVIDIA H100 confidential computing |
| Outside verification | Tamper-evident log of approved policies, open to authorized auditors (PSP); no public images announced | Exploring keyservers run by other parties | Every production software image published for researchers; devices only send to nodes whose measurements are in a public log | Microsoft says customers can remotely measure and audit the code that processes the data |

Anthropic's report, written with Pattern Labs, is candid about the hard part. It notes that "not all accelerators fully support confidential computing yet" and that sharing encrypted host memory with an accelerator is not well established, so Anthropic would rely on its compute providers for physical and hypervisor security. Its design also leaves the API server, which tokenizes the prompt, outside the scope of what it describes. That is the same kind of boundary OpenAI's white paper draws around the initial API request.

Apple's design sets the bar for verifiability. Its 2024 security post lists five requirements, including "no privileged runtime access" for its own site reliability staff and "verifiable transparency," under which a user's device encrypts each request to the public keys of specific server nodes and only to nodes whose attested software appears in an append-only public log. OpenAI's materials describe attestation and a transparency log for approved policies, but not public software images that researchers can inspect.

For buyers comparing private inference providers, the practical difference is who can check the claim. With Apple, outside researchers can; with OpenAI's alpha, the evidence is attestation that OpenAI's own key vault checks, plus SOC 2 Type 2, ISO and HIPAA or FedRAMP coverage that the Private Intelligence page lists for eligible services. If you route traffic through an internal [model gateway](/tutorials/model-gateway-enterprise-ai-control-plane/), remember that the gateway sees plaintext too, and no vendor-side TEE changes that.

## Private Inference API access: alpha status and how to apply {#private-inference-api-access}

Private Inference API access is by application only. OpenAI runs an interest form where organizations can register for Private Inference, ZDR with Private Safety Processing, or both, and describe their privacy needs and use cases; Altman's post pointed interested companies to Shekar on X. There is no public API reference, pricing or model list for Private Inference yet.

If your organization is weighing it, these are the questions the public documents leave open and a security review should get answered in writing:

1. **Which hops are covered.** Does Private Inference cover the main inference of your own requests, or only the safety-inference workloads the October white paper describes? What happens at the API server that receives and tokenizes the prompt?
2. **What the attestation proves to you.** Can your own systems verify the attestation evidence, or only OpenAI's key vault? Will OpenAI publish the measured software, as Apple does, or only keep policy records for auditors?
3. **Which models and features.** OpenAI has not said whether every model on the API, or tools such as file search and code execution, run inside the protected environment.
4. **How it stacks with what you already run.** Private Inference is layered on top of ZDR, so retention settings, PSP storage in your cloud account and your EKM keys still need to be configured. Organizations that also use Anthropic's models through EFS will be running two different safety architectures side by side.
5. **Capacity and latency.** OpenAI ties availability to confidential-compute capacity it is still securing. Ask whether alpha traffic is rate-limited or routed to separate hardware, and whether response times differ.

Companies with the strictest data rules, the kind that today keep frontier models away from source code, unpublished research or regulated records, are the obvious early users. For them the useful step now is to register, get the eligibility criteria and the covered-path diagram for their own account, and keep sensitive workloads on ZDR with PSP until those answers come back. For what the models behind the API can do once access is settled, see our [GPT-6.2 benchmark review](/tutorials/gpt-6-2-benchmarks/); for OpenAI's approach to gating a sensitive model by customer, see [GPT-6 Cyber access rules](/tutorials/gpt-6-cyber/), and for another OpenAI system built on signed, measured code, the [Shirudo eBPF shield architecture](/tutorials/openai-shirudo/).

## References {#references}

1. OpenAI, ["OpenAI Private Intelligence: Frontier intelligence. Private by design."](https://openai.com/business/private-intelligence/), product page, accessed November 28, 2026.
2. OpenAI, ["Private Safety Processing Overview: Technical White Paper"](https://openaiassets.blob.core.windows.net/$web/pdf/c7284810-2252-462f-803e-075b0c95bccb/psp-whitepaper.pdf), October 26, 2026, and the [ZDR with Private Safety Processing guide](https://developers.openai.com/api/docs/guides/private-safety-processing), OpenAI API documentation, accessed November 28, 2026.
3. OpenAI, ["Offering Zero Data Retention for frontier models"](https://openai.com/index/offering-zero-data-retention-for-frontier-models/), August 19, 2026, updated September 22, 2026; and Sam Altman's [announcement on X](https://x.com/sama/status/2125638790593274259), November 25, 2026.
4. Anthropic, ["Confidential Inference via Trusted Virtual Machines"](https://www.anthropic.com/research/confidential-inference-trusted-vms), June 18, 2025.
5. Apple Security Engineering and Architecture, ["Private Cloud Compute: A new frontier for AI privacy in the cloud"](https://security.apple.com/blog/private-cloud-compute/), June 10, 2024.
