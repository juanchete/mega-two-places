#!/usr/bin/env bash
# Encrypts out/ so a public run log or artifact shows nothing usable.
# Only the holder of the private key for worker/result.pub.pem can open it (worker/open.sh).
# Usage: worker/seal.sh <dest-dir>   → <dest-dir>/result.tgz.enc and <dest-dir>/result.key.enc
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:?destination folder}"
mkdir -p "$DEST" "$ROOT/out"

SEAL_KEY="$(openssl rand -hex 32)"
[ -n "${GITHUB_ACTIONS:-}" ] && echo "::add-mask::$SEAL_KEY"
export SEAL_KEY

tar -C "$ROOT" -czf - out | openssl enc -aes-256-cbc -pbkdf2 -salt -pass env:SEAL_KEY -out "$DEST/result.tgz.enc"
printf '%s' "$SEAL_KEY" | openssl pkeyutl -encrypt -pubin -inkey "$ROOT/worker/result.pub.pem" \
  -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 -out "$DEST/result.key.enc"

echo "sealed: $(ls "$DEST" | tr '\n' ' ')"
