# Wave 2 Research & Implementation Plan: Transactional Installer, Safe Rollback & OMP Target Parity

**Date:** 2026-10-13  
**Status:** Research & Architectural Plan Complete (Awaiting Commit Confirmation & Director Code Authorization)  
**Research Location:** `plans/research/agentkit-wave2/wave2-plan.md`  
**Primary Authors:** Source Forensics & Upgrade Workstream  

---

## 1. Discovery & Analysis of Requested `je` Command

### 1.1 Discovery Investigation & Concrete Evidence
The user prompt requested: *"sử dụng je --parallel --auto"*. A thorough, bounded investigation was performed across the workstation environment without speculative models or host mutations:
1. **System PATH Resolution:**
   - Executed `type je`: returned `type: je not found` (exit code 1).
   - Scanned `/home/manhquy/.local/bin`, `/usr/local/bin`, `/usr/bin` for binaries matching `je*`: no executable named `je` exists on disk.
2. **Shell & Environment Aliases:**
   - Executed `alias`: no alias defined for `je`.
   - Checked git aliases (`git config -l | grep alias.je`): none defined.
3. **Package Ecosystem Checks:**
   - Global npm modules (`npm list -g je`): returned empty (no package named `je`).
   - Python stdlib probe (`python3 -c "import je"`): returned `ModuleNotFoundError: No module named 'je'`.
4. **Operational Conclusion:**
   - `je` is **not installed on this host** — `not found` across PATH, disk, npm, and Python. That not-found state is sufficient; no session-history mining, IME/typing speculation, or alias guessing is performed or retained.

---

## 2. Problem Statement: Current Flow Installer Deficiencies

A rigorous audit of `npm-wrapper/src/` (`constants.mjs`, `detect.mjs`, `installer.mjs`) and `install.sh`/`install.ps1` against AgentKit's owner-locked installation standards revealed three concrete vulnerabilities:

### 2.1 Deficiency 1: Complete Absence of OMP (Oh My Pi) Target Support
* **The Reality:** On this host, Oh My Pi is actively running (`~/.omp/agent/skills/` containing 149 skills).
* **The Bug:** `constants.mjs` defines only 5 targets (`claude`, `codex`, `agents`, `antigravity`, `cursor`). `install.sh` similarly checks only Claude, Codex, Antigravity, and generic Agents home.
* **The Impact:** Running `npx @manhquy/flow-skill@latest` or `bash install.sh` never detects or installs Flow into OMP, forcing users to manually copy files or maintain unmanaged symlinks.

### 2.2 Deficiency 2: Destructive Pre-Deletion Without Rollback
* **The Reality:** In `installer.mjs:154-168`:
  ```javascript
  // Cleanup the 6 subdirs — matches install.sh:25.
  for (const sub of cleanupSubdirs) {
    const p = join(destDir, sub);
    if (existsSync(p)) rmRecursiveWithRetry(p);
  }
  // Merge copy
  withRetry(() => cpSync(sourceDir, destDir, { ... }));
  ```
* **The Bug:** The installer destroys the existing subdirectories (`runner`, `references`, etc.) **before** the copy completes.
* **The Impact:** If `cpSync` throws an error mid-flight (e.g., `ENOSPC` disk full, I/O failure, permission deadlock, or process termination), the destination is left in a **corrupted, non-functional state** with no runner and no skill files. `installer.mjs` simply catches and returns `{ success: false, error: err.message }` without restoring the deleted files.

### 2.3 Deficiency 3: Incomplete Subdir Cleanup (`adapter-hooks`)
* **The Bug:** `CLEANUP_SUBDIRS` in `constants.mjs` lists only `runner`, `_templates`, `law`, `references`, `harness`, `playbooks`. Newly added `adapter-hooks` is omitted.
* **The Impact:** On upgrade, renamed or removed hook files in `adapter-hooks` linger indefinitely as stale artifacts.

---

## 3. Architecture & Design: Transactional Staged Installer with Rollback

To achieve AgentKit-grade installation reliability without growing background daemons, Flow's installer will implement a **transactional staging and backup recovery pattern**:

```
[Start Install]
       │
       ▼
[1. Acquire Lock] ──────► Atomic wx lock (.flow-skill.installing.lock)
       │
       ▼
[2. Staging Phase] ─────► Copy sourceDir -> <destDir>.staging.<rand>
       │                  Verify assertNoSymlinks on staging tree
       ▼
[3. Backup Phase] ──────► If <destDir> exists:
       │                  Copy clean subdirs -> <destDir>.backup.<rand>
       ▼
[4. Apply Mutation] ────► Remove clean subdirs in <destDir>
       │                  Merge-copy from staging into <destDir>
       │                  chmod +x <destDir>/runner/flow.sh
       ├───► [FAIL?] ───► ROLLBACK: Restore from <destDir>.backup.<rand>
       │                  Remove staging & backup; Return { success: false, error }
       ▼ [SUCCESS]
[5. Finalize] ──────────► Remove <destDir>.backup.<rand> & <destDir>.staging.<rand>
       │                  Release lock; Return { success: true }
```

### 3.1 Core Invariants & Boundaries
1. **Zero External Runtime Dependencies:** Pure Node.js built-ins (`node:fs`, `node:path`, `node:crypto`). No third-party npm packages.
2. **Preservation of Unmanaged User Files:** Files outside the managed subdirs (e.g. user-authored cards, notes, custom configs) are untouched.
3. **Atomic Rollback Guarantee:** If any step fails during the mutation, the existing destination is restored byte-for-byte from the backup snapshot before surfacing the error.
4. **Single Source of Truth:** `CLEANUP_SUBDIRS` includes `adapter-hooks`.
5. **OMP Target Parity:** OMP is fully supported across `npm-wrapper` and `install.sh` with automatic reload hints.

---

## 4. Workstream 2 (W2) Implementation Specification

### 4.1 Files Owned & Exact Changes

#### 1. `npm-wrapper/src/constants.mjs`
* Add `omp` target to `TARGETS`:
  ```javascript
  {
    name: 'omp',
    label: 'Oh My Pi (OMP)',
    markers: ['.omp/agent/skills'],
    destTemplates: ['~/.omp/agent/skills/flow'],
    alwaysInclude: false,
    projectScopeAllowed: false,
  }
  ```
* Add `'adapter-hooks'` to `CLEANUP_SUBDIRS`:
  ```javascript
  export const CLEANUP_SUBDIRS = [
    'runner',
    '_templates',
    'law',
    'references',
    'harness',
    'playbooks',
    'adapter-hooks',
  ];
  ```

#### 2. `npm-wrapper/src/installer.mjs`
* Implement `install()` transactional workflow:
  - Create temporary staging directory `const stagingDir = join(dirname(destDir), `.flow-skill.staging.${Date.now()}`);`
  - Copy source into `stagingDir` and verify `assertNoSymlinks`.
  - Create temporary backup directory `const backupDir = join(dirname(destDir), `.flow-skill.backup.${Date.now()}`);`
  - Backup existing managed subdirectories before deletion.
  - In `catch (err)` block: automatically restore from `backupDir` if backup was created, clean up `stagingDir` and `backupDir`, and propagate error honestly.
  - In success path: cleanly remove `stagingDir` and `backupDir`.

#### 3. `install.sh` & `install.ps1`
* Add `omp` support:
  - Check for `~/.omp/agent/skills` marker during auto-detection.
  - Add `global omp` option to CLI argument handler.
  - Add OMP restart hint to `done_line()`: `OMP: restart omp agent or session to discover the new skill |`.
  - Add `adapter-hooks` to `install.sh` clean subdirs list: `rm -rf "$dest"/_templates "$dest"/law "$dest"/references "$dest"/runner "$dest"/harness "$dest"/playbooks "$dest"/adapter-hooks`.

#### 4. `npm-wrapper/test/installer.test.mjs` & `detect.test.mjs`
* Add behavioral test: `simulated copy failure triggers automatic rollback and preserves original destination`.
* Add behavioral test: `OMP detection when ~/.omp/agent/skills is present`.
* Add behavioral test: `target list includes omp and cleans adapter-hooks`.

#### 5. Documentation & Release Coherence
* Update `docs/system-architecture.md`: document OMP install target and transactional rollback guarantee.
* Update `CHANGELOG.md` under `[Unreleased]`: record OMP target support and installer rollback.

---

## 5. Verification Matrix & Acceptance Criteria

| Check / Test | Command | Acceptance Criterion |
|---|---|---|
| **OMP Detection** | `cd npm-wrapper && npm test` | All tests pass, including new `detect` and `installer` OMP test cases. |
| **Installer Rollback** | `npm test` (synthetic failure test) | Destination remains intact with original files after simulated `cpSync` error. |
| **Pack Rehearsal** | `bash scripts/pack-rehearsal.sh` | Clean install, tamper detection (exit 1), and restore verify cleanly (126 files). |
| **Shell Installer OMP**| `bash install.sh global omp` (in isolated temp) | Installs cleanly to `$HOME/.omp/agent/skills/flow` and prints OMP done hint. |
| **Doc Budgets** | `bash scripts/check-doc-budgets.sh` | All 5 files pass doc budgets. |
| **Manifest Parity** | `bash tests/test_manifest_runner.sh` | 12/12 pass (no orphans, no missing suites). |

---

## 6. Execution Status
* **Current Status:** Planning and research complete under `plans/research/agentkit-wave2/wave2-plan.md`.
* **Lock State:** Standing by for director authorization and confirmation of previous wave commit before initiating production code edits.
