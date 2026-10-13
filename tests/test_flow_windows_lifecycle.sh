#!/usr/bin/env bash
# Shell runner for Windows lifecycle regression suite
# (skills/flow/adapter-hooks/context_handler.py process containment & gate contract).
# Run: bash tests/test_flow_windows_lifecycle.sh
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
PY="${FLOW_PYTHON:-python3}"
exec "$PY" "$HERE/test_flow_windows_lifecycle.py"
