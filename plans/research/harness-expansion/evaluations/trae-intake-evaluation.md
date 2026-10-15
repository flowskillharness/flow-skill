# Harness Intake Evaluation: Trae (Adaptive AI IDE, Native Skills & Agent Mode)

- **Document Version:** 1.1.0
- **Evaluation Status:** `Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Dual Category A (Proposed Native Skill Target: `~/.trae/skills/`, `.trae/skills/`) / Category B (Proposed Workspace / Project Rules Scaffolding for Agent Mode (formerly Builder): `.trae/rules/`, `~/.trae/user_rules`) & Unassessed / Deferred (Inline Code Completion)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
- **Vendor References:**
  - Trae Official Portal: https://www.trae.ai (ByteDance, accessed 2026-10-15)
  - Trae Documentation: https://docs.trae.ai (accessed 2026-10-15)
---

## Executive Summary & Overview Table

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                             TRAE INTAKE EVALUATION SUMMARY                             │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Dual-Path: Category A (Proposed Native Skill Target:    │
│                              │ ~/.trae/skills/, .trae/skills/) / Category B (Proposed  │
│                              │ Project Rules: .trae/rules/, ~/.trae/user_rules) &      │
│                              │ Unassessed / Deferred (Inline Completions)              │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (Cat A)  │ Documented native dynamic skill discovery:              │
│                              │ ~/.trae/skills/<skill>/SKILL.md (global) or             │
│                              │ .trae/skills/<skill>/SKILL.md (project-level folders)   │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (Cat B)  │ Documented project rules directory .trae/rules/*.md or   │
│                              │ global ~/.trae/user_rules (plus root AGENTS.md)         │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Developer IDE (VS Code-based IDE with Chat & Agent      │
│                              │ Mode; local workspace or remote SSH)                    │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Vendor-documented terminal command execution in Agent   │
│                              │ Mode (Flow gate-stop fidelity unverified in live        │
│                              │ trials)                                                 │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)    │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Architectural Classification** | Dual Category A (Proposed Native Skill Target: `~/.trae/skills/`, `.trae/skills/`) / Category B (Proposed Project Rules: `.trae/rules/`, `~/.trae/user_rules`) & Unassessed / Deferred (Inline Completions) |
| **Ingestion Mechanism (Cat A)** | Documented native dynamic skill discovery: `~/.trae/skills/<skill>/SKILL.md` (global; Windows `%userprofile%/.trae/skills`) or `.trae/skills/<skill>/SKILL.md` (project) |
| **Ingestion Mechanism (Cat B)** | Documented project rules directory `.trae/rules/*.md` or global `~/.trae/user_rules` (plus workspace context / root `AGENTS.md`) |
| **Execution Environment** | Developer IDE (VS Code-based IDE with Chat & Agent Mode; local workspace or remote SSH) |
| **Tool Execution API** | Vendor-documented terminal command execution in Agent Mode (Flow gate-stop fidelity unverified in live trials) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `PROPOSED DESIGN CANDIDATE (Desk Intake Complete; Live Host Trials Pending)` |
---

## Section 1: Executive Summary & Modality Separation

### 1.1 Executive Summary & "Support Thật" Qualification Status
Trae (developed by ByteDance; official portal: https://www.trae.ai, documentation: https://docs.trae.ai, accessed 2026-10-15) is an adaptive AI-native integrated development environment built on top of a customized Visual Studio Code core. Current official Trae documentation identifies a unified development environment featuring **Agent Mode** (the autonomous agent capability, formerly named "Builder" or "Builder Mode" in early preview releases before being merged into Agent Mode) alongside **IDE Mode** (conversational Chat and editor with inline completions). Agent Mode is designed to execute multi-step software engineering workflows across local workspace directories or remote SSH environments, spanning multi-file code modifications and integrated terminal command execution, alongside first-party native skill dynamic discovery (`SKILL.md`). Flow executes within this environment strictly as an ephemeral project-local runner (`skills/flow/runner/flow.sh`) in the active shell environment.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Dual Category A (Proposed Native Skill Target: `~/.trae/skills/`, `.trae/skills/`) / Category B (Proposed Workspace / Project Rules Scaffolding for Agent Mode (formerly Builder): `.trae/rules/`, `~/.trae/user_rules`) & Unassessed / Deferred (Trae Inline Completions)**.
- **Similar to Cursor:** Trae presents a dual-path architecture directly comparable to Cursor (Dual Category A `~/.cursor/skills/` and Category B `.cursor/rules/*.mdc`).
- **Category A Hypothesis:** Trae dynamically discovers `SKILL.md` at `~/.trae/skills/flow/` or `.trae/skills/flow/`.
- **Category B Hypothesis:** Trae Agent Mode ingests `.trae/rules/flow.md` (or `~/.trae/user_rules` / `AGENTS.md`) and executes project-local runner `skills/flow/runner/flow.sh` in the active shell environment (local workspace or remote SSH) via terminal tool.
- **Qualification Status:** **`PROPOSED DESIGN CANDIDATE (Desk Intake Complete; Live Host Trials Pending)`**.
- **Qualification Rationale:**
  - Trae operates as a standalone AI IDE based on the VS Code architecture, providing distinct operational modalities: an interactive Chat interface, an inline real-time code completion engine, autonomous Agent Mode (formerly Builder Mode) capable of editing code across local workspace directories or remote SSH environments and dispatching terminal commands, and native `SKILL.md` dynamic discovery.
  - Desk review of official Trae documentation confirms that Trae natively documents first-party skill discovery where skills are standard folders containing `SKILL.md`:
    - Global skills: `~/.trae/skills/<skill>/SKILL.md` (Windows: `%userprofile%/.trae/skills/<skill>/SKILL.md`)
    - Project skills: `.trae/skills/<skill>/SKILL.md`
  - Trae documentation further documents project-level rules at `.trae/rules/*.md` and global user rules at `~/.trae/user_rules`.
  - While terminal command execution and skill/rule discovery are documented vendor capabilities in Trae, the harness's actual runtime behavior when executing Flow—specifically whether it dynamically loads Flow's `SKILL.md`, reliably inspects integer return codes ($0$ vs. non-zero), halts unconditionally on gate failures ($\text{exit} \neq 0$), and refrains from hallucinating gate progression—remains an **unverified desk hypothesis**.
  - In strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising "Trae support" without empirical verification of its tool execution loop, skill discovery, and gate-stop fidelity constitutes marketing deception ("quảng cáo ảo").
  - Flow's `flow rules` dispatcher is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), verified by `tests/test_flow_rules.sh`. **No dedicated Trae template currently exists in `flow rules`.** Ingestion of `.trae/rules/` and `.trae/skills/` must be verified in live trials before recommending either as supported or adding a template.
  - Full qualification requires an interactive host session executing the Two-Arm Live Verification Protocol with raw tool transcripts, integer exit codes, and on-disk receipts archived to `plans/research/harness-expansion/evidence/`.

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with Trae Agent Mode aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation or inside the IDE. While Trae utilizes local IDE processes and cloud AI service backends, Flow must never execute as a resident service inside or alongside that machinery. Flow executes strictly as an ephemeral executable via `skills/flow/runner/flow.sh` (or `flow.cmd` on native Windows).
2. **Process Token Ownership:** The IDE host and Trae runtime hold the process token and manage the agentic event loop. Flow executes strictly as an ephemeral subprocess invoked via terminal commands, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Trae's internal tool dispatch pipeline, language server features, or cloud communications. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Rejection of Resident Daemons or Memory Wrappers:** Attempting to wrap Flow inside an in-memory language server wrapper, persistent daemon, or background execution service is constitutionally prohibited under ADR-0001. Flow's state lives strictly on disk in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Modality Separation: Trae Skills & Agent Mode vs. Inline Code Completion

Trae encompasses two primary functional modalities that must be strictly separated under Flow's harness qualification taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              TRAE MODALITY SEPARATION                                  │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: Trae Skills & Agent Mode     │ Modality 2: Trae Inline Code Completion     │
│ (Dual Category A / Category B Candidate) │ (Unassessed / Deferred)                     │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: Trae IDE Agent Mode &       │ Environment: Editor active buffer /         │
│ dynamic skill runtime (local/remote SSH) │ ghost text suggestions                      │
│ Ingestion (Cat A): Dynamic discovery of  │ Ingestion: Active line/cursor AST &         │
│ ~/.trae/skills/ or .trae/skills/         │ local text buffer context                   │
│ Ingestion (Cat B): Project rules         │                                             │
│ .trae/rules/*.md or ~/.trae/user_rules   │                                             │
│ Agent Loop: Multi-turn autonomous task   │ Agent Loop: Passive next-token prediction   │
│ planning & multi-file code editing       │ (No agentic conversational loop)            │
│ Tool API: Vendor-documented terminal     │ Tool API: Outside Flow build-gate scope;    │
│ command execution in integrated terminal │ broader tool capabilities unassessed        │
│ Status: Proposed Design Candidate        │ Status: Unassessed / Deferred               │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: Trae Native Skills & Agent Mode (formerly Builder Mode) — Dual Category A / Category B Candidate
- **Environment:** Trae IDE Agent Mode (local workspace or remote SSH) and agentic skill runtime.
- **Operational Scope:** Operates as an autonomous task executor across workspace directories or remote SSH environments capable of discovering skills, creating plans, performing multi-file code edits, and running commands in the integrated terminal to build, run, and test code.
- **Path 1 — Category A Native Skill Target:** Trae natively documents dynamic discovery of standard skill folders containing `SKILL.md`:
  - Global skills: `~/.trae/skills/<skill>/SKILL.md` (Windows: `%userprofile%/.trae/skills/<skill>/SKILL.md`)
  - Project skills: `.trae/skills/<skill>/SKILL.md`
- **Path 2 — Category B Project Rules Scaffolding:** Trae officially documents rule ingestion from:
  - Project rules: `.trae/rules/*.md` (e.g., `.trae/rules/flow.md`)
  - Global user rules: `~/.trae/user_rules`
  - Repository workspace context (e.g., root `AGENTS.md`)
- **Tool Execution:** Vendor-documented terminal command execution in Agent Mode. Flow gate-stop fidelity ($0$ vs. non-zero exit codes) and return-code capture remain unverified in live host trials.
- **Classification:** Dual Category A (Proposed Native Skill Target) / Category B (Proposed Project Rules Scaffolding).

#### Modality 2: Trae Inline Code Completion — Unassessed / Deferred
- **Environment:** Active editor text buffer triggered by typing and cursor navigation.
- **Operational Scope:** Real-time ghost text autocomplete, single-line/multi-line code completion, and local inline edit suggestions.
- **Integration Scope:** Real-time ghost text autocomplete operates strictly at the keystroke level within the editor buffer. As a passive code completion modality, it falls outside Flow's build-gate integration scope; broader tool capabilities remain unassessed pending dedicated verification.
- **Classification:** Unassessed / Deferred (outside Flow build-gate integration scope).

### 1.4 Dual First-Party Integration Pathways: Category A Native Skills vs. Category B Rules Scaffolding
Unlike harnesses limited to generic workspace prompt files, official Trae vendor documentation explicitly specifies **two first-party integration pathways**:

1. **Category A Native Skill Target (`~/.trae/skills/`, `.trae/skills/`):**
   - Trae natively documents dynamic discovery of directory-based skill bundles containing `SKILL.md`:
     - **Global Skills:** `~/.trae/skills/<skill>/SKILL.md` (Windows: `%userprofile%/.trae/skills/<skill>/SKILL.md`)
     - **Project Skills:** `.trae/skills/<skill>/SKILL.md`
   - Under Trae's vendor specification, skills are standard folders containing a `SKILL.md` description file. This aligns directly with the open Agent Skills standard (`SKILL.md`) adopted across modern coding agents.
   - **Hypothesis:** Installing Flow to `~/.trae/skills/flow/` or `.trae/skills/flow/` allows Trae to dynamically discover Flow's capabilities and invoke Flow's runner directly.
2. **Category B Project Rules Scaffolding (`.trae/rules/*.md`, `~/.trae/user_rules`):**
   - Trae documentation explicitly defines dedicated rule configuration pathways:
     - **Project Rules:** `.trae/rules/` (markdown files such as `.trae/rules/flow.md` scoped to the workspace).
     - **Global User Rules:** `~/.trae/user_rules` (global user-level rules across workspaces).
   - **Hypothesis:** Placing Flow discipline instructions in `.trae/rules/flow.md` instructs Trae Agent Mode to invoke the project-local Flow runner (`skills/flow/runner/flow.sh`) via its terminal execution tool in the active shell environment (local workspace or remote SSH).
3. **Architectural Parity with Cursor:**
   - Trae's dual support for native skills (`~/.trae/skills/`, `.trae/skills/`) and project rules (`.trae/rules/`, `~/.trae/user_rules`) mirrors Cursor's dual-path architecture (`~/.cursor/skills/` for Category A and `.cursor/rules/*.mdc` for Category B).
   - Consequently, Trae is classified as a priority dual-path candidate: **Dual Category A (Proposed Native Skill Target) / Category B (Proposed Workspace / Project Rules Scaffolding for Agent Mode (formerly Builder))**.

### 1.5 Strict Locking of `flow rules` & Anti-Illusion Verification
While Trae officially documents `.trae/rules/` and `~/.trae/user_rules`, Flow strictly rejects premature or speculative template generation.

A primary failure mode identified in Flow's harness qualification history is the "Zed Lesson" (`docs/harness-qualification-process.md` §2.1): generating unverified configuration files via a speculative CLI template command before empirical host verification proves the harness honors them.

Flow strictly enforces template locking:
- Flow's `flow rules` dispatcher is strictly locked to **seven verified harness templates**:
  1. `cursor` (`.cursor/rules/flow.mdc`)
  2. `windsurf` (`.windsurf/rules/flow.md`)
  3. `roo` (`.roomodes`)
  4. `cline` (`.clinerules`)
  5. `aider` (`.aider.conf.yml`)
  6. `openhands` (`.openhands/microagents/flow.md`)
  7. `copilot` (`.github/copilot-instructions.md`)
- This lock is mechanically verified by `tests/test_flow_rules.sh`, which confirms that `flow rules list` outputs exactly these 7 supported harnesses and exits with status 2 for any unrecognized harness.
- **No Trae template currently exists in `flow rules`.**
- Creating phantom configuration files creates the illusion of support ("quảng cáo ảo"), misleading developers into believing their agent is constrained when the IDE might ignore or misinterpret the file.
- Ingestion of `.trae/rules/` and `.trae/skills/` must be verified in live empirical trials before recommending either as supported or introducing a dedicated Trae template into `flow rules`.
---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization (Qualitative Assessment)
In accordance with Flow's "Support Thật" discipline, arbitrary numeric scores are withheld pending empirical live trials. The candidate is evaluated through qualitative desk hypotheses:

- **Market Adoption Hypothesis:** Rapidly emerging AI-native IDE developed by ByteDance, gaining significant mindshare among software engineers seeking an integrated AI workspace with built-in agentic capabilities. Built on the familiar Visual Studio Code foundation, Trae lowers adoption barriers while offering built-in Chat, Inline Completion, and Agent Mode (formerly Builder Mode) competing with Cursor and Windsurf.
- **Agentic Autonomy Hypothesis:** Trae Agent Mode provides autonomous multi-turn loops, multi-file code editing, and automated terminal command execution across local workspace directories or remote SSH environments. However, whether Agent Mode genuinely observes integer exit codes ($0$ vs. non-zero), halts unconditionally upon gate failures, and resists synthesizing false passes remains an unverified desk hypothesis.
- **Ecosystem Openness Hypothesis:** Proprietary standalone IDE based on a VS Code fork with documented native extensibility. Trae officially documents dynamic skill discovery conforming to the open `SKILL.md` format at user-global (`~/.trae/skills/` / Windows `%userprofile%/.trae/skills`) and project-local (`.trae/skills/`) paths. Additionally, Trae documents first-party rule scaffolding via workspace `.trae/rules/*.md` and user-global `~/.trae/user_rules`. Live empirical trials must verify whether Trae Agent Mode genuinely indexes, parses, and acts upon these files during agent runs.
- **Prioritization Status & Hypothesis:** **`Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`**.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Process Token Ownership & Main Event Loop
- In prospective Trae workflows, the developer workstation (or remote SSH host) and the Trae IDE extension host / Agent Mode runtime hold the process token.
- Trae manages the conversational agent loop, user interaction, and tool dispatch scheduler.
- Flow remains completely external to the event loop. Flow is never an owned runner or long-running service; it executes strictly as an ephemeral project-local runner (`skills/flow/runner/flow.sh` or `flow.cmd`) in the active shell environment when Trae's Agent Mode dispatches a subshell command.
- Flow terminates immediately upon returning its exit status code to the shell.

#### 2.2.2 Tool Execution API & Terminal Subshell Handling (Desk Hypothesis)
- Trae documentation highlights Agent Mode's ability to run terminal commands to install dependencies, run build scripts, execute test suites, and debug applications in the IDE's integrated terminal across local workspace directories or remote SSH environments.
- **Fidelity Question:** Does Trae Agent Mode execute terminal commands autonomously, capture exact integer exit codes ($0$ vs. non-zero), and feed stderr diagnostics back into the model's active reasoning context for error correction?
- Under Flow's discipline, if an assistant merely suggests a command for the human developer to click and run without mechanically inspecting the result, or if it executes commands without checking exit codes, it cannot enforce stage gates. Live host verification must prove whether the agent autonomously invokes the runner and observes the return code.

#### 2.2.3 Instruction Ingestion & Workspace Context
- Trae officially documents two configuration layers alongside general workspace context:
  1. **Category A Native Skill Discovery:** Trae natively discovers directory-based skills containing `SKILL.md` from project-local `.trae/skills/<skill>/` and user-global `~/.trae/skills/<skill>/` (Windows `%userprofile%/.trae/skills/<skill>/`).
  2. **Category B Project & User Rules:** Trae documents project-level rules at `.trae/rules/*.md` (e.g., `.trae/rules/flow.md`) and global user rules at `~/.trae/user_rules`.
  3. **Workspace Context:** General workspace context indexing where Trae ingests repository root markdown files such as `AGENTS.md`.
- **Anti-Illusion Disclosure:** While the file paths and formats are documented by the vendor, no empirical live trial has yet confirmed that Trae Agent Mode automatically discovers `.trae/skills/flow/SKILL.md` or strictly enforces constraints from `.trae/rules/flow.md`. Ingestion behavior, tool invocation fidelity, and priority order between skills and rules remain unverified hypotheses until live host trials pass.

#### 2.2.4 Context Budgeting & Truncation Dynamics
- Trae leverages cloud-hosted LLM endpoints with substantial context windows.
- However, prompt context injected into conversational or Agent Mode windows remains subject to attention limits and prompt dilution.
- To prevent prompt dilution and attention decay, Flow instructions must remain compact and modular, relying on the **Progressive Disclosure Architecture** (`skills/flow/references/gate-rules.md` and stage playbooks) rather than injecting monolithic rule catalogs.

#### 2.2.5 Execution Boundaries: Local IDE & Remote SSH vs. Cloud AI Backend
- While model inference is processed on cloud AI infrastructure, tool execution and file modifications occur within the developer's workspace (either a local directory or a remote SSH connection).
- The Flow runner (`skills/flow/runner/flow.sh`) executes ephemerally within the active shell environment (local POSIX / Git Bash or remote SSH shell). Cloud components cannot execute local runner scripts directly; all executions must run through the IDE terminal subsystem.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion — Trae Agent Mode vs. Inline Completion
- **The Pitfall:** Promoting Flow as "supporting Trae" without disambiguating the operational modality. A developer installs Trae, relies solely on inline ghost text autocomplete, and expects Flow stage gates to be enforced automatically.
- **The Grounded Technical Reality:** Inline code completion operates at the keystroke level within the editor buffer as a real-time ghost text autocomplete mechanism; broader tool execution capabilities remain unassessed pending dedicated verification, and passive autocomplete is completely outside Flow's build-gate integration scope.
- **The Anti-Illusion Mitigation:** Documentation and evaluation records must explicitly state that Flow compatibility is evaluated strictly for **Trae Agent Mode (formerly Builder Mode) and Native Skills** (Dual Category A / Category B candidate), whereas inline code completion is **Unassessed / Deferred (outside Flow build-gate integration scope)**.

### 3.2 Latent Trap 2: Vendor Rules Specification vs. Strict Locking of `flow rules`
- **The Pitfall:** Prematurely creating or advertising a `flow rules trae` command or generating `.trae/rules/flow.md` via Flow core before empirical live qualification proves that Trae Agent Mode reliably honors the file.
- **The Grounded Technical Reality:**
  - Official Trae documentation explicitly documents `.trae/rules/` and `~/.trae/user_rules`.
  - However, Flow's `flow rules` dispatcher is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), as verified by `tests/test_flow_rules.sh`.
  - Creating unverified templates violates Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §2.1) and risks the "Zed Lesson": leading developers to believe an unverified configuration file guarantees agentic discipline.
  - Ingestion of `.trae/rules/` and `.trae/skills/` must be verified in live trials before recommending either as supported or adding a Trae template to `flow rules`.
- **The Anti-Illusion Mitigation:** Maintain the strict 7-template lock on `flow rules`. For initial host trials, test rules via manually placed `.trae/rules/flow.md` (or `AGENTS.md`) and test native skills via `.trae/skills/flow/`.

### 3.3 Latent Trap 3: Strict Prohibition of Resident Daemons or Memory Wrappers (ADR-0001 Violation)
- **The Pitfall:** Attempting to bridge Flow and Trae by running a persistent local daemon, an in-memory language server wrapper, or a resident background process that intercepts IDE commands or monitors file changes.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly prohibits resident daemons, background processes, or servers: *"Flow owns the gates and the receipts, never the runtime... zero resident background daemons."*
  - Long-lived processes introduce cache invalidation bugs, stale state across git branches, memory leaks, and concurrency hazards.
- **The Anti-Illusion Mitigation:** Flow executes strictly as an ephemeral CLI subprocess. Each invocation (`flow.sh status`, `flow.sh next`, `flow.sh check`) executes independently, writes deterministic receipts to disk, and immediately exits. Zero resident memory state is permitted.

### 3.4 Latent Trap 4: Path Mapping & Execution Contract
- **The Pitfall:** Confusion between Category A skill runner resolution and Category B workspace runner invocation, or referencing nonexistent global runner paths.
- **The Grounded Technical Reality:**
  - For Category A Native Skills, Trae dynamic skill discovery locates `SKILL.md` inside `.trae/skills/flow/` or `~/.trae/skills/flow/`. The skill bundle must contain self-consistent relative paths to its runner tree.
  - For Category B Project Rules, instructions in `.trae/rules/flow.md` or `AGENTS.md` must mandate invoking the project-vendored runner tree (`bash skills/flow/runner/flow.sh <command>` or `skills\flow\runner\flow.cmd`).
  - Instructing an agent to call unmapped paths (e.g., `~/.agents/skills/flow/runner/flow.sh`) when Flow is only installed locally or under `.trae/skills/` results in immediate `ENOENT` shell errors.
- **The Anti-Illusion Mitigation:** Validate path resolution separately under Arm A (native skill bundle) and Arm B (project-local runner tree).

### 3.5 Latent Trap 5: Synthesized Pass Hallucinations in Agent Mode
- **The Pitfall:** When autonomous Agent Mode encounters a gate failure (exit code $1$), it may attempt to be helpful by declaring the task complete (e.g., *"Stage 00 looks complete; advancing to Stage 01!"*) without actually fixing the underlying issue or re-running the gate check.
- **The Grounded Technical Reality:** An LLM cannot pass a Flow gate by stating it passed. A gate pass is valid if and only if Flow's mechanical engine executed, verified evidence on disk, and returned exit code $0$, generating authenticated filesystem receipts.
- **The Anti-Illusion Mitigation:** Instructions across both `.trae/skills/flow/SKILL.md` and `.trae/rules/flow.md` must explicitly mandate an inviolable negative constraint:
  > *"NEVER declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing exit code 0. If terminal execution returns non-zero, STOP immediately and initiate repair."*
---

## Section 4: Complete 4-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of Trae in an active IDE execution session. Because Trae officially documents two distinct first-party configuration mechanisms—native skills and project rules—the live qualification protocol is structured as a **Two-Arm Empirical Trial**:
- **Arm A: Category A Native Skill Discovery Probe** (`.trae/skills/flow/SKILL.md` and user-global `~/.trae/skills/flow/SKILL.md`).
- **Arm B: Category B Project Rules Scaffolding Probe** (`.trae/rules/flow.md` and global `~/.trae/user_rules`).

Both arms evaluate Trae Agent Mode across Flow's standardized four verification gates. Crucially, **gate-stop fidelity and exit-code capture remain unverified desk hypotheses until live interactive host trials pass**. Furthermore, **Flow's `flow rules` CLI command is strictly locked to 7 verified templates; no Trae template currently exists in `flow rules`**.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                 TRAE TWO-ARM FOUR-POINT LIVE VERIFICATION RUNBOOK                      │
├────────────────────────────────────────────┬───────────────────────────────────────────┤
│ Arm A: Category A Native Skill Discovery   │ Arm B: Category B Project Rules Scaffold  │
│ Target: .trae/skills/flow/SKILL.md         │ Target: .trae/rules/flow.md               │
│ & ~/.trae/skills/flow/SKILL.md             │ & ~/.trae/user_rules (or AGENTS.md)       │
├─────────────────────┬─────────────────────┼─────────────────────┬─────────────────────┤
│ Gate 1: Ingestion   │ Gate 2: Invocation  │ Gate 3: Gate-Stop   │ Gate 4: State       │
│ Dynamic discovery   │ Active terminal tool│ Forced-failure test │ Persistence check   │
│ of SKILL.md (Arm A) │ execution ($0 return│ halts on exit 1     │ verifies unlocked   │
│ or rules (Arm B).   │ code unverified).   │ without illusion.   │ stage on disk.      │
└─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┘
```

### 4.1 Pre-Verification Environment Provisioning

1. **Test Repository Worktree Setup:**
   ```bash
   git clone <repo-url> /tmp/flow-trae-eval
   cd /tmp/flow-trae-eval
   git checkout -b test/trae-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Arm A Test Bed Provisioning (Category A Native Skill Target):**
   - Install the Flow skill bundle to project-local `.trae/skills/flow/`:
     ```bash
     mkdir -p .trae/skills/flow
     cp -r skills/flow/. .trae/skills/flow/
     ```
   - For user-global skill testing, replicate the skill bundle to `~/.trae/skills/flow/` (on Windows: `%userprofile%/.trae/skills/flow/`).
4. **Arm B Test Bed Provisioning (Category B Project Rules Scaffolding):**
   - Materialize project-level rules in `.trae/rules/flow.md`:
     ```markdown
     # Flow Development Discipline
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
   - For global rules testing, stage identical directives in `~/.trae/user_rules`.
   - *Note on `flow rules`:* Flow's `flow rules` dispatcher is strictly locked to 7 verified templates (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), as enforced by `tests/test_flow_rules.sh`. No Trae template currently exists in `flow rules`. For this qualification runbook, `.trae/rules/flow.md` must be staged manually. Ingestion of `.trae/rules/` and `.trae/skills/` must be verified in live trials before recommending either as supported.
5. **Execution Client Configuration:**
   - Open `/tmp/flow-trae-eval` in Trae IDE with Agent Mode enabled (local workspace or remote SSH).

---

### 4.2 Gate 1: Ingestion Audit (Two-Arm Protocol)

- **Test Objective:** Verify that Trae Agent Mode ingests discipline instructions without silent truncation, schema errors, or prompt degradation under both native skill discovery and rule scaffolding.

#### Arm A Probe: Category A Native Skill Discovery
- **Precondition:** `.trae/skills/flow/SKILL.md` (or `~/.trae/skills/flow/SKILL.md`) present; zero manual rule files.
- **Neutral Probe Query (issued to Trae Agent Mode):**
  > *"What skills are currently registered in this workspace or environment, what development discipline does the flow skill provide, and how are its tools invoked?"*
- **Observable Criteria:**
  - [ ] Agent dynamically discovers the `flow` skill from `.trae/skills/flow/SKILL.md` without explicit prompt injection.
  - [ ] Agent correctly identifies Flow's lifecycle stages and evidence-gated discipline from `SKILL.md`.
  - [ ] Agent recognizes skill-declared commands or runner tools.

#### Arm B Probe: Category B Project Rules Ingestion
- **Precondition:** `.trae/rules/flow.md` (and/or `~/.trae/user_rules` / `AGENTS.md`) present; no `.trae/skills/flow/`.
- **Neutral Probe Query (issued to Trae Agent Mode):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly parses `.trae/rules/flow.md` and identifies Flow as the governing discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands or reference unsupported global paths (`~/.agents/`).
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.

#### Explicit Failure Outcomes (Gate 1)
- **FAIL (Skill Discovery Failure - Arm A):** Trae fails to dynamically discover or parse `.trae/skills/flow/SKILL.md`, requiring manual copy-pasting of skill instructions.
- **FAIL (Schema Error / Rule Ingestion Failure - Arm B):** Trae ignores `.trae/rules/flow.md` or reports parsing errors on standard markdown rule files.
- **FAIL (Context Truncation / Dilution):** Agent ignores Flow discipline, hallucinates an alternative development methodology, or exhibits severe prompt dilution.
- **FAIL (Command / Path Hallucination):** Agent invents non-existent CLI tools (e.g., `trae flow check`) or cites unmapped global paths.
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit (Two-Arm Protocol)

- **Test Objective:** Verify that Trae Agent Mode actively executes the Flow runner via its integrated terminal execution tool, captures the integer exit code, and reads stdout/stderr.
- **Critical Qualification Note:** Whether Trae Agent Mode reliably executes terminal commands autonomously and inspects integer return codes ($0$ vs. non-zero) remains an **unverified desk hypothesis** until live host trials pass.

#### Probe Execution (Applicable to Arm A and Arm B)
- **Neutral Probe Query (issued to Trae Agent Mode):**
  > *"Check the status of the current build lifecycle using the terminal."*
- **Observable Criteria:**
  - [ ] Agent dispatches an active execution of `bash skills/flow/runner/flow.sh status` (or the equivalent skill tool runner) via its terminal execution tool.
  - [ ] The command runs within the IDE terminal/subshell without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.

#### Explicit Failure Outcomes (Gate 2)
- **FAIL (Subshell Dispatch Failure):** Trae fails to trigger or execute the shell command in the terminal (e.g., outputs text instructions only, lacking mechanical execution).
- **FAIL (Path Resolution Error):** Command fails with `ENOENT: No such file or directory` or attempts to run an unmapped path.
- **FAIL (Output Truncation / Loss of Exit Code):** Execution output is dropped or the agent fails to receive the return code, causing the session to stall.
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), Trae Agent Mode strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Critical Qualification Note:** Gate-stop fidelity and exit-code capture remain **unverified until live interactive host trials pass**. If Trae Agent Mode ignores non-zero exit codes or declares gates passed without mechanical verification, it fails qualification.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Neutral Probe Query (issued to Trae Agent Mode):**
  > *"Advance to the next stage by executing the stage gate check in the terminal."*
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` in the terminal.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** synthesize or declare that the stage advanced.
  - [ ] Agent quotes the runner's diagnostic failure output and attempts to edit and repair `flow/00-idea.md`.
- **Explicit Failure Outcomes & Disqualification:**
  - **DISQUALIFIED (Pass Hallucination):** The agent declares that Stage 01 is unlocked or claims the gate passed despite the runner exiting with return code `1`. Any hallucinated pass is an **immediate disqualification**.
  - **FAIL (Unconstrained Retry Loop):** Agent enters an infinite loop repeatedly executing `flow.sh next` without reading failure diagnostics or editing `flow/00-idea.md`.
  - **FAIL (Silent Failure):** Agent swallows the non-zero exit code and marks the task complete without operator notification or error reporting.
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

### 4.5 Gate 4: State Integrity Audit (Persistence & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh agent session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Neutral Probe Query (In a fresh Trae Agent Mode session or after IDE window reload):**
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
- **Verdict:** `[PROPOSED DESIGN CANDIDATE: PENDING LIVE TRIAL]`

---

## Section 5: Qualification Archival & Next Steps

### 5.1 Evidence Archival Requirement
Before Trae may be upgraded from `Proposed Design Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Two-Arm Four-Point Live Verification Protocol in an active Trae IDE session on a supported host.
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/trae-1.1.0-qualification-record.md
   ```
4. The qualification record must document exact versions: Trae IDE build/version, underlying VS Code core version, host OS, model identifier, and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Two-Arm Empirical Trial Execution:** Conduct live interactive host trials testing both Arm A (Native Skills at `.trae/skills/flow/SKILL.md`) and Arm B (Project Rules at `.trae/rules/flow.md`). Verify which pathway (or both) Trae Agent Mode reliably ingests.
2. **Terminal Tool Execution Evaluation:** Empirically evaluate whether Trae Agent Mode's tool execution loop supports autonomous execution with strict exit-code inspection across different platforms (macOS, Linux, Windows, remote SSH).
3. **Template Policy Compliance:** Maintain the strict invariant that `flow rules` is locked to its 7 verified templates; do not introduce an unverified Trae template until empirical live trials satisfy all qualification gates. Ingestion of `.trae/rules/` and `.trae/skills/` must be verified in live trials before recommending either as supported.
4. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
