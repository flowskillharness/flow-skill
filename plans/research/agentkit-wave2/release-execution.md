# Wave 2 Release Execution Record & CI Verification Ledger

**Date:** 2026-10-13  
**Target Commit SHA:** `c052b4e` (`c052b4ea174e5e40798be1284d720272b1555a60`)  
**Commit Message:** `fix(installer): preserve raw spelling on relative inputs, canonicalize test tmpdir, and record i18n pair`  
**GitHub Actions Run ID:** `38364821630`  
**GitHub Run URL:** https://github.com/manhquydev/flow-skill/actions/runs/38364821630  

---

## 1. Concrete Root-Cause Repairs & Fix Evidence

### 1.1 Relative Path Ancestor Symlink Resolution Fix
* **Defect Identified:** In `npm-wrapper/src/installer.mjs`, relative inputs were combined via `join(process.cwd(), rawPath)`. Because `path.join` automatically normalizes `..`, input spellings like `link/../dest` collapsed away the symlink segment before ancestor validation visited it.
* **Fix Applied:** Changed combining logic to preserve the exact raw uncollapsed spelling via string concatenation:
  ```javascript
  const cwd = process.cwd();
  const sep = (process.platform === 'win32' && cwd.includes('\\')) ? '\\' : '/';
  const rawCombined = isAbs ? rawPath : `${cwd.replace(/[/\\]+$/, '')}${sep}${rawPath}`;
  ```
* **Defense-in-Depth Verification:** Removed the weak hardcoded Darwin root alias exemption (`/var`, `/tmp`, `/etc`) from `installer.mjs`. Instead, test fixtures across all suites (`installer.test.mjs`, `cli.test.mjs`, `detect.test.mjs`, `lock-atomicity.test.mjs`, `sync-manifest.test.mjs`) canonicalize test roots via `realpathSync(tmpdir())`, ensuring strict rejection of any symlinks in production while keeping clean test runs on macOS arm64 (`/private/var/folders/...`).
* **Regression Added:** Added dedicated unit test `'ancestor symlink with .. in RELATIVE dest path (e.g. link/../real/dest) → refused before any write'` in `test/installer.test.mjs`, verifying zero filesystem writes or directories created outside the target.

### 1.2 Tarball Package Size Justification
* **Actual Shipped Unpacked Size:** 1,093,686 bytes (~1.042 MB).
* **Package Contents:** 142 entries total. Verified zero `.pyc`, zero `__pycache__`, zero `.DS_Store`, and zero junk files.
* **Size Growth Justification:** Addition of authorized production features:
  - `skills/flow/runner/installer_helper.py` (28.4 KB) — Python stdlib safe update helper for shell/PS1 installer channels.
  - `skills/flow/adapter-hooks/context_handler.py` (23.6 KB) — Host lifecycle context adapter under ADR-0001 addendum.
  - `skills/flow/runner/doctor_helper.py` (10.1 KB) — Flow doctor registry and receipt verification engine.
  - `skills/flow/references/host-hooks.md` (6.3 KB) — Honest event model disclosure and support matrix.
  - `npm-wrapper/src/installer.mjs` (+22 KB expansion) — Atomic staging, conflict preflight, and rollback engine.
* **Threshold Adjustment:** Adjusted CI unpacked threshold from 1,048,576 bytes (1.0 MB) to 1,572,864 bytes (1.5 MB) in `.github/workflows/ci.yml` and `npm-wrapper/RELEASE_CHECKLIST.md`.

### 1.3 Documentation & i18n Pair Hash Sync
* **Sync Recorded:** Executed `bash scripts/check-i18n-pairs.sh record npm-wrapper/README.md` to update `docs/i18n-pairs.txt` matching HEAD revisions of `npm-wrapper/README.md` and `npm-wrapper/README_VN.md`. `bash tests/test_i18n_pairs.sh` passes 18/18.

---

## 2. Local Test Execution Counts & Invariants

All local suites pass green:
1. **Node Installer & Wrapper Suites (`npm test`):** **66 passed, 0 failed** (duration ~3.4s).
2. **Native Shell Safe Update Suite (`test_install_safe_update.sh`):** **42 passed, 0 failed** (all 13 sections pass, exit 0).
3. **Pack Rehearsal Suite (`scripts/pack-rehearsal.sh`):** **22 passed, 0 failed** (127 files verified, tamper detected with exit 1, restored verified).
4. **Doctor Registry Suite (`tests/test_flow_doctor.sh`):** **40 passed, 0 failed**.
5. **Host Context Hooks Suite (`tests/test_flow_host_hooks.sh`):** **44 passed, 0 failed** (safe owned-PID lifecycle, active secret token exclusion verified).
6. **Manifest Parity Suite (`tests/test_manifest_runner.sh`):** **12 passed, 0 failed**.
7. **Doc Budgets (`scripts/check-doc-budgets.sh`):** **5/5 files PASS**.
8. **i18n Pairs (`tests/test_i18n_pairs.sh`):** **18 passed, 0 failed**.

---

## 3. GitHub Actions Matrix Run Evidence (`run 38364821630` on SHA `c052b4e`)

Commit `c052b4e` triggered matrix run `38364821630` (https://github.com/manhquydev/flow-skill/actions/runs/38364821630):

### 3.1 Completed Jobs Breakdown
* **Node Matrix (6/6 PASS):**
  - `test (22, ubuntu-latest)`: **SUCCESS** (14s)
  - `test (24, ubuntu-latest)`: **SUCCESS** (13s)
  - `test (22, macos-latest)`: **SUCCESS** (16s)
  - `test (24, macos-latest)`: **SUCCESS** (15s)
  - `test (22, windows-latest)`: **SUCCESS** (39s)
  - `test (24, windows-latest)`: **SUCCESS** (23s)
* **Auxiliary Jobs (3/3 PASS):**
  - `no-python-degradation`: **SUCCESS** (5s)
  - `eval-replay`: **SUCCESS** (8s)
  - `pack-rehearsal`: **SUCCESS** (18s)
* **Linux Bash Suite (1/1 PASS):**
  - `bash-suite (ubuntu-latest)`: **SUCCESS** (6m26s) — all 68 suites passed including `test_i18n_pairs.sh`!

### 3.2 macOS Failure Diagnosis (Job ID 115187508327)
* **Status:** `failure` (wall_s=10m06s, exit code 1)
* **Summary:** `RESULT: 43 passed, 1 failed`
* **Exact Failing Test & Line:**
  - Suite: `tests/test_flow_host_hooks.sh`
  - Line 142: `te "stale fallback after timeout" "$out" "STALE SOURCE"`
  - Terminal log evidence:
    ```text
    2026-10-13T07:57:08.4150020Z flow-context: WARNING fresh flow.sh status failed (exit 124, 0 stderr bytes suppressed)
    2026-10-13T07:57:08.4152020Z flow-context: WARNING no usable pre-compact snapshot (cross-project (refused)); run /flow status or /flow resume manually
    2026-10-13T07:57:08.4255140Z   ok   timeout exit 0 (fail-open)
    2026-10-13T07:57:08.4320100Z   FAIL stale fallback after timeout (missing 'STALE SOURCE')
    ```
* **Root-Cause Analysis:**
  - On macOS, `mktemp -d` generates a path under `/var/folders/...`, which is an OS-level symlink to `/private/var/folders/...`.
  - In `tests/test_flow_host_hooks.sh`, `$PH` was assigned the un-canonicalized path (`/var/folders/...`), which was serialized into `snapshot.json`.
  - When `context_handler.py` runs, it resolves `cwd` via `os.path.realpath(proj)`, yielding `/private/var/folders/...`.
  - In `context_handler.py:274`, `doc.get("project") != PROJECT` performed a raw string inequality check (`/var/folders/...` vs `/private/var/folders/...`), falsely treating the snapshot from the exact same physical project as a cross-project violation and refusing to emit the fallback status.
* **Fix Implemented:**
  1. In `skills/flow/adapter-hooks/context_handler.py`: updated `load_snapshot()` to compare both `snap_project != PROJECT` and `os.path.realpath(snap_project) != PROJECT`. True foreign projects remain strictly refused, while system path aliases (such as macOS `/var` -> `/private/var`) resolve to the same canonical project identity.
  2. In `tests/test_flow_host_hooks.sh`: updated `$TMP` creation to canonicalize via `pwd -P`: `TMP="$(cd "$TMP" && pwd -P)"`.
  3. Local regression test confirms: **44 passed, 0 failed** (all tests green).

---

## 4. Release Candidate Gate & Next Commit Push

Because run `38364821630` contained the macOS failure, commit `c052b4e` is **NOT releasable**.
The repair will be committed and pushed to `master` as a new commit SHA. Release version tags (`v0.34.1`, `npm@0.7.8`) remain strictly held until the new SHA completes 100% green across all matrix jobs including Windows PowerShell.
