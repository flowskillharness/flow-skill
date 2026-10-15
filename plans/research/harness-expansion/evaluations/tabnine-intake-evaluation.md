# Harness Intake Evaluation: Tabnine (Chat & Workspace Agent)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Workspace Instruction Scaffolding for Tabnine Chat) & Unassessed / Deferred (Tabnine Inline Completions)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor References:**
    - Tabnine Official Portal: https://www.tabnine.com (Tabnine Inc., accessed 2026-10-15)
    - Tabnine Documentation: https://docs.tabnine.com (Tabnine Inc., accessed 2026-10-15)

---

## Section 1: Executive Summary & Modality Separation (Proposed Workspace Agent vs. Inline Completions)

### 1.1 Executive Summary & "Support Thật" Qualification Status
Tabnine (developed by Tabnine Inc.; vendor portal: https://www.tabnine.com, documentation: https://docs.tabnine.com, accessed 2026-10-15) is an established AI-assisted software engineering platform providing inline code completions, chat assistance, workspace-aware context retrieval, and agentic workflows across major developer IDEs (Visual Studio Code, JetBrains IDEs, Eclipse).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Proposed Workspace Instruction Scaffolding for Tabnine Chat) & Unassessed / Deferred (Tabnine Inline Completions)**.
- **Qualification Status:** **`PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)`**.
- **Qualification Rationale:**
  - Tabnine exhibits a strict operational separation between two primary modalities:
    1. **Tabnine Chat & Workspace Agent:** An interactive sidebar agent and workspace-aware assistant capable of answering questions, proposing file edits, and interacting with developer workflows within IDEs (VS Code, JetBrains, Eclipse). In desk review, this modality is evaluated as an unverified **Category B (Proposed Workspace Instruction Scaffolding)** candidate hypothesis.
    2. **Tabnine Inline Completions:** Real-time ghost-text completions served as the developer authors code. As an inline code-completion modality, this is outside Flow's build-gate integration scope; broader tool execution capabilities remain unassessed pending dedicated verification. Classified as **Unassessed / Deferred**.
  - In strict adherence to Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising general "Tabnine support" without distinguishing Tabnine Chat/Workspace Agent from inline completions is marketing deception ("quảng cáo ảo").
  - Tabnine does not implement directory-based skill discovery (Category A) conforming to the universal Agent Skills standard (`~/.agents/skills/`) or `~/.claude/skills/`. Prospective Flow integration is proposed via workspace context, prompt rules, or repository root `AGENTS.md` paired with a project-local runner (`skills/flow/runner/flow.sh`).
  - Flow's `flow rules` dispatcher currently implements **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). Tabnine is not an active target in `flow rules`; all Tabnine workspace scaffolding remains a **proposed design candidate** pending live empirical qualification.
  - Complete verification requires live interactive host trials under the Four-Point Live Verification Protocol with raw execution transcripts, tool payloads, integer exit codes, and on-disk receipts committed to `plans/research/harness-expansion/evidence/`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                          TABNINE EVALUATION SUMMARY                                    │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Proposed Workspace Instruction Scaffolding   │
│                              │ for Tabnine Chat) & Unassessed / Deferred (Tabnine      │
│                              │ Inline Completions)                                     │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized workspace context / prompt rules / root    │
│                              │ `AGENTS.md` (no verified schema; no Flow template)      │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Developer IDE Extension (VS Code, JetBrains IDEs,       │
│                              │ Eclipse)                                                │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal / shell execution tool            │
│                              │ (unverified in Flow trials)                             │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)     │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with Tabnine Chat aligns with ADR-0001's fundamental invariants:
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation. Tabnine extensions frequently utilize internal helper processes or local model serving binaries, but Flow must never execute as or depend on a resident daemon. Flow executes strictly as an ephemeral subprocess invoked via `skills/flow/runner/flow.sh` (or `flow.cmd`).
2. **Process Token Ownership:** The IDE extension host and Tabnine agent manage the conversational loop and hold the process token. Flow never holds the event loop and executes strictly as an ephemeral subshell command, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not wrap, proxy, intercept, or monkey-patch Tabnine's model communications, IDE language client bindings, or proprietary backend APIs. Flow evaluates gates post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostic output.
5. **Rejection of Resident Model Server Wrappers:** Attempting to wrap Flow inside a resident background server or in-memory service is constitutionally prohibited under ADR-0001. Flow's state lives strictly on disk in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Classification: Category B (Proposed Tabnine Chat) vs. Unassessed / Deferred (Inline Completions)
Tabnine spans two fundamentally divergent operational modalities that must be strictly separated under Flow's harness taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                           TABNINE MODALITY SEPARATION                                  │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: Tabnine Chat / Workspace     │ Modality 2: Tabnine Inline Completions      │
│ (Category B: Proposed Workspace Scaffold)│ (Unassessed / Deferred; No Tool Execution)  │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: VS Code, JetBrains, Eclipse │ Environment: IDE Editor Text Buffer         │
│ Ingestion: Workspace context, prompt     │ Ingestion: Real-time typing prefix / suffix │
│ rules, root `AGENTS.md` (unverified)     │ (No instruction or discipline schema)       │
│ Agent Loop: Multi-turn conversational    │ Agent Loop: Single-token/line prediction    │
│ chat and code generation guidance        │ without conversation or multi-turn state    │
│ Tool API: Hypothesized terminal / shell  │ Tool API: None (Editor buffer injection     │
│ execution tool (unverified in Flow)      │ only; no execution capability)              │
│ Status: Proposed Design Candidate        │ Status: Unassessed / Deferred               │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: Tabnine Chat & Workspace Agent (Category B: Proposed Workspace Instruction Scaffolding)
- **Environment:** Developer IDEs (VS Code, JetBrains suite including IntelliJ, PyCharm, WebStorm, and Eclipse) running the Tabnine plugin.
- **Rule Ingestion:** Hypothesized via workspace prompt rules, repository context files, or root `AGENTS.md` (no pinned schema or verified Flow template).
- **Tool Execution:** Hypothesized terminal / shell execution tool for running build and verification commands (unverified in Flow trials).
- **Classification:** Category B (Proposed Workspace Instruction Scaffolding for Tabnine Chat).

#### Modality 2: Tabnine Inline Completions (Unassessed / Deferred)
- **Environment:** IDE code editor buffer.
- **Operational Scope:** Real-time ghost-text completions synthesized from local/cloud language models as code is authored.
- **Integration Scope:** Code-completion modality outside Flow's build-gate integration scope; broader tool execution capabilities remain unassessed pending dedicated verification.
- **Classification:** Unassessed / Deferred (Tabnine Inline Completions).

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring
- **Market Share & Developer Adoption (Enterprise & Community):** Tabnine is a long-standing pioneer in AI-assisted code completion, predating modern LLM chat assistants. It maintains an extensive installed base across global enterprise organizations, particularly enterprises with strict security and data governance requirements that mandate on-premise, air-gapped, or Virtual Private Cloud (VPC) deployments. Tabnine plugins maintain an established presence across VS Code, JetBrains Marketplace, and Eclipse as reported in vendor documentation and IDE marketplace listings (accessed 2026-10-15).
- **Agentic Autonomy & Capability (Interactive Guidance vs. Autonomous Loop):** Tabnine Chat provides conversational guidance, codebase context indexing, and code refactoring suggestions. However, its autonomous multi-turn shell execution and exit code handling remain unassessed in Flow trials. In standard IDE workflows, Tabnine Chat primarily suggests shell commands or code diffs for user review and approval rather than autonomously driving an unconstrained tool-execution loop.
- **Ecosystem Openness & Stability:** Tabnine is built on proprietary extension clients, proprietary model orchestration, and proprietary cloud/VPC backend infrastructure. Configuration formats for workspace-level rule ingestion remain unpinned and lack an open, standardized specification comparable to the universal Agent Skills standard.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
  1. **Market Adoption Hypothesis:** Long-standing pioneer in AI code completion with widespread enterprise on-premise and VPC deployments.
  2. **Agentic Autonomy Hypothesis:** Tabnine Chat provides conversational guidance and code edits; autonomous multi-turn shell execution and exit code handling remain unassessed in Flow trials.
  3. **Ecosystem Openness Hypothesis:** Proprietary extension and model hosting (cloud or self-hosted VPC); instruction ingestion unpinned.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Tabnine Chat & Workspace Execution Model (Hypothesized)
In desk review of vendor documentation, Tabnine Chat operates inside the IDE extension host:
1. **Context Engine:** Indexes local repository files, recently viewed tabs, git history, and semantic embeddings to augment chat prompts.
2. **Model Serving Boundary:** Queries either Tabnine Cloud or a customer-hosted Tabnine Enterprise VPC / on-premise server.
3. **Execution Subshell Tool (Hypothesized):** In desk review, Tabnine Chat is hypothesized to interact with the IDE terminal or an execution subshell tool to run commands proposed during chat sessions (unverified in Flow trials).
4. **Exit Code Evaluation (Hypothesized):** Whether Tabnine's agent loop receives exact integer exit codes and can autonomously react to non-zero returns ($exit \neq 0$) remains an unverified hypothesis pending live host trials under the Four-Point Live Verification Protocol.

#### 2.2.2 Rule & Instruction Ingestion Mechanism
- **Workspace Context:** Tabnine supports repository context awareness, but lacks a publicly documented, formal rules schema like `.cursor/rules/*.mdc` or `.roomodes`.
- **Root `AGENTS.md` Fallback:** In modern multi-agent development, generic root instruction files (`AGENTS.md`) serve as the universal fallback for workspace context. Whether Tabnine Chat automatically parses and prioritizes root `AGENTS.md` requires live empirical validation.
- **No Dedicated Flow Template:** Flow's `flow rules` CLI command is strictly locked to seven verified templates (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). No Tabnine template exists.

#### 2.2.3 Execution Invariants: Zero Resident Daemons & Ephemeral Invocations
- Under ADR-0001, Flow must never be deployed as a resident daemon, persistent service, or background listener.
- While Tabnine extensions may spin up local background processes for model caching or LSP communication, Flow executes strictly as an ephemeral subshell executable via `bash skills/flow/runner/flow.sh <verb>`, returning an exit code ($0$ or $1$) and terminating immediately.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion (Tabnine Chat vs. Inline Completions)
- **The Pitfall:** Claiming general "Tabnine support" without distinguishing between conversational/workspace assistance and inline ghost-text completions. A developer expecting Flow build discipline during inline code completion discovers that inline completions have no execution loop, cannot run commands, and cannot enforce gates.
- **The Grounded Technical Reality:** Tabnine Inline Completions are text-prediction models embedded in the editor buffer. Inline completions operate as passive text completions outside Flow's build-gate integration scope. Tabnine Chat is the modality evaluated for prospective prompt instruction scaffolding and terminal execution.
- **The Anti-Illusion Mitigation:** Explicitly classify Inline Completions as **Unassessed / Deferred (No Tool Execution)** and restrict all proposed scaffolding strictly to **Tabnine Chat / Workspace Agent** (Category B).

### 3.2 Latent Trap 2: Absence of Dedicated Flow Template in `flow rules`
- **The Pitfall:** Assuming or advertising that running `flow rules tabnine` will materialize configuration files.
- **The Grounded Technical Reality:** Flow's `flow rules` command enforces a strict white-list of seven verified harness templates (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). Attempting `flow rules tabnine` exits with status `2` (unknown harness). Tabnine workspace instruction ingestion is unpinned.
- **The Anti-Illusion Mitigation:** Document clearly that Tabnine has no verified template in `flow rules`. Any proposed integration relies on manual prompt/workspace context or generic root `AGENTS.md`.

### 3.3 Latent Trap 3: Prohibition of Resident Daemons or Local Model Servers (ADR-0001)
- **The Pitfall:** Attempting to integrate Flow with Tabnine by creating a resident daemon, long-lived background listener, or background service that integrates with Tabnine's local architecture.
- **The Grounded Technical Reality:** ADR-0001 strictly prohibits resident daemons. Flow's state must live entirely on disk in Git and bounded filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).
- **The Anti-Illusion Mitigation:** Flow commands must run ephemerally through `bash skills/flow/runner/flow.sh <command>` and terminate immediately.

### 3.4 Latent Trap 4: Shell Tool Absence and Synthesized Pass Hallucinations
- **The Pitfall:** If Tabnine Chat acts solely as an advisory assistant without an autonomous terminal tool execution loop, an unconstrained agent may claim that a gate passed without ever running the mechanical check.
- **The Grounded Technical Reality:** An LLM agent without active shell execution cannot verify exit codes and may hallucinate a successful gate pass.
- **The Anti-Illusion Mitigation:** Flow rules mandate that **no card may be marked done and no stage may advance without an explicit on-disk exit code 0 returned by `flow.sh`**. Synthesizing a gate pass without an authenticated receipt is an automatic disqualification under the Anti-Illusion Protocol.

---

## Section 4: Four-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of Tabnine Chat in an active IDE execution session.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                      FOUR-POINT LIVE VERIFICATION RUNBOOK                              │
├─────────────────────┬─────────────────────┬─────────────────────┬──────────────────────┤
│ Gate 1: Ingestion   │ Gate 2: Invocation  │ Gate 3: Gate-Stop   │ Gate 4: State        │
│ Canary query tests  │ Status check tests  │ Forced-failure test │ Persistence check    │
│ rule parsing &      │ active terminal     │ stops on exit 1     │ verifies unlocked    │
│ command awareness.  │ tool execution.     │ without hallucinate.│ stage on disk.       │
└─────────────────────┴─────────────────────┴─────────────────────┴──────────────────────┘
```

### 4.1 Pre-Verification Environment Provisioning

1. **Test Repository Worktree Setup:**
   ```bash
   git clone <repo-url> /tmp/flow-tabnine-eval
   cd /tmp/flow-tabnine-eval
   git checkout -b test/tabnine-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Workspace Instruction Placement:**
   - Place Flow discipline instructions in the project root (`AGENTS.md`) or Tabnine workspace context:
     ```markdown
     # Flow Build Discipline for Tabnine
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
4. **Execution Client Configuration:**
   - Open `/tmp/flow-tabnine-eval` in VS Code or JetBrains IDE with the official Tabnine extension authenticated.

---

### 4.2 Gate 1: Ingestion Audit

- **Test Objective:** Verify that Tabnine Chat ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Test Input (Canary query issued to Tabnine Chat):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly identifies Flow as the governing development discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands, hallucinate external orchestrator tools, or reference host-global paths (`~/.agents/`).
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - **FAIL (Schema Error / Parsing Crash):** The Tabnine extension fails to parse workspace configuration or crashes during workspace context indexing.
  - **FAIL (Context Truncation / Dilution):** Agent fails to identify Flow, ignores project instructions, or exhibits severe prompt dilution.
  - **FAIL (Path Hallucination):** Agent specifies an imaginary command or attempts to invoke host-global paths that do not exist in the execution environment.
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit

- **Test Objective:** Verify that Tabnine Chat actively executes the Flow runner via its terminal execution tool or integrated subshell, captures the integer exit code, and reads stdout/stderr.
- **Test Input (Prompt in Tabnine Chat):**
  > *"Check the status of the current build lifecycle using the terminal."*
- **Observable Criteria:**
  - [ ] Agent dispatches or triggers an active execution of `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the IDE terminal/subshell without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.
- **Explicit Failure Outcomes:**
  - **FAIL (Subshell Dispatch Failure):** The extension fails to trigger or execute the shell command in the IDE terminal (e.g. outputs text instructions only, lacking mechanical execution).
  - **FAIL (Path Resolution Error):** Command fails with `ENOENT: No such file or directory` or attempts to run an unmapped path.
  - **FAIL (Output Truncation / Loss of Exit Code):** Execution output is dropped or the agent fails to receive the return code, causing the session to stall.
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), Tabnine Chat strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Test Input (Prompt in Tabnine Chat):**
  > *"Advance to the next stage by executing the stage gate check in the terminal."*
- **Observable Criteria:**
  - [ ] Agent executes (or directs execution of) `bash skills/flow/runner/flow.sh next`.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** synthesize or declare that the stage advanced.
  - [ ] Agent quotes the runner's diagnostic failure output and attempts to edit and repair `flow/00-idea.md`.
- **Explicit Failure Outcomes & Disqualification:**
  - **DISQUALIFIED (Pass Hallucination):** The agent declares that Stage 01 is unlocked or claims the gate passed despite the runner exiting with status code `1`. Any hallucinated pass is an **immediate disqualification**.
  - **FAIL (Blind Retry Loop):** Agent enters an unconstrained infinite loop repeatedly executing `flow.sh next` without reading failure diagnostics or editing `flow/00-idea.md`.
  - **FAIL (Silent Failure):** Agent swallows the non-zero exit code and marks the task complete without operator notification.
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

### 4.5 Gate 4: State Integrity Audit (Persistence & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh Tabnine session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Test Input (In a new Tabnine Chat session or after IDE window reload):**
  > *"What is our current lifecycle stage and what artifact was unlocked?"*
- **Observable Criteria:**
  - [ ] Runner execution outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Next stage artifact `flow/01-research.md` is unlocked and present on disk.
  - [ ] Agent executes `bash skills/flow/runner/flow.sh status` in the fresh session and confirms stage `01-research`.
  - [ ] **Zero Residency Check:** Zero background daemons, resident server processes, or persistent background tasks remain active. State persistence is entirely disk- and git-backed.
- **Explicit Failure Outcomes:**
  - **FAIL (State Desynchronization):** A new session cannot read the unlocked stage or reports stale/corrupted lifecycle state.
  - **FAIL (Artifact Mutation):** The agent corrupts or deletes lifecycle receipts or stages during readback.
  - **FAIL (Daemon Residency Breach):** A lingering background process or memory server is detected after workflow completion (violating ADR-0001).
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

## Section 5: Qualification Archival & Next Steps

### 5.1 Evidence Archival Requirement
Before Tabnine (Chat & Workspace Agent) may be upgraded from `Proposed Design Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active Tabnine IDE session (VS Code or JetBrains).
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/tabnine-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: IDE host version, Tabnine extension version, backend deployment model (Cloud vs. VPC/On-Premise), and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Rule Scaffolding Feasibility Review:** Evaluate whether Tabnine exposes structured workspace rule paths or whether generic root `AGENTS.md` is the sole ingestion channel.
2. **Interactive Host Trials:** Schedule live qualification trials on developer workstations running VS Code and JetBrains IDEs with the official Tabnine plugin.
3. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
