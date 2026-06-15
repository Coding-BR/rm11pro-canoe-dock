#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

printf 'This legacy helper now delegates to build-orangefox-nx809j-local.sh.\n' >&2
exec "$SCRIPT_DIR/build-orangefox-nx809j-local.sh" "$@"
