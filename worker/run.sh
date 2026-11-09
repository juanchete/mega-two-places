#!/usr/bin/env bash
# Runs one headless Claude Code worker for one job.
# Usage: JOB_URL=<job link> worker/run.sh <job-id> <skill-name> [extra line for the prompt]
# Output: out/<job-id>.jsonl (full transcript) and out/<job-id>.result.json (the submit reply, as the tool returned it).
set -euo pipefail

JOB="${1:?job id, e.g. job-1}"
SKILL="${2:?skill name, e.g. incident-lookup}"
EXTRA="${3:-No other input.}"
: "${JOB_URL:?JOB_URL is not set}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/out"
mkdir -p "$OUT"

PROMPT="$(JOB="$JOB" SKILL="$SKILL" EXTRA="$EXTRA" node -e '
  const fs = require("fs");
  const t = fs.readFileSync(process.argv[1], "utf8");
  process.stdout.write(t.replaceAll("{{JOB}}", process.env.JOB).replaceAll("{{SKILL}}", process.env.SKILL).replaceAll("{{EXTRA}}", process.env.EXTRA));
' "$ROOT/worker/prompt.md")"

cd "$ROOT"
claude -p "$PROMPT" \
  --mcp-config "$ROOT/worker/mcp.json" --strict-mcp-config \
  --setting-sources project \
  --append-system-prompt-file "$ROOT/worker/system.md" \
  --allowedTools "mcp__job" "Skill" "ListMcpResourcesTool" "ReadMcpResourceTool" \
  --disallowedTools "Bash" "Write" "Edit" "NotebookEdit" "WebFetch" "WebSearch" "Agent" \
  --output-format stream-json --verbose \
  > "$OUT/$JOB.jsonl"

node "$ROOT/worker/extract.mjs" "$OUT/$JOB.jsonl" > "$OUT/$JOB.result.json"
node -e 'const r = require(process.argv[1]); console.log(`${r.job ?? ""} submit calls: ${r.submitCalls}, last reply is error: ${r.lastSubmit?.isError ?? "n/a"}, final line: ${r.finalLine}`)' "$OUT/$JOB.result.json"
