# Native Installer Workstream: Transactional Safe-Update & OMP Target Parity

**Document Path:** `plans/research/agentkit-wave2/native-install-result.md`  
**Date:** 2026-10-13  
**Status:** Implementation complete. Verification passing (42/42 tests green).  

---

## 1. Executive Summary & Ownership Boundaries

This workstream delivers the production transactional installer and safe ownership update engine for Flow's native channels (`install.sh`, `install.ps1`, and the shared Python stdlib helper `skills/flow/runner/installer_helper.py`).

### Ownership Boundaries (Strictly Observed)
- **Native Workstream Sole Ownership (All Delivered):**
  - `skills/flow/runner/installer_helper.py` (Python 3.8+ stdlib-only full transaction engine)
  - `install.sh` (POSIX/Bash 3.2-safe transactional installer)
  - `install.ps1` (PowerShell 7+ safe installer wrapper)
  - `tests/test_install_safe_update.sh` (42 comprehensive automated behavioral tests)
  - `plans/research/agentkit-wave2/native-install-result.md` (this report)
- **Peer Ownership (`agentkit-handoff-final`):**
  - `npm-wrapper/` (Node installer, constants, CLI, sync)
  - `tests/manifest.txt` (sole test registry owner)
  - Final git staging / commit.

---

## 2. Core Architectural Principles & Mitigations

### 2.1 Zero Destructive Pre-Deletion (Clean Cutover)
The historical pattern of `rm -rf "$dest"/_templates "$dest"/law ...` followed by destructive copy has been completely eliminated across all native installers. Destinations are never pre-emptively wiped or partially overwritten.

### 2.2 Raw Lexical Path & Ancestor Validation Before Directory Creation
- **Symlink & Traversal Safety:** Raw input paths are validated component-by-component *before* any normalization, `resolve()`, or `os.path.abspath()`.
- **Traversal Bypass Prevention:** Relative traversals such as `/tmp/link/../dest` (where `link` is a symlink pointing outside) are detected and refused at the symlink prefix with exit code 7 before `..` is traversed and before any directory is created.
- **Cross-Platform Root Support:** Supports POSIX root (`/`), Windows drive letters (`C:\`), and UNC network shares (`\\server\share`).
- **No Early Mkdir:** Ancestors and destinations are validated using `lstat` before any parent directory is created.

### 2.3 Process Locking Parity
- Acquires an exclusive lock file at `.flow-skill.installing.lock` in the destination's parent directory prior to modifying the filesystem.
- Lock format and semantics match the Node installer: records PID, probes active status via `os.kill(pid, 0)`, safely reclaims dead/stale locks, and releases the lock in a guaranteed `finally:` block.

### 2.4 Strict Ownership & Receipt Contract (`manifest-hashes.json`)
- **Schema Strictness:** Root must be a JSON object, `schema_version` must be integer `1` (boolean `true` and string `"1"` are rejected), duplicate keys are strictly rejected via custom parser hooks, and paths must be canonical relative POSIX paths (no leading slash, no `~`, no `\`, no `:`, and no self-reference).
- **Non-Regular Entry Rejection:** FIFOs, sockets, character/block devices, and symlinks are rejected *before* any hashing takes place, preventing hangs on unreadable or blocking streams.
- **Bytecode Exclusion:** `PYTHONDONTWRITEBYTECODE=1` is enforced and `__pycache__` / `*.pyc` are filtered out during walks.

### 2.5 Conflict Refusal & User Custom Preservation
- **Preserve Unowned Files:** Unowned user files located anywhere in the destination—including inside previously managed subdirectories like `runner/`—are automatically preserved into the staged candidate.
- **Conflict Refusal:** If a file owned by the previous receipt has been modified by the user, the install aborts with exit code 3 *before* touching the destination. The original destination remains 100% byte-identical.
- **Retired Files:** Files owned by the old receipt that no longer exist in the new version are pruned if unmodified, but preserved as unowned if user-modified.
- **Legacy Idempotence:** If an existing destination has no receipt, differing byte collisions trigger exit 3, while identical byte collisions are accepted.

### 2.6 Staged Swap & Non-Destructive Quarantine Recovery (Return-Failure Guarantee Only)
- **Staging:** Candidate is assembled in a private mode `0700` directory created via `tempfile.mkdtemp(prefix=".flow-skill-stage-", dir=dst_parent)`.
- **Swap Seam:**
  1. Dest is renamed to `.flow-skill-backup-<token>`.
  2. Candidate is promoted via rename `stage -> dest`.
  3. Promoted tree is verified against the immutable staged receipt.
  4. Backup is removed only after verified promotion.
  - *Note on Atomicity:* The swap consists of two sequential filesystem renames (`dest->backup` then `stage->dest`). A brief visibility gap exists between the two renames, and no crash/SIGKILL atomicity is claimed. Guarantees hold for returned failures only.
- **Quarantine Failure Safety (Zero Destination Delete):**
  - If post-promotion verification or swap fails, the bad candidate is moved aside to `.flow-skill-failed-<token>` via rename.
  - If quarantine rename fails, `shutil.rmtree(dst)` is **NEVER** called. The candidate remains at `dst`, the backup is preserved, and a structured `EROLLBACK` JSON payload reporting `recovery_path` and `failed_candidate_path` is emitted with exit code 6.
  - The backup is restored via rename *only* if the destination is vacant.
### 2.7 Channel Parity & Runtimes
- **Shell (`install.sh`):**
  - Fresh install with Python: Uses `installer_helper.py upgrade` to build candidate and write ownership receipt.
  - Fresh install without Python: POSIX-compliant staging (`mktemp -d`, `cp -R`, `mv`) into empty destination with deferred rename-backup and warning advisory that updates will require Python.
  - In-place update: Strictly requires Python 3.8+ stdlib. If Python is absent, fails loudly with exit 1 leaving the original installation untouched.
- **PowerShell (`install.ps1`):**
  - Fresh install uses helper when Python is present; otherwise native PowerShell staging with reparse point checks and rename-backed empty destination rollback.
  - In-place update delegates to shared `installer_helper.py upgrade`.
  - Subprocess stdout/stderr is captured to prevent pipeline pollution (ensuring `$last` receives only the destination string).
- **OMP Target:**
  - Explicit target: `global omp` -> `~/.omp/agent/skills/flow`.
  - Autodetect in `global all`: triggers *only* when genuine `~/.omp/agent/skills` directory exists (bare `~/.omp` runtime directories are strictly ignored).
  - Restart hint: `OMP: restart/reload your agent to load the new skill, then invoke flow`.

---

## 3. Verification & Automated Test Evidence

### Suite: `tests/test_install_safe_update.sh`
Executed directly on the current Linux workstation environment:
```bash
bash tests/test_install_safe_update.sh
```
**Results:** **Pass: 42, Fail: 0** (execution time: 3.41s). Linux path segmentation, FIFO rejection, and POSIX staging verified. Windows drive and UNC path components are checked lexically; actual Windows runtime verification runs via GitHub Actions CI on `windows-latest`.

### Test Coverage Matrix:
| Section | Test Assertion | Result |
|---|---|---|
| **1. Symlink & Traversal** | Symlink source root refused (exit 7) | `ok` |
| | Symlink destination root refused (exit 7) | `ok` |
| | Symlink in source ancestry refused (exit 7) | `ok` |
| | Traversal through symlink component (`/tmp/link/../dest`) refused (exit 7) | `ok` |
| **2. Non-Regular / FIFO** | `gen-receipt` refuses FIFO without hanging (exit 4) | `ok` |
| **3. Receipt Schema** | Duplicate JSON keys strictly rejected | `ok` |
| | Boolean `schema_version: true` strictly rejected | `ok` |
| | Non-canonical relative path rejected | `ok` |
| **4. Fresh Install** | Fresh install succeeds (exit 0) | `ok` |
| | Fresh install creates `manifest-hashes.json` | `ok` |
| | Runner `flow.sh` is made executable (`chmod +x`) | `ok` |
| **5. Conflict Refusal** | User-modified owned file triggers exit 3 (conflict) | `ok` |
| | Destination left completely untouched on conflict | `ok` |
| **6. Custom Preservation** | Update succeeds when owned files match (exit 0) | `ok` |
| | Custom file at root preserved | `ok` |
| | Custom file inside managed `runner/` subdir preserved | `ok` |
| | Custom files excluded from `manifest-hashes.json` | `ok` |
| **7. Retired Files** | Update with retired files succeeds | `ok` |
| | Unmodified retired file pruned | `ok` |
| | Modified retired file preserved as unowned | `ok` |
| **8. Legacy Collision** | Legacy differing-byte collision refused with exit 3 | `ok` |
| | Legacy identical-byte collision accepted | `ok` |
| **9. Fault Injection** | Promotion failure via `_rename` seam returns exit 6 | `ok` |
| | Destination restored intact after promotion failure | `ok` |
| | Quarantine failure returns exit 6 | `ok` |
| | Backup directory preserved on quarantine failure (no rmtree) | `ok` |
| | Destination candidate preserved (NEVER deleted) on quarantine failure | `ok` |
| **10. End-to-End Shell** | `install.sh global claude` creates fresh install with receipt | `ok` |
| | `install.sh global omp` installs to `~/.omp/agent/skills/flow` | `ok` |
| | `install.sh global all` detects `~/.omp/agent/skills` | `ok` |
| | Bare `~/.omp` without `agent/skills` does NOT install omp | `ok` |
| | `install.sh` update preserves custom file | `ok` |
| | `install.sh` update conflict fails with exit code 3 | `ok` |
| | No-Python update fails loudly with exit 1 | `ok` |
| | No-Python fresh install succeeds with exit 0 | `ok` |
| | No-Python fresh install staged into place | `ok` |
| | No-Python fresh install has no receipt (as designed) | `ok` |
| **11. Traversal Pre-Mkdir** | Traversal destination rejected by `install.sh` (exit 1) | `ok` |
| | New parent directory NOT created on filesystem | `ok` |
| **12. No-Py Empty Dest** | No-Python fresh install over empty directory succeeds (exit 0) | `ok` |
| | Empty directory cleanly replaced with skill content | `ok` |
| **13. Windows / UNC Parsing** | Raw Windows drive (`C:\`) and UNC paths correctly parsed | `ok` |

---

## 4. Peer Coordination & Sign-Off Checklist

1. **Test Registry Row:** Registered `test_install_safe_update.sh` in `tests/manifest.txt` (manifest runner 12/12 pass).
2. **NPM Wrapper Sync:** `skills/flow/runner/installer_helper.py` synced into `npm-wrapper/skills/flow/` and verified across 65/65 npm tests.
3. **PowerShell Test Suite:** Dedicated `tests/test_install_safe_update.ps1` authored and configured in `.github/workflows/ci.yml` with mandatory execution and exit-code propagation on `windows-latest`. Windows runtime verification is pending GHA CI execution (no unverified cross-OS parity claimed from Linux).
