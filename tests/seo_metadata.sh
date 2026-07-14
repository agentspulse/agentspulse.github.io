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

if grep -Fq "61.149.12.104" "_site/tutorials/self-evolving-agents-review-en/index.html"; then
  echo "FAIL: internal preview URL leaked into the published article"
  exit 1
fi

if [[ -e "_site/tutorials/self-evolving-agents-review-zh/index.html" ]]; then
  echo "FAIL: Chinese paper should not be published"
  exit 1
fi

echo "PASS: SEO metadata matches expected homepage and article values"
