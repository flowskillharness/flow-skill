# Plan: Deterministic Private TMPDIR for Flow Eval Residue Test (Case K)

## Who Is Hurt
Maintainers; post-merge CI on macOS (`bash-suite` job 116954165025 on run 38941087736, master commit `1a187f0`) failed `tests/test_flow_eval.sh` Case K with:
```
FAIL [TMPDIR delta=2 after a full 13-fixture batch - rundir cleanup regression]
```
blocking release confidence and false-failing an otherwise healthy 263/1 test run.

## Evidence
- PR #38 macOS job had delta=0 (passed).
- Master merge run 38941087736 Ubuntu job had delta=0 (passed).
- Post-merge master run 38941087736 macOS job had delta=2 (failed).
- Case K sampled the ambient shared global `${TMPDIR:-/tmp}` before and after running the 13-fixture batch (~6–8 seconds runtime).
- Case K allowed only `[ "$delta" -le 1 ]` ambient noise, but background system/agent processes on the shared macOS runner created 2 unrelated directories in the shared temp root during the execution window.
- The failure was not a Flow runner rundir leak; `cmd_eval` in `flow.sh` cleans each per-fixture `rundir` immediately via `rm -rf "$rundir"` on normal completion, skip, and abort paths.

## Hypothesis (Race / Ambient Noise)
Sampling the global shared `${TMPDIR:-/tmp}` exposes Case K to a non-deterministic race with unrelated concurrent processes on the runner machine. Setting a dedicated private `mktemp -d` root as `TMPDIR` for the batch invocation isolates Flow-owned temp directory creation to an unshared namespace, eliminating ambient noise while strictly measuring whether Flow leaves any residual rundirs.

## Acceptance Criteria
1. The full 13-fixture batch continues to run completely (`has "$batch_out" "of 13 evaluated"`).
2. Case K executes the batch with a dedicated private `mktemp -d` root as `TMPDIR`.
3. Directory counts before and after in the private root are compared with exact equality (`delta == 0`), rejecting any Flow-owned residual directory without tolerance for ambient noise.
4. If an actual rundir leak occurs, the test deterministically fails (`delta > 0`).
5. Ambient directory creation in the global `/tmp` or system `TMPDIR` does not affect the private count.
6. The private root is cleaned up after assertion verification and in `_cleanup_all`.
7. Runner eval STOP zones (`_eval_engine_run`, `_run_with_timeout`) and runner code remain untouched.
8. Bash 3.2 compatible, zero new dependencies.

## Non-Goals
- No changes to `skills/flow/runner/flow.sh`.
- No widening of tolerance thresholds in the shared global namespace.
- No version bumps.

## Rollback
Revert commit on branch `fix/eval-private-tmpdir`.
