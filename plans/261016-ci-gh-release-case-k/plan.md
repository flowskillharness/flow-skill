# Plan: CI GitHub Release Case K Diagnostics & Failure Visibility

## Who Is Hurt
Maintainers; macOS and Windows CI pipelines run red on `tests/test_sync_release.sh` Case K, blocking release confidence across multiple operating systems.

## Evidence
- GitHub Actions run 38741314141, job 116443435209 (macOS bash-suite) and the Windows job of the same run:
  - Case K banner, then git's "On branch master / nothing to commit, working tree clean", followed by 9 assertion failures.
  - K1 and K3 exited 1 instead of 0. Expected strings ("GitHub Release for v", "already exists. Skipping release creation.", "RELEASE SHIP SUCCESSFUL", "GitHub Release created for v", "FAIL: Could not create GitHub Release for v", "Could not check GitHub Release status") never appeared.
  - K2 and K4 exit-code checks passed (exit 1), but message checks failed.
  - Test redirected node output to `$tmp/k*.out`, completely hiding the real abort line in CI logs.
- Current master HEAD `479efff4b4dd68e36f689858c17b3ba1cc8bcf12` macOS job failed the same step (run 38843168819).

## Current Status: macOS Abort Unproven
The macOS cause remains strictly unconfirmed until a CI log captures and displays `k*.out`. On local Linux, the full Case K integration suite passes completely (all 13 assertions in Case K pass, full battery runs and succeeds). Therefore, this change does not speculate or inject an unproven macOS fix, but makes any future failure immediately loud and diagnostic.

## Hypothesis
Case K executes `node scripts/sync-release.mjs --ship --yes` under mocked `gh`. In CI on macOS and Windows, the release pipeline exits 1 prior to the GitHub Release view/create block. Because standard output and error were redirected to `$tmp/k*.out`, the exact failing step or error condition was obscured. Additionally, when tests are executed in isolated branch worktrees where HEAD is not `master`, `sync-release.mjs` fails when pushing to `origin master`.

## Acceptance Criteria
1. Full end-to-end integration coverage of `node scripts/sync-release.mjs --ship --yes` remains intact in Case K across all four mocked `gh` modes (`exists`, `create_fail`, `create_success`, `auth_error`).
2. When any assertion fails in Case K, captured `$tmp/k*.out` and process exit codes are printed to stderr/stdout along with failing verification step markers, ensuring CI logs expose the exact abort line.
3. Test fixture explicitly switches the cloned test repo to branch `master` (`git checkout -B master`) so branch pushes succeed consistently regardless of current worktree branch.
4. `ln -s` node_modules guards against nonexistent directories to avoid false failures on platforms without symlink privilege or when node_modules is absent.
5. All 54 assertions in `tests/test_sync_release.sh` pass locally on Linux.
6. `node scripts/sync-release.mjs --check` passes cleanly (exit 0).

## Baseline
- Ubuntu bash-suite: passes.
- macOS bash-suite: 9 Case K assertion failures.
- Local Linux baseline: 54 passed, 0 failed.

## Non-Regressions
- Dry-run mode (`--ship --dry-run`) remains strictly read-only and non-mutating (Case H).
- Fail-closed remote abort behavior remains preserved (Cases F, G, J).
- Live verification battery still runs in full on real `--ship --yes` invocations.
- No new runtime dependencies, bash 3.2 compatibility preserved.

## Scope & Files
- `tests/test_sync_release.sh`: Add failure diagnosis helper (`ck_k`) printing `k*.out` and exit codes upon assertion failures; ensure master branch checkout in test fixture.
- `CHANGELOG.md`: Record diagnostic test improvement under `[Unreleased]`.
- `plans/261016-ci-gh-release-case-k/plan.md`: This documentation.

## Rollback
Revert the branch commit or delete branch `fix/ci-gh-release-case-k`. Risk is low as changes are scoped to test diagnostic output and test harness fixture setup.

Self-ship allowed only after independent review and test suite execution.
