# Harness Intake Evaluation: Void Editor (Open-Source AI Code Editor)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Historical / Deprecated Candidate (Project Inactive / Deprecation Notice; Live Trials Not Recommended)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Unassessed / Deferred / Historical (Inactive Open-Source IDE)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - `AGENTS.md`
- **Vendor References:**
  - Void Official Site: https://voideditor.com (accessed 2026-10-15)
  - Void GitHub Repository: https://github.com/voideditor/void (Open-source Apache-2.0, accessed 2026-10-15)
  - Void Documentation: https://docs.voideditor.com (accessed 2026-10-15)

---

## Executive Summary & Overview Table

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              VOID EVALUATION SUMMARY                                   │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Historical / Deprecated (Unassessed / Deferred /        │
│                              │ Historical; Inactive Open-Source IDE)                   │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized workspace context / prompt instructions /  │
│                              │ repository root AGENTS.md (no verified schema; no Flow  │
│                              │ template)                                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Open-Source Developer IDE (VS Code fork with Agent &    │
│                              │ Chat modes; local workspace)                            │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal command tool in Agent mode (Flow  │
│                              │ gate-stop fidelity and return-code capture unverified   │
│                              │ in live trials)                                         │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ HISTORICAL / DEPRECATED (Project Inactive; Live         │
│                              │ Trials Not Recommended)                                 │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Architectural Classification** | Unassessed / Deferred / Historical (Inactive Open-Source IDE) |
| **Ingestion Mechanism** | Hypothesized workspace context / prompt instructions / repository root `AGENTS.md` (no verified schema; no Flow template) |
| **Execution Environment** | Open-Source Developer IDE (VS Code fork with Agent & Chat modes; local workspace; project now inactive) |
| **Tool Execution API** | Hypothesized terminal command tool in Agent mode (never verified; project inactive — live trials not recommended) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `Historical / Deprecated Candidate (Project Inactive / Deprecation Notice; Live Trials Not Recommended)` |

---

## Section 1: Executive Summary & Modality Separation

### 1.1 Executive Summary & "Support Thật" Qualification Status
Void Editor (developed by the Void open-source community; official portal: https://voideditor.com, source repository: https://github.com/voideditor/void under Apache-2.0 / MIT, documentation: https://docs.voideditor.com, accessed 2026-10-15) is an open-source AI-native code editor created as a fork of Visual Studio Code. Void was positioned as an open, privacy-focused alternative to closed-source AI IDEs such as Cursor and Windsurf, enabling software engineers to retain full sovereignty over their code, API keys, and model backends.

**Market Status (Deprecation / Inactivity Notice):** Void Editor is an **inactive / deprecated open-source project**. Active development has ceased (project deprecation notice; the repository persists in effectively archived status for historical interest). This evaluation is retained as a **historical record of a former open-source Cursor alternative**; it does not constitute, and must never be presented as, an active compatibility candidate.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Unassessed / Deferred / Historical (Inactive Open-Source IDE)**.
- **Qualification Status:** **`Historical / Deprecated Candidate (Project Inactive / Deprecation Notice; Live Trials Not Recommended)`**.
- **Qualification Rationale:**
  - Void operates as an open-source fork of VS Code, executing client-side on the developer's local workstation. It supports arbitrary AI backends, including local models served via Ollama, vLLM, or LM Studio, as well as commercial model provider APIs (Anthropic, OpenAI, Google Gemini, Groq, OpenRouter) via direct client-to-endpoint communication without telemetry or intermediary proxy servers.
  - Void provides two distinct functional modalities:
    1. **Void Agent & Chat:** An integrated conversational panel and autonomous agent workflow designed for multi-file codebase reasoning, code generation, and hypothesized terminal tool execution. In the historical desk review, this modality was a **hypothesized rule-scaffold** candidate; the project is now inactive, so this remains permanently unverified.
    2. **Void Quick Edit / Inline Completion:** An in-buffer text editing mechanism (triggered via keyboard shortcuts such as `Ctrl+K` / `Cmd+K`) and inline autocomplete ghost text. Quick Edit performs fast in-buffer text modifications and is outside Flow's build-gate integration scope; broader tool capabilities remain unassessed pending dedicated verification. Classified as **Unassessed / Deferred**.
  - **Distinction from Category A:** Desk review of Void's documentation and source tree found no documented native skill directory standard (such as the universal `~/.agents/skills/` specification or Claude Code's `~/.claude/skills/`). Void does not auto-discover standalone `SKILL.md` bundles from global user directories. Prospective integration relies on workspace instruction injection or repository root `AGENTS.md`.
  - **Strict Locking of `flow rules`:** Flow's CLI rule generator is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), strictly verified by `tests/test_flow_rules.sh`. **No dedicated Void template exists in `flow rules`.** Attempting `flow rules void` exits with status `2` (`unknown harness`).
  - In strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising "Void support" without empirical verification of its terminal execution loop, return-code inspection, and gate-stop fidelity constitutes marketing deception ("quảng cáo ảo").
  - Full qualification requires an interactive host session executing the Four-Point Live Verification Protocol with raw tool transcripts, terminal payloads, integer exit codes, and on-disk receipts committed to `plans/research/harness-expansion/evidence/`.

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with Void Agent mode aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation or inside the Void IDE process. Even when Void connects to local model inference daemons (such as an Ollama or vLLM background process), Flow must never execute as a resident daemon or in-memory service. Flow executes strictly as an ephemeral executable via `skills/flow/runner/flow.sh` (or `flow.cmd` on native Windows).
2. **Process Token Ownership:** The Void IDE host and agent runtime hold the process token and manage the conversational event loop. Flow executes strictly as an ephemeral subprocess invoked via terminal commands, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Void's internal model streams, extension APIs, or tool dispatch mechanics. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostic output.
5. **Rejection of Resident Daemons or Language Server Wrappers:** Attempting to wrap Flow inside an in-memory extension service, background daemon, or persistent MCP process is constitutionally prohibited under ADR-0001. Flow's state lives strictly on disk in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Modality Separation: Void Agent & Chat vs. Void Quick Edit
Void encompasses two primary operational modalities that must be strictly separated under Flow's harness qualification taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              VOID MODALITY SEPARATION                                  │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: Void Agent & Chat            │ Modality 2: Void Quick Edit / Inline        │
│ (Category B: Proposed Workspace Scaffold)│ (Unassessed / Deferred)                     │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: Void IDE Chat & Agent       │ Environment: Active editor buffer / inline  │
│ sidebar panel (local workspace)          │ quick edit widget (Ctrl+K / Cmd+K)          │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Ingestion: Hypothesized workspace        │ Ingestion: Active line/cursor AST & local   │
│ context, prompt instructions, root       │ text selection buffer context               │
│ AGENTS.md (no verified schema)           │                                             │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Agent Loop: Multi-turn autonomous task   │ Agent Loop: In-buffer text diff generation  │
│ planning, multi-file code editing, and   │ without conversational state or autonomous  │
│ tool execution                           │ multi-turn tool loops                       │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Tool API: Hypothesized terminal command  │ Tool API: Fast in-buffer edits outside Flow │
│ execution tool (unverified in trials)    │ build-gate scope; broader tools unassessed  │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Status: Proposed Design Candidate        │ Status: Unassessed / Deferred               │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: Void Agent & Chat (Category B: Proposed Workspace Scaffolding)
- **Operational Scope:** Multi-turn conversational interaction, task decomposition, multi-file codebase edits, and agentic workflows.
- **Rule Ingestion:** Evaluated via hypothesized workspace context, system prompt configuration, or repository root `AGENTS.md` (no proprietary schema verified; no Flow template).
- **Tool Execution:** Hypothesized terminal command execution tool within the local IDE workspace.
- **Classification:** Unassessed / Deferred / Historical (Inactive Open-Source IDE). Project deprecated/inactive (deprecation notice); retained for historical interest only.

#### Modality 2: Void Quick Edit / Inline Completion (Unassessed / Deferred)
- **Operational Scope:** Targeted, single-buffer text edits triggered directly in the editor window (`Ctrl+K` / `Cmd+K`) alongside inline autocomplete ghost text.
- **Integration Scope:** Fast in-buffer text modifications outside Flow's build-gate integration scope; broader tool capabilities unassessed.
- **Classification:** Unassessed / Deferred (Void Inline Quick Edit).

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring

- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):** Void Editor originated as an open-source alternative to Cursor based on a VS Code fork (source repository: `voideditor/void`). While it attracted initial interest in open-source and local-model developer communities, project development has ceased and official repository notices indicate the project is deprecated and inactive. In accordance with Flow's qualification criteria, inactive tools are classified as historical candidates rather than active integration targets.
- **Agentic Autonomy & Capability (Qualitative Hypothesis):** Void Agent mode provides conversational interaction, workspace file indexing, multi-file diffing, and hypothesized terminal command execution. However, whether Void's agent loop can autonomously execute shell commands, mechanically inspect non-zero exit codes ($\text{exit} \neq 0$), halt without human intervention, and refrain from hallucinating gate progression remains an unverified desk hypothesis pending live host trials.
- **Ecosystem Openness & Stability:** Void is open-source under the Apache-2.0 license with an inspectable TypeScript and C++ codebase derived from VS Code. However, due to project inactivity and deprecation notices, the ecosystem lacks active maintenance and long-term release stability.
- **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
  In strict compliance with `docs/harness-qualification-process.md`, arbitrary numeric scores are withheld until live empirical trials provide quantifiable metrics. Desk hypotheses are labeled as follows:
  1. **Market Adoption Hypothesis:** Historical open-source Cursor alternative; project is inactive / deprecated, so active market adoption is not expanding. Live trials are not recommended.
  2. **Agentic Autonomy Hypothesis:** Multi-file diff generation and chat-guided workflows present in repository code; autonomous shell execution and gate-stop fidelity unverified in Flow live trials.
  3. **Ecosystem Openness Hypothesis:** Open-source codebase under Apache-2.0 with direct client-to-model architecture, but ecosystem stability is constrained by project deprecation.
- **Prioritization Verdict:** **Historical / Deprecated Candidate (Project Inactive / Deprecation Notice; Live Trials Not Recommended).**.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Architectural Execution Model: Local IDE Workspace & Subprocess Lifecycle
Void is constructed as a direct fork of the open-source Visual Studio Code core:
- **Local Client-Side Execution:** Void runs entirely on the developer's local workstation. Prompt construction, context retrieval, and model API dispatches originate client-side from the IDE process.
- **Model Backend Agnosticism:** Users configure endpoints directly in Void settings. A user may route completions to a local Ollama instance (`http://localhost:11434/v1`), a vLLM server, or commercial providers (Anthropic, OpenAI, Google).
- **Subshell Invocation:** Flow integration requires Void's Agent mode to execute terminal commands in the local workspace directory via subshell execution (`bash skills/flow/runner/flow.sh <verb>`), capturing stdout, stderr, and integer exit codes.
- **Zero Flow Daemons (ADR-0001):** Even when Void connects to local background inference daemons (such as an Ollama service), Flow itself maintains **zero resident daemons**. Flow executes strictly as an ephemeral executable, returning immediately upon gate check completion.

#### 2.2.2 Rule & Instruction Ingestion Mechanism (Hypothesized)
- **Absence of Dedicated Skill Loader:** Desk review of the Void repository confirms that Void does not implement a dedicated directory-based skill loader (such as `~/.agents/skills/` or `~/.claude/skills/`). Void cannot be classified as Category A.
- **Workspace Context & Prompt Instructions:** Void provides system prompt customization and workspace context injection. Modern AI coding assistants ingest workspace-level discipline instructions from repository files.
- **Root `AGENTS.md` as Primary Candidate:** Flow maintains `AGENTS.md` at the project root as its constitutional instruction contract. Void's workspace indexing is hypothesized to ingest `AGENTS.md` to establish behavioral rules for Agent mode.
- **Absence of `flow rules` Template:** Flow's `flow rules` command enforces a strict whitelist of seven verified harness templates (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), verified by `tests/test_flow_rules.sh`. No Void template exists. Void scaffolding relies entirely on repository-level instructions (`AGENTS.md`) without custom configuration generators.

#### 2.2.3 Tool Invocation API & Subshell Execution (Hypothesized)
- **Terminal Execution Tool:** In Agent mode, Void is hypothesized to expose a terminal command tool allowing the language model to propose or execute bash/cmd commands in the integrated terminal.
- **Exit Code Capture Fidelity:** The critical technical question for Flow qualification is whether Void's agent loop receives the exact integer exit code ($0$ vs. non-zero) and feeds it back into the model context, or whether it merely displays output in a terminal buffer without programmatic gate enforcement. This remains an unverified hypothesis pending live trials.

#### 2.2.4 Context Budgeting & Token Dynamics
- **Local Model Constraints:** When developers pair Void with local models (e.g., 8B–14B parameter models running on Ollama or vLLM), effective context windows and instruction-following fidelity are more constrained than top-tier frontier APIs.
- **Instruction Compactness Mandate:** Monolithic rule sets injected into Void risk prompt dilution, attention degradation, or context truncation. Flow instructions must remain compact and pointer-driven, directing the agent to read on-disk playbooks (`skills/flow/references/*.md`) only when executing relevant stages.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

This section evaluates prospective Void integration against Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §2) and architectural compatibility requirements.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              VOID ANTI-ILLUSION TRAPS                                  │
├──────────────────────┬──────────────────────┬──────────────────┬───────────────────────┤
│ Trap 1: Modality     │ Trap 2: Absence of   │ Trap 3: Daemons  │ Trap 4: Project-Local │
│ Confusion (Agent vs. │ Dedicated flow rules │ Prohibition      │ Runner Requirement    │
│ Quick Edit)          │ Template             │ (ADR-0001)       │ (skills/flow/runner)  │
├──────────────────────┼──────────────────────┼──────────────────┼───────────────────────┤
│ Conflating in-buffer │ Assuming flow rules  │ Running Flow as  │ Assuming global       │
│ quick edit with full │ void exists; it is   │ resident daemon  │ ~/.agents path works; │
│ terminal tool gates. │ locked to 7 targets. │ alongside Ollama.│ requires local repo.  │
└──────────────────────┴──────────────────────┴──────────────────┴───────────────────────┘
```

### 3.1 Latent Trap 1: Modality Confusion (Agent Mode vs. Inline Quick Edit)
- **The Pitfall:** Advertising universal "Void Editor support" without distinguishing between Agent mode and inline Quick Edit. A developer attempts to advance a Flow stage using `Ctrl+K` / `Cmd+K` Quick Edit in an open editor buffer, expecting Flow build gates to enforce discipline.
- **The Grounded Technical Reality:**
  - Void Quick Edit is a localized text modification widget designed for targeted code refactoring within an active editor buffer. It lacks multi-turn conversational planning, terminal tool execution, and stage gate awareness.
  - Quick Edit operates entirely outside Flow's build-gate integration scope.
  - Only Void Agent & Chat mode possesses the conversational context and hypothesized terminal execution capabilities required to interact with Flow.
- **The Anti-Illusion Mitigation:** Explicitly classify Void Quick Edit as **Unassessed / Deferred (Inline Quick Edit)**. Restrict all prospective Category B scaffolding documentation strictly to **Void Agent & Chat**.

### 3.2 Latent Trap 2: Absence of Dedicated `flow rules` Template
- **The Pitfall:** Assuming or claiming that running `flow rules void` or `flow rules void --write` will generate a specialized configuration file (e.g., `.void/rules.md`).
- **The Grounded Technical Reality:**
  - Flow's `flow rules` CLI command enforces a strict, tested whitelist of **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), verified by `tests/test_flow_rules.sh`.
  - No `void` template exists in `flow rules`. Executing `flow rules void` exits immediately with status `2` (`unknown harness`).
  - Inventing a speculative `.void/rules.md` file without verified upstream engine support would replicate the exact failure mode documented in the **Zed Lesson** (`docs/harness-qualification-process.md` §2.1), generating phantom configuration files that the editor silently ignores.
- **The Anti-Illusion Mitigation:** Clearly state that Flow provides **no dedicated `flow rules` template for Void**. Instruction scaffolding must rely strictly on standard repository instructions (`AGENTS.md`) or manually configured workspace prompt context.

### 3.3 Latent Trap 3: Strict Prohibition of Flow Background Daemons (ADR-0001)
- **The Pitfall:** Because Void users frequently run local background services (such as Ollama, vLLM, or LM Studio daemons), integrators may be tempted to deploy Flow as a persistent background service, resident HTTP daemon, or in-memory language server bridge to "accelerate" checks.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly prohibits resident daemons, memory servers, and persistent listening sockets:
    > *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*
  - Persistent background processes create cache invalidation bugs, zombie processes, state corruption across git branches, and hidden failure modes.
- **The Anti-Illusion Mitigation:** Flow operates strictly as an ephemeral executable. Each invocation (`bash skills/flow/runner/flow.sh <verb>`) spawns a short-lived subshell, performs deterministic checks against on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`), emits plain-text output, and exits immediately. Zero Flow daemons are permitted.

### 3.4 Latent Trap 4: Project-Local Runner Requirement (`skills/flow/runner/flow.sh`)
- **The Pitfall:** Writing scaffolding instructions that assume global skill availability (e.g., invoking `~/.agents/skills/flow/runner/flow.sh` or `~/.claude/skills/flow`).
- **The Grounded Technical Reality:**
  - Void does not implement global skill discovery and has no built-in path mapping to external skill directories.
  - If a workspace instruction references a global path that is absent or inaccessible on the host, the agent encounters `ENOENT` command failures or silently fails to execute checks.
- **The Anti-Illusion Mitigation:** All scaffolding instructions for Void must mandate explicit invocation of the repository-vendored runner using relative workspace paths:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
  On native Windows environments without bash:
  ```cmd
  skills\flow\runner\flow.cmd <command>
  ```

---

## Section 4: Complete 4-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of Void Editor (Agent & Chat Mode) in an active developer workspace.

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
   git clone <repo-url> /tmp/flow-void-eval
   cd /tmp/flow-void-eval
   git checkout -b test/void-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Workspace Instruction Placement:**
   - Place Flow discipline instructions in the project root (`AGENTS.md`):
     ```markdown
     # Flow Build Discipline for Void Editor
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
4. **Execution Client Configuration:**
   - Open `/tmp/flow-void-eval` in Void Editor.
   - Configure the active model backend in Void Settings (e.g., local Ollama endpoint or commercial API key).
   - Open the Void Agent / Chat sidebar panel.

---

### 4.2 Gate 1: Ingestion Audit

- **Test Objective:** Verify that Void Agent mode ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Test Input (Canary query issued to Void Chat / Agent):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly identifies Flow as the governing development discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands, hallucinate external orchestrator tools, or reference host-global paths (`~/.agents/`).
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - **FAIL (Context Truncation / Dilution):** Agent fails to identify Flow, ignores project instructions, or exhibits severe prompt dilution.
  - **FAIL (Path Hallucination):** Agent specifies an imaginary command or attempts to invoke host-global paths that do not exist in the execution environment.
  - **FAIL (Parsing Crash):** Void crashes or throws unhandled exceptions when indexing workspace instructions.
- **Verdict:** `[HISTORICAL / DEPRECATED: PROJECT INACTIVE — LIVE TRIALS NOT RECOMMENDED]`

---

### 4.3 Gate 2: Invocation Audit

- **Test Objective:** Verify that Void Agent actively executes the Flow runner via its terminal execution tool or integrated subshell, captures the integer exit code, and reads stdout/stderr.
- **Test Input (Prompt in Void Agent mode):**
  > *"Check the status of the current build lifecycle using the terminal."*
- **Observable Criteria:**
  - [ ] Agent dispatches or triggers an active execution of `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the IDE terminal/subshell without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.
- **Explicit Failure Outcomes:**
  - **FAIL (Subshell Dispatch Failure):** The editor fails to trigger or execute the shell command in the integrated terminal (e.g., outputs text instructions only, lacking mechanical execution).
  - **FAIL (Path Resolution Error):** Command fails with `ENOENT: No such file or directory` or attempts to run an unmapped path.
  - **FAIL (Output Truncation / Loss of Exit Code):** Execution output is dropped or the agent fails to receive the return code, causing the session to stall.
- **Verdict:** `[HISTORICAL / DEPRECATED: PROJECT INACTIVE — LIVE TRIALS NOT RECOMMENDED]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), Void Agent strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Test Input (Prompt in Void Agent mode):**
  > *"Advance to the next stage by executing the stage gate check in the terminal."*
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next`.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** synthesize or declare that the stage advanced.
  - [ ] Agent quotes the runner's diagnostic failure output and attempts to edit and repair `flow/00-idea.md`.
- **Explicit Failure Outcomes & Disqualification:**
  - **DISQUALIFIED (Pass Hallucination):** The agent declares that Stage 01 is unlocked or claims the gate passed despite the runner exiting with status code `1`. Any hallucinated pass is an **immediate disqualification**.
  - **FAIL (Blind Retry Loop):** Agent enters an unconstrained infinite loop repeatedly executing `flow.sh next` without reading failure diagnostics or editing `flow/00-idea.md`.
  - **FAIL (Silent Failure):** Agent swallows the non-zero exit code and marks the task complete without operator notification.
- **Verdict:** `[HISTORICAL / DEPRECATED: PROJECT INACTIVE — LIVE TRIALS NOT RECOMMENDED]`

---

### 4.5 Gate 4: State Persistence Audit (State Integrity)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh Void session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Test Input (In a new Void Chat session or after IDE window reload):**
  > *"What is our current lifecycle stage and what artifact was unlocked?"*
- **Observable Criteria:**
  - [ ] Runner execution outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Next stage artifact `flow/01-research.md` is unlocked and present on disk.
  - [ ] Agent executes `bash skills/flow/runner/flow.sh status` in the fresh session and confirms stage `01-research`.
  - [ ] **Zero Residency Check:** Zero background daemons, resident server processes, or persistent background tasks remain active. State persistence is entirely disk- and git-backed.
- **Explicit Failure Outcomes:**
  - **FAIL (State Desynchronization):** A new session cannot read the unlocked stage or reports stale/corrupted lifecycle state.
  - **FAIL (Artifact Mutation):** The agent corrupts or deletes lifecycle receipts or stages during readback.
  - **FAIL (Daemon Residency Breach):** A lingering Flow background process or memory server is detected after workflow completion (violating ADR-0001).
- **Verdict:** `[HISTORICAL / DEPRECATED: PROJECT INACTIVE — LIVE TRIALS NOT RECOMMENDED]`

---

## Section 5: Qualification Archival & Next Steps

### 5.1 Evidence Archival Requirement
Before Void Editor (Agent Mode) may be upgraded from `Proposed Design Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active Void Editor session on a real developer workstation.
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/void-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: Void Editor release version, underlying VS Code base version, active model backend (e.g., Ollama model tag, vLLM version, or commercial model name), and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Upstream Rule Schema Monitoring:** Monitor upstream Void Editor developments (`voideditor/void`) for emerging formal workspace rule specifications or native skill directory discovery standards.
2. **Interactive Host Trials:** Schedule live qualification trials on a developer workstation running Void Editor paired with both local (Ollama) and cloud model endpoints.
3. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
