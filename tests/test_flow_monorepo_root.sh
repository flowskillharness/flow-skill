#!/usr/bin/env bash
# Regression suite for the monorepo dual-root guard (Fix B): running flow from a subdir of an
# existing flow project must ADOPT the ancestor root, not silently mint a second .flow root.
# Run: bash tests/test_flow_monorepo_root.sh
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
RUN="$HERE/../skills/flow/runner/flow.sh"
pass=0; fail=0
ck()  { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected '$1' got '$2'"; fail=$((fail+1)); fi; }
has() { if printf '%s' "$1" | grep -q "$2"; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] (missing: $2)"; fail=$((fail+1)); fi; }
no()  { if printf '%s' "$1" | grep -q "$2"; then echo "  FAIL [$3] (unexpected: $2)"; fail=$((fail+1)); else echo "  ok   [$3]"; pass=$((pass+1)); fi; }

# Parent flow project with a flow/ planning dir; a frontend/ subdir with no flow state of its own.
newsb() { SB="$(mktemp -d)"; mkdir -p "$SB/flow" "$SB/frontend/src"; printf '# 00\n## Gate\n- [x] ok\n\nx.\n' > "$SB/flow/00-idea.md"; }

echo "A) from a subdir with no flow/ -> ADOPT the ancestor root + stderr note"
newsb
out="$( cd "$SB/frontend" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>&1 )"
has "$out" "note: using flow root" "prints adoption note to stderr"
has "$out" "project: $SB" "status resolves to the ANCESTOR project, not the subdir"
no  "$out" "project: $SB/frontend" "does NOT mint a child root at the subdir"
# and no second .flow was created under frontend/
ck 1 "$([ -d "$SB/frontend/.flow" ] && echo 0 || echo 1)" "no second .flow root created under frontend/"
# stdout-only capture: the adoption marker is visible to host parsers on STDOUT too (C2)
sout="$( cd "$SB/frontend" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>/dev/null )"
has "$sout" "adopting flow root $SB from an ancestor" "adoption marker also on stdout for host parsers"

echo "A2) /flow next from the adopted subdir -> PASS names the ROOT-qualified path"
SB="$(mktemp -d)"; mkdir -p "$SB/.flow" "$SB/frontend/src"   # SB was used as a root (.flow run-state); frontend adopts it
sout2="$( cd "$SB/frontend" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>/dev/null )"
has "$sout2" "adopting flow root $SB from an ancestor" "status adopts the ancestor before first next"
nout="$( cd "$SB/frontend" && unset FLOW_PROJECT_ROOT; bash "$RUN" next 2>&1 )"
has "$nout" "unlocked stage 00" "stage-00 unlock literal preserved (parity contract)"
has "$nout" "PASS: unlocked stage 00 -> $SB/flow/00-idea.md" "PASS names the ROOT-qualified artifact path"
ck 0 "$([ -f "$SB/flow/00-idea.md" ] && echo 0 || echo 1)" "the qualified path actually exists at the ancestor"
rm -rf "$SB"

echo "B) subdir WITH its own flow/ (deliberate sub-project) -> NOT adopted"
newsb; mkdir -p "$SB/frontend/flow"
out="$( cd "$SB/frontend" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>&1 )"
no  "$out" "note: using flow root" "deliberate sub-project is left alone (no adoption)"
has "$out" "project: $SB/frontend" "sub-project keeps its own root"
rm -rf "$SB"

echo "C) explicit FLOW_PROJECT_ROOT always wins (no adoption walk)"
newsb
out="$( cd "$SB/frontend" && FLOW_PROJECT_ROOT="$SB/frontend" bash "$RUN" status 2>&1 )"
no  "$out" "note: using flow root" "override suppresses the adoption walk"
has "$out" "project: $SB/frontend" "override root respected"
rm -rf "$SB"

echo "D) a standalone dir NOT under any flow project -> stays itself + new-root note (no false adoption)"
SB="$(mktemp -d)"; mkdir -p "$SB/plain"
out="$( cd "$SB/plain" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>&1 )"
no  "$out" "note: using flow root" "no adoption when no ancestor is a flow project"
has "$out" "note: no Flow project found here or in ancestors" "announces that a NEW flow root starts at this CWD"
has "$out" "starting a new Flow project at $SB/plain" "announced destination is exactly this CWD"
has "$out" "project: $SB/plain" "standalone dir still resolves to itself"
rm -rf "$SB"

echo "F) a dir with only .flow/ run-state (no flow/, no cards/) -> existing root, NO new-project note"
SB="$(mktemp -d)"; mkdir -p "$SB/plain/.flow"
out="$( cd "$SB/plain" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>&1 )"
no  "$out" "note: no Flow project found here" ".flow run-state means this root is not new"
has "$out" "project: $SB/plain" ".flow-only dir still resolves to itself"
rm -rf "$SB"

echo "G) git repo: run-state ignores land in .git/info/exclude, never committed"
SB="$(mktemp -d)"
( cd "$SB" \
  && export GIT_AUTHOR_NAME=ci GIT_AUTHOR_EMAIL=ci@localhost GIT_COMMITTER_NAME=ci GIT_COMMITTER_EMAIL=ci@localhost \
  && git init -q && git commit -qm base --allow-empty && unset FLOW_PROJECT_ROOT && bash "$RUN" next >/dev/null 2>&1 )
( cd "$SB" && EX="$(git rev-parse --git-path info/exclude)" \
  && grep -qxF '.flow/' "$EX" && grep -qxF 'flow/.lock*' "$EX" && grep -qxF 'cards/.inflight' "$EX" ) || { echo "  FAIL [info/exclude missing patterns]"; fail=$((fail+1)); }
git -C "$SB" add -A && git -C "$SB" commit -qm "novice: git add -A"
ck 0 "$(git -C "$SB" ls-files | grep -cE '^\.flow/|^flow/\.lock|^\.gitignore$')" "committed tree has no .flow/, no flow/.lock*, no minted .gitignore"
ck 0 "$([ -f "$SB/.flow/events.jsonl" ] && echo 0 || echo 1)" "telemetry still written to disk (ignored, not suppressed)"
( cd "$SB" && test ! -f .gitignore ) && echo "  ok   [no .gitignore created in git repos]" || { echo "  FAIL [.gitignore should not be created]"; fail=$((fail+1)); }
rm -rf "$SB"

echo "E) DECOY: ancestor has a bare flow/ dir but NO stage artifact -> must NOT adopt (real-signature guard)"
SB="$(mktemp -d)"; mkdir -p "$SB/flow" "$SB/deep/sub"   # flow/ exists but is EMPTY (no 00-idea.md, no .flow/, no cards)
out="$( cd "$SB/deep/sub" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>&1 )"
no  "$out" "note: using flow root" "a bare flow/ folder (e.g. ~/flow) is NOT a flow project — no adoption"
rm -rf "$SB"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
