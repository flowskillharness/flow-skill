# Integration Review — AgentKit Engineer → Flow Upgrade Wave 261013

**Date:** 2026-10-13  
**Reviewer:** `agentkit-review` (Independent Read-Only Integration Reviewer)  
**Target:** `/home/manhquy/Documents/flow-skill`  
**Review Status:** **targeted slices verified; full 66-suite result unverified** (evidence-access blocker: terminal exit receipt of master full-suite run unavailable in session transcript; no success inferred from prior run or process state; native decompilation NONE blocked)
**Target Workstreams:**
- W1 (Source workstream): Doctor named registry, CLI/JSON envelopes, whole-tree receipt (`manifest-hashes.json`), and test hardening.
- W2 (Flow adapter workstream): Host lifecycle context adapters (`skills/flow/adapter-hooks/`), ADR-0001 addendum, and host-hooks documentation.
- Research Forensic Alignment: `plans/research/agentkit-engineer-installed/` artifacts vs real disk evidence and REA evidence-index.

---

## 1. Executive Summary

This independent integration review evaluated the pending changes across W1 and W2 against repository constitution (`AGENTS.md`, `docs/adr/0001-discipline-layer-identity.md`), security boundaries, consumer-visible correctness, and portability constraints.

### Core Review Findings:
1. **Host-Context Adapter Hooks (W2):** Fully compliant with ADR-0001 Addendum. The adapter is operator-installed, host-fired, strictly advisory, fail-open on all handled input faults, with zero tool interposition and no daemon or resident process. Output bounds, strict UTF-8 decoding, duplicate JSON key rejection, symlink leaf/parent refusal via `O_NOFOLLOW` / `dir_fd`, process-group timeout termination, and telemetry suppression (`FLOW_LOG_DISABLE=1`) were verified through independent controlled replay.
2. **Doctor Registry & Bundled Tree Receipt (W1):** Exactly 12 named checks registered in `doctor-checks.tsv`. CLI argument pre-scanning ensures `--json` outputs a valid `schema_version: 1, kind: "doctor.report"` JSON envelope even on early syntax/check errors. Dev checkout correctly reports advisory skip (`status: "skip"`), while tampered/symlinked/missing files produce loud deterministic failures (`status: "fail"`, exit 1). Clean cutover from legacy portable manifest is complete. Tree receipt integrity verifies the complete bundled tree dynamically computed by `sync.mjs` (124–126 files depending on bundle build/fixtures).
3. **Safety Flaw Fixes in `tests/test_flow_host_hooks.sh` Verified:**
   - **PID Reuse:** All cleanup signal kills to PID file entries were eliminated. Only observational `kill -0` checks remain; zero global `pgrep`/`pkill` or arbitrary PID signalling occurs.
   - **Secret Leakage:** The tautological AKIA check was replaced with injected `secret_note` payload fields carrying the suite's own random-looking sentinel strings: one for the PreCompact event, asserted absent from the persisted snapshot file; one for the SessionStart event under a 200-byte output cap, asserted absent from both stdout and stderr. (Sentinel values are read live from `tests/test_flow_host_hooks.sh`; they are deliberately generic test fixtures, not real credentials.)
4. **Research Forensic & Inventory Alignment:**
   - The initial discrepancy in `component-analysis.json` (which previously listed invented rule paths like `rules/code-review.md`, `rules/git.md`, etc.) was repaired by the source worker. An independent check confirmed that all 8 actual rule files on disk (`development-rules`, `documentation-management`, `orchestration-protocol`, `primary-workflow`, `process-management`, `review-audit-self-decision`, `skill-domain-routing`, `skill-workflow-routing`) and 5 scripts (`resolve_env.py`, `set-active-plan.cjs`, `validate-skill-crossrefs.py`, `worktree.cjs`, `worktree.test.cjs`) are accurately analyzed with authentic headings and summaries.
   - All 193 component export paths declared in `inventory.json` exist on disk under `/home/manhquy/.agentkit/cache/kits/engineer/omp/2.18.1/engineer/`.
   - REA evidence retention correctly records 10 verified records (4 unknown-mutation records, 2 hooks JS analysis views — partial, 2 notifications static-analysis views over 6 JS files, 2 process captures) and 4 residual unknowns. Native decompilation was completely blocked (NONE) due to missing toolchain prerequisites (Headless Ghidra requires JDK 21+ with `GHIDRA_INSTALL_DIR` unset — host has Temurin JDK 17; `REA_PWNTOOLS_PYTHON` unset); REA performed CLI process scenario captures of `ak.bak` and static binary layout / string inspection. CFG and struct layouts were not produced (missing toolchain) and are documented narratively, distinct from the 4 residual unknowns, which cover process-filesystem/environment/process/network capture-coverage uncertainty. No proprietary code is committed.
5. **Repository Guardrails Honored:**
   - `_eval_engine_run` and `_run_with_timeout` in `skills/flow/runner/flow.sh` are **100% untouched** (`git diff` clean).
   - `website/` directory is untouched.
   - No new runtime dependencies introduced (POSIX shell + Python 3 stdlib).
   - Zero billable AI calls executed.

---

## 2. Independent Controlled Verification Matrix

An independent verification suite was executed using the real runner in isolated temporary directories (`/tmp/flow-review-*`) and thoroughly cleaned up afterwards.

*Platform Scope:* All tests below were verified on Linux x86-64 (kernel 7.0). No runtime or behavioral claims are made for macOS or Windows Git Bash.

| # | Test Scenario | Expected Behavior | Observed Result | Status |
|---|---|---|---|---|
| 1 | `PreCompact` with valid flow project | Exit 0, stdout empty | Exit 0, stdout length 0 | **PASS** |
| 2 | `PreCompact` snapshot permissions | File mode `0600`, dir mode `0700` | File `0600`, dir `0700` | **PASS** |
| 3 | `SessionStart` after project mutation | Fresh authoritative recompute citing snapshot | Fresh `flow.sh status` with newly added card `C-001`, `[source: fresh ...]` header, pre-compact cited as valid reference | **PASS** |
| 4 | Telemetry suppression | `events.jsonl` not created on hook invocation | `.flow/events.jsonl` absent | **PASS** |
| 5 | Auto-init prevention | Project with `flow/` but no `.flow` directory | `.flow` is NOT created; stdout empty; exit 0 | **PASS** |
| 6 | Malformed JSON input | Unparseable stdin payload | Fail-open exit 0; stdout empty; warning on stderr | **PASS** |
| 7 | Duplicate JSON key payload | `{"hook_event_name":..., "hook_event_name":...}` | Fail-open exit 0; stdout empty; duplicate key warning on stderr | **PASS** |
| 8 | Symlinked `.flow` parent directory | Parent directory `.flow` is a symlink | `O_NOFOLLOW` refuses snapshot write; real target untouched; exit 0 | **PASS** |
| 9 | Symlinked `snapshot.json` leaf | Destination leaf `snapshot.json` is a symlink | `O_NOFOLLOW` refuses write; symlink target untouched; exit 0 | **PASS** |
| 10 | Reading symlinked snapshot leaf | `SessionStart` encounters symlinked snapshot | Snapshot cited as `symlink (refused)`; exit 0 | **PASS** |
| 11 | Lax private directory permissions | `.flow/context-handoff` mode `0755` | Write refused due to lax mode; exit 0 | **PASS** |
| 12 | Group-writable parent directory | `.flow` mode `0775` (`st_mode & 0o022`) | Write refused due to group-writable parent; exit 0 | **PASS** |
| 13 | Non-flow directory cwd | Directory lacking `flow/` and `.flow/` markers | Fail-open exit 0; stdout empty; warning on stderr | **PASS** |
| 14 | Doctor CLI listing | `flow doctor --list` | Displays 12 registered checks with descriptions | **PASS** |
| 15 | Doctor JSON listing | `flow doctor --list --json` | Valid `schema_version: 1, kind: "doctor.list"` | **PASS** |
| 16 | Doctor check filtering | `flow doctor --check os,bash --json` | Reports only `os` and `bash` in `checks` array | **PASS** |
| 17 | Unknown check name | `flow doctor --check invalid_xyz` | Loud exit 1; error message naming `invalid_xyz` | **PASS** |
| 18 | Unknown check JSON error | `flow doctor --check invalid_xyz --json` | Valid `schema_version: 1, kind: "doctor.report"`, `healthy: false`, summary fail=1, exit 1 | **PASS** |
| 19 | Dev checkout receipt | `flow doctor --json` on dev checkout | `bundled_tree_integrity` reports `status: "skip"` ("dev checkout"); `healthy: true`, exit 0 | **PASS** |
| 20 | Tree receipt: valid bundle | `verify-receipt` with authentic `manifest-hashes.json` | Returns `OK:<count>` | **PASS** |
| 21 | Tree receipt: missing file | File listed in receipt deleted | Returns `FAIL:missing bundled file(s): <name>` | **PASS** |
| 22 | Tree receipt: tampered file | Byte modification in bundled file | Returns `FAIL:modified bundled file(s): <name>` | **PASS** |
| 23 | Tree receipt: symlink in tree | Symlinked leaf or directory in bundled tree | Returns `FAIL:symlink(s) in bundled tree: <name>` | **PASS** |
| 24 | Tree receipt: path traversal | Entry with `../outside.txt` in receipt | Returns `FAIL:unsafe path(s) in receipt: ../outside.txt` | **PASS** |
| 25 | Tree receipt: duplicate keys | Duplicate JSON keys in receipt | Returns `FAIL:malformed receipt JSON (duplicate key: ...)` | **PASS** |
| 26 | Tree receipt: symlinked receipt | `manifest-hashes.json` is a symlink | Returns `FAIL:manifest receipt file cannot be a symlink` | **PASS** |
| 27 | Supplementary: `PreCompact` injected secret | Injected secret token in `PreCompact` payload | Snapshot persisted (0600 mode, valid JSON); stdout 0 bytes; secret absent from stdout, stderr, and snapshot file | **PASS** |

*Verification Artifact:* All temporary directories created during reviewer verification (`/tmp/flow-review-*`) were cleanly unlinked upon test completion.

---

## 3. Workstream W2 Review — Host Lifecycle Context Adapters

### 3.1 Architecture & ADR-0001 Addendum Compliance
- **Invocation & Lifetime:** Invoked strictly by the host agent on lifecycle events (`SessionStart`, `PreCompact`). Execution terminates immediately when the process finishes; no background daemons, cron jobs, or persistent servers are spawned.
- **Fail-Open Scope:** The adapter fails open (exit 0) on all handled event input faults (malformed JSON, duplicate keys, oversize payloads, stdin deadline timeouts), missing/unusable Python runtime, runner timeouts, and unexpected Python unhandled exceptions via `sys.excepthook` / `os._exit(0)`. (This boundary covers software/input exceptions; it does not claim survival under uncatchable OS process kills like `SIGKILL` or hardware faults).
- **Zero Interposition:** The adapter does not register for or handle `PreToolUse`, `PostToolUse`, or tool-filtering hooks. It does not inspect, rewrite, or authorize tool commands.
- **Private State Boundary:** The sole permitted on-disk write is `.flow/context-handoff/snapshot.json`. The parent `.flow` directory is never created or chmodded by the adapter.

### 3.2 Security & Isolation Implementation
- **File System Operations:** Traversal uses `dir_fd` with `O_NOFOLLOW | O_DIRECTORY`. Existing `.flow` and `context-handoff` directories must be owned by the current user (`st_uid == getuid()`) and must not be group/world-writable (`st_mode & 0o022 == 0`). The private directory must be exactly `0700`.
- **Atomic Writes:** Snapshots are staged into a randomly named secret file (`.stage-<token_hex>`) opened with `O_CREAT | O_EXCL | O_NOFOLLOW` mode `0600` inside the private directory fd, followed by `os.replace` via `dir_fd`.
- **Process Group Isolation:** Runner calls are spawned with `start_new_session=True`. The saved process group ID (`pgid`) is tracked. In timeout scenarios, `os.killpg(pgid, signal.SIGKILL)` is sent to terminate child and descendant processes before reaping the root process, preventing orphaned processes.
- **Telemetry & Root Shielding:** Runner calls explicitly set `FLOW_LOG_DISABLE=1` and pin `FLOW_PROJECT_ROOT` to the validated project path, preventing telemetry logging and cross-project pollution from host session environments.

---

## 4. Workstream W1 Review — Doctor Registry & Whole-Tree Integrity

### 4.1 Named Registry & CLI Parser
- The registry in `skills/flow/runner/doctor-checks.tsv` contains exactly 12 checks across defined categories:
  - `environment`: `os`, `bash`
  - `runtime`: `python`, `sqlite3`
  - `tools`: `grep_p`, `git`, `cargo`, `timeout`
  - `assets`: `templates`, `harness`
  - `integrity`: `bundled_tree_integrity`
  - `install`: `install_homes`
- Argument pre-scanning in `skills/flow/runner/flow.sh` inspects `$@` for `--json` prior to parsing flags, guaranteeing that errors like `--list and --check cannot be combined` or `--check requires an argument` emit structured JSON envelopes when `--json` is supplied.
- Check names are deduplicated and validated against the registry. Unknown checks trigger exit 1 with a helpful message directing the user to `flow doctor --list`.

### 4.2 Whole-Tree Receipt & Tamper Detection
- `npm-wrapper/scripts/sync.mjs` generates `skills/flow/manifest-hashes.json` containing SHA-256 digests dynamically computed across all shipped assets in the bundled tree (124–126 files depending on bundle build/fixtures).
- `skills/flow/runner/doctor_helper.py verify-receipt`:
  - Enforces `schema_version: 1` and rejects duplicate JSON keys.
  - Verifies that `manifest-hashes.json` itself is a regular file and not a symlink.
  - Rejects backslashes, leading/trailing slashes, drive colons, empty segments, and path traversal components (`.`, `..`).
  - Walks each path component verifying that neither ancestor directories nor the leaf target are symlinks.
  - Verifies that targets strictly resolve within the skill root directory.
  - Validates file SHA-256 digests against recorded hashes.

---

## 5. Research Forensic & Evidence Alignment

### 5.1 Rules & Scripts Alignment
- **Rules Alignment:** Earlier draft discrepancy in `component-analysis.json` had placeholder keys (`code-review`, `git`, etc.). This was corrected by `agentkit-source` through direct inspection of the 8 authentic rule files in `/home/manhquy/.agentkit/cache/kits/engineer/omp/2.18.1/engineer/rules/`:
  1. `development-rules.md` (`# Development Rules`)
  2. `documentation-management.md` (`# Project Documentation Management`)
  3. `orchestration-protocol.md` (`# Orchestration Protocol`)
  4. `primary-workflow.md` (`# Primary Workflow`)
  5. `process-management.md` (`# Process and Resource Management`)
  6. `review-audit-self-decision.md` (`# Review, Audit, and Decision Rules`)
  7. `skill-domain-routing.md` (`# Skill Domain Routing`)
  8. `skill-workflow-routing.md` (`# Skill Workflow Routing`)
- **Scripts Alignment:** The 5 scripts in `scripts/` (`resolve_env.py`, `set-active-plan.cjs`, `validate-skill-crossrefs.py`, `worktree.cjs`, `worktree.test.cjs`) have authentic functional summaries matching their executable headers and implementations.
- **Inventory Component Walk:** An independent file-existence check confirmed that all 193 component paths listed in `inventory.json` exist on disk (0 missing).

### 5.2 REA Evidence & Native Analysis Transparency
- `evidence-index.json` indexes 10 authentic Evidence records (`ev_*`) and 4 residual unknowns (`unk_*`). The 10 records comprise 4 unknown-mutation records, 2 JavaScript analysis views on `hooks` (partial within view), 2 auxiliary static-analysis views on `notifications` (6 JS files parsed), and 2 process captures — not 10 independent analyses.
- As disclosed in `REPORT.md` §2.2, native decompilation of the stripped `ak` Go binary was completely blocked (NONE) due to missing host dependencies (Headless Ghidra requires JDK 21+ with `GHIDRA_INSTALL_DIR` unset — host has Temurin JDK 17; `REA_PWNTOOLS_PYTHON` unset). This native gap is documented narratively only and is **not** one of the 4 residual unknowns: those (`unk_22be913d…`, `unk_625c2d6c…`, `unk_6c8b4107…`, `unk_7b81cc74…`) cover process-filesystem, process-environment, process-process, and process-network capture-coverage uncertainty from the CLI scenarios.
- REA operations were limited to PTY process captures of `/home/manhquy/.local/bin/ak.bak` (actual `ak.bak --version` output `ak 2.19.0`; a partial ANSI-bounded `ak.bak --help` frame) plus static binary layout / string inspection. The dangling `/home/manhquy/.local/bin/ak` symlink was observed by separate host static filesystem inspection, not by any CLI capture.
- Control-flow graph reconstruction and internal Go struct layouts were not produced (missing toolchain); their absence is documented narratively as a blocked prerequisite, distinct from the 4 capture-coverage unknown IDs, rather than fabricated outputs.
- No raw proprietary code or proprietary EULA text was checked into the repository, respecting commercial license boundaries.

### 5.3 Skills Whitelist & Aliases Review
- `skills/flow/references/claudekit-skills.md` defines an exact whitelist with live-registry-first resolution rules.
- `security-scan` row explicitly confirms: *"— no kit alias: AgentKit ships no `security-scan` export (2026-10-13 inventory); offer only what a live-registry probe actually verifies"*.
- The STRIDE honesty clause explicitly disallows relabeling semantic threat modeling as mechanical security scanning and forbids inventing `ak-security-scan`.
- All other alias mappings (`ck-predict` -> `ak:predict, ak-predict, predict`, `ck-scenario`, `ck-security`, `ck-loop`, `ck-graphify`, `review-pr`, `retro`, `xia`, `deploy`, `web-testing`, `docs-seeker`, `scout`, `repomix`) accurately reflect the verified inventory without speculative additions.

---

## 6. Verification and Integration Verdict

| Evaluation Dimension | Standard / Requirement | Result |
|---|---|---|
| Invariant Preserved | ADR-0001: Process token terminates when handler returns | **Compliant** |
| Security Boundaries | Symlink/owner/mode validation, process-group kill, telemetry suppression | **Compliant** |
| Registry Precision | 12 checks in TSV; early JSON error formatting; clean cutover | **Compliant** |
| Forensic Honesty | Real disk paths, accurate headings/summaries, honest blocked native decompilation | **Compliant** |
| Repository Safety | Untouched `_eval_engine_run`, `_run_with_timeout`, and `website/` | **Compliant** |

### Verdict: **targeted slices verified; full 66-suite result unverified**
Targeted slices (W1 doctor, W2 host hooks, manifest runner, npm tests, pack rehearsal, doc budgets, release coherence) and 27-scenario controlled reviewer matrix are verified with zero blocking P0/P1 issues. Full 66-suite master test run terminal exit receipt is unavailable in session transcript (evidence-access blocker; no success inferred from prior run or process state). Native decompilation is NONE blocked due to missing toolchain prerequisites. Status is strictly targeted slices verified; full 66-suite result unverified.
