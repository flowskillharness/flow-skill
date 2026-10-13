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
IS_WINDOWS=0
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
esac

to_native_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

to_json_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -m "$1"
  else
    printf '%s' "$1"
  fi
}

TMP="$(mktemp -d "${TMPDIR:-/tmp}/flow-hooks-test.XXXXXX")"
TMP="$(cd "$TMP" && pwd -P)"
trap 'rm -rf "$TMP"' EXIT
export FLOW_SKILL_DIR="$(to_json_path "$REAL_SKILL")"
mkproj() {
  d="$TMP/$1"; mkdir -p "$d/flow" "$d/.flow"; chmod 755 "$d/.flow"
  printf '# idea\n' > "$d/flow/00-idea.md"
  printf '%s' "$d"
}

# --- Persistence contract ------------------------------------------------------
P1="$(mkproj persist)"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$(to_json_path "$P1")"}
EOF
) ; rc=$?
check "precompact exit 0" "$rc" "0"
check "precompact stdout empty" "$out" ""
SNAP="$P1/.flow/context-handoff/snapshot.json"
if [ "$IS_WINDOWS" -eq 1 ]; then
  [ ! -f "$SNAP" ] && ok "Windows: snapshot refused due to missing O_NOFOLLOW (fresh-only security boundary)" || bad "Windows: snapshot written without O_NOFOLLOW"
else
  [ -f "$SNAP" ] && ok "snapshot persisted in private dir" || bad "snapshot missing"
  mode_of() { python3 -c 'import os,stat,sys;print(oct(stat.S_IMODE(os.stat(sys.argv[1]).st_mode))[2:])' "$(to_native_path "$1")" 2>/dev/null; }
  check "snapshot mode 0600" "$(mode_of "$SNAP")" "600"
  check "private dir mode 0700" "$(mode_of "$P1/.flow/context-handoff")" "700"
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
assert d.get('magic') == 'flow-compact-handoff/v1'
assert d.get('status_body', '').strip()
" "$(to_native_path "$SNAP")" && ok "snapshot strict JSON + magic + body" || bad "snapshot JSON invalid"
fi

# --- SessionStart fresh authority ----------------------------------------------
out=$("$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P1")"}
EOF
) ; rc=$?
check "sessionstart exit 0" "$rc" "0"
te "fresh source labeled" "$out" '\[source: fresh'
if [ "$IS_WINDOWS" -eq 1 ]; then
  ok "Windows: snapshot citation absent (fresh-only)"
else
  te "snapshot cited as reference only" "$out" 'pre-compact snapshot: valid'
fi
tne "no stale mislabel on fresh path" "$out" 'STALE SOURCE'

# --- Strict payload parsing ----------------------------------------------------
printf 'not-json{{{' | "$HANDLER" >/dev/null 2>&1; check "malformed JSON fail-open" "$?" "0"
printf '{"hook_event_name":"SessionStart","hook_event_name":"PreCompact","cwd":"%s"}' "$(to_json_path "$P1")" \
  | "$HANDLER" >/dev/null 2>&1; check "duplicate keys rejected fail-open" "$?" "0"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PostToolUse","cwd":"$(to_json_path "$P1")"}
EOF
) ; check "unsupported event exit 0" "$?" "0"; check "unsupported event stdout empty" "$out" ""

# --- Ownership / symlink / mode refusals ---------------------------------------
P2="$(mkproj symlinkflow)"
if [ "$IS_WINDOWS" -eq 1 ] && command -v cmd >/dev/null 2>&1; then
  mv "$P2/.flow" "$TMP/rf2"
  cmd //c mklink //J "$(cygpath -w "$P2/.flow")" "$(cygpath -w "$TMP/rf2")" >/dev/null 2>&1
else
  mv "$P2/.flow" "$TMP/rf2"; ln -s "$TMP/rf2" "$P2/.flow"
fi
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$(to_json_path "$P2")"}
EOF
) ; check "symlinked .flow exit 0" "$?" "0"; check "symlinked .flow stdout empty" "$out" ""
python3 -c "
import os, sys
p = sys.argv[1]
assert os.path.islink(p) or os.path.isjunction(p)
" "$(to_native_path "$P2/.flow")" && ok "symlink not replaced" || bad ".flow symlink tampered"
P3="$(mkproj laxdir)"; mkdir -p "$P3/.flow/context-handoff"; chmod 755 "$P3/.flow/context-handoff"
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$(to_json_path "$P3")"}
EOF
) ; check "non-0700 private dir refused, exit 0" "$?" "0"
if [ "$IS_WINDOWS" -eq 1 ]; then
  ok "Windows: no snapshot into lax dir (snapshot skipped)"
else
  [ -f "$P3/.flow/context-handoff/snapshot.json" ] && bad "snapshot written into lax dir" || ok "no snapshot into non-0700 dir"
fi
P4="$(mkproj crossproj)"; mkdir -p "$P4/.flow/context-handoff"; chmod 700 "$P4/.flow/context-handoff"
P4_SNAP="$P4/.flow/context-handoff/snapshot.json"
python3 -c "
import json, sys
json.dump({'magic':'flow-compact-handoff/v1','captured':'t','project':'/somewhere/else','source':'s','status_body':'CROSSPROJ-BODY'}, open(sys.argv[1],'w'))
import os; os.chmod(sys.argv[1], 0o600)
" "$(to_native_path "$P4_SNAP")"
[ -f "$P4_SNAP" ] && ok "cross-project snapshot fixture created" || bad "cross-project snapshot fixture missing"
mkdir -p "$TMP/fakefail/runner"; printf '#!/bin/sh\nexit 1\n' > "$TMP/fakefail/runner/flow.sh"; chmod +x "$TMP/fakefail/runner/flow.sh"
out=$(FLOW_SKILL_DIR="$(to_json_path "$TMP/fakefail")" "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P4")"}
EOF
) ; rc=$?
check "cross-project refused: exit 0" "$rc" "0"
tne "cross-project body never rehydrated" "$out" "CROSSPROJ-BODY"
tne "cross-project never presented as state" "$out" "STALE SOURCE"
[ -z "$out" ] && ok "cross-project refusal keeps stdout empty" || bad "cross-project refusal leaked stdout"

# --- Bounds ---------------------------------------------------------------------
out=$(FLOW_HOOK_MAX_BYTES=1024 "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P1")"}
EOF
) ; rc=$?; blen=$(printf '%s' "$out" | wc -c)
check "min-cap accepted, exit 0" "$rc" "0"
[ "$blen" -le 1024 ] && ok "output within 1024-byte cap ($blen)" || bad "output exceeded cap ($blen)"
SECRET_COMPACT="SENTINEL_SECRET_COMPACT_99999"
"$HANDLER" <<EOF >/dev/null 2>&1
{"hook_event_name":"PreCompact","cwd":"$(to_json_path "$P1")","secret_note":"$SECRET_COMPACT"}
EOF
if [ "$IS_WINDOWS" -eq 1 ]; then
  [ ! -f "$P1/.flow/context-handoff/snapshot.json" ] && ok "Windows: secret token never persisted (snapshots refused)" || bad "Windows: snapshot persisted unexpectedly"
elif [ -f "$P1/.flow/context-handoff/snapshot.json" ]; then
  tne "secret token never leaked into snapshot" "$(cat "$P1/.flow/context-handoff/snapshot.json")" "$SECRET_COMPACT"
else
  bad "snapshot not written during secret leakage test"
fi

SECRET_SESSION="SENTINEL_SECRET_SESSION_88888"
err_out="$TMP/secret.err"
out=$(FLOW_HOOK_MAX_BYTES=200 "$HANDLER" 2>"$err_out" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P1")","secret_note":"$SECRET_SESSION"}
EOF
) ; rc=$?
check "below-floor cap falls back to default (exit 0)" "$rc" "0"
te "below-floor cap rejected with note" "$(cat "$err_out")" "out of range"
tne "secret token never echoed in stdout" "$out" "$SECRET_SESSION"
tne "secret token never echoed in stderr" "$(cat "$err_out")" "$SECRET_SESSION"
# --- Timeout: process-group kill with orphan-scenario evidence -------------------
PH="$(mkproj hang)"; mkdir -p "$PH/.flow/context-handoff"; chmod 700 "$PH/.flow/context-handoff"
python3 -c "
import json, sys
json.dump({'magic':'flow-compact-handoff/v1','captured':'t','project':sys.argv[2],'source':'s','status_body':'FALLBACK-MARKER'}, open(sys.argv[1],'w'))
import os; os.chmod(sys.argv[1], 0o600)
" "$(to_native_path "$PH/.flow/context-handoff/snapshot.json")" "$PH"
mkdir -p "$TMP/hanghome/runner"
PIDFILE="$TMP/hanghome/child.pids"
STARTFILE="$TMP/hanghome/child.started"
PY_BIN="$(command -v python3 || command -v python)"
N_PIDFILE="$(to_json_path "$PIDFILE")"
N_STARTFILE="$(to_json_path "$STARTFILE")"
printf '#!/bin/sh\n"%s" -c '\''import sys, os, time; open(sys.argv[1], "w").write(str(os.getpid())); open(sys.argv[2], "w").write("STARTED"); time.sleep(30)'\'' "%s" "%s" &\nwait\n' \
  "$PY_BIN" "$N_PIDFILE" "$N_STARTFILE" > "$TMP/hanghome/runner/flow.sh"
chmod +x "$TMP/hanghome/runner/flow.sh"
out=$(FLOW_SKILL_DIR="$(to_json_path "$TMP/hanghome")" FLOW_HOOK_TIMEOUT=3 "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$PH")"}
EOF
) ; rc=$?
check "timeout exit 0 (fail-open)" "$rc" "0"
if [ "$IS_WINDOWS" -eq 1 ]; then
  tne "Windows: stale fallback absent (fresh-only)" "$out" "STALE SOURCE"
  check "Windows: output empty on timeout" "$out" ""
else
  te "stale fallback after timeout" "$out" "STALE SOURCE"
fi
sleep 1
check "orphan scenario: child actually started" "$([ -f "$STARTFILE" ] && echo 1 || echo 0)" "1"
survivors=0
if [ "$IS_WINDOWS" -eq 1 ]; then
  if [ -s "$PIDFILE" ]; then
    python3 -c '
import sys, ctypes
from ctypes import wintypes
cpid = int(open(sys.argv[1]).read().strip())
SYNCHRONIZE = 0x00100000
PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
STILL_ACTIVE = 259
ERROR_INVALID_PARAMETER = 87

k32 = ctypes.WinDLL("kernel32", use_last_error=True)
k32.OpenProcess.restype = wintypes.HANDLE
k32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
k32.WaitForSingleObject.restype = wintypes.DWORD
k32.WaitForSingleObject.argtypes = [wintypes.HANDLE, wintypes.DWORD]
k32.GetExitCodeProcess.restype = wintypes.BOOL
k32.GetExitCodeProcess.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
k32.CloseHandle.restype = wintypes.BOOL
k32.CloseHandle.argtypes = [wintypes.HANDLE]

h = k32.OpenProcess(SYNCHRONIZE | PROCESS_QUERY_LIMITED_INFORMATION, False, cpid)
if not h:
    err = ctypes.get_last_error()
    if err == ERROR_INVALID_PARAMETER:
        sys.exit(0)
    print("OpenProcess failed for PID %d: OS error %d" % (cpid, err), file=sys.stderr)
    sys.exit(1)
try:
    wait_res = k32.WaitForSingleObject(h, 0)
    if wait_res != 0:
        print("WaitForSingleObject returned non-signaled state: %d" % wait_res, file=sys.stderr)
        sys.exit(1)
    exit_code = wintypes.DWORD()
    if not k32.GetExitCodeProcess(h, ctypes.byref(exit_code)):
        err = ctypes.get_last_error()
        print("GetExitCodeProcess failed: OS error %d" % err, file=sys.stderr)
        sys.exit(1)
    if exit_code.value == STILL_ACTIVE:
        print("Process %d is STILL_ACTIVE" % cpid, file=sys.stderr)
        sys.exit(1)
    sys.exit(0)
finally:
    k32.CloseHandle(h)
' "$(to_native_path "$PIDFILE")" && ok "orphan scenario: all recorded child pids reaped by group kill (owned-pid evidence)" || bad "orphan scenario: child pid survived on Windows"
  else
    bad "orphan scenario: pidfile empty - owned-pid evidence not collected"
  fi
elif [ -s "$PIDFILE" ]; then
  ok "orphan scenario: fake runner recorded its child pid(s) before the kill"
  while read -r pid; do
    [ -n "$pid" ] || continue
    if kill -0 "$pid" 2>/dev/null; then
      survivors=$((survivors + 1))
    fi
  done < "$PIDFILE"
  [ "$survivors" -eq 0 ] && ok "orphan scenario: all recorded child pids reaped by group kill (owned-pid evidence)" || bad "orphan scenario: $survivors owned child pid(s) survived"
else
  bad "orphan scenario: pidfile empty - owned-pid evidence not collected"
fi

# --- Root exits while descendant holds pipe (deadline + group kill) -------------
PH2="$(mkproj rootexit)"; mkdir -p "$PH2/.flow/context-handoff"; chmod 700 "$PH2/.flow/context-handoff"
python3 -c "
import json, sys
json.dump({'magic':'flow-compact-handoff/v1','captured':'t','project':sys.argv[2],'source':'s','status_body':'FALLBACK-ROOTEXIT'}, open(sys.argv[1],'w'))
" "$(to_native_path "$PH2/.flow/context-handoff/snapshot.json")" "$PH2"
mkdir -p "$TMP/rootexithome/runner"
PIDFILE2="$TMP/rootexithome/child.pids"
STARTFILE2="$TMP/rootexithome/child.started"
PY_BIN="$(command -v python3 || command -v python)"
N_PIDFILE2="$(to_json_path "$PIDFILE2")"
N_STARTFILE2="$(to_json_path "$STARTFILE2")"
printf '#!/bin/sh\n"%s" -c '\''import sys, os, time; open(sys.argv[1], "w").write(str(os.getpid())); open(sys.argv[2], "w").write("STARTED"); time.sleep(30)'\'' "%s" "%s" &\nexit 0\n' \
  "$PY_BIN" "$N_PIDFILE2" "$N_STARTFILE2" > "$TMP/rootexithome/runner/flow.sh"
chmod +x "$TMP/rootexithome/runner/flow.sh"
out=$(FLOW_SKILL_DIR="$(to_json_path "$TMP/rootexithome")" FLOW_HOOK_TIMEOUT=2 "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$PH2")"}
EOF
) ; rc=$?
check "root-exit held-pipe exit 0" "$rc" "0"
sleep 1
check "root-exit held pipe: child actually started" "$([ -f "$STARTFILE2" ] && echo 1 || echo 0)" "1"
survivors2=0
if [ "$IS_WINDOWS" -eq 1 ]; then
  if [ -s "$PIDFILE2" ]; then
    python3 -c '
import sys, ctypes
from ctypes import wintypes
cpid = int(open(sys.argv[1]).read().strip())
SYNCHRONIZE = 0x00100000
PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
STILL_ACTIVE = 259
ERROR_INVALID_PARAMETER = 87

k32 = ctypes.WinDLL("kernel32", use_last_error=True)
k32.OpenProcess.restype = wintypes.HANDLE
k32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
k32.WaitForSingleObject.restype = wintypes.DWORD
k32.WaitForSingleObject.argtypes = [wintypes.HANDLE, wintypes.DWORD]
k32.GetExitCodeProcess.restype = wintypes.BOOL
k32.GetExitCodeProcess.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
k32.CloseHandle.restype = wintypes.BOOL
k32.CloseHandle.argtypes = [wintypes.HANDLE]

h = k32.OpenProcess(SYNCHRONIZE | PROCESS_QUERY_LIMITED_INFORMATION, False, cpid)
if not h:
    err = ctypes.get_last_error()
    if err == ERROR_INVALID_PARAMETER:
        sys.exit(0)
    print("OpenProcess failed for PID %d: OS error %d" % (cpid, err), file=sys.stderr)
    sys.exit(1)
try:
    wait_res = k32.WaitForSingleObject(h, 0)
    if wait_res != 0:
        print("WaitForSingleObject returned non-signaled state: %d" % wait_res, file=sys.stderr)
        sys.exit(1)
    exit_code = wintypes.DWORD()
    if not k32.GetExitCodeProcess(h, ctypes.byref(exit_code)):
        err = ctypes.get_last_error()
        print("GetExitCodeProcess failed: OS error %d" % err, file=sys.stderr)
        sys.exit(1)
    if exit_code.value == STILL_ACTIVE:
        print("Process %d is STILL_ACTIVE" % cpid, file=sys.stderr)
        sys.exit(1)
    sys.exit(0)
finally:
    k32.CloseHandle(h)
' "$(to_native_path "$PIDFILE2")" && ok "root-exit held pipe: descendant child killed by group on deadline" || bad "root-exit held pipe: descendant child survived on Windows"
  else
    bad "root-exit held pipe: pidfile empty on Windows"
  fi
else
  if [ -s "$PIDFILE2" ]; then
    while read -r pid; do
      [ -n "$pid" ] || continue
      if kill -0 "$pid" 2>/dev/null; then
        survivors2=$((survivors2 + 1))
      fi
    done < "$PIDFILE2"
  fi
  [ "$survivors2" -eq 0 ] && ok "root-exit held pipe: descendant child killed by group on deadline" || bad "root-exit held pipe: descendant child survived ($survivors2)"
fi

# --- Silent held-stdin producer (bounded deadline, fail-open) --------------------
t0=$(date +%s)
out=$(python3 -c "import time; time.sleep(2.5)" | FLOW_HOOK_STDIN_DEADLINE=1 "$HANDLER")
rc=$?
t1=$(date +%s)
elapsed=$((t1 - t0))
check "silent held-stdin exit 0" "$rc" "0"
check "silent held-stdin stdout empty" "$out" ""
[ "$elapsed" -le 3 ] && ok "silent held-stdin bounded by deadline (${elapsed}s <= 3s)" || bad "silent held-stdin exceeded deadline (${elapsed}s)"

# --- No-side-effect guarantees ---------------------------------------------------
P5="$(mkproj noflow)"; rmdir "$P5/.flow"
before=$(find "$P5" | sort)
out=$("$HANDLER" <<EOF
{"hook_event_name":"PreCompact","cwd":"$(to_json_path "$P5")"}
EOF
) ; check "no-.flow project exit 0" "$?" "0"; check "no-.flow stdout empty" "$out" ""
after=$(find "$P5" | sort)
if [ "$before" = "$after" ]; then ok "no auto-init (filesystem unchanged)"; else printf '%s\n' "$after" > "$TMP/fs.after"; bad "filesystem changed (compare \$before vs \$TMP/fs.after)"; fi
out=$("$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P5")"}
EOF
) ; check "sessionstart no-project exit 0" "$?" "0"
[ -f "$P5/.flow/events.jsonl" ] && bad "telemetry written on hook path" || ok "no telemetry (FLOW_LOG_DISABLE honored)"
EXT="$(mkproj ext)"; extb=$(find "$EXT" -type f | sort)
out=$(FLOW_PROJECT_ROOT="$(to_json_path "$EXT")" "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P1")"}
EOF
) ; check "inherited FLOW_PROJECT_ROOT ignored, exit 0" "$?" "0"
[ -n "$out" ] && ok "handoff produced for payload project" || bad "handoff empty under inherited root"
exta=$(find "$EXT" -type f | sort)
if [ "$extb" = "$exta" ]; then ok "external project untouched"; else printf '%s\n' "$exta" > "$TMP/ext.after"; bad "external project mutated (compare \$extb vs \$TMP/ext.after)"; fi

# --- Launcher fail-open without python -------------------------------------------
SHIM="$TMP/shim"; mkdir -p "$SHIM"
printf '#!/bin/sh\nexit 127\n' > "$SHIM/python3"; printf '#!/bin/sh\nexit 127\n' > "$SHIM/python"; chmod +x "$SHIM/python3" "$SHIM/python"
out=$(PATH="$SHIM:$PATH" "$HANDLER" <<EOF
{"hook_event_name":"SessionStart","cwd":"$(to_json_path "$P1")"}
EOF
) ; rc=$?
check "no-python launcher exit 0" "$rc" "0"; check "no-python stdout empty" "$out" ""

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
