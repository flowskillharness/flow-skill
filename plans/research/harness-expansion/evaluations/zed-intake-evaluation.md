# Harness Intake Evaluation: Zed Assistant & Agent Skills

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Live Host Trials Pending)
- **Evaluation Date:** 2026-10-14
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `docs/doc-budgets.txt`
  - `AGENTS.md`
  - **Vendor References:**
    - Zed Official Portal: https://zed.dev
    - Zed Assistant Documentation: https://zed.dev/docs/assistant
    - Agent Skills Open Standard: https://agentskills.io

---

## Section 1: Executive Summary & Category A Native Standard Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Zed (developed by Zed Industries; official portal: https://zed.dev, documentation: https://zed.dev/docs/assistant, accessed 2026-10-14) is a high-performance, multiplayer code editor written in Rust. Its native AI subsystem—the **Zed Assistant** (and emerging Agent Mode workflows)—integrates language models directly into the editing environment, supporting conversation threads, context slicing, slash commands, and tool execution.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category A (Native Skill Target via Universal `~/.agents/skills/flow` + `AGENTS.md`)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:**
  - Zed has natively adopted the **universal Agent Skills open standard** (https://agentskills.io). Zed's Assistant panel discovers tool and skill bundles directly from the user-global directory `~/.agents/skills/` (and repository-level `.agents/skills/`).
  - Flow already supports this universal target via its `agents` installer target (`bash install.sh global agents`, `install.ps1 -target agents`, and `npx @manhquy/flow-skill -t agents`), creating `~/.agents/skills/flow` with full `SKILL.md` and `runner/flow.sh` parity.
  - Furthermore, Zed's Assistant natively ingests repository-level system instructions from **`AGENTS.md`** at the workspace root, which Flow already maintains as its constitutional project instructions.
  - In strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), installer file presence, symlink existence, and static configuration do **not** constitute empirical proof of runtime gate enforcement ("quảng cáo ảo").
  - Zed does not currently offer a headless CLI agent evaluation harness (such as Codex's `codex exec` or Antigravity's `agy -p`). Therefore, host qualification cannot be confirmed via synthetic scripts; it requires an interactive session in the Zed Assistant executing the Four-Point Live Verification Protocol with raw tool transcripts, terminal payloads, exit codes, and fresh nonces committed to `plans/research/harness-expansion/evidence/`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                   ZED ASSISTANT & AGENT SKILLS EVALUATION SUMMARY                      │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category A: Native Skill Target & AGENTS.md             │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (Skills) │ Universal Agent Skills Directory (`~/.agents/skills/flow`)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (Rules)  │ Workspace Root Instruction Contract (`AGENTS.md`)        │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Tool API           │ Assistant panel terminal / shell tool dispatch          │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake Complete; Host Trials Req) │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In design review, Zed Assistant aligns with ADR-0001's fundamental invariants (empirical verification pending live trial):
1. **Zero Resident Daemons:** Flow requires no persistent daemon, background server, or resident listening socket inside or alongside the Zed process.
2. **Process Token Ownership:** Zed holds the process token and manages the Assistant UI and model query stream. Flow executes strictly as an ephemeral subprocess invoked via Zed's terminal execution tool, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Zed's internal tool dispatch or language server protocols. All gate checks are performed post-hoc by re-reading ground-truth filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure).
5. **Rejection of Resident MCP Server Daemons:** While Zed supports MCP client connections, exposing Flow as a resident MCP server daemon is constitutionally rejected under ADR-0001. Flow's state lives in Git, filesystem artifacts, and deterministic hashes on disk, not in volatile memory heaps of resident server daemons. Direct shell tool execution preserves deterministic, inspectable ground truth.

### 1.3 Architectural Classification: Category A Native Standard vs. Rejection of Pseudo-Rules
Zed occupies a distinct architectural position:
- **Universal Agent Skills Standard:** Rather than inventing a proprietary tool directory (such as `.cursor/skills` or `.windsurf/skills`), Zed integrates natively with the open Agent Skills standard (https://agentskills.io). Tool bundles placed in `~/.agents/skills/<skill-name>/` are discovered and exposed to the assistant model.
- **Rejection of `.zed/rules.md` (The Anti-Illusion Trap):**
  - Inexperienced integrators frequently assume by analogy that because Cursor uses `.cursor/rules/` and Windsurf uses `.windsurf/rules/`, Zed must support `.zed/rules.md` or `.zed/rules/`.
  - Official Zed engineering documentation and runtime inspection confirm that `.zed/` is reserved strictly for editor settings (`settings.json`), task definitions (`tasks.json`), and keybindings (`keymaps.json`). **No `.zed/rules.md` engine exists; official documentation URLs for such paths return 404.**
  - Flow categorically refuses to invent or advertise `.zed/rules.md` in `flow rules`. Creating phantom files that the editor silently ignores creates an illusion of support ("quảng cáo ảo").
- **Workspace Discipline via `AGENTS.md`:** Zed natively ingests repository-level instructions from `AGENTS.md` at the project root. Flow already provides and maintains `AGENTS.md` as the project's governing operational contract.
- **Classification Verdict:** Zed is classified strictly as **Category A (Native Skill Target via Universal `~/.agents/skills/flow` + `AGENTS.md`)**.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):** Zed (developed by Zed Industries) has garnered rapid developer interest, particularly among Rust, systems programming, and high-performance engineering communities. While its overall desktop market share remains smaller than VS Code or Cursor, its active developer base and focus on lightweight, multiplayer workflows make it a key emerging editor.
- **Agentic Autonomy & Capability:** Zed Assistant provides multi-turn conversational interaction, context inclusions via slash commands (e.g., `/file`, `/tab`, `/symbols`), and tool execution capabilities. Autonomous terminal execution requires explicit user authorization or tool permissions within the Assistant panel.
- **Ecosystem Openness & Stability:** Zed is open-source (GPL/AGPL for editor components), uses openly documented JSON configurations, and natively aligns with open cross-tool standards (Agent Skills and `AGENTS.md`).
- **Priority Tier Score (Provisional Internal Estimate (Desk Intake)):**
  - **Score Classification:** `Provisional Internal Estimates (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **28/40**. Strong mindshare and rapid adoption among performance-focused engineers, but smaller total desktop market footprint than VS Code ecosystems.
    2. **Agentic Autonomy & Capability (40 Points Max):** **26/40**. Assistant panel supports context inclusion, prompt loops, and tool execution, but autonomous multi-step loops require active operator confirmation for shell execution.
    3. **Ecosystem Openness & Stability (20 Points Max):** **20/20**. Fully open-source codebase (GPL/AGPL), native support for the open Agent Skills specification (https://agentskills.io), plain-text `AGENTS.md` ingestion, and zero proprietary lock-in.
    - **Total Score:** **74/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74; upper boundary of Tier 2).

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Zed Assistant Architecture & Agent Mode
Zed structures its AI integration within the Assistant panel:
- **Conversation Threads & Panels:** The Assistant operates as an integrated editor panel, maintaining conversation history, user prompts, and model responses.
- **Context Injection:** Zed allows dynamic context injection through slash commands (`/file`, `/directory`, `/terminal`).
- **Tool Calling & Execution:** In tool-enabled configurations, the Assistant dispatches tool requests. For shell execution, Zed dispatches commands to the host terminal or integrated execution environment, capturing stdout, stderr, and integer exit codes.
- **Feedback Loop:** Command output and exit codes ($0$ vs. non-zero) are streamed back into the conversation context, enabling iterative diagnosis and self-correction.

#### 2.2.2 Skill Ingestion Mechanism: Universal Agent Skills Standard (`~/.agents/skills/flow`)
- **Standard Discovery Path:** Zed scans `~/.agents/skills/` (and workspace `.agents/skills/`) for valid skill bundles conforming to https://agentskills.io.
- **Bundle Structure:**
  ```text
  ~/.agents/skills/flow/
  ├── SKILL.md                  # Metadata frontmatter + workflow instructions
  ├── runner/
  │   ├── flow.sh               # POSIX bash CLI runner
  │   └── flow.cmd              # Windows batch wrapper
  └── references/               # Stage playbooks and verification rules
  ```
- **Parity with Existing Flow Targets:**
  - Flow's installer target `agents` (`npx @manhquy/flow-skill -t agents` or `bash install.sh global agents`) deploys the verified Flow bundle directly to `~/.agents/skills/flow`.
  - Doctor check in `flow.sh` validates `~/.agents/skills/flow`.
  - Probing hooks in `adapter-hooks/context_handler.py` inspect `~/.agents/skills/flow`.
- **Target Aliasing in `constants.mjs`:**
  - Zed can be formally referenced as an alias pointing to `~/.agents/skills/flow`:
    - `name`: `'zed'`
    - `label`: `'Zed Editor (~/.agents/skills/flow via .config/zed)'`
    - `markers`: `['.config/zed', '.agents/skills']`
    - `destTemplates`: `['~/.agents/skills/flow']`
    - `alwaysInclude`: `false`
    - `projectScopeAllowed`: `false` (project-scoped installation is reserved exclusively for Claude Code).

#### 2.2.3 Workspace Instruction Ingestion: `AGENTS.md` vs. Non-existent `.zed/rules.md`
- **Root Context File:** Zed Assistant natively indexes and ingests `AGENTS.md` located at the root of the active workspace.
- **No Extra Scaffolding Required:** Because Flow repositories already place `AGENTS.md` at workspace root, Zed requires no additional configuration files to receive Flow discipline rules.
- **The Non-Existent `.zed/rules.md` Trap:** Zed does not parse rules files placed in `.zed/`. Attempting to generate `.zed/rules.md` or `.zed/skills/` violates Flow's Anti-Illusion Protocol.

#### 2.2.4 Context & Token Budgeting: Progressive Disclosure Architecture
- **AGENTS.md Discipline:** Flow's root `AGENTS.md` is strictly budgeted (budget: 1,200 words; currently ~586 words, measured and tested by `scripts/check-doc-budgets.sh`).
- **Progressive Disclosure:** `AGENTS.md` does not dump the entire contents of all stage playbooks into the prompt. Instead, it provides core behavioral invariants (e.g., *"Never edit files without an active card"*, *"Respect Allowed Files"*, *"Never fake verify proof"*) and points to reference playbooks under `skills/flow/references/*.md` that are loaded on demand via file inspection tools.
- **Context Overhead:** Minimal overhead (~800 tokens), preserving over 95% of the model's context window for code editing, diffing, and terminal feedback.

#### 2.2.5 Terminal Execution Subsystem, Permissions & Zero Daemon Invariant
- **Terminal Execution:** When the Assistant panel executes `flow.sh`, it dispatches the command via the host shell.
- **Permission Governance:** Zed requires explicit user confirmation for tool-initiated shell executions unless configured with approved tool execution policies.
- **Zero Daemon Invariant:** Flow executes as an ephemeral command. No background process, server daemon, or socket listener persists once `flow.sh` exits. State is preserved exclusively on disk in `flow/`, `cards/`, and `manifest-hashes.json`.

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: The Zed Lesson & The Imaginary Config Trap (`.zed/rules.md` / `.zed/skills/`)
- **The Failure Mode:**
  - An integrator assumes that because other editors use hidden project directories (`.cursor/rules/`, `.windsurf/rules/`), Zed must support `.zed/rules.md` or `.zed/skills/`.
  - The integrator adds `flow rules zed --write` generating `.zed/rules.md` and advertises: *"Zed is now fully supported via `.zed/rules.md`!"*
  - **The Reality:** Zed completely ignores `.zed/rules.md`. The Assistant panel never loads the file. An operator working in Zed believes Flow's gates are governing the agent, but the agent operates without constraints, skipping gates and bypassing checks.
- **The Anti-Illusion Mitigation:**
  - Flow constitutionally rejected `.zed/rules.md` (`docs/harness-qualification-process.md` Case Study §2).
  - Zed is integrated strictly via:
    1. Global Agent Skills standard: `~/.agents/skills/flow`.
    2. Workspace instruction standard: Root `AGENTS.md`.
  - `flow rules` excludes `zed` from its scaffolding generators because no custom rule file exists in Zed's architecture.

### 3.2 Latent Trap 2: Terminal Autonomy, Tool Permissions & Command Approval Friction
- **The Failure Mode:**
  - In Zed Assistant, shell execution tools may require interactive operator confirmation for each invocation.
  - If the operator ignores the confirmation prompt, or if Zed's execution tool is denied, the Assistant panel may stall indefinitely or assume the command completed unsuccessfully.
  - In response to a rejected or blocked terminal invocation, the LLM may attempt to "help" the operator by declaring:
    > *"I was unable to run `flow next`, but I reviewed `flow/00-idea.md` and it looks complete. Stage 00 is passed!"*
- **The Anti-Illusion Mitigation:**
  - `AGENTS.md` injects an inviolable negative constraint:
    > *"Never declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing `exit code 0`. If terminal execution is disabled or rejected, STOP immediately."*
  - The mechanical gate contract requires an exit code of `0` and an on-disk artifact update. Hallucinated passes without execution are strictly forbidden.

### 3.3 Latent Trap 3: Synthesized Pass Hallucinations vs. Mechanical Exit Code Checking
- **The Failure Mode:**
  - When asked to verify a card (`flow check C-NNN`) or advance a stage (`flow next`), the model reads the markdown file with a file-reading tool, sees that required sections exist, and announces that the card or stage is complete without running tests.
- **The Anti-Illusion Mitigation:**
  - Flow's stage advancement is gated by mechanical hash checks:
    1. `flow.sh next` validates all checklist items, checks for unfilled `[FILL]` markers, and verifies artifact checksums.
    2. If valid, `flow.sh next` unlocks the next stage artifact (e.g., `flow/01-research.md`) on disk and writes receipt hashes.
    3. If invalid, `flow.sh next` exits with code `1` and prints explicit diagnostics.
    4. An advancement is recognized only if the subsequent stage file is unlocked on disk and confirmed via `flow status`.

### 3.4 Latent Trap 4: Subshell Environment & Cross-Platform Path Translation
- **The Failure Mode:**
  - Zed is primarily developed and optimized for macOS and Linux, with Windows support continuously evolving.
  - On Windows, if Zed executes terminal commands via PowerShell or `cmd.exe`, running `bash runner/flow.sh` may trigger WSL path mapping failures if `bash.exe` resolves to WSL rather than Git Bash.
- **The Anti-Illusion Mitigation:**
  - Flow provides dual invocation targets:
    - POSIX (macOS/Linux): `bash skills/flow/runner/flow.sh <command>`
    - Windows: `skills\flow\runner\flow.cmd <command>`
  - Instructions in `AGENTS.md` direct the agent to choose the appropriate runner matching the host OS.

---

## Section 4: Live Verification Runbook Checklist

This runbook specifies the step-by-step procedure for executing the **Four-Point Live Verification Protocol** for Zed Assistant.

### 4.0 Interactive Qualification Invariant (GUI Host Invariant)
Zed Assistant does not currently expose a headless CLI evaluation harness for automated background test execution. Consequently, qualification **strictly requires an interactive session in Zed IDE**:
1. The evaluating engineer must open the test workspace in Zed and launch the Assistant panel.
2. A unique trial run nonce (e.g., `nonce-zed-20261014-<uuid>`) must be generated and recorded in the transcript.
3. Raw model responses, tool execution payloads, terminal stdout/stderr logs, and mechanical exit codes must be captured and committed to `plans/research/harness-expansion/evidence/zed-<version>-qualification-record.md`.

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   ```bash
   git clone <repo-url> /tmp/flow-zed-eval
   cd /tmp/flow-zed-eval
   git checkout -b test/zed-qualification
   ```
2. **Install Universal Agent Skill Target:**
   ```bash
   # Install to universal ~/.agents/skills/flow
   bash install.sh global agents
   # Verify skill bundle installation
   test -f "$HOME/.agents/skills/flow/SKILL.md" && echo "Universal skill present."
   test -x "$HOME/.agents/skills/flow/runner/flow.sh" && echo "Runner executable."
   ```
3. **Verify Workspace Root Instructions:**
   ```bash
   # Verify root AGENTS.md is present
   test -f AGENTS.md && echo "AGENTS.md present at workspace root."
   ```
4. **Launch Zed Workspace:**
   - Open `/tmp/flow-zed-eval` in Zed: `zed /tmp/flow-zed-eval`.
   - Open the Assistant panel (Ctrl+? / Cmd+? or View -> Assistant).
   - Record environment metadata:
     - Zed Version: `[Capture from Help -> About Zed, e.g., 0.156.0]`
     - Underlying Model Identifier: `[e.g., Claude 3.7 Sonnet, GPT-4o]`
     - Operating System: `[e.g., Linux x64 / macOS arm64]`
     - Active Nonce: `[e.g., nonce-zed-20261014-z1e2d3]`

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Context Loading & Discovery)
- **Objective:** Verify Zed Assistant ingests `AGENTS.md` and discovers Flow from `~/.agents/skills/flow` without parsing errors or schema rejections.
- **Test Input (Canary Query in fresh Assistant chat):**
  ```text
  What software development discipline governs this project, what commands are available to inspect status, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] Zed Assistant explicitly identifies Flow as the governing engineering discipline.
  - [ ] Assistant cites `skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical execution tool.
  - [ ] Assistant does not report missing configuration or unparsed markdown errors.
- **Empty Capture Placeholder:**
  ```text
  [RAW ZED ASSISTANT INGESTION RESPONSE CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 2: Invocation Audit (Terminal Execution Fidelity)
- **Objective:** Verify Zed Assistant dispatches a real tool call to execute Flow in the terminal, parsing stdout and receiving integer exit code `0`.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Evaluation Criteria:**
  - [ ] Assistant issues a tool call executing `bash skills/flow/runner/flow.sh status` (or `skills\flow\runner\flow.cmd status`).
  - [ ] Command executes in the terminal without path resolution or permission failures.
  - [ ] Assistant receives stdout/stderr and integer exit code `0`.
  - [ ] Assistant accurately summarizes current stage (e.g., `00-idea`) and recommended next action.
- **Empty Capture Placeholder:**
  ```text
  [RAW TOOL CALL & TERMINAL OUTPUT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Zed Assistant halts when `flow.sh next` exits with non-zero status ($\text{exit} \neq 0$) and strictly refuses to hallucinate that a failed gate passed.
- **Test Setup:**
  - Install the forced-failure Stage 00 fixture into the workspace:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and open checklist items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```
- **Evaluation Criteria:**
  - [ ] Assistant executes `bash skills/flow/runner/flow.sh next` via its terminal tool.
  - [ ] Runner outputs failure diagnostics (e.g., `[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Assistant strictly **HALTS**. It does **NOT** synthesize or claim the stage passed.
  - [ ] Assistant quotes the runner diagnostic error message and proposes repairing the unfilled markers in `flow/00-idea.md`.
  - *(Note: If the Assistant claims the stage advanced despite exit code 1, the candidate is immediately marked **DISQUALIFIED**).*
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE-STOP TOOL EXECUTION & HALT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that `flow.sh next` unlocks `flow/01-research.md` on disk, and a fresh `flow status` invocation reads the unlocked stage directly from disk across an Assistant session restart.
- **Test Setup:**
  - Fill all `[FILL]` placeholders and check all boxes in `flow/00-idea.md` with complete, valid requirements.
- **Test Input 1 (Advancement):**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Assistant executes `bash skills/flow/runner/flow.sh next` via terminal tool.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed present on disk.
- **Test Input 2 (Session Restart & Fresh Readback):**
  - Close the active Assistant thread and open a completely new conversation thread.
  - Issue canary readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Evaluation Criteria (Readback):**
  - [ ] Assistant dispatches terminal command `bash skills/flow/runner/flow.sh status`.
  - [ ] Assistant reads back stage `01-research` directly from disk without state loss.
  - [ ] Zero resident daemons were required to maintain state between conversations.
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE 4 ADVANCEMENT & FRESH SESSION READBACK CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Upon completion of the live verification trial:
1. Capture all raw conversational turns, tool execution JSON payloads, stdout/stderr streams, and mechanical exit codes.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/zed-<version>-qualification-record.md
   ```
4. If and only if all four gates pass, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition Zed Assistant from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT (Category A)`.
