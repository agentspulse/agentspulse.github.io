#!/usr/bin/env bash

set -euo pipefail

check_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "FAIL: missing archive page $file"
    exit 1
  fi
}

check_file "_site/tutorials/tag/agents/index.html"
check_file "_site/tutorials/category/frontier-research/index.html"

if ! grep -Fq 'href="https://agentspulse.github.io/tutorials/tag/agents/"' "_site/tutorials/tag/agents/index.html"; then
  echo "FAIL: tutorial tag canonical URL should include a trailing slash"
  exit 1
fi

if ! grep -Fq 'href="https://agentspulse.github.io/tutorials/category/frontier-research/"' "_site/tutorials/category/frontier-research/index.html"; then
  echo "FAIL: tutorial category canonical URL should include a trailing slash"
  exit 1
fi

echo "PASS: tutorial tag and category archive pages exist"
