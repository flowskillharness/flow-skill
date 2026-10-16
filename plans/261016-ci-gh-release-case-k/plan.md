# Plan: CI GitHub Release Case K Diagnostics & Pack-Rehearsal Physical Path Fix

## Who Is Hurt
Maintainers; macOS and Windows CI pipelines ran red on `tests/test_sync_release.sh` Case K, blocking release confidence across multiple operating systems.

## Evidence & Confirmed Root Cause
- GitHub Actions run 38741314141, job 116443435209 (macOS bash-suite) and the Windows job of the same run:
  - Case K banner, followed by 9 assertion failures with node output suppressed into `$tmp/k*.out`.
- PR #35 run 38850224190, job 116809585980 (macOS bash-suite) on commit `a97837a`:
  - With diagnostic output enabled in Case K, captured `k1.out` exposed the exact abort:
    ```
    FAIL: Verification step "pack-rehearsal" failed (exit code 1). Aborting release.
    ```
  - Inside `scripts/pack-rehearsal.sh`, the real project install invocation (`"$BIN" --yes --project --dir "$DEST"`) aborted with:
    ```
    ✗ claude -> /var/folders/.../tmp.Cy1A3fT1Yi/.claude/skills/flow  (destination ancestor symlink refused: /var)
    ```
  - On macOS, default `TMPDIR` is located under `/var/folders/...`, where `/var` is a system symlink pointing to `/private/var`.
  - The installer's `assertNoAncestorSymlinks` deliberately lstats every ancestor segment as spelled to prevent symlink traversal attacks. Because `pack-rehearsal.sh` passed raw `mktemp -d` paths, the `/var` segment triggered the security check.
  - Ubuntu has no `/var` symlink, so Case K passed on Linux.

## Required Fix
1. In `scripts/pack-rehearsal.sh`, canonicalize all temp directories (`WORKDIR`, `PREFIX`, `DEST`) to physical paths using `to_physical` (`(cd "$dir" && pwd -P)`). On macOS, this resolves `/var/folders/...` to `/private/var/folders/...`, eliminating the symlinked `/var` ancestor while keeping installer security checks fully enforced.
2. In `npm-wrapper/test/installer.test.mjs`, add a regression test confirming that:
   - A destination path spelled through an ancestor symlink continues to be refused (`destination ancestor symlink refused`).
   - A destination path using the physical path (`pwd -P` / `realpathSync`) succeeds without error.
3. In `tests/test_sync_release.sh`, retain the four `--ship --yes` integrations in Case K, failure output dumping (`ck_k`), worktree master branch safety, and safe node_modules symlink handling.

## Acceptance Criteria
1. Full end-to-end integration coverage of `node scripts/sync-release.mjs --ship --yes` remains intact in Case K across all four mocked `gh` modes.
2. `scripts/pack-rehearsal.sh` canonicalizes `WORKDIR`, `PREFIX`, and `DEST` using physical path resolution (`cd "$dir" && pwd -P`).
3. Refusal of unexpected ancestor symlinks in the installer is 100% preserved (no skip flags, no internal realpath bypass).
4. Regression test in `npm-wrapper/test/installer.test.mjs` verifies symlink-spelled dest refusal and physical dest acceptance.
5. All 54 assertions in `tests/test_sync_release.sh` pass locally.
6. `npm test --prefix npm-wrapper` passes all 68 tests cleanly.

## Non-Regressions
- Dry-run mode (`--ship --dry-run`) remains strictly read-only and non-mutating.
- Fail-closed remote abort behavior remains preserved (Cases F, G, J).
- Live verification battery still runs in full on real `--ship --yes` invocations.
- No new runtime dependencies, bash 3.2 compatibility preserved.
- No edits to `website/` or eval STOP zones.

## Rollback
Revert the branch commit or delete branch `fix/ci-gh-release-case-k`.
