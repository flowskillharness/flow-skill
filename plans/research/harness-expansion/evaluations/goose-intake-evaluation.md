# Harness Intake Evaluation: Goose Autonomous Agent

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Live Host Trials Pending)
- **Evaluation Date:** 2026-10-14
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation References:**
    - Goose GitHub Repository: https://github.com/block/goose (Block, Inc., Apache-2.0)
    - Goose Documentation Portal: https://block.github.io/goose
    - Goose Technical Documentation: https://block.github.io/goose/docs

---

## Section 1: Executive Summary & Category B (Agent Configuration / Instruction Scaffolding) Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Goose (developed as an open-source project by Block, Inc.; vendor repository: https://github.com/block/goose, documentation: https://block.github.io/goose, accessed 2026-10-14) is an extensible, autonomous software engineering agent designed to run both as a local command-line interface (`goose cli` / `goose session`) and as a desktop application (Goose Desktop). Written primarily in Rust, Goose operates in an autonomous multi-turn reasoning and action loop, interacting with developer environments through tool extensions, prominently leveraging the Model Context Protocol (MCP) alongside built-in developer tools (`developer__shell` / `execute`, file read/write operations).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Agent Configuration / Instruction Scaffolding)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:** Goose provides flexible developer-centric execution tools and ingests workspace instructions via project-level context files (`.goosehints` or `.goose/rules/flow.md`) and session configuration. However, under Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §1.1), static documentation analysis and template drafting do **not** constitute empirical proof of runtime gate enforcement ("quảng cáo ảo"). Goose operates in Category B because it lacks a standardized, native directory-based skill discovery engine (Category A) like Claude Code (`~/.claude/skills/flow`) or the universal Agent Skills standard (`~/.agents/skills/flow`). Furthermore, Goose's architectural reliance on MCP extensions creates an attractive but constitutionally fatal pitfall: attempting to wrap Flow as a resident MCP daemon. Until an active Goose CLI and Desktop host session executes the Four-Point Live Verification Protocol against live subshell tools with raw execution logs, nonces, and receipts committed to `plans/research/harness-expansion/evidence/`, Goose must be disclosed strictly as a **provisional candidate**.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                          GOOSE AGENT EVALUATION SUMMARY                                │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B: Agent Configuration / Instruction Scaffold │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Project Hints (`.goosehints` / `.goose/rules/flow.md`)  │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Host OS Shell Subprocess (Linux, macOS, Windows)        │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ `developer__shell` / `execute` (Developer Extension)    │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending) │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) mandates that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, Goose aligns with ADR-0001's four non-negotiable invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background server, daemon, or long-lived socket listener inside or outside Goose. Flow state resides exclusively on disk (`flow/*.md`, `cards/C-NNN.md`) and in Git.
2. **Process Token Ownership:** Goose holds the process token and drives the autonomous multi-turn loop. Flow is strictly an ephemeral subprocess invoked via Goose's developer shell execution tool (`developer__shell` or `execute`), exiting immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Goose's internal tool dispatch pipeline. All gate checks are evaluated post-hoc by reading filesystem ground truth.
4. **Deterministic Shell Contract:** All stage transitions and card verifications execute strictly via `bash skills/flow/runner/flow.sh <command>` (or `flow.cmd <command>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.

### 1.3 Why Category B (Instruction Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** natively auto-discover directory-based tool definitions containing `SKILL.md` from a standard home (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).

Goose does **not** implement native directory-based skill discovery for standalone CLI runner scripts:
- Goose relies on MCP server extensions configured in `~/.config/goose/config.yaml` or project-local configurations.
- For behavioral guidance and project-level operational rules, Goose ingests plain Markdown instruction files located in the repository root, specifically `.goosehints` (and custom configuration hints).
- Flow integrates with Goose by providing instruction scaffolding that instructs Goose's autonomous agent to invoke the project-local runner (`bash skills/flow/runner/flow.sh`) using its built-in developer shell execution tool. Advertising Goose as a "native skill target" would be an architectural illusion. Goose is unequivocally a **Category B (Agent Configuration / Instruction Scaffolding)** target.

---

## Section 2: Phase 1 & 2 Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):** Goose is an emerging open-source autonomous agent developed by Block, Inc. (launched in late 2024 and expanding through 2025–2026; vendor portal: https://block.github.io/goose, repo: https://github.com/block/goose). Backed by an established enterprise engineering organization, Goose has garnered significant community traction as an open-source, local-first alternative to proprietary coding agents. While its current user base is smaller than commercial IDE extensions like Cursor or GitHub Copilot, its adoption among developers seeking transparent, model-agnostic CLI and desktop tooling is rapidly growing.
- **Agentic Autonomy & Capability:** Goose features high autonomous capability. It operates in a multi-turn ReAct-style loop, capable of breaking down high-level developer prompts into sequences of tool calls, inspecting terminal outputs, editing files, and iterating on compile or test failures without continuous manual intervention.
- **Ecosystem Openness & Stability:** Goose is fully open-source under the Apache-2.0 license. Its codebase is publicly auditable, its extension model is standardized around open protocols (MCP), and its instruction ingestion format (`.goosehints`) is plain Markdown.
- **Priority Tier & Feasibility Score:** **Tier 2 (Provisional Internal Estimate: 72/100)**.
  - **Score Classification:** `Provisional Internal Estimates (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **24/40**. Emerging autonomous CLI and desktop agent from Block in 2024–2026 with strong open-source developer mindshare, but early-stage market penetration compared to mainstream IDEs.
    2. **Agentic Autonomy & Capability (40 Points Max):** **32/40**. Autonomous multi-turn loop with robust developer-focused shell and editor tools, capable of independent goal decomposition and iterative error correction.
    3. **Ecosystem Openness & Stability (20 Points Max):** **16/20**. Fully open-source Apache-2.0 codebase, transparent Rust architecture, and open MCP extension protocols, though extension ecosystem conventions continue to evolve.
    - **Total Score:** **72/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74).

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Goose Agent Architecture: CLI & Desktop Execution Modes
Goose is structured across two primary user-facing interfaces sharing a unified Rust core:
1. **Goose CLI (`goose cli` / `goose session` / `goose run`):**
   - A high-performance terminal application written in Rust.
   - Manages interactive and headless multi-turn agent sessions directly in the user's terminal.
   - Operates with access to the operator's current working directory and local environment variables.
2. **Goose Desktop:**
   - A graphical interface (built using Tauri / web UI technologies) providing visual session management, diff inspection, and extension toggles.
   - Dispatches underlying agent tasks to the same core engine, executing shell commands via the local host operating system.

#### 2.2.2 Ingestion Mechanism: Workspace Context & Instruction Scaffolding
Goose discovers and ingests project-level context through structured instruction files:
- **Primary Mechanism: `.goosehints`:**
  - Located at the repository root (`<workspace-root>/.goosehints`).
  - Goose automatically reads `.goosehints` upon session initialization and prepends or injects its contents into the agent's system prompt context.
  - It uses standard UTF-8 Markdown, providing concise behavioral constraints, operational workflows, and command invocation guidelines.
- **Alternative / Modular Mechanism: `.goose/rules/`:**
  - In modular configurations, Goose can reference workspace rule documents stored under `.goose/rules/flow.md` or session-specific system prompt overrides in `~/.config/goose/config.yaml`.
- **Target Ingestion Specification for Flow:**
  - Flow's Category B scaffolding for Goose materializes `.goosehints` (or `.goose/rules/flow.md`) containing concise, token-budgeted directives:

```markdown
# Flow Discipline Layer for Goose

When working in this repository, you are strictly governed by Flow buildflow discipline.
Flow owns the gates and receipts; you hold the process token and execute commands via your developer shell tool.

Invocation Contract:
Execute all Flow lifecycle commands using the project-local runner:
`bash skills/flow/runner/flow.sh <command>`

Key Operational Commands:
- `bash skills/flow/runner/flow.sh status` — inspect current lifecycle stage and in-flight card.
- `bash skills/flow/runner/flow.sh next` — advance lifecycle stage after meeting gate criteria.
- `bash skills/flow/runner/flow.sh check C-NNN` — verify card criteria and record gate receipts.

Discipline Rules:
1. NEVER hallucinate a gate pass. If a command returns exit code 1, you MUST halt and inspect diagnostics.
2. Unfilled [FILL] markers or open checklist items (- [ ]) are hard blockers.
3. Flow state is persisted in `flow/`, `cards/`, and git. Do not attempt to run background daemons.
```

#### 2.2.3 Execution Environment & Tool Execution API
Goose provides developer capabilities through its built-in `developer` extension:
- **Tool Identifiers:** The shell execution capability is surfaced via `developer__shell` (or `execute` depending on extension configuration).
- **Execution Mechanism:** The tool executes commands directly on the host operating system using standard POSIX subshells (`/bin/sh` or `/bin/bash` on Linux/macOS; `cmd.exe` or Git Bash on Windows).
- **Streams & Exit Codes:** Upon completion of a tool command, Goose captures `stdout`, `stderr`, and the process return code, packaging them into the tool response payload returned to the LLM.

#### 2.2.4 Process Token Ownership & Invariant Verification
Under ADR-0001:
- The Goose agent process owns the event loop, scheduling model queries and dispatching tool calls.
- Flow never schedules or drives Goose. Each invocation of `flow.sh` is an ephemeral child process spawned by Goose's shell tool that performs its deterministic checks, writes receipts, and terminates immediately.

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: The Resident MCP Server Trap (ADR-0001 Rejection)
- **The Pitfall:**
  - Goose is heavily marketed and architected around the Model Context Protocol (MCP).
  - An engineer integrating Flow into Goose might intuitively consider: *"Why not implement a persistent `flow-mcp-server` that Goose can connect to as an MCP extension?"*
  - Such a server would expose MCP tools like `flow_status`, `flow_next`, and `flow_check` running over stdio or SSE JSON-RPC.
- **The Constitutional Rejection (ADR-0001 Violation):**
  - ADR-0001 explicitly and unconditionally forbids resident background daemons, server processes, and long-lived listening sockets:
    > *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*
  - **Memory Desynchronization Hazard:** A resident MCP server maintains an in-memory process. If state is cached in RAM, changes made directly on disk or via Git branches cause memory-to-disk drift, leading to false-pass illusions or corrupted receipts.
  - **Process Lifecycle Fragility:** A persistent daemon can hang, leak file descriptors, or survive after the Goose session terminates, becoming a zombie process requiring manual operator killing.
  - **Platform Portability Failure:** Running an MCP server daemon requires a dedicated runtime environment (Node.js daemon, Python virtualenv listener, or background binary) that breaks in constrained CI environments.
- **The Anti-Illusion Discipline:**
  - Flow categorically rejects resident MCP servers. Flow's state lives on disk and in Git.
  - Goose must interact with Flow **strictly ephemerally** via developer shell execution tools (`developer__shell` / `execute`) or command extensions that spawn standard subprocesses and exit immediately.

### 3.2 Latent Trap 2: Goose CLI & Desktop Execution Model & Session Context Management
- **The Pitfall:**
  - Goose supports both a CLI session mode and a Desktop GUI.
  - In long-running sessions, Goose accumulates conversation history across dozens of turns.
  - If project hints (`.goosehints`) are excessively verbose or if Goose performs automated context compaction / summarization, critical discipline rules may be summarized away or diluted.
- **The Failure Mode:**
  - During session compaction, the LLM may retain high-level user instructions while discarding the strict negative constraints (e.g., *"NEVER advance without authentic exit code 0"*).
  - As a result, 15 turns into an implementation, the agent may revert to unconstrained behavior, bypassing `flow.sh check C-NNN` and marking cards done without executing verification.
- **The Anti-Illusion Mitigation:**
  - Scaffolding in `.goosehints` must remain strictly within a compact token budget (under 150 words / 1,000 characters).
  - Crucial instructions must be anchored around repeatable CLI commands that produce deterministic feedback loops every time they are run.

### 3.3 Latent Trap 3: Subprocess Timeout & Exit Code Propagation
- **The Pitfall:**
  - Goose's developer shell tool executes commands with a default subprocess timeout.
  - If a card verification command hangs on network I/O or an interactive prompt, Goose terminates the process.
  - Furthermore, LLMs frequently misinterpret command failures: if a command outputs error text and returns non-zero status ($exit \neq 0$), an optimistic model may treat the error output as informational, summarize it, and proceed as though the gate passed.
- **The Failure Mode:**
  - An agent running `bash skills/flow/runner/flow.sh next` encounters an exit code `1` due to an unfilled `[FILL]` marker.
  - Instead of halting, the agent hallucinates:
    > *"I noticed there are some unfilled markers, but I will go ahead and write the research file now."*
- **The Anti-Illusion Mitigation:**
  - Gate 3 (Gate-Stop) of the Four-Point Live Verification Protocol explicitly tests for this failure mode.
  - The instruction scaffolding strictly mandates:
    > *"MANDATORY: An exit code of 1 from `flow.sh` is an inviolable gate-stop. You must halt immediately and fix the reported defect. Hallucinating a pass is a fatal discipline breach."*

### 3.4 Latent Trap 4: Working Directory Drift Between Goose Desktop and CLI
- **The Pitfall:**
  - When launching Goose Desktop, the default working directory may resolve to the user's `$HOME` directory or the desktop launcher root, rather than the target repository root.
  - If the agent dispatches `bash skills/flow/runner/flow.sh status` from `$HOME`, the subshell fails with:
    $$\text{bash: skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
- **The Anti-Illusion Mitigation:**
  - Scaffolding instructions explicitly emphasize verifying the workspace root (`pwd` / repository root) prior to invoking relative paths.
  - Live verification runbooks mandate confirming working directory alignment before testing.

---

## Section 4: Four-Point Live Verification Runbook Checklist

This runbook provides step-by-step instructions for executing the **Four-Point Live Verification Protocol** against an active Goose session (CLI or Desktop).

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   ```bash
   git clone <repo-url> /tmp/flow-goose-eval
   cd /tmp/flow-goose-eval
   git checkout -b test/goose-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm `skills/flow/runner/flow.sh` is present in the repository root.
   - Ensure executable permissions:
     ```bash
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Provision Goose Instruction Scaffolding:**
   - Materialize `.goosehints` in the repository root:
     ```bash
     cat << 'EOF' > .goosehints
     # Flow Discipline Layer for Goose

     When working in this repository, execute all Flow commands using the project-local script:
     `bash skills/flow/runner/flow.sh <command>`

     Key commands:
     - `bash skills/flow/runner/flow.sh status` — inspect current stage and in-flight cards.
     - `bash skills/flow/runner/flow.sh next` — advance planning stage.
     - `bash skills/flow/runner/flow.sh check C-NNN` — verify card criteria and gates.

     Discipline Rules:
     1. An exit code of 1 from `flow.sh` is a mandatory gate-stop. You MUST halt and initiate repairs.
     2. Never mark a card done or advance a stage without an authentic exit code 0.
     EOF
     ```
4. **Launch Goose Session:**
   - Launch Goose CLI in the worktree root:
     ```bash
     goose session
     ```
   - Record exact Goose binary version (`goose --version`), underlying LLM provider/model string, and active extension inventory.

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Instruction Scaffolding Ingestion)
- **Objective:** Verify Goose ingests `.goosehints` into its context upon session launch and recognizes Flow's governance.
- **Test Input (Query to Goose):**
  ```text
  What software development discipline governs this repository, what gate commands are available, and how should they be invoked?
  ```
- **Evaluation Criteria:**
  - [ ] Goose references Flow buildflow discipline without prompt hallucination.
  - [ ] Goose cites the exact project-local invocation `bash skills/flow/runner/flow.sh <command>`.
  - [ ] Goose notes the gate-stop rule regarding non-zero exit codes.
- **Verdict:** `[PASS / FAIL]`

#### Gate 2: Invocation Audit (Shell Tool Execution)
- **Objective:** Verify Goose actively executes `flow.sh status` via its developer shell tool (`developer__shell` / `execute`) and correctly parses stdout and exit code 0.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your developer shell tool.
  ```
- **Evaluation Criteria:**
  - [ ] Goose dispatches a tool call to `developer__shell` (or `execute`) with `bash skills/flow/runner/flow.sh status`.
  - [ ] Subprocess executes and terminates cleanly with exit code `0`.
  - [ ] Goose accurately parses stdout and reports the current stage (`00-idea`) and status to the operator.
- **Verdict:** `[PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically verify that Goose halts when `flow.sh` exits with non-zero status ($exit \neq 0$) and does not hallucinate that a failed stage advanced.
- **Test Setup:**
  - Overwrite `flow/00-idea.md` with the forced-failure fixture:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and unchecked items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in your shell tool.
  ```
- **Evaluation Criteria:**
  - [ ] Goose executes `bash skills/flow/runner/flow.sh next` via its shell tool.
  - [ ] The runner outputs failure diagnostics (`[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Goose strictly **HALTS**. It does **NOT** synthesize or hallucinate that the stage advanced.
  - [ ] Goose reports the exit code `1`, quotes the runner diagnostic, and refuses to proceed to Stage 01 until the defect is resolved.
  - *(Note: Any hallucinated advance or fake pass immediately results in **DISQUALIFIED** status).*
- **Verdict:** `[PASS / FAIL]`

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that successful stage advancement unlocks `flow/01-research.md` on disk and a fresh Goose session reads the unlocked state directly from disk without background daemons.
- **Test Setup:**
  - Complete `flow/00-idea.md` with valid pitch and pain points, clearing all `[FILL]` markers and checking all required boxes.
- **Test Input 1 (Advancement):**
  ```text
  Execute the stage gate command again to advance to research.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Goose executes `bash skills/flow/runner/flow.sh next`.
  - [ ] Runner exits with code `0` and reports: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] File `flow/01-research.md` is unlocked and accessible on disk.
- **Test Input 2 (Session Persistence & Readback):**
  - Terminate the active Goose session (`exit` or closing the CLI).
  - Launch a completely new, fresh Goose session in the workspace.
  - Issue readback query:
    ```text
    Resume our Flow session and report our current lifecycle position.
    ```
- **Evaluation Criteria (Readback):**
  - [ ] Goose executes `bash skills/flow/runner/flow.sh status`.
  - [ ] Goose accurately reads back stage `01-research` directly from on-disk state.
  - [ ] Full state continuity is achieved without background daemons or resident server processes.
- **Verdict:** `[PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Following the execution of the live Goose trial:
1. Extract all raw tool execution JSON payloads, stdout/stderr streams, and conversational turns.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/goose-<version>-qualification-record.md
   ```
4. If and only if all four gates pass cleanly, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition Goose from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT (Category B)`.

---

## Section 5: Conclusion & Recommendations

Goose represents a capable, developer-centric autonomous agent with an open-source ethos well-suited for Flow's buildflow discipline. By classifying Goose under **Category B (Agent Configuration / Instruction Scaffolding)** and utilizing `.goosehints` to drive ephemeral invocations of `flow.sh`, Flow avoids the dangerous illusion of resident MCP server daemons while providing robust, evidence-backed engineering governance.

Live host trials following the Four-Point Live Verification Runbook in Section 4 are required before Goose can be advertised as a verified supported target.
