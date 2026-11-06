#!/bin/bash
#
# Adds a cron job that runs "metrics.sh --log" every 15 minutes, so the system
# log keeps a history of Anubis' traffic across container restarts.
# Read it with: `journalctl -t anubis-metrics`
#
# Usage: ./metrics-cron.sh [--remove]
#        --remove removes an existing metrics cron job.

set -euo pipefail

cd "$(dirname "$0")"
job="*/15 * * * * '$PWD/metrics.sh' --log"

# Rewrite the crontab without our job first to prevent duplicates.
others="$(crontab -l 2>/dev/null | grep -vF "$PWD/metrics.sh" || true)"

if [ "${1:-}" = --remove ]; then
  printf '%s\n' "$others" | crontab -
  echo "Removed the metrics cron job."
  exit 0
fi

{
  if [ -n "$others" ]; then
    printf '%s\n' "$others"
  fi
  echo "$job"
} | crontab -

echo "Added: $job"
echo "Read the log with: journalctl -t anubis-metrics"
