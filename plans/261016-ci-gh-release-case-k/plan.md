# Plan: CI GitHub Release Case K Diagnostics, Pack-Rehearsal Physical Path, and macOS/Windows Guard Fixes

## Who Is Hurt
Maintainers; macOS and Windows CI pipelines ran red on `tests/test_sync_release.sh` Case K, blocking release confidence across multiple operating systems.

## Evidence & Confirmed Root Causes
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
  - On macOS, default `TMPDIR` is located under `/var/folders/...`, where `/var` is a system symlink pointing to `/private/var`. The installer's `assertNoAncestorSymlinks` deliberately lstats every ancestor segment as spelled to prevent symlink traversal attacks; raw `mktemp -d` paths triggered the check. Ubuntu has no `/var` symlink, so Case K passed on Linux.

- Run 38854333940, job 116822620461 (Windows bash-suite) on commit `d109f38`:
  - macOS and Ubuntu passed; Windows died in Step 4/8 across Case K and earlier cases:
    ```
    Error: spawnSync npm.cmd EINVAL (errno -4071) at scripts/sync-release.mjs:457
    ```
  - Node 22 on Windows refuses `execFileSync('npm.cmd', ...)` without a shell. The same pattern existed in the live battery (`npm.cmd test --prefix npm-wrapper`).

- Run 38859524391, job 116838395958 (macOS bash-suite) on commit `70e7828`:
  - Every `test_sync_release` case exited 0 with empty output (`k1.out`..`k4.out` were 0 bytes).
  - The direct-run guard `import.meta.url === pathToFileURL(process.argv[1]).href` failed on macOS because Node resolves `import.meta.url` to the physical realpath (`file:///private/var/...`) while `process.argv[1]` had the `/var/folders/...` spelling. `main()` was never invoked.

## Required Fixes
1. `scripts/pack-rehearsal.sh` canonicalizes all temp directories (`WORKDIR`, `PREFIX`, `DEST`) to physical paths using `to_physical` (`(cd "$dir" && pwd -P)`). On macOS, this resolves `/var/folders/...` to `/private/var/folders/...`, eliminating the symlinked `/var` ancestor while keeping installer security checks fully enforced.
2. `scripts/sync-release.mjs` replaces both npm spawn sites with `process.execPath` (node), matching `npm-wrapper/package.json`:
   - sync step: `node scripts/sync.mjs` with cwd `npm-wrapper` (`npmSpawnHelper()`).
   - live battery test: pretest `node scripts/sync.mjs`, then `node --test --test-concurrency=1` on the same test files listed in `npm-wrapper/package.json` "test" (`npmTestHelper()`). No `npm.cmd`, no `shell: true`, no `--skip-battery`.
3. `scripts/sync-release.mjs` CLI entry guard uses `realpathSync(fileURLToPath(import.meta.url)) === realpathSync(process.argv[1])` (with fallback to URL comparison on error) so symlink aliases like macOS `/var` -> `/private/var` match correctly while preventing dynamic imports from calling `main()`.
4. `tests/test_sync_release.sh` Case M asserts that executing `sync-release.mjs` via a symlink invokes `main()` and produces non-empty output, catching any future realpath guard regressions on Linux.
5. `tests/test_sync_release.sh` Case L asserts, via a real file importer, that both exported helpers set `cmd` to `process.execPath`, never reference `npm.cmd`, and importing the module does not execute the CLI.
6. `tests/test_flow_rules.sh` case D: when `cygpath` exists (Windows Git Bash), translates `.aider.conf.yml` path via `cygpath -w` for Windows python.
7. `npm-wrapper/test/installer.test.mjs` regression: verifies symlink-spelled dest refusal and physical dest acceptance.

## Acceptance Criteria
1. Full end-to-end integration coverage of `node scripts/sync-release.mjs --ship --yes` remains intact in Case K across all four mocked `gh` modes.
2. `scripts/pack-rehearsal.sh` canonicalizes `WORKDIR`, `PREFIX`, and `DEST` using physical path resolution.
3. Refusal of unexpected ancestor symlinks in the installer is 100% preserved (no skip flags, no internal realpath bypass).
4. `scripts/sync-release.mjs` CLI entry guard uses `realpathSync` on both sides to handle symlink aliases like macOS `/var`.
5. Both npm spawn sites in `scripts/sync-release.mjs` use `process.execPath`; no `npm.cmd` remains.
6. All 59 assertions in `tests/test_sync_release.sh` pass locally, all 42 in `tests/test_flow_rules.sh`, and `node scripts/sync-release.mjs --check` exits 0.

## Non-Regressions
- Dry-run mode (`--ship --dry-run`) remains strictly read-only and non-mutating.
- Fail-closed remote abort behavior remains preserved (Cases F, G, J).
- Live verification battery still runs in full on real `--ship --yes` invocations.
- No new runtime dependencies, bash 3.2 compatibility preserved.
- No edits to `website/` or eval STOP zones.

## Rollback
Revert the branch commit or delete branch `fix/ci-gh-release-case-k`.
