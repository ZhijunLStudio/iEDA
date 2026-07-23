#!/bin/bash
# Canonical AES 13-version batch entry point.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/aes13_flow.py" "$@"
