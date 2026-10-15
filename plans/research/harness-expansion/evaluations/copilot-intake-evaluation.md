# Harness Intake Evaluation: GitHub Copilot (VS Code & Workspace)

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Live Host Trials Pending)
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation References:**
    - GitHub Copilot Official Documentation: https://docs.github.com/en/copilot (accessed 2026-10-15)
    - Adding custom instructions for GitHub Copilot: https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot (accessed 2026-10-15)

---

## Section 1: Executive Summary & Modality Separation (Category B & Category D)

### 1.1 Executive Summary & "Support Thật" Qualification Status
GitHub Copilot (developed by GitHub and Microsoft; vendor documentation: https://docs.github.com/en/copilot, accessed 2026-10-15) is an AI-powered coding assistant deeply integrated into the Visual Studio Code editor and GitHub developer ecosystem. It spans multiple operational surfaces: inline code completions, multi-turn conversational chat (Copilot Chat in VS Code), multi-file editing workflows (Copilot Edits and emerging Copilot Workspace/Agent capabilities), and a command-line assistant (`gh copilot` extension for the GitHub CLI).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Workspace Rule Scaffolding for VS Code / Workspace) & Unassessed / Pending Verification (GitHub Copilot CLI)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:**
  - Flow implements native workspace rule scaffolding for GitHub Copilot via `flow rules copilot --write`, materializing `.github/copilot-instructions.md`.
  - In strict adherence to Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), claiming general "GitHub Copilot support" without explicitly distinguishing the VS Code workspace environment from the standalone `gh copilot` CLI is marketing deception ("quảng cáo ảo").
  - The standalone `gh copilot` CLI historically functions as an interactive command suggestion utility without an autonomous tool execution loop; its capability under current GitHub CLI extensions remains unassessed pending dedicated verification (status: Unassessed / Pending Verification).
  - In VS Code, GitHub Copilot Chat and Agent Mode ingest `.github/copilot-instructions.md` as repository-level prompt guidance. However, standard Copilot Chat operates primarily as a conversational assistant that proposes terminal commands to the operator rather than executing them in an autonomous, unprompted loop; only Agent Mode or explicit terminal execution actions dispatch commands into the integrated terminal.
  - Static generation of `.github/copilot-instructions.md` does not constitute empirical proof of live gate enforcement. Because GitHub Copilot lacks an unauthenticated, local headless execution CLI for automated CI qualification, full qualification requires an interactive host session executing the Four-Point Live Verification Protocol with raw tool transcripts, terminal payloads, exit codes, and receipts committed to `plans/research/harness-expansion/evidence/`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                 GITHUB COPILOT (VS CODE & WORKSPACE) EVALUATION SUMMARY                │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Workspace Rule Scaffolding for VS Code) &   │
│                              │ Deferred / Unassessed (GitHub Copilot    │
│                              │ CLI; Pending Verification)              │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Workspace Instructions (`.github/copilot-instructions.md`)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Tool API           │ Interactive terminal proposal / subshell execution      │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host  │
│                              │ Trials Pending)                                         │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, GitHub Copilot in VS Code aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, server process, or resident listening socket inside or outside the VS Code extension host. Flow operates purely as an ephemeral executable.
2. **Process Token Ownership:** The VS Code extension host and GitHub Copilot runtime hold the process token and manage the conversational event loop. Flow executes strictly as an ephemeral subprocess invoked via the integrated terminal or workspace task tool, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Copilot's tool execution, language server communications, or extension host IPC. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Rejection of Resident Language Server / Background Daemons:** Attempting to run Flow as a persistent background language server daemon, an in-memory Copilot extension socket, or a GitHub Codespaces background service is constitutionally prohibited under ADR-0001. Flow's state lives on disk in Git and bounded markdown files, never in volatile memory heaps of resident server daemons.

### 1.3 Architectural Classification: Category B (Workspace Scaffolding) vs. Category D (Deferred CLI)
GitHub Copilot spans two fundamentally divergent operational modalities that require strict separation under Flow's harness taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        GITHUB COPILOT MODALITY SEPARATION                              │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: VS Code Copilot Workspace    │ Modality 2: GitHub Copilot CLI              │
│ (Category B: Workspace Rule Scaffolding) │ (Deferred / Unassessed; Pending    │
│                                          │ Verification)                      │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: VS Code & Codespaces        │ Environment: Terminal shell (`gh copilot`)  │
│ Ingestion: `.github/copilot-instructions.md`│ Ingestion: Unassessed (No verified instruction file schema)   │
│ Agent Loop: Multi-turn Chat / Agent Mode │ Agent Loop: Unassessed (Historically query) │
│ Tool API: Terminal proposal & execution  │ Tool API: Unassessed (Historically suggests)│
│ Status: Provisional Candidate            │ Status: Unassessed / Pending Verification              │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: GitHub Copilot in VS Code (Category B: Workspace Rule Scaffolding)
- **Environment:** Visual Studio Code, VS Code for Web, and GitHub Codespaces using the GitHub Copilot and GitHub Copilot Chat extensions.
- **Rule Ingestion:** Natively reads markdown instructions from `.github/copilot-instructions.md` at the repository root.
- **Tool Execution:** In standard chat, Copilot proposes terminal commands that the user can execute via a single click ("Run in Terminal"). In Agent Mode / Copilot Edits, Copilot can propose and trigger terminal tool execution in the integrated terminal.
- **Classification:** Category B (Workspace Rule Scaffolding).

#### Modality 2: GitHub Copilot CLI (`gh copilot`) (Unassessed / Pending Verification)
- **Environment:** Standalone terminal extension for the GitHub CLI (`gh copilot suggest`, `gh copilot explain`).
- **Historical Query Scope:** `gh copilot` was designed as an interactive command suggestion utility without an autonomous multi-turn tool execution loop; its capability under current/emerging CLI extensions remains unassessed pending dedicated host verification.
- **Instruction Ingestion Unverified:** It has no verified, vendor-documented mechanism to parse `.github/copilot-instructions.md`, `AGENTS.md`, or project build contracts.
- **Classification:** Unassessed / Pending Verification. Claiming Flow support for `gh copilot` is strictly prohibited without live verification evidence.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption:** GitHub Copilot represents a widely deployed commercial developer assistant in the AI coding market. Backed by Microsoft and GitHub, it has extensive enterprise adoption and broad distribution across the VS Code ecosystem.
- **Agentic Autonomy & Capability (Constrained Loop):** While GitHub Copilot has evolved from inline completions to conversational chat, Copilot Edits, and Agent Mode, its autonomous task loop remains constrained compared to autonomous agent harnesses (such as Cursor Composer, Claude Code, or Codex CLI). Standard chat relies heavily on single-turn user prompts and terminal approval prompts; it requires human driving to progress through multi-stage lifecycles.
- **Ecosystem Openness & Stability:** GitHub Copilot is a proprietary, closed-source extension ecosystem governed by GitHub terms of service. However, its workspace instruction mechanism (`.github/copilot-instructions.md`) is publicly documented, standardized across repositories, and based on plain Markdown, providing a stable, low-fragility configuration surface.
- **Priority Tier Score:** **Tier 2 (Provisional Internal Estimate: 70/100)**.
  - **Score Classification:** `Provisional Internal Estimate (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **36/40**. Extensive developer adoption across the global GitHub and VS Code ecosystem, with high enterprise penetration.
    2. **Agentic Autonomy & Capability (40 Points Max):** **18/40**. Constrained autonomous task loop compared to Composer/Agent harnesses; relies heavily on user turn prompts and terminal approval; standard chat only suggests terminal commands to the operator rather than running them in an autonomous self-correcting loop.
    3. **Ecosystem Openness & Stability (20 Points Max):** **16/20**. Proprietary extension with closed-source runtime and cloud backend; offset by publicly documented, stable, standard Markdown configuration schema (`.github/copilot-instructions.md`) with zero complex schema fragility.
  - **Total Score:** **70/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74).

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Copilot Architecture & Execution Modalities
GitHub Copilot operates across distinct conversational and editing modalities within VS Code:
1. **Inline Completions:** Ghost-text suggestions while typing; non-agentic, no tool access.
2. **Copilot Chat (Standard Conversational Mode):** A chat panel where developers ask questions and request refactoring. In this mode, Copilot **only suggests** terminal commands using markdown code blocks with an interactive "Run in Terminal" action button. It does not possess an autonomous loop to execute commands without operator interaction.
3. **Copilot Edits & Agent Mode:** Multi-file editing workspace capable of staging changes across files and dispatching command proposals. In agentic configurations, it can interact with the terminal execution subsystem, subject to human approval policies.

#### 2.2.2 Workspace Rule Ingestion & Template Alignment
GitHub Copilot natively discovers and ingests repository instructions from `.github/copilot-instructions.md` at the workspace root (per vendor documentation: https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot):
- **Ingestion Path:** `<workspace-root>/.github/copilot-instructions.md`.
- **Alternative Configuration:** VS Code workspace settings `github.copilot.chat.customInstructions` in `.vscode/settings.json`. Flow standardizes on the file-based `.github/copilot-instructions.md` convention to ensure cross-platform repository portability without committing IDE-specific settings.
- **Template Alignment with `flow rules copilot`:** Flow generates verified GitHub Copilot instructions via `flow rules copilot --write`. The template emitted by `flow rules copilot` (mechanically verified in `tests/test_flow_rules.sh`) is:

```markdown
# GitHub Copilot Instructions for Flow

This repository enforces Flow discipline:
- Planning artifacts live under `flow/` (`00-idea.md` through `05-contract.md`).
- Units of work are tracked as atomic markdown cards in `cards/C-NNN.md`.
- Never modify files outside a card's declared `## Allowed files`.
- Verification requires reproducible commands documented under `## Verify`.
- Mechanical ground truth is `bash skills/flow/runner/flow.sh check C-NNN`.
```

- **Template Metrics Analysis:**
  - Raw Byte Length: **456 bytes** (characters).
  - Line Count: **8 lines**.
  - Word Count: **61 words**.
  - Context Overhead: **~80 tokens** (< 0.1% of Copilot's active context window).
- **Behavioral Directives:**
  - Declares the location and progression of planning artifacts (`flow/00-idea.md` through `flow/05-contract.md`).
  - Enforces the card-governed execution model (`cards/C-NNN.md`).
  - Restricts modifications strictly to files listed under `## Allowed files`.
  - Mandates reproducible verification commands under `## Verify`.
  - Establishes mechanical ground truth strictly via `bash skills/flow/runner/flow.sh check C-NNN`.

#### 2.2.3 Context Budgeting & Token Discipline
- **Token Degradation Hazards:** Injecting large instruction files into Copilot Chat consumes valuable context space and leads to prompt dilution, causing Copilot to ignore constraints or hallucinate completions.
- **Progressive Disclosure Architecture:** Flow strictly rejects monolithic rule dumping. The `.github/copilot-instructions.md` template is ultra-lean (456 characters, ~80 tokens). It serves as an **invariant guard and index router**. Stage playbooks (`skills/flow/references/*.md`) remain on disk and are inspected on-demand by the developer or assistant only during active execution of that specific stage.

#### 2.2.4 Terminal Tool API & Human-in-the-Loop Dynamics
- **Terminal Execution Mechanism:** In VS Code Copilot Chat, terminal execution is fundamentally **interactive**. When Copilot determines a command must be run (e.g., `bash skills/flow/runner/flow.sh status`), it presents the command with a "Run in Terminal" action or pastes it into the active terminal buffer.
- **Human-in-the-Loop Approval:** The operator reviews the proposed command and authorizes its execution. Once executed, the command runs in the integrated terminal shell (bash, zsh, cmd.exe, or PowerShell).
- **Feedback Propagation:** In Agent Mode, the terminal output and exit code are reported back to the Copilot context; in standard chat, the operator references terminal output in follow-up chat turns.

---

## Section 3: Latent Bug Analysis & Failure Modes (Anti-Illusion Protocol)

### 3.1 Latent Trap 1: Modality Separation Collapse (VS Code Copilot vs. `gh copilot` CLI)
- **The Failure Mode:**
  - An engineer or vendor creates a marketing claim stating: *"Flow now supports GitHub Copilot across all interfaces!"*
  - A developer attempts to use `gh copilot` in the terminal to advance a Flow stage or check an in-flight card:
    ```bash
    gh copilot suggest "advance flow stage to 01-research"
    ```
  - `gh copilot` was historically designed as an interactive command suggestion utility; it returned a generic natural-language text response rather than a tool invocation, and instruction file ingestion remains unverified under current CLI extensions. Its autonomous loop and runner exit-code handling remain unassessed pending current CLI verification, and the repository is left in an unverified state.
- **The Anti-Illusion Mitigation:**
  - Flow's documentation and compatibility matrix explicitly bifurcate GitHub Copilot:
    - **VS Code Copilot Workspace:** Category B (Workspace Rule Scaffolding).
    - **GitHub Copilot CLI (`gh copilot`):** Unassessed / Pending Verification.
  - Flow strictly refuses to document or advertise CLI support for GitHub Copilot.

### 3.2 Latent Trap 2: Lack of Autonomous Loop & Chat Hallucination Trap
- **The Failure Mode:**
  - In standard VS Code Copilot Chat, the assistant lacks an autonomous self-correcting loop. When prompted:
    > *"Check if stage 00-idea is ready to advance."*
  - Instead of requiring the terminal command `bash skills/flow/runner/flow.sh next` to execute, Copilot reads `flow/00-idea.md` via its file-reading tool, observes that the markdown text appears well-written, and asserts:
    > *"Stage 00-idea looks great and complete! You can now proceed to stage 01-research."*
  - This is a catastrophic discipline breach: `[FILL]` markers or unchecked boxes may still exist, mechanical gate checks were completely bypassed, and no authenticated receipt was written to disk.
- **The Anti-Illusion Mitigation:**
  - The instructions explicitly anchor ground truth in the runner:
    > *"Mechanical ground truth is `bash skills/flow/runner/flow.sh check C-NNN`."*
  - Scaffolding instructs the model and operator that **only** an active terminal execution returning exit code `0` validates stage transitions. If the command returns non-zero, the operator and agent must halt and repair errors.

### 3.3 Latent Trap 3: Prohibition of Background GitHub Daemons / Resident Servers
- **The Failure Mode:**
  - An integrator attempts to wrap Flow as a resident Language Server Protocol (LSP) extension daemon or persistent background server running inside VS Code or GitHub Codespaces to continuously poll Flow status.
  - Why this is constitutionally prohibited under ADR-0001:
    1. **ADR-0001 Invariant:** Flow strictly forbids background daemons and resident servers.
    2. **Stale State Corruption:** Long-lived LSP server daemons cache ASTs and file trees in memory. When git branches switch or files change outside the IDE, the daemon serves stale state.
    3. **Interposition Hazard:** A resident server intercepts tool communications, obscuring the plain bash exit code ground truth.
- **The Anti-Illusion Mitigation:**
  - Flow executes strictly as an **ephemeral CLI** (`runner/flow.sh` or `runner/flow.cmd`). Each command invocation performs its check, updates receipts, outputs plain text, and immediately exits.

### 3.4 Latent Trap 4: Windows Path Mapping, PowerShell vs. Git Bash, and WSL Traps
- **The Failure Mode:**
  - VS Code on Windows defaults to PowerShell or `cmd.exe` as its integrated terminal profile.
  - If Copilot proposes `bash skills/flow/runner/flow.sh check C-NNN`:
    - If `bash` resolves to WSL (`C:\Windows\System32\bash.exe`) instead of Git Bash, WSL may fail to map Windows paths or fail on secondary drives (`D:\`).
    - CRLF line endings introduced by Windows git checkouts trigger bash syntax errors (`\r: command not found`).
- **The Anti-Illusion Mitigation:**
  - Flow ships and tests `skills/flow/runner/flow.cmd`, a native Windows CMD batch wrapper that executes without WSL.
  - On Windows workstations, Copilot instructions can reference:
    ```cmd
    skills\flow\runner\flow.cmd check C-NNN
    ```
    or Git Bash:
    ```bash
    bash skills/flow/runner/flow.sh check C-NNN
    ```

---

## Section 4: Live Verification Runbook Checklist

This runbook specifies the step-by-step instructions for executing the **Four-Point Live Verification Protocol** for GitHub Copilot in VS Code.

### 4.0 Interactive Qualification Invariant (Absence of Headless CLI)
Unlike CLI-first agents that provide non-interactive evaluation entrypoints (such as Antigravity's `agy -p` or Codex's `codex exec`), GitHub Copilot in VS Code is an interactive editor extension. There is no unauthenticated local headless CLI mode that executes arbitrary Copilot multi-turn agent sessions in headless CI.

Consequently, qualification **strictly requires an interactive session in VS Code with the GitHub Copilot Chat extension**:
1. The evaluating engineer must open the test workspace in VS Code with GitHub Copilot Chat active.
2. Every gate test must capture raw conversational prompts, terminal tool proposals, executed terminal stdout/stderr, and exit status codes.
3. Live transcripts must be recorded verbatim and archived to `plans/research/harness-expansion/evidence/`.

---

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   Create an isolated temporary git worktree with no prior Flow state:
   ```bash
   git worktree add /tmp/flow-copilot-eval -b test/copilot-eval-intake
   cd /tmp/flow-copilot-eval
   ```

2. **Generate GitHub Copilot Rule Scaffolding:**
   Materialize `.github/copilot-instructions.md` using Flow's mechanical rule generator:
   ```bash
   bash skills/flow/runner/flow.sh rules copilot --write
   ```
   Verify the file was created and contains the exact template:
   ```bash
   cat .github/copilot-instructions.md
   ```

3. **Ensure Runner Availability:**
   Ensure `skills/flow/runner/flow.sh` is present in the workspace and executable:
   ```bash
   chmod +x skills/flow/runner/flow.sh
   bash skills/flow/runner/flow.sh status
   ```

4. **Launch VS Code Workspace:**
   Open `/tmp/flow-copilot-eval` in VS Code:
   ```bash
   code /tmp/flow-copilot-eval
   ```
   Open Copilot Chat (Ctrl+Alt+I / Cmd+Alt+I) and document host environment details:
   - VS Code Version: `[Capture VS Code version from Help -> About]`
   - GitHub Copilot Extension Version: `[e.g., v1.x.x]`
   - GitHub Copilot Chat Extension Version: `[e.g., v0.x.x]`
   - Underlying Model Identifier: `[e.g., Claude 3.7 Sonnet / GPT-4o]`
   - Operating System: `[e.g., Linux x64 / macOS arm64 / Windows x64]`
   - Active Nonce: `[e.g., nonce-copilot-20261015-c1p0t9]`

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Context Loading & Rule Discovery)
- **Objective:** Verify GitHub Copilot Chat ingests `.github/copilot-instructions.md` cleanly without truncation, syntax errors, or prompt dilution.
- **Test Input (Canary Query in fresh Copilot Chat thread):**
  ```text
  What software development discipline governs this repository, what commands are available to inspect status, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] Copilot explicitly identifies Flow as the governing development discipline.
  - [ ] Copilot references `skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical execution tool.
  - [ ] Copilot identifies artifacts under `flow/` and atomic cards under `cards/C-NNN.md`.
  - [ ] Copilot does not report parsing errors or drop the instruction context.
- **Empty Capture Placeholder:**
  ```text
  [RAW COPILOT INGESTION RESPONSE CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

#### Gate 2: Invocation Audit (Terminal Execution Fidelity)
- **Objective:** Verify Copilot correctly proposes or dispatches a terminal execution tool call for `flow.sh status` and accurately interprets the resulting stdout and exit code.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using the project terminal command.
  ```
- **Evaluation Criteria:**
  - [ ] Copilot proposes or executes `bash skills/flow/runner/flow.sh status` (or `skills\flow\runner\flow.cmd status`).
  - [ ] The command executes in the integrated terminal without path resolution errors.
  - [ ] The runner exits with integer code `0`.
  - [ ] Copilot receives stdout and correctly reports the current stage (e.g., `00-idea`) and next recommended step.
- **Empty Capture Placeholder:**
  ```text
  [RAW TERMINAL PROPOSAL & EXECUTION CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Copilot halts when `flow.sh` exits with non-zero status ($\text{exit} \neq 0$) and strictly refuses to hallucinate that a failed gate passed.
- **Test Setup:**
  Install the standard forced-failure Stage 00 fixture into the workspace:
  ```bash
  cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
  ```
  Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and open checklist items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```
- **Evaluation Criteria:**
  - [ ] Copilot proposes or executes `bash skills/flow/runner/flow.sh next`.
  - [ ] The runner outputs failure diagnostics (e.g., `[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Copilot strictly **HALTS**. It does **NOT** synthesize or declare that the stage passed.
  - [ ] Copilot quotes the runner diagnostic failure and advises repairing the unfilled markers in `flow/00-idea.md`.
  - *(Note: If Copilot claims the stage advanced despite exit code 1, the candidate is immediately marked **DISQUALIFIED**).*
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE-STOP TOOL EXECUTION & HALT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that `flow.sh next` unlocks `flow/01-research.md` on disk, and a fresh `flow status` invocation reads the unlocked stage directly from disk across a new Copilot Chat session without state loss.
- **Test Setup:**
  Fill all `[FILL]` placeholders and check all boxes in `flow/00-idea.md` with complete, valid requirements.
- **Test Input 1 (Advancement):**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Copilot proposes or executes `bash skills/flow/runner/flow.sh next`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed present on disk.
- **Test Input 2 (Session Restart & Fresh Readback):**
  Close the active chat panel and start a completely fresh Copilot Chat thread. Issue:
  ```text
  Resume our Flow session and report our position.
  ```
- **Evaluation Criteria (Readback):**
  - [ ] Copilot proposes or executes `bash skills/flow/runner/flow.sh status`.
  - [ ] Copilot reads back stage `01-research` directly from disk without state loss.
  - [ ] Zero resident daemons were required to maintain state between sessions.
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE 4 ADVANCEMENT & FRESH SESSION READBACK CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Upon completion of the live host trial:
1. Capture all raw conversational turns, terminal execution proposals, stdout/stderr streams, and mechanical exit codes.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/copilot-<version>-qualification-record.md
   ```
4. If and only if all four gates pass, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition GitHub Copilot from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT (Category B)`.
