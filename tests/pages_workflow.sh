#!/usr/bin/env bash

set -euo pipefail

workflow=".github/workflows/pages.yml"

if [[ ! -f "$workflow" ]]; then
  echo "FAIL: missing $workflow"
  exit 1
fi

grep -Fq 'actions/configure-pages' "$workflow" || {
  echo "FAIL: missing configure-pages step"
  exit 1
}

grep -Fq "ruby-version: 3.1" "$workflow" || {
  echo "FAIL: workflow must pin a Ruby version compatible with Gemfile.lock"
  exit 1
}

grep -Fq 'bundle exec jekyll build' "$workflow" || {
  echo "FAIL: missing jekyll build step"
  exit 1
}

grep -Fq 'actions/deploy-pages' "$workflow" || {
  echo "FAIL: missing deploy-pages step"
  exit 1
}

grep -Fq 'scripts/submit_indexnow.py' "$workflow" || {
  echo "FAIL: missing IndexNow notification step"
  exit 1
}

grep -Fq 'https://agentspulse.github.io/indexnow-key.txt' "$workflow" || {
  echo "FAIL: missing public IndexNow key location"
  exit 1
}


grep -Fq 'paths-ignore:' "$workflow" || {
  echo "FAIL: README and docs-only changes should not deploy"
  exit 1
}

grep -Fq -- '- README.md' "$workflow" || {
  echo "FAIL: README-only changes should not deploy"
  exit 1
}

grep -Fq -- '- docs/**' "$workflow" || {
  echo "FAIL: docs-only changes should not deploy"
  exit 1
}

grep -Fq 'scripts/find_changed_urls.py' "$workflow" || {
  echo "FAIL: missing changed public URL detection"
  exit 1
}

grep -Fq -- '--url-file indexnow-urls.txt' "$workflow" || {
  echo "FAIL: IndexNow must submit only changed public URLs"
  exit 1
}

echo "PASS: pages workflow exists and contains required steps"
