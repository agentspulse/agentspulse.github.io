---
layout: article-sky
article_variant: research-review
lang: en
title: "Cordis Spatiotemporal Composability: Revertible Effects, Reactive Coeffects, and Fibers"
seo_title: "Cordis Spatiotemporal Composability Explained"
description: "A practical explanation of Cordis temporal and spatial composability, including revertible effects, reactive coeffects, Fiber lifecycles, and system limits."
keywords: "Cordis spatiotemporal composability, Cordis framework, revertible effects, reactive coeffects, Fiber lifecycle"
tags: [cordis, agent-infrastructure, frontier-research]
categories: [frontier-research]
permalink: /tutorials/cordis-spatiotemporal-composability/
thumbnail: "/images/cordis-spatiotemporal-composability/cordis-three-mechanisms.jpg"
og_image: "/images/cordis-spatiotemporal-composability/cordis-three-mechanisms.jpg"
date: 2026-08-15
last_modified_at: 2026-08-15
author_name: "AgentsPulse Editorial Team"
cover_alt: "Cordis revertible effects, reactive coeffects, and Fiber lifecycle"
cover_width: 1200
cover_height: 675
paper_count: 1
research_scope: "Cordis · Composability · Plugin Lifecycles"
dek: "A practical explanation of Cordis temporal and spatial composability, including revertible effects, reactive coeffects, Fiber lifecycles, and system limits."
key_takeaways:
  - "Temporal composability records inverse effects and unwinds them in reverse order when components unload."
  - "Spatial composability lets dependencies appear, disappear, or change while affected Fibers react to the new topology."
  - "Cordis structures lifecycle cleanup but cannot prove semantic correctness outside the effects registered with its context."
article_toc:
  - id: "the-unload-problem-everyone-has-hit"
    label: "The unload problem everyone has hit"
  - id: "time-and-topology-are-different-axes"
    label: "Time and topology are different axes"
  - id: "revertible-effects-the-runtime-remembers-how-to-undo-you"
    label: "Revertible effects: the runtime remembers how to undo you"
  - id: "reactive-coeffects-dependencies-that-come-and-go"
    label: "Reactive coeffects: dependencies that come and go"
  - id: "the-fiber-lifecycle-in-plain-terms"
    label: "The Fiber lifecycle, in plain terms"
  - id: "putting-it-together-hot-reload-and-configuration-reconciliation"
    label: "Putting it together: hot reload and configuration reconciliation"
  - id: "where-the-guarantee-stops-the-system-boundary"
    label: "Where the guarantee stops: the system boundary"
  - id: "what-the-paper-establishes-and-what-it-leaves-open"
    label: "What the paper establishes, and what it leaves open"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/deepseek-harness-and-cordis-why-everything-is-a-plugin/"
    title: "DeepSeek Harness Architecture"
    description: "How DeepSeek Harness applies Cordis to an everything-is-a-plugin agent runtime."
  - url: "/tutorials/deepseek-harness-vs-pi-agent/"
    title: "DeepSeek Harness vs Pi Agent"
    description: "How Cordis composition differs from a deliberately minimal extension model."
  - url: "/tutorials/agent-framework-harness-runtime-production/"
    title: "The Agent Framework Is Not the Runtime"
    description: "The broader production shift toward dedicated agent execution harnesses."
---
## The unload problem everyone has hit

Anyone who has built a plugin system in a long-running process knows the failure mode: a plugin registers an event listener, opens a resource, or patches some shared state, and then the host application decides to unload it. The plugin's `dispose` function — if it exists at all — removes *some* of what it did, but not all. A listener stays attached to an emitter. A timer keeps firing. A monkey-patched method never gets restored. Over time, repeated load/unload cycles (common during development with hot reload, or in systems that let users toggle plugins at runtime) leave the process in a state that no longer matches any single, coherent configuration. Debugging becomes an exercise in archaeology: which of the last five plugin toggles left this handler behind?

This is not a bug in any one plugin. It is a structural gap: most plugin frameworks give authors a place to write setup code, but only a weak, manually maintained convention for teardown. The Cordis framework, developed within the Koishi ecosystem and described in an August 2026 preprint, treats this gap as the central design problem and proposes a runtime-level answer rather than a documentation-level one.

## Time and topology are different axes

Cordis's contribution starts from separating two concerns that plugin systems usually blur together.

**Temporal composability** asks: if a component is removed, are the effects it registered through the context undone in the correct order? The author still has to pair each effect with a correct inverse; the runtime takes responsibility for tracking and ordering those registered inverses. This is fundamentally a question about *time* — about symmetric entry and exit.

**Spatial composability** asks: when components depend on each other — a logger depends on a config store, a command handler depends on a database connection — how does the dependent react when the thing it depends on appears, disappears, or is replaced? This is a question about *topology* — the shifting graph of who provides what to whom.

Treating these as one undifferentiated "plugin lifecycle" problem is what leads to ad hoc solutions: teardown logic entangled with dependency-checking logic, both handled inconsistently across a codebase. Cordis's paradigm keeps them conceptually separate — revertible effects govern time, reactive coeffects govern topology — while providing a runtime, the Fiber, that ties both together for a given component instance.

![Cordis temporal and spatial composability axes](/images/cordis-spatiotemporal-composability/cordis-composition-axes.jpg)

## Revertible effects: the runtime remembers how to undo you

The mechanism for temporal composability is `ctx.effect`. Instead of writing setup code that produces an ad hoc `dispose` closure, a component author wraps each individual side effect in a call that also supplies its own inverse. The runtime records these inverse operations as they accumulate.

Consider a plugin that attaches a listener to a shared event bus:

```ts
ctx.effect(() => {
  const handler = (msg) => console.log(msg)
  bus.on('message', handler)
  return () => bus.off('message', handler)
})
```

The function passed to `effect` runs immediately and returns its own inverse. Cordis does not inspect *what* the inverse does — it has no way to know whether `bus.off` genuinely cancels `bus.on`. That correctness is an obligation left entirely to the plugin author. What Cordis *does* guarantee is that this inverse will be called, and called in the correct order relative to every other inverse registered by the same component.

That ordering matters. If a component does three things — attaches a listener, opens a resource, then registers a service that further wraps that resource — recovery must reverse them in LIFO order: undo the service registration, then close the resource, then detach the listener. Reversing in forward order would try to close a resource still referenced by the (not-yet-removed) service, and could throw or corrupt state. Cordis's runtime maintains this stack per component and, on removal, walks it backward automatically. The plugin author's job is to declare each effect with its correct inverse; the framework's job is to invoke the registered inverses in LIFO order.

This is the precise, and modest, nature of the guarantee: Cordis proves *completeness and ordering* of invocation. It does not, and cannot, prove *semantic correctness* of the inverse itself. A component author who writes a wrong inverse — one that doesn't actually undo the forward effect — will still see it called at the right time; Cordis has no way to verify that calling it actually restores prior state. That verification burden sits outside the runtime's boundary.

## Reactive coeffects: dependencies that come and go

Spatial composability addresses a different question: what happens when the *availability* of a dependency changes, not because the dependent did anything, but because the provider was unloaded, replaced, or reconfigured?

In Cordis, a component declares what it needs — a coeffect — through an inject/coeffect specification rather than by directly importing or instantiating a provider. The runtime tracks which Fiber currently provides each named dependency and notifies dependents when that provider's status changes.

A concrete example: suppose a logging component depends on a `database` service to persist structured logs. At startup, an in-memory database provider is active, and the logging component receives it and begins writing. Later, an operator swaps in a persistent database provider — perhaps as part of a configuration change or a hot-reloaded plugin. The old provider is deactivated and the new one activates. The logging component does not need to poll for this; it receives a fresh notification that its `database` coeffect is now served by a different provider, and it can re-initialize its client against the new backend without restarting the whole process.

The crucial rule the paper states is that a dependency only counts as *available* while its provider Fiber is in the ACTIVE state. A provider that exists but is still loading, or is in the process of unloading, is not a valid source of the coeffect. This closes a subtle race: a dependent should never be handed a half-initialized or half-torn-down provider and told to proceed as if it were ready.

## The Fiber lifecycle, in plain terms

The Fiber is the unit that makes both of the above mechanisms operational for a given component instance. Conceptually, a Fiber pairs an effect function — the code that runs the component's forward setup, accumulating `ctx.effect` calls — with the inject/coeffect specification that says what it needs and provides.

A Fiber moves through four states: **LOADING**, **ACTIVE**, **UNLOADING**, and **INACTIVE**. LOADING is where the effect function runs and dependencies are checked; only once setup succeeds and required coeffects are present does the Fiber become ACTIVE, at which point it can itself serve as a provider for others. UNLOADING is where recovery happens — the LIFO stack of inverses is walked. INACTIVE is the settled, torn-down state.

An important detail is that these transitions are *inertial*: once a Fiber starts moving from one state to another, it finishes that transition before it will respond to a new external trigger. If a dependency starts flapping — appearing and disappearing rapidly — the Fiber does not try to abort a transition midway to chase the latest state. It completes the current LOADING or UNLOADING pass, then reassesses. This avoids a whole class of interleaving bugs where a partially-initialized component is asked to also partially tear down.

The other detail that matters for correctness is the *ordering of teardown across a dependency edge*. When a provider Fiber begins unloading, its dependents are drained first — they are moved through their own teardown before the provider's own tracked effects are recovered. This is provider-first-notify, dependent-first-teardown: the provider signals "I am going away" but does not actually recover its resources until everything that depended on it has already unwound. This ordering prevents the mirror-image bug of the LIFO effect ordering: a dependent should never find itself running teardown code against a resource the provider has already released.

![Cordis effects, dependencies, and Fiber lifecycle](/images/cordis-spatiotemporal-composability/cordis-three-mechanisms.jpg)

The three mechanisms solve different parts of one operational problem: effects make teardown recoverable, coeffects keep the dependency graph current, and the Fiber orders the transition between usable and inactive states.

## Putting it together: hot reload and configuration reconciliation

The payoff of separating temporal and spatial composability is visible when Cordis handles two practical scenarios.

**Hot module replacement.** When a developer edits a plugin's source and the runtime wants to swap in the new version without restarting the process, it needs to: (1) tear down the old instance completely, using its recorded LIFO effect stack, so no stale listeners or handles survive; (2) notify anything that depended on services the old instance provided, so they can cleanly detach; and (3) bring up the new instance, re-registering effects and re-establishing coeffects, so dependents reconnect to the fresh instance. Revertible effects handle step (1); reactive coeffects handle steps (2) and (3). Without both mechanisms working together, hot reload degrades into "restart the whole process," which is what most plugin systems fall back to.

**Configuration reconciliation.** When a user changes a declarative configuration file — disabling one plugin, changing another's options, adding a third — Cordis can diff the desired state against the running state and issue the minimal set of Fiber transitions needed: unload components no longer in the config (triggering their recovery), reconfigure and possibly reload components whose options changed, and load new ones. Because dependency availability is reactive, a change to a low-level provider's configuration automatically ripples to dependents through coeffect notifications, rather than requiring the whole dependency graph to be manually reloaded.

## Where the guarantee stops: the system boundary

It bears repeating, because it is the most common way this pattern gets over-trusted: Cordis guarantees that registered inverses are invoked, in the right order, relative to other effects and to dependency teardown. It does not guarantee that the *external world* returns to its prior state.

If a component's forward effect sent an email, spawned an external process, wrote a row to an external system without transactional semantics, or made a network call with side effects on a remote service, no inverse the author writes can be verified by Cordis to actually undo that external change — and in many cases, no inverse can undo it at all (an email cannot be unsent). The runtime's guarantee is about the *invocation contract* inside the process; it says nothing about the reversibility of the real-world effects that invocation triggers. Authors are expected to design their forward effects with this boundary in mind — for instance, by making external calls idempotent or by deferring genuinely irreversible actions outside the effect-tracked path — but that design discipline is entirely the author's responsibility, not something the framework can enforce or detect.

## What the paper establishes, and what it leaves open

The August 2026 preprint is explicit that it is a preprint under active revision, not a peer-reviewed final result, and its evidence should be read accordingly.

What it does establish: the paradigm exists, is implemented, and is used in a real, if single, TypeScript ecosystem — Koishi/Cordis. DeepSeek Harness is a separate downstream application of the framework. The paper's evidence is observational: it demonstrates that the paradigm can be built and adopted, and it walks through revertible effects, reactive coeffects, and the Fiber lifecycle as a coherent design.

What it does not establish: any controlled, quantitative comparison against alternative plugin architectures. There is no benchmark showing Cordis-style teardown is faster, more memory-efficient, or less error-prone than manual dispose functions, dependency injection frameworks with lifecycle hooks, or other approaches, because no such baseline comparison has been run. Runtime overhead of tracking effects and coeffects, and any productivity impact on developers, are both explicitly left as future work by the paper's own account.

Who should study this pattern: engineers building long-running, plugin-extensible systems — chat frameworks, editor extension hosts, application servers with hot-swappable modules — who have already felt the pain of incomplete teardown or brittle dependency wiring. It is a useful pattern to study for its conceptual clarity, particularly the separation of "did we undo everything" from "does everyone know what's currently available," even before any quantitative performance claims exist to evaluate. Teams evaluating it should treat the existing implementation and paper as a design reference and existence proof, not as evidence that adopting it will yield measurable gains without their own evaluation in context.

## References

- [Cordis paper repository — August 13, 2026 preprint](https://github.com/cordiverse/paper)
- [Cordis paper PDF](https://github.com/cordiverse/paper/blob/main/paper.pdf)
- [Cordis framework repository](https://github.com/cordiverse/cordis)
- [DeepSeek Harness — a downstream Cordis application](https://github.com/deepseek-ai/deepseek-harness)
