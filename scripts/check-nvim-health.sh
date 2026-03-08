#!/usr/bin/env bash
# scripts/check-nvim-health.sh
# Runs nvim checkhealth headlessly and fails if any ERROR lines are found.
# Designed to run after plugins are already installed (e.g. after Lazy! sync in CI).
# Exits 0 if clean, 1 if any ERROR lines are found.

set -euo pipefail

HEALTH_OUTPUT="/tmp/nvim-health-$$.txt"

cleanup() {
  rm -f "$HEALTH_OUTPUT"
}
trap cleanup EXIT

echo "Running nvim checkhealth (headless)..."

# nvim --headless writes its output via internal screen rendering.
# The trick: open checkhealth buffer, write it to a file, then quit.
# We silence stderr to avoid noise from plugin loading output.
nvim --headless \
  -c "checkhealth" \
  -c "silent! w! $HEALTH_OUTPUT" \
  -c "qa!" \
  2>/dev/null || true

if [ ! -f "$HEALTH_OUTPUT" ]; then
  echo "ERROR: Health output file was not created."
  echo "nvim may have failed to start or the config has a fatal error on load."
  exit 1
fi

echo ""
echo "=== nvim :checkhealth output ==="
# Use strings to handle any binary/control chars nvim may embed in the buffer
strings "$HEALTH_OUTPUT"
echo ""

# Use awk to count matches - always exits 0, safe with set -o pipefail.
# grep -c exits 1 on 0 matches which trips set -e in a pipeline.
error_count=$(LC_ALL=C strings "$HEALTH_OUTPUT" | awk '/ERROR/{c++} END{print c+0}')
warn_count=$(LC_ALL=C strings "$HEALTH_OUTPUT" | awk '/WARNING/{c++} END{print c+0}')
ok_count=$(LC_ALL=C strings "$HEALTH_OUTPUT" | awk '/ OK /{c++} END{print c+0}')

echo "=== Summary ==="
echo "OK:       $ok_count"
echo "WARNINGS: $warn_count"
echo "ERRORS:   $error_count"
echo ""

if [ "$error_count" -gt 0 ]; then
  echo "FAIL: $error_count ERROR line(s) found in nvim health check."
  echo ""
  echo "Failing lines:"
  LC_ALL=C strings "$HEALTH_OUTPUT" | awk '/ERROR/{print}'
  exit 1
fi

echo "PASS: nvim health check completed with no errors."
exit 0
