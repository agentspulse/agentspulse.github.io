#!/usr/bin/env bash
set -euo pipefail

# Figure collages are generated artifacts (git-ignored, rebuilt in CI).
# Refresh popularity when local GA4 credentials are available; otherwise keep
# the checked-in fallback generated for the latest deploy.
python3 scripts/fetch_ga4_popularity.py --days 30

# Regenerate collages locally so the homepage cards are not empty.
python3 scripts/build_collages.py

# Latest follows the most recent git commit touching each article file.
python3 scripts/build_git_order.py

bundle exec jekyll serve --port 4001 --host 0.0.0.0
