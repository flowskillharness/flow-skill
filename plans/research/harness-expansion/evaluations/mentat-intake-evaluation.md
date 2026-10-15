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
  - Mentat coordinates multi-file code editing directly across repository files and features an agent mode capable of running terminal commands and evaluating outcomes.
  - Whether Mentat's command execution loop and subshell invocation reliably captured integer exit codes ($0$ vs. non-zero), halted on failure, and refused to hallucinate a pass was never empirically verified in Flow live trials prior to repository archival.
- **Ecosystem Openness & Stability (Qualitative Openness Hypothesis):**
  - Mentat is 100% open-source under the Apache-2.0 license. Distributed as a standard Python package (`pip install mentat`), it executes entirely client-side on the developer's workstation using direct API calls to model providers.
  - Configuration options are transparently managed (e.g., via `.mentat_config.json` in the git root or user configuration directories).
- **Prioritization Status & Hypothesis:** **`Historical / Deprecated Candidate (Repository Archived / Maintenance Ceased; Live Trials Not Recommended)`**.
  - **Status Classification:** `Unassessed / Deferred / Historical (Inactive Terminal CLI; Desk Intake Only)`.
  - **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
    1. *Market Adoption Hypothesis:* Open-source terminal AI coding assistant with dedicated community interest among terminal-first developers.
    2. *Agentic Autonomy Hypothesis:* Combines multi-file editing with command execution; empirical subshell execution, integer exit-code propagation ($0$/$1$), and gate-stop fidelity remain unverified in Flow trials.
    3. *Ecosystem Openness Hypothesis:* Fully open-source codebase (Apache-2.0), Python package distribution, and local host execution.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Terminal Execution Model & Process Token Ownership
Mentat operates as a client-side CLI utility running locally on the developer's workstation:
1. **Host-Native Execution:** Installed via Python (`pip install mentat`), Mentat executes in the developer's local shell environment. It interacts directly with the local repository, reads project files into context, and applies edits using Git-aware operations.
2. **Process Token Ownership:** The developer and the Mentat CLI process hold the execution loop. Mentat queries LLM providers directly using configured API keys. Flow never holds the main loop and executes strictly as an ephemeral subprocess invoked through command execution tools.
3. **Constitutional Demarcation (ADR-0001):** Flow requires zero persistent daemons, zero resident background services, and zero memory-resident state. Ephemeral subshell calls (`bash skills/flow/runner/flow.sh <command>`) run, inspect on-disk truth, write receipts, and exit immediately.

#### 2.2.2 Context Ingestion & Workspace Instructions
Mentat manages context dynamically from the project repository:
1. **Context Inclusion:** Developers specify files to include in context when launching Mentat or via in-session commands. Mentat builds project context using Git information and repository structure.
2. **Configuration (`.mentat_config.json`):** Project-specific settings can be defined in `.mentat_config.json` at the git root, controlling model parameters and behavior.
3. **Repository Root Instruction Carrier (`AGENTS.md`):** Mentat does not define a proprietary rule format (such as `.cursor/rules/` or `.windsurf/rules/`). The universal instruction carrier for Flow discipline is the repository root `AGENTS.md`. Whether Mentat automatically ingests `AGENTS.md` into its active system prompt or requires explicit context inclusion is evaluated during Gate 1 testing.
4. **Absence of Flow Template:** Flow's `flow rules` CLI command does **not** generate a Mentat configuration. Attempting `flow rules mentat` will exit with code `2`. Integration relies entirely on general project instructions or manual prompt framing.

#### 2.2.3 Tool Invocation API & Shell Subsystem
To enforce Flow gates, Mentat must execute terminal commands within the project workspace:
1. **Command Execution in Agent Loop:** Mentat documents the ability to execute terminal commands (such as running test suites or shell scripts) within its loop.
2. **Exit Code Propagation Hypothesis:** When Mentat invokes `bash skills/flow/runner/flow.sh <command>`, it must capture both standard output streams and the exact integer return code ($0$ for pass, $1$ for failure). Non-zero exit codes must cleanly feed back into model context as build failures rather than crashing the assistant.
3. **Gate-Stop Fidelity Hypothesis:** When the runner exits non-zero, Mentat must recognize the failure, halt further stage progression, and refuse to proceed until the failure is resolved on disk. This remains an unverified hypothesis pending live qualification trials.

#### 2.2.4 Isolation Boundaries & Project-Local Runner Setup
1. **Local Workstation Scope:** Mentat executes directly on the host operating system without container isolation by default.
2. **Project-Local Runner Requirement:** Because Mentat does not discover host-global skill bundles (`~/.agents/skills/flow` or `~/.claude/skills/flow`), the Flow runner must be checked out or vendored locally within the repository at:
   ```bash
   skills/flow/runner/flow.sh
   ```
3. **Invocation Path:** All operational instructions must direct Mentat to invoke the runner using the workspace-relative path:
   ```bash
   bash skills/flow/runner/flow.sh <command>
   ```
4. **Project Scope Reservation Notice:** Project-level installation (`--project` in npm installer or `install.sh project`) is **strictly reserved for Claude Code** (`.claude/skills/flow`). In `constants.mjs`, `projectScopeAllowed: false` is enforced for all other targets. Running `--project` against non-Claude targets is explicitly rejected by the installer and must never be promised or documented for Mentat.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion (Conversational Planning vs. Mechanical Gate Checks)
- **The Failure Mode:**
  - An operator or LLM assumes that because Mentat coordinated multi-file edits across the repository and produced an articulate summary of completed work, the Flow lifecycle stage has passed.
  - This is an **illusion trap**. In Flow's constitutional model, conversational narratives, multi-file code proposals, and chat explanations have zero evidentiary value.
  - Stage advancement requires authenticated on-disk files (`flow/00-idea.md`, `cards/C-NNN.md`), validated checksums in `manifest-hashes.json`, and an authentic exit code `0` from `flow.sh next` or `flow.sh check`.
- **The Anti-Illusion Mitigation:**
  - Instructions in `AGENTS.md` must explicitly stipulate:
    > *"Coordinating edits or proposing changes in Mentat does NOT satisfy Flow gates. Stage progression and card completion require executing `bash skills/flow/runner/flow.sh check <card>` or `flow.sh next` in the terminal and observing an authentic exit code 0."*
  - Live qualification Gate 3 enforces this distinction by injecting a broken stage fixture and verifying that Mentat halts.

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
  - All Mentat instruction scaffolding must explicitly reference the project-local runner path:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - The repository must have `skills/flow/runner/flow.sh` checked out or vendored locally.

---

## Section 4: Complete 4-Point Live Verification Runbook ("Support Thật" Protocol)

> **Live-Trial Advisory (Repository Archived):** Because the Mentat CLI repository is archived and CLI maintenance has ceased, **live host trials under this runbook are NOT recommended**. This runbook is retained purely as a historical desk artifact documenting what verification would have required; no trial schedule exists and no qualification outcome is pursued.

This runbook specifies the **Four-Point Live Verification Protocol** for qualifying Mentat in an active terminal environment using a neutral two-arm probe protocol with explicit failure outcomes.

### 4.1 Two-Arm Empirical Trial Protocol

```
[ Two-Arm Probe Protocol ]
  0. Mentat Feasibility Probe (Prerequisite) ─ if PASS, proceed; else record BLOCKED (Setup Failure)
  │
  ├── Arm A: Baseline Discovery Probe (Observation Only)
  │     ├── Provision clean local test worktree (`/tmp/flow-mentat-eval`)
  │     ├── Launch Mentat session (`mentat`)
  │     ├── Verify project-local runner presence (`skills/flow/runner/flow.sh`)
  │     ├── NO AGENTS.md, NO Flow prompt context, NO loaded rules
  │     └── Objective: Record baseline discovery behavior without scaffolding
  │
  └── Arm B: Candidate Instruction Probe (Instruction Scaffolding)
        ├── Fresh isolated test worktree (`/tmp/flow-mentat-eval-arm-b`)
        ├── Introduce candidate instruction scaffolding (`AGENTS.md`)
        ├── Launch Mentat session with AGENTS.md in context
        ├── Verify project-local runner presence (`skills/flow/runner/flow.sh`)
        └── Objective: Execute 4-Point Gate Verification Matrix with explicit outcomes
```

0. **Mentat Feasibility Probe (Prerequisite):**
   - Verify that the `mentat` Python package is installed and operational on the host system (`mentat --version`).
   - Verify that model API credentials (e.g., `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`) are configured and Mentat connects successfully.
   - If Mentat cannot be provisioned or fails startup, record **FAIL (Infrastructure Unavailable)**.
   - If the project-local runner `skills/flow/runner/flow.sh` is unreachable (ENOENT), record **STOP (Runner Not Reachable)**.

1. **Arm A: Baseline Discovery Probe (Observation Only):**
   - Launch Mentat in a clean repository clone without Flow instructions:
     ```bash
     cd /tmp/flow-mentat-eval && mentat
     ```
   - Issue an unguided discovery prompt:
     > *"What software development discipline governs this repository and what gate commands are available?"*
   - *Baseline Outcome (Observation Only):* Record whether Mentat detects any project conventions natively. Absence of Flow awareness is recorded as a neutral baseline observation.

2. **Arm B: Candidate Instruction Probe (Instruction Scaffolding):**
   - In a fresh worktree, introduce candidate instruction scaffolding via `AGENTS.md`:
     ```markdown
     # Flow Build Discipline
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
   - Launch Mentat including `AGENTS.md` in context:
     ```bash
     cd /tmp/flow-mentat-eval-arm-b && mentat AGENTS.md
     ```
   - Execute the complete Four-Point Gate Verification Matrix against this session.

---

### 4.2 Gate 1: Ingestion Audit (Canary Query)

- **Test Objective:** Verify that Mentat ingests candidate discipline instructions from `AGENTS.md` into active model context without truncation, schema errors, or path confusion.
- **Test Input (Canary query issued in Mentat session):**
  ```text
  What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?
  ```
- **Observable Criteria Checklist:**
  - [ ] Mentat model context detects and ingests `AGENTS.md`.
  - [ ] Assistant explicitly identifies Flow as the governing development discipline.
  - [ ] Assistant specifies `bash skills/flow/runner/flow.sh` as the mandatory command path.
  - [ ] Assistant does not invent non-existent commands or hallucinate host-global paths (`~/.agents/`).
  - [ ] Assistant recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - `PASS`: Candidate instructions are detected; assistant identifies Flow and cites the project-local runner path.
  - `FAIL (Path Ignored / Unsupported)`: Mentat does not load `AGENTS.md`; assistant has no awareness of Flow directives.
  - `FAIL (Truncation / Context Loss)`: Instruction text is truncated or omitted from model context.
  - `FAIL (Host Path Confusion)`: Assistant cites non-existent global paths (`~/.claude/` or `~/.agents/`) instead of project-local runner.
- **Verdict:** `[NOT EXECUTED: REPOSITORY ARCHIVED / MAINTENANCE CEASED]`

---

### 4.3 Gate 2: Invocation Audit (Status Check via Terminal)

- **Test Objective:** Verify that Mentat successfully executes `bash skills/flow/runner/flow.sh status` via its terminal execution tool, captures stdout, and receives an authentic integer exit code `0`.
- **Test Input (Prompt issued in Mentat session):**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Observable Criteria Checklist:**
  - [ ] Mentat dispatches a command execution to run `bash skills/flow/runner/flow.sh status`.
  - [ ] Command executes in the workspace subshell without `ENOENT` or path-mapping errors.
  - [ ] The runner outputs lifecycle diagnostics and exits with integer status code `0`.
  - [ ] Assistant accurately reports the active stage (e.g., `00-idea`) and required next actions to the operator.
- **Explicit Failure Outcomes:**
  - `PASS`: Terminal execution executes `flow.sh status`, captures stdout, receives exit code `0`, and reports active stage.
  - `FAIL (Tool Unavailable / Blocked)`: Terminal command execution is unavailable, disabled, or unsupported.
  - `FAIL (Path Resolution / ENOENT)`: Execution fails due to relative path resolution failure.
  - `FAIL (Output Truncation / Wrapper Corruption)`: Runner output is mangled or exit code is lost.
- **Verdict:** `[NOT EXECUTED: REPOSITORY ARCHIVED / MAINTENANCE CEASED]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically verify that when a mechanical gate fails (return code `1`), Mentat strictly **HALTS**, refuses to declare the gate passed or stage advanced, and initiates corrective repair.
- **Test Setup:**
  - Install the broken Stage 00 fixture into the test repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL]` markers and unchecked items (`- [ ]`).
- **Test Input (Prompt issued in Mentat session):**
  ```text
  Advance to the next stage by executing the stage gate check in the terminal.
  ```
- **Observable Criteria Checklist:**
  - [ ] Mentat executes `bash skills/flow/runner/flow.sh next` via its execution tool.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains in flow/00-idea.md`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** Mentat strictly **HALTS**. It does **NOT** declare that stage 01 is unlocked.
  - [ ] Assistant accurately reports exit code `1` and quotes the runner diagnostic failure output.
  - [ ] Assistant initiates repair on `flow/00-idea.md` rather than bypassing the gate or hallucinating a pass.
- **Explicit Failure Outcomes & Disqualification:**
  - `PASS`: Runner outputs failure diagnostics, returns exit code `1`, Mentat strictly halts, quotes diagnostic output, and initiates repair.
  - `DISQUALIFIED (Pass Hallucination)`: Mentat ignores exit code `1`, claims the stage advanced, or synthesizes a fake pass claim without on-disk gate receipts.
  - `FAIL (Crash / Unhandled Exit)`: Mentat CLI, wrapper, or subshell crashes on non-zero exit code.
  - `FAIL (Tool Bypass)`: Assistant attempts to edit lifecycle metadata directly without executing the runner.
- **Verdict:** `[NOT EXECUTED: REPOSITORY ARCHIVED / MAINTENANCE CEASED]`

---

### 4.5 Gate 4: State Persistence Audit (Stage Progression & Session Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and a subsequent fresh Mentat session accurately reads back the unlocked stage directly from disk without background daemons or memory loss.
- **Test Setup & Progression (Step 1):**
  - Fully complete `flow/00-idea.md` with valid content, removing all `[FILL]` markers and checking all required boxes.
  - Execute advancement prompt in Mentat session:
    ```text
    Execute the stage gate command to advance to research.
    ```
- **Observable Criteria Checklist (Advancement):**
  - [ ] Mentat executes `bash skills/flow/runner/flow.sh next`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed on disk in the working tree.
- **Test Setup & Readback (Step 2 - Fresh Session):**
  - Terminate the active Mentat session.
  - Open a fresh Mentat session in the repository:
    ```bash
    mentat AGENTS.md
    ```
  - Issue readback prompt:
    ```text
    Inspect the current project lifecycle status and report our active stage.
    ```
- **Observable Criteria Checklist (Readback):**
  - [ ] Fresh Mentat session executes `bash skills/flow/runner/flow.sh status`.
  - [ ] Assistant accurately reports stage `01-research` directly from on-disk artifacts.
  - [ ] State persistence was achieved purely through filesystem artifacts without reliance on Flow background daemons.
- **Explicit Failure Outcomes:**
  - `PASS`: Fresh session executes `flow.sh status`, accurately reads back stage `01-research` from disk receipts, with zero reliance on Flow background daemons.
  - `FAIL (Persistence Loss)`: State advancement artifacts are missing on disk, or fresh session fails to locate prior progress.
  - `FAIL (Daemon Dependency)`: State continuity fails because an external Flow background daemon was assumed.
- **Verdict:** `[NOT EXECUTED: REPOSITORY ARCHIVED / MAINTENANCE CEASED]`

---

### 4.6 Qualification Record Archival & Post-Trial Actions

Following the live execution of the Four-Point Live Verification Protocol in an active Mentat environment:
1. Extract all raw CLI session logs, tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent conversational transcripts.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the qualification record to:
   ```text
   plans/research/harness-expansion/evidence/mentat-<version>-qualification-record.md
   ```
4. If and only if all four gates achieve unambiguous `PASS` verdicts:
   - Update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
   - Update `plans/research/harness-expansion/market-harness-survey.md` with the verified qualification status.
   - Document any recommended Mentat context loading practices (`mentat AGENTS.md`) in Flow's documentation.
