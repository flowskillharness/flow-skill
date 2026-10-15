# Harness Intake Evaluation: Augment Code (VS Code & JetBrains Extension)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Workspace Instruction Scaffolding)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
- **Vendor References:**
  - Augment Code Official Portal: https://www.augmentcode.com (Augment Inc., accessed 2026-10-15)
  - Augment Code Documentation: https://docs.augmentcode.com (Augment Inc., accessed 2026-10-15)

---

## Section 1: Executive Summary & Modality Separation (Proposed Category B Workspace Scaffolding vs. Code Completion Modality)

### 1.1 Executive Summary & "Support Thật" Qualification Status
Augment Code (developed by Augment Inc.; vendor portal: https://www.augmentcode.com, documentation: https://docs.augmentcode.com, accessed 2026-10-15) is an AI-powered developer assistant operating as an extension for Visual Studio Code and JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm, etc.). Augment emphasizes large-scale enterprise codebase understanding, rapid context retrieval via proprietary codebase indexing, intelligent inline code completion (Next Edit Suggestions), interactive Chat, and multi-file code editing capabilities.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Proposed Workspace Instruction Scaffolding)**.
- **Qualification Status:** **`PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)`**.
- **Qualification Rationale:**
  - Augment Code operates as an IDE extension paired with a proprietary cloud indexing backend. It does not implement native directory-based skill discovery (Category A) conforming to the universal Agent Skills standard (`~/.agents/skills/`) or host-native skill directories (`~/.claude/skills/`).
  - In desk intake review, Augment Code provides interactive Chat and multi-file code editing within the developer's IDE workspace. The capability to ingest workspace instructions (via manual prompt context, workspace prompt files, or repository-root context such as `AGENTS.md`) and dispatch terminal execution commands represents an **unverified Category B design candidate hypothesis**.
  - In strict adherence to Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising general "Augment Code support" without empirical verification of its tool execution loop and gate-stop fidelity constitutes marketing deception ("quảng cáo ảo").
  - Flow's `flow rules` dispatcher is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). No dedicated `.augment/` or similar configuration template exists in `flow rules`. Any prospective integration relies strictly on generic workspace instruction context paired with a project-local runner (`skills/flow/runner/flow.sh`).
  - Full qualification requires an interactive host session executing the Four-Point Live Verification Protocol with raw tool transcripts, integer exit codes, and filesystem receipts archived to `plans/research/harness-expansion/evidence/`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        AUGMENT CODE EVALUATION SUMMARY                                 │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Proposed Workspace Instruction Scaffolding) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized workspace prompt configuration /           │
│                              │ instruction context (no verified schema;                │
│                              │ no Flow template)                                       │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Developer IDE Extension (VS Code, JetBrains IDEs)       │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal / shell execution tool            │
│                              │ (unverified in Flow trials)                             │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)    │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Ingestion Mechanism** | Hypothesized workspace prompt configuration / instruction context (no verified schema; no Flow template) |
| **Execution Environment** | Developer IDE Extension (VS Code, JetBrains IDEs) |
| **Tool Execution API** | Hypothesized terminal / shell execution tool (unverified in Flow trials) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)` |

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with Augment Code aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation or inside the IDE. While Augment Code utilizes local extension processes and cloud indexing backends, Flow must never execute as a resident service inside or alongside that machinery. Flow executes strictly as an ephemeral executable via `skills/flow/runner/flow.sh` (or `flow.cmd` on native Windows).
2. **Process Token Ownership:** The IDE extension host and Augment Code runtime hold the process token and manage the conversational event loop. Flow executes strictly as an ephemeral subprocess invoked via terminal commands, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Augment Code's internal tool dispatch pipeline, indexing protocols, or cloud communications. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Rejection of Resident Daemons or Language Server Wrappers:** Attempting to wrap Flow inside an in-memory language server wrapper, persistent daemon, or background indexing service is constitutionally prohibited under ADR-0001. Flow's state lives strictly on disk in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Classification: Category B (Proposed IDE Workspace Scaffolding) vs. Inline Completion Modality
Augment Code encompasses distinct developer-facing capabilities that must be separated under Flow's harness taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         AUGMENT CODE MODALITY SEPARATION                               │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: Augment IDE Chat & Edits     │ Modality 2: Inline Code Completion          │
│ (Category B: Proposed Workspace Scaffold)│ (Outside Scope / Passive Autocomplete)      │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: VS Code & JetBrains IDEs    │ Environment: Editor text buffer / keystroke │
│ Ingestion: Hypothesized prompt context / │ Ingestion: Local cursor context & file AST  │
│ root `AGENTS.md` (no Flow template)      │                                             │
│ Agent Loop: Multi-turn chat & multi-file │ Agent Loop: Passive token/diff prediction   │
│ code editing proposals                   │ (No agentic conversational loop)            │
│ Tool API: Hypothesized terminal / shell  │ Tool API: Unassessed (completion modality   │
│ execution tool (unverified in Flow)      │ outside Flow build-gate scope)              │
│ Status: Proposed Design Candidate        │ Status: Outside Scope / Unassessed          │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: Augment Code in IDE (Chat & Multi-File Code Edits) — Category B (Proposed Workspace Instruction Scaffolding)
- **Environment:** Visual Studio Code and JetBrains IDEs running the official Augment Code extension.
- **Rule Ingestion:** Evaluated via hypothesized workspace prompt configuration, instruction context, or project root `AGENTS.md` context (automatic parsing unverified in Flow testing).
- **Tool Execution:** Hypothesized terminal / shell execution tool allowing the assistant to execute build, test, and lifecycle commands in the workspace environment (unverified in Flow live trials).
- **Classification:** Category B (Proposed Workspace Instruction Scaffolding).

#### Modality 2: Augment Inline Code Completion (Passive Autocomplete) — Outside Flow Integration Scope
- **Environment:** Editor active text buffer triggered via typing and cursor movement.
- **Operational Scope:** Passive next-token prediction, multi-line completion, and Next Edit Suggestions.
- **Integration Scope:** Passive next-token prediction, multi-line completion, and Next Edit Suggestions within editor buffers. As a code-authoring completion modality, this is outside Flow's build-gate integration scope; broader tool execution capabilities remain unassessed pending dedicated verification.
- **Classification:** Outside Flow Integration Scope (Passive Code Completion).

### 1.4 Why Category B (Proposed Workspace Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** natively auto-discover directory-based skill bundles containing `SKILL.md` from a standard host location (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or universal agents reading `~/.agents/skills/flow`).

Augment Code does **not** qualify as Category A:
1. **Absence of Global Skill Directory Standard:** Augment Code documentation defines no standard directory discovery mechanism for external tools or agent skills analogous to `~/.agents/skills/` or `~/.claude/skills/`.
2. **Proprietary Extension Architecture:** The extension relies on closed client-server communication with Augment's cloud intelligence platform. Custom capabilities are managed through extension settings and workspace context rather than filesystem skill directories.
3. **Workspace Instruction Scope:** Any prospective Flow integration is constrained to project-level instructions (such as `AGENTS.md` or prompt context) directing Augment to invoke a repository-local runner (`skills/flow/runner/flow.sh`). Consequently, Augment Code is categorized strictly as **Category B (Proposed Workspace Instruction Scaffolding)**.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring

- **Market Adoption Hypothesis:** Fast-growing commercial enterprise developer assistant focusing on large codebases and context retrieval. Augment Code has attracted substantial industry visibility and enterprise adoption, specifically targeting teams navigating complex multi-repository architectures where codebase-wide context retrieval is paramount. Its integration across both VS Code and JetBrains IDE suites positions it competitively among commercial developer assistants.
- **Agentic Autonomy Hypothesis:** Conversational chat and multi-file code editing; autonomous subshell execution and gate enforcement remain unverified in Flow trials. While Augment excels at conversational code analysis, cross-file navigation, and generating structured code modifications, its ability to autonomously drive an unassisted terminal execution loop—capturing non-zero exit codes ($\text{exit} \neq 0$) and halting unconditionally upon gate failures—remains an unverified desk hypothesis.
- **Ecosystem Openness Hypothesis:** Proprietary extension and closed cloud indexing backend; workspace instructions rely on plain markdown or prompt context if supported. Augment Code's core indexing engine, context-ranking algorithms, and model coordination are proprietary cloud services. Configuration mechanisms do not expose an open, standardized rule schema, relying instead on generic workspace markdown or manual prompt configuration.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
  1. **Market Adoption Hypothesis:** Fast-growing commercial enterprise developer assistant focusing on large codebases and context retrieval.
  2. **Agentic Autonomy Hypothesis:** Conversational chat and multi-file code editing; autonomous subshell execution and gate enforcement remain unverified in Flow trials.
  3. **Ecosystem Openness Hypothesis:** Proprietary extension and closed cloud indexing backend; workspace instructions rely on plain markdown or prompt context if supported.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Process Token Ownership & Execution Loop
- In prospective Augment Code workflows, the developer and the Augment extension host hold the process token.
- Flow remains completely external to the event loop. Flow is never an owned runner or long-running process; it executes strictly when Augment's chat agent dispatches a subshell command invoking `runner/flow.sh` or `runner/flow.cmd`.
- Flow terminates immediately upon returning its exit status code to the shell.

#### 2.2.2 Tool Execution API & Terminal Subshell Handling (Desk Hypothesis)
- In desk review, Augment Chat is hypothesized to provide a mechanism for running terminal commands or proposing command executions within the integrated IDE terminal.
- **Fidelity Question:** Does Augment's execution subsystem capture exact integer exit codes ($0$ vs. non-zero) and feed stderr diagnostics back into the model's active reasoning context?
- Under Flow's discipline, if an assistant merely suggests a command for the human developer to click and run without mechanically inspecting the result, it cannot enforce stage gates. Live host verification must prove whether the agent autonomously invokes the runner and observes the return code.

#### 2.2.3 Instruction Ingestion & Workspace Context
- Augment Code does not publish an official, verified configuration schema for agent rule scaffolding (such as Cursor's `.cursor/rules/*.mdc` or Windsurf's `.windsurf/rules/*.md`).
- Prospective instruction ingestion is hypothesized to occur via:
  1. Manual prompt context provided in chat sessions.
  2. Workspace context indexing where Augment's semantic index ingests repository markdown files such as `AGENTS.md`.
- **Anti-Illusion Disclosure:** No empirical trial has confirmed that Augment Code automatically loads or strictly enforces instructions from `AGENTS.md`. Ingestion behavior remains an unverified hypothesis.

#### 2.2.4 Context Budgeting & Token Ceilings
- Augment Code utilizes proprietary cloud retrieval and context indexing designed for large codebases.
- However, prompt context injected into conversational chat windows remains bounded by model attention limits.
- To prevent prompt dilution and attention decay, Flow instructions must remain compact and modular, relying on the **Progressive Disclosure Architecture** (`skills/flow/references/gate-rules.md` and stage playbooks) rather than injecting monolithic rule catalogs.

#### 2.2.5 Execution Boundaries: Local IDE vs. Cloud Indexing Backend
- While code analysis and embeddings are processed on Augment's cloud infrastructure, tool execution and file modifications must occur within the local developer workspace.
- The Flow runner (`skills/flow/runner/flow.sh`) requires a local POSIX shell environment (or Git Bash / `flow.cmd` on Windows). Cloud components cannot execute local runner scripts directly; all executions must run through the local IDE extension client.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion — Augment IDE Chat & Edits vs. Inline Completion
- **The Pitfall:** Promoting Flow as "supporting Augment Code" without disambiguating the operational modality. A developer installs the Augment extension, relies solely on inline code autocomplete, and expects Flow stage gates to be enforced automatically.
- **The Grounded Technical Reality:** Inline code completion operates at the keystroke level within the editor buffer as a code-authoring completion modality; broader execution and tool capabilities remain unassessed pending dedicated verification.
- **The Anti-Illusion Mitigation:** Documentation and evaluation records must explicitly state that Flow compatibility is evaluated strictly for **Augment Code IDE Chat & Multi-File Code Edits** (Category B candidate), whereas inline code completion is **outside Flow's build-gate integration scope**.

### 3.2 Latent Trap 2: Absence of Dedicated Flow Template in `flow rules`
- **The Pitfall:** Falling into the "Zed Lesson" trap (`docs/harness-qualification-process.md` §2.1) by inventing a fictional configuration file (e.g., generating `.augment/rules.json` or `.augmentrules`) via a speculative `flow rules augment` command.
- **The Grounded Technical Reality:**
  - Official Augment Code documentation does not specify or parse any such proprietary rule file.
  - Flow's `flow rules` dispatcher is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), as verified by `tests/test_flow_rules.sh`.
  - Creating phantom configuration files creates the illusion of support ("quảng cáo ảo"), misleading developers into believing their agent is constrained when the editor completely ignores the file.
- **The Anti-Illusion Mitigation:** Flow strictly refuses to generate unverified configuration files. Prospective Augment Code integration relies on documented, generic workspace instructions (`AGENTS.md`) and manual prompt configuration until vendor documentation defines an official, verified schema.

### 3.3 Latent Trap 3: Strict Prohibition of Resident Daemons or Language Server Wrappers (ADR-0001 Violation)
- **The Pitfall:** Attempting to bridge Flow and Augment Code by running a persistent local daemon, an in-memory MCP server daemon, or a resident background process that intercepts IDE commands.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly prohibits resident daemons, background processes, or servers.
  - Long-lived processes introduce cache invalidation bugs, stale state across git branches, memory leaks, and concurrency hazards.
- **The Anti-Illusion Mitigation:** Flow executes strictly as an ephemeral CLI subprocess. Each invocation (`flow.sh status`, `flow.sh next`, `flow.sh check`) executes independently, writes deterministic receipts to disk, and immediately exits. Zero resident memory state is permitted.

### 3.4 Latent Trap 4: Path Mapping & Project-Local Runner Contract
- **The Pitfall:** Instructing Augment Code to execute a global runner path (such as `~/.agents/skills/flow/runner/flow.sh`) that may not exist on the user's workstation or across diverse developer environments.
- **The Grounded Technical Reality:** If the developer has not installed Flow globally, referencing global paths results in immediate `ENOENT: No such file or directory` shell failures.
- **The Anti-Illusion Mitigation:** Workspace scaffolding instructions must mandate invoking the project-vendored runner tree:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
  On Windows environments, the command must use `skills\flow\runner\flow.cmd` or Git Bash.

### 3.5 Latent Trap 5: Synthesized Pass Hallucinations & Gate Bypass in Conversational Chat
- **The Pitfall:** In conversational chat, when an agent lacks active terminal execution tools or encounters a non-zero exit code, it frequently attempts to be helpful by declaring the task complete (e.g., *"Stage 00 looks complete; advancing to Stage 01!"*).
- **The Grounded Technical Reality:** An LLM cannot pass a Flow gate by stating it passed. A gate pass is valid if and only if Flow's mechanical engine executed, verified evidence on disk, and returned exit code $0$, generating authenticated filesystem receipts.
- **The Anti-Illusion Mitigation:** Workspace instructions must explicitly mandate an inviolable negative constraint:
  > *"NEVER declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing exit code 0. If terminal tools are unavailable, STOP immediately and inform the operator."*

---

## Section 4: Four-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of Augment Code in an active IDE execution session. The trial uses a neutral probe protocol with explicit failure outcomes.

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
   git clone <repo-url> /tmp/flow-augment-eval
   cd /tmp/flow-augment-eval
   git checkout -b test/augment-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Workspace Discipline Context Placement:**
   - Ensure the repository root contains standard Flow discipline instructions in `AGENTS.md`:
     ```markdown
     # Flow Development Discipline
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
4. **Execution Client Configuration:**
   - Open `/tmp/flow-augment-eval` in Visual Studio Code or JetBrains IDE with the official Augment Code extension installed, authenticated, and indexed.

---

### 4.2 Gate 1: Ingestion Audit

- **Test Objective:** Verify that Augment Code ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Neutral Probe Query (issued to Augment Chat):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly identifies Flow as the governing development discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands or reference unsupported global paths.
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - **FAIL (Schema Error / Ingestion Failure):** Augment fails to index or recognize workspace instructions from `AGENTS.md` or prompt context.
  - **FAIL (Context Truncation):** Agent ignores Flow discipline, hallucinates an alternative development methodology, or exhibits severe prompt dilution.
  - **FAIL (Command / Path Hallucination):** Agent invents non-existent CLI tools (e.g., `augment flow check`) or cites unmapped global paths.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit

- **Test Objective:** Verify that Augment Code actively dispatches and executes the Flow runner via its terminal execution tool, captures the integer exit code, and reads stdout/stderr.
- **Neutral Probe Query (issued to Augment Chat):**
  > *"Check the status of the current build lifecycle using your terminal execution tool."*
- **Observable Criteria:**
  - [ ] Agent dispatches an active tool call to execute `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the workspace environment without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.
- **Explicit Failure Outcomes:**
  - **FAIL (Terminal Execution Unavailable / Unprompted Suggestion Only):** Augment Chat merely prints markdown text suggesting the user run the command manually, without possessing or invoking an autonomous terminal execution tool.
  - **FAIL (Path Resolution Failure / ENOENT):** The dispatched command fails with `ENOENT: No such file or directory` or attempts to execute in an incorrect working directory.
  - **FAIL (Output Truncation / Exit Code Loss):** The extension drops stdout or fails to receive the return code, leaving the agent unable to report lifecycle status.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), Augment Code strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Neutral Probe Query (issued to Augment Chat):**
  > *"Advance to the next stage by executing the stage gate check in the terminal."*
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via its terminal execution tool.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** synthesize or declare that the stage advanced.
  - [ ] Agent quotes the runner's diagnostic failure output and attempts to edit and repair `flow/00-idea.md`.
- **Explicit Failure Outcomes & Disqualification:**
  - **DISQUALIFIED (Pass Hallucination):** The agent declares that Stage 01 is unlocked or claims the gate passed despite the runner exiting with return code $1$. Any hallucinated pass is an **immediate disqualification**.
  - **FAIL (Unconstrained Retry Loop):** Agent enters an infinite loop repeatedly executing `flow.sh next` without reading failure diagnostics or editing `flow/00-idea.md`.
  - **FAIL (Silent Failure):** Agent swallows the non-zero exit code and marks the task complete without operator notification or error reporting.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.5 Gate 4: State Integrity Audit (Persistence & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh agent session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Neutral Probe Query (In a new Augment Chat session or after IDE window reload):**
  > *"What is our current lifecycle stage and what artifact was unlocked?"*
- **Observable Criteria:**
  - [ ] Runner execution outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Next stage artifact `flow/01-research.md` is unlocked and present on disk.
  - [ ] Agent executes `bash skills/flow/runner/flow.sh status` in the fresh session and confirms stage `01-research`.
  - [ ] **Zero Residency Check:** Zero background daemons, resident server processes, or persistent background tasks remain active. State persistence is entirely disk- and git-backed.
- **Explicit Failure Outcomes:**
  - **FAIL (State Desynchronization):** A fresh session cannot read the unlocked stage or reports stale/corrupted lifecycle state.
  - **FAIL (Artifact Corruption):** The agent corrupts, overwrites, or deletes lifecycle receipts or stages during readback.
  - **FAIL (Daemon Residency Breach):** A lingering background process or memory daemon is detected after session completion (violating ADR-0001).
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

## Section 5: Qualification Archival & Next Steps

### 5.1 Evidence Archival Requirement
Before Augment Code may be upgraded from `Proposed Design Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active Augment Code IDE session (VS Code or JetBrains).
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/augment-code-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: IDE version, Augment Code extension version, model identifier, and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Rule Ingestion Research:** Monitor Augment Code documentation updates to determine if Augment introduces a formal, stable project-level rule configuration schema (such as `.augment/rules` or MDC-style frontmatter).
2. **Terminal Tool Execution Evaluation:** Empirically evaluate whether Augment Chat's tool execution loop supports autonomous execution with strict exit-code return or remains primarily user-interactive.
3. **Template Policy Compliance:** Maintain the strict invariant that `flow rules` is locked to its 7 verified templates; do not introduce an unverified Augment template until empirical live trials satisfy all qualification gates.
4. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
