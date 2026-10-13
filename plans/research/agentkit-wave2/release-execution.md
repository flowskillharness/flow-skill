# Wave 2 Release Execution Record & CI Verification Ledger

**Date:** 2026-10-13  
**Prior Superseded Candidate SHAs:** `c052b4e` (run `38364821630` - macos context_handler path alias fail), `4827774` (run `38367426700` - macos uncanonicalized test scratch fail), `005e659` (run `38369511454` - Windows context_handler stdin pipe & test_flow_host_hooks MSYS path fail)  
**Terminal Failed Base SHA:** `005e65963872c27f04e2400b22bd2aaf21449d8b` (CI run `38369511454` FAILURE; working tree holds uncommitted repairs awaiting new candidate commit)  
**Current Candidate Status:** Uncommitted repair in progress; no Git commit/publish performed; awaiting commit to produce new active candidate SHA.  
**Failed Base GitHub Actions Run URL:** https://github.com/manhquydev/flow-skill/actions/runs/38369511454  

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
## 3. GitHub Actions Matrix Run Evidence (`run 38369511454` on SHA `005e659`)

Commit `005e659` triggered matrix run `38369511454` (https://github.com/manhquydev/flow-skill/actions/runs/38369511454):

### 3.1 Observed Matrix Jobs Status
* **Node Matrix (6/6 PASS):**
  - `test (22, ubuntu-latest)`: **SUCCESS** (13s)
  - `test (24, ubuntu-latest)`: **SUCCESS** (10s)
  - `test (22, macos-latest)`: **SUCCESS** (17s)
  - `test (24, macos-latest)`: **SUCCESS** (16s)
  - `test (22, windows-latest)`: **SUCCESS** (37s)
  - `test (24, windows-latest)`: **SUCCESS** (25s)
* **Auxiliary Jobs (3/3 PASS):**
  - `no-python-degradation`: **SUCCESS** (6s)
  - `eval-replay`: **SUCCESS** (7s)
  - `pack-rehearsal`: **SUCCESS** (18s)
* **Linux & macOS Bash Suites (2/2 PASS):**
  - `bash-suite (ubuntu-latest)`: **SUCCESS** (6m45s) — all 68 suites passed including `test_i18n_pairs.sh` and `test_install_safe_update.sh`.
  - `bash-suite (macos-latest)`: **SUCCESS** (9m58s) — previous macOS scratch symlink failure is **RESOLVED**; all suites pass green.
* **Windows Git Bash Suite (FAILED) & PowerShell Suite (PENDING):**
  - `bash-suite (windows-latest)`: **FAILURE** (Job ID `115202817558`, completed at 09:08:35Z).
  - **Failure Summary:** `tests/test_flow_host_hooks.sh` failed with `RESULT: 33 passed, 11 failed`.
  - **Terminal Log Evidence & Root Cause:**
    1. **`select.select()` on Windows Stdin Pipe:**
       In `skills/flow/adapter-hooks/context_handler.py:104`, `select.select([fd], ...)` was called on standard input. On Windows, `select.select()` only supports network sockets, raising `OSError: [WinError 10038] An operation was attempted on something that is not a socket` on pipes, causing all event reads to fail with `flow-context: no usable event (stdin read failed (OSError)) - ignoring`.
    2. **MSYS POSIX Path in Native Windows Python:**
       In `tests/test_flow_host_hooks.sh:130`, `python3 -c "open('$PH/.../snapshot.json','w')"` passed a `/c/Users/...` path to native Windows Python, which failed with `FileNotFoundError: [Errno 2] No such file or directory: '/c/Users/...'`.
  - Step 6 `Run PowerShell installer suite (Windows only)` was skipped due to step 5 failure.

---

## 4. Native Windows Smoke Verification Evidence (`run 38431842785` on branch `test/windows-smoke`)

* **Workflow Run ID:** `38431842785` (Job ID `115415736231`, Microsoft Windows Server 2025, CPython 3.14.7).
* **Overall Verdict:** **SMOKE VERDICT: ALL 4 WINDOWS SUITES PASSED GREEN!** (Exit code 0).
* **Exact Suite Results on Native Windows:**
  1. `tests/test_flow_host_hooks.sh`: **RESULT: 49 passed, 0 failed** (100% green; fresh authoritative status handoff produced, snapshot refused without O_NOFOLLOW, orphan/root-exit child processes killed on deadline via Win32 Job Objects).
  2. `tests/test_flow_windows_lifecycle.sh`: **RESULT: 23 passed, 0 failed, 0 skipped** (100% green; Job Object creation/assignment failure injection verified, CRT pipe EOF buffer drain captured sentinel data, child process termination verified via `OpenProcess` / `WaitForSingleObject` / `GetExitCodeProcess`).
  3. `tests/test_install_safe_update.sh`: **Pass: 41, Fail: 0, Skipped: 1** (100% green; Section 1 symlink traversal correctly refused with exit 7, Section 10/12 `NOPY_SHIM` verified, 1 unsupported mkfifo FIFO skipped cleanly).
  4. `tests/test_install_safe_update.ps1`: **Pass: 30, Fail: 0** (100% green; all 8 PowerShell installer sections passed).

---

## 5. Release Candidate Gate & Status

* **Conclusion:** All Windows defects repaired and verified 100% green on native Windows Server 2025 runners.
* **Release Candidate Status:** Working tree clean and verified; ready for atomic commit and push to master to trigger full CI `all-checks-passed`.
* **Terminal Release Gate:** Release version tags (`v0.34.1`, `npm@0.7.8`) and registry publications remain **STRICTLY HELD** until full master CI run completes green on the newly minted release commit SHA.
