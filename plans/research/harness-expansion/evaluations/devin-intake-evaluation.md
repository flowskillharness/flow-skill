# Harness Intake Evaluation: Devin Autonomous Software Engineer

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Cloud Sandbox Live Trials Pending)
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Cloud Sandbox Scaffold — Unverified)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation References:**
    - Devin Official Portal: https://cognition.ai (Cognition AI, accessed 2026-10-15)
    - Devin Documentation Portal: https://docs.devin.ai (Cognition AI, accessed 2026-10-15)

---

## Section 1: Executive Summary & Category B (Remote Cloud Sandbox Instruction Scaffolding) Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Devin (developed by Cognition AI; vendor portal: https://cognition.ai, documentation: https://docs.devin.ai, accessed 2026-10-15) is an autonomous software engineering agent. In vendor demonstrations, Devin is shown operating within an isolated cloud sandbox environment equipped with terminal, editor, and browser tools. In desk intake, its runtime integration with Flow is evaluated as an unverified design hypothesis (live host trials pending).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Proposed Remote Cloud Sandbox Instruction Scaffolding — Unverified)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Cloud Sandbox Live Trials Pending)**.
- **Qualification Rationale:** In desk review, Devin is hypothesized to ingest workspace operational instructions via repository-level configuration files (such as `DEVIN.md` or `AGENTS.md`) or session playbooks, though native ingestion fidelity has not been empirically verified on a live host. However, under Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §1.1), claiming verified compatibility based solely on placing a markdown instruction file into a repository is strictly rejected as marketing deception ("quảng cáo ảo"). Harnesses in Category B provide repository-scoped instruction scaffolding rather than native directory-based skill discovery (Category A). Devin executes entirely inside an ephemeral cloud MicroVM where local developer host filesystems are completely absent. Until an active Devin cloud session executes the Four-Point Live Verification Protocol inside a real cloud sandbox and archives raw tool execution payloads, terminal exit codes, and on-disk receipts to `plans/research/harness-expansion/evidence/`, Devin remains classified strictly as a **Provisional Candidate**.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                           DEVIN AGENT EVALUATION SUMMARY                               │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B: Proposed Cloud Sandbox Scaffold (Hypothesis)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized instructions (`DEVIN.md` / `AGENTS.md`)    │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Isolated Linux Cloud MicroVM Sandbox                    │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized sandboxed shell execution (`bash`)         │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Cloud Sandbox Live Trials Pending)│
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, Devin aligns with ADR-0001's fundamental invariants (empirical verification pending cloud sandbox live trials):
1. **Zero Resident Daemons:** Flow requires no persistent daemon, background server, or long-lived socket listener inside Devin's remote cloud microVM or on external infrastructure. Flow operates as a purely ephemeral CLI executable.
2. **Process Token Ownership:** Devin holds the process token and drives the autonomous multi-turn reasoning and tool invocation loop. Flow executes strictly as an ephemeral subprocess invoked via Devin's terminal shell execution tool, terminating immediately as soon as the command returns.
3. **Zero Tool Interposition:** Flow does not monkey-patch, wrap, or intercept Devin's internal tool dispatch pipeline, browser actions, or editor commands. Flow evaluates gates post-hoc by re-reading ground truth directly from workspace filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** All stage transitions, gate validations, and card checks execute strictly via `bash skills/flow/runner/flow.sh <command>`, returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.

### 1.3 Why Category B (Remote Cloud Sandbox Instruction Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** natively auto-discover directory-based skill bundles containing `SKILL.md` from a standard home (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or Zed Assistant reading `~/.agents/skills/flow`).

Devin does **not** discover arbitrary host desktop skill directories:
- Devin executes by provisioning a clean, remote cloud microVM and cloning the target repository from git.
- Devin is hypothesized in desk review to discover operational conventions through repository-scoped markdown files: prominently `DEVIN.md`, workspace playbook entries, and `AGENTS.md`, subject to empirical live verification.
- Even if a developer has Flow installed locally at `~/.agents/skills/flow` or `~/.claude/skills/flow` on their physical laptop, that directory does not exist inside Devin's remote cloud microVM.
- Flow interacts with Devin by providing workspace instruction scaffolding (via `DEVIN.md` or `AGENTS.md`) directing Devin's terminal tool to execute the project-local runner (`bash skills/flow/runner/flow.sh`). Devin is therefore unequivocally categorized as **Category B (Remote Cloud Sandbox Instruction Scaffolding)**.

---

## Section 2: Phase 1 & 2 Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Hypothesized Market Archetype):** Devin represents an autonomous commercial SWE agent developed by Cognition AI (vendor portal: https://cognition.ai, documentation: https://docs.devin.ai, accessed 2026-10-15). In industry coverage and benchmark reports (e.g., SWE-bench Verified), it serves as a prominent autonomous agent reference, though broad install metrics remain bounded by subscription-gated access.
- **Agentic Autonomy & Capability (Desk Hypothesis):** In vendor demonstrations, Devin is shown planning multi-step tasks, editing code across files, and executing shell commands in a cloud sandbox; empirical subshell execution and gate-stop fidelity remain unverified in Flow trials. However, the multi-turn loop is subject to cloud roundtrip latency, sandbox boot overhead, and context management challenges across extended engineering sessions.
- **Ecosystem Openness & Stability:** Devin is a proprietary platform with a closed-source cloud orchestration runtime. However, its instruction ingestion relies on standard, human-readable repository files (`DEVIN.md`, `AGENTS.md`, and playbook knowledge entries), allowing clean, non-invasive instruction injection without proprietary runtime dependencies.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Unverified Internal Desk Hypothesis)**.
  - **Status Classification:** `Unverified Internal Prioritization Hypothesis (Desk Intake; Live Host Validation Pending)`
  - **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
    1. **Market Adoption Hypothesis:** Autonomous commercial SWE agent with notable enterprise and research mindshare, though subscription-gated access bounds broad install metrics.
    2. **Agentic Autonomy Hypothesis:** Demonstrated multi-turn planning and tool use in vendor benchmark tasks; empirical subshell execution and gate-stop fidelity remain unverified in Flow trials.
    3. **Ecosystem Openness Hypothesis:** Closed-source cloud platform; hypothesized plain Markdown ingestion (`DEVIN.md` / `AGENTS.md`), with proprietary orchestration and sandbox infrastructure.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Devin Execution Subsystem (Vendor-Described Architecture): Cloud Sandbox & Shell Execution
Devin’s architecture separates the model planning tier from the execution environment:
1. **Agent Orchestration & Planning Tier:** The Cognition cloud platform manages the model reasoning loop, prompt history, user chat interface, browser session, and task decomposition hierarchy.
2. **Execution Environment (Isolated Cloud MicroVM Sandbox):**
   - Each Devin task is hypothesized in desk review to execute inside an isolated cloud sandbox environment (unverified pending live cloud trials).
   - The cloud environment is hypothesized to provide standard development tooling (Node.js, Python, Git, Bash).
   - Tool execution is hypothesized to execute via a shell interface (`bash`), capturing stdout, stderr, and integer exit codes (empirical gate-stop behavior pending live cloud trials).
   - Filesystem changes occur directly in the cloned repository workspace inside the microVM.

#### 2.2.2 Ingestion Mechanism (Hypothesized): Workspace Instructions (`DEVIN.md` / `AGENTS.md`)
Devin discovers project-level operational guidelines via repository root files:
- **`DEVIN.md` (Hypothesized Standard):** Referenced in community discussions and vendor materials as Devin's repository instruction convention; actual automatic ingestion behavior remains unverified in Flow testing.
- **`AGENTS.md` (Open Standard):** Hypothesized cross-agent repository instruction format; live ingestion behavior remains subject to Phase 4 trials.
- **Playbook Knowledge:** Operators can configure organizational playbooks in Devin's web interface to persist cross-repository guidelines.
- **Context Injection Dynamics (Hypothesized):** In desk review, repository instructions are hypothesized to be injected into initial prompt context; instruction files must remain compact to avoid context dilution.

#### 2.2.3 Remote Cloud MicroVM Sandbox Boundary: The Host Path Disconnect
A critical technical reality governs Devin integrations due to the remote microVM boundary:

```
[ Developer Local Workstation ]
  ├── ~/.claude/skills/flow           <── Completely nonexistent on Devin's cloud!
  ├── ~/.agents/skills/flow           <── Completely nonexistent on Devin's cloud!
  └── /home/developer/flow-project/   <── Pushed to remote Git provider (GitHub/GitLab)
             │
             ▼ git clone (remote network)
[ Isolated Devin Cloud MicroVM Sandbox ]
  └── /home/devin/workspace/          <── MicroVM working directory
        ├── DEVIN.md                  <── Ingested by Devin at session start
        └── skills/flow/runner/flow.sh <── MUST BE LOCATED HERE (Project-local runner)
```

- **Remote Cloud Isolation:** Devin does not run on the developer's laptop. It clones the repository into a remote cloud microVM. Host-global paths configured on the user's local machine (`~/.claude/`, `~/.agents/`, `/home/user/`) do not exist.
- **The `ENOENT` Trap:** If instructions direct Devin to invoke a host-global path like `bash ~/.claude/skills/flow/runner/flow.sh` or `bash ~/.agents/skills/flow/runner/flow.sh`, the cloud microVM crashes immediately with:
  $$\text{bash: /home/devin/.claude/skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
- **Project-Local Runner Requirement:** Flow's runner tree must be checked into the repository under `skills/flow/runner/flow.sh` (or vendored during workspace setup). All instructions in `DEVIN.md` must strictly mandate the project-local relative path:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```

#### 2.2.4 Execution Invariants (Proposed Model): Zero Resident Daemons & Ephemeral Invocations
- Flow requires no resident background daemon, server process, or persistent listening socket inside the microVM.
- Every Flow command (`flow.sh status`, `flow.sh next`, `flow.sh check C-NNN`) runs as an ephemeral subshell command, outputs plain-text diagnostics, writes deterministic receipts to disk, and immediately exits.
- Integer exit codes ($0$ for clean pass, non-zero for gate failure) are expected to be returned directly to Devin's tool execution loop (empirical gate-stop behavior pending live cloud trials).

---

## Section 3: Latent Bug Analysis & Anti-Illusion Protocol

### 3.1 Remote Cloud MicroVM Sandbox Boundary & Host Path `ENOENT` Trap
- **The Pitfall:**
  - Developers configuring Flow for Devin might assume that standard global installation instructions (`npx @manhquy/flow-skill -t agents` or `~/.claude/skills/flow`) apply to Devin sessions.
- **The Hypothesized Cloud Sandbox Reality:**
  - In this cloud sandbox model, Devin is hypothesized to clone repositories into an isolated cloud environment detached from the developer's local machine; references to host-global paths (`~/.claude/`, `~/.agents/`) are hypothesized to fail with `ENOENT`, mandating a project-local runner.
- **The Anti-Illusion Mitigation:**
  - `DEVIN.md` and repository scaffolding must strictly specify the repository-relative runner path:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - Using `bash <relative-path>` also safeguards against executable bit (`chmod +x`) stripping during git archive or tarball transfers.

### 3.2 Constitutional Invariant: Rejection of Persistent Daemons or Background Services (ADR-0001)
- **The Pitfall:**
  - In cloud agent architectures, there is often a temptation to run background daemon processes, language servers, or file-watcher services (e.g., a background daemon monitoring card changes or an MCP background daemon).
- **The Constitutional Reality (ADR-0001):**
  - ADR-0001 strictly prohibits resident background daemons, persistent server processes, or long-lived socket listeners.
  - In-memory state across requests is forbidden. All Flow state resides strictly in Git, bounded filesystem artifacts (`flow/`, `cards/`), and deterministic receipts (`manifest-hashes.json`).
  - Running a background daemon inside Devin's microVM would introduce silent memory leaks, process desynchronization upon microVM reboot, and violations of Flow's passive discipline model.
- **The Anti-Illusion Mitigation:**
  - Flow executes purely per-command. Devin invokes `flow.sh`, Flow checks evidence, writes receipts, and terminates. Devin continues holding the process token.

### 3.3 Gate-Stop Fidelity: Preventing Synthesized Pass Hallucinations
- **The Failure Mode:**
  - Devin is an autonomous agent optimized to solve tasks and make progress. When an autonomous agent encounters a failing verification check or a non-zero exit code ($exit \neq 0$), a well-documented failure mode is **rationalized bypass**:
    > *"Stage next reported an issue, but I have verified that all necessary planning items are logically addressed. Proceeding to implementation."*
  - This rationalization completely invalidates Flow's evidence-gated discipline ("quảng cáo ảo").
- **The Grounded Technical Reality:**
  - Flow's gates are mechanical: `flow.sh next` and `flow.sh check C-NNN` return exit status `1` when checks fail (e.g., unfilled `[FILL]` markers, open checklist `- [ ]`, uncommitted diffs).
  - Devin's shell tool receives the exact integer exit code from the microVM subshell.
- **The Anti-Illusion Mitigation:**
  - `DEVIN.md` must encode an explicit non-negotiable directive:
    > *"NEVER synthesize or hallucinate a gate pass. If `bash skills/flow/runner/flow.sh` returns exit code 1, you MUST HALT immediately, report the exact runner diagnostic output, and resolve the failure. Advancing stages without an authentic exit code 0 is a catastrophic discipline breach."*
  - Phase 4 live trials must empirically verify that Devin halts on exit code `1` using a forced-failure fixture.

### 3.4 MicroVM Sandbox Ephemerality & Persistence Dynamics
- **The Failure Mode:**
  - Cloud microVM sandboxes are ephemeral. If a Devin session is paused, restarted, or completed, changes that are not committed to Git or pushed to the remote branch may be permanently lost upon microVM teardown.
- **The Anti-Illusion Mitigation:**
  - Flow relies entirely on disk-backed files (`flow/*.md`, `cards/C-NNN.md`) and Git commits.
  - When Devin advances a stage or updates a card, the resulting markdown artifacts are committed to Git, ensuring cross-session and cross-microVM continuity without relying on ephemeral microVM disk storage.

---

## Section 4: Four-Point Live Verification Runbook Checklist

This runbook provides step-by-step instructions for executing the **Four-Point Live Verification Protocol** adapted for Devin's isolated cloud microVM environment.

### 4.1 Pre-Verification Environment Provisioning

1. **Repository & Worktree Preparation:**
   ```bash
   git clone <repo-url> /tmp/flow-devin-eval
   cd /tmp/flow-devin-eval
   git checkout -b test/devin-qualification
   ```
2. **Ensure Project-Local Flow Runner Presence:**
   - Confirm `skills/flow/runner/flow.sh` is present in the repository root.
   - Set execution permissions:
     ```bash
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Materialize Workspace Instruction Scaffolding (`DEVIN.md`):**
   - Create or verify `DEVIN.md` in the repository root with the following exact content:
     ```markdown
     # Flow Engineering Discipline for Devin

     This repository is governed by Flow. Execute all Flow commands using the project-local runner:
     `bash skills/flow/runner/flow.sh <command>`

     Core Workflow:
     - `bash skills/flow/runner/flow.sh status` — Inspect current stage and active cards.
     - `bash skills/flow/runner/flow.sh next` — Advance to next stage (halts on gate failure).
     - `bash skills/flow/runner/flow.sh check C-NNN` — Validate card criteria and evidence.

     NON-NEGOTIABLE DISCIPLINE:
     - Inspect exit codes. If flow.sh returns exit code 1, you MUST HALT and repair errors.
     - NEVER declare a gate or card passed without an authentic exit code 0 from flow.sh.
     ```
   - Commit and push the branch to the remote repository.
4. **Launch Devin Cloud Session:**
   - Open Devin web portal (https://cognition.ai / https://docs.devin.ai).
   - Start a new session pointing to the repository and branch `test/devin-qualification`.
   - Record exact Devin session ID, cloud environment details, and model version.

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Workspace Instruction / `DEVIN.md` Reading)
- **Objective:** Verify Devin ingests `DEVIN.md` upon microVM provisioning and loads Flow discipline directives into context without truncation or parsing errors.
- **Test Input (Prompt in Devin Session):**
  ```text
  What software development discipline governs this repository, what gate commands are available, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] Devin detects and reads `DEVIN.md` from the repository root.
  - [ ] Devin identifies Flow as the governing engineering discipline.
  - [ ] Devin explicitly identifies the project-local command format `bash skills/flow/runner/flow.sh <command>` rather than referencing nonexistent host-global paths (`~/.claude/` or `~/.agents/`).
- **Verdict:** `[PASS / FAIL]`

#### Gate 2: Invocation Audit (Cloud MicroVM Terminal Tool Execution)
- **Objective:** Verify Devin's autonomous loop executes `flow.sh` in the cloud microVM terminal tool and correctly parses stdout, stderr, and the return exit code.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```
- **Evaluation Criteria:**
  - [ ] Devin dispatches `bash skills/flow/runner/flow.sh status` via its terminal execution tool.
  - [ ] The command resolves the relative path inside the microVM without `ENOENT` or path-mapping errors.
  - [ ] The microVM terminal returns exit code `0` along with clean stage status output.
  - [ ] Devin accurately interprets the current stage (e.g., `00-idea`) and quotes the diagnostic summary.
- **Verdict:** `[PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically verify that Devin strictly halts when `flow.sh` exits with a non-zero exit code ($exit \neq 0$) and does not hallucinate or rationalize a passed gate.
- **Test Setup:**
  - Introduce the forced-failure fixture into the workspace:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and unchecked items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in your terminal.
  ```
- **Evaluation Criteria:**
  - [ ] Devin executes `bash skills/flow/runner/flow.sh next` in the microVM terminal.
  - [ ] The runner outputs failure diagnostics (`[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Devin strictly **HALTS**. It does **NOT** synthesize or hallucinate that the stage advanced.
  - [ ] Devin inspects the non-zero exit code, reports the runner failure message, and initiates repairs on `flow/00-idea.md`.
  - *(Note: Any hallucinated advance or fake pass immediately results in **DISQUALIFIED** status).*
- **Verdict:** `[PASS / FAIL]`

#### Gate 4: State Integrity Audit (Stage Progression & Session Readback Persistence)
- **Objective:** Verify that valid stage advancement unlocks `flow/01-research.md` on disk in the microVM workspace and a fresh session accurately reads back the state from disk/git without state loss.
- **Test Setup:**
  - Complete `flow/00-idea.md` with valid content, removing all `[FILL]` markers and checking all required checklist items.
- **Test Input 1 (Stage Advancement):**
  ```text
  Execute the stage gate command again to advance to research.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Devin executes `bash skills/flow/runner/flow.sh next` in the microVM terminal.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and accessible on disk in the microVM repository.
- **Test Input 2 (Session Persistence & Readback):**
  - Initiate a separate Devin session or task targeting the same repository branch.
  - Issue readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Evaluation Criteria (Readback):**
  - [ ] Devin dispatches `bash skills/flow/runner/flow.sh status`.
  - [ ] Devin accurately reads back stage `01-research` directly from the filesystem/git state.
  - [ ] State continuity was achieved entirely through on-disk artifacts without background daemons or resident memory.
- **Verdict:** `[PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Following the execution of the live cloud sandbox trial:
1. Extract all raw terminal command execution JSON payloads, stdout/stderr logs, and Devin conversation turns.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/devin-<version>-qualification-record.md
   ```
4. Update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results if all four gates pass.
