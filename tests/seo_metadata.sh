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
check_contains "_site/index.html" 'aria-label="Sort research articles"'
check_contains "_site/index.html" 'class="sky-sort-btn sky-sort-active" data-sort="popular" aria-pressed="true"'
check_contains "_site/index.html" 'class="sky-sort-btn" data-sort="latest" aria-pressed="false"'
check_contains "_site/index.html" 'data-popular="'
check_contains "_site/index.html" 'data-popular-pinned="1"'
check_contains "_site/index.html" 'data-latest="'
if grep -Fq "Popularity · last 30 days" "_site/index.html"; then
  echo "FAIL: popularity window label should not be visible"
  exit 1
fi
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

# --- P0 enhancement checks for the self-evolving agents survey ---
SEA="_site/tutorials/self-evolving-agents-review-en/index.html"

check_contains "$SEA" '<h2 id="what-are-self-evolving-agents">What Are Self-Evolving Agents?</h2>'
check_contains "$SEA" '<h2 id="papers-at-a-glance">8 Papers at a Glance</h2>'
check_contains "$SEA" '<h2 id="data-and-citation">Data and Citation</h2>'

# target keyword phrases must appear in body copy
check_contains "$SEA" "self-evolving agents survey"
check_contains "$SEA" "self-improving AI agents"
check_contains "$SEA" "self evolution in AI agents"

# comparison table must cover exactly the eight reviewed systems
for paper in AlphaEvolve FARS GEPA EEVEE UI-Mem Alita BoundaryRouter "Absolute Zero"; do
  check_contains "$SEA" "$paper"
done

# downloadable data and citation assets
check_contains "$SEA" 'href="/assets/data/self-evolving-agents-survey.csv"'
check_contains "$SEA" 'href="/assets/bibliography/self-evolving-agents-survey.bib"'
check_contains "$SEA" "Suggested citation"
check_contains "$SEA" "agentspulse2026selfevolving"

for asset in "_site/assets/data/self-evolving-agents-survey.csv" "_site/assets/bibliography/self-evolving-agents-survey.bib"; do
  if [[ ! -s "$asset" ]]; then
    echo "FAIL: missing or empty downloadable asset $asset"
    exit 1
  fi
done

csv_rows=$(($(wc -l < "_site/assets/data/self-evolving-agents-survey.csv") - 1))
if [[ "$csv_rows" -ne 8 ]]; then
  echo "FAIL: comparison CSV should hold 8 paper rows, found $csv_rows"
  exit 1
fi

bib_authors=$(grep -c "^  author " "_site/assets/bibliography/self-evolving-agents-survey.bib")
if [[ "$bib_authors" -ne 8 ]]; then
  echo "FAIL: every BibTeX entry needs an author list, found $bib_authors"
  exit 1
fi

bib_entries=$(grep -c "^@misc{" "_site/assets/bibliography/self-evolving-agents-survey.bib")
if [[ "$bib_entries" -ne 8 ]]; then
  echo "FAIL: BibTeX file should hold 8 entries, found $bib_entries"
  exit 1
fi

# every tutorial card must use a generated multi-figure collage, not a single figure
shopt -s nullglob
built_collages=(_site/images/collages/*-card.jpg)
shopt -u nullglob

tutorial_count=$(ls _tutorials/*.md | wc -l | tr -d ' ')
if [[ "${#built_collages[@]}" -ne "$tutorial_count" ]]; then
  echo "FAIL: expected $tutorial_count card collages, found ${#built_collages[@]}."
  echo "      Collages are generated artifacts. Run: python3 scripts/build_collages.py"
  exit 1
fi

for collage in "${built_collages[@]}"; do
  if [[ ! -s "$collage" ]]; then
    echo "FAIL: empty collage $collage"
    exit 1
  fi
done

collage_cards=$(grep -o 'src="/images/collages/[^"]*-card.jpg"' _site/index.html | sort -u | wc -l | tr -d ' ')
if [[ "$collage_cards" -ne "$tutorial_count" ]]; then
  echo "FAIL: homepage should show $tutorial_count distinct card collages, found $collage_cards"
  exit 1
fi

if grep -q 'sky-card-thumb"><img src="/images/359239/figure-1.jpg"' _site/index.html; then
  echo "FAIL: a card fell back to the single-figure placeholder"
  exit 1
fi

# descriptive internal links pointing at the survey
check_contains "_site/index.html" 'class="sky-featured" href="/tutorials/self-evolving-agents-review-en/"'
check_contains "_site/index.html" "A survey of 8 self-evolving agent systems"
check_contains "_site/index.html" 'class="sky-featured-figures"'
check_contains "_site/index.html" 'src="/images/collages/self-evolving-agents-review-en-featured.jpg"'
check_contains "_site/index.html" "Featured survey"
check_contains "_site/index.html" "Read the survey"
check_contains "_site/tutorials/stateful-long-horizon-agents-review/index.html" '<a href="/tutorials/self-evolving-agents-review-en/">self-evolving agents survey</a>'
check_contains "_site/tutorials/measuring-reward-seeking-contrastive-beliefs/index.html" '<a href="/tutorials/self-evolving-agents-review-en/">self-improving AI agents</a>'

python3 - <<'PY'
import xml.etree.ElementTree as ET

root = ET.parse("_site/sitemap.xml").getroot()
namespace = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
urls = [node.text for node in root.findall("sm:url/sm:loc", namespace)]
from pathlib import Path
import re

expected = {"https://agentspulse.github.io/"}
for source in Path("_tutorials").glob("*.md"):
    text = source.read_text()
    match = re.search(r"^permalink:\s*([^\s]+)", text, re.MULTILINE)
    path = match.group(1) if match else f"/tutorials/{source.stem}/"
    expected.add("https://agentspulse.github.io" + path)
if set(urls) != expected or len(urls) != len(expected):
    raise SystemExit(f"FAIL: sitemap URLs differ from expected canonical set: {urls}")
PY

echo "PASS: SEO metadata matches expected homepage and article values"
