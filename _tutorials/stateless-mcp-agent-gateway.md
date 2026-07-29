---
layout: article-sky
article_variant: research-review
lang: en
title: "Stateless MCP and the Rise of the Agent Gateway"
seo_title: "Stateless MCP and the Rise of the Agent Gateway"
description: "What MCP 2026-07-28 changes: stateless requests, gateway-centered authorization, per-request versioning, observability, and safer enterprise deployment."
keywords: "stateless MCP, MCP gateway, Model Context Protocol, agent infrastructure, OAuth, agent authorization"
tags: [MCP, agent-infrastructure, gateways, security]
categories: [frontier-research]
permalink: /tutorials/stateless-mcp-agent-gateway/
thumbnail: "/images/stateless-mcp-agent-gateway/figure-1.jpg"
og_image: "/images/stateless-mcp-agent-gateway/figure-1.jpg"
date: 2026-07-29
last_modified_at: 2026-07-29
author_name: "AgentsPulse Editorial Team"
cover_alt: "The engineering iceberg behind an enterprise MCP gateway"
cover_width: 1200
cover_height: 672
paper_count: 4
research_scope: "MCP · Gateways · Authorization"
dek: "Stateless MCP turns agent tools into ordinary HTTPS infrastructure—and makes the gateway the central layer for policy, identity, routing, and audit."
key_takeaways:
  - "Stateless MCP removes protocol sessions and sticky routing, making each tool call a self-contained request."
  - "Gateways become the enforcement point for identity, permissions, caching, tracing, and audit logging."
  - "Per-request version negotiation allows gradual migration, but exposed unauthenticated servers remain a serious risk."
article_toc:
  - id: "tldr"
    label: "TL;DR"
  - id: "the-end-of-mcp-sessions"
    label: "The End of MCP Sessions"
  - id: "routing-caching-and-tracing-without-parsing-the-body"
    label: "Routing, Caching, and Tracing Without Parsing the Body"
  - id: "gateways-as-the-policy-layer"
    label: "Gateways as the Policy Layer"
  - id: "authorization-moves-to-the-gateway"
    label: "Authorization Moves to the Gateway"
  - id: "what-exposure-looks-like-in-the-wild"
    label: "What Exposure Looks Like in the Wild"
  - id: "multi-round-trip-requests-replace-server-push"
    label: "Multi-Round-Trip Requests Replace Server Push"
  - id: "extensions-framework-and-governance-changes"
    label: "Extensions Framework and Governance Changes"
  - id: "incremental-adoption-and-version-negotiation"
    label: "Incremental Adoption and Version Negotiation"
  - id: "what-to-do-now"
    label: "What to Do Now"
  - id: "evidence-and-limits"
    label: "Evidence and Limits"
  - id: "references"
    label: "References"
related_research:
  - url: "/tutorials/ai-agent-internal-access-security-boundary/"
    title: "When AI Agents Get Internal Access"
    description: "Why agent credentials and exposed tooling change the enterprise security boundary."
  - url: "/tutorials/stateful-long-horizon-agents-review/"
    title: "Stateful Long-Horizon Agents: 10 Key Papers"
    description: "How agent systems preserve state, recover from failure, and operate over long horizons."
---
Stateless MCP is not merely a transport cleanup. It changes the deployment unit for agent tools and makes gateways, explicit authorization, session policy, and observability central to enterprise agent infrastructure.

When the Model Context Protocol moved to a stateless core [in the 2026-07-28 specification](https://modelcontextprotocol.io/specification/2026-07-28/), it eliminated the session handshake and sticky routing that had forced every MCP server onto long-lived connections and session stores. Tools became ordinary HTTPS endpoints that run on Lambda, scale behind standard load balancers, and cache like any REST resource. [AWS reports](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that this is "one of the most significant spec releases to date," introducing backward-incompatible changes alongside new governance structures designed to limit future breakage. [Anthropic states](https://claude.com/blog/bringing-mcp-2026-07-28-to-claude) the specification recently surpassed 400 million monthly SDK downloads, a fourfold increase this year, establishing MCP as "the industry standard for connecting AI agents to applications."

The immediate technical outcome is that every tool call now carries its own version, client metadata, and capability flags in a single self-contained request, replacing the initialize-then-call flow. The second-order effect is that agent infrastructure begins to look like API infrastructure—requests route through gateways, permissions are checked against an identity system on every call, audit logs capture who accessed what customer data when, and policies decide which tools a session may invoke before the model ever sees them.

[Wiz Research recently scanned](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) exposed MCP servers and found that approximately 70% returned a full tool catalog to an anonymous caller, 42% returned real data when a tool was executed, and 10% exposed a sensitive backend—including cases where unauthenticated requests reached cloud metadata endpoints and retrieved temporary credentials. Nearly all still ran the original 2024-11-05 protocol version, from before OAuth was added to the specification in March 2025. The pattern Wiz observed was consistent: backend credentials baked into the deployment, a managed cloud endpoint reachable from the Internet by default, and no authentication layer added on top.

<img src="/images/stateless-mcp-agent-gateway/figure-1.jpg" decoding="async" loading="lazy" width="1200" height="672" alt="The engineering iceberg behind an enterprise MCP gateway" />

*Sierra's gateway appears as a single connection point to users, while identity, policy, audit, and service integration remain below the surface.*

## TL;DR

- **Stateless MCP removes protocol sessions and the initialize handshake**, making every tool call a self-contained HTTPS request that scales on ordinary infrastructure without sticky routing or shared session stores. ([AWS](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/))
- **The specification moves authorization, caching, tracing, and error handling into standard HTTP primitives**, surfacing intent in headers (`Mcp-Method`, `Mcp-Name`) and introducing TTL metadata for list results. ([AWS](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/))
- **Gateways become the enforcement point for identity, permissions, session policy, and audit logging** instead of individual MCP servers implementing their own. [Sierra reports](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) that 89% of employees now use its gateway to connect agents to 45 services, with cross-customer access controls and per-tool auditing enforced centrally.
- **Security scanning found widespread exposure**: [Wiz observed](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) that approximately 1 in 6 cloud environments with MCP expose at least one server, 70% of exposed servers return tool catalogs anonymously, and 42% return real data—including cases of hardcoded credentials, unprotected databases, and cloud metadata access.
- **Version negotiation is per-request and multi-version gateways are supported**, allowing gradual migration without a flag day. ([AWS](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/))
- **An extensions framework now separates optional capabilities from the core protocol**, so features like interactive UIs and long-running tasks graduate as versioned, opt-in extensions instead of forcing breaking changes into the base specification. ([Anthropic](https://claude.com/blog/bringing-mcp-2026-07-28-to-claude))

## The End of MCP Sessions

Every MCP interaction before the 2026-07-28 specification began with a stateful handshake. A client issued an `initialize` request, the server responded with its protocol version and capabilities, and the server assigned an `Mcp-Session-Id` that every subsequent request was required to carry. [AWS explains](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "that session pinned the client to the server that issued it," forcing operators to choose between sticky sessions at the load balancer, a shared session store behind the fleet, or both.

The 2026-07-28 specification removes the protocol session entirely. Every request now includes protocol version, client information, and client capabilities inside a `_meta` parameter embedded in the JSON-RPC payload. The handshake is gone; clients that need to learn what a server supports can call the new `server/discover` method at any point, but it is optional. [AWS states](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "a single tool call is fully self-contained. It requires no prior session context and can be routed to any server instance."

Remote MCP servers become ordinary HTTPS endpoints. They run on serverless infrastructure, scale with autoscaling groups, and sit behind standard HTTP load balancers without modification. [Anthropic writes](https://claude.com/blog/bringing-mcp-2026-07-28-to-claude) that "servers can now deploy on serverless and edge infrastructure," simplifying both the build experience and the operational work required to scale adoption.

When a server needs continuity across calls, [AWS recommends](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) following established HTTP patterns: the server returns an opaque identifier as part of a tool result, and the agent threads that identifier through subsequent requests. For example, a shopping-cart service returns `basket_id` in the result of `create_basket`, and the agent passes it to `add_item`. State lives in the application, not the protocol.

## Routing, Caching, and Tracing Without Parsing the Body

In earlier protocol versions, the operation a request performed was buried inside the JSON-RPC body. Load balancers, API gateways, and rate limiters had to parse the payload to determine what method was being called. [AWS observes](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "MCP traffic, in short, did not play well with standard HTTP infrastructure."

The 2026-07-28 specification closes that gap in three ways. First, every request surfaces its intent in standard headers: `Mcp-Method` and `Mcp-Name` travel outside the body, giving intermediaries enough information to route, throttle, and meter at the HTTP layer without inspecting the payload. A server that receives a request where the declared headers contradict the body rejects it with HTTP 400 and error code `-32020`.

Second, responses to list and resource-read operations now include explicit freshness metadata—`ttlMs` and `cacheScope`—borrowed from the semantics of HTTP `Cache-Control`. Clients can cache a `tools/list` response for a known duration and scope without maintaining a persistent connection to watch for invalidations.

Third, the specification reserves the W3C Trace Context keys (`traceparent`, `tracestate`, `baggage`) inside the `_meta` parameter. [AWS states](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "a distributed trace originating in your application can now propagate through the full call chain, from agent to MCP client to gateway to downstream service, and render as a unified span tree in any OpenTelemetry-compatible collector."

These changes make MCP requests look like any other HTTP API call at the network and infrastructure layer. Standard tooling—load balancers, API gateways, CDNs, observability platforms—can route, cache, trace, and meter MCP traffic without protocol-specific logic.

## Gateways as the Policy Layer

Once MCP became stateless, the protocol stopped caring where a request came from or which backend credentials it should use. That responsibility moved to the layer that sits between the agent and the tool: the gateway.

[Sierra reports](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) building an internal MCP gateway that now connects 89% of employees to 45 different services. The gateway solves several problems that would otherwise fall to individual MCP servers or agent developers: aggregating tools from Lambda functions, APIs, and remote MCP servers behind a single endpoint; enforcing authorization and session policies before requests reach backends; and auditing which users accessed what customer data.

<img src="/images/stateless-mcp-agent-gateway/figure-2.jpg" decoding="async" loading="lazy" width="1200" height="885" alt="Sierra MCP Gateway connecting agents to 45 internal services" />

*A gateway decouples the agent interface from the growing set of internal services and their individual authorization models.*

Sierra's gateway enforces cross-customer access controls by analyzing every data access for customer context. When an agent attempts to retrieve information about a customer, the gateway builds a candidate list, uses a fast model to narrow it down, and then uses a slower model to determine the customer (if any) and the sensitivity of the data. If the agent tries to access data about multiple customers in the same session, the request is blocked unless the user has explicitly approved cross-customer access out of band. [Sierra writes](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) that building this system "gave our legal and compliance teams confidence that we could safely roll it out across the company."

The gateway also collapses the distinction between local Lambda functions, remote MCP servers, and direct API access. [Sierra notes](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) that for some workflows, exposing a full-featured MCP server introduced too much overhead: agents spent time discovering hundreds of tools and bloated the context window with large responses. Instead, Sierra exposed the GitHub CLI directly, minting read-only tokens scoped to specific repositories. "We want all write or destructive operations to be tied to user intent and approval," Sierra explains, so the CLI is paired with restricted credentials and used only for read operations.

The gateway's audit log captures what data was accessed, by whom, about which customers, and at what sensitivity level—independently of the backends being called.

[AWS AgentCore Gateway](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) takes a similar approach, aggregating AWS Lambda functions, APIs, and MCP servers behind a managed endpoint. When a gateway supports multiple protocol versions, clients select a version on every request by setting the `MCP-Protocol-Version` header. The gateway serves the request in that version if it appears in `supportedVersions`, or rejects it with HTTP 400 and error code `-32022` along with a list of supported versions. Requests that omit the header default to 2025-03-26. AWS states that "version selection happens per request, not through a one-time handshake," so a dual-version gateway can serve old and new clients simultaneously.

## Authorization Moves to the Gateway

The 2026-07-28 specification tightens authorization by aligning the protocol more closely with production OAuth 2.0 and OpenID Connect deployments. [Anthropic states](https://claude.com/blog/bringing-mcp-2026-07-28-to-claude) that "authorization now aligns with production OAuth 2.0 and OIDC deployments, so MCP servers connect to enterprise identity systems like Entra or Okta without workarounds."

The gateway, not the individual MCP server, becomes the point where identity is checked and credentials are scoped. [AWS writes](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "your gateway's inbound authorization, whether IAM (SigV4) or OAuth/JWT, is unchanged by the protocol version. So are your outbound credential providers. Upgrading the protocol version does not require changing credentials or authorizer configuration."

[Sierra observes](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) that identity splits into two modes: interactive work runs as the user, and scheduled or shared workflows run as service accounts with only the permissions they need. "Interactive work (actively using an agent to accomplish a task, like writing code) should run with a user's identity, permissions, approvals, and audit trail. Anything recurring or shared (scheduled automations, monitoring bots, team workflows) gets a service account, so it carries only the access it needs and doesn't break... when its author changes roles or leaves."

For workflows that access customer data, Sierra added pre-authorized workflows that explicitly declare which customers and tools they are allowed to access before they run, preventing an automation from silently inheriting one person's broad access after that person leaves the team.

| Responsibility | Pre-2026-07-28 | 2026-07-28 |
|----|----|----|
| Protocol-level session | Server issues `Mcp-Session-Id`, client includes it on every request | Removed; no protocol session |
| Identity verification | Typically in the MCP server or backend | Gateway enforces OAuth/OIDC or IAM before forwarding |
| Per-request authorization | Backend checks embedded credentials on each call | Gateway enforces policy, audits access, then forwards |
| Multi-customer access | Enforced inconsistently, if at all | Gateway blocks cross-customer access unless explicitly approved |
| Service account scoping | Manual per-server configuration | Gateway grants least-privilege credentials per workflow |

## What Exposure Looks Like in the Wild

[Wiz Research scanned](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) MCP servers reachable from the public Internet and found that MCP "can be found across 80% of cloud environments." About 1 in 6 of those environments exposed at least one MCP server. Of the exposed servers, approximately 70% returned their full tool catalog to an anonymous caller, 42% returned real data when a tool was called, and 10% exposed a sensitive backend. A small but confirmed share was vulnerable to server-side request forgery against the cloud metadata endpoint, returning temporary credentials.

Wiz reports that "nearly all still negotiate the original protocol version (2024-11-05), from before authentication was added to the spec in [March 2025](https://modelcontextprotocol.io/docs/tutorials/security/authorization)." The pattern was consistent: backend credentials baked into the deployment, a managed cloud endpoint that is Internet-reachable by default, and no authentication layer added on top.

Wiz grouped the findings into four problem classes:

**Sensitive-data access** was the most common. Servers in this group proxied tools that reached production databases, internal mailboxes, issue trackers, and regulated records—returning real data to an anonymous caller because the backend credentials were embedded in the deployment. One server exposed a tool that returned a named participant's retirement-account balance with no login. Another proxied an internal issue tracker holding security cases alongside hardcoded credentials. A third handed back an organization's entire application-security program: every scanned component, the findings against each one down to file and line, and which had been written off as false positives. A business-intelligence platform exposed `query_sql` alongside `get_connection_schemas` and `get_connection_table_columns`, letting an anonymous caller enumerate every connected database and run arbitrary queries across them.

**Write and delete access** was the second most common class. These servers exposed tools to create, update, and delete records against CRM, IAM, and infrastructure backends. Wiz did not call them to avoid potentially destructive actions during testing, so the firm cannot confirm every one would execute successfully. The capability was in the catalog for anyone who connected. One IAM backend exposed `add_application`, `update_application`, and `delete_application`. A team-management platform listed `send_blast_message` ("Send a text and/or email message to a group of people") alongside tools to delete rosters and appointments.

**Code execution and server-side network access** were the rarest but arguably most severe. In some cases a tool directly ran commands or evaluated code on the server. In others, the server wrapped a language-model agent that had shell access to the backend—the "tool" was really a prompt the agent acted on, and the model was the only thing deciding whether a request was allowed. The same agent could also be aimed at the cloud metadata endpoint: a tool that fetched a URL or proxied a request could reach internal services a caller could never access directly. On a small but confirmed number of hosts, Wiz reached the instance metadata service and received temporary credentials. Wiz reports that one agent refused a blunt request for secrets but carried out the same action once it was described as routine maintenance.

**Direct secret exposure** was the most straightforward class. Some tools handed back credentials or connection strings outright, with no agent or pivot needed. In one case, Lambda function logs retrieved through `cloudwatch_get_lambda_logs` contained environment variables with API keys. In another, a tool's response included a database connection string with embedded credentials.

[Wiz notes](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) that "a malicious call to one of these servers looks nearly identical to a legitimate one. The server makes the same backend request with the same embedded credential it always uses, and the backend answers an authorized, well-formed request without complaint. No failed login attempt, no denied-access spike indicative of a brute-force attack, and therefore no alert."

## Multi-Round-Trip Requests Replace Server Push

In stateful MCP, servers could initiate requests back to the client—prompting the user for confirmation, asking for filesystem access, or invoking the client's model for a completion. These server-initiated requests traveled over a long-lived server-sent events stream held open between client and server.

The 2026-07-28 specification replaces that with multi-round-trip requests. [AWS explains](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "server-initiated requests are now only permitted while the server is actively processing a client request." When a server needs additional input—a confirmation, a filesystem path, a model completion—it embeds the question in an `InputRequiredResult` and externalizes state through an opaque `requestState` token, rather than pushing a question over a persistent stream. The client collects the user's answers and reissues the original call with the responses and the `requestState`. Everything the server needs is in the payload, so any server instance can pick up the retry.

Only tools that declare elicitation or sampling inputs trigger the multi-round-trip exchange, and only when the client advertises support for it. Progress notifications and log delivery are now request-scoped. [AWS states](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "the gateway relays progress updates only when the client supplies a progress token on the originating request, and delivers log messages only when the client sets `io.modelcontextprotocol/logLevel` in per-request metadata."

## Extensions Framework and Governance Changes

Until the 2026-07-28 specification, MCP extensions were an informal concept with no governance behind them. The specification now introduces a formal extensions framework that allows capabilities to mature on their own timelines without forcing breaking changes into the core protocol. Each extension carries a reverse-DNS identifier, is negotiated through an `extensions` map in client and server capabilities, lives in a dedicated repository under delegated maintainers, and follows its own release cadence. [AWS notes](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "clients and servers that do not negotiate a given extension are unaffected."

[Anthropic reports](https://claude.com/blog/bringing-mcp-2026-07-28-to-claude) that MCP Apps and Tasks now ship under this versioned extensions framework, "giving developers a formal path to add capabilities like interactive UIs and long-running work without changing the core protocol."

The specification also introduces a feature lifecycle policy. Three core features are deprecated: Roots, Sampling, and Logging. [AWS states](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "these deprecations are advisory. The methods, types, and capability flags remain functional in this release and in any specification version published within twelve months of it. However, we highly recommend that new implementations not take a dependency on them."

Roots is replaced by tool parameters, resource URIs, or server configuration. Sampling is replaced by direct integration with LLM provider APIs. Logging is replaced by `stderr` for stdio transports and OpenTelemetry for structured observability.

The broader effect is that the specification now has a path for evolution that does not require breaking existing clients. [AWS writes](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that the 2026-07-28 release "is designed to be the last revision that breaks compatibility."

## Incremental Adoption and Version Negotiation

The 2026-07-28 specification contains backward-incompatible changes, but upgrading is opt-in. [AWS states](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "nothing changes until both you and your clients act." A gateway advertises the protocol versions it speaks through a single `supportedVersions` configuration field. Clients select a version on every request by setting the `MCP-Protocol-Version` header. Adding 2026-07-28 to a gateway that also advertises 2025-11-25 does not change anything for clients that request the older version.

AWS AgentCore Gateway supports 2025-03-26, 2025-06-18, 2025-11-25, and 2026-07-28. Enabling a new version requires a single `UpdateGateway` call that replaces `supportedVersions` with the complete list the gateway should advertise. There is no per-target configuration step; the protocol version is a property of the gateway, not of individual tools. Tool definitions, target configurations, and inbound authentication—IAM, OAuth—remain unchanged.

If a gateway fronts an MCP server target that upgrades to 2026-07-28 before clients do, the gateway translates between versions. [AWS notes](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) that "a `2025-*` client can call ordinary tools on a 2026-07-28 target and receive results in the format it expects, without upgrading." However, this translation does not currently support elicitations and sampling calls from servers to clients. If a client running the 2025 protocol calls a tool on a 2026 server that requires elicitation or sampling, it receives an error.

[Sierra reports](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) that supporting all clients has a cost. "At times development on the gateway reminded us of the early days of web development: just as it was a guessing game as to whether the same HTML would work in both Netscape and Internet Explorer, we would struggle to get the full gateway capabilities working in Pinecone, local coding agents and hosted ones."

## What to Do Now

Add authentication to any MCP server reachable from the Internet. If a server must be public, gate tool execution behind OAuth 2.0, OIDC, or IAM even if the tool catalog remains open. [Wiz recommends](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) auditing "which MCP servers are Internet-reachable and whether they require authentication." If OAuth is not an option, limit the permissions of the MCP server's backend credentials to prevent anonymous access to sensitive data or destructive actions.

Scope backend credentials for MCP servers to the minimum required. [Wiz states](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) that you should "treat an MCP server's role like any other privileged service account: adhere to the principle of least privilege and scope its backend credentials to the bare minimum it needs to function." Do not bake production database connection strings, API tokens, or cloud credentials into a deployment that is accessible without authentication.

Capture agent prompts and enable invocation logs. For servers that wrap language-model agents with shell access or URL-fetching capabilities, prompts and invocation logs are the only place an attack leaves a useful trace. The network telemetry will show an authorized, well-formed request that the backend answered without complaint.

Decide whether your clients and gateways are ready to support the 2026-07-28 specification. Check that the MCP client SDKs your agent frameworks and host applications use have shipped 2026-07-28 support. Tier 1 SDKs were expected to ship during the ten-week release candidate window. Test clients that support 2026-07-28 before advertising it on a production gateway.

Audit for code that depends on removed or changed behavior. [AWS recommends](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) checking for protocol sessions used to carry application state, calls to `logging/setLevel`, client code matching the literal `-32002` error code, and any dependence on Roots, Sampling, or Logging. If your tools use elicitation or sampling, confirm your clients declare the matching capability. A client that omits it will be rejected with error code `-32021`.

If you operate a gateway, add 2026-07-28 to `supportedVersions` alongside your existing versions, migrate clients at your own pace, and only after all clients request the new version, remove the older versions from the list. Version selection happens per request, so a dual-version gateway serves old and new clients simultaneously.

## Evidence and Limits

This article synthesizes four sources: blog posts from [Anthropic](https://claude.com/blog/bringing-mcp-2026-07-28-to-claude) (July 28, 2026) and [AWS](https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/) (July 28, 2026), an engineering retrospective from [Sierra](https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg) (July 22, 2026), and a security report from [Wiz Research](https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers) (July 28, 2026).

Anthropic and AWS are primary sources for the 2026-07-28 specification changes, the governance enhancements, and the mechanics of version negotiation and gateway operation. Sierra is a primary source for the design decisions, authorization patterns, and operational lessons learned from building and scaling an internal MCP gateway to 89% of employees. Wiz is a primary source for the prevalence and severity of exposed MCP servers, though it does not report sample sizes, scanning methodology, or how "cloud environments" and "exposed" were defined. The "80% of cloud environments" figure and "1 in 6" exposure rate are not accompanied by denominators or confidence intervals.

All four sources were published on or shortly before the 2026-07-28 specification release date. Sierra's post predates the final specification by six days and references the release candidate. Anthropic and AWS were published on the specification release date. Wiz's post was also published on the release date, though the scanning appears to have occurred earlier.

The Anthropic and AWS posts describe changes that are verifiable in the [MCP 2026-07-28 specification](https://modelcontextprotocol.io/specification/2026-07-28/) and [changelog](https://modelcontextprotocol.io/specification/2026-07-28/changelog), though those documents were not provided as sources. The Sierra post is a case study of one organization's implementation and reflects its specific requirements—cross-customer access controls, integration with 45 services, and support for both local and hosted agents—not universal truths about MCP gateways. The Wiz findings describe what was observed during their scan, not the behavior of all MCP servers or the security posture of the protocol itself.

None of the sources provide longitudinal data on adoption rates, breaking-change frequencies, or comparative performance between stateful and stateless deployments. The claim that the 2026-07-28 release "is designed to be the last revision that breaks compatibility" is forward-looking and cannot be verified.

## References

1.  Anthropic. (2026, July 28). MCP 2026-07-28 spec: stateless core, coming to Claude. https://claude.com/blog/bringing-mcp-2026-07-28-to-claude
2.  Amazon Web Services. (2026, July 28). How AgentCore Gateway supports the MCP 2026-07-28 spec. https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/
3.  Sierra. (2026, July 22). Building Sierra's MCP Gateway: An engineering iceberg. https://sierra.ai/blog/building-sierras-mcp-gateway-an-engineering-iceberg
4.  Wiz Research. (2026, July 28). The Security Risks Hiding Behind Exposed MCP Servers. https://www.wiz.io/blog/the-risk-hiding-behind-exposed-mcp-servers
