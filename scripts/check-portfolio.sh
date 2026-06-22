#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

file="index.html"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_fixed() {
  local needle="$1"
  local message="$2"
  if ! grep -Fq "$needle" "$file"; then
    fail "$message"
  fi
}

reject_fixed() {
  local needle="$1"
  local message="$2"
  if grep -Fq "$needle" "$file"; then
    fail "$message"
  fi
}

[[ -f "$file" ]] || fail "Missing index.html"

require_fixed '<h1>Learning Design Portfolio</h1>' "Missing portfolio heading"
require_fixed '<a class="social-link" href="https://github.com/schoedel-learn" target="_blank" rel="noopener noreferrer">' "GitHub footer link is not the exact expected link"
require_fixed '<a class="social-link" href="https://www.linkedin.com/in/barrypschoedel" target="_blank" rel="noopener noreferrer">' "LinkedIn footer link is not the exact expected link"

reject_fixed 'href="#"' "Found placeholder project links"
reject_fixed 'via.placeholder.com' "Found placeholder images"
reject_fixed 'your-actual-' "Found placeholder social profile handles"
reject_fixed '[Insert your 2024-2026 citation here]' "Found inline citation placeholders"
reject_fixed '[Note: Insert the specific 2024-2026 APA citations' "Found references placeholder note"
reject_fixed '<a href="#"' "Found legacy placeholder anchors"
reject_fixed '<img src="https://via.placeholder.com/' "Found old placeholder image tags"

placeholder_count=$(grep -Fc '<div class="portfolio-logo-placeholder" aria-hidden="true">' "$file" || true)
[[ "$placeholder_count" -eq 0 ]] || fail "Expected no non-clickable placeholder panels, found $placeholder_count"

require_fixed '<div class="portfolio-image-stack">' "LearnCAT visual stack wrapper is missing"
require_fixed '<img class="portfolio-logo-image" src="images/LearnCAT-view.png" alt="LearnCAT course page view">' "LearnCAT primary image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/LearnCAT_product_view.png" alt="LearnCAT product view">' "LearnCAT secondary image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/LearnCAT_quiz_view.png" alt="LearnCAT quiz view">' "LearnCAT third image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/carmelito-i.png" alt="Carmelito sign-in screen">' "Carmelito sign-in image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/carmelito-ii.png" alt="Carmelito legislative library screen">' "Carmelito library image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/carmelite_iv.png" alt="Carmelito progress dashboard screen">' "Carmelito dashboard image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/linux-learning-i.png" alt="Linux Terminal Glossary command library screen">' "Linux Learning App image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/cultural-historical-i.png" alt="Pre-Spanish Mesoamerica presentation section on sacrificial ceremonies">' "Heritage first image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/cultural-historical-ii.png" alt="Pre-Spanish Mesoamerica presentation learning content">' "Heritage second image is not using the expected local asset markup"
require_fixed '<img class="portfolio-logo-image" src="images/cultural-historical-iii.png" alt="Pre-Spanish Mesoamerica presentation reference section">' "Heritage third image is not using the expected local asset markup"

if perl -0ne 'exit((/<a\b[^>]*>\s*<div class="portfolio-logo-placeholder" aria-hidden="true">/s) ? 1 : 0)' "$file"; then
  :
else
  fail "Found placeholder panels wrapped in anchors"
fi

printf 'PASS: portfolio launch checks passed\n'
