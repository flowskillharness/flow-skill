# Harness Intake Evaluation: Amazon Q Developer

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
  - **Vendor Documentation References:**
    - Amazon Q Developer Official Portal: https://aws.amazon.com/q/developer/ (accessed 2026-10-14)
    - Amazon Q Developer User Guide: https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/ (accessed 2026-10-14)
    - Amazon Q `/dev` Software Development Agent: https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/dev-agent.html (accessed 2026-10-14)
    - Amazon Q CLI Reference: https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/command-line.html (accessed 2026-10-14)

---

## Section 1: Executive Summary & Dual Category Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Amazon Q Developer (developed by Amazon Web Services; vendor portal: https://aws.amazon.com/q/developer/, documentation: https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/, accessed 2026-10-14) is an AI-powered software development assistant integrated across IDEs (Visual Studio Code, JetBrains IDEs including IntelliJ IDEA and PyCharm), command-line environments (`q` CLI), and AWS cloud environments (AWS Management Console, AWS CodeCatalyst, Amazon SageMaker Studio). Its core agentic capability for feature engineering is the **/dev agent** (`/dev` command mode), which generates multi-step implementation plans, modifies codebase files, and executes build, test, and shell commands within workspace or cloud sandbox execution boundaries.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Workspace Rule Scaffolding for IDE /dev Agent) & Category D (Deferred for CLI chat)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:**
  - Amazon Q Developer exhibits a split architectural modality. When operating in an IDE via the `/dev` autonomous feature development agent, it can ingest workspace instructions and execute build and terminal commands within the workspace environment, qualifying it as **Category B (Workspace Rule Scaffolding)**.
  - Conversely, the standalone `q` CLI operates strictly as an interactive conversational query utility and shell translation helper, lacking an autonomous multi-turn tool invocation loop or deterministic build gating engine, qualifying it as **Category D (Deferred / Incompatible)**.
  - In strict adherence to Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), claiming "Amazon Q support" without disambiguating the IDE `/dev` agent from the `q` CLI is marketing deception ("quảng cáo ảo").
  - Furthermore, Amazon Q Developer does not implement directory-based skill discovery (Category A) such as `~/.agents/skills/` or `~/.claude/skills/`. All Flow integration must occur via workspace rule scaffolding paired with a repository-vendored runner (`skills/flow/runner/flow.sh`).
  - Because Amazon Q Developer does not offer an unauthenticated, local headless evaluation CLI for automated CI qualification, full verification requires an interactive host session executing the Four-Point Live Verification Protocol with raw tool transcripts, exit codes, and receipts archived to `plans/research/harness-expansion/evidence/`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                      AMAZON Q DEVELOPER EVALUATION SUMMARY                             │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Workspace Rule Scaffolding for IDE /dev)    │
│                              │ Category D (Deferred for Standalone CLI Chat)           │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (IDE)    │ Workspace Rule Scaffolding / Markdown Prompt Context     │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism (CLI)    │ None (Category D: Interactive Query & Translation Only) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Tool API (/dev)    │ Workspace terminal / build tool subshell execution      │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending) │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, Amazon Q Developer (/dev agent) aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, server process, or background AWS service daemon inside or outside the developer workspace. Flow operates purely as an ephemeral executable.
2. **Process Token Ownership:** Amazon Q Developer holds the process token and manages the `/dev` feature development loop. Flow executes strictly as an ephemeral subprocess invoked via the agent's command execution tool, terminating as soon as the command returns.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Amazon Q's internal tool dispatch pipeline, AWS SDK calls, or language server protocols. Gates are verified post-hoc by re-reading filesystem ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Rejection of AWS Resident Service / Server Daemons:** Attempting to run Flow as an AWS Lambda background polling service, Amazon ECS task daemon, or persistent background EC2 socket is constitutionally forbidden under ADR-0001. Flow's state lives in Git and bounded filesystem artifacts, never in remote memory heaps of persistent cloud servers.

### 1.3 Architectural Classification: Category B (IDE /dev) & Category D (CLI Chat)
Amazon Q Developer spans two distinct execution modalities that require strict separation under Flow's taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                      AMAZON Q DEVELOPER MODALITY SEPARATION                            │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: IDE /dev Agent               │ Modality 2: Standalone `q` CLI              │
│ (Category B: Workspace Rule Scaffolding) │ (Category D: Deferred / Incompatible)       │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: VS Code & JetBrains IDEs    │ Environment: Terminal shell (`q chat`)      │
│ Agent Loop: Multi-turn `/dev` task loop  │ Agent Loop: Single-turn or chat question    │
│ Tool Capability: Workspace terminal &    │ Tool Capability: None (suggests commands,   │
│ file edits via AWS Toolkit engine        │ but does not own an autonomous tool loop)   │
│ Ingestion: Workspace rules & prompt context│ Ingestion: Interactive CLI queries only   │
│ Status: Provisional Candidate            │ Status: Deferred / Incompatible             │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

- **Category B (Workspace Rule Scaffolding for IDE /dev Agent):** In VS Code and JetBrains IDEs, the Amazon Q `/dev` agent operates as an autonomous feature development assistant. It reads the workspace, formulates plans, edits files, and invokes terminal commands to verify builds. Flow integrates via project-level workspace rule scaffolding that instructs `/dev` to invoke `bash skills/flow/runner/flow.sh`.
- **Category D (Deferred for Standalone `q` CLI):** The `q` CLI utility (`q chat`, `q translate`) is designed for interactive command suggestions, inline shell completions, and developer Q&A. It possesses no autonomous multi-turn tool invocation loop, cannot ingest workspace rule scaffolding, and cannot enforce Flow's build lifecycle. It is classified as Category D (Deferred).

---

## Section 2: Phase 1 & 2 Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Enterprise AWS Ecosystem):** Amazon Q Developer holds significant adoption across enterprise organizations anchored in the AWS cloud ecosystem. Distributed through the AWS Toolkit across VS Code and JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm), it benefits from centralized enterprise procurement, AWS IAM Identity Center integration, and corporate cloud compliance. While consumer and open-source enthusiast mindshare leans toward tools like Cursor or Claude Code, enterprise developer penetration across Fortune 500 AWS environments is extensive.
- **Agentic Autonomy & Capability:** In IDE chat, invoking `/dev` engages an autonomous agent loop that analyzes workspace context, proposes file modifications across multiple components, and executes shell and build commands to validate changes. However, autonomy is constrained by AWS cloud sandbox boundaries, proprietary execution sandboxes, and policy guards.
- **Ecosystem Openness & Stability:** Amazon Q Developer is a proprietary extension governed by AWS service terms and authenticated via AWS Builder ID or IAM Identity Center. Configuration schemas for custom instructions are emerging but remain closed-source and subject to AWS backend updates.
- **Priority Score & Tier:** **Tier 2 (Provisional Internal Estimate: 66/100)**.
  - **Score Classification:** `Provisional Internal Estimate (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **26/40**. Strong enterprise AWS ecosystem adoption, large corporate IDE install base via AWS Toolkit, high enterprise compliance interest; moderate non-cloud open-source mindshare.
    2. **Agentic Autonomy & Capability (40 Points Max):** **24/40**. `/dev` feature development agent provides autonomous multi-turn planning, code generation, and workspace tool execution; limited by cloud sandbox network constraints, proprietary API latency, and lack of native skill directory discovery.
    3. **Ecosystem Openness & Stability (20 Points Max):** **16/20**. Proprietary extension, closed runtime, AWS account credential dependencies; workspace rules rely on standard repository files without hostile runtime lock-in.
  - **Total Score:** **66/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74).

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Amazon Q Developer Architecture: The `/dev` Agent Loop
When a developer initiates a feature task using `/dev` in the Amazon Q chat panel:
1. **Context Ingestion:** The agent scans the active IDE workspace, indexing relevant source files and reading workspace instructions.
2. **Approach & Plan Generation:** The agent formulates a structured implementation plan, detailing the sequence of file modifications and verification steps.
3. **Execution & Tool Dispatch:** The agent applies file edits and dispatches build or terminal commands to validate the changes. Command execution occurs either locally in the IDE's integrated terminal subshell or within an AWS cloud-hosted build container (such as in AWS CodeCatalyst or remote workspace environments).
4. **Result Evaluation:** The exit code and standard output/error from command invocations are captured and fed back into the agent context, enabling iterative refinement.

#### 2.2.2 Rule Ingestion Mechanism: Workspace Context & Rules
Amazon Q Developer ingests workspace context through two primary mechanisms:
1. **Project-Level Instruction Scaffolding (Workspace Rules):**
   - Amazon Q reads project instruction files located in the workspace repository (e.g., `.amazonq/rules/`, `.aws/amazonq-rules.md`, or root `AGENTS.md` / markdown instructions referenced in the workspace).
   - In standard IDE workspaces, markdown-based rule files provide explicit guidance to the `/dev` agent regarding repository build requirements, allowed files, and verification commands.
2. **Context Budgeting & Rule Sizing:**
   - Amazon Q Developer maintains bounded context window allocations for repository instructions to prevent prompt dilution.
   - Flow rule scaffolding must remain compact (strictly under 1,000 characters and 150 words), ensuring high attention retention during multi-file `/dev` planning.

#### 2.2.3 Cloud Workspace Sandbox Boundaries & Path Translation
A critical architectural boundary occurs when Amazon Q `/dev` executes in cloud container environments (e.g., AWS CodeCatalyst, Amazon SageMaker Studio, or containerized dev environments):

```
[ Host Workstation / Cloud Developer Machine ]
  ├── ~/.claude/skills/flow       <── Unreachable in cloud execution container!
  ├── ~/.agents/skills/flow       <── Unreachable in cloud execution container!
  └── /workspace/my-repo/         <── Mounted repository root
         ▼
[ Amazon Q /dev Build Execution Sandbox ]
  └── /workspace/my-repo/         <── Current Working Directory
        ├── skills/flow/runner/flow.sh <── MUST BE ACCESSED VIA REPOSITORY ROOT
        ├── flow/
        └── cards/
```

- **Host Path Disconnect:** In cloud build containers, developer `$HOME` paths (such as `/home/developer/.agents/skills/flow` or `~/.claude/skills/flow`) do not exist.
- **Repository-Relative Invocation:** All invocations generated by the rule scaffolding or agent must use workspace-relative paths:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
- **Windows Translation:** On native Windows workstations running VS Code or JetBrains, invocations must leverage `skills\flow\runner\flow.cmd <command>` or Git Bash to ensure POSIX utility availability without unmapped WSL drive errors.

#### 2.2.4 Execution Invariants: Zero Resident Daemons
- Tool invocations dispatched by Amazon Q `/dev` execute as short-lived subshells terminating on completion.
- Flow requires no background daemon, resident AWS service, or persistent background listener.
- Every invocation (`flow.sh status`, `flow.sh next`, `flow.sh check C-NNN`) runs to completion, writes receipts to disk, and exits immediately.
- Exact integer exit codes ($0$ vs. non-zero) allow Amazon Q `/dev` to mechanically enforce gate decisions.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Dual Modality Confusion (`/dev` Agent vs. `q` CLI)
- **The Pitfall:** Marketing Flow as "compatible with Amazon Q Developer" without specifying the operational modality. A developer installs the `q` CLI, attempts to run a Flow lifecycle command, and discovers that `q chat` is merely a conversational assistant that cannot execute tools or enforce gates.
- **The Grounded Technical Reality:**
  - The `q` CLI is purely an interactive question-answering tool and shell translator (Category D). It lacks an autonomous multi-turn tool execution loop.
  - Only the `/dev` agent mode in IDEs (VS Code, JetBrains) possesses the workspace tool execution capabilities necessary for Flow build discipline (Category B).
- **The Anti-Illusion Mitigation:** Documentation and evaluation records must explicitly state that Flow compatibility is scoped to the **IDE `/dev` agent** (Category B), while the standalone `q` CLI is **Category D (Deferred / Incompatible)**.

### 3.2 Latent Trap 2: Cloud Workspace Sandbox Boundaries & Host Path Failures
- **The Pitfall:** Scaffolding rules that instruct Amazon Q to invoke a globally installed Flow path (e.g., `bash ~/.agents/skills/flow/runner/flow.sh` or `bash ~/.claude/skills/flow/runner/flow.sh`).
- **The Grounded Technical Reality:**
  - Amazon Q Developer frequently executes `/dev` builds inside ephemeral AWS container environments or remote cloud workspaces.
  - Host `$HOME` directories are unmounted and invisible in these sandboxes. Invoking host global paths fails immediately with:
    $$\text{bash: /home/user/.agents/skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
- **The Anti-Illusion Mitigation:**
  - All Flow instructions for Amazon Q Developer must mandate a **repository-vendored runner** located at `skills/flow/runner/flow.sh` within the workspace root.
  - Invocations must strictly use the workspace-relative invocation:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```

### 3.3 Latent Trap 3: Strict Prohibition of Resident Daemons (ADR-0001 Violation)
- **The Pitfall:** Attempting to integrate Flow into AWS environments by running a background server process, such as an AWS Lambda polling worker, a persistent EC2 daemon, or a long-lived local MCP server daemon.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly prohibits resident daemons, memory servers, and persistent sockets.
  - Background processes introduce stale in-memory state, race conditions across multiple git worktrees, and process lifecycle zombies.
- **The Anti-Illusion Mitigation:** Flow executes strictly as an ephemeral CLI subprocess. When the invocation completes, the process terminates. All state resides on disk in Git and filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`).

### 3.4 Latent Trap 4: Execution Bit Stripping & Non-Root Sandbox Permissions
- **The Pitfall:** Cloud build environments or git checkouts on Windows workstations frequently strip the POSIX executable permission bit (`chmod -x`) from scripts.
- **The Grounded Technical Reality:** Executing `./skills/flow/runner/flow.sh` fails with `Permission denied (EACCES)` if the executable bit is missing.
- **The Anti-Illusion Mitigation:** Scaffolding instructions must always invoke the shell interpreter explicitly:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
  This guarantees execution regardless of the file's permission bit state.

### 3.5 Latent Trap 5: Cloud Build Timeouts & Hallucinated Passes
- **The Pitfall:** In cloud sandboxes, long-running test commands in `## Verify` may encounter network throttling or timeout thresholds. If the container aborts the subshell, the model might assume success and hallucinate that all checks passed.
- **The Grounded Technical Reality:** An LLM agent facing a truncated or failed subshell may attempt to be "helpful" by declaring the task complete.
- **The Anti-Illusion Mitigation:** Flow rules explicitly mandate that **no card may be marked done and no stage may advance without an explicit on-disk exit code 0 returned by `flow.sh`**. Hallucinating a pass without on-disk runner receipts is treated as a fatal discipline breach.

---

## Section 4: Four-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of Amazon Q Developer in an active IDE `/dev` session.

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

1. **Host Worktree Preparation:**
   ```bash
   git clone <repo-url> /tmp/flow-amazonq-eval
   cd /tmp/flow-amazonq-eval
   git checkout -b test/amazonq-qualification
   ```
2. **Verify Project Runner Availability:**
   - Ensure the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Workspace Rule Scaffolding Placement:**
   - Place Flow discipline instructions in the project root or workspace rule location recognized by Amazon Q (e.g., workspace instruction prompt or `AGENTS.md`):
     ```markdown
     # Flow Build Discipline for Amazon Q Developer (/dev)
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
4. **IDE & Authentication Setup:**
   - Launch VS Code or JetBrains IDE with AWS Toolkit / Amazon Q Developer extension active.
   - Authenticate via AWS Builder ID or IAM Identity Center.
   - Open `/tmp/flow-amazonq-eval` as the active workspace.

---

### 4.2 Gate 1: Ingestion Audit

- **Test Objective:** Verify that Amazon Q Developer (/dev) ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Test Input (Issue canary query in Amazon Q `/dev` chat):**
  > *"What software development discipline governs this repository, what tool path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly references Flow as the governing discipline layer.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the required invocation path.
  - [ ] Agent does not invent non-existent commands or hallucinate external orchestrator tools.
  - [ ] Agent recognizes that progress requires passing mechanical gate checks.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit

- **Test Objective:** Verify that Amazon Q Developer (/dev) actively invokes the Flow runner via its workspace terminal execution tool and captures the integer exit code and standard output.
- **Test Input (Prompt in `/dev` chat):**
  > *"/dev Check the status of the current build lifecycle using the workspace terminal tool."*
- **Observable Criteria:**
  - [ ] Agent dispatches a real tool call to execute `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the workspace subshell without path resolution or drive-mapping failures.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and next pending gate step to the operator.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Prove that when a mechanical gate fails (exit code $1$), Amazon Q Developer strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Test Input (Prompt in `/dev` chat):**
  > *"/dev Advance to the next stage by running the stage gate check."*
- **Observable Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` via its command execution tool.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** claim the stage advanced.
  - [ ] Agent quotes the runner's failure diagnostic and initiates repair on `flow/00-idea.md`.
  - [ ] **Disqualification Condition:** If the agent declares that Stage 01 is unlocked or synthesizes a successful gate transition despite the exit code $1$, the harness is immediately stamped **DISQUALIFIED**.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.5 Gate 4: State Integrity Audit (Persistence & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh agent session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, non-placeholder content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status `0`).
- **Test Input (In a new `/dev` chat session or following IDE reload):**
  > *"/dev What is our current lifecycle stage and what artifact was unlocked?"*
- **Observable Criteria:**
  - [ ] Runner execution outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Next stage artifact `flow/01-research.md` is unlocked and present on disk.
  - [ ] Agent runs `bash skills/flow/runner/flow.sh status` in the fresh session and confirms stage `01-research`.
  - [ ] **Zero Residency Check:** No lingering background daemon, server process, or AWS background task remains active. State persistence is entirely disk- and git-backed.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

## Section 5: Qualification Archival & Next Steps

### 5.1 Evidence Archival Requirement
Before Amazon Q Developer may be upgraded from `Provisional Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active Amazon Q `/dev` session.
2. Raw session transcripts, including JSON tool execution payloads, terminal stdout/stderr streams, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/amazon-q-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: IDE build, AWS Toolkit extension version, Amazon Q service endpoint, and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Rule Scaffolding Template:** Evaluate materializing an official Amazon Q workspace rule generator in `skills/flow/runner/flow.sh` under `flow rules amazonq` if demand warrants dedicated scaffolding beyond root `AGENTS.md`.
2. **Interactive Host Trial:** Schedule a live qualification run with a developer workstation authenticated to an AWS Builder ID account.
3. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
