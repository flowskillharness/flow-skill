#!/usr/bin/env bash
# tests/test_flow_rules.sh - Verification for multi-harness workspace rule scaffolding (flow rules).
# Run: bash tests/test_flow_rules.sh (Git Bash on Windows or any POSIX bash). Exit 0 = all pass, 1 = any fail.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
RUN="$HERE/../skills/flow/runner/flow.sh"
PY="${FLOW_PYTHON:-python3}"

pass=0
fail=0

ck()  { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected '$1' got '$2'"; fail=$((fail+1)); fi; }
has() { if printf '%s' "$1" | grep -q "$2"; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] (missing: $2)"; fail=$((fail+1)); fi; }
no()  { if printf '%s' "$1" | grep -q "$2"; then echo "  FAIL [$3] (unexpected: $2)"; fail=$((fail+1)); else echo "  ok   [$3]"; pass=$((pass+1)); fi; }

SCRATCH="$(mktemp -d)"
cleanup() { rm -rf "$SCRATCH" 2>/dev/null; }
trap cleanup EXIT

echo "A) rules list outputs all 7 supported harnesses"
out_list="$(bash "$RUN" rules list 2>&1)"; rc_list=$?
ck 0 "$rc_list" "rules list exits 0"
has "$out_list" "cursor" "cursor listed"
has "$out_list" "windsurf" "windsurf listed"
has "$out_list" "roo" "roo listed"
has "$out_list" "cline" "cline listed"
has "$out_list" "aider" "aider listed"
has "$out_list" "openhands" "openhands listed"
has "$out_list" "copilot" "copilot listed"

echo "B) rules cursor emits valid frontmatter and directives"
out_cur="$(bash "$RUN" rules cursor 2>&1)"; rc_cur=$?
ck 0 "$rc_cur" "rules cursor exits 0"
has "$out_cur" "description: Flow buildflow discipline layer" "frontmatter description present"
has "$out_cur" "alwaysApply: false" "alwaysApply flag is false"
has "$out_cur" "globs:" "globs directive present"
has "$out_cur" "globs: flow/\*\*,cards/\*\*" "targeted globs present"
has "$out_cur" "Respect Allowed Files" "core directive present"
CUR_DIR="$SCRATCH/cur_test"
mkdir -p "$CUR_DIR"
(
  cd "$CUR_DIR"
  FLOW_PROJECT_ROOT="$CUR_DIR" bash "$RUN" rules cursor --write >/dev/null 2>&1
)
has "$(cat "$CUR_DIR/.cursor/rules/flow.mdc")" "alwaysApply: false" "generated .cursor/rules/flow.mdc contains alwaysApply: false"
has "$(cat "$CUR_DIR/.cursor/rules/flow.mdc")" "globs:" "generated .cursor/rules/flow.mdc contains globs:"

echo "C) rules roo emits valid JSON custom modes"
out_roo="$(bash "$RUN" rules roo 2>&1)"; rc_roo=$?
ck 0 "$rc_roo" "rules roo exits 0"
ROO_DIR="$SCRATCH/roo_test"
mkdir -p "$ROO_DIR"
(
  cd "$ROO_DIR"
  FLOW_PROJECT_ROOT="$ROO_DIR" bash "$RUN" rules roo --write >/dev/null 2>&1
  "$PY" -c "import json, sys; d=json.load(open('.roomodes')); assert isinstance(d.get('customModes'), list); m=d['customModes'][0]; assert m['slug']=='flow'"
)
ck 0 "$?" "rules roo generates valid .roomodes JSON/customModes structure"

echo "D) rules aider emits valid YAML with test-cmd"
out_aider="$(bash "$RUN" rules aider 2>&1)"; rc_aider=$?
ck 0 "$rc_aider" "rules aider exits 0"
has "$out_aider" "test-cmd: \"bash -c 'cid=\$(tr -d" "test-cmd present with cid validation"
has "$out_aider" "auto-test: true" "auto-test present"
no "$out_aider" "check-doc-budgets\.sh" ".aider.conf.yml does not contain check-doc-budgets.sh"

AIDER_TEST_DIR="$SCRATCH/aider_test"
mkdir -p "$AIDER_TEST_DIR/cards" "$AIDER_TEST_DIR/skills/flow/runner"
ln -s "$RUN" "$AIDER_TEST_DIR/skills/flow/runner/flow.sh"
(
  cd "$AIDER_TEST_DIR"
  FLOW_PROJECT_ROOT="$AIDER_TEST_DIR" bash "$RUN" rules aider --write >/dev/null 2>&1
)
no "$(cat "$AIDER_TEST_DIR/.aider.conf.yml")" "check-doc-budgets\.sh" "materialized .aider.conf.yml does not contain check-doc-budgets.sh"

# Python on Windows cannot open Git Bash /tmp/... paths (FileNotFoundError). When cygpath
# exists (Windows Git Bash), translate to a native Windows path for the python -c open().
AIDER_CONF_FOR_PY="$AIDER_TEST_DIR/.aider.conf.yml"
if command -v cygpath >/dev/null 2>&1; then
  AIDER_CONF_FOR_PY="$(cygpath -w "$AIDER_CONF_FOR_PY")"
fi

test_cmd="$("$PY" -c '
import re
with open(r"'"$AIDER_CONF_FOR_PY"'") as f:
    text = f.read()
try:
    import yaml
    print(yaml.safe_load(text)["test-cmd"])
except Exception:
    m = re.search(r"^test-cmd:\s*\"(.*)\"$", text, re.M)
    print(m.group(1).replace(r"\"", "\"").replace(r"\\r", "\r").replace(r"\\n", "\n"))
')"

MARKER="$SCRATCH/flow_aider_injected_$$"
rm -f "$MARKER"
printf 'C-001; touch %s\n' "$MARKER" > "$AIDER_TEST_DIR/cards/.inflight"

cmd_out="$(
  cd "$AIDER_TEST_DIR"
  FLOW_PROJECT_ROOT="$AIDER_TEST_DIR" eval "$test_cmd" 2>&1
)"
[ ! -f "$MARKER" ]; ck 0 "$?" "hostile injection did NOT execute (marker file not created)"
has "$cmd_out" "flow status" "safely fell back to running status on hostile inflight content"

echo "E) rules cursor --write creates .cursor/rules/flow.mdc on disk"
(
  cd "$SCRATCH"
  FLOW_PROJECT_ROOT="$SCRATCH" bash "$RUN" rules cursor --write >/dev/null 2>&1
)
ck 0 "$?" "rules cursor --write exits 0"
[ -f "$SCRATCH/.cursor/rules/flow.mdc" ]; ck 0 "$?" "file materialized at .cursor/rules/flow.mdc"
has "$(cat "$SCRATCH/.cursor/rules/flow.mdc")" "Flow Discipline Rules for Cursor" "materialized file contains expected directives"

echo "E2) rules --write strictly refuses to overwrite existing files"
# Test 1: pre-existing .aider.conf.yml
printf '%s\n' "PRE_EXISTING_USER_CONFIG_SENTINEL" > "$SCRATCH/.aider.conf.yml"
out_ow="$(
  cd "$SCRATCH"
  FLOW_PROJECT_ROOT="$SCRATCH" bash "$RUN" rules aider --write 2>&1
)"
rc_ow=$?
ck 1 "$rc_ow" "rules aider --write on existing file exits 1"
has "$out_ow" "already exists" "refusal message reports destination already exists"
has "$(cat "$SCRATCH/.aider.conf.yml")" "PRE_EXISTING_USER_CONFIG_SENTINEL" "existing .aider.conf.yml content preserved"

# Test 2: pre-existing .cursor/rules/flow.mdc
printf '%s\n' "PRE_EXISTING_CURSOR_RULE_SENTINEL" > "$SCRATCH/.cursor/rules/flow.mdc"
out_ow_cur="$(
  cd "$SCRATCH"
  FLOW_PROJECT_ROOT="$SCRATCH" bash "$RUN" rules cursor --write 2>&1
)"
rc_ow_cur=$?
ck 1 "$rc_ow_cur" "rules cursor --write on existing file exits 1"
has "$out_ow_cur" "refusing to overwrite" "refusal message states refusing to overwrite"
has "$(cat "$SCRATCH/.cursor/rules/flow.mdc")" "PRE_EXISTING_CURSOR_RULE_SENTINEL" "existing .cursor/rules/flow.mdc content preserved"

# Test 3: dangling symlink refusal (must not follow dangling symlink to write target)
PROJ_SYM="$SCRATCH/proj_sym"
mkdir -p "$PROJ_SYM/.cursor/rules"
ln -s "$SCRATCH/absent_target.txt" "$PROJ_SYM/.cursor/rules/flow.mdc" 2>/dev/null || true
if [ -L "$PROJ_SYM/.cursor/rules/flow.mdc" ]; then
  out_sym="$(
    cd "$PROJ_SYM"
    FLOW_PROJECT_ROOT="$PROJ_SYM" bash "$RUN" rules cursor --write 2>&1
  )"
  rc_sym=$?
  ck 1 "$rc_sym" "rules cursor --write on dangling symlink exits 1"
  case "$out_sym" in
    *"already exists"*|*"refusing to overwrite"*) ck 0 0 "error message mentions already exists or refusing to overwrite" ;;
    *) ck 0 1 "error message mentions already exists or refusing to overwrite" ;;
  esac
  [ -L "$PROJ_SYM/.cursor/rules/flow.mdc" ]; ck 0 "$?" "dangling symlink is preserved"
  [ ! -f "$SCRATCH/absent_target.txt" ]; ck 0 "$?" "dangling target was NOT created"
else
  echo "  ok   [platform cannot create symlinks: dangling symlink test skipped]"
  pass=$((pass+4))
fi

echo "F) unknown harness exits 2 with usage"
out_unk="$(bash "$RUN" rules unknown_harness 2>&1)"; rc_unk=$?
ck 2 "$rc_unk" "unknown harness exits 2"
has "$out_unk" "unknown harness: unknown_harness" "error message reports unknown harness"

echo "G) invalid extra arguments exits 2"
out_bad="$(bash "$RUN" rules cursor --badflag 2>&1)"; rc_bad=$?
ck 2 "$rc_bad" "invalid extra option exits 2"
has "$out_bad" "usage: flow rules" "usage string printed on bad option"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
exit $?
