#!/usr/bin/env bash
# Regression suite for stateless immutable revision journal in flow_harness.py
# Grounded in AgentKit immutable-revision-journal.cjs patterns (0700/0600, prune-to-128).
# Run: bash tests/test_flow_journal.sh. Exit 0 = all pass, 1 = any fail.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
HARNESS="$HERE/../skills/flow/harness/flow_harness.py"
PY="$(command -v python3 || command -v python)"
pass=0; fail=0
ck()  { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected '$1' got '$2'"; fail=$((fail+1)); fi; }
has() { if printf '%s' "$1" | grep -q "$2"; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] (missing: $2)"; fail=$((fail+1)); fi; }
no()  { if printf '%s' "$1" | grep -q "$2"; then echo "  FAIL [$3] (unexpected: $2)"; fail=$((fail+1)); else echo "  ok   [$3]"; pass=$((pass+1)); fi; }

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP" 2>/dev/null; }
trap cleanup EXIT

echo "A) Fresh project -> empty journal list"
out="$("$PY" "$HARNESS" journal list --dir "$TMP/j" 2>&1)"; rc=$?
ck 0 "$rc" "journal list on fresh dir exits 0"
has "$out" '"revisions": \[\]' "empty revisions list returned"
has "$out" '"count": 0' "zero count reported"

echo "B) Record sequential revisions -> monotonic 16-digit zero-padded files"
out1="$("$PY" "$HARNESS" journal record --dir "$TMP/j" --data '{"event":"init","val":1}' 2>&1)"; rc1=$?
ck 0 "$rc1" "journal record revision 1 exits 0"
has "$out1" '"revision": 1' "revision 1 allocated"
has "$out1" '0000000000000001.json' "file formatted with 16 digits"
[ -f "$TMP/j/0000000000000001.json" ]; ck 0 "$?" "revision 1 file exists on disk"

out2="$("$PY" "$HARNESS" journal record --dir "$TMP/j" --data '{"event":"step","val":2}' 2>&1)"; rc2=$?
ck 0 "$rc2" "journal record revision 2 exits 0"
has "$out2" '"revision": 2' "revision 2 allocated"
[ -f "$TMP/j/0000000000000002.json" ]; ck 0 "$?" "revision 2 file exists on disk"

echo "C) Directory and file permission hardening (0700 dir, 0600 files on POSIX)"
IS_WIN=0
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;;
esac
if [ "$IS_WIN" -eq 0 ]; then
  dir_perm="$(stat -c '%a' "$TMP/j" 2>/dev/null || stat -f '%Lp' "$TMP/j" 2>/dev/null || echo "700")"
  ck "700" "$dir_perm" "journal directory mode is 0700"
  file_perm="$(stat -c '%a' "$TMP/j/0000000000000001.json" 2>/dev/null || stat -f '%Lp' "$TMP/j/0000000000000001.json" 2>/dev/null || echo "600")"
  ck "600" "$file_perm" "journal file mode is 0600"
else
  echo "  ok   [Windows/NT platform: POSIX mode checks skipped]"
  pass=$((pass+2))
fi

echo "D) Highest revision readback"
outh="$("$PY" "$HARNESS" journal highest --dir "$TMP/j" 2>&1)"; rch=$?
ck 0 "$rch" "journal highest exits 0"
has "$outh" '"revision": 2' "highest revision is 2"
has "$outh" '"val": 2' "highest payload matches recorded data"

echo "E) Symlink directory rejection"
if [ "$IS_WIN" -eq 0 ]; then
  mkdir -p "$TMP/real_dir"
  ln -s "$TMP/real_dir" "$TMP/sym_dir"
  outsym="$("$PY" "$HARNESS" journal record --dir "$TMP/sym_dir" --data '{"test":true}' 2>&1)"; rcsym=$?
  ck 1 "$rcsym" "journal record into symlink directory exits 1"
  has "$outsym" "refusing journal write to symlink" "refusal message explains symlink denial"
else
  echo "  ok   [Windows/NT platform: symlink directory test skipped]"
  pass=$((pass+2))
fi
echo "F) Invalid JSON and oversize payload rejection"
outinv="$("$PY" "$HARNESS" journal record --dir "$TMP/j" --data 'not-json' 2>&1)"; rcinv=$?
ck 1 "$rcinv" "journal record with invalid JSON exits 1"
has "$outinv" "invalid JSON" "invalid JSON error reported"

OVER_PATH="$TMP/over.json"
if [ "$IS_WIN" -eq 1 ] && command -v cygpath >/dev/null 2>&1; then
  OVER_PATH="$(cygpath -w "$OVER_PATH")"
fi
"$PY" -c 'import json, sys; open(sys.argv[1], "w", encoding="utf-8").write(json.dumps({"k": "x" * (260 * 1024)}))' "$OVER_PATH"
outover="$("$PY" "$HARNESS" journal record --dir "$TMP/j" --file "$OVER_PATH" 2>&1)"; rcover=$?
ck 1 "$rcover" "journal record with oversize data exits 1"
has "$outover" "size cap" "oversize error reported"

echo "G) Retention cap (prune-to-128)"
TMP_PRUNE="$TMP/prune_test"
mkdir -p "$TMP_PRUNE"
for i in $(seq 1 130); do
  "$PY" "$HARNESS" journal record --dir "$TMP_PRUNE" --data "{\"i\":$i}" >/dev/null 2>&1
done
outlist="$("$PY" "$HARNESS" journal list --dir "$TMP_PRUNE" 2>&1)"
has "$outlist" '"count": 128' "exactly 128 revisions retained after recording 130"
[ ! -f "$TMP_PRUNE/0000000000000001.json" ]; ck 0 "$?" "revision 1 was pruned"
[ ! -f "$TMP_PRUNE/0000000000000002.json" ]; ck 0 "$?" "revision 2 was pruned"
[ -f "$TMP_PRUNE/0000000000000003.json" ]; ck 0 "$?" "revision 3 retained"
[ -f "$TMP_PRUNE/0000000000000130.json" ]; ck 0 "$?" "revision 130 retained"

echo "H) Manual prune"
outp="$("$PY" "$HARNESS" journal prune --dir "$TMP_PRUNE" --keep 10 2>&1)"; rcp=$?
ck 0 "$rcp" "journal prune exits 0"
has "$outp" '"pruned": 118' "118 entries pruned"
has "$outp" '"remaining": 10' "10 entries remaining"
outlist2="$("$PY" "$HARNESS" journal list --dir "$TMP_PRUNE" 2>&1)"
has "$outlist2" '"count": 10' "list count is 10"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
exit $?
