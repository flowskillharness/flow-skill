# Harness Intake Evaluation: PearAI (Open-Source AI Code Editor)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Workspace Instruction Scaffolding for PearAI Creator/Agent) & Unassessed / Deferred (PearAI Inline Code Editing)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - `AGENTS.md`
- **Vendor References:**
  - PearAI Official Site: https://trypear.ai (accessed 2026-10-15)
  - PearAI GitHub Repository: https://github.com/trypear/pearai-submodule (Open Source Apache-2.0 / Fork of VS Code, accessed 2026-10-15)
  - PearAI Documentation: https://trypear.ai/docs (accessed 2026-10-15)

---

## Executive Summary & Overview Table

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              PEARAI EVALUATION SUMMARY                                 │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Proposed Workspace Instruction Scaffolding  │
│                              │ for PearAI Creator/Agent) & Unassessed / Deferred       │
│                              │ (Inline Code Editing)                                   │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized workspace context / prompt instructions /  │
│                              │ repository root AGENTS.md (no verified schema; no Flow  │
│                              │ template)                                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Open-Source Developer IDE (VS Code fork with Chat &     │
│                              │ Creator/Agent modes; local workspace)                   │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal command tool in Creator/Agent     │
│                              │ mode (Flow gate-stop fidelity and return-code capture   │
│                              │ unverified in live trials)                              │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)    │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Architectural Classification** | Category B (Proposed Workspace Instruction Scaffolding for PearAI Creator/Agent) & Unassessed / Deferred (Inline Code Editing) |
| **Ingestion Mechanism** | Hypothesized workspace context / prompt instructions / repository root `AGENTS.md` (no verified schema; no Flow template) |
| **Execution Environment** | Open-Source Developer IDE (VS Code fork with Chat & Creator/Agent modes; local workspace) |
| **Tool Execution API** | Hypothesized terminal command tool in Creator/Agent mode (Flow gate-stop fidelity and return-code capture unverified in live trials) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)` |

---

## Section 1: Executive Summary & Modality Separation

### 1.1 Executive Summary & "Support Thật" Qualification Status
PearAI (developed by the PearAI open-source project, backed by Y Combinator W24; official portal: https://trypear.ai, source repository: https://github.com/trypear/pearai-submodule under Apache-2.0, documentation: https://trypear.ai/docs, accessed 2026-10-15) is an open-source AI-native code editor created as a fork of Microsoft Visual Studio Code. PearAI positions itself as an open-source, transparent alternative to closed AI IDEs (such as Cursor and Windsurf), integrating technologies from the open-source AI tooling ecosystem—notably Continue (for chat, codebase indexing, and context providers) and Roo Code / Roo Clinic (adapted for agentic creation and multi-file workflows as "PearAI Creator")—while allowing developers to customize model providers (Anthropic Claude, OpenAI, Perplexity, OpenRouter, and self-hosted models via Ollama or LM Studio).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Proposed Workspace Instruction Scaffolding for PearAI Creator/Agent) & Unassessed / Deferred (PearAI Inline Code Editing)**.
- **Qualification Status:** **`PROPOSED DESIGN CANDIDATE (Desk Intake Complete; Live Host Trials Pending)`**.
- **Qualification Rationale:**
  - PearAI operates as an open-source desktop IDE based on VS Code, running locally on the developer's workstation.
  - PearAI provides two distinct functional modalities that must be segregated under Flow's qualification taxonomy:
    1. **PearAI Creator / Agent Mode:** An agentic workflow for task planning and multi-file code generation adapting Continue and Roo technologies. While terminal command execution is hypothesized in desk review, its active loop, integer exit code capture ($0$/$1$), and gate-stop fidelity remain unverified hypotheses. Classified as a **Category B (Proposed Workspace Instruction Scaffolding)** candidate.
    2. **PearAI Inline Code Editing:** An in-buffer text modification and diff generation interface (invoked via keyboard shortcuts such as `Cmd+I` / `Ctrl+I`) alongside tab-based autocomplete. Inline Code Editing performs fast in-buffer text modifications outside Flow's build-gate integration scope; broader tool capabilities remain unassessed pending dedicated verification. Classified as **Unassessed / Deferred**.
  - **Distinction from Category A:** Desk review of PearAI documentation and source repositories found no documented native skill directory standard (such as the universal `~/.agents/skills/` specification or Claude Code's `~/.claude/skills/`). PearAI does not auto-discover standalone `SKILL.md` bundles from global user directories. Prospective integration relies on workspace instruction injection or repository root `AGENTS.md`.
  - **Strict Locking of `flow rules`:** Flow's CLI rule generator is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), verified by `tests/test_flow_rules.sh`. **No dedicated PearAI template exists in `flow rules`.** Attempting `flow rules pearai` exits with status `2` (`unknown harness`).
  - In strict compliance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising "PearAI support" without empirical verification of its terminal execution loop, return-code inspection, and gate-stop fidelity constitutes marketing deception ("quảng cáo ảo").
  - Full qualification requires an interactive host session executing the Four-Point Live Verification Protocol with raw tool transcripts, terminal payloads, integer exit codes, and on-disk receipts committed to `plans/research/harness-expansion/evidence/`.

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with PearAI Creator / Agent Mode aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation or inside the PearAI IDE process. Even when PearAI connects to local model inference services (such as Ollama or vLLM daemons), Flow must never execute as a resident daemon or in-memory service. Flow executes strictly as an ephemeral executable via `skills/flow/runner/flow.sh` (or `flow.cmd` on native Windows).
2. **Process Token Ownership:** The PearAI IDE host and Creator/Agent runtime hold the process token and manage the conversational event loop. Flow executes strictly as an ephemeral subprocess invoked via terminal commands, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept PearAI's internal model streams, extension APIs, or tool dispatch mechanics. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostic output.
5. **Rejection of Resident Daemons or Language Server Wrappers:** Attempting to wrap Flow inside an in-memory extension service, background daemon, or persistent MCP process is constitutionally prohibited under ADR-0001. Flow's state lives strictly on disk in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Modality Separation: PearAI Creator / Agent Mode vs. PearAI Inline Code Editing

PearAI encompasses two primary operational modalities that must be strictly separated under Flow's harness qualification taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              PEARAI MODALITY SEPARATION                                │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: PearAI Creator / Agent Mode  │ Modality 2: PearAI Inline Code Editing      │
│ (Category B: Proposed Workspace Scaffold)│ (Unassessed / Deferred)                     │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: PearAI Creator / Agent UI   │ Environment: Active editor buffer / inline  │
│ sidebar panel (local workspace)          │ edit prompt widget (Cmd+I / Ctrl+I)         │
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

#### Modality 1: PearAI Creator / Agent Mode (Category B: Proposed Workspace Scaffolding)
- **Operational Scope:** Multi-turn conversational interaction, task decomposition, multi-file codebase edits, and agentic workflows.
- **Rule Ingestion:** Evaluated via hypothesized workspace context, system prompt configuration, or repository root `AGENTS.md` (no proprietary schema verified; no Flow template).
- **Tool Execution:** Hypothesized terminal command execution tool allowing the assistant to execute build, test, and lifecycle commands in the workspace environment (unverified in Flow live trials).
- **Classification:** Category B (Proposed Workspace Instruction Scaffolding).

#### Modality 2: PearAI Inline Code Editing (Unassessed / Deferred)
- **Operational Scope:** In-buffer quick code generation, localized refactoring, diff preview, and autocomplete ghost text.
- **Integration Scope:** Fast in-buffer edits outside Flow build-gate integration scope; broader tool capabilities unassessed pending dedicated verification.
- **Classification:** Unassessed / Deferred (Inline Code Editing).

### 1.4 Why Category B (Proposed Workspace Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** natively auto-discover directory-based skill bundles containing `SKILL.md` from a standard host location (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or universal agents reading `~/.agents/skills/flow`).

PearAI does **not** qualify as Category A:
1. **Absence of Directory-Based Skill Discovery:** Desk review of PearAI documentation and source code confirms that PearAI does not implement directory-based skill discovery conforming to the universal Agent Skills standard (`~/.agents/skills/`) or vendor-specific directories (`~/.claude/skills/`).
2. **Reliance on Injected Instructions:** PearAI relies on workspace prompt context, extension configuration, or repository documentation files (such as root `AGENTS.md`).
3. **Disclosure Mandate:** Under Flow's harness taxonomy (`docs/harness-qualification-process.md` §5.3), integrations lacking native global skill discovery must be classified strictly as **Category B: Workspace Rule Scaffolding**, never as a Native Skill Target.

### 1.5 Strict Locking of `flow rules` Dispatcher (Absence of PearAI Template)
Flow's `flow rules` generator is strictly locked to **seven verified harness templates**:
- `cursor` (`.cursor/rules/flow.mdc`)
- `windsurf` (`.windsurf/rules/flow.md`)
- `roo` (`.roomodes`)
- `cline` (`.clinerules`)
- `aider` (`.aider.conf.yml`)
- `openhands` (`.openhands/microagents/flow.md`)
- `copilot` (`.github/copilot-instructions.md`)

This invariant is verified by `tests/test_flow_rules.sh`. **No dedicated PearAI template exists in `flow rules`.** Attempting `flow rules pearai` exits 2 (`unknown harness`). Until an official rule configuration schema is documented by PearAI and verified in live trials, Flow will not add a speculative template. Prospective integration relies on repository-root `AGENTS.md` and manual workspace prompt instructions.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization (Qualitative Desk Hypotheses)

In strict adherence to `docs/harness-qualification-process.md` §1.1, arbitrary numeric scores are withheld until live empirical trials provide quantifiable metrics. Desk hypotheses are labeled as qualitative desk assessments:

- **Open-Source Ecosystem & Backing:** PearAI is an open-source AI code editor launched out of Y Combinator (W24). As an open-source fork of Visual Studio Code (Apache-2.0), PearAI integrates and adapts established open-source AI tooling technologies—notably Continue (for chat, context indexing, codebase search, and prompt UI) and Roo Code / Roo Clinic (for the agentic "PearAI Creator" mode). PearAI offers native configuration for multiple model backends, including commercial APIs (Anthropic Claude, OpenAI, Perplexity, OpenRouter) and local inference servers (Ollama, LM Studio).
- **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
  1. **Market Adoption Hypothesis:** Open-source alternative to Cursor seeking community adoption through YC (W24) backing. Quantitative market share and verified active installation numbers remain unassessed in desk review.
  2. **Agentic Autonomy Hypothesis:** PearAI Creator incorporates multi-file editing and task planning concepts derived from Roo Code / Continue lineages. However, actual terminal command execution, autonomous subshell control, integer return-code inspection, and strict gate-stop fidelity ($\text{exit} \neq 0$) remain unverified desk hypotheses pending Flow live trials.
  3. **Ecosystem Openness Hypothesis:** Fully open-source codebase on GitHub (`trypear/pearai-submodule`), transparent Apache-2.0 licensing, and support for open model endpoints and local inference engines.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)**.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Process Token Ownership & Execution Loop
- In prospective PearAI Creator / Agent workflows, the developer and the PearAI IDE host hold the process token.
- Flow remains completely external to the event loop. Flow is never an owned runner or resident process; it executes strictly when PearAI Creator dispatches a subshell command invoking `runner/flow.sh` (or `runner/flow.cmd`).
- Flow executes deterministically, writes receipts to disk, and terminates immediately upon returning its exit status code to the shell.

#### 2.2.2 Tool Execution API & Terminal Subshell Handling (Desk Hypothesis)
- In desk review, PearAI Creator / Agent mode is hypothesized to provide a terminal execution tool allowing the model to propose and execute shell commands within the workspace terminal.
- **Fidelity Question:** Does PearAI Creator capture exact integer exit codes ($0$ vs. non-zero) and feed stderr diagnostics back into the model's active reasoning context?
- Under Flow's discipline, if an assistant merely suggests a command for the human developer to click and run without mechanically inspecting the result, it cannot enforce stage gates. Live host verification must prove whether the agent autonomously invokes the runner and observes the return code.

#### 2.2.3 Instruction Ingestion & Workspace Context
- PearAI does not publish an official, verified proprietary configuration schema for agent rule scaffolding (such as Cursor's `.cursor/rules/*.mdc` or Windsurf's `.windsurf/rules/*.md`).
- Prospective instruction ingestion is hypothesized to occur via:
  1. Manual prompt context provided in Creator / Chat sessions.
  2. Workspace context indexing where PearAI's context engine ingests repository markdown files such as `AGENTS.md`.
  3. Extension configuration mechanisms inherited from Continue (`config.json` / `config.yaml`) or Roo Code (`.roomodes`), though no official PearAI-branded schema has been standardized or verified for Flow.
- **Anti-Illusion Disclosure:** No empirical trial has confirmed that PearAI automatically loads or strictly enforces instructions from `AGENTS.md`. Ingestion behavior remains an unverified hypothesis.

#### 2.2.4 Context Budgeting & Token Dynamics
- PearAI supports diverse model backends, ranging from high-capacity frontier models (Claude 3.7 Sonnet, GPT-4o) to compact local models (Llama 3 8B, Qwen 2.5 7B via Ollama).
- Context windows on local models are constrained, making prompt dilution and attention decay acute risks if monolithic rules are injected.
- To prevent prompt dilution, Flow instructions must remain compact and modular, relying on the **Progressive Disclosure Architecture** (`skills/flow/references/gate-rules.md` and stage playbooks) rather than injecting monolithic rule catalogs.

#### 2.2.5 Architectural Execution Model: Local IDE Workspace, Ephemeral Subshell Execution, Zero Flow Daemons (ADR-0001)
- **Local Workspace Execution:** PearAI executes locally on the developer's workstation. All file modifications and tool executions take place directly within the local workspace directory.
- **Ephemeral Subshell Execution:** Commands dispatched by PearAI Creator execute in an ephemeral subshell environment. Invocations of `skills/flow/runner/flow.sh` run as discrete subprocesses, returning integer status codes ($0$ or $1$) and terminating upon completion.
- **Zero Flow Daemons:** In strict compliance with ADR-0001, Flow runs zero background daemons, zero resident services, and zero in-memory listeners. All Flow state resides on disk in Git and bounded filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion (Creator / Agent Mode vs. Inline Code Editing)
- **The Pitfall:** Promoting Flow as "supporting PearAI" without distinguishing between PearAI Creator (Agent Mode) and Inline Code Editing. A developer invokes PearAI's inline editing widget (`Cmd+I` / `Ctrl+I`) or autocomplete and expects Flow stage gates to be enforced automatically.
- **The Grounded Technical Reality:** Inline Code Editing operates strictly within the active editor buffer, performing fast localized text diffs and completions without autonomous multi-turn conversational loops or terminal tool execution capabilities. It cannot invoke Flow runners or inspect exit codes.
- **The Anti-Illusion Mitigation:** Documentation and evaluation records must explicitly state that Flow compatibility is evaluated strictly for **PearAI Creator / Agent Mode** (Category B candidate), whereas Inline Code Editing is **Unassessed / Deferred** and outside Flow's build-gate integration scope.

### 3.2 Latent Trap 2: Absence of Dedicated `flow rules` Template (The "Zed Lesson" & Anti-Illusion Trap)
- **The Pitfall:** Falling into the "Zed Lesson" trap (`docs/harness-qualification-process.md` §2.1) by inventing a fictional configuration file (e.g., generating `.pearai/rules.json`, `.pearairules`, or `.pearaiprompt`) via a speculative `flow rules pearai` command.
- **The Grounded Technical Reality:**
  - Official PearAI documentation does not specify or parse any such proprietary rule file.
  - Flow's `flow rules` dispatcher is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), as verified by `tests/test_flow_rules.sh`.
  - Creating phantom configuration files creates the illusion of support ("quảng cáo ảo"), misleading developers into believing their agent is constrained when the editor completely ignores the file.
- **The Anti-Illusion Mitigation:** Flow strictly refuses to generate unverified configuration files. Prospective PearAI integration relies on documented, generic workspace instructions (`AGENTS.md`) and manual prompt configuration until vendor documentation defines an official, verified schema.

### 3.3 Latent Trap 3: Strict Prohibition of Flow Background Daemons (ADR-0001 Violation)
- **The Pitfall:** Attempting to bridge Flow and PearAI by running a persistent local daemon, an in-memory MCP server daemon, or a resident background process that intercepts IDE commands.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly prohibits resident daemons, background processes, or servers.
  - Long-lived processes introduce cache invalidation bugs, stale state across git branches, memory leaks, and concurrency hazards.
- **The Anti-Illusion Mitigation:** Flow executes strictly as an ephemeral CLI subprocess. Each invocation (`flow.sh status`, `flow.sh next`, `flow.sh check`) executes independently, writes deterministic receipts to disk, and immediately exits. Zero resident memory state is permitted.

### 3.4 Latent Trap 4: Project-Local Runner Requirement (`skills/flow/runner/flow.sh`)
- **The Pitfall:** Instructing PearAI to execute a global runner path (such as `~/.agents/skills/flow/runner/flow.sh` or `~/.claude/skills/flow/runner/flow.sh`) that may not exist on the user's workstation or across diverse developer environments.
- **The Grounded Technical Reality:** Because PearAI does not implement Category A native skill discovery, global skill directories may not be installed. Referencing global paths results in immediate `ENOENT: No such file or directory` shell failures.
- **The Anti-Illusion Mitigation:** Workspace scaffolding instructions must mandate invoking the project-vendored runner tree:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
  On Windows environments, the command must use `skills\flow\runner\flow.cmd` or Git Bash.

### 3.5 Latent Trap 5: Synthesized Pass Hallucinations & Gate Bypass in Conversational Chat
- **The Pitfall:** In conversational chat or semi-autonomous agent execution, when an agent encounters a non-zero exit code or lacks execution permissions, it may attempt to be helpful by declaring the task complete (e.g., *"Stage 00 looks complete; advancing to Stage 01!"*).
- **The Grounded Technical Reality:** An LLM cannot pass a Flow gate by stating it passed. A gate pass is valid if and only if Flow's mechanical engine executed, verified evidence on disk, and returned exit code $0$, generating authenticated filesystem receipts.
- **The Anti-Illusion Mitigation:** Workspace instructions must explicitly mandate an inviolable negative constraint:
  > *"NEVER declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing exit code 0. If terminal tools are unavailable, STOP immediately and inform the operator."*

---

## Section 4: Complete 4-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of PearAI in an active IDE execution session. The trial uses a neutral probe protocol with explicit failure outcomes.

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
   git clone <repo-url> /tmp/flow-pearai-eval
   cd /tmp/flow-pearai-eval
   git checkout -b test/pearai-qualification
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
   - Open `/tmp/flow-pearai-eval` in the PearAI IDE with PearAI Creator / Agent mode enabled and configured with an active model provider.

---

### 4.2 Gate 1: Ingestion Audit (Canary Query)

- **Test Objective:** Verify that PearAI Creator ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Neutral Probe Query (issued to PearAI Creator / Agent Chat):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly identifies Flow as the governing development discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands or reference unsupported global paths.
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - **FAIL (Schema Error / Ingestion Failure):** PearAI fails to index or recognize workspace instructions from `AGENTS.md` or prompt context.
  - **FAIL (Context Truncation):** Agent ignores Flow discipline, hallucinates an alternative development methodology, or exhibits severe prompt dilution.
  - **FAIL (Command / Path Hallucination):** Agent invents non-existent CLI tools (e.g., `pearai flow check`) or cites unmapped global paths.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit (Status Check via Terminal)

- **Test Objective:** Verify that PearAI Creator actively dispatches and executes the Flow runner via its terminal execution tool, captures the integer exit code, and reads stdout/stderr.
- **Neutral Probe Query (issued to PearAI Creator / Agent Chat):**
  > *"Check the status of the current build lifecycle using your terminal execution tool."*
- **Observable Criteria:**
  - [ ] Agent dispatches an active tool call to execute `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the workspace environment without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.
- **Explicit Failure Outcomes:**
  - **FAIL (Terminal Execution Unavailable / Unprompted Suggestion Only):** PearAI merely prints markdown text suggesting the user run the command manually, without possessing or invoking an autonomous terminal execution tool.
  - **FAIL (Path Resolution Failure / ENOENT):** The dispatched command fails with `ENOENT: No such file or directory` or attempts to execute in an incorrect working directory.
  - **FAIL (Output Truncation / Exit Code Loss):** The IDE drops stdout or fails to receive the return code, leaving the agent unable to report lifecycle status.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), PearAI Creator strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Neutral Probe Query (issued to PearAI Creator / Agent Chat):**
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

### 4.5 Gate 4: State Persistence Audit (State Integrity & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh agent session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Neutral Probe Query (In a new PearAI Creator session or after IDE window reload):**
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
Before PearAI may be upgraded from `Proposed Design Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active PearAI IDE session.
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/pearai-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: PearAI IDE version, model identifier, and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Rule Ingestion Research:** Monitor PearAI releases to determine if PearAI introduces a formal, stable project-level rule configuration schema (or adopts `.cursor/rules/*.mdc`, `.windsurf/rules/*.md`, or universal `AGENTS.md`).
2. **Terminal Tool Execution Evaluation:** Empirically evaluate whether PearAI Creator's terminal execution tool supports autonomous execution with strict exit-code return or requires manual user confirmation for each command.
3. **Template Policy Compliance:** Maintain the strict invariant that `flow rules` is locked to its 7 verified templates; do not introduce an unverified PearAI template until empirical live trials satisfy all qualification gates.
4. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
