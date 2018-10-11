#!/usr/bin/env bash
set -euf -o pipefail
openssl aes-256-cbc -K $encrypted_dbe4de280e0d_key -iv $encrypted_dbe4de280e0d_iv -in scripts/codesigning.asc.enc -out scripts/codesigning.asc -d
