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
  && git init -q && git commit -qm base --allow-empty )
EX_REL="$(git -C "$SB" rev-parse --git-path info/exclude)"
case "$EX_REL" in /*) EX_PATH="$EX_REL" ;; *) EX_PATH="$SB/$EX_REL" ;; esac
printf '# existing local excludes without final newline' > "$EX_PATH"
( cd "$SB" && unset FLOW_PROJECT_ROOT && bash "$RUN" next >/dev/null 2>&1 )
EX="$(git -C "$SB" rev-parse --git-path info/exclude)"
case "$EX" in /*) ;; *) EX="$SB/$EX" ;; esac
[ "$(grep -cF '/.flow/' "$EX")" -eq 1 ] && grep -qxF '/flow/.lock*' "$EX" && grep -qxF '/cards/.inflight' "$EX" || { echo "  FAIL [info/exclude missing or concatenated patterns]"; fail=$((fail+1)); }
git -C "$SB" config user.name ci
git -C "$SB" config user.email ci@localhost
git -C "$SB" -c user.name=ci -c user.email=ci@localhost add -A && git -C "$SB" -c user.name=ci -c user.email=ci@localhost commit -qm "novice: git add -A"
ck 0 "$(git -C "$SB" ls-files | grep -cE '^\.flow/|^flow/\.lock|^\.gitignore$')" "committed tree has no .flow/, no flow/.lock*, no minted .gitignore"
ck 0 "$([ -f "$SB/.flow/events.jsonl" ] && echo 0 || echo 1)" "telemetry still written to disk (ignored, not suppressed)"
( cd "$SB" && test ! -f .gitignore ) && echo "  ok   [no .gitignore created in git repos]" || { echo "  FAIL [.gitignore should not be created]"; fail=$((fail+1)); }
rm -rf "$SB"

echo "E) DECOY: ancestor has a bare flow/ dir but NO stage artifact -> must NOT adopt (real-signature guard)"
SB="$(mktemp -d)"; mkdir -p "$SB/flow" "$SB/deep/sub"   # flow/ exists but is EMPTY (no 00-idea.md, no .flow/, no cards)
out="$( cd "$SB/deep/sub" && unset FLOW_PROJECT_ROOT; bash "$RUN" status 2>&1 )"
no  "$out" "note: using flow root" "a bare flow/ folder (e.g. ~/flow) is NOT a flow project — no adoption"
rm -rf "$SB"


echo "H) adopted Flow root inside a larger repo scopes ignore rules to its prefix"
SB="$(mktemp -d)"
git -C "$SB" init -q
git -C "$SB" config user.name ci
git -C "$SB" config user.email ci@localhost
mkdir -p "$SB/frontend/flow" "$SB/frontend/cards" "$SB/frontend/src"
printf '# Stage 00\n## Goal\n- [x] goal recorded\n\nDone.\n' > "$SB/frontend/flow/00-idea.md"
git -C "$SB" add frontend/flow/00-idea.md
git -C "$SB" commit -qm base
(cd "$SB/frontend" && unset FLOW_PROJECT_ROOT && bash "$RUN" next >/dev/null 2>&1)
EX="$(git -C "$SB/frontend" rev-parse --git-path info/exclude)"
case "$EX" in /*) ;; *) EX="$SB/frontend/$EX" ;; esac
for pat in '/frontend/.flow/' '/frontend/flow/.lock*' '/frontend/cards/.inflight' '/frontend/MODE' '/frontend/PROJECT_TYPE'; do
  grep -qxF "$pat" "$EX" || { echo "  FAIL [nested exclude missing $pat]"; fail=$((fail+1)); }
done
mkdir -p "$SB/frontend/.flow" "$SB/frontend/flow" "$SB/frontend/cards" "$SB/.flow" "$SB/flow"
touch "$SB/frontend/.flow/events.jsonl" "$SB/frontend/flow/.lock" "$SB/frontend/cards/.inflight" "$SB/frontend/MODE" "$SB/frontend/PROJECT_TYPE" "$SB/.flow/keep" "$SB/flow/.lock"
for path in frontend/.flow/events.jsonl frontend/flow/.lock frontend/cards/.inflight frontend/MODE frontend/PROJECT_TYPE; do
  git -C "$SB" check-ignore -q "$path" || { echo "  FAIL [nested run-state not ignored: $path]"; fail=$((fail+1)); }
done
for path in .flow/keep flow/.lock; do
  git -C "$SB" check-ignore -q "$path" && { echo "  FAIL [unrelated repo path ignored: $path]"; fail=$((fail+1)); } || echo "  ok   [unrelated repo path remains trackable: $path]"
done
rm -rf "$SB"

echo "I) linked worktree without .gitignore writes absolute main-git-dir exclude"
SB="$(mktemp -d)"
git -C "$SB" init -q
git -C "$SB" config user.name ci
git -C "$SB" config user.email ci@localhost
printf '# base\n' > "$SB/base.txt"
git -C "$SB" add base.txt
git -C "$SB" commit -qm base
git -C "$SB" worktree add --detach "$SB-linked" HEAD >/dev/null
test -f "$SB-linked/.git" && test ! -d "$SB-linked/.git" && test ! -e "$SB-linked/.gitignore"
(cd "$SB-linked" && unset FLOW_PROJECT_ROOT && bash "$RUN" next >/dev/null 2>&1)
EX="$(git -C "$SB-linked" rev-parse --git-path info/exclude)"
case "$EX" in /*) ;; *) EX="$SB-linked/$EX" ;; esac
for pat in '/.flow/' '/flow/.lock*' '/cards/.inflight' '/MODE' '/PROJECT_TYPE'; do
  grep -qxF "$pat" "$EX" || { echo "  FAIL [linked exclude missing $pat]"; fail=$((fail+1)); }
done
test ! -e "$SB-linked/.git/info/exclude" && echo "  ok   [no relative-path stray .git tree under worktree]" || { echo "  FAIL [relative-path stray .git tree]"; fail=$((fail+1)); }
git -C "$SB-linked" worktree remove --force "$SB-linked"
rm -rf "$SB"

echo "J) nested Flow root with ignore metacharacters is matched literally"
SB="$(mktemp -d)"
git -C "$SB" init -q
git -C "$SB" config user.name ci
git -C "$SB" config user.email ci@localhost
mkdir -p "$SB/frontend[1]/flow" "$SB/frontend1/.flow"
printf '# Stage 00\n## Goal\n- [x] goal recorded\n\nDone.\n' > "$SB/frontend[1]/flow/00-idea.md"
git -C "$SB" add 'frontend[1]/flow/00-idea.md'
git -C "$SB" commit -qm base
(cd "$SB/frontend[1]" && unset FLOW_PROJECT_ROOT && bash "$RUN" next >/dev/null 2>&1)
EX="$(git -C "$SB" rev-parse --git-path info/exclude)"
case "$EX" in /*) ;; *) EX="$SB/$EX" ;; esac
grep -qxF '/frontend\[1\]/.flow/' "$EX" || { echo "  FAIL [literal metachar prefix not escaped]"; fail=$((fail+1)); }
mkdir -p "$SB/frontend[1]/.flow" "$SB/frontend1/.flow"
touch "$SB/frontend[1]/.flow/events.jsonl" "$SB/frontend1/.flow/keep"
git -C "$SB" check-ignore -q 'frontend[1]/.flow/events.jsonl' || { echo "  FAIL [literal root state not ignored]"; fail=$((fail+1)); }
git -C "$SB" check-ignore -q 'frontend1/.flow/keep' && { echo "  FAIL [metachar lookalike unexpectedly ignored]"; fail=$((fail+1)); } || echo "  ok   [metachar lookalike remains trackable]"
rm -rf "$SB"
echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
