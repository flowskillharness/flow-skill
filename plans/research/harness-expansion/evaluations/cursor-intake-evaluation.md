# Harness Intake Evaluation: Cursor Composer & Agent Mode

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Live Host Trials Pending)
- **Evaluation Date:** 2026-10-14
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation Reference:** Cursor Documentation (Rules: https://docs.cursor.com/context/rules-for-ai, Agent Mode: https://docs.cursor.com/composer, accessed 2026-10-14)

---

## Section 1: Executive Summary & Dual-Path Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Cursor (developed by Anysphere) is an AI-focused code editor built as a fork of Visual Studio Code. Its primary agentic feature, **Composer** (specifically in **Agent Mode**), operates as an autonomous engineering assistant capable of multi-turn planning, simultaneous multi-file editing, terminal tool execution (`run_terminal_cmd`), and iterative problem resolution.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Dual-Path Support Candidate**:
  - **Path 1 (Category A):** Native Skill Target (`~/.cursor/skills/flow`).
  - **Path 2 (Category B):** Workspace Rule Scaffolding (`.cursor/rules/flow.mdc`).
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:**
  - On the codebase side, Flow has implemented full target parity for Cursor across all global installation channels (`install.sh`, `install.ps1`, `npm-wrapper/bin/cli.mjs`), verified doctor inspection (`skills/flow/runner/flow.sh:3127-3145`), adapter-hook fallback probing (`skills/flow/adapter-hooks/context_handler.py:276-280`), and rule generation via `flow rules cursor --write`.
  - Furthermore, empirical investigation on the development workstation confirmed that Cursor auto-discovers directory-based skills at `~/.cursor/skills/` (validated by a live symlink to `~/.agents/skills/find-skills`).
  - However, in strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), installer presence, symlink existence, and static file generation do **not** constitute empirical proof of runtime gate enforcement. Cursor currently lacks an automated headless execution CLI (commands like `cursor agent --help` fall through to generic VS Code flags without headless print/eval modes like Antigravity's `agy -p` or Codex's `codex exec`). Therefore, host qualification cannot be executed through scripted headless CI; it strictly requires an interactive Composer session in the Cursor IDE running the Four-Point Live Verification Protocol with raw tool transcripts, terminal payloads, stdout/stderr streams, and fresh nonces committed to `plans/research/harness-expansion/evidence/cursor-<version>-qualification-record.md`. Until these live receipts are recorded, Cursor must be truthfully designated as a **provisional candidate** rather than a fully verified live target.
```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                   CURSOR COMPOSER & AGENT MODE EVALUATION SUMMARY                      │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Dual-Path: Category A (Native) & Category B (Scaffold) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (Cat A)  │ User-Global Skill Home (`~/.cursor/skills/flow`)        │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (Cat B)  │ Workspace MDC Rule (`.cursor/rules/flow.mdc`)           │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Tool API           │ `run_terminal_cmd` (Integrated terminal execution tool) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake OK; Host Trials Req) │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) mandates that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In design review, Cursor Composer & Agent Mode align with ADR-0001's fundamental invariants (empirical verification pending live trial):
1. **Zero Resident Daemons:** Flow requires no persistent background server, daemon, or listening socket inside or outside the Cursor process.
2. **Process Token Ownership:** Cursor holds the process token and manages the Composer/Agent conversation loop. Flow executes strictly as an ephemeral subprocess invoked via Cursor's terminal execution tool (`run_terminal_cmd`), exiting immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Cursor's internal tool dispatch pipeline. All gate checks are performed post-hoc by reading ground-truth filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate checks, and card verifications occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure).
5. **Rejection of Resident MCP Server Daemons:** Exposing Flow as a long-lived MCP server within Cursor's MCP extension ecosystem is constitutionally rejected under ADR-0001. Flow's state lives in Git, SQLite, and bounded files on disk, not in volatile memory heaps of resident server daemons. Direct shell tool execution (`run_terminal_cmd`) preserves deterministic, inspectable ground truth.

### 1.3 Dual-Path Architectural Classification: Category A Native Skill vs. Category B Rule Scaffolding
Cursor occupies a unique architectural position in Flow's harness expansion matrix, supporting two distinct and complementary integration pathways:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                             CURSOR DUAL-PATH ARCHITECTURE                              │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Path 1: Category A Native Skill Target   │ Path 2: Category B Rule Scaffolding         │
│ (~/.cursor/skills/flow)                  │ (.cursor/rules/flow.mdc)                    │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Scope: User-global installation          │ Scope: Project-level workspace guidance     │
│ Mechanism: Directory discovery of        │ Mechanism: MDC file with YAML frontmatter   │
│ full skill bundle (SKILL.md, runner/)    │ (`description`, `globs`, `alwaysApply: false`)│
│ Parity: install.sh, install.ps1, npm,    │ Materialization: `flow rules cursor --write`│
│ doctor check #12, context_handler.py     │ Purpose: Repository-specific constraint     │
│ Purpose: Global capability for Cursor    │ injection binding Composer to local runner   │
│ Agent to discover and invoke Flow tools  │ without assuming user-global installation   │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Path 1: Category A Native Skill Target (`~/.cursor/skills/flow`)
- **Discovery Mechanism:** Cursor discovers directory-based agent skills located in the user-global home directory `~/.cursor/skills/<name>/`. An empirical probe on the development workstation confirmed Cursor links into the universal Agent Skills standard (`~/.cursor/skills/find-skills -> ~/.agents/skills/find-skills`).
- **Installed Parity (`c050950a`):**
  - Shell installer: `bash install.sh global cursor` installs directly to `~/.cursor/skills/flow`. Autodetection requires `~/.cursor/skills` (bare `~/.cursor` is guarded to avoid false positives).
  - PowerShell installer: `install.ps1 -target cursor` installs to `Join-Path $UserHome '.cursor/skills/flow'`.
  - npm installer: `npx @manhquy/flow-skill -t cursor` installs transactionally with manifest verification.
  - Doctor verification: Check #12 in `skills/flow/runner/flow.sh` validates `~/.cursor/skills/flow`.
  - Adapter hook probe: `context_handler.py` inspects `~/.cursor/skills/flow` during fallback candidate probing.
- **Project Scope Reservation Invariant:** In `constants.mjs` and `install.sh`, `projectScopeAllowed: false` is strictly enforced for Cursor. Project-scoped installation (`--project`) is reserved exclusively for Claude Code (`.claude/skills/flow`). Running `npx @manhquy/flow-skill -t cursor --project` is explicitly rejected.

#### Path 2: Category B Workspace Rule Scaffolding (`.cursor/rules/flow.mdc`)
- **Discovery Mechanism:** Cursor automatically ingests project-level rules stored in `.cursor/rules/*.mdc`.
- **Materialization:** Generated deterministically via `flow rules cursor --write`.
- **Role in Team Repositories:** Category B scaffolding provides essential discipline inside repositories where external developers or CI environments may not have Flow installed globally in `~/.cursor/skills/flow`. The rule file pins the operational constraints directly into Composer's context window and directs it to invoke the project-vendored runner (`bash skills/flow/runner/flow.sh`).

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Adoption & Ecosystem Context:** Cursor (developed by Anysphere) is an AI-focused code editor fork of VS Code with widespread developer adoption, active community mindshare, and rapid industry deployment.
- **Agentic Autonomy:** Cursor's Composer in Agent Mode operates with full multi-turn autonomy. It can synthesize high-level intentions into file edits across arbitrary repository directories, execute terminal commands, parse command outputs, and iteratively correct syntax and test failures.
- **Ecosystem Openness & Stability:** Cursor officially documents its Rules system (`.cursor/rules/`), utilizing standard Markdown enhanced with YAML frontmatter (`.mdc`).
- **Feasibility Tier Score (Provisional Internal Estimate (Desk Intake)):**
  - **Cursor (88/100):** Market Share & Adoption (36/40 - high developer mindshare in AI-first IDEs), Agentic Autonomy (36/40 - Composer Agent Mode multi-file diff and terminal execution), Ecosystem Openness & Stability (16/20 - documented .cursor/rules system, though headless CLI is proprietary/unexposed). Priority Tier 1 candidate.
### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Cursor Composer & Agent Mode Architecture
Cursor separates conversational assistance into two primary modalities:
1. **Normal Chat / Edit Mode:** Single-file or scoped multi-file code editing with direct user review of proposed diffs.
2. **Composer / Agent Mode:** An autonomous, multi-turn execution loop where the model acts as an active agent:
   - **Multi-File Context & Parallel Diffs:** Agent Mode dynamically selects and modifies multiple files across the repository, generating cohesive diff blocks that the user can accept or reject.
   - **Terminal Tool Execution (`run_terminal_cmd`):** When Composer needs to inspect system state, compile code, or run tests, it issues a structured tool call (`run_terminal_cmd`) to execute shell commands in Cursor's integrated terminal.
   - **Feedback Stream:** The terminal output (stdout, stderr) and the mechanical exit status code ($0$ vs. non-zero) are streamed back into Composer's context window, allowing the agent to observe gate outcomes.

#### 2.2.2 Rule Ingestion & MDC Format Specification
Cursor's rule engine processes files located at `<workspace-root>/.cursor/rules/*.mdc`:
- **Format:** MDC (*Markdown for Cursor*), combining YAML frontmatter with standard Markdown bodies.
- **Official Schema (per Vendor Documentation):**
  ```yaml
  ---
  description: Flow buildflow discipline layer and gated execution engine
  globs: flow/**,cards/**,*.md,src/**
  alwaysApply: false
  ---
  ```
- **Frontmatter Field Mechanics:**
  - `description`: A clear, natural-language explanation of what the rule enforces. Cursor indexes this field for semantic retrieval, allowing the model to dynamically load rules when user intent matches the description.
  - `globs`: Comma-separated file glob patterns (`flow/**,cards/**,*.md,src/**`). When the active file, diff, or query targets any matching path, Cursor injects the rule into context.
  - `alwaysApply: false`: **Targeted Activation Invariant**. When set to `false`, Cursor activates the rule selectively when working on project files matching `globs` (such as `flow/**` stage artifacts, `cards/**` unit tasks, project markdown, or `src/**` application source). This prevents context window waste on unrelated repository tasks while guaranteeing that Flow discipline constraints are strictly active whenever Flow assets or source files are touched. (By contrast, `alwaysApply: true` forces unconditional inclusion across all interactions, ignoring glob selectivity).
- **Parsing Strictness:** Malformed frontmatter (e.g., missing closing `---`, unquoted colons, invalid YAML indentation) causes Cursor to fail to parse the rule or drop it silently without active operator warning.
#### 2.2.3 Token Budgeting & Context Efficiency
Context window management is critical in Cursor Composer:
- **Token Degradation Hazards:** Even with large-context LLMs (such as Claude 3.7 Sonnet or GPT-4o), active Composer sessions consume context rapidly due to codebase indexing chunks, multi-file diff representations, and iterative terminal logs.
- **Progressive Disclosure Architecture:** Flow strictly rejects monolithic rule dumping. Flow's `.cursor/rules/flow.mdc` template is engineered to be ultra-lean:
  ```markdown
  ---
  description: Flow buildflow discipline layer and gated execution engine
  globs: flow/**,cards/**,*.md,src/**
  alwaysApply: false
  ---
  # Flow Discipline Rules for Cursor

  You are operating inside a repository managed by Flow (`/flow`).
  Flow turns coding agents into evidence-gated, kill-honest build processes.

  ## Rules of Engagement
  1. **Never edit files without an active card.** Check in-flight cards via `bash skills/flow/runner/flow.sh status`.
  2. **Always inspect gates before coding.** Run `bash skills/flow/runner/flow.sh next` or `bash skills/flow/runner/flow.sh check C-NNN`.
  3. **Respect Allowed Files.** Only modify files explicitly listed in the active card's `## Allowed files` section.
  4. **Never fake verify proof.** Paste real terminal output, exit codes, and URLs into `## Evidence`.
  ```
- **Context Budget Metrics:**
  - Exact size: **~480 characters** (~80 words, ~15 lines).
  - Context overhead: **~100 tokens** (< 0.1% of typical context windows).
  - Detailed stage playbooks (`research.md`, `build.md`, `gate-rules.md`) remain on disk under `skills/flow/references/` and are read on-demand via the agent's file-reading tools only when that specific lifecycle stage is active.

#### 2.2.4 YOLO Mode vs. Interactive Command Approval
Cursor Composer supports two operational execution models for terminal commands:
1. **Interactive Approval Mode (Default):**
   - Whenever Composer dispatches `run_terminal_cmd`, execution is suspended, and an interactive approval prompt is presented in the IDE UI for human confirmation.
   - *Impact on Flow:* If the developer clicks "Reject" or cancels the command, Composer receives an error or abort notification. Composer must strictly recognize this as an unverified operation and must **never** assume the gate passed.
2. **YOLO Mode (Auto-run / Autonomous Execution):**
   - The user enables auto-run for terminal commands, allowing Composer to execute shell tools continuously without manual approval dialogs.
   - *Impact on Flow:* In YOLO mode, Composer can autonomously run `flow status`, author code, and run `flow.sh next` or `flow.sh check C-NNN`. However, the agent remains strictly bound by the mechanical exit code contract: if `flow.sh` returns exit code `1`, Composer is forced to halt or iterate on repairs, eliminating unauthorized gate bypasses.

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: Silent Truncation & Middle-Out Context Clipping from Monolithic Rule Ingestion
- **The Failure Mode:**
  - An inexperienced integrator might attempt to copy Flow's entire `SKILL.md` (1,200+ lines, ~15,000 tokens) or concatenate all reference playbooks into `.cursor/rules/flow.mdc` or the legacy `.cursorrules` file.
  - In Cursor Composer, injecting an oversized rule file results in:
    1. **Middle-Out Context Truncation:** Cursor's context manager silently truncates oversized system prompt rules to preserve tokens for file context and chat history.
    2. **"Lost in the Middle" Attention Failure:** The model's attention mechanism degrades over lengthy rule blocks, causing it to disregard negative constraints (such as *"Never fake verify proof"* or *"Respect Allowed Files"*).
    3. **Severe Token Bloat:** Every conversational turn burns thousands of unnecessary tokens, increasing user latency and API costs.
- **The Anti-Illusion Mitigation:**
  - Flow enforces the **Progressive Disclosure Architecture** (`docs/harness-qualification-process.md` §2.4).
  - `.cursor/rules/flow.mdc` acts strictly as an **index router and invariant guard** (~100 tokens).
  - Core doc budgets across the Flow repository are strictly enforced and tested by `docs/doc-budgets.txt` and `scripts/check-doc-budgets.sh`.

### 3.2 Latent Trap 2: Windows Path Mapping, Shell Selection & WSL Traps
- **The Failure Mode:**
  - On Windows host workstations running Cursor, `run_terminal_cmd` may execute commands within PowerShell, Windows `cmd.exe`, Git Bash, or WSL depending on user preferences.
  - **The WSL Path Trap:** If PowerShell executes `bash skills/flow/runner/flow.sh`, Windows may resolve `bash.exe` to `C:\Windows\System32\bash.exe` (WSL) instead of Git Bash. WSL interprets Windows paths (`C:\Users\...`) differently (`/mnt/c/Users/...`), and if the workspace is located on a secondary drive (e.g., `D:\workspace`), WSL may fail completely with path mapping errors (`no such file or directory`).
  - **CRLF Line Endings:** Checking out repository files on Windows with Git `autocrlf=true` introduces `\r\n` line endings, causing shell scripts executed in POSIX environments to fail with `\r: command not found`.
- **The Anti-Illusion Mitigation:**
  - Flow ships a native Windows batch wrapper: `skills/flow/runner/flow.cmd`.
  - Scaffolding and documentation clearly specify dual invocation targets:
    ```markdown
    # On POSIX systems / Git Bash:
    bash skills/flow/runner/flow.sh <command>

    # On Windows (cmd.exe / PowerShell):
    skills\flow\runner\flow.cmd <command>
    ```
  - Both wrappers enforce identical exit code contracts and receipt formatting.

### 3.3 Latent Trap 3: Synthesized Pass Hallucinations vs. Mechanical Exit Code Checking
- **The Failure Mode:**
  - When asked to advance a stage or verify a card, an LLM agent operating in Composer may inspect `flow/00-idea.md` or `cards/C-NNN.md` with its file-reading tool, observe that the Markdown text appears well-structured, and declare:
    > *"Stage 00-idea looks completely filled out and valid! Advancing to stage 01-research."*
  - This is a catastrophic discipline failure ("quảng cáo ảo"): the agent bypassed mechanical verification, no hash receipts were generated, and `flow/01-research.md` was not unlocked on disk.
- **The Anti-Illusion Mitigation:**
  - The rule scaffolding injects strict, inviolable negative constraints:
    > *"Never declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing `exit code 0`."*
  - Mechanical gate enforcement guarantees that:
    1. A stage advance is valid **only if** `flow.sh next` executes with exit code $0$, unlocking `flow/01-research.md` on disk.
    2. A fresh invocation of `flow status` reads the unlocked stage directly from the filesystem.
    3. If the terminal tool fails, times out, or returns exit code $1$, the agent is mechanically blocked from proceeding.

---

## Section 4: Live Verification Runbook Checklist

This runbook specifies the step-by-step instructions for executing the **Four-Point Live Verification Protocol** for Cursor Composer & Agent Mode.

### 4.0 Interactive Qualification Invariant (Absence of Headless CLI)
Unlike CLI-first agents that provide non-interactive evaluation entrypoints (such as Antigravity's `agy -p` or Codex's `codex exec`), Cursor is an interactive graphical IDE. Subcommands like `cursor agent --help` or `cursor -p` fall through to generic VS Code and Chromium Electron flags rather than executing a headless agent session.

Consequently, host qualification **strictly requires an interactive Composer session** inside the Cursor IDE:
1. The evaluating engineer must open the isolated workspace in Cursor and launch Composer in **Agent Mode**.
2. A unique trial run nonce (e.g., `nonce-cursor-20261014-<uuid>`) must be generated and embedded in the test transcript to guarantee freshness and prevent evidence replay.
3. Raw model responses, `run_terminal_cmd` JSON payloads, terminal stdout/stderr logs, and mechanical exit codes must be captured directly from Composer and committed to `plans/research/harness-expansion/evidence/cursor-<version>-qualification-record.md`.
4. The test evaluates both integration pathways:
   - **Path 1 (Category A):** Global skill auto-discovery via `~/.cursor/skills/flow`.
   - **Path 2 (Category B):** Workspace rule ingestion via `.cursor/rules/flow.mdc` (`alwaysApply: false`).

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   ```bash
   git clone <repo-url> /tmp/flow-cursor-eval
   cd /tmp/flow-cursor-eval
   git checkout -b test/cursor-qualification
   ```
2. **Materialize Rule Scaffolding (Path 2 Setup):**
   ```bash
   # Materialize Cursor rule scaffold
   bash skills/flow/runner/flow.sh rules cursor --write
   # Verify creation and contents of .cursor/rules/flow.mdc
   test -f .cursor/rules/flow.mdc && echo "Cursor rule scaffold present."
   ```
3. **Verify Runner Permissions:**
   ```bash
   chmod +x skills/flow/runner/flow.sh
   ```
4. **Launch Cursor Workspace:**
   - Open `/tmp/flow-cursor-eval` in Cursor IDE: `cursor /tmp/flow-cursor-eval`.
   - Open Composer (Ctrl+I / Cmd+I) and ensure **Agent Mode** is selected.
   - Document exact host environment details:
     - Cursor Version: `[Capture Cursor version from Help -> About, e.g., 0.45.0]`
     - Composer Engine / Mode: `Agent Mode`
     - Underlying Model Identifier: `[e.g., Claude 3.7 Sonnet, GPT-4o]`
     - Operating System: `[e.g., Linux x64 / macOS arm64 / Windows x64]`
     - Active Nonce: `[e.g., nonce-cursor-20261014-a1b2c3d4]`
### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Context Loading & Rule Discovery)
- **Objective:** Verify Cursor Composer ingests `.cursor/rules/flow.mdc` (or `~/.cursor/skills/flow`) cleanly without YAML frontmatter parsing errors, schema warnings, or rule clipping.
- **Test Input (Canary Query in fresh Composer chat):**
  ```text
  What software development discipline governs this project, what commands are available to inspect status, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] Composer explicitly identifies Flow as the governing engineering discipline.
  - [ ] Composer cites `skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical command mechanism.
  - [ ] Composer does not report YAML frontmatter parsing errors or schema syntax rejections.
- **Empty Capture Placeholder:**
  ```text
  [RAW COMPOSER INGESTION RESPONSE CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 2: Invocation Audit (Terminal Execution Fidelity)
- **Objective:** Verify Composer dispatches a real tool call via `run_terminal_cmd` executing `flow.sh status` and correctly parses the returned stdout and exit code.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Evaluation Criteria:**
  - [ ] Composer issues a `run_terminal_cmd` tool call executing `bash skills/flow/runner/flow.sh status` (or `skills\flow\runner\flow.cmd status`).
  - [ ] The command executes in the terminal without path resolution or permission failures.
  - [ ] Composer receives stdout/stderr and integer exit code `0`.
  - [ ] Composer accurately summarizes the current stage (e.g., `00-idea`) and specifies the next recommended step.
- **Empty Capture Placeholder:**
  ```text
  [RAW TOOL CALL & TERMINAL OUTPUT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Composer halts when `flow.sh` exits with non-zero status ($\text{exit} \neq 0$) and strictly refuses to hallucinate that a failed gate passed.
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
  - [ ] Composer executes `bash skills/flow/runner/flow.sh next` via `run_terminal_cmd`.
  - [ ] The runner outputs failure diagnostics (e.g., `[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Composer strictly **HALTS**. It does **NOT** synthesize or claim the stage passed.
  - [ ] Composer quotes the runner diagnostic error message and proposes repairing the unfilled markers in `flow/00-idea.md`.
  - *(Note: If Composer claims the stage advanced despite exit code 1, the candidate is immediately marked **DISQUALIFIED**).*
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE-STOP TOOL EXECUTION & HALT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that `flow.sh next` unlocks `flow/01-research.md` on disk, and a fresh `flow status` invocation reads the unlocked stage directly from disk without state loss across a new Composer session.
- **Test Setup:**
  - Fill all `[FILL]` placeholders and check all boxes in `flow/00-idea.md` with complete, valid requirements.
- **Test Input 1 (Advancement):**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Composer executes `bash skills/flow/runner/flow.sh next` via `run_terminal_cmd`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed present on disk.
- **Test Input 2 (Session Restart & Fresh Readback):**
  - Close the active Composer panel and start a completely fresh Composer conversation thread.
  - Issue the canary readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Evaluation Criteria (Readback):**
  - [ ] Composer dispatches `run_terminal_cmd` executing `bash skills/flow/runner/flow.sh status`.
  - [ ] Composer reads back stage `01-research` directly from disk without state loss.
  - [ ] Zero resident daemons were required to maintain state between conversations.
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE 4 ADVANCEMENT & FRESH SESSION READBACK CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Upon completion of the live verification trial:
1. Capture all raw conversational messages, `run_terminal_cmd` JSON payloads, stdout/stderr streams, and mechanical exit codes.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/cursor-<version>-qualification-record.md
   ```
4. If and only if all four gates pass, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition Cursor from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT`.
