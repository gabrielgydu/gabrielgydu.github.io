#!/usr/bin/env bash
# Switch the live English home page between content variants.
#
#   variants/switch.sh vector    # the Vector-focused page (while that thread is live)
#   variants/switch.sh default   # the broad payments page (back to the general search)
#   variants/switch.sh --status  # which variant index.html currently matches
#
# Only index.html is swapped; de/index.html, the CV sources and the PDFs are untouched.
# The script never commits or pushes: review `git diff`, then commit and push yourself
# (GitHub Pages builds master). `variants/` is excluded from the Jekyll build, so the
# inactive variant is never served.
set -euo pipefail
cd "$(dirname "$0")/.."

status() {
  for v in variants/*/; do
    v="${v%/}"; name="${v#variants/}"
    if cmp -s "$v/index.html" index.html; then echo "index.html = $name"; return 0; fi
  done
  echo "index.html matches no variant (edited by hand? copy it back into variants/<name>/ first)"
  return 1
}

case "${1:-}" in
  --status|"") status ;;
  *)
    src="variants/$1/index.html"
    [[ -f "$src" ]] || { echo "no such variant: $1 (have: $(ls variants | grep -v switch.sh | tr '\n' ' '))"; exit 1; }
    cp "$src" index.html
    echo "index.html <- $1"
    git --no-pager diff --stat -- index.html
    echo "next: review, then  git commit -am 'site: switch home page to $1' && git push"
    ;;
esac
