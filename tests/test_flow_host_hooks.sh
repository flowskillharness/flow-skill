#!/usr/bin/env bash
# Permanent boundary regression suite for the host-context adapter
# (skills/flow/adapter-hooks/, ADR-0001 Addendum 2026-10-13).
# Covers the risks that warrant permanence: snapshot persistence contract, strict
# payload parsing, ownership/mode/symlink refusals, output bounds, timeout process-group
# kill (with orphan-scenario evidence), and the no-side-effect guarantees (no telemetry,
# no .flow creation, inherited FLOW_PROJECT_ROOT shielded). NOT a source-text echo suite.
# Run: bash tests/test_flow_host_hooks.sh   (exit 0 = pass)

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
HANDLER="$HERE/../skills/flow/adapter-hooks/flow-context-handler"
REAL_SKILL="$HERE/../skills/flow"
pass=0; fail=0
ok()  { echo "  ok   $1"; pass=$((pass+1)); }
bad() { echo "  FAIL $1"; fail=$((fail+1)); }
check() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (got: $2 | want: $3)"; fi; }
te() { if echo "$2" | grep -q "$3"; then ok "$1"; else bad "$1 (missing '$3')"; fi; }
tne() { if echo "$2" | grep -q "$3"; then bad "$1 (leaked: $3)"; else ok "$1"; fi; }

TMP="$(mktemp -d "${TMPDIR:-/tmp}/flow-hooks-test.XXXXXX")"
TMP="$(cd "$TMP" && pwd -P)"
trap 'rm -rf "$TMP"' EXIT
export FLOW_SKILL_DIR="$REAL_SKILL"

mkproj() {
  d="$TMP/$1"; mkdir -p "$d/flow" "$d/.flow"; chmod 755 "$d/.flow"
  printf '# idea\n' > "$d/flow/00-idea.md"
  printf '%s' "$d"
}

# --- Persistence contract ------------------------------------------------------
P1="$(mkproj persist)"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$P1"}
EOF
) ; rc=$?
check "precompact exit 0" "$rc" "0"
check "precompact stdout empty" "$out" ""
SNAP="$P1/.flow/context-handoff/snapshot.json"
[ -f "$SNAP" ] && ok "snapshot persisted in private dir" || bad "snapshot missing"
mode_of() { python3 -c 'import os,stat,sys;print(oct(stat.S_IMODE(os.stat(sys.argv[1]).st_mode))[2:])' "$1" 2>/dev/null; }
check "snapshot mode 0600" "$(mode_of "$SNAP")" "600"
check "private dir mode 0700" "$(mode_of "$P1/.flow/context-handoff")" "700"
python3 -c "
import json
d = json.load(open('$SNAP'))
assert d.get('magic') == 'flow-compact-handoff/v1'
assert d.get('status_body', '').strip()
" && ok "snapshot strict JSON + magic + body" || bad "snapshot JSON invalid"

# --- SessionStart fresh authority ----------------------------------------------
out=$("$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P1"}
EOF
) ; rc=$?
check "sessionstart exit 0" "$rc" "0"
te "fresh source labeled" "$out" '\[source: fresh'
te "snapshot cited as reference only" "$out" 'pre-compact snapshot: valid'
tne "no stale mislabel on fresh path" "$out" 'STALE SOURCE'

# --- Strict payload parsing ----------------------------------------------------
printf 'not-json{{{' | "$HANDLER" >/dev/null 2>&1; check "malformed JSON fail-open" "$?" "0"
printf '{"hook_event_name":"SessionStart","hook_event_name":"PreCompact","cwd":"%s"}' "$P1" \
  | "$HANDLER" >/dev/null 2>&1; check "duplicate keys rejected fail-open" "$?" "0"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PostToolUse","cwd":"$P1"}
EOF
) ; check "unsupported event exit 0" "$?" "0"; check "unsupported event stdout empty" "$out" ""

# --- Ownership / symlink / mode refusals ---------------------------------------
P2="$(mkproj symlinkflow)"; mv "$P2/.flow" "$TMP/rf2"; ln -s "$TMP/rf2" "$P2/.flow"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$P2"}
EOF
) ; check "symlinked .flow exit 0" "$?" "0"; check "symlinked .flow stdout empty" "$out" ""
[ -L "$P2/.flow" ] && ok "symlink not replaced" || bad ".flow symlink tampered"
P3="$(mkproj laxdir)"; mkdir -p "$P3/.flow/context-handoff"; chmod 755 "$P3/.flow/context-handoff"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$P3"}
EOF
) ; check "non-0700 private dir refused, exit 0" "$?" "0"
[ -f "$P3/.flow/context-handoff/snapshot.json" ] && bad "snapshot written into lax dir" || ok "no snapshot into non-0700 dir"
P4="$(mkproj crossproj)"; mkdir -p "$P4/.flow/context-handoff"; chmod 700 "$P4/.flow/context-handoff"
python3 -c "
import json
json.dump({'magic':'flow-compact-handoff/v1','captured':'t','project':'/somewhere/else','source':'s','status_body':'CROSSPROJ-BODY'}, open('$P4/.flow/context-handoff/snapshot.json','w'))
import os; os.chmod('$P4/.flow/context-handoff/snapshot.json', 0o600)
"
mkdir -p "$TMP/fakefail/runner"; printf '#!/bin/sh\nexit 1\n' > "$TMP/fakefail/runner/flow.sh"; chmod +x "$TMP/fakefail/runner/flow.sh"
out=$(FLOW_SKILL_DIR="$TMP/fakefail" "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P4"}
EOF
) ; rc=$?
check "cross-project refused: exit 0" "$rc" "0"
tne "cross-project body never rehydrated" "$out" "CROSSPROJ-BODY"
tne "cross-project never presented as state" "$out" "STALE SOURCE"
[ -z "$out" ] && ok "cross-project refusal keeps stdout empty" || bad "cross-project refusal leaked stdout"

# --- Bounds ---------------------------------------------------------------------
out=$(FLOW_HOOK_MAX_BYTES=1024 "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P1"}
EOF
) ; rc=$?; blen=$(printf '%s' "$out" | wc -c)
check "min-cap accepted, exit 0" "$rc" "0"
[ "$blen" -le 1024 ] && ok "output within 1024-byte cap ($blen)" || bad "output exceeded cap ($blen)"
SECRET_COMPACT="SENTINEL_SECRET_COMPACT_99999"
"$HANDLER" <<EOF >/dev/null 2>&1
{"hook_event_name":"PreCompact","cwd":"$P1","secret_note":"$SECRET_COMPACT"}
EOF
if [ -f "$P1/.flow/context-handoff/snapshot.json" ]; then
  tne "secret token never leaked into snapshot" "$(cat "$P1/.flow/context-handoff/snapshot.json")" "$SECRET_COMPACT"
else
  bad "snapshot not written during secret leakage test"
fi

SECRET_SESSION="SENTINEL_SECRET_SESSION_88888"
err_out="$TMP/secret.err"
out=$(FLOW_HOOK_MAX_BYTES=200 "$HANDLER" 2>"$err_out" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P1","secret_note":"$SECRET_SESSION"}
EOF
) ; rc=$?
check "below-floor cap falls back to default (exit 0)" "$rc" "0"
te "below-floor cap rejected with note" "$(cat "$err_out")" "out of range"
tne "secret token never echoed in stdout" "$out" "$SECRET_SESSION"
tne "secret token never echoed in stderr" "$(cat "$err_out")" "$SECRET_SESSION"
# --- Timeout: process-group kill with orphan-scenario evidence -------------------
PH="$(mkproj hang)"; mkdir -p "$PH/.flow/context-handoff"; chmod 700 "$PH/.flow/context-handoff"
python3 -c "
import json
json.dump({'magic':'flow-compact-handoff/v1','captured':'t','project':'$PH','source':'s','status_body':'FALLBACK-MARKER'}, open('$PH/.flow/context-handoff/snapshot.json','w'))
import os; os.chmod('$PH/.flow/context-handoff/snapshot.json', 0o600)
"
mkdir -p "$TMP/hanghome/runner"
PIDFILE="$TMP/hanghome/child.pids"
printf '#!/bin/sh\nsleep 30 & echo $! >> "%s"\nwait\n' "$PIDFILE" > "$TMP/hanghome/runner/flow.sh"
chmod +x "$TMP/hanghome/runner/flow.sh"
out=$(FLOW_SKILL_DIR="$TMP/hanghome" FLOW_HOOK_TIMEOUT=3 "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$PH"}
EOF
) ; rc=$?
check "timeout exit 0 (fail-open)" "$rc" "0"
te "stale fallback after timeout" "$out" "STALE SOURCE"
sleep 1
# Owned-PID evidence only: the fake runner recorded ITS OWN child pids in our temp
# pidfile. Observation only: we verify with kill -0 that child pids were reaped by
# the process group kill. No cleanup signal is sent, and no global matching is used.
survivors=0
if [ -s "$PIDFILE" ]; then
  ok "orphan scenario: fake runner recorded its child pid(s) before the kill"
  while read -r pid; do
    [ -n "$pid" ] || continue
    if kill -0 "$pid" 2>/dev/null; then
      survivors=$((survivors + 1))
    fi
  done < "$PIDFILE"
else
  bad "orphan scenario: pidfile empty - owned-pid evidence not collected"
fi
[ "$survivors" -eq 0 ] && ok "orphan scenario: all recorded child pids reaped by group kill (owned-pid evidence)" || bad "orphan scenario: $survivors owned child pid(s) survived"

# --- No-side-effect guarantees ---------------------------------------------------
P5="$(mkproj noflow)"; rmdir "$P5/.flow"
before=$(find "$P5" | sort)
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$P5"}
EOF
) ; check "no-.flow project exit 0" "$?" "0"; check "no-.flow stdout empty" "$out" ""
after=$(find "$P5" | sort)
if [ "$before" = "$after" ]; then ok "no auto-init (filesystem unchanged)"; else printf '%s\n' "$after" > "$TMP/fs.after"; bad "filesystem changed (compare \$before vs \$TMP/fs.after)"; fi
out=$("$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P5"}
EOF
) ; check "sessionstart no-project exit 0" "$?" "0"
[ -f "$P5/.flow/events.jsonl" ] && bad "telemetry written on hook path" || ok "no telemetry (FLOW_LOG_DISABLE honored)"
EXT="$(mkproj ext)"; extb=$(find "$EXT" -type f | sort)
out=$(FLOW_PROJECT_ROOT="$EXT" "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P1"}
EOF
) ; check "inherited FLOW_PROJECT_ROOT ignored, exit 0" "$?" "0"
[ -n "$out" ] && ok "handoff produced for payload project" || bad "handoff empty under inherited root"
exta=$(find "$EXT" -type f | sort)
if [ "$extb" = "$exta" ]; then ok "external project untouched"; else printf '%s\n' "$exta" > "$TMP/ext.after"; bad "external project mutated (compare \$extb vs \$TMP/ext.after)"; fi

# --- Launcher fail-open without python -------------------------------------------
SHIM="$TMP/shim"; mkdir -p "$SHIM"
printf '#!/bin/sh\nexit 127\n' > "$SHIM/python3"; printf '#!/bin/sh\nexit 127\n' > "$SHIM/python"; chmod +x "$SHIM/python3" "$SHIM/python"
out=$(PATH="$SHIM:$PATH" "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$P1"}
EOF
) ; rc=$?
check "no-python launcher exit 0" "$rc" "0"; check "no-python stdout empty" "$out" ""

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
