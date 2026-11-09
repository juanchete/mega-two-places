#!/usr/bin/env bash
# Cloud worker: says why the `job` MCP server may be missing, without printing the job link.
set -uo pipefail

if [ -z "${JOB1_URL:-}" ]; then
  echo "JOB1_URL: not set in this cloud environment"
  exit 0
fi
echo "JOB1_URL: set (host $(printf '%s' "$JOB1_URL" | sed -E 's#^https?://([^/]+)/.*#\1#'))"

code=$(curl -s -o /tmp/job-check.body -w '%{http_code}' -X POST "$JOB1_URL" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}')
echo "POST to job link: HTTP $code"
grep -o 'host_not_allowed' /tmp/job-check.body | head -1
