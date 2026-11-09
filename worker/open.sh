#!/usr/bin/env bash
# Opens what worker/seal.sh encrypted.
# Usage: worker/open.sh <private-key> <sealed-dir> <dest-dir>   → <dest-dir>/out/...
set -euo pipefail

KEY_FILE="${1:?private key file}"
SEALED="${2:?folder with result.tgz.enc and result.key.enc}"
DEST="${3:?destination folder}"
mkdir -p "$DEST"

SEAL_KEY="$(openssl pkeyutl -decrypt -inkey "$KEY_FILE" -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 -in "$SEALED/result.key.enc")"
export SEAL_KEY
openssl enc -d -aes-256-cbc -pbkdf2 -pass env:SEAL_KEY -in "$SEALED/result.tgz.enc" | tar -C "$DEST" -xzf -
echo "opened into $DEST/out"
