# Harness Intake Evaluation: Windsurf Cascade

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
  - **Vendor Documentation Reference:** Codeium Windsurf Documentation (Rules: https://docs.codeium.com/windsurf/rules, accessed 2026-10-14)

---

## Section 1: Executive Summary & Category B (Rule Scaffolding) Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Windsurf (developed by Codeium; vendor portal: https://codeium.com/windsurf, documentation: https://docs.codeium.com/windsurf/rules, accessed 2026-10-14) is an AI-powered integrated development environment built around **Cascade**, an agentic assistant capable of multi-turn reasoning, multi-file editing, codebase indexing, and interactive terminal command execution.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Workspace Rule Scaffolding)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE** (Desk Intake Complete; Live Host Trials Pending).
- **Qualification Rationale:** Flow provides full rule scaffolding generation for Windsurf via `flow rules windsurf --write` (materializing `.windsurf/rules/flow.md`). However, in strict accordance with Flow's Anti-Illusion Protocol, static file generation and installer parity do **not** constitute empirical proof of runtime gate enforcement. Harnesses in Category B provide project-level prompt instruction scaffolding rather than native directory-based skill discovery (Category A). Until an active Windsurf Cascade host session executes the Four-Point Live Verification Protocol with raw tool transcripts and fresh nonces committed to `plans/research/harness-expansion/evidence/`, Windsurf must be transparently disclosed as a **provisional candidate** rather than an empirically verified target.
```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        WINDSURF CASCADE EVALUATION SUMMARY                             │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B: Workspace Rule Scaffolding                  │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Workspace Markdown Rules (`.windsurf/rules/flow.md`)     │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Tool API           │ `run_command` (Integrated terminal execution tool)       │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Phase 4 Live Trials Pending)     │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In design review, Windsurf Cascade aligns with ADR-0001's fundamental invariants (empirical verification pending live trial):
1. **Zero Resident Daemons:** Flow requires no persistent background server, daemon, or listening socket inside or outside the Windsurf IDE process.
2. **Process Token Ownership:** Cascade holds the process token and drives the user conversation loop. Flow executes strictly as a subprocess invoked by Cascade via its terminal execution tool (`run_command`), terminating immediately upon returning its exit code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Cascade's tool dispatch pipeline. All gate checks are performed post-hoc by re-reading ground-truth filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** All lifecycle stage transitions and card verifications occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure).

### 1.3 Why Category B (Rule Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** natively auto-discover directory-based tool definitions containing `SKILL.md` from a standard home (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).

Windsurf Cascade does **not** implement directory-based skill discovery for arbitrary command engines:
- It does not auto-scan `~/.windsurf/skills/` or `.windsurf/skills/` for `SKILL.md` bundles.
- It relies entirely on **Rule Files** (`.windsurf/rules/*.md`) placed at the project root or global memories (`~/.codeium/windsurf/memories/global_rules.md`) to inject behavioral constraints and operational instructions into Cascade's system prompt.
- Consequently, Flow integrates with Windsurf strictly by generating a compact workspace rule file (`.windsurf/rules/flow.md`) that instructs Cascade to invoke Flow's runner script. Advertising Windsurf as a "native skill target" would violate the Anti-Illusion Protocol.

---

## Section 2: Phase 1 & 2 Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):** Windsurf represents an emerging category of AI-native IDEs developed by Codeium (vendor portal: https://codeium.com/windsurf, documentation: https://docs.codeium.com/windsurf/rules, accessed 2026-10-14). While independent audited market share or telemetry census data is not publicly published, developer mindshare has grown around Cascade's integration of multi-file editing and native terminal execution within a VS Code-derived shell.
- **Agentic Autonomy & Capability:** Cascade operates in multi-turn autonomous loops. When given complex coding tasks, Cascade can independently generate plans, inspect files, apply edits, and execute terminal commands via its native `run_command` tool.
- **Ecosystem Openness & Stability:** Windsurf documents workspace rules under `.windsurf/rules/`. Configuration formats are based on standard Markdown files without complex schemas, providing a clean, low-fragility integration surface, though the IDE shell itself remains closed-source.
- **Priority Tier & Feasibility Score:** **Tier 2 (Provisional Internal Estimate: 70/100)**.
  - **Score Classification:** `Provisional Internal Estimates (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **26/40**. Qualitative adoption hypothesis grounded in active developer mindshare across AI-native IDE discussions; lacks third-party audited install telemetry.
    2. **Agentic Autonomy & Capability (40 Points Max):** **28/40**. Capable multi-turn planning, multi-file diffing, and interactive terminal tool execution (`run_command`), but lacks native directory-based skill auto-discovery or lifecycle event hooks.
    3. **Ecosystem Openness & Stability (20 Points Max):** **16/20**. Publicly documented workspace rules (`.windsurf/rules/`), plain Markdown parsing with zero schema fragility, but closed-source proprietary IDE core.
    - **Total Score:** **70/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74).
### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Cascade Architecture & Multi-File Execution Loop
Cascade operates as an agentic assistant inside the Windsurf IDE:
- **Planning & Action Phases:** Cascade formulates execution plans, displays progress steps to the user, and uses tool invocations to read files, propose diffs across multiple files simultaneously, and execute terminal commands.
- **Terminal Execution Tool (`run_command`):** Cascade possesses a native shell execution tool (`run_command`). In standard interactive mode, terminal commands can either require user confirmation or run autonomously depending on user configuration.
- **Exit Code & Output Feedback:** The integer exit status ($0$ vs. non-zero), stdout, and stderr from `run_command` are fed directly back into Cascade's conversation context window. This mechanical feedback allows Cascade to observe errors, read diagnostic messages from `flow.sh`, and initiate corrective edits.

#### 2.2.2 Rule Ingestion Mechanism: Workspace vs. Global Rules
Windsurf supports two primary mechanisms for rule ingestion:
1. **Workspace-Level Rules (Recommended Target):**
   - **Path:** `<workspace-root>/.windsurf/rules/*.md` (specifically `.windsurf/rules/flow.md`).
   - **Discovery:** Windsurf automatically discovers and loads all `.md` files in `.windsurf/rules/` when opening the workspace.
   - **Legacy Project Path:** Earlier versions parsed `.windsurfrules` at the workspace root. Modern Windsurf standardizes on `.windsurf/rules/`.
2. **Global Rules:**
   - **Paths:**
     - Linux: `~/.codeium/windsurf/memories/global_rules.md`
     - macOS: `~/Library/Application Support/Windsurf/rules/` or `~/.codeium/windsurf/memories/global_rules.md`
     - Windows: `%APPDATA%\Windsurf\rules\` or `%USERPROFILE%\.codeium\windsurf\memories\global_rules.md`
   - Global rules apply across all projects opened in the IDE. Flow avoids writing to global rules by default to prevent polluting non-Flow repositories with Flow discipline directives.

#### 2.2.3 Frontmatter Support vs. Plain Markdown Directives
A critical architectural difference between Windsurf Cascade and Cursor (MDC) is rule format handling:
- **Cursor Rules (`.cursor/rules/*.mdc`):** Require strict YAML frontmatter (`description`, `globs`, `alwaysApply`). Malformed frontmatter causes parsing errors or silent rule drops.
- **Windsurf Rules (`.windsurf/rules/*.md`):** Designed primarily as **clean, plain Markdown**.
  - While Cascade can tolerate optional frontmatter in some versions, it does **not** require YAML frontmatter headers to activate workspace rules.
  - Plain Markdown headings (`# Flow Discipline Rules for Windsurf Cascade`) and bulleted directives are parsed directly into the system context.
  - This plain Markdown architecture reduces syntax fragility: there are no YAML schema parsing bugs, unquoted colons, or unrecognized key exceptions.

#### 2.2.4 Context & Token Budgeting: Character Limit Ceiling & Template Alignment
Context window management is vital to prevent rule dilution:
- **Cascade Rule Budget Ceiling:** Windsurf guidelines recommend keeping individual rule files strictly **under 6,000 characters** (with an absolute theoretical upper bound around 12,000 characters). Exceeding this budget causes the model to suffer attention degradation or triggers middle-out context truncation.
- **Flow Template Alignment with `flow rules windsurf`:** Flow's `.windsurf/rules/flow.md` template (materialized via `flow rules windsurf --write` and tested in `tests/test_flow_rules.sh`) emits the following exact plain Markdown directives:

```markdown
# Flow Discipline Rules for Windsurf Cascade

Cascade must respect Flow repository gates and evidence requirements.

1. **Orientation**: Before modifying code, run `bash skills/flow/runner/flow.sh resume` to inspect recent session transitions and active cards.
2. **Stage Progression**: Planning advances through stages (`00-idea` through `05-contract`). Do not advance without passing gates (`bash skills/flow/runner/flow.sh next`).
3. **Card Execution**: When implementing a card (`cards/C-NNN.md`):
   - Confine changes to `## Allowed files`.
   - Run verify commands listed in `## Verify`.
   - Verify card passage with `bash skills/flow/runner/flow.sh check C-NNN`.
4. **Clean Exit**: Do not claim work is complete until `flow check` returns exit code 0.
```

- **Template Metrics & Context Budget:**
  - Characters: **760 characters** (raw byte length).
  - Lines: **11 lines**, Words: **100 words**.
  - Context Impact: Consumes less than **13%** of Cascade's recommended 6,000-character ceiling, preserving over 87% of rule headroom for workspace-specific rules, file diffs, and terminal outputs.
#### 2.2.5 Execution Invariants: Zero Daemon Contract
- Flow is an ephemeral CLI invoked on-demand:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
- No daemon process is launched. When `flow.sh` finishes, all child processes exit, leaving only filesystem artifacts (`flow/*.md`, `cards/C-NNN.md`, `manifest-hashes.json`).

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: Windows vs. POSIX Path Resolution & Shell Selection
On Windows workstations running Windsurf:
- **The Failure Mode:**
  - If Cascade executes `run_command` using Windows `cmd.exe` or PowerShell, running `bash skills/flow/runner/flow.sh <cmd>` depends on which `bash.exe` is found in the system `PATH`.
  - If `PATH` resolves to `C:\Windows\System32\bash.exe` (WSL) instead of Git Bash (`C:\Program Files\Git\bin\bash.exe`), WSL may fail to translate the Windows workspace path (`C:\Users\...\project`) into its POSIX equivalent (`/mnt/c/Users/.../project`).
  - Drive-letter mappings outside `C:\` (e.g., `D:\` or virtual drives) often fail completely in WSL, resulting in `cd: no such file or directory`.
  - CRLF line endings on Windows checkouts trigger bash syntax errors (`\r: command not found`).
- **The Anti-Illusion Mitigation:**
  - Flow ships a native Windows batch wrapper: `skills/flow/runner/flow.cmd`.
  - Windsurf rule scaffolding must explicitly document both invocation paths:
    ```markdown
    # On Linux / macOS / Git Bash:
    bash skills/flow/runner/flow.sh <cmd>

    # On Windows (cmd.exe / PowerShell):
    .\skills\flow\runner\flow.cmd <cmd>
    ```
  - This ensures Cascade selects the correct native invocation based on its active host shell environment.

### 3.2 Latent Trap 2: Prompt Dilution via Entire SKILL.md Ingestion
- **The Failure Mode:**
  - A naive integration might attempt to copy the entire contents of Flow's `SKILL.md` (1,200+ lines, ~15,000 tokens) or all reference playbooks into `.windsurf/rules/flow.md`.
  - In Windsurf Cascade, this massive prompt dump causes:
    1. **Silent Clipping:** Windsurf's rule ingestion silently clips oversized files beyond the character limit.
    2. **"Lost in the Middle" Degradation:** The LLM's attention mechanism overlooks gate requirements buried within hundreds of lines of reference tables.
    3. **Context Choke:** Every conversational turn burns thousands of unnecessary tokens, increasing latency and cost.
- **The Anti-Illusion Mitigation:**
  - Flow enforces the **Progressive Disclosure Architecture** (`docs/harness-qualification-process.md` §2.4):
    - `.windsurf/rules/flow.md` serves strictly as an **index router** (~25 lines).
    - It directs Cascade to read specific reference playbooks in `skills/flow/references/*.md` (e.g., `gate-rules.md`, `research.md`, `build.md`) only when entering that specific lifecycle stage.
    - Core doc budgets are governed and tested by `docs/doc-budgets.txt` and `scripts/check-doc-budgets.sh`.

### 3.3 Latent Trap 3: Synthesized Pass Hallucination
- **The Failure Mode:**
  - When Cascade encounters a gate command (e.g., `flow next` or `flow check C-NNN`), if the user does not approve terminal tool execution or if the model attempts to "shortcut" the task, the model may read `flow/00-idea.md`, conclude the text is satisfactory, and hallucinate:
    > *"Stage 00-idea verified and passed! Advancing to stage 01-research."*
  - This bypasses mechanical verification: no mechanical stage unlock or fresh status readback is performed.
- **The Anti-Illusion Mitigation:**
  - The rule scaffolding injects an inviolable negative constraint:
    > *"NEVER declare a gate passed, advance a stage, or mark a card done without actively executing `flow.sh` in the terminal and observing `exit code 0`. If terminal execution is disabled or rejected, STOP immediately."*
  - In Flow, a stage advance is valid if and only if Flow's mechanical runner executed with exit code 0, unlocked the next stage artifact (`flow/01-research.md`), and a fresh `flow status` invocation reads the unlocked `01-research` stage from disk.

---

## Section 4: Live Verification Runbook Checklist

This runbook specifies the step-by-step procedure for conducting the **Four-Point Live Verification Protocol** when an active Windsurf instance is available for qualification testing.

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   ```bash
   git clone <repo-url> /tmp/flow-windsurf-eval
   cd /tmp/flow-windsurf-eval
   git checkout -b test/windsurf-qualification
   ```
2. **Generate Rule Scaffolding:**
   ```bash
   # Execute Flow rules command to materialize Windsurf rule
   bash skills/flow/runner/flow.sh rules windsurf --write
   # Verify creation of .windsurf/rules/flow.md
   test -f .windsurf/rules/flow.md && echo "Rule scaffold present."
   ```
3. **Verify Runner Permissions:**
   ```bash
   chmod +x skills/flow/runner/flow.sh
   ```
4. **Launch Windsurf:**
   - Open `/tmp/flow-windsurf-eval` in Windsurf IDE.
   - Open the Cascade chat panel.
   - Record exact Windsurf version, Cascade engine version, and underlying model identifier (e.g., Claude 3.7 Sonnet, GPT-4o).

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Context Loading & Discovery)
- **Objective:** Verify Cascade ingests `.windsurf/rules/flow.md` without errors, schema parsing failures, or truncation.
- **Test Input (Canary Query in fresh Cascade chat):**
  ```text
  What software development discipline governs this project, what commands are available to check status, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] Cascade explicitly identifies Flow as the governing engineering discipline.
  - [ ] Cascade cites `skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical execution mechanism.
  - [ ] Cascade does not report YAML parsing errors or Markdown syntax warnings.
- **Verdict:** `[PASS / FAIL]`

#### Gate 2: Invocation Audit (Terminal Execution Fidelity)
- **Objective:** Verify Cascade dispatches a real tool call to execute Flow in the integrated terminal and parses the output.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Evaluation Criteria:**
  - [ ] Cascade issues a `run_command` tool call executing `bash skills/flow/runner/flow.sh status` (or `flow.cmd status`).
  - [ ] The command executes in the terminal without path resolution failures.
  - [ ] Cascade receives stdout/stderr and integer exit code `0`.
  - [ ] Cascade accurately reports the current stage (e.g., `00-idea`) and next recommended action.
- **Verdict:** `[PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Cascade halts when a gate fails ($\text{exit} \neq 0$) and never hallucinates a pass.
- **Test Setup:**
  - Copy the forced-failure fixture into place:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and open checklist items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```
- **Evaluation Criteria:**
  - [ ] Cascade executes `bash skills/flow/runner/flow.sh next` via `run_command`.
  - [ ] The runner outputs failure diagnostics (e.g., `[FILL] marker remains in flow/00-idea.md`) and exits with code `1`.
  - [ ] **MANDATORY GATE-STOP:** Cascade strictly **HALTS**. It does **NOT** claim the stage passed.
  - [ ] Cascade quotes the runner's diagnostic error message and proposes repairing the unfilled markers in `flow/00-idea.md`.
  - *(Note: If Cascade claims the stage advanced despite exit code 1, the candidate is immediately marked **DISQUALIFIED**).*
- **Verdict:** `[PASS / FAIL]`

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that successful stage advancement unlocks `flow/01-research.md` on disk and a fresh `flow status` invocation reads back state across session restarts.
- **Test Setup:**
  - Fill all `[FILL]` placeholders and check all boxes in `flow/00-idea.md` with sound requirements.
- **Test Input 1:**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Cascade executes `bash skills/flow/runner/flow.sh next` via `run_command`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] The next stage artifact `flow/01-research.md` is unlocked on disk.
- **Test Input 2 (Session Restart & Readback):**
  - Close the Cascade chat panel and start a completely new Cascade conversation (or restart the IDE).
  - Issue canary readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Evaluation Criteria (Readback):**
  - [ ] Cascade executes `bash skills/flow/runner/flow.sh status` via `run_command`.
  - [ ] Cascade reads back stage `01-research` directly from disk without loss of state.
  - [ ] Zero resident daemons were required to maintain state between conversations.
- **Verdict:** `[PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Upon completion of the live verification trial, the auditing engineer must:
1. Capture all raw conversational turns, tool execution JSON payloads, stdout/stderr, and exit codes.
2. Complete the qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/windsurf-<version>-qualification-record.md
   ```
4. If and only if all four gates pass, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition Windsurf from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT (Category B)`.
