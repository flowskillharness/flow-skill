#!/usr/bin/env bash
# Test suite for scripts/sync-release.mjs (hardened README checks, prerelease protection, tag suppression).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
pass=0; fail=0
ck() { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected=$1 got=$2"; fail=$((fail+1)); fi; }

echo "A) sync-release --check exits 0 on current repository"
node "$ROOT/scripts/sync-release.mjs" --check >/tmp/sync_check.out 2>&1
ck 0 $? "sync-release --check exit code"
grep -q "PASS: All release surfaces coherent" /tmp/sync_check.out && ck 0 0 "reported PASS line" || ck 0 1 "reported PASS line"

echo "B) --check is strictly read-only"
before_status="$(git -C "$ROOT" status --porcelain scripts/ npm-wrapper/ README* skills/ .claude-plugin/ portable-manifest.json CHANGELOG*)"
node "$ROOT/scripts/sync-release.mjs" --check >/dev/null 2>&1
after_status="$(git -C "$ROOT" status --porcelain scripts/ npm-wrapper/ README* skills/ .claude-plugin/ portable-manifest.json CHANGELOG*)"
[ "$before_status" = "$after_status" ] && ck 0 0 "working tree identical before and after --check" || ck 0 1 "working tree identical before and after --check"

echo "C) deliberate table row drift fails --check with exit 1"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/skills/flow/SKILL.md" "$tmp/r/skills/flow/"
cp "$ROOT/skills/flow/runner/flow.sh" "$tmp/r/skills/flow/runner/"
cp "$ROOT/portable-manifest.json" "$tmp/r/"
cp "$ROOT/.claude-plugin/plugin.json" "$tmp/r/.claude-plugin/"
cp "$ROOT/npm-wrapper/package.json" "$tmp/r/npm-wrapper/"
cp "$ROOT/npm-wrapper/README.md" "$tmp/r/npm-wrapper/"
cp "$ROOT/npm-wrapper/README_VN.md" "$tmp/r/npm-wrapper/"
cp "$ROOT/README.md" "$tmp/r/"
cp "$ROOT/README_VN.md" "$tmp/r/"
cp "$ROOT/CHANGELOG.md" "$tmp/r/"
cp "$ROOT/npm-wrapper/CHANGELOG.md" "$tmp/r/npm-wrapper/"

# Deliberate drift in npm-wrapper/README.md
printf '| **Current GA** | **9.9.9** — ships skill product **v0.0.1** |\n' > "$tmp/r/npm-wrapper/README.md"
node "$tmp/r/scripts/sync-release.mjs" --check >/tmp/sync_c.out 2>&1
ck 1 $? "drift fails --check"
grep -q "FAIL: Release coherence check failed" /tmp/sync_c.out && ck 0 0 "reports failure message" || ck 0 1 "reports failure message"
grep -q "ROW MISMATCH" /tmp/sync_c.out && ck 0 0 "detects row mismatch" || ck 0 1 "detects row mismatch"
rm -rf "$tmp"

echo "D) missing README file fails --check with exit 1"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/skills/flow/SKILL.md" "$tmp/r/skills/flow/"
cp "$ROOT/skills/flow/runner/flow.sh" "$tmp/r/skills/flow/runner/"
cp "$ROOT/portable-manifest.json" "$tmp/r/"
cp "$ROOT/.claude-plugin/plugin.json" "$tmp/r/.claude-plugin/"
cp "$ROOT/npm-wrapper/package.json" "$tmp/r/npm-wrapper/"
cp "$ROOT/npm-wrapper/README.md" "$tmp/r/npm-wrapper/"
# Intentionally omit npm-wrapper/README_VN.md
cp "$ROOT/README.md" "$tmp/r/"
cp "$ROOT/README_VN.md" "$tmp/r/"
cp "$ROOT/CHANGELOG.md" "$tmp/r/"
cp "$ROOT/npm-wrapper/CHANGELOG.md" "$tmp/r/npm-wrapper/"

node "$tmp/r/scripts/sync-release.mjs" --check >/tmp/sync_d.out 2>&1
ck 1 $? "missing README fails --check"
grep -q "FILE MISSING" /tmp/sync_d.out && ck 0 0 "reports FILE MISSING" || ck 0 1 "reports FILE MISSING"
rm -rf "$tmp"

echo "E) --sync with prerelease version in package.json preserves Current GA row"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper/scripts" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/skills/flow/SKILL.md" "$tmp/r/skills/flow/"
cp "$ROOT/skills/flow/runner/flow.sh" "$tmp/r/skills/flow/runner/"
cp "$ROOT/portable-manifest.json" "$tmp/r/"
cp "$ROOT/.claude-plugin/plugin.json" "$tmp/r/.claude-plugin/"
cp "$ROOT/npm-wrapper/package.json" "$tmp/r/npm-wrapper/"
cp "$ROOT/npm-wrapper/scripts/sync.mjs" "$tmp/r/npm-wrapper/scripts/"
cp "$ROOT/npm-wrapper/README.md" "$tmp/r/npm-wrapper/"
cp "$ROOT/npm-wrapper/README_VN.md" "$tmp/r/npm-wrapper/"
cp "$ROOT/README.md" "$tmp/r/"
cp "$ROOT/README_VN.md" "$tmp/r/"
cp "$ROOT/CHANGELOG.md" "$tmp/r/"
cp "$ROOT/npm-wrapper/CHANGELOG.md" "$tmp/r/npm-wrapper/"
cp -r "$ROOT/skills/flow" "$tmp/r/skills/"

# Set prerelease version in npm-wrapper/package.json
sed -i 's/"version": "0.7.8"/"version": "0.7.9-next.0"/' "$tmp/r/npm-wrapper/package.json"
# Add changelog entry for the prerelease in npm-wrapper/CHANGELOG.md
sed -i '1s/^/## [0.7.9-next.0] - 2026-10-15\n\n- Pre-release test.\n\n/' "$tmp/r/npm-wrapper/CHANGELOG.md"

node "$tmp/r/scripts/sync-release.mjs" --sync >/tmp/sync_e.out 2>&1
ck 0 $? "--sync exits 0 with prerelease"

# Check npm-wrapper/README.md preserved Current GA and added Prerelease
grep -q '| \*\*Current GA\*\* | \*\*0.7.8\*\* — ships skill product \*\*v0.34.1\*\* |' "$tmp/r/npm-wrapper/README.md"
ck 0 $? "npm-wrapper/README.md preserves Current GA row"
grep -q '| \*\*Prerelease\*\* | \*\*0.7.9-next.0\*\* — ships skill product \*\*v0.34.1\*\* |' "$tmp/r/npm-wrapper/README.md"
ck 0 $? "npm-wrapper/README.md has Prerelease row"

# Check npm-wrapper/README_VN.md preserved GA hiện tại and added Bản thử nghiệm
grep -q '| \*\*GA hiện tại\*\* | \*\*0.7.8\*\* — ships skill product \*\*v0.34.1\*\* |' "$tmp/r/npm-wrapper/README_VN.md"
ck 0 $? "npm-wrapper/README_VN.md preserves GA hiện tại row"
grep -q '| \*\*Bản thử nghiệm\*\* | \*\*0.7.9-next.0\*\* — ships skill product \*\*v0.34.1\*\* |' "$tmp/r/npm-wrapper/README_VN.md"
ck 0 $? "npm-wrapper/README_VN.md has Bản thử nghiệm row"

rm -rf "$tmp"

echo "F) existing tags suppress tag creation instructions and report metadata repair"
node "$ROOT/scripts/sync-release.mjs" --instructions >/tmp/sync_f.out 2>&1
ck 0 $? "sync-release --instructions exit code"
grep -q "Both release tags already exist. This operation was metadata repair / synchronization, not a new release." /tmp/sync_f.out && ck 0 0 "reports metadata repair note" || ck 0 1 "reports metadata repair note"
grep -q "Git tag npm@0.7.8 ALREADY exists in repository (published). Skipping npm tag command." /tmp/sync_f.out && ck 0 0 "skips npm tag command" || ck 0 1 "skips npm tag command"
grep -q "Git tag v0.34.1 ALREADY exists in repository. Skipping skill tag command." /tmp/sync_f.out && ck 0 0 "skips skill tag command" || ck 0 1 "skips skill tag command"
grep -q "git tag npm@" /tmp/sync_f.out && ck 1 0 "does not emit git tag npm@" || ck 0 0 "does not emit git tag npm@"
grep -q "git tag v" /tmp/sync_f.out && ck 1 0 "does not emit git tag v" || ck 0 0 "does not emit git tag v"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
