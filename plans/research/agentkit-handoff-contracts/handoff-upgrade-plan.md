# Architectural Evaluation & Proposal: Flow Handoff & Continuation Boundaries

**Plan File Path:** `plans/research/agentkit-handoff-contracts/handoff-upgrade-plan.md`  
**Date:** 2026-10-13  
**Status:** Architecture Proposal & Challenge Decision (UNAPPROVED / PRE-IMPLEMENTATION)  
**Author:** Source Forensics & Handoff Upgrade Workstream  

---

## 1. Executive Summary & Challenge Decision

Following deep forensic analysis of AgentKit's `ak:handoff` and detailed comparison against Flow's existing codebase, this proposal formally evaluates whether Flow requires a new continuation command or whether existing primitives already satisfy the operational requirement.

### 1.1 The Challenge Finding
* **One Home Per Fact (AGENTS.md line 16) & Mutable State Boundaries:**
  - In Flow, cards (`cards/C-NNN.md`) are the atomic units of execution, storing the goal, allowed files, verify command, and evidence. The durable relational database (`.flow/harness.db`) stores decisions, traces, and friction.
  - Generating persistent markdown handoff documents (e.g., under `plans/handoffs/`) represents **normative source duplication**, creating a competing source of truth for in-progress work that inevitably drifts from authoritative cards and harness tables.
  - *Distinction:* Nonauthoritative runtime caches/receipts (such as `<project>/.flow/context-handoff/snapshot.json` under the ADR-0001 addendum or attestation receipts) do *not* violate one-home per se because they are transient, project-bound, privacy-restricted (0700 dir, 0600 file), and recomputed fresh upon session start rather than serving as normative truth.
  - *Glob Safety & Stdout Preference:* There is no evidence that files under `plans/handoffs/` break `cards/C-*.md` globs (which target `cards/`). Rather, the architectural basis for rejecting file-based handoffs is the **valid boring preference for read-only stdout over unnecessary mutable duplicate state** on disk, avoiding filesystem churn and credential serialization risks.
* **Existing Flow Coverage:**
  - `flow resume` and `flow resume --budget` reconstruct session state while strictly avoiding raw argument dumps that could leak credentials.
  - `skills/flow/adapter-hooks/context_handler.py` captures and injects `flow status` snapshots across context compaction (ADR-0001 addendum).
  - Canonical Home: `skills/flow/references/agent-stage-mapping.md` (§Scoped prompt template, lines 72-121) already defines the authoritative subagent brief and return contract (`summary:`, `evidence:`, `nextSteps:`, `blocker:`, `STATUS:`) with cross-field semantics (`DONE` requires evidence; `BLOCKED`/`NEEDS_CONTEXT` require blocker; missing `STATUS` treated as `BLOCKED`). Per `AGENTS.md`, full rules remain in that canonical home.
* **Verdict:** **REJECT standalone `/flow handoff` file-generator.**
  Do not introduce file-writing handoff commands. Any future continuation enrichment must extend existing read-only inspection verbs (`flow resume` or `flow status`) streaming purely to `stdout`.
---

## 2. Refined Extension Specification (Future Wave Candidate)

If richer card-level continuation is authorized in a future wave:
* **Syntax:** `flow resume --card <C-NNN>` (streaming to `stdout` only; zero disk files written).
* **Behavior:**
  - Reads specified card from `cards/C-NNN.md` (validating status: `todo` or `in_progress`).
  - Queries `flow_harness.py` for decisions linked to the card.
  - Prints bounded git status (`git status --short`). Raw diffs are strictly omitted to prevent credential leaks.
  - Cites only verified cryptographic attestation receipts; never infers gate passage from unstructured text.
  - Displays advisory `NEXT_VERB` and first recommended action (display-only; zero autonomous execution).

---

## 3. Scope Scenarios & Boundary Handling

| Scenario | Behavior & Guarantee |
|---|---|
| **Multiple in-flight cards** | Explicit card ID required (`--card C-NNN`); if omitted, falls back to standard stage-level resume without guessing. |
| **Missing card ID** | Exits with error code 1; reports missing card path. |
| **Card already `done`** | Points user to `/flow recall` (prior done cards belong to memory, not active resume). |
| **Stage boundary (planning)** | Shows current gate checklist and missing FILL items; no card fields rendered. |
| **Durable harness disabled** | Degrades gracefully; omits decision/trace section and outputs gate/git state. |
| **Non-Git workspace** | Labels git section `Not captured in this session`; does not crash. |

---

## 4. Current Workstream Status
* **Implementation Boundary:** Pre-implementation proposal only. Zero production files edited, zero new APIs introduced.
* **Release Gate Status:** Release candidate `005e659` remains strictly held pending Windows PowerShell suite completion and green CI verification.
