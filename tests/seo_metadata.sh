#!/usr/bin/env bash

set -euo pipefail

check_contains() {
  local file="$1"
  local needle="$2"

  if [[ ! -f "$file" ]]; then
    echo "FAIL: missing file $file"
    exit 1
  fi

  if ! grep -Fq "$needle" "$file"; then
    echo "FAIL: expected '$needle' in $file"
    exit 1
  fi
}

check_contains "_site/index.html" "<title>AI Agent Research, Papers &amp; Surveys | AgentsPulse</title>"
check_contains "_site/index.html" "<meta name=\"description\" content=\"Explore AI agent research through clear paper reviews, surveys, and practical explainers on agent evolution, architectures, tool use, evaluation, and safety.\""
check_contains "_site/index.html" "<html lang=\"en\">"
check_contains "_site/index.html" "<h1>AI Agent Research Papers and Surveys</h1>"
check_contains "_site/index.html" "AI Agent Research Digest"
check_contains "_site/index.html" "Search agent research..."
check_contains "_site/index.html" 'href="https://x.com/AgentsPulse"'
check_contains "_site/about/index.html" 'href="https://x.com/AgentsPulse"'
if grep -R -Fq "https://x.com/ai_cat_news" _site --include='*.html'; then
  echo "FAIL: retired X profile remains in generated pages"
  exit 1
fi
if grep -Fq 'href="/blog/"' "_site/index.html"; then
  echo "FAIL: retired Blog page remains in homepage navigation"
  exit 1
fi

if [[ -e "_site/blog/index.html" ]]; then
  echo "FAIL: retired Blog page should not be generated"
  exit 1
fi

check_contains "_site/about/index.html" "<title>AI Agent Research Editorial Process | AgentsPulse</title>"
check_contains "_site/about/index.html" "<html lang=\"en\">"
check_contains "_site/about/index.html" "<h1 id=\"about-title\">AI agent research, read clearly.</h1>"
check_contains "_site/about/index.html" "How a review is built"
check_contains "_site/about/index.html" "Editorial standards"
check_contains "_site/about/index.html" "Corrections and contact"
check_contains "_site/about/index.html" '"@type": "AboutPage"'
check_contains "_site/404.html" "<title>Page Not Found | AgentsPulse</title>"
check_contains "_site/404.html" "<meta name=\"description\" content=\"Return to AgentsPulse to explore frontier AI papers, surveys, and practical explainers across LLMs, agents, reasoning, and benchmarks.\""

check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<title>Self-Evolving Agents: A Review of 8 Key Papers | AgentsPulse</title>"
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<meta name=\"description\" content=\"A self-evolving agents survey of eight key papers, explaining how AI agents improve models, harnesses, and artifacts through feedback and self-play.\""
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<h1>Self-Evolving Agents: Model, Harness, and Artifact Evolution</h1>"
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "aria-label=\"Table of contents\""
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "href=\"https://arxiv.org/abs/2506.13131\""
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<html lang=\"en\">"
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<meta property=\"og:type\" content=\"article\">"
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" '"@type": "Article"'
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" '"inLanguage": "en"'

check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" "<title>Stateful Long-Horizon Agents: 10 Key Papers | AgentsPulse</title>"
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" ">Stateful Long-Horizon Agents: 10 Key Papers</h1>"
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" 'aria-label="Table of contents"'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" 'fetchpriority="high"'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" 'loading="lazy" width="1200" height="671"'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" 'href="/tutorials/self-evolving-agents-review-en/"'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" '<meta name="twitter:card" content="summary_large_image">'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" '"datePublished": "2026-07-20T00:00:00+08:00"'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" '"@type": "BreadcrumbList"'
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "By AgentsPulse Editorial Team"
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" 'href="/tutorials/stateful-long-horizon-agents-review/"'

check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" "<title>Measuring Reward-Seeking in RL Models | AgentsPulse</title>"
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" ">Measuring Reward-Seeking in RL-Trained Models</h1>"
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" 'Research review <span aria-hidden="true">/</span> 1 paper'
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" 'aria-label="Table of contents"'
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" 'loading="lazy" width="1200" height="617"'
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" 'href="https://alignment.openai.com/measuring-reward-seeking/"'
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" 'href="/tutorials/stateful-long-horizon-agents-review/"'
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" 'href="/tutorials/measuring-reward-seeking-contrastive-beliefs/"'

if grep -Fq "61.149.12.104" "_site/tutorials/self-evolving-agents-review-en/index.html"; then
  echo "FAIL: internal preview URL leaked into the published article"
  exit 1
fi

if [[ -e "_site/tutorials/topic-review-stateful-long-horizon-agent-20260720-en/index.html" ]]; then
  echo "FAIL: old long Stateful URL should not be generated"
  exit 1
fi

if [[ -e "_site/tutorials/self-evolving-agents-review-zh/index.html" ]]; then
  echo "FAIL: Chinese paper should not be published"
  exit 1
fi

python3 - <<'PY'
import xml.etree.ElementTree as ET

root = ET.parse("_site/sitemap.xml").getroot()
namespace = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
urls = [node.text for node in root.findall("sm:url/sm:loc", namespace)]
expected = {
    "https://agentspulse.github.io/",
    "https://agentspulse.github.io/tutorials/self-evolving-agents-review-en/",
    "https://agentspulse.github.io/tutorials/stateful-long-horizon-agents-review/",
    "https://agentspulse.github.io/tutorials/measuring-reward-seeking-contrastive-beliefs/",
}
if set(urls) != expected or len(urls) != len(expected):
    raise SystemExit(f"FAIL: sitemap URLs differ from expected canonical set: {urls}")
PY

echo "PASS: SEO metadata matches expected homepage and article values"
