#!/usr/bin/env bash

set -euo pipefail

site_file="_site/index.html"

if [[ ! -f "$site_file" ]]; then
  echo "FAIL: $site_file does not exist"
  exit 1
fi

if ! grep -q "AgentsPulse" "$site_file"; then
  echo "FAIL: AgentsPulse not found in $site_file"
  exit 1
fi

if grep -q "main.css?d41d8cd98f00b204e9800998ecf8427e" "$site_file"; then
  echo "FAIL: homepage references a stale empty digest for main.css"
  exit 1
fi

echo "PASS: homepage contains AgentsPulse and a non-empty CSS cache bust hash"
