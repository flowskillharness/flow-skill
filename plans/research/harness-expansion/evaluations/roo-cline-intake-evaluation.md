# Harness Intake Evaluation: Roo Code & Cline

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
  - **Official Vendor Documentation References:**
    - Roo Code:
      - Repository & Source: https://github.com/RooCodeInc/Roo-Code (transitioned from RooVetGit/Roo-Code)
      - Custom Modes & Configuration: https://github.com/RooCodeInc/Roo-Code#custom-modes
      - Project Portal: https://roocode.com
      - VS Code Marketplace ID: `RooVeterinaryInc.roo-cline` (~2.1M installs recorded Oct 2026, repository points to `RooCodeInc/Roo-Code`).
    - Cline:
      - Repository & Source: https://github.com/cline/cline (originally created as Claude Dev)
      - Custom Rules Documentation: https://docs.cline.bot/customization/cline-rules
      - Project Portal: https://docs.cline.bot
---

## Section 1: Executive Summary & Category B (Rule Scaffolding) Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Cline (originally developed by Saoud Rizwan as Claude Dev) and its community fork Roo Code are autonomous AI coding agent extensions for VS Code, Cursor, and VSCodium. Both extensions embed an autonomous multi-turn reasoning and tool-execution loop directly within the developer's editor, operating with native file editing, terminal execution (`execute_command`), diff inspection, and browser automation capabilities.

While Cline utilizes root-level or modular Markdown prompt injection (`.clinerules`), Roo Code introduces a structured JSON custom mode architecture (`.roomodes`) providing role segregation, tailored system prompt directives, and granular tool-group permission controls (`groups: ["read", "edit", "command"]`).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Workspace Rule Scaffolding)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:** Flow generates verified, syntax-valid scaffolding for both harnesses:
  - Roo Code: `.roomodes` materialized via `bash skills/flow/runner/flow.sh rules roo --write`.
  - Cline: `.clinerules` materialized via `bash skills/flow/runner/flow.sh rules cline --write`.

Crucially, neither extension implements directory-based skill auto-discovery (`Category A`). Both operate strictly under **Category B (Workspace Rule Scaffolding)** via prompt injection files. Under Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §1.1), static rule generation and installer parity do **not** constitute empirical proof of runtime gate enforcement ("quảng cáo ảo"). Until independent active VS Code sessions running Roo Code and Cline each execute their own dedicated Four-Point Live Verification Protocol with raw tool execution transcripts, exit codes, and fresh nonces committed to `plans/research/harness-expansion/evidence/`, both Roo Code and Cline must be transparently disclosed as **provisional candidates** rather than certified live harnesses.
```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        ROO CODE & CLINE EVALUATION SUMMARY                             │
├──────────────────────────────┬────────────────────────────┬────────────────────────────┤
│ Dimension                    │ Roo Code                   │ Cline                      │
├──────────────────────────────┼────────────────────────────┼────────────────────────────┤
│ Architectural Classification │ Category B (Rule Scaffold) │ Category B (Rule Scaffold) │
├──────────────────────────────┼────────────────────────────┼────────────────────────────┤
│ Configuration Mechanism      │ `.roomodes` (JSON schema)  │ `.clinerules` (Markdown)   │
├──────────────────────────────┼────────────────────────────┼────────────────────────────┤
│ Execution Tool API           │ `execute_command`          │ `execute_command`          │
├──────────────────────────────┼────────────────────────────┼────────────────────────────┤
│ Tool Permission Governance   │ Tool Groups (`command`)    │ Interactive Approval Prompt│
├──────────────────────────────┼────────────────────────────┼────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed)│ PROVISIONAL (Desk-Reviewed)│
├──────────────────────────────┼────────────────────────────┼────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE      │ PROVISIONAL CANDIDATE      │
└──────────────────────────────┴────────────────────────────┴────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In design review, both Roo Code and Cline align with ADR-0001's four non-negotiable invariants (empirical verification pending live trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or listening socket inside or outside the VS Code extension host.
2. **Process Token Ownership:** Roo Code and Cline hold the process token and manage the conversational event loop. Flow is strictly an ephemeral subprocess invoked by the agent via `execute_command`, terminating immediately upon returning its exit code.
3. **Zero Tool Interposition:** Flow does not wrap, proxy, or intercept the extension's internal tool dispatch pipeline. All gate checks are performed post-hoc by reading filesystem ground truth (`flow/*.md`, `cards/C-NNN.md`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** All lifecycle stage transitions and card verifications occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.

### 1.3 Why Category B (Rule Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** implement native directory-based skill discovery (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).

Neither VS Code, Roo Code, nor Cline implement directory-based skill auto-discovery:
- They do not auto-scan `~/.vscode/skills/`, `~/.roo/skills/`, or `~/.cline/skills/` for `SKILL.md` bundles.
- Roo Code requires a `.roomodes` JSON declaration in the workspace root (or global storage) to define custom modes and grant tool permissions.
- Cline requires a `.clinerules` Markdown file at the workspace root (or modular `.clinerules/*.md`) to inject system instructions.
- Flow interacts with both environments by generating lightweight configuration scaffolding that instructs the host agent to invoke Flow's runner CLI. Designating Roo Code or Cline as "native skill targets" would be an illusion trap that misleads developers. They are unequivocally **Category B (Workspace Rule Scaffolding)** targets.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Adoption & Ecosystem Context:** VS Code maintains extensive developer adoption worldwide. Within the open-source VS Code extension ecosystem, Cline and Roo Code represent widely deployed autonomous coding agent extensions with active community engagement and significant marketplace distribution (observed across 2024–2026).
- **Fork Relationship & Maintenance Reality:**
  - **Cline:** Originally launched as Claude Dev by Saoud Rizwan, Cline established an early model for in-editor autonomous multi-turn execution with terminal and file tools. Hosted at `https://github.com/cline/cline` under the Apache-2.0 license, with documentation at `https://docs.cline.bot`.
  - **Roo Code:** Originated as an open-source community fork of Cline (initially under the `RooVetGit/Roo-Code` repository, subsequently transitioning to the `RooCodeInc/Roo-Code` organization and repository). Roo Code added custom modes (`.roomodes`), fine-grained tool permissions (`fileRegex`, `commandRegex`), and token optimization features.
  - **Maintenance Reality:** Both projects operate on separate release cadences, distinct governance models, and independent community forks. Roo Code's repository transition reflects active organization restructuring. Flow must evaluate and maintain support for them as distinct host targets, avoiding conflated assumptions about their configuration surfaces or runtime behaviors.
- **Agentic Autonomy:** Both agents run autonomous multi-turn loops capable of complex reasoning, AST-aware file editing, diff application, and command execution.
- **Ecosystem Openness & Stability:** Both projects maintain public GitHub repositories under permissive open-source licenses (Apache 2.0 / MIT). Configuration schemas are publicly documented and inspectable.
- **Category B Invariant:** Neither extension provides a native directory-based skill loader (e.g. `~/.roo/skills/` or `~/.cline/skills/`). Consequently, both remain strictly **Category B (Workspace Rule Scaffolding)** candidates requiring scaffold generation and active host verification.
- **Feasibility Tier Scores (Provisional Internal Estimates (Desk Intake)):**
  - **Roo Code (80/100):** Market Share & Adoption (32/40 - citing VS Code Marketplace extension `RooVeterinaryInc.roo-cline` with ~2.1M installs as of Oct 2026), Agentic Autonomy (32/40 - multi-turn loop, execute_command tool, fine-grained mode isolation), Ecosystem Openness & Stability (16/20 - open source Apache-2.0, documented .roomodes schema, organization transition from RooVetGit to RooCodeInc). Priority Tier 1 candidate.
  - **Cline (72/100):** Market Share & Adoption (30/40 - established install base as original Claude Dev), Agentic Autonomy (26/40 - full autonomous loop, but tool permissions depend on interactive operator confirmations without mode scoping), Ecosystem Openness & Stability (16/20 - open source Apache-2.0). Priority Tier 2 candidate.
### 2.2 Phase 2: Architecture Probing

#### 2.2.1 VS Code Extension Agent Architecture
Roo Code and Cline share a common architectural heritage as TypeScript extensions running within the VS Code Extension Host:
- **Process Architecture:** The extension runs within the Node.js extension host process (`code --extensionHostProcess`). It communicates with the user via a React-based WebView panel mounted in the primary or secondary sidebar.
- **LLM Provider Abstraction:** The extension coordinates API requests across diverse inference providers (Anthropic Claude, OpenAI, DeepSeek, AWS Bedrock, GCP Vertex AI, Ollama) using an internal message-history orchestrator.
- **Autonomous Execution Loop:**
  ```
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 1. User Prompt + Ingested Rules (.roomodes / .clinerules)              │
  └───────────────────────────────────┬────────────────────────────────────┘
                                      ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 2. Model API Turn (Reasoning + Tool Call Generation)                   │
  └───────────────────────────────────┬────────────────────────────────────┘
                                      ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 3. Tool Permission & Approval Check (Auto-Approve vs. Operator Modal)  │
  └───────────────────────────────────┬────────────────────────────────────┘
                                      ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 4. Native Tool Invocation (`execute_command` running `flow.sh`)         │
  └───────────────────────────────────┬────────────────────────────────────┘
                                      ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 5. Capture stdout, stderr, and Exit Code (0 vs. 1)                     │
  └───────────────────────────────────┬────────────────────────────────────┘
                                      ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 6. Feedback to Model Context Window -> Next Action or Gate Stop        │
  └────────────────────────────────────────────────────────────────────────┘
  ```
- **Terminal Execution API (`execute_command`):** Both extensions execute commands by spawning subprocesses or interacting with the VS Code integrated terminal. They capture stdout, stderr, and the process exit code, streaming output back to the model context.

#### 2.2.2 Roo Code `.roomodes` JSON Custom Mode Schema
Roo Code elevates extension configuration by supporting user-defined custom modes via `.roomodes` in the workspace root.

##### Schema Field Specifications:
- `slug` *(string, required)*: Unique, machine-readable mode identifier (alphanumeric and dashes). Must match the active mode selector (e.g., `"flow"`).
- `name` *(string, required)*: Human-readable display label shown in the mode selector dropdown (e.g., `"Flow Discipline"`).
- `roleDefinition` *(string, required)*: The foundational system prompt injected into the LLM context for this mode. It sets the agent's persona, negative constraints, and operational guidelines.
- `groups` *(array, required)*: Specifies the exact tool groups available to this mode. Entries can be plain strings or two-element configuration tuples:
  - String format: `"read"` (enables `read_file`, `list_files`, `list_code_definition_names`, `search_files`).
  - Tuple format: `[groupName, { options }]`
    - `"edit"`: Controls file-writing tools (`write_to_file`, `replace_in_file`). Accepts `fileRegex` to restrict modifications to specific path patterns.
    - `"command"`: Controls terminal execution (`execute_command`). Accepts `commandRegex` to restrict executable command patterns.
    - `"browser"`: Controls browser automation tools (`browser_action`).
    - `"mcp"`: Controls Model Context Protocol tool access.

##### Flow's Scaffolding Specification for Roo Code:
Materialized by `bash skills/flow/runner/flow.sh rules roo --write` into `.roomodes`:
```json
{
  "customModes": [
    {
      "slug": "flow",
      "name": "Flow Discipline",
      "roleDefinition": "You are a disciplined software engineer operating under Flow gates. You never write code without an active card and you verify all changes against card criteria.",
      "groups": [
        "read",
        ["edit", { "fileRegex": "^(cards/.*|src/.*|tests/.*|flow/.*)$", "description": "Flow and source directories" }],
        ["command", { "commandRegex": "^bash skills/flow/runner/flow\\.sh.*", "description": "Flow runner execution" }]
      ]
    }
  ]
}
```

#### 2.2.3 Cline `.clinerules` Markdown Prompt Injection
Cline adheres to a Markdown-centric rule ingestion model:
- **Workspace Discovery:** Cline automatically reads `.clinerules` at the workspace root when starting any task. In modern versions, it additionally ingests individual Markdown rule files located within `.clinerules/*.md`.
- **System Prompt Insertion:** The contents of `.clinerules` are appended directly into the system prompt's rules section.
- **Flow's Scaffolding Specification for Cline:**
  Materialized by `bash skills/flow/runner/flow.sh rules cline --write` into `.clinerules`:
  ```markdown
  # Flow Discipline Rules for Cline

  1. Before starting tasks, execute `bash skills/flow/runner/flow.sh status` to identify the active stage and card.
  2. If planning is in progress, do not modify application code. Complete stage artifacts in `flow/` first.
  3. If building a card:
     - Read `cards/C-NNN.md`.
     - Strictly honor `## Allowed files`.
     - Execute verification tests with `bash skills/flow/runner/flow.sh check C-NNN`.
  4. Never mark a card done without real, verified command output in `## Evidence`.
  ```

#### 2.2.4 Critical Invariant: The `"command"` Group Requirement
In Roo Code's architecture, tool groups are strictly restrictive: **if a tool group is omitted from `groups`, the corresponding tools are completely stripped from the tool definitions sent to the LLM.**

##### The Fatal Failure Cascade of Omitting `"command"`:
1. If a `.roomodes` entry configures only `groups: ["read", "edit"]` and omits `"command"`, Roo Code will not expose `execute_command` to the model.
2. When an operator asks the agent to advance the stage (`flow next`) or verify a card (`flow check C-NNN`), the model is physically incapable of running Flow's runner script.
3. Because LLMs are tuned to be helpful and complete instructions, the model will attempt an unauthorized shortcut:
   - It reads `flow/00-idea.md` using `read_file`.
   - It observes that the text looks coherent.
   - It synthesizes a **hallucinated gate pass** in its conversational response:
     > *"I have verified the idea stage and all criteria are satisfied. Stage 00-idea passed! We are now in stage 01-research."*
4. **Discipline Failure:** No gate was executed, no exit code was returned, and the next stage artifact was never unlocked on disk.

##### The Anti-Illusion Enforcement:
- The `"command"` group is a **mandatory invariant** in Roo Code configuration.
- To balance safety and autonomy, Flow uses a scoped command tuple:
  `["command", { "commandRegex": "^bash skills/flow/runner/flow\\.sh.*", "description": "Flow runner execution" }]`
  This explicitly permits the agent to invoke Flow's runner CLI while preventing unconstrained execution of arbitrary commands.

#### 2.2.5 Execution Invariants: Zero Resident Daemons
- Neither Roo Code nor Cline require or spawn a resident Flow daemon.
- Every invocation of `flow.sh` or `flow.cmd` executes as an ephemeral child process of the extension host, running tests or checking gate conditions, writing receipts to disk, and terminating immediately.

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: Permission Prompt Exhaustion & Terminal Auto-Approval
- **The Failure Mode:**
  - By default, both Roo Code and Cline require manual human confirmation for every tool execution that modifies state or runs commands.
  - A rigorous Flow lifecycle task involves multiple command invocations: inspecting status (`flow status`), checking preflight conditions, running linters and test suites, checking card evidence (`flow check C-NNN`), and advancing the stage (`flow next`).
  - This results in **Permission Prompt Exhaustion**: the operator is bombarded with 8–15 modal approval popups within a few minutes.
  - Under fatigue, operators often:
    1. Accidentally reject a command, causing the agent to abort or attempt an unverified hallucinated fallback.
    2. Reflexively check "Always allow execution of all commands", exposing their workstation to unconstrained shell operations.
- **The Anti-Illusion Mitigation:**
  - **In Roo Code:** Scaffolding leverages Roo Code's `commandRegex` setting within `.roomodes`:
    ```json
    ["command", { "commandRegex": "^bash skills/flow/runner/flow\\.sh.*", "description": "Flow runner execution" }]
    ```
    This allows operators to enable auto-approval specifically for Flow's deterministic runner commands, maintaining strict safety for all other arbitrary shell commands.
  - **In Cline:** Operators should be guided to configure trusted command prefixes in Cline's settings panel, ensuring Flow commands execute smoothly while preserving interactive guardrails.

### 3.2 Latent Trap 2: Context Budgeting for `.clinerules` & `.roomodes`
- **The Failure Mode:**
  - Naive integrations attempt to inline Flow's entire `SKILL.md` (1,200+ lines, ~15,000 tokens) or all 24 reference playbooks directly into `.clinerules` or `.roomodes`.
  - In VS Code extensions, this prompt bloat leads to:
    1. **Context Choke:** System prompt overhead consumes a massive portion of the LLM context window, leaving inadequate headroom for large codebases, diff hunks, and terminal outputs.
    2. **"Lost in the Middle" Degradation:** Critical negative constraints (e.g., "never declare a gate passed without exit code 0") become diluted and ignored when buried in thousands of lines of documentation.
    3. **Economic Waste:** Re-sending 15,000 tokens on every conversational turn drastically inflates API costs and latency.
- **The Anti-Illusion Mitigation:**
  - Flow enforces the **Progressive Disclosure Architecture** (`docs/harness-qualification-process.md` §2.4):
    - `.clinerules` and `.roomodes` serve strictly as **compact index routers**:
      - `.roomodes` `roleDefinition` is lean (~35 words, ~250 characters).
      - `.clinerules` is concise (~100 words, ~500 characters, 4 core rules).
    - The agent is instructed to read specific reference playbooks in `skills/flow/references/*.md` (e.g., `gate-rules.md`, `research.md`, `build.md`) on demand when entering that specific lifecycle stage.
    - Core doc budgets are governed and tested by `docs/doc-budgets.txt` and `scripts/check-doc-budgets.sh`.

### 3.3 Latent Trap 3: Cross-Platform Shell Differences (POSIX Bash vs. Windows `flow.cmd`)
- **The Failure Mode:**
  - On Windows workstations, VS Code's integrated terminal defaults to PowerShell or `cmd.exe`.
  - When `.clinerules` or prompt instructions instruct the agent to run `bash skills/flow/runner/flow.sh`:
    1. If `bash.exe` resolves to WSL (`C:\Windows\System32\bash.exe`) instead of Git Bash (`C:\Program Files\Git\bin\bash.exe`), WSL often fails to translate the Windows workspace path (`C:\Users\...` vs. `/mnt/c/Users/...`).
    2. Non-C drive volumes (`D:\`, `E:\`, network drives) are frequently unmapped in WSL, triggering fatal `cd: no such file or directory` errors.
    3. Windows checkouts with CRLF line endings cause bash syntax errors (`\r: command not found`).
- **The Anti-Illusion Mitigation:**
  - Flow ships a native Windows batch wrapper: `skills/flow/runner/flow.cmd`.
  - Scaffolding and runbooks explicitly document dual invocation syntax:
    ```markdown
    # On Linux / macOS / Git Bash:
    bash skills/flow/runner/flow.sh <command>

    # On Windows (cmd.exe / PowerShell):
    .\skills\flow\runner\flow.cmd <command>
    ```
  - Windows lifecycle execution is continuously verified by `tests/test_flow_windows_lifecycle.sh` in Flow's CI.

### 3.4 Latent Trap 4: Synthesized Pass Hallucination & The MCP Daemon Trap
- **Synthesized Pass Hallucination:**
  - If terminal execution fails or is denied, models may attempt to "please" the user by asserting that stage artifacts or cards are complete without running tests.
  - Scaffolding explicitly injects an inviolable negative constraint:
    > *"NEVER declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing `exit code 0`. If terminal execution is disabled or rejected, STOP immediately."*
- **The MCP Daemon Trap (ADR-0001 Violation):**
  - Proponents often suggest wrapping Flow as a long-lived Model Context Protocol (MCP) server configured in `cline_mcp_settings.json` or `roo_mcp_settings.json`.
  - **Constitutional Rejection:** ADR-0001 strictly bans resident background servers. An MCP server running continuously in memory introduces stale filesystem caching, lock contention across multi-window VS Code sessions, and interposition hazards that obscure exit code truth. Flow interacts with Roo Code and Cline strictly via ephemeral CLI commands.

---

## Section 4: Live Verification Runbook Checklist

This runbook specifies the step-by-step instructions for conducting the **Four-Point Live Verification Protocol**. Because Roo Code and Cline implement fundamentally different configuration mechanisms (Roo Code utilizes structured JSON `.roomodes` with explicit tool group permissions, while Cline utilizes root-level Markdown `.clinerules` system prompt injection), each host requires its own isolated verification checklist, test runbook, and evidence record.

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   ```bash
   git clone <repo-url> /tmp/flow-eval-workspace
   cd /tmp/flow-eval-workspace
   git checkout -b test/harness-qualification
   ```
2. **Verify Runner Permissions:**
   ```bash
   chmod +x skills/flow/runner/flow.sh
   ```
3. **Isolation Principle:**
   - Do not test Roo Code and Cline simultaneously in the same workspace directory. Test each extension in an isolated session or clean clone to prevent rule ingestion cross-contamination between `.roomodes` and `.clinerules`.

---

### 4.2 Roo Code Four-Point Live Verification Protocol Runbook & Checklist

#### 4.2.0 Roo Code Test Environment Setup
1. **Materialize Roo Code Scaffolding:**
   ```bash
   bash skills/flow/runner/flow.sh rules roo --write
   test -f .roomodes && echo "Roo Code mode scaffold present."
   ```
2. **Launch VS Code with Roo Code:**
   - Open workspace: `code /tmp/flow-eval-workspace`.
   - Ensure the official Roo Code extension (`rooveterinaryinc.roo-cline`) is active.
   - Open the Roo Code panel in the sidebar.
   - Open the mode dropdown selector and switch to the **Flow Discipline** mode (`slug: flow`).
   - Document exact host environment details:
     - Roo Code Extension Version: `[e.g., v3.8.1]`
     - VS Code Version: `[e.g., 1.98.0]`
     - Underlying Model Identifier: `[e.g., claude-3-7-sonnet-20250219]`
     - Host Operating System: `[e.g., Linux x86_64 / macOS arm64 / Windows x64]`

#### Gate 1: Ingestion Audit (Context Loading & `.roomodes` JSON/customModes Structure Check)
- **Objective:** Verify that Roo Code parses the `.roomodes` custom mode definition cleanly (performing a JSON/customModes structure check, clarifying that formal host acceptance belongs to the interactive live trial), activates the `flow` mode, injects the `roleDefinition` system prompt, and correctly provisions the configured tool groups (`read`, `edit`, `command`).
- **Test Input (Canary Query in a fresh conversation):**
  ```text
  What software development discipline governs this project, what commands are available to check status, and what is our current stage?
  ```
- **Observable Criteria:**
  - [ ] Roo Code parses `.roomodes` without JSON/customModes structure errors or missing customModes notifications (formal host acceptance verified during the interactive live trial).
  - [ ] Mode selector displays "Flow Discipline" (`slug: flow`).
  - [ ] Agent explicitly identifies Flow as the governing engineering discipline.
  - [ ] Agent cites `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical execution mechanism.
  - [ ] Agent acknowledges the operational constraints of the active Flow Discipline mode.
- **Verdict:** `[PASS / FAIL]`

#### Gate 2: Invocation Audit (`execute_command` Tool Execution Fidelity)
- **Objective:** Verify that Roo Code dispatches `execute_command` executing `flow.sh status`, satisfies the `commandRegex` filter (`^bash skills/flow/runner/flow\.sh.*`), and correctly parses stdout and exit code `0`.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Observable Criteria:**
  - [ ] Agent dispatches `execute_command` with payload `bash skills/flow/runner/flow.sh status` (or `skills\flow\runner\flow.cmd status`).
  - [ ] The command matches `.roomodes` `commandRegex` and executes in the integrated terminal without permission aborts or path errors.
  - [ ] Agent captures stdout, stderr, and integer exit code `0`.
  - [ ] Agent accurately reports the current stage (e.g., `00-idea`) and the next recommended action to the operator.
- **Verdict:** `[PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Roo Code strictly halts when a gate fails ($\text{exit} \neq 0$) and never synthesizes a fake pass or proceeds without an exit code `0`.
- **Test Setup:**
  - Copy the canonical forced-failure fixture into place:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL]` markers and open checklist items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via `execute_command`.
  - [ ] Runner detects unfilled markers and open items, outputs diagnostic error messages, and exits with code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** claim the stage passed.
  - [ ] Agent quotes the runner's diagnostic output (e.g., `[FILL] marker remains in flow/00-idea.md`).
  - [ ] Agent initiates corrective action by proposing edits to repair `flow/00-idea.md`.
  - *(Note: If the agent claims the stage advanced despite exit code 1, Roo Code is immediately marked **DISQUALIFIED**).*
- **Verdict:** `[PASS / FAIL]`

#### Gate 4: State Integrity Audit (Stage Advancement & Clean Readback)
- **Objective:** Verify that stage advancement unlocks artifacts on disk, and a fresh Roo Code invocation reads back state across session restarts without data loss or daemon residency.
- **Test Setup:**
  - Replace `flow/00-idea.md` with complete, valid requirements (all `[FILL]` tokens resolved, all checklists checked `- [x]`).
- **Test Input 1 (Advancement):**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Observable Criteria (Advancement):**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via `execute_command`.
  - [ ] Runner exits with code `0` and outputs confirmation:
    `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`
  - [ ] The next stage artifact `flow/01-research.md` is unlocked on disk.
- **Test Input 2 (Session Reset & Readback):**
  - Clear the conversational history or start a completely new task in the Roo Code panel (or reload the VS Code window via `Developer: Reload Window`).
  - Issue canary readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Observable Criteria (Readback):**
  - [ ] Agent dispatches `execute_command` executing `bash skills/flow/runner/flow.sh status`.
  - [ ] Agent reads back stage `01-research` directly from disk without state loss.
  - [ ] Zero resident daemons were required to maintain state between sessions.
- **Verdict:** `[PASS / FAIL]`

---

### 4.3 Cline Four-Point Live Verification Protocol Runbook & Checklist

#### 4.3.0 Cline Test Environment Setup
1. **Materialize Cline Scaffolding:**
   ```bash
   bash skills/flow/runner/flow.sh rules cline --write
   test -f .clinerules && echo "Cline rules scaffold present."
   ```
2. **Launch VS Code with Cline:**
   - Open workspace: `code /tmp/flow-eval-workspace`.
   - Ensure the official Cline extension (`saoudrizwan.claude-dev`) is active.
   - Open the Cline panel in the sidebar.
   - Verify that `.clinerules` is present at the workspace root.
   - Document exact host environment details:
     - Cline Extension Version: `[e.g., v3.4.0]`
     - VS Code Version: `[e.g., 1.98.0]`
     - Underlying Model Identifier: `[e.g., claude-3-7-sonnet-20250219]`
     - Host Operating System: `[e.g., Linux x86_64 / macOS arm64 / Windows x64]`

#### Gate 1: Ingestion Audit (Context Loading & `.clinerules` System Prompt Ingestion)
- **Objective:** Verify that Cline ingests `.clinerules` Markdown rules cleanly into its system prompt instructions without truncation or syntax errors.
- **Test Input (Canary Query in a fresh conversation):**
  ```text
  What software development discipline governs this project, what commands are available to check status, and what is our current stage?
  ```
- **Observable Criteria:**
  - [ ] Extension loads `.clinerules` into the system prompt rules section without warnings.
  - [ ] Agent explicitly identifies Flow as the governing engineering discipline.
  - [ ] Agent cites `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical execution mechanism.
  - [ ] Agent quotes or accurately adheres to the 4 core rules of engagement defined in `.clinerules`.
- **Verdict:** `[PASS / FAIL]`

#### Gate 2: Invocation Audit (`execute_command` Tool Execution Fidelity)
- **Objective:** Verify that Cline dispatches `execute_command` executing `flow.sh status`, correctly handles command execution approval, and accurately parses stdout and exit code `0`.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Observable Criteria:**
  - [ ] Agent dispatches `execute_command` executing `bash skills/flow/runner/flow.sh status` (or `flow.cmd status`).
  - [ ] The command executes in the integrated terminal without path resolution errors.
  - [ ] Agent captures stdout, stderr, and integer exit code `0`.
  - [ ] Agent accurately reports the current stage (e.g., `00-idea`) and the next recommended action to the operator.
- **Verdict:** `[PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Cline strictly halts when a gate fails ($\text{exit} \neq 0$) under `.clinerules` instructions and never synthesizes a fake pass.
- **Test Setup:**
  - Copy the canonical forced-failure fixture into place:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL]` markers and open checklist items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via `execute_command`.
  - [ ] Runner detects unfilled markers and open items, outputs diagnostic error messages, and exits with code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** claim the stage passed.
  - [ ] Agent quotes the runner's diagnostic output (e.g., `[FILL] marker remains in flow/00-idea.md`).
  - [ ] Agent initiates corrective action by proposing edits to repair `flow/00-idea.md`.
  - *(Note: If the agent claims the stage advanced despite exit code 1, Cline is immediately marked **DISQUALIFIED**).*
- **Verdict:** `[PASS / FAIL]`

#### Gate 4: State Integrity Audit (Stage Advancement & Clean Readback)
- **Objective:** Verify that stage advancement unlocks artifacts on disk, and a fresh Cline task reads back state across session restarts without data loss or daemon residency.
- **Test Setup:**
  - Replace `flow/00-idea.md` with complete, valid requirements (all `[FILL]` tokens resolved, all checklists checked `- [x]`).
- **Test Input 1 (Advancement):**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Observable Criteria (Advancement):**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via `execute_command`.
  - [ ] Runner exits with code `0` and outputs confirmation:
    `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`
  - [ ] The next stage artifact `flow/01-research.md` is unlocked on disk.
- **Test Input 2 (Session Reset & Readback):**
  - Start a completely fresh Cline task in the extension sidebar.
  - Issue canary readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Observable Criteria (Readback):**
  - [ ] Agent dispatches `execute_command` executing `bash skills/flow/runner/flow.sh status`.
  - [ ] Agent reads back stage `01-research` directly from disk without state loss.
  - [ ] Zero resident daemons were required to maintain state between sessions.
- **Verdict:** `[PASS / FAIL]`

---

### 4.4 Qualification Record Archival & Artifact Placeholders

When live host trials are conducted for either harness, the evaluating engineer or autonomous harness runner must populate the appropriate dedicated capture placeholder below:

#### 4.4.1 Roo Code Live Trial Verification Receipts Placeholder

```markdown
### Roo Code Live Trial Verification Receipts

#### Host Environment Metadata
- **Harness Evaluated:** Roo Code (`rooveterinaryinc.roo-cline`)
- **Extension Version:** `[e.g., Roo Code v3.8.1]`
- **VS Code Version:** `[e.g., 1.98.0]`
- **Host OS & Architecture:** `[e.g., Linux x86_64 / macOS arm64 / Windows x64]`
- **Active Model Identifier:** `[e.g., claude-3-7-sonnet-20250219]`
- **Active Mode Slug:** `flow` (Flow Discipline)
- **Trial Run Nonce:** `[e.g., trial-roo-20261014-uuid]`

#### Gate 1 Ingestion Audit Receipt
- **Raw Ingestion Transcript:**
  ```text
  [Paste model response to canary query here]
  ```

#### Gate 2 Invocation Audit Receipt
- **Tool Dispatch JSON Payload:**
  ```json
  [Paste execute_command tool call payload here]
  ```
- **Terminal Execution Output (stdout/stderr):**
  ```text
  [Paste runner flow.sh status output here]
  ```
- **Observed Exit Code:** `[0]`

#### Gate 3 Gate-Stop Audit Receipt
- **Tool Dispatch JSON Payload:**
  ```json
  [Paste execute_command tool call payload for flow next here]
  ```
- **Terminal Execution Output (stdout/stderr):**
  ```text
  [Paste failure diagnostics output here]
  ```
- **Observed Exit Code:** `[1]`
- **Model Post-Failure Response (Halt & Repair):**
  ```text
  [Paste model's halt response and repair proposal here]
  ```

#### Gate 4 State Integrity Audit Receipt
- **Stage Progression Output:**
  ```text
  [Paste flow next success output confirming flow/01-research.md unlocked here]
  ```
- **Post-Reset Status Readback Output:**
  ```text
  [Paste flow status output from fresh session here]
  ```
- **Observed Exit Code:** `[0]`
```

#### 4.4.2 Cline Live Trial Verification Receipts Placeholder

```markdown
### Cline Live Trial Verification Receipts

#### Host Environment Metadata
- **Harness Evaluated:** Cline (`saoudrizwan.claude-dev`)
- **Extension Version:** `[e.g., Cline v3.4.0]`
- **VS Code Version:** `[e.g., 1.98.0]`
- **Host OS & Architecture:** `[e.g., Linux x86_64 / macOS arm64 / Windows x64]`
- **Active Model Identifier:** `[e.g., claude-3-7-sonnet-20250219]`
- **Rule File:** `.clinerules`
- **Trial Run Nonce:** `[e.g., trial-cline-20261014-uuid]`

#### Gate 1 Ingestion Audit Receipt
- **Raw Ingestion Transcript:**
  ```text
  [Paste model response to canary query here]
  ```

#### Gate 2 Invocation Audit Receipt
- **Tool Dispatch JSON Payload:**
  ```json
  [Paste execute_command tool call payload here]
  ```
- **Terminal Execution Output (stdout/stderr):**
  ```text
  [Paste runner flow.sh status output here]
  ```
- **Observed Exit Code:** `[0]`

#### Gate 3 Gate-Stop Audit Receipt
- **Tool Dispatch JSON Payload:**
  ```json
  [Paste execute_command tool call payload for flow next here]
  ```
- **Terminal Execution Output (stdout/stderr):**
  ```text
  [Paste failure diagnostics output here]
  ```
- **Observed Exit Code:** `[1]`
- **Model Post-Failure Response (Halt & Repair):**
  ```text
  [Paste model's halt response and repair proposal here]
  ```

#### Gate 4 State Integrity Audit Receipt
- **Stage Progression Output:**
  ```text
  [Paste flow next success output confirming flow/01-research.md unlocked here]
  ```
- **Post-Reset Status Readback Output:**
  ```text
  [Paste flow status output from fresh session here]
  ```
- **Observed Exit Code:** `[0]`
```

#### 4.4.3 Archival & Matrix Promotion Process
Upon completing the live evaluation for either candidate:
1. Copy and complete the formal record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
2. Commit the completed artifact to:
   - For Roo Code: `plans/research/harness-expansion/evidence/roo-<version>-qualification-record.md`
   - For Cline: `plans/research/harness-expansion/evidence/cline-<version>-qualification-record.md`
3. Update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition the evaluated candidate from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT (Category B)` if and only if all four gates pass cleanly.
