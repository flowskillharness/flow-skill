# Harness Intake Evaluation: GitLab Duo (Duo Workflow & Duo Chat)

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Live Host Trials Pending)
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Workspace Rule Scaffolding for Duo Workflow) & Unassessed / Deferred (GitLab Duo Chat)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation References:**
    - GitLab Duo Official Documentation: https://docs.gitlab.com/ee/user/gitlab_duo/ (GitLab Inc., accessed 2026-10-15)
    - GitLab Duo Workflow Documentation: https://docs.gitlab.com/ee/user/duo_workflow/ (GitLab Inc., accessed 2026-10-15)
    - GitLab Duo Workflow Architecture Blueprint: https://docs.gitlab.com/ee/architecture/blueprints/duo_workflow/ (GitLab Inc., accessed 2026-10-15)

---

## Section 1: Executive Summary & Modality Separation (Category B & Category D)

### 1.1 Executive Summary & "Support Thật" Qualification Status
GitLab Duo (developed by GitLab Inc.; vendor portal: https://docs.gitlab.com/ee/user/gitlab_duo/, documentation: https://docs.gitlab.com/ee/user/duo_workflow/, accessed 2026-10-15) is an AI-assisted capability suite integrated throughout the GitLab DevSecOps platform, IDE extensions (GitLab Workflow for Visual Studio Code, JetBrains IDEs, and GitLab Web IDE), and GitLab CI/CD container runner environments.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Proposed Workspace Rule Scaffolding for Duo Workflow) & Unassessed / Deferred Pending Verification (GitLab Duo Chat)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:**
  - GitLab Duo exhibits a fundamental split in operational architecture between two distinct modalities:
    1. **GitLab Duo Workflow:** In vendor documentation, GitLab Duo Workflow is described as an emerging multi-step execution agent. In desk review, its capability to formulate plans, modify files, and invoke terminal subshells in local IDEs or remote CI/CD runner sandboxes is evaluated as an unverified **Category B (Proposed Workspace Rule Scaffolding)** candidate hypothesis.
    2. **GitLab Duo Chat:** Standard Duo Chat historically operates as a conversational assistant in the GitLab Web UI, IDE sidebars, and Web IDE; its autonomous tool execution capability remains unassessed pending dedicated live verification (classified as Unassessed / Deferred Pending Verification).
  - In strict adherence to Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising general "GitLab Duo support" without separating the autonomous Duo Workflow agent from conversational Duo Chat is marketing deception ("quảng cáo ảo").
  - GitLab Duo does not implement directory-based skill discovery (Category A) conforming to the universal Agent Skills standard (`~/.agents/skills/`) or `~/.claude/skills/`. Any prospective Flow integration is proposed to operate via workspace configuration and project instructions (such as `.gitlab/duo_workflow.yml` or repository root `AGENTS.md`) paired with a project-local runner (`skills/flow/runner/flow.sh`).
  - Flow's `flow rules` dispatcher currently implements **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). GitLab Duo is not currently an active target in `flow rules`; all Duo Workflow scaffolding remains a **proposed design candidate** pending live empirical qualification.
  - Because GitLab Duo Workflow requires authenticated cloud coordination through the GitLab Duo Workflow Service and remote/local runner execution sandboxes, full verification requires live interactive host and CI runner trials executing the Four-Point Live Verification Protocol with raw execution transcripts, tool payloads, integer exit codes, and on-disk receipts committed to `plans/research/harness-expansion/evidence/`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        GITLAB DUO EVALUATION SUMMARY                                   │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Proposed Workspace Rule Scaffolding for     │
│                              │ Duo Workflow) & Unassessed / Deferred (GitLab Duo Chat; │
│                              │ Pending Verification)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Workspace configuration / CI/CD context                 │
│                              │ (`.gitlab/duo_workflow.yml` or root `AGENTS.md`)        │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ IDE Extension (VS Code / Web IDE) and GitLab CI/CD      │
│                              │ Container Runners                                       │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal/execution subshell tool           │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake Complete; Live       │
│                              │ Trials Pending)                                         │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with GitLab Duo Workflow aligns with ADR-0001's fundamental invariants (empirical verification pending live host and runner trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation or inside the GitLab CI/CD runner container. Flow executes ephemerally per command and exits immediately.
2. **Process Token Ownership:** The GitLab Duo Workflow service, IDE extension host, and CI/CD runner hold the process token and drive the execution loop. Flow never holds the event loop and executes strictly as an ephemeral subprocess invoked via Duo Workflow's terminal/execution tool, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not wrap, proxy, intercept, or monkey-patch GitLab Duo's internal tool dispatch pipeline, language server communications, or GitLab GraphQL/REST APIs. Flow evaluates gates post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostic output.
5. **Rejection of Resident CI/CD Daemons or Background Services:** Attempting to run Flow as a persistent background daemon, a shared sidecar service in GitLab CI/CD, or an in-memory workflow orchestrator is constitutionally prohibited under ADR-0001. Flow's state lives strictly in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Classification: Category B (Proposed Duo Workflow) vs. Unassessed / Deferred (Duo Chat)
GitLab Duo spans two fundamentally divergent operational modalities that must be strictly separated under Flow's harness taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         GITLAB DUO MODALITY SEPARATION                                 │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: GitLab Duo Workflow          │ Modality 2: GitLab Duo Chat                 │
│ (Category B: Proposed Workspace Scaffold)│ (Unassessed / Deferred Pending Verification)│
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: IDE Extension & CI Runners  │ Environment: Web UI, Web IDE, IDE Sidebar   │
│ Ingestion: `.gitlab/duo_workflow.yml` or │ Ingestion: Interactive chat prompt context  │
│ root `AGENTS.md`                         │ (No verified workspace rule schema)         │
│ Agent Loop: Hypothesized autonomous plan &  │ Agent Loop: Unassessed (Historically        │
│ execution loop                           │ conversational)                             │
│ Tool API: Hypothesized execution subshell   │ Tool API: Unassessed (Historically suggests │
│ execution tool                           │ snippets; tool execution unassessed)        │
│ Status: Provisional Candidate            │ Status: Unassessed / Deferred               │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: GitLab Duo Workflow (Category B: Proposed Workspace Rule Scaffolding)
- **Environment:** Local developer IDE (VS Code with GitLab Workflow extension) and remote GitLab CI/CD container runners provisioned for automated workflow execution.
- **Rule Ingestion:** Proposed via workspace workflow configuration (`.gitlab/duo_workflow.yml`) or repository root instructions (`AGENTS.md`).
- **Tool Execution:** Duo Workflow provides an autonomous execution subshell capable of invoking bash commands in the workspace environment, capturing stdout/stderr, and receiving exit codes.
- **Classification:** Category B (Proposed Workspace Rule Scaffolding).

#### Modality 2: GitLab Duo Chat (Unassessed / Deferred Pending Verification)
- **Environment:** GitLab Web UI, GitLab Web IDE, and IDE sidebar panels.
- **Conversational Scope:** Functions primarily as an interactive code explanation, documentation lookup, and refactoring assistant. It answers developer queries and suggests code blocks in Markdown.
- **Tool Execution Scope:** In vendor documentation and desk analysis, standard Duo Chat historically operates as a conversational query assistant; an autonomous tool execution loop and runner exit-code handling remain unassessed pending dedicated live verification.
- **Classification:** Unassessed / Deferred Pending Verification (Historically conversational).

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring
- **Market Share & Developer Adoption:** GitLab Duo serves a massive enterprise developer base embedded within self-managed GitLab EE/CE instances and GitLab.com SaaS. Organizations subject to strict data sovereignty, regulatory compliance (FedRAMP, HIPAA, SOC 2), and air-gapped security policies frequently standardize on GitLab for source code management, CI/CD, and DevSecOps. While consumer AI mindshare is concentrated around tools like Cursor and Claude Code, GitLab's enterprise penetration represents a widespread, high-value user segment.
- **Agentic Autonomy & Capability:** GitLab Duo spans a wide autonomy spectrum:
  - Duo Chat historically operates as a conversational query assistant; its autonomous tool-loop capability remains unassessed in verified testing.
  - Duo Workflow is described in vendor documentation as an emerging multi-step planning and tool execution agent; its empirical subshell execution and gate-stop fidelity remain unverified in Flow trials.
- **Ecosystem Openness & Stability:** GitLab operates on an open-core model. While the GitLab Community Edition source code is public, GitLab Duo and Duo Workflow rely on proprietary cloud backend services (GitLab Duo Workflow Service / AI Gateway). Configuration formats are emerging and documented, but runtime orchestration is closed-source.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Unverified Internal Desk Hypothesis)**.
- **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
  1. Market Adoption Hypothesis: Extensive enterprise GitLab ecosystem developer base.
  2. Agentic Autonomy Hypothesis: Duo Workflow provides an emerging multi-step planning loop (empirical tool-loop and gate-stop fidelity unverified in Flow trials); standard Duo Chat historically operates as conversational query assistant.
  3. Ecosystem Openness Hypothesis: Open-core / proprietary enterprise service.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Duo Workflow Execution Subsystem & Agent Loop
The GitLab Duo Workflow architecture decouples model planning from execution:
1. **Duo Workflow Service (Control Plane):** A centralized service communicating with the GitLab AI Gateway and underlying LLMs (e.g., Anthropic Claude models). It maintains task state, generates multi-step plans, and coordinates tool execution requests.
2. **Execution Client (Data Plane):** The local IDE extension (GitLab Workflow in VS Code) or the GitLab CI/CD runner container acts as the execution client.
3. **Execution Subshell Tool (Hypothesized):** In vendor architectural blueprints, Duo Workflow is described as dispatching execution requests to the execution client, hypothesized to execute commands in a subshell, capture stdout/stderr, and return the integer exit code to the control plane (unverified pending live trials).
4. **Iterative Refinement:** If a command exits with status $0$, Duo Workflow marks the step completed; if it exits non-zero ($\text{exit} \neq 0$), Duo Workflow is designed to evaluate error diagnostics and attempt corrective actions.

> **Unverified Desk Hypothesis (Anti-Illusion Disclosure):** The execution subshell tool dispatch, stdout/stderr capture, and integer exit code return path described above are **unverified desk hypotheses** derived from vendor documentation. They have not been observed in a live Duo Workflow host session and remain pending live host trials under the Four-Point Live Verification Protocol (Section 4).

#### 2.2.2 Rule & Instruction Ingestion Mechanism
Duo Workflow ingests operational context through repository-level configuration and workspace instructions:
1. **Workflow Configuration (`.gitlab/duo_workflow.yml`):** Proposed workflow definition file where project-specific instructions, constraints, and tool invocation contracts can be declared.
2. **Root Context File (`AGENTS.md`):** As GitLab tooling embraces standard agent instructions, root `AGENTS.md` provides cross-agent build discipline instructions.
3. **Context Budgeting:** GitLab Duo enforces token budgets on system instructions to avoid attention degradation. Scaffolding rules must remain compact (strictly under 1,000 characters and 150 words) to ensure high retention during extended multi-step workflows.

> **Unverified Desk Hypothesis (Anti-Illusion Disclosure):** The existence, schema, and ingestion of `.gitlab/duo_workflow.yml` (and `AGENTS.md` pickup by Duo Workflow) are **unverified desk hypotheses**. No live host trial has demonstrated that a GitLab execution client parses this file or applies its tool invocation contracts; verification remains pending live host trials under Section 4.

#### 2.2.3 CI/CD Runner Sandbox vs. Local IDE Execution Boundaries
GitLab Duo Workflow can execute in two distinct operational environments: a local developer IDE or an isolated GitLab CI/CD container runner. This introduces a critical architectural boundary:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                 GITLAB DUO WORKFLOW EXECUTION BOUNDARIES                               │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Environment A: Local IDE Workspace       │ Environment B: GitLab CI/CD Runner Sandbox  │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Host Machine (Developer Workstation)     │ Ephemeral GitLab Runner Docker Container    │
│  ├── ~/.claude/skills/flow               │  ├── /builds/group/project/ (Workspace)    │
│  ├── ~/.agents/skills/flow               │  │    ├── skills/flow/runner/flow.sh (✓)   │
│  └── /workspace/project/                 │  │    ├── flow/                             │
│       ├── skills/flow/runner/flow.sh     │  │    └── cards/                            │
│       ├── flow/                          │  └── Host global ~/.agents/ DOES NOT EXIST! │
│       └── cards/                         │      (Invoking ~/.agents/ -> ENOENT Crash)  │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

- **The Host-Global Path Disconnect:** In GitLab CI/CD runner containers, developer `$HOME` paths on their local laptops (e.g., `~/.agents/skills/flow/` or `~/.claude/skills/flow/`) do not exist.
- **The `ENOENT` Trap:** Instructing Duo Workflow to invoke host-global paths causes immediate failure:
  $$\text{bash: /home/user/.agents/skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
- **Project-Local Runner Requirement:** All Duo Workflow instructions must strictly mandate executing the project-local runner located at `skills/flow/runner/flow.sh`:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```

#### 2.2.4 Execution Invariants: Zero Resident Daemons & Ephemeral Invocations
- Flow requires no resident background daemon, background server process, or persistent listening socket inside the GitLab CI/CD runner or developer IDE.
- Every Flow command (`flow.sh status`, `flow.sh next`, `flow.sh check C-NNN`) runs as an ephemeral subshell command, outputs plain-text diagnostics, writes deterministic receipts to disk, and immediately exits.
- Exact integer exit codes ($0$ for pass, $1$ for failure) are returned to Duo Workflow's execution client, allowing the agent to mechanically enforce gate decisions.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion (Duo Workflow vs. Duo Chat)
- **The Pitfall:** Advertising Flow as "compatible with GitLab Duo" without explicitly distinguishing the operational modality. A developer opens GitLab Duo Chat in the Web UI or IDE sidebar, types a prompt to advance a stage, and discovers that Duo Chat merely generates a conversational reply explaining how to advance rather than executing the gate command.
- **The Grounded Technical Reality:**
  - GitLab Duo Chat is a non-agentic conversational assistant. It does not possess an autonomous tool execution loop and cannot dispatch shell commands to enforce mechanical gates.
  - Only GitLab Duo Workflow possesses the autonomous multi-step execution loop capable of dispatching shell commands within an execution client.
- **The Anti-Illusion Mitigation:** Documentation, matrix entries, and evaluation records must explicitly state that Flow compatibility is scoped strictly to **GitLab Duo Workflow** (Category B), while standard **GitLab Duo Chat** is classified as **Category D (Deferred / Non-Agentic Conversational)**.

### 3.2 Latent Trap 2: CI/CD Runner Sandbox vs. Local IDE (Host Path Disconnect & ENOENT)
- **The Pitfall:** Writing scaffolding instructions that direct the agent to execute a globally installed Flow path (e.g., `bash ~/.agents/skills/flow/runner/flow.sh`).
- **The Grounded Technical Reality:**
  - When Duo Workflow executes in a GitLab CI/CD runner container (e.g., Docker-in-Docker or isolated Linux runner image), the host filesystem is not mounted. The runner environment contains only the cloned repository under `/builds/<group>/<project>/`.
  - Invoking `~/.agents/skills/flow/runner/flow.sh` triggers an immediate `ENOENT: No such file or directory` crash.
- **The Anti-Illusion Mitigation:**
  - Scaffolding instructions must always reference the repository-vendored runner tree:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - Workspaces must verify the presence of `skills/flow/runner/flow.sh` in repository source control prior to enabling Duo Workflow execution.

### 3.3 Latent Trap 3: Strict Prohibition of Background Daemons (ADR-0001 Violation)
- **The Pitfall:** Attempting to integrate Flow into GitLab environments by deploying a resident daemon, such as a long-lived CI/CD service container sidecar, a background GitLab webhook listener daemon, or an in-memory MCP server daemon running alongside the IDE extension.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly forbids resident daemons, servers, and background memory processes.
  - Long-lived background processes introduce stale in-memory state, concurrency race conditions across parallel pipeline jobs, and zombie processes in runner containers.
- **The Anti-Illusion Mitigation:** Flow executes strictly as an ephemeral CLI subprocess. Each invocation terminates immediately upon return. All persistent state resides on disk in Git and filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).

### 3.4 Latent Trap 4: Container Execution Bit Stripping & Non-Root Runner Permissions
- **The Pitfall:** GitLab CI/CD runners or git repositories checked out across diverse operating systems may strip the POSIX executable permission bit (`chmod -x`) from `flow.sh`. Additionally, GitLab CI runners often execute under unprivileged user accounts (`gitlab-runner` or `nobody`).
- **The Grounded Technical Reality:** Invoking `./skills/flow/runner/flow.sh` directly fails with `Permission denied (EACCES)` if the executable bit is missing or the filesystem is mounted `noexec`.
- **The Anti-Illusion Mitigation:** Scaffolding rules must explicitly invoke the shell interpreter:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
  Invoking via `bash` ensures reliable execution regardless of the file's permission bit state.

### 3.5 Latent Trap 5: Runner Timeouts & Synthesized Pass Hallucinations
- **The Pitfall:** GitLab CI/CD container jobs enforce execution timeouts. If a build or test command times out or is aborted by the runner, an unconstrained LLM agent may attempt to resolve the stalled task by declaring the step complete.
- **The Grounded Technical Reality:** An LLM agent facing a truncated or failed subshell may hallucinate a successful gate transition, claiming that all criteria were met.
- **The Anti-Illusion Mitigation:** Flow rules explicitly mandate that **no card may be marked done and no stage may advance without an explicit on-disk exit code 0 returned by `flow.sh`**. Hallucinating a pass without on-disk runner receipts is treated as a fatal discipline breach that immediately disqualifies the harness.

---

## Section 4: Four-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of GitLab Duo Workflow in an active execution session.

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
   git clone <repo-url> /tmp/flow-gitlab-duo-eval
   cd /tmp/flow-gitlab-duo-eval
   git checkout -b test/gitlab-duo-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Workspace Rule Scaffolding Placement:**
   - Place Flow discipline instructions in the project root (`AGENTS.md`) or workflow configuration (`.gitlab/duo_workflow.yml`):
     ```markdown
     # Flow Build Discipline for GitLab Duo Workflow
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
4. **Execution Client Configuration:**
   - Open `/tmp/flow-gitlab-duo-eval` in VS Code with the GitLab Workflow extension configured and authenticated to a GitLab instance with Duo Workflow enabled (or trigger a Duo Workflow execution pipeline in GitLab CI/CD).

---

### 4.2 Gate 1: Ingestion Audit

- **Test Objective:** Verify that GitLab Duo Workflow ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Test Input (Canary query issued to Duo Workflow):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly identifies Flow as the governing development discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands, hallucinate external orchestrator tools, or reference host-global paths (`~/.agents/`).
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - **FAIL (Schema Error / Parsing Crash):** The execution client or workflow service fails to parse `.gitlab/duo_workflow.yml` or crashes during workspace instruction indexing.
  - **FAIL (Context Truncation):** Agent fails to identify Flow, ignores project instructions, or exhibits severe prompt dilution.
  - **FAIL (Path Hallucination):** Agent specifies an imaginary command or attempts to invoke host-global paths that do not exist in the execution environment.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit

- **Test Objective:** Verify that GitLab Duo Workflow actively invokes the Flow runner via its execution subshell tool, captures the integer exit code, and reads stdout/stderr.
- **Test Input (Prompt in Duo Workflow task):**
  > *"Check the status of the current build lifecycle using the execution terminal tool."*
- **Observable Criteria:**
  - [ ] Agent dispatches an active tool call to execute `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the execution subshell without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.
- **Explicit Failure Outcomes:**
  - **FAIL (Subshell Dispatch Failure):** The execution client refuses or fails to execute shell commands.
  - **FAIL (Path Resolution Error):** Command fails with `ENOENT: No such file or directory` or attempts to run an unmapped path.
  - **FAIL (Output Truncation / Loss of Exit Code):** Execution client drops stdout or fails to pass the return code back to the control plane, causing the agent to stall.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), GitLab Duo Workflow strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Test Input (Prompt in Duo Workflow task):**
  > *"Advance to the next stage by executing the stage gate check in the terminal."*
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via its execution subshell tool.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** synthesize or declare that the stage advanced.
  - [ ] Agent quotes the runner's diagnostic failure output and attempts to edit and repair `flow/00-idea.md`.
- **Explicit Failure Outcomes & Disqualification:**
  - **DISQUALIFIED (Pass Hallucination):** The agent declares that Stage 01 is unlocked or claims the gate passed despite the runner exiting with status code `1`. Any hallucinated pass is an **immediate disqualification**.
  - **FAIL (Blind Retry Loop):** Agent enters an unconstrained infinite loop repeatedly executing `flow.sh next` without reading failure diagnostics or editing `flow/00-idea.md`.
  - **FAIL (Silent Failure):** Agent swallows the non-zero exit code and marks the workflow complete without operator notification.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.5 Gate 4: State Integrity Audit (Persistence & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh agent session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Test Input (In a new Duo Workflow session or after container reload):**
  > *"What is our current lifecycle stage and what artifact was unlocked?"*
- **Observable Criteria:**
  - [ ] Runner execution outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Next stage artifact `flow/01-research.md` is unlocked and present on disk.
  - [ ] Agent executes `bash skills/flow/runner/flow.sh status` in the fresh session and confirms stage `01-research`.
  - [ ] **Zero Residency Check:** Zero background daemons, resident server processes, or persistent background tasks remain active. State persistence is entirely disk- and git-backed.
- **Explicit Failure Outcomes:**
  - **FAIL (State Desynchronization):** A new session cannot read the unlocked stage or reports stale/corrupted lifecycle state.
  - **FAIL (Artifact Mutation):** The agent corrupts or deletes lifecycle receipts or stages during readback.
  - **FAIL (Daemon Residency Breach):** A lingering background process or memory server is detected after workflow completion (violating ADR-0001).
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

## Section 5: Qualification Archival & Next Steps

### 5.1 Evidence Archival Requirement
Before GitLab Duo Workflow may be upgraded from `Provisional Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active GitLab Duo Workflow session (local IDE or CI runner).
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/gitlab-duo-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: GitLab version (EE/CE), GitLab Workflow extension version, AI Gateway service version, and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Rule Scaffolding Template Evaluation:** Assess whether developer demand warrants introducing a dedicated `flow rules gitlab` command to generate `.gitlab/duo_workflow.yml`, or whether standard repository root `AGENTS.md` provides sufficient coverage.
2. **Interactive Host & CI Runner Trials:** Schedule live qualification trials on a developer machine with the GitLab Workflow extension and within a GitLab CI/CD pipeline runner environment.
3. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
