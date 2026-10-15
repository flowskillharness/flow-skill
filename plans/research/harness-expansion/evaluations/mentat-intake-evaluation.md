# Harness Intake Evaluation: Mentat (Terminal AI Coding Assistant)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Historical / Deprecated Candidate (Repository Archived / Maintenance Ceased; Live Trials Not Recommended)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Historical / Deprecated (Unassessed / Deferred / Historical; Inactive Terminal CLI)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - `AGENTS.md`
- **Vendor References:**
  - Mentat Official Site: https://mentat.ai (accessed 2026-10-15)
  - Mentat GitHub Repository: https://github.com/AbanteAI/mentat (Open Source Apache-2.0, Abante AI, accessed 2026-10-15)

---

## Executive Summary & Overview Table

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                             MENTAT INTAKE EVALUATION SUMMARY                           │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Historical / Deprecated (Unassessed / Deferred /        │
│                              │ Historical; Inactive Terminal CLI)                      │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized prompt context / instructions / repository │
│                              │ root `AGENTS.md` (no verified schema; no Flow template) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Developer Terminal / CLI (Python package `mentat`       │
│                              │ running on host workstation)                            │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal / shell command execution tool    │
│                              │ in Mentat loop (Flow gate-stop fidelity and             │
│                              │ return-code capture unverified in live trials)          │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ HISTORICAL / DEPRECATED CANDIDATE (Repository           │
│                              │ Archived; Maintenance Ceased; Live Trials Not           │
│                              │ Recommended)                                            │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Architectural Classification** | Historical / Deprecated (Unassessed / Deferred / Historical; Inactive Terminal CLI) |
| **Ingestion Mechanism** | Hypothesized prompt context / instructions / repository root `AGENTS.md` (no verified schema; no Flow template) |
| **Execution Environment** | Developer Terminal / CLI (Python package `mentat` running on host workstation) |
| **Tool Execution API** | Hypothesized terminal / shell command execution tool in Mentat loop (Flow gate-stop fidelity and return-code capture unverified in live trials) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `Historical / Deprecated Candidate (Repository Archived / Maintenance Ceased; Live Trials Not Recommended)` |

---

## Section 1: Executive Summary & Modality Separation

### 1.1 Executive Summary & "Support Thật" Qualification Status

> **⚠️ PROJECT STATUS DISCLOSURE (RECLASSIFICATION):** The Mentat CLI repository (https://github.com/AbanteAI/mentat) is **archived and no longer maintained or supported** (maintenance ceased; the Mentat name has since pivoted to a separate bot product). Mentat is accordingly reclassified as an **Unassessed / Deferred / Historical (Inactive Terminal CLI)** candidate — historically significant as an early terminal coding assistant, but **live host trials are NOT recommended** due to project archival. No "supported" claim of any kind is made.

Mentat (developed by Abante AI; official portal: https://mentat.ai, repository: https://github.com/AbanteAI/mentat under Apache-2.0, accessed 2026-10-15) is an archived open-source terminal AI coding assistant. It historically operated from the command line to coordinate multi-file code modifications directly in local Git repositories and execute terminal commands. Because the CLI repository is archived, these capabilities represent historical desk review artifacts.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Unassessed / Deferred / Historical (Inactive Terminal CLI)**.
- **Qualification Status:** **`Historical / Deprecated Candidate (Repository Archived / Maintenance Ceased; Live Trials Not Recommended)`**.
- **Qualification Rationale:**
  - Mentat operated in the developer terminal as an open-source command-line coding assistant. With repository archival and cessation of maintenance, active execution capabilities remain unverified historical artifacts.
  - **Distinction from Category A (Native Skill Target):** Desk review of Mentat's official documentation and open-source codebase found no documented native skill directory standard (such as the universal `~/.agents/skills/` specification or Claude Code's `~/.claude/skills/`). Mentat does not auto-discover standalone `SKILL.md` bundles from global host directories. Claiming Category A native skill discovery without empirical evidence would be an illusion trap.
  - **Strict Locking of `flow rules`:** Flow's CLI rule generator is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), strictly verified by `tests/test_flow_rules.sh`. **No Mentat template exists in `flow rules`.** Attempting `flow rules mentat` exits with status `2` (`unknown harness: mentat`).
  - In strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising "Mentat support" or claiming compatibility without empirical live host verification of subshell invocation, return-code capture ($0$ vs. non-zero), and gate-stop fidelity constitutes marketing deception ("quảng cáo ảo").
  - Prospective Flow integration must rely on hypothesized prompt context, command-line arguments, or repository root `AGENTS.md` guiding the assistant to invoke the project-local runner (`skills/flow/runner/flow.sh`).
  - Because the repository is archived and maintenance has ceased, live host trials are **not recommended**; this record is retained purely as a historical desk review artifact under Flow's qualification taxonomy.

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, Mentat's architecture was evaluated against ADR-0001's fundamental invariants (historical analysis):
1. **Zero Resident Daemons for Flow:** Flow requires no persistent daemon, background server, or long-lived socket listener on the host system. Flow's runner executes on-demand (`bash skills/flow/runner/flow.sh <verb>`) and terminates immediately.
2. **Process Token Ownership:** The developer and the Mentat CLI hold the process token and drive the execution loop. Flow never holds the main loop and executes strictly as an ephemeral subprocess invoked via command execution tools.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Mentat's Python internals, git operations, or LLM API calls. Gates are evaluated post-hoc by inspecting on-disk filesystem truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <command>` (or `flow.cmd <command>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Stateless On-Disk Storage:** All state transitions are captured in Git commits and verified filesystem files, requiring zero volatile in-memory caching. Attempting to turn Flow into a persistent service or embedding Flow into Mentat's agent loop as a background service is constitutionally forbidden under ADR-0001.

### 1.3 Architectural Classification: Why Category B and Not Category A or C?
Understanding Mentat's architectural classification requires analyzing why it belongs in Category B rather than Category A or Category C:
1. **Why Not Category A (Native Skill Target)?**
   - Category A harnesses natively scan for and discover directory-based skill bundles containing `SKILL.md` from standardized host locations (e.g., Claude Code reading `~/.claude/skills/flow`, Codex reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).
   - In desk review of official vendor documentation and codebase, no documented native directory-based skill discovery mechanism conforming to `SKILL.md` bundles (`~/.agents/skills/` or `~/.claude/skills/`) was identified for Mentat. Claiming Category A native skill discovery without empirical evidence would be an illusion trap.
2. **Historical Alignment with Category B Patterns (CLI Scaffolding):**
   - Category B harnesses rely on workspace instruction scaffolding, prompt framing, and contextual rules to guide the agent toward invoking shell tools and adhering to engineering discipline.
   - Mentat historically accepted task instructions through terminal arguments, prompt directives, configuration (`.mentat_config.json`), and repository context files. The repository root `AGENTS.md` served as the primary hypothesized instruction carrier.
   - Because Mentat's CLI repository is archived and maintenance has ceased, it is retained strictly as an **Unassessed / Deferred / Historical Candidate**, not an active Category B integration proposal.
3. **Why Not Category C (Automated Test Gate Scaffolding)?**
   - Category C harnesses (such as Aider with `test-cmd` in `.aider.conf.yml`) provide an automated, non-agentic test execution lifecycle hook that mechanically triggers on every file edit without requiring model persuasion.
   - While Mentat historically supported running commands and tests within its agent loop, it provided no automated post-edit non-agentic lifecycle hook comparable to Aider's `test-cmd` / `auto-test`.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring

- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):**
  - Mentat established an early open-source presence as a CLI-centric AI coding assistant developed by Abante AI. Designed for software engineers who prefer terminal workflows, it attracted significant initial interest on GitHub.
  - However, official project notices confirm the CLI repository is archived and maintenance has ceased. In accordance with Flow's qualification criteria, archived tools are classified as historical candidates rather than active integration targets; live host trials are not recommended.
- **Agentic Autonomy & Capability (Qualitative Autonomy Hypothesis):**
  - Mentat historically supported multi-file code editing directly across repository files and featured an agent mode designed to run terminal commands and evaluate outcomes.
  - Whether Mentat's command execution loop and subshell invocation reliably captured integer exit codes ($0$ vs. non-zero), halted on failure, and refused to hallucinate a pass was never empirically verified in Flow live trials prior to repository archival.
- **Ecosystem Openness & Stability (Qualitative Openness Hypothesis):**
  - Mentat was published as an open-source tool under the Apache-2.0 license and historically distributed via PyPI (`pip install mentat`); official notices confirm the CLI repository is archived and maintenance has ceased.
  - Configuration options are transparently managed (e.g., via `.mentat_config.json` in the git root or user configuration directories).
- **Prioritization Status & Hypothesis:** **`Historical / Deprecated Candidate (Repository Archived / Maintenance Ceased; Live Trials Not Recommended)`**.
  - **Status Classification:** `Unassessed / Deferred / Historical (Inactive Terminal CLI; Desk Intake Only)`.
  - **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
    1. *Market Adoption Hypothesis:* Historical open-source terminal assistant; project repository is archived and CLI maintenance has ceased, so live trials are not recommended.
    2. *Agentic Autonomy Hypothesis:* Historically combined multi-file editing with command execution; Flow subshell execution, integer exit-code propagation ($0$/$1$), and gate-stop fidelity were never empirically verified prior to archival.
    3. *Ecosystem Openness Hypothesis:* Open-source codebase on GitHub under Apache-2.0, but project ecosystem is inactive due to repository archival.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Terminal Execution Model & Process Token Ownership (Historical Analysis)
Mentat operated as a client-side CLI utility running locally on the developer's workstation:
1. **Host-Native Execution:** Historically installed via Python (`pip install mentat`), Mentat executed in the developer's local shell environment, reading project files into context and applying edits using Git-aware operations.
2. **Process Token Ownership:** The developer and the Mentat CLI process held the execution loop. Mentat queried LLM providers directly using configured API keys. Flow would have executed strictly as an ephemeral subprocess invoked through command execution tools, never holding the main loop.
3. **Constitutional Demarcation (ADR-0001):** Flow requires zero persistent daemons, zero resident background services, and zero memory-resident state. Ephemeral subshell calls (`bash skills/flow/runner/flow.sh <command>`) run, inspect on-disk truth, write receipts, and exit immediately.

#### 2.2.2 Context Ingestion & Workspace Instructions (Historical Analysis)
Mentat historically managed context dynamically from the project repository:
1. **Context Inclusion:** Developers specified files to include in context when launching Mentat or via in-session commands.
2. **Configuration (`.mentat_config.json`):** Project-specific settings were documentable in `.mentat_config.json` at the git root, controlling model parameters.
3. **Repository Root Instruction Carrier (`AGENTS.md`):** Mentat did not define a proprietary rule format (such as `.cursor/rules/` or `.windsurf/rules/`). The universal instruction carrier for Flow discipline was hypothesized as repository root `AGENTS.md`, but whether Mentat automatically ingested `AGENTS.md` was never empirically verified in live trials prior to archival.
4. **Absence of Flow Template:** Flow's `flow rules` CLI command does **not** generate a Mentat configuration. Attempting `flow rules mentat` will exit with code `2`. Integration relies entirely on general project instructions or manual prompt framing.

#### 2.2.3 Tool Invocation API & Shell Subsystem (Historical Analysis)
To enforce Flow gates, Mentat would have needed to execute terminal commands within the project workspace:
1. **Command Execution in Agent Loop:** Mentat documentation historically described the ability to execute terminal commands (such as running test suites or shell scripts) within its loop.
2. **Exit Code Propagation Hypothesis:** In hypothetical integration, Mentat would have needed to capture both standard output streams and the exact integer return code ($0$ for pass, $1$ for failure). Non-zero exit codes would need to feed back into model context as build failures.
3. **Gate-Stop Fidelity Hypothesis:** Whether Mentat's command execution loop and subshell invocation reliably captured integer exit codes ($0$ vs. non-zero), halted on failure, and refused to hallucinate a pass was never empirically verified in Flow live trials prior to repository archival.

#### 2.2.4 Isolation Boundaries & Project-Local Runner Setup
1. **Local Workstation Scope:** Mentat executed directly on the host operating system without container isolation by default.
2. **Project-Local Runner Requirement:** Because no documented mechanism for discovering host-global skill bundles (`~/.agents/skills/flow` or `~/.claude/skills/flow`) was identified in desk review, hypothetical integration would have required the Flow runner tree to be present in the project workspace at `skills/flow/runner/flow.sh`.
3. **Invocation Path (Non-Operational Historical Recipe):** Scaffolding would have directed Mentat to invoke the workspace-relative runner (`bash skills/flow/runner/flow.sh <command>`). Because the repository is archived, this recipe is non-operational and preserved strictly as a historical desk note.
4. **Project Scope Reservation Notice:** Project-level installation (`--project` in npm installer or `install.sh project`) is **strictly reserved for Claude Code** (`.claude/skills/flow`). In `constants.mjs`, `projectScopeAllowed: false` is enforced for all other targets. Running `--project` against non-Claude targets is explicitly rejected by the installer and must never be promised or documented for Mentat.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion (Conversational Planning vs. Mechanical Gate Checks)
- **The Failure Mode:**
  - An operator or LLM assumes that because Mentat coordinated multi-file edits across the repository and produced an articulate summary of completed work, the Flow lifecycle stage has passed.
  - This is an **illusion trap**. In Flow's constitutional model, conversational narratives, multi-file code proposals, and chat explanations have zero evidentiary value.
  - Stage advancement requires authenticated on-disk files (`flow/00-idea.md`, `cards/C-NNN.md`), validated checksums in `manifest-hashes.json`, and an authentic exit code `0` from `flow.sh next` or `flow.sh check`.
- **The Anti-Illusion Mitigation:**
  - Instructions in `AGENTS.md` would have needed to explicitly stipulate that coordinating edits in Mentat does not satisfy Flow gates.
  - Because Mentat is an archived project, live qualification Gate 3 was not executed.

### 3.2 Latent Trap 2: Absence of Dedicated `flow rules` Template
- **The Failure Mode:**
  - A developer assumes that Flow includes a built-in generator for Mentat and attempts:
    ```bash
    bash skills/flow/runner/flow.sh rules mentat --write
    ```
  - Flow's `flow rules` command is strictly locked to **seven supported harnesses** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), as verified by `tests/test_flow_rules.sh`:
    ```text
    unknown harness: mentat
    usage: flow rules [list|cursor|windsurf|roo|cline|aider|openhands|copilot] [--write]
    exit: 2
    ```
  - An automated script assuming a Mentat rule template will crash with exit code `2`.
- **The Anti-Illusion Mitigation:**
  - Flow documentation must explicitly declare that Mentat has **no dedicated `flow rules` generator**.
  - Instruction scaffolding for Mentat must be provided via the repository root `AGENTS.md` and standard prompt context.

### 3.3 Latent Trap 3: Strict Prohibition of Flow Background Daemons (ADR-0001)
- **The Failure Mode:**
  - To streamline repeated gate checks in an interactive CLI session, an integrator might propose running Flow as a long-lived background service, resident daemon, or daemonized socket listener.
  - Introducing a resident Flow daemon directly violates Flow's core constitutional anchor (ADR-0001). Daemons introduce persistent in-memory caching, stale state desynchronization, process orphan leaks, and hidden lifecycle dependencies.
- **The Anti-Illusion Mitigation:**
  - Under ADR-0001, **Flow must never hold the process token and must never run a resident daemon**.
  - Flow executes strictly per command as an ephemeral subprocess (`flow.sh status`, `flow.sh check`, `flow.sh next`) and terminates immediately upon returning an integer exit code.
  - Mentat runs as an interactive Python CLI; Flow remains strictly an ephemeral child process.

### 3.4 Latent Trap 4: Project-Local Runner Requirement (`skills/flow/runner/flow.sh`)
- **The Failure Mode:**
  - Users familiar with Category A harnesses (such as Claude Code or Codex) expect the agent to automatically resolve global commands installed under `~/.claude/skills/flow` or `~/.agents/skills/flow`.
  - Mentat does not inspect host global skill directories. If instructions tell Mentat to run `flow status` or refer to global paths, the terminal subshell will fail with:
    ```text
    bash: flow: command not found (exit code 127)
    ```
  - Furthermore, running `npx @manhquy/flow-skill -t mentat --project` is invalid because Flow's installer (`constants.mjs`) restricts `--project` strictly to Claude Code (`projectScopeAllowed: false` for all other targets).
- **The Anti-Illusion Mitigation:**
  - All hypothetical Mentat instruction scaffolding would have referenced the project-local runner path (`bash skills/flow/runner/flow.sh <command>`), but no active integration recipe is supported for the archived tool.

---

## Section 4: Four-Point Live Verification Protocol — Historical Archive (DO NOT RUN)

> **⛔ NON-EXECUTABLE HISTORICAL ARTIFACT (DO NOT RUN):**
> The Mentat CLI repository (`https://github.com/AbanteAI/mentat`) was archived by its maintainers with development and CLI maintenance permanently ceased. Under Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), live host trials are **NOT AUTHORIZED OR RECOMMENDED** for archived software. 
> 
> No feasibility probes, credential setups, or interactive sessions should be executed. This section is preserved strictly as a non-executable historical specification outlining what a Four-Point Live Verification trial would have required prior to project archival.

### 4.1 Historical Protocol Specification (Not Executed)
- **Evaluation Status:** `NOT EXECUTED: REPOSITORY ARCHIVED / MAINTENANCE CEASED`
- **Arm A (Baseline Discovery):** Not executed.
- **Arm B (Candidate Instruction Scaffolding):** Not executed.
- **Gate 1 (Ingestion Audit):** `[NOT EXECUTED: REPOSITORY ARCHIVED]`
- **Gate 2 (Invocation Audit):** `[NOT EXECUTED: REPOSITORY ARCHIVED]`
- **Gate 3 (Gate-Stop Audit):** `[NOT EXECUTED: REPOSITORY ARCHIVED]`
- **Gate 4 (State Persistence Audit):** `[NOT EXECUTED: REPOSITORY ARCHIVED]`

### 4.2 Status Statement
Because the Mentat CLI repository is archived and maintenance has ceased, live host trials are **NOT RECOMMENDED OR AUTHORIZED**; live qualification and matrix promotion are **NOT APPLICABLE**. Mentat remains permanently cataloged as an **Unassessed / Deferred / Historical Candidate (Archived Open-Source CLI)** under Tier 3.
