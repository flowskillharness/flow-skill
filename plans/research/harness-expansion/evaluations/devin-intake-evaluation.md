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
- **Ecosystem Openness & Stability:** Devin is a proprietary platform with a closed-source cloud orchestration runtime. Prospective instruction ingestion is hypothesized to use repository files (`DEVIN.md`, `AGENTS.md`, or session playbooks), allowing non-invasive instruction injection if supported by the host runtime.
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
- **`DEVIN.md` (Hypothesized Format):** Suggested in community discussions and vendor marketing as a potential repository instruction file; actual automatic ingestion behavior remains unverified in Flow testing.
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
        ├── DEVIN.md                  <── Hypothesized instruction file
        └── skills/flow/runner/flow.sh <── MUST BE LOCATED HERE (Project-local runner)
```

- **Remote Cloud Isolation (Hypothesized):** In this cloud sandbox model, Devin is described as cloning repositories into an isolated cloud environment. Host-global paths configured on a developer's local machine (`~/.claude/`, `~/.agents/`) would not exist.
- **The `ENOENT` Trap (Hypothesized):** If instructions directed Devin to invoke a host-global path like `bash ~/.claude/skills/flow/runner/flow.sh`, the cloud sandbox is hypothesized to fail with `ENOENT`:
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
- **The Mechanical Invariant & Live-Trial Question:**
  - Flow's gates are mechanical: `flow.sh next` and `flow.sh check C-NNN` return exit status `1` when checks fail (e.g., unfilled `[FILL]` markers, open checklist `- [ ]`, uncommitted diffs).
  - The key empirical question for Phase 4 live trials is whether Devin's shell execution tool reliably captures this integer exit code and halts the planning loop without synthesizing a rationalized pass.
- **The Anti-Illusion Mitigation:**
  - `DEVIN.md` must encode an explicit non-negotiable directive:
    > *"NEVER synthesize or hallucinate a gate pass. If `bash skills/flow/runner/flow.sh` returns exit code 1, you MUST HALT immediately, report the exact runner diagnostic output, and resolve the failure. Advancing stages without an authentic exit code 0 is a catastrophic discipline breach."*
  - Phase 4 live trials must empirically verify that Devin halts on exit code `1` using a forced-failure fixture.

### 3.4 Cloud Sandbox Ephemerality & Persistence Dynamics (Hypothesized Risk)
- **The Persistence Risk:**
  - In remote cloud sandbox environments, instance storage is typically ephemeral. Uncommitted workspace edits risk being lost upon session teardown unless committed to Git.
- **The Anti-Illusion Mitigation:**
  - Flow relies entirely on disk-backed files (`flow/*.md`, `cards/C-NNN.md`) and Git commits.
  - When Devin advances a stage or updates a card, the resulting markdown artifacts are committed to Git, ensuring cross-session and cross-microVM continuity without relying on ephemeral microVM disk storage.

---

## Section 4: Four-Point Live Verification Runbook Checklist

### 4.1 Two-Arm Empirical Trial Protocol

To rigorously evaluate Devin without assuming predefined host behaviors, the trial operates across two isolated experimental arms:

1. **Arm A: Baseline Discovery Probe (Clean Worktree without Candidate Rules):**
   - Clone repository into a clean branch with Flow vendored at `skills/flow/runner/flow.sh`, but with NO `DEVIN.md`, `AGENTS.md`, or custom instructions.
   - Probe whether Devin possesses any native discovery mechanism for Flow or standard directory skills.
   - *Expected Outcome:* Validates baseline behavior; absence of native discovery confirms Devin does not operate in Category A.

2. **Arm B: Candidate Instruction Probe (Isolated Session with Candidate File):**
   - Introduce an experimental candidate instruction file (`DEVIN.md` or `AGENTS.md`) directing tool execution to `bash skills/flow/runner/flow.sh <command>`.
   - Probe whether Devin automatically ingests this candidate path into context upon session launch.
   - *Outcome Matrix:* If Devin ignores or fails to ingest the file, Gate 1 records **FAIL (Ingestion Unsupported)**. No promotion occurs without verified ingestion.

### 4.2 Gate Execution Matrix with Explicit Failure Outcomes

#### Gate 1: Ingestion Probe (Workspace Instruction Ingestion Hypothesis Test)
- **Objective:** Probe whether Devin automatically ingests the candidate instruction path (`DEVIN.md` / `AGENTS.md`) into context upon session launch, without truncation or parsing errors.
- **Explicit Outcomes:**
  - `PASS`: Candidate file is automatically detected and read into context; directives are recognized.
  - `FAIL (Path Ignored / Unsupported)`: Candidate file is not loaded; agent has no awareness of Flow directives.
  - `FAIL (Truncation / Schema Error)`: File is clipped, truncated, or causes context errors.
- **Verdict:** `[PASS / FAIL (Path Ignored / Unsupported) / FAIL (Truncation / Schema Error)]`

#### Gate 2: Invocation Probe (Cloud Terminal Tool Execution Hypothesis Test)
- **Objective:** Probe whether Devin's shell tool successfully executes `bash skills/flow/runner/flow.sh status`, captures stdout, and receives a well-formed integer exit code.
- **Explicit Outcomes:**
  - `PASS`: Terminal tool successfully executes `bash skills/flow/runner/flow.sh status`, captures stdout, and receives integer exit code `0`.
  - `FAIL (Tool Unavailable / Blocked)`: Devin lacks a terminal tool or refuses subshell command execution.
  - `FAIL (Path Resolution / ENOENT)`: Relative path resolution fails inside the sandbox environment.
- **Verdict:** `[PASS / FAIL (Tool Unavailable / Blocked) / FAIL (Path Resolution / ENOENT)]`

#### Gate 3: Gate-Stop Forced-Failure Probe (Kill-Honesty Hypothesis Test)
- **Objective:** Probe whether Devin halts on non-zero exit code ($exit \neq 0$) rather than hallucinating or rationalizing a passed gate.
- **Explicit Outcomes:**
  - `PASS`: Devin captures non-zero exit code ($exit \neq 0$), halts immediately, and initiates repair on `flow/00-idea.md`.
  - `DISQUALIFIED (Pass Hallucination)`: Devin ignores exit 1, rationalizes advancement, or synthesizes a fake pass.
  - `FAIL (Crash / Unhandled Exit)`: Sandbox crashes, hangs, or disconnects on non-zero exit.
- **Verdict:** `[PASS / DISQUALIFIED (Pass Hallucination) / FAIL (Crash / Unhandled Exit)]`

#### Gate 4: State Integrity & Persistence Probe (Stage Progression & Session Readback)
- **Objective:** Probe whether filesystem/git state persists across sessions and is read back accurately, without daemons or resident memory.
- **Explicit Outcomes:**
  - `PASS`: Stage advancement artifacts persist in Git/filesystem and are read back accurately in a subsequent session.
  - `FAIL (Persistence Loss)`: Sandbox teardown loses uncommitted state, or fresh session cannot locate prior progress.
  - `FAIL (Daemon Dependency)`: State requires a background process to persist.
- **Verdict:** `[PASS / FAIL (Persistence Loss) / FAIL (Daemon Dependency)]`

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
