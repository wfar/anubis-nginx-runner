#!/bin/bash
#
# Gathers and summarizes Anubis' metrics. Data resets when the container restarts.
#
# Usage: ./metrics.sh [--log]
#   --log  write a one-line summary to the system log instead, for cron or a
#          timer. You can read the logs with: `journalctl -t anubis-metrics`

set -euo pipefail

cd "$(dirname "$0")"
source ./anubis.env

if ! metrics="$(curl -fsS --max-time 5 "http://$ANUBIS_METRICS_BIND/metrics" 2>&1)"; then
  message="Cannot reach Anubis metrics at $ANUBIS_METRICS_BIND: $metrics"
  echo "$message" >&2
  if [ "${1:-}" = --log ]; then
    logger -t anubis-metrics "$message"
  fi
  exit 1
fi

# Prints the metric's counts summed by the given labels, largest first:
#   sum_by anubis_policy_results action rule  ->  "ALLOW bot-rule 42"
sum_by() {
  local metric="$1"
  shift
  printf '%s\n' "$metrics" | awk -v metric="$metric" -v labels="$*" '
    function label(name) {
      if (!match($0, name "=\"[^\"]*\"")) return "-"
      return substr($0, RSTART + length(name) + 2, RLENGTH - length(name) - 3)
    }

    index($0, metric "{") == 1 {
      count = split(labels, names, " ")
      key = label(names[1])
      for (i = 2; i <= count; i++) key = key " " label(names[i])
      totals[key] += $NF
    }

    END { for (key in totals) printf "%s %d\n", key, totals[key] }' | sort -k "$(($# + 1))" -nr
}

challenges="$(printf '%s\n' "$metrics" | awk '/^anubis_challenges_issued\{/ { total += $NF } END { printf "%d", total }')"

if [ "${1:-}" = --log ]; then
  logger -t anubis-metrics "challenges=$challenges$(sum_by anubis_policy_results action | awk '{ printf " %s=%s", tolower($1), $2 }')"
  exit 0
fi

started="$(printf '%s\n' "$metrics" | awk '$1 == "process_start_time_seconds" { printf "%d", $2 }')"
uptime=$(($(date +%s) - started))
printf 'Anubis up %dd %dh %dm, %s challenges issued\n' $((uptime / 86400)) $((uptime % 86400 / 3600)) $((uptime % 3600 / 60)) "$challenges"

echo
echo "Challenges by method"
sum_by anubis_challenges_issued method | column -t

echo
echo "Decisions by action and rule"
sum_by anubis_policy_results action rule | column -t
