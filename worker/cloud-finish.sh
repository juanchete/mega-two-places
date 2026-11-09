#!/usr/bin/env bash
# Cloud worker, after submit: saves the submit reply exactly as the tool returned it
# (from this session's own transcript), seals it, and pushes the sealed files to
# branch claude/<job>-result. The repo is public, so only sealed files leave the VM.
# Usage: bash worker/cloud-finish.sh job-1
set -euo pipefail

JOB="${1:?job id}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

T="$(ls -t "$HOME"/.claude/projects/*/*.jsonl 2>/dev/null | head -1 || true)"
[ -n "$T" ] || { echo "no session transcript found under ~/.claude/projects"; exit 1; }

mkdir -p out
cp "$T" "out/$JOB.jsonl"
node worker/extract.mjs "out/$JOB.jsonl" > "out/$JOB.result.json"
node -e 'const r = require(process.argv[1]); console.log(`${r.job} submit calls: ${r.submitCalls}, last reply is error: ${r.lastSubmit?.isError ?? "n/a"}`)' "$ROOT/out/$JOB.result.json"

rm -rf sealed
bash worker/seal.sh sealed

BR="claude/$JOB-result"
git checkout -B "$BR"
git add -f sealed
git -c user.name="two-places worker" -c user.email="worker@users.noreply.github.com" commit -q -m "chore: sealed $JOB result"
git push -f -u origin "$BR" 2>&1 | tail -2
echo "pushed sealed result to $BR"
