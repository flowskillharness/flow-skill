# Forensic Analysis: AgentKit Handoff & Subagent Recovery vs Flow Discipline Layer

**Date:** 2026-10-13  
**Target System:** AgentKit CLI `ak 2.19.0` (observed via controlled CLI capture `ak.bak --version` [ev_656890bbacb42575d39110398965fa5c81c07d9d31c112174cdc16ad33359ef3]; kit cache installation path: `~/.agentkit/cache/kits/engineer/omp/2.18.1/engineer/`)  
**Investigator:** Source Forensics & Upgrade Workstream  
**Research Artifacts Location:** `plans/research/agentkit-handoff-contracts/`  
**Artifacts Generated:**
1. Forensic Investigation Report: `plans/research/agentkit-handoff-contracts/REPORT.md` (this document)
2. Sanitized REA Evidence Index: `plans/research/agentkit-handoff-contracts/evidence-index.json`
3. Architectural Decision Record & Evaluation: `plans/research/agentkit-handoff-contracts/handoff-upgrade-plan.md`

---

## 1. Concrete Subsystem Analysis in Installed AgentKit Engineer

### 1.1 `ak:handoff` Continuation Contract Engine
* **Source Location:** `skills/ak-handoff/SKILL.md` (v2.1.0) and `skills/ak-handoff/references/`.
* **Purpose & Distinction:**
  * `ak:handoff` generates a **continuation contract for successor AI agents**, explicitly distinct from `ak:watzup` (which generates human-facing progress summaries from git logs and worktrees).
  * It records mission focus, guardrails, git status/diff, decisions made, verification outcomes, and the first safe action—never dumping raw conversational transcripts or chain-of-thought.
* **Artifact Schema Structure (`references/artifact-schema.md`):**
  * Target path: `plans/handoffs/<slug>-<YYYYMMDD-HHmm>.md`.
  * Prescribes 9 H2 sections:
    1. `## Mission and current status` (Focus, Done list, Remaining list, Urgency).
    2. `## Scope and guardrails` (Workspace, In scope, Out of scope, Constraints, Safety boundaries).
    3. `## Current state` (Branch, HEAD, Working tree clean/dirty, Changed files, Untracked files).
    4. `## Decisions and rationale` (Table: Decision — Rationale — Alternative rejected — Reference).
    5. `## Work performed` (Bulleted commands executed with observed outcomes, file-level changes).
    6. `## Verification` (Table: Check — Command — Outcome — When; explicit `Not run:` list).
    7. `## Open risks and blockers` (Bulleted items with Type, Owner, Impact).
    8. `## Exact next actions` (Numbered list; first item prefixed `**First safe step**`).
    9. `## Source pointers` (Repo-relative paths and verified URLs).
* **Secret Redaction Pipeline (`references/redaction-patterns.md`):**
  * Uses regex pattern matching over tokens, JWTs, PEM blocks, SSH keys, `.env` values, and database connection strings before writing.
  * Replaces matched secrets with stable tokens (`[REDACTED:aws-key]`, `[REDACTED:jwt]`).
  * *Important Constraint:* Text-based regex redaction is a heuristic filter; it does not provide cryptographic or deterministic prevention against novel or obfuscated credentials in arbitrary diffs.

### 1.2 Subagent Delegation Protocol & State Store
* **Delegation Context (`rules/orchestration-protocol.md`):**
  * Full conversation history is explicitly suppressed. Prompts receive only task, allowed files to modify, read-only files, acceptance criteria, constraints, and work context path.
* **Subagent Status Machine:** All subagents are required to end with a standardized four-state machine response:
  ```text
  Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
  Summary: <one or two sentences>
  Concerns/Blockers: <optional>
  ```
* **Durable Session Checkpoint Store (`hooks/lib/project-handoff-store.cjs`):**
  * *(Status: Observed via static file read; dynamic runtime trace unobserved. No live ak:handoff execution trace or project-handoff-store dynamic trace was captured.)*
  * Manages session state files under `~/.agentkit/session-states/v2/<runtime>/<projectKey>/`.
  * Maintains numbered, immutable event revisions (`revisions/`) and verified checkpoints (`checkpoints/`).
  * Checkpoint schema: `schemaVersion: 2`, `sourceSessionKey`, `eventRevision`, `snapshotRevision`, `branch`, `activePlan`, `todos` (capped at 200 items), `modifiedFiles` (capped at 100 items), with 7-day TTL expiry.
* **Agent Status Authority Matrix:**
  * `planner` (`agents/planner.md`): Tech Lead persona. Formulates dependency DAGs, failure modes, rollback strategies. Status authority is **advisory and authoring only**—does not approve production gates.
  * `tester` (`agents/tester.md`): QA Lead persona. Runs test suites, analyzes coverage, verifies error handling. Authority is **verification reporting only**.
  * `code-reviewer` (`agents/code-reviewer.md`): Staff Engineer persona. Audits diffs for production traps, security defects, and regressions. Authority is **advisory feedback only**.
* **Runtime Orchestration & Daemon Claims:**
  * Any claims of background daemons, persistent servers, or resident runtime orchestration are `[UNOBSERVED]`: no resident background loop or daemon was observed in retained process scenario captures. Furthermore, no global proprietary license claims are asserted; observations are strictly bounded to local files and captured CLI invocations.
---

## 2. REA MCP Reverse Engineering Evidence & Scoping

* **Retained Evidence Inventory (No New Tool Invocations or REA Reruns):**
  1. `ev_7773c2b267566769dfd9707c5334b6c800feea890ea62688f7fe6beed47e3934`: `inspect_analysis_view` on `hooks/scout-block` (static AST syntax analysis; conservative relationship candidates; no dynamic execution).
  2. `ev_231a9a8e777ddbe28083bff49d49788242f1211be5fc10e4088ae59e0cd359a2`: `analyze_javascript_application` on `hooks/scout-block` (static AST graph; no dynamic trace).
  3. `ev_deb05dfaa8ee9360de7c06f6f3ecda6e25f0508668d81c29d5e3e88467b93b8a`: `inspect_analysis_view` on `hooks/notifications` (static AST analysis view; no dynamic execution).
  4. `ev_656890bbacb42575d39110398965fa5c81c07d9d31c112174cdc16ad33359ef3`: `capture_process_scenario` on `ak.bak --version` (observed exit 0; stdout `ak 2.19.0`).
  5. `ev_74643d62c09653f9b67d08d646792a58f59828f22508494f17f4ab19828f53c4`: `capture_process_scenario` on `ak.bak --help` (observed exit 0; partial stdout frame bounded by terminal cell render cap).
  6. `ev_fcabdc1a35a2ac55423a4b67db60cfc19c193894157d8a4e0b2e8d466daabe9e`: `capture_process_scenario` on `ak.bak backups --help` (observed exit 0; snapshot subcommand summary).

* **Observed Scope & Truthful Boundaries:**
  - The retained evidence is strictly divided between **static AST inspection** (`hooks/scout-block/`, `hooks/notifications/`) and **controlled CLI process observations** (`ak.bak` version/help).
  - **No live `ak:handoff` dynamic execution trace** and **no live `project-handoff-store` runtime trace** was captured.
  - Background daemons, resident processes, and runtime orchestrators remain `[UNOBSERVED]`.
  - Unmeasured execution speed assertions (such as "<100ms") and assertions of "complete context" recovery are explicitly avoided; AST analysis is bounded to parsed syntax trees, and CLI observations are bounded to captured terminal stdout frames.
  - Native binary decompilation remains blocked by host prerequisites (Host JDK 17 vs JDK 21+ required for Ghidra; `GHIDRA_INSTALL_DIR` unset).
---

## 3. Deep Comparative Analysis Against Existing Flow Primitives

Before proposing any new commands, Flow's existing codebase was analyzed across runner, references, and durable storage:

### 3.1 Flow's Existing Handoff & Continuation Mechanisms
1. **Durable Relational Memory (`.flow/harness.db`):**
   - Flow already stores structured relational records for stories, proofs, traces, decisions, backlogs, and accessed counts via `flow_harness.py`.
   - This relational state persists across context compaction and session restarts without relying on file sprawl.
2. **Context-Bounded Resume (`flow.sh resume` & `flow.sh resume --budget`):**
   - In `skills/flow/runner/flow.sh:1017-1080`: `cmd_resume` reconstructs gate state, last session's command names, and stage transitions.
   - Crucially, line 1060 explicitly enforces secret masking: command names and exit codes are output, but **raw arguments are never printed** to prevent leaking unmasked credentials or tokens into LLM context.
3. **Atomic Execution Units (`cards/C-NNN.md`):**
   - Status vocabulary is closed and exact: `todo`, `in_progress`, `done`.
   - Every card explicitly documents `## Scope`, `## Allowed files`, `## Verify`, `## Done-evidence`, and `## Evidence`.
4. **Lifecycle Context Adapter (`context_handler.py` under ADR-0001 Addendum):**
   - Captures `flow.sh status` snapshot on `PreCompact` into `.flow/context-handoff/snapshot.json` (0600 mode, 0700 dir, fail-open, empty stdout).
   - Recomputes fresh authoritative status on `SessionStart`.
5. **Subagent Delegation Contract (`skills/flow/references/agent-stage-mapping.md:72-121`):**
   - Canonical Home: `skills/flow/references/agent-stage-mapping.md` (§Scoped prompt template). Per `AGENTS.md` ("One home per fact: Point; do not copy. Do not invent a second home for a fact that already has one"), full delegation rules remain authoritative in that file.
   - The canonical prompt template defines the subagent return contract:
     ```text
     summary: <one sentence what changed>
     evidence: <paths, commands, live proof>
     nextSteps: <parent-only; never skip/debt/merge>
     blocker: <empty unless BLOCKED or NEEDS_CONTEXT>
     STATUS: DONE|DONE_WITH_CONCERNS|BLOCKED|NEEDS_CONTEXT
     ```
   - Canonical cross-field semantics (docs-only; runner does not parse STATUS):
     - Last line MUST be `STATUS`. Missing `STATUS` is treated by the parent as `BLOCKED`.
     - `STATUS: DONE` requires non-empty `evidence:` and empty `blocker:`.
     - `STATUS: BLOCKED` and `NEEDS_CONTEXT` require a non-empty `blocker:`.
     - `nextSteps:` never skip, debt, or merge.
   - Flow already establishes a complete, evidence-gated 4-status terminal report without needing ungrounded prompt directives.
---

## 4. Challenge Matrix: Evaluating Candidate `/flow handoff`

| Architectural Challenge | Option A: Standalone `/flow handoff` Command | Option B: Extend Existing `flow resume` / Status Verbs | Option C: No Code Change (Document Existing Contract) |
|---|---|---|---|
| **One Home Per Fact (AGENTS.md line 16)** | **VIOLATION (Normative Source Duplication).** Cards already store scope, allowed files, and verify criteria. Harness DB stores decisions and traces. A new `plans/handoffs/` spec file creates a competing normative source of truth that drifts from authoritative files. *(Distinction: Nonauthoritative runtime caches/receipts like `.flow/context-handoff/snapshot.json` under ADR-0001 addendum are valid because they are transient, project-bound, privacy-restricted [mode 0700/0600], and re-verified fresh on start.)* | **COMPLIANT.** Surfaces existing card and harness facts through the existing `resume` interface without creating competing normative documents. | **COMPLIANT.** Relies on established card and harness records. |
| **Mutable State vs Stdout** | Unnecessary mutable duplicate state on disk. Creates filesystem churn, stale file accumulation, and potential credential leakage in diff files. *(Note: Writing to `plans/handoffs/` does not break `cards/C-*.md` globs, but disk persistence is unneeded.)* | **SUPERIOR (Boring Preference for Read-Only Stdout).** Pure stdout stream (read-only); zero disk mutation, zero stale state on disk. | Zero disk mutation. |
| **Secret Redaction Reality** | Text-based regex masking on raw git diffs cannot guarantee credential exclusion (e.g. novel token formats, base64 blobs). | **SUPERIOR.** Flow's `resume` avoids dumping raw diffs or arguments entirely; outputs bounded `diff --stat` and command names only. | Identical to Option B. |
| **Action & Gate Claims** | Risk of claiming "Gate PASS" from unverified text or inferring autonomous executable actions from prose. | Preserves Flow's deterministic gate discipline: only cites valid cryptographic attestation receipts (`attestations.sh`); action is display-only `NEXT_VERB`. | Identical to Option B. |
| **Runtime & Process Boundary** | Synchronous CLI output to stdout is safe; but writing files requires locking, cleanup, and disk lifecycle handling. | Pure stdout stream (read-only); zero disk mutation. | Zero disk mutation. |
---

## 5. Architectural Recommendation & Decision

### Verdict: REJECT Standalone `/flow handoff` File-Writer; ADOPT Read-Only Status Enrichment
* **Decision:** We **reject** creating a new standalone `/flow handoff` command or generating markdown handoff files on disk.
  - Reason 1: It creates competing normative files for facts already maintained in `cards/C-NNN.md` and `.flow/harness.db`.
  - Reason 2: Flow's canonical home `skills/flow/references/agent-stage-mapping.md` already defines the subagent return contract (`summary:`, `evidence:`, `nextSteps:`, `blocker:`, `STATUS:`) with cross-field semantics.
  - Reason 3: Flow's `context_handler.py` (ADR-0001 addendum) already provides inter-session status handoff across context compaction via a nonauthoritative, privacy-bounded runtime snapshot.
  - Reason 4: Valid boring preference for read-only `stdout` inspection over unnecessary mutable duplicate state on disk.
* **Refined Proposal (Future Wave Candidate):**
  If in-progress card handoff requires richer CLI rendering, it should be considered as an **advisory read-only flag on existing verbs** (e.g., `flow resume --card C-NNN` or `flow status --handoff`), outputting purely to `stdout` with zero disk files written.
* **Current Status:** Strict pre-implementation state. No production code or new APIs will be implemented this wave. All proposals remain strictly held pending Windows PowerShell suite completion and green CI verification.
