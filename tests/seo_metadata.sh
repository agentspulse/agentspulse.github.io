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

check_contains "_site/index.html" "<title>AI Research, Frontier Papers &amp; Surveys | AgentsPulse</title>"
check_contains "_site/index.html" "<meta name=\"description\" content=\"Learn frontier AI research through clear paper breakdowns, survey-driven explainers, and practical insights across LLMs, agents, reasoning, and benchmarks.\""
check_contains "_site/404.html" "<title>Page Not Found | AgentsPulse</title>"
check_contains "_site/404.html" "<meta name=\"description\" content=\"Return to AgentsPulse to explore frontier AI papers, surveys, and practical explainers across LLMs, agents, reasoning, and benchmarks.\""

check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<title>Self-evolving Agents Review: 8 Papers | AgentsPulse</title>"
check_contains "_site/tutorials/self-evolving-agents-review-en/index.html" "<meta name=\"description\" content=\"A review of eight self-evolving agent papers, covering artifact-layer refinement, harness-layer adaptation, and model-layer learning without ground-truth ...\""
check_contains "_site/tutorials/self-evolving-agents-review-zh/index.html" "<title>Self-evolving Agents综述：8篇论文讲透Artifact | AgentsPulse</title>"
check_contains "_site/tutorials/self-evolving-agents-review-zh/index.html" "<meta name=\"description\" content=\"系统梳理8篇Self-evolving Agents论文，从Artifact、Harness与Model三层理解智能体如何通过产出迭代、运行时自改与参数更新实现自我演化。\""

echo "PASS: SEO metadata matches expected homepage and article values"
