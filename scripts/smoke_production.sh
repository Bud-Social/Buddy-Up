#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://buddy-up-production.up.railway.app/api/v1}"
TOKEN="${SMOKE_ACCESS_TOKEN:-}"

request() {
  local path="$1"
  local expected="${2:-200}"
  local auth_args=()
  if [[ -n "$TOKEN" ]]; then
    auth_args=(-H "Authorization: Bearer $TOKEN")
  fi
  local out status request_id
  out="$(mktemp)"
  status="$(curl --fail-with-body --silent --show-error --max-time 30 \
    "${auth_args[@]}" -D "${out}.headers" -o "$out" -w '%{http_code}' "$BASE_URL$path" || true)"
  request_id="$(tr -d '\r' < "${out}.headers" | awk -F': ' 'tolower($1)=="x-request-id" {print $2}')"
  if [[ "$status" != "$expected" ]]; then
    echo "SMOKE FAIL path=$path expected=$expected got=$status request_id=${request_id:-none}"
    cat "$out"
    rm -f "$out" "${out}.headers"
    return 1
  fi
  echo "SMOKE OK path=$path status=$status request_id=${request_id:-none}"
  rm -f "$out" "${out}.headers"
}

# Public readiness probe always runs.
request "/health/" 200

if [[ -n "$TOKEN" ]]; then
  request "/feed/?tab=for_you&exclude_post_types=meal" 200
  request "/messaging/conversations/" 200
  request "/analytics/summary/?period=month" 200
  request "/notifications/unread-count/" 200
  request "/profiles/discover/trending/" 200
else
  echo "SMOKE WARNING: SMOKE_ACCESS_TOKEN unset; authenticated probes skipped"
fi
