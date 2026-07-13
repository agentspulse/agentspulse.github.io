---
layout: design-replica
permalink: /about/
title: "About · AgentsPulse"
description: "About the AgentsPulse digest."
replica_variant: replica-sky
---

{% include sky-nav.liquid active='about' %}

<main class="sky-main">

<header class="sky-header">
<div class="sky-header-row">
<div class="sky-header-copy">
<h1>About</h1>
<p class="sky-sub">What AgentsPulse is and how the digest is built.</p>
</div>
</div>
</header>

<div class="sky-about">
<section class="sky-about-block">
<h2>Mission</h2>
<p>AgentsPulse turns dense frontier-AI papers into readable, structured digests. We track surveys and primary work across large language models, security, reasoning, and training methods, then distill each into an accessible breakdown so practitioners can keep up without reading every preprint end to end.</p>
</section>

<section class="sky-about-block">
<h2>How it works</h2>
<p>Each entry pairs a short editorial summary with the figures and tags that matter. Posts are searchable and filterable by topic, and every digest links back to the source paper so you can go deeper whenever a result is relevant to your work.</p>
</section>

<section class="sky-about-block">
<h2>Coverage</h2>
<div class="sky-about-tags">
<span>LLMs</span>
<span>Security</span>
<span>Surveys</span>
<span>Mid-training</span>
<span>Reasoning</span>
</div>
</section>

<section class="sky-about-block">
<h2>Contact</h2>
<p>Follow along through the links in the header for updates as new digests are published.</p>
</section>
</div>

</main>

<footer class="sky-footer">
<span>© {{ site.time | date: '%Y' }} AgentsPulse</span>
</footer>
