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
base_npm_v=$(node -p 'require("'"$tmp"'/r/npm-wrapper/package.json").version')
base_skill_v=$(node -e 'const m = require("fs").readFileSync("'"$tmp"'/r/skills/flow/SKILL.md", "utf8").match(/version:\s*"([^"]+)"/); console.log(m[1])')
prerelease_v="${base_npm_v}-next.0"
node -e '
  const fs = require("node:fs");
  const p = process.argv[1];
  const pkg = JSON.parse(fs.readFileSync(p, "utf8"));
  pkg.version = process.argv[2];
  fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + "\n");
' "$tmp/r/npm-wrapper/package.json" "$prerelease_v"
# Add changelog entry for the prerelease in npm-wrapper/CHANGELOG.md
node -e '
  const fs = require("node:fs");
  const p = process.argv[1];
  const v = process.argv[2];
  fs.writeFileSync(p, "## [" + v + "] - 2026-10-15\n\n- Pre-release test.\n\n" + fs.readFileSync(p, "utf8"));
' "$tmp/r/npm-wrapper/CHANGELOG.md" "$prerelease_v"

node "$tmp/r/scripts/sync-release.mjs" --sync >/tmp/sync_e.out 2>&1
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
test_npm_v=$(node -p 'require("'"$tmp"'/r/npm-wrapper/package.json").version')
test_skill_v=$(node -e 'const m = require("fs").readFileSync("'"$tmp"'/r/skills/flow/SKILL.md", "utf8").match(/version:\s*"([^"]+)"/); console.log(m[1])')
git -C "$tmp/r" tag "npm@$test_npm_v"
git -C "$tmp/r" tag "v$test_skill_v"

node "$tmp/r/scripts/sync-release.mjs" --instructions >/tmp/sync_f.out 2>&1
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

node "$tmp/r/scripts/sync-release.mjs" --instructions >/tmp/sync_g.out 2>&1
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
cp "$ROOT/scripts/release.sh" "$tmp/r/scripts/"
git -C "$tmp/r" add scripts/
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
else
  ln -s "$ROOT/npm-wrapper/node_modules" "$tmp/r/npm-wrapper/node_modules" 2>&1 || true
fi

before_tree_hash="$(portable_hash "$tmp/r")"
before_head="$(git -C "$tmp/r" rev-parse HEAD)"
before_tags="$(git -C "$tmp/r" tag -l)"

node "$tmp/r/scripts/sync-release.mjs" --ship --dry-run >/tmp/sync_h.out 2>&1
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
node "$tmp/r/scripts/sync-release.mjs" --ship --dry-run >/tmp/sync_i.out 2>&1
ck 1 $? "dry-run fails on battery failure"
after_i_tree_hash="$(portable_hash "$tmp/r")"
[ "$after_edit_tree_hash" = "$after_i_tree_hash" ] && ck 0 0 "tree hash unchanged on failure" || ck 0 1 "tree hash changed on failure"
rm -rf "$tmp"

echo "J) fail-closed unconfirmed remote tag check aborts atomically before mutations"
tmp=$(mktemp -d)
git clone --no-tags -q "$ROOT" "$tmp/r"
git -C "$tmp/r" config user.email "test@example.com"
git -C "$tmp/r" config user.name "Test Runner"
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release.sh" "$tmp/r/scripts/"
git -C "$tmp/r" add scripts/
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
else
  ln -s "$ROOT/npm-wrapper/node_modules" "$tmp/r/npm-wrapper/node_modules" 2>&1 || true
fi
git -C "$tmp/r" remote set-url origin /dev/null/nonexistent

before_j_head="$(git -C "$tmp/r" rev-parse HEAD)"
before_j_status="$(git -C "$tmp/r" status --porcelain)"

node "$tmp/r/scripts/sync-release.mjs" --ship --yes >/tmp/sync_j.out 2>&1
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
git clone --bare -q "$ROOT" "$tmp/origin.git"
git clone -q "$tmp/origin.git" "$tmp/r"
git -C "$tmp/r" config user.email "test@example.com"
git -C "$tmp/r" config user.name "Test Runner"
checkout_err=$(git -C "$tmp/r" checkout -B master 2>&1) || {
  echo "FAIL: could not check out master in Case K fixture: $checkout_err" >&2
  exit 1
}
cp "$ROOT/scripts/sync-release.mjs" "$tmp/r/scripts/"
cp "$ROOT/scripts/release.sh" "$tmp/r/scripts/"
git -C "$tmp/r" add scripts/
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
else
  ln -s "$ROOT/npm-wrapper/node_modules" "$tmp/r/npm-wrapper/node_modules" 2>&1 || true
fi

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

# Test K1: Mock gh release view returns 0 (existing release):
# Assert output contains "GitHub Release for v" and "already exists. Skipping release creation."
GH_MOCK_MODE="exists" PATH="$mock_bin:$PATH" node "$tmp/r/scripts/sync-release.mjs" --ship --yes > "$tmp/k1.out" 2>&1
k1_rc=$?
ck_k 0 $k1_rc "K1: sync-release exits 0 when release already exists" "$tmp/k1.out" $k1_rc
grep -q "GitHub Release for v" "$tmp/k1.out" && ck_k 0 0 "K1: output contains 'GitHub Release for v'" "$tmp/k1.out" $k1_rc || ck_k 0 1 "K1: output contains 'GitHub Release for v'" "$tmp/k1.out" $k1_rc
grep -q "already exists. Skipping release creation." "$tmp/k1.out" && ck_k 0 0 "K1: output contains 'already exists. Skipping release creation.'" "$tmp/k1.out" $k1_rc || ck_k 0 1 "K1: output contains 'already exists. Skipping release creation.'" "$tmp/k1.out" $k1_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k1.out" && ck_k 0 0 "K1: output contains 'RELEASE SHIP SUCCESSFUL'" "$tmp/k1.out" $k1_rc || ck_k 0 1 "K1: output contains 'RELEASE SHIP SUCCESSFUL'" "$tmp/k1.out" $k1_rc

# Test K2: Mock gh release view returns 1 (not found) and gh release create fails with exit 1:
# Assert exit code is 1.
# Assert output contains "FAIL: Could not create GitHub Release for v"
# Assert output does NOT contain "RELEASE SHIP SUCCESSFUL"
GH_MOCK_MODE="create_fail" PATH="$mock_bin:$PATH" node "$tmp/r/scripts/sync-release.mjs" --ship --yes > "$tmp/k2.out" 2>&1
k2_rc=$?
ck_k 1 $k2_rc "K2: sync-release exits 1 when gh release create fails" "$tmp/k2.out" $k2_rc
grep -q "FAIL: Could not create GitHub Release for v" "$tmp/k2.out" && ck_k 0 0 "K2: output contains 'FAIL: Could not create GitHub Release for v'" "$tmp/k2.out" $k2_rc || ck_k 0 1 "K2: output contains 'FAIL: Could not create GitHub Release for v'" "$tmp/k2.out" $k2_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k2.out"
ck_k 1 $? "K2: output does NOT contain 'RELEASE SHIP SUCCESSFUL'" "$tmp/k2.out" $k2_rc

# Test K3: Mock gh release view returns 1 and gh release create succeeds with exit 0:
# Assert output contains "GitHub Release created for v"
GH_MOCK_MODE="create_success" PATH="$mock_bin:$PATH" node "$tmp/r/scripts/sync-release.mjs" --ship --yes > "$tmp/k3.out" 2>&1
k3_rc=$?
ck_k 0 $k3_rc "K3: sync-release exits 0 when gh release create succeeds" "$tmp/k3.out" $k3_rc
grep -q "GitHub Release created for v" "$tmp/k3.out" && ck_k 0 0 "K3: output contains 'GitHub Release created for v'" "$tmp/k3.out" $k3_rc || ck_k 0 1 "K3: output contains 'GitHub Release created for v'" "$tmp/k3.out" $k3_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k3.out" && ck_k 0 0 "K3: output contains 'RELEASE SHIP SUCCESSFUL'" "$tmp/k3.out" $k3_rc || ck_k 0 1 "K3: output contains 'RELEASE SHIP SUCCESSFUL'" "$tmp/k3.out" $k3_rc

# Test K4: Mock gh release view fails with auth/network error:
# Assert exit code 1, output contains "Could not check GitHub Release status", and does NOT contain "RELEASE SHIP SUCCESSFUL"
GH_MOCK_MODE="auth_error" PATH="$mock_bin:$PATH" node "$tmp/r/scripts/sync-release.mjs" --ship --yes > "$tmp/k4.out" 2>&1
k4_rc=$?
ck_k 1 $k4_rc "K4: sync-release exits 1 when gh release view has auth/network error" "$tmp/k4.out" $k4_rc
grep -q "Could not check GitHub Release status" "$tmp/k4.out" && ck_k 0 0 "K4: output contains 'Could not check GitHub Release status'" "$tmp/k4.out" $k4_rc || ck_k 0 1 "K4: output contains 'Could not check GitHub Release status'" "$tmp/k4.out" $k4_rc
grep -q "RELEASE SHIP SUCCESSFUL" "$tmp/k4.out"
ck_k 1 $? "K4: output does NOT contain 'RELEASE SHIP SUCCESSFUL'" "$tmp/k4.out" $k4_rc
rm -rf "$tmp"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
