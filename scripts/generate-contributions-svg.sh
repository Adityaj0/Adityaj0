#!/usr/bin/env bash
set -euo pipefail

USERNAME="Adityaj0"
REPOS=(
  "aws/aws-cdk-cli"
  "ml-explore/mlx"
  "NVIDIA/NemoClaw"
  "lancedb/lancedb"
  "pactus-project/pactus-wallet"
)

format_stars() {
  local n=$1
  if [ "$n" -ge 1000 ]; then
    awk -v n="$n" 'BEGIN { printf "%.1fk", n/1000 }'
  else
    echo "$n"
  fi
}

mkdir -p cards

for repo in "${REPOS[@]}"; do
  name="${repo##*/}"
  slug=$(echo "$name" | tr '[:upper:]' '[:lower:]')

  stars=$(gh repo view "$repo" --json stargazerCount --jq '.stargazerCount')
  stars_fmt=$(format_stars "$stars")

  merged=$(gh search prs --author="$USERNAME" --merged --repo="$repo" --limit 100 --json url --jq 'length')

  cat > "cards/${slug}.svg" <<SVG
<svg width="280" height="110" viewBox="0 0 280 110" xmlns="http://www.w3.org/2000/svg" font-family="Segoe UI, Helvetica, Arial, sans-serif">
  <defs>
    <linearGradient id="grad-${slug}" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#667eea"/>
      <stop offset="1" stop-color="#764ba2"/>
    </linearGradient>
    <linearGradient id="bg-${slug}" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#14141f"/>
      <stop offset="1" stop-color="#1b1b2c"/>
    </linearGradient>
  </defs>
  <rect width="280" height="110" rx="14" fill="url(#bg-${slug})" stroke="url(#grad-${slug})" stroke-width="1.5"/>
  <rect x="0" y="0" width="6" height="110" rx="3" fill="url(#grad-${slug})"/>
  <text x="24" y="38" font-size="19" font-weight="700" fill="#f0f0f5">${name}</text>
  <text x="24" y="66" font-size="14" fill="#a0a0b5">⭐ <tspan font-weight="600" fill="#c9b8f0">${stars_fmt}</tspan></text>
  <text x="24" y="90" font-size="14" fill="#a0a0b5">🔀 <tspan font-weight="600" fill="#c9b8f0">${merged} merged PRs</tspan></text>
</svg>
SVG

  echo "Wrote cards/${slug}.svg ($stars_fmt stars, $merged PRs)"
done

rm -f contributions.svg
