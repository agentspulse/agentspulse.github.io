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

check_contains "_site/tutorials/harnessing-the-power-of-llms-in-practice-a-survey-on-chatgpt-and-beyond/index.html" "<title>Harnessing LLMs in Practice: Guide &amp; Survey | AgentsPulse</title>"
check_contains "_site/tutorials/harnessing-the-power-of-llms-in-practice-a-survey-on-chatgpt-and-beyond/index.html" "<meta name=\"description\" content=\"Learn how LLMs are used in practice across model choice, data, and downstream tasks, with a survey of real-world use cases and tradeoffs.\""
check_contains "_site/tutorials/a-survey-on-llm-mid-training/index.html" "<title>LLM Mid-Training: Data, Methods &amp; Trends | AgentsPulse</title>"
check_contains "_site/tutorials/a-survey-on-llm-mid-training/index.html" "<meta name=\"description\" content=\"Learn how LLM mid-training works across data curation, synthesis, decontamination, and training strategy, with a practical survey of methods and trends.\""
check_contains "_site/tutorials/a-survey-on-large-language-model-llm-security-and-privacy-the-good-the-bad-and-t/index.html" "<title>LLM Security &amp; Privacy: Risks &amp; Defenses | AgentsPulse</title>"
check_contains "_site/tutorials/a-survey-on-large-language-model-llm-security-and-privacy-the-good-the-bad-and-t/index.html" "<meta name=\"description\" content=\"Explore LLM security and privacy research across attacks, defenses, code security, and data protection, with a survey of risks, safeguards, and open issues.\""

echo "PASS: SEO metadata matches expected homepage and article values"
