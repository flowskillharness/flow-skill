#!/usr/bin/env bash
# Test suite for scripts/sync-release.mjs (hardened README checks, prerelease protection, tag suppression).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
pass=0; fail=0
ck() { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected=$1 got=$2"; fail=$((fail+1)); fi; }
portable_hash() {
  if command -v sha256sum >/dev/null 2>&1; then
    find "$1" -type f -exec sha256sum {} + 2>/dev/null | sort
  else
    find "$1" -type f -exec shasum -a 256 {} + 2>/dev/null | sort
  fi
}
winpath() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}

echo "A) sync-release --check exits 0 on current repository"
node "$(winpath "$ROOT/scripts/sync-release.mjs")" --check >/tmp/sync_check.out 2>&1
ck 0 $? "sync-release --check exit code"
grep -q "PASS: All release surfaces coherent" /tmp/sync_check.out && ck 0 0 "reported PASS line" || ck 0 1 "reported PASS line"

echo "B) --check is strictly read-only"
before_status="$(git -C "$ROOT" status --porcelain scripts/ npm-wrapper/ README* skills/ .claude-plugin/ portable-manifest.json CHANGELOG*)"
node "$(winpath "$ROOT/scripts/sync-release.mjs")" --check >/dev/null 2>&1
after_status="$(git -C "$ROOT" status --porcelain scripts/ npm-wrapper/ README* skills/ .claude-plugin/ portable-manifest.json CHANGELOG*)"
[ "$before_status" = "$after_status" ] && ck 0 0 "working tree identical before and after --check" || ck 0 1 "working tree identical before and after --check"

echo "C) deliberate table row drift fails --check with exit 1"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
mkdir -p "$tmp/r/npm-wrapper/scripts"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
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
node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --check >/tmp/sync_c.out 2>&1
ck 1 $? "drift fails --check"
grep -q "FAIL: Release coherence check failed" /tmp/sync_c.out && ck 0 0 "reports failure message" || ck 0 1 "reports failure message"
grep -q "ROW MISMATCH" /tmp/sync_c.out && ck 0 0 "detects row mismatch" || ck 0 1 "detects row mismatch"
rm -rf "$tmp"

echo "D) missing README file fails --check with exit 1"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
mkdir -p "$tmp/r/npm-wrapper/scripts"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
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

node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --check >/tmp/sync_d.out 2>&1
ck 1 $? "missing README fails --check"
grep -q "FILE MISSING" /tmp/sync_d.out && ck 0 0 "reports FILE MISSING" || ck 0 1 "reports FILE MISSING"
rm -rf "$tmp"

echo "E) --sync with prerelease version in package.json preserves Current GA row"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper/scripts" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
mkdir -p "$tmp/r/npm-wrapper/scripts"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
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
base_npm_v=$(node -e 'const p = process.argv[1]; console.log(require(p).version)' "$(winpath "$tmp/r/npm-wrapper/package.json")")
base_skill_v=$(node -e 'const fs = require("node:fs"); const m = fs.readFileSync(process.argv[1], "utf8").match(/version:\s*"([^"]+)"/); console.log(m[1])' "$(winpath "$tmp/r/skills/flow/SKILL.md")")
prerelease_v="${base_npm_v}-next.0"
node -e '
  const fs = require("node:fs");
  const p = process.argv[1];
  const pkg = JSON.parse(fs.readFileSync(p, "utf8"));
  pkg.version = process.argv[2];
  fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + "\n");
' "$(winpath "$tmp/r/npm-wrapper/package.json")" "$prerelease_v"
# Add changelog entry for the prerelease in npm-wrapper/CHANGELOG.md
node -e '
  const fs = require("node:fs");
  const p = process.argv[1];
  const v = process.argv[2];
  fs.writeFileSync(p, "## [" + v + "] - 2026-10-15\n\n- Pre-release test.\n\n" + fs.readFileSync(p, "utf8"));
' "$(winpath "$tmp/r/npm-wrapper/CHANGELOG.md")" "$prerelease_v"

node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --sync >/tmp/sync_e.out 2>&1
ck 0 $? "--sync exits 0 with prerelease"

# Check npm-wrapper/README.md preserved Current GA and added Prerelease
grep -q "| \*\*Current GA\*\* | \*\*${base_npm_v}\*\* — ships skill product \*\*v${base_skill_v}\*\* |" "$tmp/r/npm-wrapper/README.md"
ck 0 $? "npm-wrapper/README.md preserves Current GA row"
grep -q "| \*\*Prerelease\*\* | \*\*${prerelease_v}\*\* — ships skill product \*\*v${base_skill_v}\*\* |" "$tmp/r/npm-wrapper/README.md"
ck 0 $? "npm-wrapper/README.md has Prerelease row"

# Check npm-wrapper/README_VN.md preserved GA hiện tại and added Bản thử nghiệm
grep -q "| \*\*GA hiện tại\*\* | \*\*${base_npm_v}\*\* — ships skill product \*\*v${base_skill_v}\*\* |" "$tmp/r/npm-wrapper/README_VN.md"
ck 0 $? "npm-wrapper/README_VN.md preserves GA hiện tại row"
grep -q "| \*\*Bản thử nghiệm\*\* | \*\*${prerelease_v}\*\* — ships skill product \*\*v${base_skill_v}\*\* |" "$tmp/r/npm-wrapper/README_VN.md"
ck 0 $? "npm-wrapper/README_VN.md has Bản thử nghiệm row"

rm -rf "$tmp"

echo "F) existing tags suppress tag creation instructions and report metadata repair"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
mkdir -p "$tmp/r/npm-wrapper/scripts"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
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
git -C "$tmp/r" init -q
git -C "$tmp/r" add -A
git -C "$tmp/r" -c user.email=test@test -c user.name=test commit -qm init
test_npm_v=$(node -e 'const p = process.argv[1]; console.log(require(p).version)' "$(winpath "$tmp/r/npm-wrapper/package.json")")
test_skill_v=$(node -e 'const fs = require("node:fs"); const m = fs.readFileSync(process.argv[1], "utf8").match(/version:\s*"([^"]+)"/); console.log(m[1])' "$(winpath "$tmp/r/skills/flow/SKILL.md")")
git -C "$tmp/r" tag "npm@$test_npm_v"
git -C "$tmp/r" tag "v$test_skill_v"

node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --instructions >/tmp/sync_f.out 2>&1
ck 0 $? "sync-release --instructions exit code"
grep -q "Both release tags already exist. This operation was metadata repair / synchronization, not a new release." /tmp/sync_f.out && ck 0 0 "reports metadata repair note" || ck 0 1 "reports metadata repair note"
grep -q "Git tag npm@$test_npm_v ALREADY exists" /tmp/sync_f.out && ck 0 0 "reports ALREADY exists for npm tag" || ck 0 1 "reports ALREADY exists for npm tag"
grep -q "Skipping npm tag command" /tmp/sync_f.out && ck 0 0 "skips npm tag command" || ck 0 1 "skips npm tag command"
grep -q "Git tag v$test_skill_v ALREADY exists" /tmp/sync_f.out && ck 0 0 "reports ALREADY exists for skill tag" || ck 0 1 "reports ALREADY exists for skill tag"
grep -q "Skipping skill tag command" /tmp/sync_f.out && ck 0 0 "skips skill tag command" || ck 0 1 "skips skill tag command"
grep -q "git tag npm@" /tmp/sync_f.out
ck 1 $? "does not emit git tag npm@"
grep -q "git tag v" /tmp/sync_f.out
ck 1 $? "does not emit git tag v"
grep -q "git push origin npm@" /tmp/sync_f.out
ck 1 $? "does not emit git push origin npm@"
grep -q "git push origin v" /tmp/sync_f.out
ck 1 $? "does not emit git push origin v"
rm -rf "$tmp"

echo "G) unconfirmed remote tag lookup suppresses git tag commands"
tmp=$(mktemp -d)
mkdir -p "$tmp/r/skills/flow/runner" "$tmp/r/.claude-plugin" "$tmp/r/npm-wrapper" "$tmp/r/scripts"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
mkdir -p "$tmp/r/npm-wrapper/scripts"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
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
git -C "$tmp/r" init -q
git -C "$tmp/r" add -A
git -C "$tmp/r" -c user.email=test@test -c user.name=test commit -qm init
git -C "$tmp/r" remote add origin /dev/null/nonexistent

node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --instructions >/tmp/sync_g.out 2>&1
ck 0 $? "sync-release --instructions exit code with unreachable remote"
grep -q "Tag creation commands suppressed for safety" /tmp/sync_g.out && ck 0 0 "reports suppression warning" || ck 0 1 "reports suppression warning"
grep -q "git tag npm@" /tmp/sync_g.out
ck 1 $? "does not emit git tag npm@"
grep -q "git tag v" /tmp/sync_g.out
ck 1 $? "does not emit git tag v"
grep -q "git push origin npm@" /tmp/sync_g.out
ck 1 $? "does not emit git push origin npm@"
grep -q "git push origin v" /tmp/sync_g.out
ck 1 $? "does not emit git push origin v"
rm -rf "$tmp"

echo "H) --ship --dry-run is strictly non-mutating (recursive tree hash)"
tmp=$(mktemp -d)
git clone -q "$ROOT" "$tmp/r"
git -C "$tmp/r" config user.email "test@example.com"
git -C "$tmp/r" config user.name "Test Runner"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
mkdir -p "$tmp/r/docs"
cp "$ROOT/docs/release-intent.json" "$tmp/r/docs/"
git -C "$tmp/r" add scripts/ docs/release-intent.json
commit_err=$(git -C "$tmp/r" commit -qm "sync scripts" 2>&1) || {
  if ! git -C "$tmp/r" diff --cached --quiet; then
    echo "FAIL: git commit failed for scripts/: $commit_err" >&2
    exit 1
  fi
}
if [ -d "$ROOT/npm-wrapper/node_modules" ]; then
  ln -s "$ROOT/npm-wrapper/node_modules" "$tmp/r/npm-wrapper/node_modules" || {
    echo "FAIL: failed to symlink $ROOT/npm-wrapper/node_modules to $tmp/r/npm-wrapper/node_modules" >&2
    exit 1
  }
fi

before_tree_hash="$(portable_hash "$tmp/r")"
before_head="$(git -C "$tmp/r" rev-parse HEAD)"
before_tags="$(git -C "$tmp/r" tag -l)"

node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --dry-run >/tmp/sync_h.out 2>&1
ck 0 $? "--ship --dry-run exits 0"
grep -q "DRY-RUN SUCCESS" /tmp/sync_h.out && ck 0 0 "reports DRY-RUN SUCCESS" || ck 0 1 "reports DRY-RUN SUCCESS"

after_tree_hash="$(portable_hash "$tmp/r")"
[ "$before_tree_hash" = "$after_tree_hash" ] && ck 0 0 "recursive tree hash unchanged" || ck 0 1 "recursive tree hash changed"
[ "$before_head" = "$(git -C "$tmp/r" rev-parse HEAD)" ] && ck 0 0 "HEAD unchanged" || ck 0 1 "HEAD changed"
[ "$before_tags" = "$(git -C "$tmp/r" tag -l)" ] && ck 0 0 "tags unchanged" || ck 0 1 "tags changed"

# I) forced battery failure in dry-run: tree hash still unchanged
# README.md budget is 900 words (~317 used): append enough filler to breach it so
# check-doc-budgets.sh (a read-only battery step) fails, while release-surface
# coherence (tables, i18n HEAD-blob hashes) stays green.
yes "# budget breach" | head -700 >> "$tmp/r/README.md"
after_edit_tree_hash="$(portable_hash "$tmp/r")"
node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --dry-run >/tmp/sync_i.out 2>&1
ck 1 $? "dry-run fails on battery failure"
after_i_tree_hash="$(portable_hash "$tmp/r")"
[ "$after_edit_tree_hash" = "$after_i_tree_hash" ] && ck 0 0 "tree hash unchanged on failure" || ck 0 1 "tree hash changed on failure"
rm -rf "$tmp"

echo "J) fail-closed unconfirmed remote tag check aborts atomically before mutations"
tmp=$(mktemp -d)
git clone --no-tags -q "$ROOT" "$tmp/r"
git -C "$tmp/r" config user.email "test@example.com"
git -C "$tmp/r" config user.name "Test Runner"
git -C "$tmp/r" checkout -B master >/dev/null 2>&1 || true
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
mkdir -p "$tmp/r/docs"
cp "$ROOT/docs/release-intent.json" "$tmp/r/docs/"
git -C "$tmp/r" add scripts/ docs/release-intent.json
commit_err=$(git -C "$tmp/r" commit -qm "sync scripts" 2>&1) || {
  if ! git -C "$tmp/r" diff --cached --quiet; then
    echo "FAIL: git commit failed for scripts/: $commit_err" >&2
    exit 1
  fi
}
if [ -d "$ROOT/npm-wrapper/node_modules" ]; then
  ln -s "$ROOT/npm-wrapper/node_modules" "$tmp/r/npm-wrapper/node_modules" || {
    echo "FAIL: failed to symlink $ROOT/npm-wrapper/node_modules to $tmp/r/npm-wrapper/node_modules" >&2
    exit 1
  }
fi
git -C "$tmp/r" config url."/dev/null/nonexistent".insteadOf "https://github.com/manhquydev/flow-skill.git"
git -C "$tmp/r" remote set-url origin "https://github.com/manhquydev/flow-skill.git"

before_j_head="$(git -C "$tmp/r" rev-parse HEAD)"
before_j_status="$(git -C "$tmp/r" status --porcelain)"

node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes >/tmp/sync_j.out 2>&1
ck 1 $? "sync-release --ship --yes exits 1 on unconfirmed remote"
grep -q "Remote tag status could not be confirmed with origin" /tmp/sync_j.out && ck 0 0 "reports unconfirmed remote error" || ck 0 1 "reports unconfirmed remote error"
after_j_tags="$(git -C "$tmp/r" tag -l)"
[ -z "$after_j_tags" ] && ck 0 0 "zero tags created" || ck 0 1 "zero tags created"
after_j_head="$(git -C "$tmp/r" rev-parse HEAD)"
[ "$before_j_head" = "$after_j_head" ] && ck 0 0 "zero commits made" || ck 0 1 "zero commits made"
after_j_status="$(git -C "$tmp/r" status --porcelain)"
[ "$before_j_status" = "$after_j_status" ] && ck 0 0 "working tree 100% clean, zero writes" || ck 0 1 "working tree 100% clean, zero writes"
rm -rf "$tmp"

echo "K) gh release integration branches with mocked gh (existing, create-failure, create-success)"
tmp=$(mktemp -d)
git clone --bare --no-tags -q "$ROOT" "$tmp/origin.git"
git clone --no-tags -q "$tmp/origin.git" "$tmp/r"
git -C "$tmp/r" config user.email "test@example.com"
git -C "$tmp/r" config user.name "Test Runner"
checkout_err=$(git -C "$tmp/r" checkout -B master 2>&1) || {
  echo "FAIL: could not check out master in Case K fixture: $checkout_err" >&2
  exit 1
}
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-dispatch-response.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-provenance.mjs" "$ROOT/scripts/verify-attestation-with-gh.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release-run-artifact.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release.sh" "$tmp/r/scripts/"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
cp "$ROOT/.github/workflows/publish-npm-wrapper.yml" "$tmp/r/.github/workflows/"
mkdir -p "$tmp/r/npm-wrapper/scripts"
cp "$ROOT/scripts/release-eligibility.mjs" "$ROOT/scripts/release-workflow.mjs" "$tmp/r/scripts/"
cp "$ROOT/npm-wrapper/scripts/semver.mjs" "$tmp/r/npm-wrapper/scripts/"
mkdir -p "$tmp/r/docs"
cp "$ROOT/docs/release-intent.json" "$tmp/r/docs/"
cp "$ROOT/scripts/check-release-coherence.sh" "$tmp/r/scripts/"
git -C "$tmp/r" add scripts/ .github/workflows/publish-npm-wrapper.yml npm-wrapper/scripts/semver.mjs docs/release-intent.json
commit_err=$(git -C "$tmp/r" commit -qm "sync scripts" 2>&1) || {
  if ! git -C "$tmp/r" diff --cached --quiet; then
    echo "FAIL: git commit failed for scripts/: $commit_err" >&2
    exit 1
  fi
}
git -C "$tmp/r" push -q origin master
git -C "$tmp/r" config url."file://$tmp/origin.git".insteadOf "https://github.com/manhquydev/flow-skill.git"
git -C "$tmp/r" remote set-url origin "https://github.com/manhquydev/flow-skill.git"
if [ -d "$ROOT/npm-wrapper/node_modules" ]; then
  ln -s "$ROOT/npm-wrapper/node_modules" "$tmp/r/npm-wrapper/node_modules" || {
    echo "FAIL: failed to symlink $ROOT/npm-wrapper/node_modules to $tmp/r/npm-wrapper/node_modules" >&2
    exit 1
  }
fi

k_skill_v=$(node -e 'const fs = require("node:fs"); const m = fs.readFileSync(process.argv[1], "utf8").match(/version:\s*"([^"]+)"/); console.log(m[1])' "$(winpath "$tmp/r/skills/flow/SKILL.md")")
k_npm_v=$(node -e 'const p = process.argv[1]; console.log(require(p).version)' "$(winpath "$tmp/r/npm-wrapper/package.json")")
clean_k_tags() {
  if [ -n "${k_npm_v:-}" ]; then
    git -C "$tmp/origin.git" tag -d "npm@$k_npm_v" >/dev/null 2>&1 || true
    git -C "$tmp/r" tag -d "npm@$k_npm_v" >/dev/null 2>&1 || true
  fi
  if [ -n "${k_skill_v:-}" ]; then
    git -C "$tmp/origin.git" tag -d "v$k_skill_v" >/dev/null 2>&1 || true
    git -C "$tmp/r" tag -d "v$k_skill_v" >/dev/null 2>&1 || true
  fi
  for t in $(git -C "$tmp/origin.git" tag -l | tr -d '\r'); do
    git -C "$tmp/origin.git" tag -d "$t" >/dev/null 2>&1 || true
  done
  for t in $(git -C "$tmp/r" tag -l | tr -d '\r'); do
    git -C "$tmp/r" tag -d "$t" >/dev/null 2>&1 || true
  done
  [ -z "$(git -C "$tmp/origin.git" tag -l)" ] || { echo "FAIL: origin tags remain after clean_k_tags" >&2; exit 1; }
  [ -z "$(git -C "$tmp/r" tag -l)" ] || { echo "FAIL: local tags remain after clean_k_tags" >&2; exit 1; }
}
clean_k_tags

dumped_k_files=""
ck_k() {
  local expected="$1" got="$2" label="$3" outfile="${4:-}" rc="${5:-unknown}"
  if [ "$expected" = "$got" ]; then
    echo "  ok   [$label]"
    pass=$((pass+1))
  else
    echo "  FAIL [$label] expected=$expected got=$got (exit code: $rc)"
    fail=$((fail+1))
    if [ -n "$outfile" ] && [ -f "$outfile" ]; then
      case " $dumped_k_files " in
        *" $outfile "*) ;;
        *)
          dumped_k_files="$dumped_k_files $outfile"
          echo "=== Captured output ($outfile) [rc=$rc] ==="
          cat "$outfile"
          echo "=== End captured output ==="
          grep -E "FAIL: Verification step|Aborting" "$outfile" | tail -5 || true
          ;;
      esac
    fi
  fi
}
mock_bin="$tmp/bin"
mkdir -p "$mock_bin"
cat > "$mock_bin/gh" << "EOF"
#!/usr/bin/env bash
mode="${GH_MOCK_MODE:-exists}"
ci_app="${GH_MOCK_CI_APP:-github-actions}"
env_protection="${GH_MOCK_ENV_PROTECTION:-approved}"
actor_mode="${GH_MOCK_ACTOR_MODE:-valid}"

if [ "$1" = "api" ]; then
  if { [ "${GH_MOCK_DISPATCH_MODE:-}" = "skip-publish" ] || [ "${GH_MOCK_DISPATCH_MODE:-}" = "publish-success" ]; } && [ "$2" = "-X" ] && [ "$3" = "POST" ]; then
    request_body="$(cat)"
    node -e 'const fs=require("fs");fs.writeFileSync(process.argv[1],process.argv[2]);' "$GH_MOCK_STATE_FILE" "$request_body"
    printf '{"workflow_run_id":777,"run_url":"https://api.github.com/repos/manhquydev/flow-skill/actions/runs/777"}\n'
    exit 0
  fi
  case "$2" in
    user) if [ "$actor_mode" = "invalid" ]; then printf 'not-numeric\n'; else printf '12345\n'; fi; exit 0 ;;
    */actions/runs/777/jobs*)
      node -e 'console.log(JSON.stringify({total_count:2,jobs:[{run_id:777,run_attempt:1,name:"eligibility",status:"completed",conclusion:"success"},{run_id:777,run_attempt:1,name:"publish",status:"completed",conclusion:process.env.GH_MOCK_PUBLISH_CONCLUSION||"success"}]}));'
      exit 0
      ;;
    */actions/runs/777)
      node -e 'const i=JSON.parse(require("fs").readFileSync(process.env.GH_MOCK_STATE_FILE,"utf8")).inputs;console.log(JSON.stringify({id:777,actor:{id:12345},head_sha:i.expected_sha,path:".github/workflows/publish-npm-wrapper.yml",event:"workflow_dispatch",display_title:`Publisher ${i.expected_sha} ${i.expected_version} ${i.dispatch_id}`,status:"completed",conclusion:"success",run_attempt:1}));'
      exit 0
      ;;
    *commits/*/check-runs*)
      head_sha=$(echo "$2" | sed -n 's|.*/commits/\([^/]*\)/check-runs.*|\1|p')
      cat << JSON
{"check_runs":[{"id":1,"name":"all-checks-passed","head_sha":"$head_sha","status":"completed","conclusion":"success","app":{"slug":"$ci_app"}}]}
JSON
      exit 0
      ;;
    *environments/npm-publish/deployment-branch-policies*)
      if [ "$env_protection" = "wrong" ]; then
        printf '{"branch_policies":[{"type":"tag","name":"npm@*"}]}\n'
      else
        printf '{"branch_policies":[{"type":"branch","name":"master"}]}\n'
      fi
      exit 0
      ;;
    *environments/npm-publish*)
      if [ "$env_protection" = "error" ]; then echo "gh: Not Found (HTTP 404)" >&2; exit 1; fi
      printf '{"name":"npm-publish","deployment_branch_policy":{"protected_branches":false,"custom_branch_policies":true},"protection_rules":[]}\n'
      exit 0
      ;;
  esac

if [ "$1" = "run" ] && [ "$2" = "watch" ]; then
  exit 0
fi
fi

if [ "$1" = "release" ] && [ "$2" = "view" ]; then
  if [ "$mode" = "exists" ]; then
    echo "{\"tagName\":\"$3\"}"
    exit 0
  elif [ "$mode" = "auth_error" ]; then
    echo "HTTP 401: Bad credentials (mock auth failure)" >&2
    exit 1
  else
    echo "release not found" >&2
    exit 1
  fi
fi
if [ "$1" = "release" ] && [ "$2" = "create" ]; then
  if [ "$mode" = "create_fail" ]; then
    echo "mock gh release create error" >&2
    exit 1
  else
    echo "https://github.com/manhquydev/flow-skill/releases/tag/$3"
    exit 0
  fi
fi
exit 0
EOF
chmod +x "$mock_bin/gh"
cat > "$mock_bin/gh.cmd" << "EOF"
@bash "%~dp0gh" %*
EOF

# K1: missing dispatch receipt fails closed; the workflow's own eligibility fixtures cover the disabled latch.
GH_MOCK_MODE="exists" PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k1.out" 2>&1
k1_rc=$?
ck_k 1 $k1_rc "K1: live release refuses dispatch without exact workflow run receipt" "$tmp/k1.out" $k1_rc
grep -q "workflow dispatch returned no run details" "$tmp/k1.out" && ck_k 0 0 "K1: missing run receipt is the refusal reason" "$tmp/k1.out" $k1_rc || ck_k 0 1 "K1: missing run receipt is the refusal reason" "$tmp/k1.out" $k1_rc
[ -z "$(git -C "$tmp/r" tag -l)" ] && ck_k 0 0 "K1: no local tags without verified publisher run" || ck_k 0 1 "K1: no local tags without verified publisher run"

clean_k_tags
# K2: overall success cannot authorize tags when the live publish job was skipped.
GH_MOCK_DISPATCH_MODE="skip-publish" GH_MOCK_PUBLISH_CONCLUSION="skipped" GH_MOCK_STATE_FILE="$tmp/k2-state.json" PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k2.out" 2>&1
k2_rc=$?
ck_k 1 $k2_rc "K2: skipped live publish job blocks release tagging" "$tmp/k2.out" $k2_rc
grep -q "publisher publish job conclusion must be success" "$tmp/k2.out" && ck_k 0 0 "K2: skipped publish outcome is the refusal reason" "$tmp/k2.out" $k2_rc || ck_k 0 1 "K2: skipped publish outcome is the refusal reason" "$tmp/k2.out" $k2_rc
[ -z "$(git -C "$tmp/r" tag -l)" ] && ck_k 0 0 "K2: no tags created when publish was skipped" || ck_k 0 1 "K2: no tags created when publish was skipped"

clean_k_tags
# K3: successful publish outcome without retained verification receipts must fail closed before tags.
GH_MOCK_DISPATCH_MODE="publish-success" GH_MOCK_PUBLISH_CONCLUSION="success" GH_MOCK_STATE_FILE="$tmp/k3-state.json" PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k3.out" 2>&1
k3_rc=$?
ck_k 1 $k3_rc "K3: publish run without retained artifact cannot be finalized" "$tmp/k3.out" $k3_rc
grep -q "release-artifact.json" "$tmp/k3.out" && ck_k 0 0 "K3: missing artifact receipt blocks promotion" "$tmp/k3.out" $k3_rc || ck_k 0 1 "K3: missing artifact receipt blocks promotion" "$tmp/k3.out" $k3_rc
[ -z "$(git -C "$tmp/r" tag -l)" ] && ck_k 0 0 "K3: no tags created without retained verification artifact" || ck_k 0 1 "K3: no tags created without retained verification artifact"

clean_k_tags
# K4: malformed authenticated actor identity refuses before dispatch.
GH_MOCK_ACTOR_MODE="invalid" PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k4.out" 2>&1
k4_rc=$?
ck_k 1 $k4_rc "K4: sync-release refuses malformed authenticated actor ID" "$tmp/k4.out" $k4_rc
grep -q "did not return a valid authenticated actor ID" "$tmp/k4.out" && ck_k 0 0 "K4: actor validation is the refusal reason" "$tmp/k4.out" $k4_rc || ck_k 0 1 "K4: actor validation is the refusal reason" "$tmp/k4.out" $k4_rc
[ -z "$(git -C "$tmp/r" tag -l)" ] && ck_k 0 0 "K4: no local tags without valid actor identity" || ck_k 0 1 "K4: no local tags without valid actor identity"

clean_k_tags
# Test K5: Spoofed CI check app (e.g. app slug "malicious-bot" instead of "github-actions") fails closed:
GH_MOCK_CI_APP="malicious-bot" PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k5.out" 2>&1
k5_rc=$?
ck_k 1 $k5_rc "K5: sync-release exits 1 when CI check run app is not github-actions" "$tmp/k5.out" $k5_rc
grep -q "expected authoritative \"github-actions\"" "$tmp/k5.out" && ck_k 0 0 "K5: output flags non-authoritative app slug" "$tmp/k5.out" $k5_rc || ck_k 0 1 "K5: output flags non-authoritative app slug" "$tmp/k5.out" $k5_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k5.out"
ck_k 1 $? "K5: output does NOT contain 'RELEASE SHIP SUCCESSFUL'" "$tmp/k5.out" $k5_rc
grep -qE "Git tag .* already exists" "$tmp/k5.out"
ck_k 1 $? "K5: output does NOT contain 'Git tag already exists'" "$tmp/k5.out" $k5_rc
[ -z "$(git -C "$tmp/r" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K5: zero tags created on CI app spoof" || ck_k 0 1 "K5: zero tags created on CI app spoof"

clean_k_tags
# Test K6: master-only deployment policy permits exactly branch master; tag rules fail closed.
GH_MOCK_ENV_PROTECTION="wrong" PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k6.out" 2>&1
k6_rc=$?
ck_k 1 $k6_rc "K6: rejects tag deployment policy before tags" "$tmp/k6.out" $k6_rc
grep -q "allow exactly branch master" "$tmp/k6.out" && ck_k 0 0 "K6: reports exact master-only requirement" "$tmp/k6.out" $k6_rc || ck_k 0 1 "K6: reports exact master-only requirement" "$tmp/k6.out" $k6_rc
[ -z "$(git -C "$tmp/r" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K6: zero tags created when deployment policy is wrong" || ck_k 0 1 "K6: zero tags created when deployment policy is wrong"


clean_k_tags
# Test K8: Non-canonical repository remote URL refuses promotion fail-closed before any commit/tag/push:
git -C "$tmp/r" config url."file://$tmp/origin.git".insteadOf "https://github.com/other-org/malicious-repo.git"
git -C "$tmp/r" remote set-url origin "https://github.com/other-org/malicious-repo.git"
PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k8.out" 2>&1
k8_rc=$?
ck_k 1 $k8_rc "K8: sync-release exits 1 on non-canonical repository remote" "$tmp/k8.out" $k8_rc
grep -q "not an accepted canonical repository URL" "$tmp/k8.out" && ck_k 0 0 "K8: output reports non-canonical remote error" "$tmp/k8.out" $k8_rc || ck_k 0 1 "K8: output reports non-canonical remote error" "$tmp/k8.out" $k8_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k8.out"
ck_k 1 $? "K8: output does NOT contain 'RELEASE SHIP SUCCESSFUL'" "$tmp/k8.out" $k8_rc
[ -z "$(git -C "$tmp/r" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K8: zero tags created on wrong remote" || ck_k 0 1 "K8: zero tags created on wrong remote"

clean_k_tags
# Test K9: Credential-bearing or invalid remote origin fails closed before any tag/push without leaking credentials in output:
git -C "$tmp/r" remote set-url origin "https://user:SECRET_SENTINEL@invalid.example/manhquydev/flow-skill.git"
PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k9.out" 2>&1
k9_rc=$?
ck_k 1 $k9_rc "K9: sync-release exits 1 on credential-bearing remote at evil host" "$tmp/k9.out" $k9_rc
grep -q "not an accepted canonical repository URL" "$tmp/k9.out" && ck_k 0 0 "K9: output reports sanitized canonical remote error" "$tmp/k9.out" $k9_rc || ck_k 0 1 "K9: output reports sanitized canonical remote error" "$tmp/k9.out" $k9_rc
grep -q "SECRET_SENTINEL" "$tmp/k9.out"
ck_k 1 $? "K9: output has ZERO occurrence of SECRET_SENTINEL (no credential leak)" "$tmp/k9.out" $k9_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k9.out"
ck_k 1 $? "K9: output does NOT contain 'RELEASE SHIP SUCCESSFUL'" "$tmp/k9.out" $k9_rc
[ -z "$(git -C "$tmp/r" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K9: zero tags created on credential-bearing remote" || ck_k 0 1 "K9: zero tags created on credential-bearing remote"
[ -z "$(git -C "$tmp/origin.git" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K9: zero remote tags pushed on credential-bearing remote" || ck_k 0 1 "K9: zero remote tags pushed on credential-bearing remote"

clean_k_tags
# Test K10: Lookalike evil host with unanchored github.com path fails closed before any tag/push without leaking URL:
git -C "$tmp/r" remote set-url origin "https://evil.example/github.com/manhquydev/flow-skill"
PATH="$mock_bin:$PATH" node "$(winpath "$tmp/r/scripts/sync-release.mjs")" --ship --yes > "$tmp/k10.out" 2>&1
k10_rc=$?
ck_k 1 $k10_rc "K10: sync-release exits 1 on lookalike host with embedded github.com path" "$tmp/k10.out" $k10_rc
grep -q "not an accepted canonical repository URL" "$tmp/k10.out" && ck_k 0 0 "K10: output reports sanitized canonical remote error" "$tmp/k10.out" $k10_rc || ck_k 0 1 "K10: output reports sanitized canonical remote error" "$tmp/k10.out" $k10_rc
grep -q "evil.example" "$tmp/k10.out"
ck_k 1 $? "K10: output has ZERO occurrence of evil.example (never prints raw URL)" "$tmp/k10.out" $k10_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k10.out"
ck_k 1 $? "K10: output does NOT contain 'RELEASE SHIP SUCCESSFUL'" "$tmp/k10.out" $k10_rc
[ -z "$(git -C "$tmp/r" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K10: zero tags created on lookalike remote" || ck_k 0 1 "K10: zero tags created on lookalike remote"
[ -z "$(git -C "$tmp/origin.git" tag -l "npm@$k_npm_v")" ] && ck_k 0 0 "K10: zero remote tags pushed on lookalike remote" || ck_k 0 1 "K10: zero remote tags pushed on lookalike remote"
git -C "$tmp/r" remote set-url origin "https://github.com/manhquydev/flow-skill.git"
git -C "$tmp/r" config --unset url."file://$tmp/origin.git".insteadOf "https://github.com/other-org/malicious-repo.git" || true
rm -rf "$tmp"

echo "L) npm spawn helper regression: battery must invoke node, never npm.cmd"
# Windows Node 22 refuses execFileSync of a .cmd (spawnSync EINVAL). Assert the exported
# helpers resolve to process.execPath and never reference npm.cmd, and that importing the
# module does not execute the CLI (main() is guarded by the pathToFileURL entry check).
tmp_l=$(mktemp -d)
L_IMPORTER="$tmp_l/importer.mjs"
cat > "$L_IMPORTER" << 'EOF'
import { pathToFileURL } from 'node:url';
const target = pathToFileURL(process.argv[2]).href;
const mod = await import(target);
const assert = (await import('node:assert')).strict;
assert.equal(mod.npmSpawnHelper().cmd, process.execPath, 'sync helper argv[0] must be process.execPath');
assert.equal(mod.npmTestHelper().cmd, process.execPath, 'test helper argv[0] must be process.execPath');
const all = JSON.stringify([mod.npmSpawnHelper(), mod.npmTestHelper()]);
assert.ok(!all.includes('npm.cmd'), 'no helper may reference npm.cmd');
assert.ok(all.includes('scripts/sync.mjs'), 'sync step must run node scripts/sync.mjs');
assert.ok(all.includes('--test'), 'test step must run node --test');
assert.equal(typeof mod.buildWin32GhCommandLine, 'function', 'buildWin32GhCommandLine must be exported');
const plainCmd = mod.buildWin32GhCommandLine(['release', 'view', 'v0.34.4', '--json', 'tagName']);
assert.equal(plainCmd, 'gh release view v0.34.4 --json tagName', 'plain args must stay unquoted');
assert.ok(plainCmd.startsWith('gh '), 'cmdline must start with bare gh and space');
assert.ok(!plainCmd.startsWith('"gh"'), 'bare gh token must never be quoted');
const quotedCmd = mod.buildWin32GhCommandLine(['release', 'create', 'v0.34.4', '--title', 'v0.34.4 (rc & test)', '--notes-file', 'CHANGELOG.md']);
assert.ok(quotedCmd.includes('"v0.34.4 (rc & test)"'), 'args with spaces or metacharacters must be quoted');
console.log('HELPERS OK');
EOF
node "$(winpath "$L_IMPORTER")" "$(winpath "$ROOT/scripts/sync-release.mjs")" > "$tmp_l/l.out" 2>&1
l_rc=$?
ck 0 $l_rc "npm spawn helper uses node (no npm.cmd); import does not run CLI"
if [ "$l_rc" -ne 0 ]; then
  cat "$tmp_l/l.out" >&2
fi
if grep -q "HELPERS OK" "$tmp_l/l.out"; then
  ck 0 0 "helper assertions executed"
else
  ck 0 1 "helper assertions executed"
  cat "$tmp_l/l.out" >&2
fi
rm -rf "$tmp_l"

echo "M) CLI entry guard symlink regression: symlinked script must execute main()"
# On macOS, /var/folders is a symlink to /private/var/folders. If the direct-run guard
# compares raw URLs without realpathSync, main() silently no-ops (exit 0, empty output).
# Assert that executing sync-release.mjs via a symlinked path runs main() and prints output.
tmp_m=$(mktemp -d)
sym_script="$tmp_m/sym_sync_release.mjs"
ln -s "$ROOT/scripts/sync-release.mjs" "$sym_script"
if [ ! -L "$sym_script" ]; then
  echo "  skip [M: platform cannot create symlinks (ln -s created a copy); macOS/Linux symlink alias regression asserted there]"
else
  m_target="$(winpath "$sym_script")"
  node "$m_target" --check > "$tmp_m/m.out" 2>&1
  m_rc=$?

  ck 0 $m_rc "symlinked sync-release --check exits 0"
  [ "$m_rc" -ne 0 ] && cat "$tmp_m/m.out" >&2
  [ -s "$tmp_m/m.out" ] && ck 0 0 "symlinked invocation stdout is non-empty (not a silent exit)" || { ck 0 1 "symlinked invocation stdout is non-empty (not a silent exit)"; cat "$tmp_m/m.out" >&2; }
  grep -q "PASS: All release surfaces coherent" "$tmp_m/m.out" && ck 0 0 "symlinked invocation runs main() and reports PASS" || { ck 0 1 "symlinked invocation runs main() and reports PASS"; cat "$tmp_m/m.out" >&2; }
fi
rm -rf "$tmp_m"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
