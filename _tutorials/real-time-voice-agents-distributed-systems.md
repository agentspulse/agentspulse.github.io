---
layout: article-sky
article_variant: research-review
lang: en
title: "Real-Time Voice Agents Are Distributed Systems"
seo_title: "Real-Time Voice Agents Are Distributed Systems"
description: "Why production voice agents are distributed systems: media transport, full-duplex inference, state handoffs, capacity, and audio-aware evaluation."
keywords: "voice agents, real-time AI, WebRTC, GPT-Live, agent infrastructure"
tags: [agent-infrastructure, frontier-research]
categories: [frontier-research]
permalink: /tutorials/real-time-voice-agents-distributed-systems/
thumbnail: "/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_00_architecture.jpg"
og_image: "/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_00_architecture.jpg"
date: 2026-08-05
last_modified_at: 2026-08-05
author_name: "AgentsPulse Editorial Team"
cover_alt: "Real-Time Voice Agents Are Distributed Systems"
cover_width: 1200
cover_height: 685
paper_count: 1
research_scope: "Voice agents · Real-time systems · Evaluation"
dek: "Why production voice agents are distributed systems: media transport, full-duplex inference, state handoffs, capacity, and audio-aware evaluation."
key_takeaways:
  - "Evidence-led analysis of the architecture, operational constraints, and production implications."
  - "Separates vendor-reported results from claims supported by broader evidence."
  - "Focuses on implementation decisions practitioners can evaluate today."
article_toc:
  - id: "tl-dr"
    label: "TL;DR"
  - id: "why-turn-based-thinking-fails-a-continuous-medium"
    label: "Why Turn-Based Thinking Fails a Continuous Medium"
  - id: "transport-is-not-a-neutral-substrate"
    label: "Transport Is Not a Neutral Substrate"
  - id: "table-where-latency-and-failure-actually-originate"
    label: "Table: Where Latency and Failure Actually Originate"
  - id: "streaming-inference-and-the-cost-of-statefulness"
    label: "Streaming Inference and the Cost of Statefulness"
  - id: "asynchronous-delegation-and-the-responsiveness-budget"
    label: "Asynchronous Delegation and the Responsiveness Budget"
  - id: "evaluation-cannot-stop-at-the-transcript"
    label: "Evaluation Cannot Stop at the Transcript"
  - id: "capacity-planning-is-not-gpu-planning"
    label: "Capacity Planning Is Not GPU Planning"
  - id: "the-abstraction-gap-between-platform-and-application-layer"
    label: "The Abstraction Gap Between Platform and Application Layer"
  - id: "what-to-do-now"
    label: "What to Do Now"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/model-gateway-enterprise-ai-control-plane/"
    title: "The Model Gateway Is Becoming the Control Plane"
    description: "How gateway controls shape production inference traffic."
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "Why agent execution needs a dedicated harness."
---
<img src="/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_00_architecture.jpg" decoding="async" loading="lazy" width="1200" height="685" alt="The Real-Time Voice Agent Path" />

*The Real-Time Voice Agent Path.*

In August 2026, OpenAI published a detailed engineering account of how it rebuilt ChatGPT Voice's underlying system to support GPT-Live, its full-duplex voice model family launched a month earlier. The post is unusual for a model-launch cycle: instead of leading with benchmark scores, the authors devote most of the piece to transport handshakes, stateful inference handoffs, and a shadow-traffic rollout that surfaced capacity bottlenecks in components that had nothing to do with GPU throughput ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)). It is a public admission from a frontier lab that voice responsiveness is a systems property, and that its capacity was bounded in places unrelated to model quality.

This matters because the industry's default mental model for voice agents is still "a chat model with a microphone." Product teams evaluate voice agents by testing transcript quality, response coherence, and maybe median response latency in a quiet office on a fast connection. That evaluation regime made sense for cascaded speech-to-text-to-LLM-to-text-to-speech pipelines, where each stage was a discrete, testable unit. It does not describe what actually determines whether a voice agent feels responsive, safe, and usable in production, because responsiveness is emergent behavior across a chain of independent systems: media transport, streaming inference, turn detection, tool execution, state consistency under load, and the user's actual perception of timing under real network conditions.

Evidence for this is now coming from multiple, independent directions: infrastructure vendors describing why transport protocol choice determines whether audio degrades gracefully or catastrophically ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)), evaluation vendors arguing that voice agents need three distinct evaluation dimensions a transcript alone cannot capture ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)), and platform vendors packaging realtime audio as just another modality behind a gateway, convenient for developers but obscuring exactly the distributed-systems complexity this article argues cannot be abstracted away ([Vercel, 2026](https://vercel.com/blog/realtime-voice-agents-on-ai-gateway)). Read together, these sources describe the same object from different vantage points: a voice agent is a distributed system with a human on one end of the network, and every layer between the model and that human's ear can add latency, break turn-taking, or silently corrupt state.

## TL;DR

- OpenAI's GPT-Live architecture separates the "live path" (audio streaming, inference) from an asynchronous delegation path for deeper reasoning and tool use, explicitly to prevent slow backend work from stalling media flow ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)).
- Transport protocol is not an implementation detail: WebSockets inherit TCP head-of-line blocking, which stalls audio on packet loss, while WebRTC's UDP-based RTP transport tolerates loss and includes jitter buffers and media-aware congestion control that TCP-based stacks lack by design ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)).
- OpenAI reports that a shadow-traffic rollout revealed that voice capacity is bounded by CPU-side stream handlers and supporting services, not GPU throughput alone, an operational finding specific to their deployment rather than a general law ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)).
- Evaluating a voice agent purely on transcript quality misses execution failures, outcome failures, and experience failures that only show up in traced, audio-aware evaluation, per LangChain's recommended three-dimension framework ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)).
- Full-duplex architectures like GPT-Live remove the discrete turn-detector from the audio path but introduce new problems: reconciling a continuous audio stream with turn-based downstream systems (UI, analytics, safety) requires a separate segmentation layer with speculative and authoritative views of the conversation ([OpenAI, 2026b](https://openai.com/index/introducing-gpt-live/)).
- Protocol-level optimization compounds with architectural optimization: OpenAI reports reducing WebRTC session startup from six network round trips to one via a proposed protocol change (WARP), plus a pre-negotiation mechanism (Instant Connect), both aimed at removing latency before the model does any work ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)).

## Why Turn-Based Thinking Fails a Continuous Medium

The conceptual error underlying "chat model with audio attached" is treating conversation as a sequence of discrete request-response turns, because that is how text chat works and how most LLM infrastructure is built. OpenAI's account of its own prior architecture is instructive: earlier voice systems, including the original ChatGPT Voice and Advanced Voice Mode, represented each turn as a discrete audio blob passed through a cascade of speech-to-text, LLM, and text-to-speech stages, or later a single speech-to-speech model that still depended on a turn detector to decide when the user had stopped talking ([OpenAI, 2026b](https://openai.com/index/introducing-gpt-live/)). The turn detector's job is inherently ambiguous: guess the end of speech too early and the system cuts the user off; guess too late and the response feels sluggish. Because turn detection is typically based on silence, a mid-sentence pause can be misread as end-of-turn, producing the "rigid back-and-forth" OpenAI's own comparison describes for turn-based systems.

<img src="/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_02_chatgpt-voice-displaying-a-weather-forecast-for-denver-c.jpg" decoding="async" loading="lazy" width="1200" height="675" alt="ChatGPT Voice displaying a weather forecast for Denver, Colorado" />

*ChatGPT Voice displaying a weather forecast for Denver, Colorado.*

GPT-Live's architectural change, per OpenAI's account, is to remove the turn detector from the audio path entirely by making the voice model full-duplex, processing incoming and outgoing audio continuously and making interaction decisions many times per second: whether to speak, keep listening, pause, interrupt, or invoke a tool ([OpenAI, 2026b](https://openai.com/index/introducing-gpt-live/)). This is a legitimate architectural improvement over silence-based turn detection, per OpenAI's description, but it relocates the turn-taking problem rather than eliminating it. Everything downstream of the model — the UI that displays a conversation, the analytics pipeline that logs it, safety systems that need to reason about who said what — still expects discrete, attributable turns. OpenAI describes this reconciliation as a nontrivial engineering problem handled by an application server that infers speaker attribution from partial transcripts and timing signals, maintains a provisional "speculative" view of the conversation revisable as more audio arrives, and only finalizes a message once a speaker has held the floor long enough for attribution to be reliable ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)). Every policy choice here trades freshness against certainty: commit early and the visible history fragments and reorders; wait too long and downstream features lag behind the actual audio.

This is a distributed-systems problem in the literal sense: two representations of the same conversation (speculative and authoritative) must be kept consistent under different latency and correctness requirements, similar to eventual-consistency tradeoffs in database replication. The "chat model with audio" framing erases this problem because it assumes turns already exist as a stable data structure. In a full-duplex system, turns are a derived, probabilistic reconstruction.

## Transport Is Not a Neutral Substrate

A second place where the "chat model with audio" framing breaks down is transport. LiveKit's argument, from its own experience building WebRTC-based infrastructure, is that the choice between WebSockets and WebRTC determines whether packet loss produces an imperceptible gap or an audible stall ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)). WebSockets run over TCP, which guarantees ordered, reliable delivery through retransmission — exactly wrong for live audio: when a packet is lost, TCP's head-of-line blocking means every subsequent packet, even ones that arrived intact, sits unplayed until the lost packet is retransmitted. The user hears silence, then a burst of catch-up audio. LiveKit calls this "devastating" for conversational rhythm, and the mechanism is well-established transport-layer behavior rather than a speculative claim.

WebRTC, in contrast, sends media over UDP via RTP, tolerating loss instead of retransmitting, and pairs that with adaptive jitter buffers, media-aware congestion control (such as Google Congestion Control, which detects one-way delay variation before packet loss occurs), and codec negotiation baked into session setup ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)). These components are not independently swappable: the jitter buffer feeds playout timing, congestion control affects codec bitrate decisions, and echo cancellation must track recently played audio to cancel it from the microphone signal. Reimplementing one from scratch on raw WebSocket bytes means reimplementing all of them — a multi-year effort duplicated by every team that tries, in LiveKit's framing.

OpenAI's own account corroborates this from a different angle. Rather than treating WebRTC as solved, OpenAI's engineers found its connection setup, evolved before protocols like QUIC prioritized round-trip minimization, involves redundant handshakes: separate anti-DoS mechanisms baked into multiple sub-protocols even when unnecessary ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)). Their response was a proposed protocol change, WARP (WebRTC Abridged Roundtrip Protocol), submitted as an IETF draft, that piggybacks the DTLS handshake over ICE, adopts the faster DTLS 1.3 handshake, and pre-negotiates the SCTP and data-channel handshakes. OpenAI reports this reduces media and data startup from six network round trips to one, and states WARP support has been added to libwebrtc and Pion, with other implementations reportedly in progress — a vendor claim about ecosystem adoption not independently verified in this evidence set. They paired this with Instant Connect, which pre-negotiates SDP session parameters outside the critical path so a client can attempt to start a session with a single UDP packet, falling back to standard signaling if the pre-negotiated parameters are stale.

Transport-layer latency is not a fixed cost that model quality can compensate for. It compounds with every other layer in the system, and it is the layer furthest from where most AI teams spend their engineering effort.

## Table: Where Latency and Failure Actually Originate

| Layer | What it does | Failure mode if under-engineered | Evidence |
|---|---|---|---|
| Transport | Moves audio between client and server | Head-of-line blocking stalls playback on packet loss | LiveKit's TCP/UDP comparison ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)) |
| Session startup | Establishes media path before conversation begins | Every added round trip delays first audio | OpenAI's WARP and Instant Connect work ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)) |
| Turn detection / full duplex | Decides when to speak, listen, or interrupt | Silence-based detection misreads pauses as end-of-turn | OpenAI's comparison of cascaded, turn-based, and full-duplex systems ([OpenAI, 2026b](https://openai.com/index/introducing-gpt-live/)) |
| Streaming inference | Keeps the model fed with continuous audio | Model instance handoffs or compaction stall media if not decoupled | OpenAI's seamless-handoff mechanism ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)) |
| Asynchronous delegation | Routes deeper reasoning/tool use off the live path | A slow tool call or backend service delays the conversation if not isolated | OpenAI's delegation architecture ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)) |
| Turn reconstruction | Converts continuous audio into discrete messages for UI/analytics | Fragmented or misordered conversation history | OpenAI's speculative/authoritative view design ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)) |
| Capacity under load | Sustains many concurrent long-lived sessions | Non-GPU components (queues, stream handlers) saturate before GPUs do | OpenAI's shadow-traffic findings ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)) |
| Evaluation | Determines whether the system actually works for users | Transcript-only evaluation misses latency, naturalness, and friction failures | LangChain's execution/outcome/experience framework ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)) |

This table is a synthesis across the sources, not a claim from any single one; each row is attributed to its originating source above.

## Streaming Inference and the Cost of Statefulness

A subtler distributed-systems problem in OpenAI's account concerns statefulness itself. A text chat request is close to stateless from the model's perspective: each API call can, in principle, carry its own context and be served by any available instance. A live voice session cannot work this way: it persists for a long time, its context grows continuously, and the underlying model instances handling it are not fixed for the session's duration, since instances spin up and down with demand ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)).

<img src="/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_01_the-continuous-voice-system-separates-the-live-path-from.jpg" decoding="async" loading="lazy" width="1200" height="960" alt="The continuous voice system separates the live path from asynchronous work" />

*The continuous voice system separates the live path from asynchronous work.*

OpenAI describes two specific problems this creates. First, a session may need to move from one model instance to another mid-conversation for load-balancing or lifecycle reasons; doing so naively would require rebuilding the key-value cache from scratch, causing a stall. Their described solution is to run the new instance in parallel with the old one, prefill it with current session context, run inference against both simultaneously, and cut over once ready — closer to blue-green deployment patterns from web infrastructure than to typical model-serving practice. Second, long conversations eventually exceed the model's context window, and compaction (reducing context to fit) invalidates the KV cache the same way an instance migration would. OpenAI reports treating compaction as another instance of the same handoff mechanism: compact context in the background, prepare a new instance with the compacted context, and switch over without interrupting the ongoing audio stream.

These are presented as production necessities, not hypothetical edge cases, and they exist only because the system holds session state that must be migrated live rather than recomputed cheaply per request. A chat interface with a "regenerate" button does not face this problem, because a stalled regeneration is a bad interaction, not a broken phone call. Voice systems cannot buffer their way out of this the way a text UI can show a loading spinner; the audio stream itself has to keep moving.

## Asynchronous Delegation and the Responsiveness Budget

GPT-Live's other structural feature, per OpenAI's description, is delegating deeper reasoning to a separate frontier model (GPT-5.5 at launch) while the voice model keeps the conversation moving ([OpenAI, 2026b](https://openai.com/index/introducing-gpt-live/)) — decoupling "talking" from "thinking." Vercel's AI Gateway documentation shows a simpler, more common version of a related idea at the application-developer level: a realtime session where the model can emit a tool call mid-reply, the application executes it and returns the result as a client event, and the model folds the answer into what it says next without ending the turn ([Vercel, 2026](https://vercel.com/blog/realtime-voice-agents-on-ai-gateway)). Vercel's documentation describes this at the API level, as a feature exposed through `useRealtime` and server-side VAD configuration, without disclosing the internal engineering required to keep tool latency from becoming audible dead air — that gap is precisely where OpenAI's internal engineering account differs, since OpenAI spends most of its post on exactly the plumbing that keeps this from stalling the conversation.

OpenAI treats the full delegation path — routing, prompt processing, inference, and any tool calls the frontier model makes — as part of what it calls the responsiveness budget, since the voice model can bridge a short gap conversationally but cannot hide an arbitrarily slow response ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)). Their described optimizations include pre-creating and prefilling the frontier model's inference session before delegation is requested, keeping that session warm with stable affinity across the conversation, and tuning reasoning effort, output limits, and tool schemas specifically to reduce time-to-useful-result rather than time-to-final-result. The architectural separation (voice model versus frontier model) only pays off if the plumbing between the two is engineered with the same latency discipline as the audio path itself — otherwise the separation just relocates the stall to the delegation boundary.

OpenAI's own framing is that a slow tool call or backend service can delay its own result but "cannot stall the flow of media" — a design guarantee achieved by putting delegation behind an asynchronous RPC boundary, not an emergent property that happens automatically once you call two models instead of one.

## Evaluation Cannot Stop at the Transcript

If the operational side of the argument is that responsiveness is distributed across many systems, the evaluation side is that transcript-based testing cannot detect failures in most of those systems. LangChain's framework, developed for its LangSmith product, proposes evaluating voice agents across three distinct dimensions — execution, outcome, and experience — arguing these are not interchangeable ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)). An agent can follow every instruction correctly (execution) and still fail the customer because the workflow itself never asked for a required piece of information, such as a timezone confirmation before booking an appointment (outcome). Separately, an agent can succeed on both counts and still produce a poor call if it interrupts aggressively, forces repeated clarification loops, or sounds robotic (experience).

<img src="/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_03_voice-agent-evaluation-spans-execution-outcome-and-exper.jpg" decoding="async" loading="lazy" width="1200" height="675" alt="Voice-agent evaluation spans execution, outcome, and experience" />

*Voice-agent evaluation spans execution, outcome, and experience.*

LangChain's proposed evaluation-method table maps onto this distinction: deterministic code evaluators for explicit, machine-verifiable rules like tool call ordering; LLM judges for narrow semantic questions such as whether a caller's request was resolved; audio-aware LLM judges specifically for properties that only exist in the recording, such as pronunciation, pacing, or overlapping speech; and business-system checks against downstream records like appointment databases or ticket-reopen rates. LangChain is explicit that a transcript-only judge cannot reliably assess whether an agent "sounded" clear or friendly, only whether the words themselves read that way — a claim about the limits of text-based evaluation for audio-native failure modes, not a benchmark result.

This maps directly onto the architectural material above. Latency, one of LangChain's experience-dimension metrics, is not a single number; it decomposes into voice activity detection, speech-to-text, model time-to-first-token, tool latency, and text-to-speech latency, and LangChain recommends measuring each component's P50/P95/P99 separately because the same audible pause can originate from any of them ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)). This is the evaluation-side mirror of OpenAI's shadow-traffic finding that latency compounds across CPU-side stream handlers, network paths, and inference — a team that only measures aggregate response time cannot tell which layer is actually responsible for a regression, on either the build side or the evaluation side.

## Capacity Planning Is Not GPU Planning

One of the more concrete, falsifiable claims in OpenAI's account concerns capacity testing. Before routing real traffic to GPT-Live, OpenAI ran a silent shadow test: a small, gradually increasing share of production ChatGPT Voice sessions were mirrored to the new system in read-only inference mode, while the existing Advanced Voice Mode continued serving users as normal ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)). This is a single-vendor, single-deployment observation, not a generalizable law about voice infrastructure, but the specific failure mode reported is instructive: a supporting component, unspecified beyond being CPU-side rather than GPU-side, saturated earlier than load-test estimates predicted, causing inference requests to accumulate and latency to compound. OpenAI states this changed how the team framed the capacity question, from GPU requests-per-second to "how many concurrent sessions can the system sustain while keeping every frame on schedule" — treating a voice session as a long-lived stateful stream rather than a stream of independent requests.

<img src="/images/real-time-voice-agents-distributed-systems/githubio_voice_agents_04_live-context-handoff.jpg" decoding="async" loading="lazy" width="1200" height="678" alt="Live context handoff between inference servers" />

*A compact session snapshot is prefetched and caught up before the active voice stream moves to another inference server.*

The same shadow test reportedly surfaced problems tied to session duration and lifecycle rather than raw throughput: long-running sessions exposed memory and persistence pressure, reconnects exercised the compaction and state-restoration logic described earlier, and ordinary client disconnects revealed races in shutdown handshakes. OpenAI attributes these to the fact that short load tests do not accumulate state or exercise the service-boundary interactions that only appear over realistic call lengths. This is consistent with, but should not be conflated with, LiveKit's separate argument that multi-region SFU deployment and cross-region latency (LiveKit's calculation of roughly 230–280 ms round-trip time between Singapore and US-East, based on speed-of-light-in-fiber physics and typical routing overhead) is a first-order design constraint for any globally distributed voice system, not an OpenAI-specific finding ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)). OpenAI's own account independently confirms that geography became "a first-order concern" once real traffic exposed startup and streaming delays tied to routing sessions to distant capacity — convergent evidence from an operator's internal report and an infrastructure vendor's protocol-level analysis, even though the two sources describe different systems.

## The Abstraction Gap Between Platform and Application Layer

Vercel's AI Gateway announcement is useful because it represents the opposite instinct from OpenAI's engineering post: it treats realtime audio as one more modality that slots into an existing gateway abstraction alongside text, image, and video, unified under the same provider routing, spend controls, and observability used for ordinary chat completions ([Vercel, 2026](https://vercel.com/blog/realtime-voice-agents-on-ai-gateway)). This is a legitimate and useful product decision for application developers who want to add voice without owning transport infrastructure — the `useRealtime` hook manages the WebSocket connection, microphone capture, and audio playback, and server-side VAD handles turn detection without client-side silence timers, per Vercel's documentation.

But it also illustrates the exact gap this article is arguing about. Vercel's own implementation uses a WebSocket connection between browser and gateway for the realtime session — a reasonable choice for a platform abstraction serving many use cases, but the specific transport LiveKit argues is unsuited to live audio once packet loss enters the picture. This is not necessarily a defect in Vercel's product; the tradeoffs of running realtime audio through a general-purpose gateway versus a dedicated media-optimized transport layer are a legitimate design choice depending on the deployment's tolerance for degraded conditions, and this evidence set does not include a direct benchmark comparing the two. The narrower point is that an abstraction layer that presents "realtime voice" as a drop-in API call, with the same mental model as a text completion, necessarily hides the transport-layer, statefulness, and capacity-planning problems that OpenAI's and LiveKit's posts spend most of their words on. Teams building on such a layer inherit its transport choices whether or not they understand them, and the failure modes described above (stalls on packet loss, latency spikes under concurrent session load) do not announce themselves in a changelog. They show up as a user complaining the agent feels laggy or keeps cutting them off, and tracing that complaint back to its root cause requires the kind of per-component instrumentation LangChain's evaluation framework describes.

## What to Do Now

Teams building or operating voice agents should treat the following as concrete, near-term engineering priorities rather than aspirational goals.

Instrument every layer separately before optimizing any of them. Measure time-to-first-audio, speech-to-text latency, model time-to-first-token, tool latency, and text-to-speech latency as distinct P50/P95/P99 metrics, per LangChain's recommendation, rather than a single aggregate response-time number ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)). A regression in any one of these can look identical to a user but require an entirely different fix.

Choose transport deliberately, and understand what you are giving up. If the audio needs to feel like a live conversation, LiveKit's argument for WebRTC over WebSockets rests on well-documented transport-layer mechanics (head-of-line blocking, jitter buffers, media-aware congestion control) rather than vendor preference, and teams should verify whether their current stack inherits TCP's retransmission behavior for audio before treating latency complaints as a model problem ([LiveKit, 2026](https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents)).

Load-test with session duration and concurrency, not request throughput. OpenAI's reported shadow-test finding — that a supporting CPU-side component saturated before GPU throughput became the bottleneck — is a single deployment's experience, but the underlying principle, that a voice session is a long-lived stream whose failure modes only appear over realistic duration and reconnect patterns, is reasonable to test for independently of any specific vendor's stack ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)).

Separate the live media path from application and business logic architecturally, not just operationally. Whether or not a team adopts full-duplex modeling, the principle that a slow tool call or backend dependency should delay its own result rather than the entire conversation is achievable through explicit RPC boundaries and warmed, session-affine backend connections, per OpenAI's delegation design ([OpenAI, 2026a](https://openai.com/index/continuous-voice-interaction-with-gpt-live/)).

Evaluate on all three of execution, outcome, and experience, using the method suited to each. Deterministic checks for explicit rules, LLM judges for narrow semantic questions, audio-aware judges for properties that exist only in the recording, and downstream business-system checks for ground truth, per LangChain's framework, together give a more complete picture than any single evaluation method alone ([LangChain, 2026](https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience)).

## Evidence and Limits

This article draws on five primary sources, all vendor-published: two OpenAI engineering and product posts describing the GPT-Live system and launch, a LangChain blog post describing its LangSmith evaluation framework, a LiveKit blog post arguing for WebRTC over WebSockets, and a Vercel product announcement for AI Gateway's audio support. All five are the vendors' own accounts of their own systems and products; none is independent third-party testing or academic research, and no source in this evidence set independently verifies another's claims.

Several specific claims should be read with their stated scope. OpenAI's shadow-traffic findings (CPU-side component saturation, geography-driven latency, memory pressure in long sessions) describe a single company's single deployment and should not be generalized as universal properties of all voice-agent infrastructure, though the underlying mechanisms (stateful long-lived sessions behaving differently from stateless request/response load) are plausible in general terms. OpenAI's claims about WARP's adoption in libwebrtc and Pion, and about ongoing work in other WebRTC implementations, are vendor-reported ecosystem claims not independently confirmed here. OpenAI's evaluation results comparing GPT-Live to Advanced Voice Mode on GPQA, BrowseComp, and an internal τ³-Voice Telecom variant are OpenAI's own benchmark reporting, including at least one custom internal evaluation and a customized user model; they are not independently reproduced and should be read as vendor-reported benchmark results rather than third-party findings. LiveKit's cross-region latency calculation (roughly 230–280 ms round-trip between Singapore and US-East) is a physics-based estimate derived from published fiber propagation speeds and stated routing overhead assumptions, not a measured production result. LangChain's evaluation framework is a set of recommendations tied to its own product, LangSmith, and should be read as a methodology proposal rather than an empirical study with reported outcomes.

No source in this evidence set provides a controlled, independent comparison of WebRTC versus WebSocket-based voice agents in production, nor an independent replication of OpenAI's capacity or latency findings. Claims in this article about mechanisms (why TCP head-of-line blocking degrades audio, why stateful inference requires handoff mechanisms) are supported by the technical descriptions in the sources; claims about outcomes specific to one company's deployment are flagged as such throughout.

## References

1. OpenAI. "How we built a realtime system for responsive voice AI in six months." August 3, 2026. https://openai.com/index/continuous-voice-interaction-with-gpt-live/
2. OpenAI. "Introducing GPT-Live." July 8, 2026. https://openai.com/index/introducing-gpt-live/
3. LangChain. "How to Evaluate Voice Agents with LangSmith." August 4, 2026. https://www.langchain.com/blog/how-to-evaluate-voice-agents-execution-outcomes-and-experience
4. LiveKit. "Why WebRTC beats WebSockets for realtime voice AI." March 23, 2026. https://livekit.com/blog/why-webrtc-beats-websockets-for-voice-ai-agents
5. Vercel. "Build realtime voice agents on AI Gateway." June 29, 2026. https://vercel.com/blog/realtime-voice-agents-on-ai-gateway
