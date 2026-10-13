# Native Test Windows CI Failure Analysis (run 38369511454, SHA 005e659)

## Exact 9 Failures with Root Causes

### Section 1 — Symlink Detection (4 failures, all `expected='7' got='0'`)

| Assertion | Root Cause |
|---|---|
| symlink source root refused | `ln -s "$S1_SRC" "$S1_SRC_LINK"` on Windows Git Bash creates a **directory copy**, not a reparse point. The helper correctly finds no symlink and exits 0. |
| symlink destination root refused | Same: `ln -s "$S1_DST" "$S1_DST_LINK"` → copy, not symlink. |
| symlink in source ancestry refused | Same: ancestor `ln -s` → copy. |
| traversal through symlink component | Same: `ln -s "$S1_BYPASS_TARGET" "$S1_BYPASS_LINK"` → copy. |

**Fix:** Detect that `ln -s` actually created a symlink with `[ -L "$link" ]`; if not, create a junction via `cmd //c mklink /J "$link" "$target"` which Windows `lstat()` reports as `S_ISLNK`. If neither works, mark as platform-unsupported with explicit assertion.

### Section 2 — FIFO (1 failure, `expected='4' got='0'`)

| Assertion | Root Cause |
|---|---|
| gen-receipt refuses FIFO | `mkfifo "$S2_SRC/blocker_fifo"` on Windows Git Bash does **not** create a named pipe. It either fails silently or creates a regular file. The helper sees only regular files and exits 0. |

**Fix:** Check `mkfifo` exit code; if nonzero or the created entry is not a FIFO (`[ -p ]` returns false), mark as platform-unsupported with explicit assertion.

### Section 3 — Receipt Schema (3 failures, all `expected='REJECTED:receipt' got='CRASH'`)

| Assertion | Root Cause |
|---|---|
| duplicate JSON keys strictly rejected | **CRASH** = unhandled Python exception (stderr suppressed by `2>/dev/null`). Root cause: `PYTHONPATH="$ROOT/skills/flow/runner:..."` contains an MSYS path (`/c/Users/runneradmin/...`). Windows Python cannot resolve this path for `import installer_helper`, raising `ModuleNotFoundError` (not `Fail`), which hits the `|| echo "CRASH"` fallback. |
| boolean schema_version strictly rejected | Same `PYTHONPATH` MSYS path issue → `ModuleNotFoundError` → CRASH. |
| non-canonical relative path rejected | Same. |

**Fix:** Convert `PYTHONPATH` to Windows-native format using `cygpath -w` when on MSYS/Windows before invoking Python. This makes `import installer_helper` resolve correctly.

## Summary

| # | Suite Section | Root Cause Category | Fix Type |
|---|---|---|---|
| 1-4 | Symlink detection | `ln -s` creates copy on Windows, not reparse point | Use `cmd //c mklink /J` or detect+skip unsupported |
| 5 | FIFO detection | `mkfifo` unavailable on Windows | Detect + mark unsupported |
| 6-8 | Receipt schema | `PYTHONPATH` MSYS path not resolvable by Windows Python | `cygpath -w` conversion |

**No production code bugs** — all 9 are test infrastructure issues specific to the Windows Git Bash environment. The helper (`installer_helper.py`) and installer (`install.sh`) themselves work correctly on Windows for sections 4–14 (fresh install, conflict, preservation, retirement, legacy, fault injection, shell e2e, traversal, no-Python, drive parsing — all 33 remaining assertions PASSED on CI).

## Correct receipt schema tests MUST be preserved on Windows

The duplicate-key, boolean schema_version, and non-canonical path checks are **NOT Unix-only**. They must run on Windows. The fix is exclusively the `PYTHONPATH` conversion; the test assertions themselves are correct.
