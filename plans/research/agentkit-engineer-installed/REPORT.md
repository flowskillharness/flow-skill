# Source Forensics & Flow Architecture Upgrades: Deep Analysis of Installed AgentKit Engineer

**Date of Investigation:** 2026-10-13 (REA captures recorded UTC 2026-10-12T18:09:08Z)  
**Status:** Completed Static Source Analysis & W1 Implementation Verified (targeted slices verified; full 66-suite result unverified)  
**Target Repository:** `/home/manhquy/Documents/flow-skill`  
**Research Artifacts Location:** `plans/research/agentkit-engineer-installed/`  
**Artifacts Generated:**
1. [`inventory.json`](./inventory.json) — Complete machine-readable inventory of 1,710 claimed assets, roots, digests, and metadata.
2. [`component-analysis.json`](./component-analysis.json) — Differentiated semantic matrix analyzing constituent skills, agents, hooks, and support modules with inputs, dependencies, side effects, constraints, and Flow reuse rationale.
3. [`evidence-index.json`](./evidence-index.json) — Sanitized REA evidence index referencing 10 verified records and 4 residual unknowns. (The raw 49.4 MB bundle with inline source is preserved externally at `/tmp/rea-evidence-bundle-agentkit-engineer.json` per repository privacy and commercial non-redistribution constraints).
4. [`REPORT.md`](./REPORT.md) — This authoritative synthesis and upgrade roadmap.

---

## 1. Identity, Provenance & License Findings

### 1.1 Binary Identity & Host State Discovery
* **Authoritative Executable:** `/home/manhquy/.local/bin/ak.bak`  
  *(Host Symlink Observation: Host `/home/manhquy/.local/bin/ak` was found repointed to `/usr/local/bin/ak -> /opt/ak-gui/ak-gui.AppImage`, a dangling path on disk. The authentic CLI executable was preserved at `ak.bak`.)*
* **Binary Digest (SHA-256):** `563a9bbd394c200406afd177599d86590d177be7bc3e3c6175683248fb71dce3`
* **ELF BuildID (SHA-1):** `69b40ffe740ef96cd960ff230d80d46b2ef9560c`
* **Architecture & Binary Format:** ELF 64-bit LSB executable, x86-64, statically linked, stripped.
* **Compiler & Runtime Engine:** Compiled Go binary (verified via runtime symbol strings: `runtime.goroutineProfileState`, `runtime.goready`, `runtime.gogetenv`, `runtime.goPanicIndex`).
* **Binary Version:** `2.19.0` (commit `1f79164e6dd197c957d2155a850cce0ca03a0adb`, build date `2026-09-28T07:32:00Z`).
* **REA Evidence Limitation:** The executable digest is a prelaunch file sample; matching path metadata immediately after spawn does not prove an atomic operating-system image binding.

### 1.2 Kit Identity & Licensing Rights
* **Kit Identity:** `engineer` (version `0.2.0`, cached under runtime adapter targets `omp/2.18.1` and `dsh/2.18.1`).
* **License & Commercial Status:**
  * `ak licenses --json` confirms an active account entitlement: `authenticated: true`, `authMethod: "email_otp"`, `licenses: [{kitId: "engineer", status: "active", grantType: "license", productId: "engineer"}]`.
  * **Critical Legal Boundary:** An active license entitlement for the operator's account does **not** convey open redistribution or re-licensing rights.
  * The full commercial End User License Agreement / terms document is **unavailable locally** in the cache files.
  * Individual constituent skills contain varied upstream permissive licenses (e.g., MIT, Apache-2.0 in selected skills like `ak-skill-creator`), but the assembled Engineer kit and its proprietary hook runners are commercial AgentKit distribution assets.
  * **Policy:** No proprietary code or hook bodies are republished or committed to the repository. All architectural descriptions are original technical syntheses.

### 1.3 Install Roots & Ownership Partitioning
* **Authoritative Kit Cache:** `/home/manhquy/.agentkit/cache/kits/engineer/omp/2.18.1/engineer`
* **Distribution Tarball:** `/home/manhquy/.agentkit/cache/kits/engineer/omp/2.18.1/.agentkit-cache/artifact.tar.gz` (8,000,003 bytes)
* **Adapter Ownership Manifest:** `/home/manhquy/.agentkit/adapters/omp/engineer/omp-ownership.json` (452,286 bytes, 1,710 total claims)
* **Runtime Skill Projections:**
  * `~/.omp/agent/skills`: 149 total skills (65 Engineer-exclusive, 37 shared Engineer/Marketing, 44 Marketing-exclusive, 3 third-party: `browser-skill`, `impeccable`, `security-audit`).
  * `~/.agents/skills`: 4 standalone skills (`browser-skill`, `find-skills`, `herdr`, `reverse-engineer-anything`).
* **Secrets Exclusion Boundary:** `/home/manhquy/.agentkit/auth` (2 files containing plaintext tokens/email OTP state, excluded unread).

---

## 2. REA MCP Reverse Engineering Diagnostics & Raw Results

REA tools were executed directly via `xd://mcp__rea_*`. All tool outcomes were captured with authentic Evidence records.

### 2.1 Authenticated REA Evidence Records
The REA MCP session retained **10 records and 4 residual unknowns** (composition: 4 unknown-mutation records, 2 hooks JavaScript analysis views — partial within view, 2 auxiliary `notifications` static-analysis views covering 6 JS files, and 2 process captures; not 10 independent analyses), exported externally to `/tmp/rea-evidence-bundle-agentkit-engineer.json` (49,435,238 bytes) with sanitized index at `plans/research/agentkit-engineer-installed/evidence-index.json`:
1. **`ev_656890bbacb42575d39110398965fa5c81c07d9d31c112174cdc16ad33359ef3`:**
   - **Operation:** `capture_process_scenario`
   - **Target:** `/home/manhquy/.local/bin/ak.bak --version`
   - **Provider:** `rea-process` v3 (controlled PTY execution)
   - **Observed Exit & Frame:** `exit: 0`, frame `ak 2.19.0\n`
   - **Digest Verified:** `563a9bbd394c200406afd177599d86590d177be7bc3e3c6175683248fb71dce3`
2. **`ev_74643d62c09653f9b67d08d646792a58f59828f22508494f17f4ab19828f53c4`:**
   - **Operation:** `capture_process_scenario`
   - **Target:** `/home/manhquy/.local/bin/ak.bak --help`
   - **Provider:** `rea-process` v3
   - **Observed Frame Reality:** **Retained partial stdout frame**. Due to terminal render and cell bounds, the capture frame ends abruptly at ANSI escape sequence `\x1b[38;2;156;163;1` in the feedback/help section. It confirms commands up through `diagnostics`, `doctor`, `eval`, but does **not** prove full trailing command topology without follow-up scrolling scenarios.
3. **`ev_5760d4c19da91bd89b4f4e0de09a4c9399df8ef16af5247216a0146096d75cfb` & `ev_06b98305930cc46cac3687b5e84471e9273301dfd54679690ceede7d47d26daa`:**
   - **Operation:** `analyze_javascript_application` & `inspect_analysis_view`
   - **Target:** Shipped directory `/home/manhquy/.agentkit/cache/kits/engineer/omp/2.18.1/engineer/hooks`
   - **Provider:** `rea-javascript-application` & `rea-analysis-view` v1 / JavaScript AST analyzer
   - **Coverage:** Partial within view across shipped hooks; semantic facts and unshadowed AST nodes retained; budget limitations noted for expanded relationship nodes.
   - **Auxiliary View:** `ev_deb05dfaa8ee9360de7c06f6f3ecda6e25f0508668d81c29d5e3e88467b93b8a` & `ev_cb4d036928c8798086ecf2b006cc6a17e94054dfd0cb338055f21d42ea7e0dd2` (scoped notifications view, 6 JS files, 2,393 AST nodes, 22,106 text bytes).
### 2.2 Unresolved Native Decompilation Questions
* **Blocked Prerequisites:** Headless Ghidra requires JDK 21+ (`GHIDRA_INSTALL_DIR` unset; host has Temurin JDK 17.0.20.1); `pwntools-elf` requires `REA_PWNTOOLS_PYTHON` (unset; no pwntools configuration present).
* **Unresolved Ledger:** Full control-flow graph (CFG) analysis and internal Go struct layouts of the stripped `ak` CLI binary remain **unresolved** questions due to missing host decompiler toolchains. This native gap is documented narratively in this report; it is **not** recorded as one of the 4 residual unknowns in `evidence-index.json`. Those 4 unknown IDs (`unk_22be913d…` process-filesystem, `unk_625c2d6c…` process-environment, `unk_6c8b4107…` process-process, `unk_7b81cc74…` process-network) exclusively capture behavioral coverage uncertainty (filesystem, environment, process, network behavior fully observed?) from the CLI process scenarios. Static file inspection and PTY CLI captures provided behavioral boundaries without native disassembly. The dangling `/home/manhquy/.local/bin/ak` symlink was established by separate host static filesystem observation, not by any CLI capture.

---

## 3. Deep Component Analysis & File-Walk Reconciliation

### 3.1 Reconciled File-Walk Counts
* **Skills:** 102 exported in `kit.yaml` (100% verified synchronized in `~/.omp/agent/skills/`).
* **Agents:** 16 exported in `kit.yaml` (`agents/*.md`).
* **Hook Subsystem (62 total files on disk):**
  * **16 Top-Level Hooks (`hooks/*.cjs`):** Entrypoint scripts invoked by host agent events.
  * **46 Support Modules (`hooks/**/**/*.cjs`):** Distributed across `lib/` (22), `lib/agent-behavior-linter/` (4), `lib/context-firewall/` (4), `hooks/scout-block/` (5), and `hooks/notifications/` (11).
  *(Note on Kit Manifest: `kit.yaml` explicitly exports 54 hook paths: the 16 top-level scripts + 38 primary library modules. The remaining 8 modules on disk are internal nested helpers such as `vendor/ignore.cjs` and auxiliary notification providers).*
* **Output Styles:** 6 files (`output_styles/coding-level-0-eli5.md` through `coding-level-5-god.md`).
* **Rules:** 8 files (`rules/*.md`).
* **Schemas:** 1 file (`schemas/ck-config.schema.json`).
* **Scripts:** 5 files (`scripts/worktree.cjs`, `set-active-plan.cjs`, `resolve_env.py`, `validate-skill-crossrefs.py`, `worktree.test.cjs`).
* **Statusline:** 1 file (`.config/statusline.cjs`).

### 3.2 Hook Lifecycle & Enforcement Semantics
* **Hard Policy Gates (Exit Code 2 stops execution on violation; Exit Code 0 passes):**
  * `context-firewall.cjs`: Measures per-tool read sizes; exits code 2 if reading unbudgeted files > threshold.
  * `privacy-block.cjs`: Validates file paths against sensitive patterns (`.env`, `.ssh`, private keys); exits code 2 to abort tool call.
  * `scout-block.cjs`: Enforces ignore patterns and bounds directory searches; exits code 2 on broad walks.
  * `simplify-gate.cjs`: Intercepts refactoring / code simplification prompts; exits code 2 unless active plan exists.
* **Fail-Open / Advisory Lifecycle Hooks (Exit Code 0; catch all errors):**
  * `session-init.cjs`: Injects project orientation (git branch, common root, plan path) on startup/resume/compact; distinct from `flow doctor` environment sanity check.
  * `precompact-capture.cjs`: Captures machine-derivable orientation anchors (`worktree`, `mainRoot`, `branch`, `head`, `dirtyCount`, `activePlan`) into `compactRecovery` session state before context compaction under host hook timeout (2,000–5,000 ms).
  * `dev-rules-reminder.cjs`: Injects reminder context post-write.
  * `secret-output-guardrail.cjs`: Scans prompt submissions for credential leakage patterns.
  * `subagent-init.cjs` & `team-context-inject.cjs`: Injects minimal (~200 token) task contract preamble for child tasks.
  * `cook-after-plan-reminder.cjs`: Reminds operator to advance from planning to implementation.

### 3.3 Agent Roles & Flow Gate Authority
* **No Gate Approval Authority:** Pluggable agents (`planner`, `code-reviewer`, `tester`, `kongming`) operate strictly in authoring, diagnostic, or advisory capacities. In Flow, gate approval is governed deterministically by mechanical exit codes (`flow.sh`) and operator sign-off, never delegated autonomously to LLM agents.

### 3.4 Extended System Components Analysis
* **Output Styles (6 levels):** Configures assistant verbosity from Level 0 (ELI5 analogies) to Level 5 (surgical code patches, zero narrative filler).
* **Authentic Rules (8 files):**
  1. `development-rules.md`: Baseline quality gates, project docs adherence, local pattern reuse, testing before completion.
  2. `documentation-management.md`: Rules for when to update documentation (only user-visible behavior/setup changes); plan updates during implementation.
  3. `orchestration-protocol.md`: Subagent delegation context requirements (task contract, file isolation, non-goals, status reporting).
  4. `primary-workflow.md`: 4-stage delivery chain: 1. Brainstorm outcome -> 2. Inspect codebase -> 3. Plan and implement -> 4. Verify against acceptance criteria.
  5. `process-management.md`: Prevention of orphaned "ghost" processes; tracking child PIDs, terminating background listeners, watchers, and servers.
  6. `review-audit-self-decision.md`: Decision reversibility rules: do not reverse empirically verified decisions based on abstract audit concerns unless new evidence is provided.
  7. `skill-domain-routing.md`: Procedure for routing work to domain skills using runtime's live installed skill catalog rather than hardcoded tables.
  8. `skill-workflow-routing.md`: Capability-based workflow selection (core development, bugfix, investigation, post-implementation) skipping unavailable optional capabilities.
* **Schemas (1 file):** `schemas/ck-config.schema.json` defines JSON Schema validation for kit model roles and hook bindings.
* **Authentic Scripts (5 files):**
  1. `resolve_env.py` (11.0 KB): Centralized environment variable resolver implementing Claude Code precedence (process.env > project config > global config > defaults).
  2. `set-active-plan.cjs` (3.0 KB): Updates the durable session-state JSON store with the active plan path and updates statusline tracking.
  3. `validate-skill-crossrefs.py` (6.4 KB): Discovers skills from current SKILL.md files and validates markdown links and reference anchors across the installed kit.
  4. `worktree.cjs` (218 B): Backward-compatible launcher script delegating worktree management commands to the canonical ak CLI worktree implementation.
  5. `worktree.test.cjs` (226 B): Test runner script delegating worktree integration tests to the canonical test suite.
* **Statusline (1 file):** `.config/statusline.cjs` renders dynamic terminal statuslines displaying active models, branch, and token quotas.
* **Adapter Status Disclosed:** `ak doctor` reports `hook_registration: skip` on this host. Adapter agents and hooks reside in cache and sidecars, remaining dormant until explicitly enabled by host adapter configuration.
---

## 4. Flow Architecture Comparison & Overlap Truth

* **Flow's True Three-Layer Architecture:**
  * **Semantic Layer:** `SKILL.md` + `references/` (Claude prompt judgment, gate challenges).
  * **Mechanical Layer:** `skills/flow/runner/flow.sh` (pure bash 3.2, deterministic exit 0/1).
  * **Durable Layer:** `skills/flow/harness/flow_harness.py` (Python 3 stdlib + SQLite3 managing `.flow/harness.db`). Flow has **zero external package dependencies** (built-in `sqlite3`), but is **not pure POSIX shell**—it leverages Python for durable relational state.
  * **Artifacts:** `cards/C-NNN.md` (atomic shipping units), `flow/00-idea.md` .. `05-contract.md`, `MODE`, `RETRO.md`, `DEBT.md`, `AUTO-LOG.md`, `DESIGN.md`.
* **External Memory Overlap:**
  * Flow *already* possesses durable SQLite external memory in `.flow/harness.db` (recording stories, proofs, traces, decisions, backlogs) surviving context compaction.
  * AgentKit's `precompact-capture.cjs` solves an anchor-capture trigger gap; Flow's opt-in synchronous checkpoint adapter addresses this without new daemons.


### 4.2 Comprehensive Architecture Map
| Dimension | Component / Layer | Key Artifacts | Operational Mechanics & Tool Flow | Flow Outcome Rationale |
|---|---|---|---|---|
| **Role Personas** | Pluggable Agents (16) | `agents/*.md` (`planner`, `tester`, `code-reviewer`, `kongming`) | Whitelisted tool subsets, specialized prompt instructions, and role hierarchy. Run as isolated subagents. | **Pluggable Workers:** Usable by Flow during card build/verify stages; zero autonomous gate authority. |
| **Hook Lifecycle** | Event Interceptors (16 top-level + 46 support) | `hooks/hooks.json`, `hooks/*.cjs` | Intercepts 8 lifecycle events (`SessionStart`, `PreToolUse`, `PostToolUse`, `PreCompact`, etc.). Hard gates exit code 2; lifecycle hooks exit code 0. | **W2 Context Adapter:** Flow adopted host-fired SessionStart/PreCompact status handoffs without resident daemons or tool blocking. |
| **Integrity Schemas** | Configuration & Receipts | `ck-config.schema.json`, `manifest-hashes.json` | JSON Schema validation for kit settings; byte-level SHA-256 tree manifests for tamper detection. | **W1 Tree Receipt:** Flow implemented tree-wide `manifest-hashes.json` (all packaged skill files; count generated from current source at pack time) with ancestor symlink and traversal checks. |
| **Durable Storage** | Operational Memory | AgentKit SQLite (`operational.db`) vs Flow SQLite (`harness.db`) | Relational persistence of stories, card traces, decisions, and attestation receipts surviving session compaction. | **Preserved Boundary:** Flow preserves `.flow/harness.db` with zero external pip dependencies; no daemon growth. |
---

## 5. Workstream 1 (W1) Slice A Implementation Deliverable

W1 Slice A has been implemented, tested, and verified:

### 5.1 Owned Files & Interfaces Delivered
1. `skills/flow/runner/flow.sh`:
   - Refactored `cmd_doctor` with argument pre-scanning (`--json`, `--list`, `--check`), canonical check selection, single registry list, NUL-delimited field records transport, and `cmd_doctor "$@"` dispatch.
   - Clean cutover: Removed legacy runner-only hash fallback (`portable-manifest.json`). Absent receipt in dev checkout reports advisory skip (`status: skip`); malformed/drifted receipts trigger loud **FAIL** (exit 1).
2. `skills/flow/runner/doctor_helper.py`:
   - Dedicated Python 3.8+ helper implementing single source registry, `list` / `list-json`, `validate-checks`, `format-error`, `format-report`, and `verify-receipt`.
   - Full tree verification validates leaf and ancestor symlinks, strict root containment, duplicate JSON key rejection, and 64-hex digest format fullmatch.
3. `npm-wrapper/scripts/sync.mjs`:
   - Generates full bundled-tree receipt (`skills/flow/manifest-hashes.json`) across all packaged skill files (count generated from the current source tree at pack time; 126 observed at the rehearsal pack).
4. `scripts/pack-rehearsal.sh`:
   - Updated receipt verification to validate tree receipt on clean install, verify loud FAIL on tampered runner, and verify OK after restoration.
5. `skills/flow/references/command-dispatch.md`:
   - Documented `/flow doctor [--list] [--check <csv>] [--json]`.
6. `docs/system-architecture.md`:
   - Documented doctor check registry and full bundled tree integrity receipt.
7. `CHANGELOG.md`:
   - Recorded doctor registry and full bundled tree integrity receipt under `[Unreleased]`.
8. `tests/test_flow_doctor.sh`:
   - Comprehensive behavioral test suite covering 40 test cases (registry discovery, flags, error envelopes, receipt tamper/missing/malformed/traversal/symlink boundaries, NUL transport, isolated HOME environment).
9. `tests/manifest.txt`:
   - Registered `test_flow_doctor.sh` in the master test manifest.
10. `tests/test_flow_runner.sh`:
    - Updated section I to verify bundled tree receipt clean cutover without obsolete portable manifest fallback.

### 5.2 Verification Evidence
- `tests/test_flow_doctor.sh`: **40 passed, 0 failed**.
- `tests/test_manifest_runner.sh`: **12 passed, 0 failed**.
- `tests/test_flow_runner.sh`: **28 passed, 0 failed**.
- `npm-wrapper` tests (`npm test`): **45 passed, 0 failed**.
- Pack rehearsal (`scripts/pack-rehearsal.sh`): **22 passed, 0 failed** (clean install verified, tamper detected with exit 1, restored verified).

### 5.3 Integration Status & Peer Coordination
* **Current State:** targeted slices verified; full 66-suite result unverified (missing prerequisite: master full-suite terminal exit summary retention).
* **Coordination Plan:** Targeted suites and independent review are complete; full 66-suite master test run terminal receipt is unverified. No git commits on research branch.
