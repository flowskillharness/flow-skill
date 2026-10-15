# Harness Intake Evaluation: Sourcegraph Cody (VS Code & JetBrains)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Provisional Candidate (Desk Intake Complete; Live Host Trials Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Workspace Rule Scaffolding for VS Code / JetBrains) & Category D (Deferred for Web/Search Only)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation References:**
    - Sourcegraph Cody Official Portal: https://sourcegraph.com/cody (accessed 2026-10-15)
    - Sourcegraph Cody Documentation: https://sourcegraph.com/docs/cody (accessed 2026-10-15)
    - Sourcegraph Cody GitHub Repository: https://github.com/sourcegraph/cody (Apache-2.0, accessed 2026-10-15)

---

## Section 1: Executive Summary & Modality Separation (Proposed Category B & Unassessed Web Modality)

### 1.1 Executive Summary & "Support Thật" Qualification Status
Sourcegraph Cody (developed by Sourcegraph Inc.; vendor portal: https://sourcegraph.com/cody, documentation: https://sourcegraph.com/docs/cody, source repository: https://github.com/sourcegraph/cody, Apache-2.0, accessed 2026-10-15) is an AI-assisted code intelligence platform and developer extension. Cody operates across multiple IDEs—including Visual Studio Code, JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm, GoLand), and Neovim (via the `cody-agent` protocol)—as well as within the web-based Sourcegraph code navigation and search platform. Cody integrates code graph embeddings, syntax tree analysis, context-fetching protocols (such as OpenCTX), multi-turn chat, inline code generation, multi-file code editing (`Cody Edits`), and emerging agentic workflows.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Workspace Rule Scaffolding for VS Code / JetBrains) & Unassessed / Deferred (Web Search / Read-Only Interface)**.
- **Qualification Status:** **`PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)`**.
- **Qualification Rationale:**
  - In desk review, Sourcegraph Cody exhibits an architectural split between developer IDE environments (VS Code, JetBrains, Neovim) and the web-based enterprise code search interface. In IDE environments, Cody supports repository-scoped context ingestion via workspace configuration, OpenCTX context providers, and root `AGENTS.md` instructions, alongside multi-file code edits and interactive terminal command execution. This IDE modality represents a **Category B (Workspace Rule Scaffolding)** candidate hypothesis.
  - Conversely, Cody operating within the web-based Sourcegraph search UI functions as an enterprise code search interface; its workspace tool execution capabilities remain unassessed pending dedicated verification (classified as Unassessed / Deferred).
  - In strict adherence to Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), advertising general "Sourcegraph Cody support" without distinguishing the IDE extension modality from web-based code search represents marketing deception ("quảng cáo ảo").
  - In standard developer usage within IDEs, Cody Chat primarily operates as an interactive conversational assistant that suggests terminal commands and code modifications for manual user execution. While emerging Cody Agent modes support programmatic tool dispatches, autonomous multi-turn shell execution loops that mechanically capture non-zero exit codes ($\text{exit} \neq 0$) and halt upon gate failures have not been empirically verified against live host runtimes.
  - Flow's `flow rules` dispatcher currently generates **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). Sourcegraph Cody is not an active target in `flow rules`; all prospective Cody scaffolding remains a **proposed design candidate** pending live empirical qualification through the Four-Point Live Verification Protocol.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        SOURCEGRAPH CODY EVALUATION SUMMARY                             │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Workspace Rule Scaffolding for VS Code /   │
│                              │ JetBrains) & Unassessed / Deferred (Web Search /       │
│                              │ Read-Only Interface)                                    │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Workspace prompt configuration / OpenCTX context        │
│                              │ providers / root `AGENTS.md`                            │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ IDE Extension (VS Code, JetBrains, Neovim)              │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized terminal / shell execution tool            │
│                              │ (Cody Chat / Edits)                                     │
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

In desk design review, prospective integration with Sourcegraph Cody in IDE environments aligns with ADR-0001's fundamental invariants (empirical verification pending live host trials):
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, long-lived server process, or background socket listener on the developer workstation. While Cody relies on an internal background language server/agent process (`cody-agent` Node service) to interface between IDEs and LLM endpoints, Flow must never execute as a resident service inside or alongside that daemon. Flow executes strictly as an ephemeral executable via `skills/flow/runner/flow.sh` (or `flow.cmd`).
2. **Process Token Ownership:** The IDE extension host and Cody runtime hold the process token and manage the conversational event loop. Flow executes strictly as an ephemeral subprocess invoked via terminal commands, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Cody's model communications, OpenCTX context fetches, or extension IPC. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Rejection of Resident MCP / Language Server Wrappers:** Attempting to wrap Flow inside a resident OpenCTX provider server, an in-memory MCP server daemon, or a persistent language server wrapper is constitutionally prohibited under ADR-0001. Flow's state lives strictly on disk in Git and bounded filesystem artifacts, never in resident memory heaps.

### 1.3 Architectural Classification: Category B (Proposed IDE Extension) vs. Unassessed / Deferred (Web Search)
Sourcegraph Cody spans two fundamentally distinct operational modalities that must be strictly separated under Flow's harness taxonomy:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         SOURCEGRAPH CODY MODALITY SEPARATION                           │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Modality 1: Cody IDE Extension           │ Modality 2: Sourcegraph Web Search / Chat   │
│ (Category B: Workspace Rule Scaffolding) │ (Unassessed / Deferred (Web Search /       │
│                                          │ Read-Only Interface)                       │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Environment: VS Code, JetBrains, Neovim  │ Environment: Sourcegraph Cloud & Enterprise │
│                                          │ Web UI                                      │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Ingestion: Workspace prompt config /     │ Ingestion: Conversational web prompt query  │
│ OpenCTX providers / root `AGENTS.md`     │ (Global repository search context only)     │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Agent Loop: Multi-turn chat, inline diffs│ Agent Loop: Single-turn conversational Q&A  │
│ and multi-file `Cody Edits`              │ and code search exploration                 │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Tool API: Hypothesized terminal / shell  │ Tool API: None (Cannot invoke host shell or │
│ execution tool (interactive / subshell)  │ modify local workspace files)               │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Status: Provisional Candidate            │ Status: Deferred / Incompatible             │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

#### Modality 1: Sourcegraph Cody IDE Extension (Category B: Workspace Rule Scaffolding)
- **Environment:** Local developer IDEs (VS Code, JetBrains IDEs, and Neovim) running the official Sourcegraph Cody extension.
- **Rule Ingestion:** Evaluated via workspace prompt configuration (`.vscode/cody.json` custom commands or modern Cody prompt configuration), OpenCTX context providers, or standard root `AGENTS.md` instructions.
- **Tool Execution:** Hypothesized terminal and shell execution capability (surfacing suggested commands to the integrated terminal or invoking subshells during automated tasks).
- **Classification:** Category B (Workspace Rule Scaffolding Candidate).

#### Modality 2: Sourcegraph Web Search & Web Cody (Unassessed / Deferred (Web Search / Read-Only Interface))
- **Environment:** Sourcegraph Cloud (sourcegraph.com) or self-hosted Sourcegraph Enterprise web application.
- **Conversational Scope:** Read-only enterprise codebase search, cross-repository code indexing, and conversational explanation. It answers queries by referencing indexed code graph symbols.
- **Lack of Local Execution Subsystem:** Web Cody operates as a web-based code search interface; local terminal tool execution and gate enforcement capabilities remain unassessed in verified testing (Unassessed / Deferred).
- **Classification:** Unassessed / Deferred (Web Search / Read-Only Interface).

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring

- **Market Share & Developer Adoption (Enterprise & Community):** Sourcegraph Cody commands substantial enterprise and open-source adoption, backed by Sourcegraph's established market position as a premier enterprise code search and navigation engine. Organizations with massive monorepos, multi-repository microservice architectures, and strict compliance mandates deploy Sourcegraph on-premise or via private cloud. The Cody extension enjoys widespread installation across VS Code and JetBrains IDEs.
- **Agentic Autonomy & Capability (Interactive vs. Autonomous Loop):** Cody excels at code explanation, symbol navigation, and multi-file code editing (`Cody Edits`). However, in standard chat mode, Cody functions primarily as an interactive assistant proposing code blocks and terminal commands for user execution. While recent agentic features and the underlying `cody-agent` protocol introduce automated file edits and tool execution hooks, an unprompted, autonomous shell loop capable of rigorous gate-stop behavior on mechanical non-zero exit codes remains unverified in live host trials.
- **Ecosystem Openness & Stability:** The Cody client extension and `cody-agent` core are developed as open-source software under the Apache-2.0 license (`sourcegraph/cody`). Sourcegraph actively spearheads the OpenCTX open context standard for modular context retrieval.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Unverified Internal Desk Hypothesis)**.
- **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
  1. Market Adoption Hypothesis: Substantial enterprise codebase search and AI assistant adoption across VS Code and JetBrains IDEs.
  2. Agentic Autonomy Hypothesis: Conversational chat and multi-file Cody Edits; unprompted terminal loop and gate-stop fidelity unverified in Flow trials.
  3. Ecosystem Openness Hypothesis: Open source client extension (Apache-2.0), open OpenCTX context protocol.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Extension Architecture & `cody-agent` Communication
Cody utilizes a modular client-agent architecture:
1. **IDE Client Layer:** VS Code extension, JetBrains plugin, and Neovim client handling UI presentation, diff previews, editor selections, and notifications.
2. **`cody-agent` Subsystem:** A background Node/TypeScript JSON-RPC service that communicates with the IDE frontend, manages local workspace indexing, dispatches context queries, and interfaces with LLM endpoints (via Sourcegraph Enterprise instances or Sourcegraph Cloud).
3. **Execution Boundary:** The IDE extension host and `cody-agent` have access to local file operations and IDE terminal APIs. However, terminal command execution in typical chat interactions requires user confirmation ("Run in Terminal" action) or manual copy-pasting.

#### 2.2.2 Rule & Prompt Ingestion Evolution
Cody provides several context ingestion pathways:
- **Workspace Configuration & Prompt Files:** Historically configured via `.vscode/cody.json` custom commands, moving toward standardized workspace prompts and custom commands defined in `.cody/prompts/` or `.cody/commands/`.
- **OpenCTX Context Providers:** OpenCTX allows developers to attach custom context providers (e.g., retrieving issue trackers, design docs, or repository metadata) into Cody's prompt context via `@-mentions` or automated context inclusion rules.
- **Repository Root Instructions (`AGENTS.md`):** Cody automatically indexes workspace markdown files. Placing Flow discipline instructions in the project root `AGENTS.md` allows Cody's semantic and keyword search to retrieve Flow rules during task execution.
- **Schema Stability:** While custom command configurations have evolved across Sourcegraph releases, repository-level `AGENTS.md` remains the most resilient, backward-compatible ingestion mechanism for Cody.

#### 2.2.3 Tool Execution API & Terminal Subsystem Reality
- **Interactive Terminal Proposals:** When asked to check project status or run a build, Cody Chat historically outputs a markdown code fence containing the suggested terminal snippet (e.g., `bash skills/flow/runner/flow.sh status`). In default conversational chat, the operator must review and trigger execution.
- **Hypothesized Autonomous Subshell Tool:** Advanced agent modes in Cody are hypothesized to dispatch shell commands autonomously via IDE terminal APIs. However, whether Cody inspects the integer exit code ($0$ vs. non-zero) and mechanically halts execution—rather than treating error text as conversational feedback—requires empirical verification.
- **Absence of Headless Evaluation Mode:** Cody does not provide an official standalone headless CLI evaluation mode comparable to `codex exec` or Claude Code CLI. Live qualification must be conducted interactively within an active IDE session.

#### 2.2.4 Context Budgeting & Token Dynamics
- **Enterprise Code Graph Retrieval:** Cody relies on embeddings, keyword search, and Sourcegraph's code graph index to assemble relevant prompt context. In large enterprise codebases, broad queries can retrieve dozens of irrelevant code snippets, diluting the effective context window.
- **Instruction Dilution Mitigation:** Injecting monolithic rule files into Cody risks truncation or context crowding. Flow scaffolding for Cody must remain ultra-lean (< 100 tokens), delegating in-depth stage rules to on-disk reference playbooks (`skills/flow/references/*.md`).

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

This section evaluates the integration against Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §2) and architectural compatibility requirements.

### 3.1 Latent Trap 1: Modality Separation (IDE Chat & Edits vs. Web UI Search)
- **The Pitfall:** Advertising Flow as universally compatible with "Sourcegraph Cody" without differentiating between IDE extensions and the Sourcegraph Web UI. A developer opens Sourcegraph Web Search, invokes Cody Chat to advance a Flow stage, and discovers that Web Cody cannot execute shell commands, read local disk receipts, or update cards.
- **The Grounded Technical Reality:**
  - Sourcegraph Web UI Cody is a remote, read-only conversational code search tool. It operates entirely in the cloud and has no access to the developer's local subshell or filesystem.
  - Only Cody running inside an IDE extension (VS Code, JetBrains, Neovim) possesses access to local project files and the integrated terminal.
- **The Anti-Illusion Mitigation:** Documentation and compatibility matrix entries must explicitly scope Category B candidacy to **Cody IDE Extensions (VS Code & JetBrains)**, while categorizing Sourcegraph Web UI Cody as **Category D (Deferred for Web/Search Only)**.

### 3.2 Latent Trap 2: Terminal Autonomy & The Copy-Paste Illusion
- **The Pitfall:** Assuming that because Cody displays a terminal command code fence (`bash skills/flow/runner/flow.sh next`) in chat, the harness has autonomously executed the command and verified the gate.
- **The Grounded Technical Reality:**
  - In standard chat, Cody does not execute shell commands autonomously. It proposes snippets for the human developer to execute.
  - If the user forgets to run the command, or runs it and encounters an exit code `1`, Cody has no automated subshell loop to catch the failure unless the developer pastes the terminal output back into the chat.
  - This creates the illusion of automated gating while placing the mechanical burden entirely on the human.
- **The Anti-Illusion Mitigation:** Live qualification must specifically test whether Cody operates in an autonomous tool execution loop, or whether it functions as a semi-autonomous assistant requiring operator mediation. Under no circumstances may Cody declare a stage advanced without verifying that the runner executed and returned exit code 0.

### 3.3 Latent Trap 3: Strict Prohibition of Resident Cody Background Daemons & Language Server Wrappers
- **The Pitfall:** Attempting to integrate Flow into Cody by wrapping `flow.sh` in a persistent OpenCTX server daemon, a long-lived Node.js language server wrapper, or a resident background process running alongside `cody-agent`.
- **The Grounded Technical Reality:**
  - ADR-0001 strictly prohibits resident daemons, memory servers, and persistent listening sockets:
    > *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*
  - Persistent background wrappers introduce stale in-memory cache states, zombie processes across IDE restarts, and synchronization bugs across parallel worktrees.
- **The Anti-Illusion Mitigation:** Flow operates strictly as an ephemeral executable. Each invocation (`bash skills/flow/runner/flow.sh <verb>`) spawns a discrete process, performs mechanical verification against disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`), emits plain-text diagnostics, and exits immediately. Zero daemons are permitted.

### 3.4 Latent Trap 4: Embeddings Dilution & Token Budget Truncation in Enterprise Codebases
- **The Pitfall:** Providing an extensive, multi-kilobyte rule file in `.cody/prompts/` or `.vscode/cody.json`. In massive enterprise repositories, Cody's context retrieval engine blends workspace instructions with embeddings from dozens of indexed source files, causing prompt dilution and instructions to be ignored.
- **The Grounded Technical Reality:** When context windows are saturated with code graph embeddings, instruction-following fidelity degrades significantly. The agent tends to hallucinate gate completions and bypass checklist verification.
- **The Anti-Illusion Mitigation:** Workspace rule scaffolding must be ultra-compact (< 100 tokens in `AGENTS.md` or workspace prompt configs), establishing pointer directives to on-disk reference playbooks (`skills/flow/references/gate-rules.md`).

### 3.5 Latent Trap 5: Shell Environment & Relative Path Disconnect (`flow.sh` Execution)
- **The Pitfall:** Writing rules that assume a global installation path (e.g., `~/.agents/skills/flow/runner/flow.sh`) or invoking `./skills/flow/runner/flow.sh` without the shell interpreter.
- **The Grounded Technical Reality:**
  - In enterprise settings, developers work in heterogeneous environments (Windows with PowerShell/WSL, Linux workstations, macOS).
  - Checking out repositories on Windows often strips the executable bit (`chmod -x`). Invoking `./skills/flow/runner/flow.sh` directly fails with `EACCES` or unrecognized binary format.
- **The Anti-Illusion Mitigation:** All scaffolding instructions must mandate explicit shell invocation using relative paths:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```
  On native Windows without bash, invoke via:
  ```cmd
  skills\flow\runner\flow.cmd <command>
  ```

---

## Section 4: Four-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook defines the exact operational procedure for conducting the live empirical qualification trial of Sourcegraph Cody (IDE Extension) in an active developer workspace.

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
   git clone <repo-url> /tmp/flow-cody-eval
   cd /tmp/flow-cody-eval
   git checkout -b test/cody-qualification
   ```
2. **Verify Project Runner Availability:**
   - Confirm the repository contains the vendored Flow runner tree:
     ```bash
     test -f skills/flow/runner/flow.sh && echo "Flow runner present."
     chmod +x skills/flow/runner/flow.sh
     ```
3. **Workspace Rule Scaffolding Placement:**
   - Place Flow discipline instructions in the project root (`AGENTS.md`) or Cody prompt configuration:
     ```markdown
     # Flow Build Discipline for Sourcegraph Cody
     Always invoke Flow via: bash skills/flow/runner/flow.sh <command>
     - Status: bash skills/flow/runner/flow.sh status
     - Advance stage: bash skills/flow/runner/flow.sh next
     - Verify card: bash skills/flow/runner/flow.sh check C-NNN
     NEVER proceed or declare complete if a command exits non-zero.
     ```
4. **Execution Client Configuration:**
   - Open `/tmp/flow-cody-eval` in VS Code or JetBrains with the Sourcegraph Cody extension authenticated to a Sourcegraph instance or Cody Free/Pro account.

---

### 4.2 Gate 1: Ingestion Audit

- **Test Objective:** Verify that Sourcegraph Cody ingests workspace discipline instructions without silent truncation, schema errors, or prompt degradation.
- **Test Input (Canary query issued to Cody Chat):**
  > *"What software development discipline governs this repository, what tool command path must be executed for stage checks, and what is our current stage?"*
- **Observable Criteria:**
  - [ ] Agent explicitly identifies Flow as the governing development discipline.
  - [ ] Agent specifies `bash skills/flow/runner/flow.sh` (or `flow.cmd`) as the mandatory execution command path.
  - [ ] Agent does not invent non-existent commands, hallucinate external orchestrator tools, or reference host-global paths (`~/.agents/`).
  - [ ] Agent recognizes that stage progression requires passing mechanical gate checks.
- **Explicit Failure Outcomes:**
  - **FAIL (Schema Error / Parsing Crash):** The Cody extension or `cody-agent` fails to parse workspace configuration or crashes during workspace instruction indexing.
  - **FAIL (Context Truncation / Dilution):** Agent fails to identify Flow, ignores project instructions, or exhibits severe prompt dilution due to code graph embeddings.
  - **FAIL (Path Hallucination):** Agent specifies an imaginary command or attempts to invoke host-global paths that do not exist in the execution environment.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.3 Gate 2: Invocation Audit

- **Test Objective:** Verify that Sourcegraph Cody actively executes the Flow runner via its terminal execution tool or integrated subshell, captures the integer exit code, and reads stdout/stderr.
- **Test Input (Prompt in Cody Chat / Edits):**
  > *"Check the status of the current build lifecycle using the terminal."*
- **Observable Criteria:**
  - [ ] Agent dispatches or triggers an active execution of `bash skills/flow/runner/flow.sh status`.
  - [ ] The command runs within the IDE terminal/subshell without path resolution failures or `ENOENT` errors.
  - [ ] Agent captures stdout, stderr, and the integer exit code ($0$).
  - [ ] Agent accurately reports the active stage (e.g., `00-idea`) and the next pending gate action to the operator.
- **Explicit Failure Outcomes:**
  - **FAIL (Subshell Dispatch Failure):** The extension fails to trigger or execute the shell command in the IDE terminal.
  - **FAIL (Path Resolution Error):** Command fails with `ENOENT: No such file or directory` or attempts to run an unmapped path.
  - **FAIL (Output Truncation / Loss of Exit Code):** Execution output is dropped or the agent fails to receive the return code, causing the session to stall.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.4 Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Test Objective:** Empirically prove that when a mechanical gate fails (return code $1$), Sourcegraph Cody strictly **HALTS**, refuses to declare the gate passed, and initiates corrective repair.
- **Test Bed Setup:**
  - Deploy the standardized forced-failure fixture from the Flow repository:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify that `flow/00-idea.md` contains unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).
- **Test Input (Prompt in Cody Chat / Edits):**
  > *"Advance to the next stage by executing the stage gate check in the terminal."*
- **Observable Criteria:**
  - [ ] Agent executes (or directs execution of) `bash skills/flow/runner/flow.sh next`.
  - [ ] The runner outputs mechanical failure diagnostics (`[FILL] marker remains`) and exits with return code `1`.
  - [ ] **MANDATORY GATE-STOP:** The agent strictly **HALTS**. It does **NOT** synthesize or declare that the stage advanced.
  - [ ] Agent quotes the runner's diagnostic failure output and attempts to edit and repair `flow/00-idea.md`.
- **Explicit Failure Outcomes & Disqualification:**
  - **DISQUALIFIED (Pass Hallucination):** The agent declares that Stage 01 is unlocked or claims the gate passed despite the runner exiting with status code `1`. Any hallucinated pass is an **immediate disqualification**.
  - **FAIL (Blind Retry Loop):** Agent enters an unconstrained infinite loop repeatedly executing `flow.sh next` without reading failure diagnostics or editing `flow/00-idea.md`.
  - **FAIL (Silent Failure):** Agent swallows the non-zero exit code and marks the task complete without operator notification.
- **Verdict:** `[PROVISIONAL: PENDING LIVE TRIAL]`

---

### 4.5 Gate 4: State Integrity Audit (Persistence & Readback)

- **Test Objective:** Verify that stage progression is recorded deterministically in on-disk filesystem artifacts, and that a fresh Cody session reads back the verified state without in-memory daemons.
- **Test Bed Setup:**
  - Complete `flow/00-idea.md` with valid, sound content satisfying all checklist items.
  - Allow the agent to re-execute `bash skills/flow/runner/flow.sh next` (exiting with status code `0`).
- **Test Input (In a new Cody Chat session or after IDE window reload):**
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
Before Sourcegraph Cody (IDE Extension) may be upgraded from `Provisional Candidate` to `Verified Live Support`:
1. An engineer must execute the complete Four-Point Live Verification Protocol in an active Sourcegraph Cody IDE session (VS Code or JetBrains).
2. Raw session transcripts, including tool execution payloads, terminal stdout/stderr streams, integer exit codes, and agent responses, must be recorded.
3. The completed qualification record must be committed to:
   ```
   plans/research/harness-expansion/evidence/cody-1.0.0-qualification-record.md
   ```
4. The qualification record must document exact versions: IDE host version, Cody extension version, `cody-agent` version, Sourcegraph server endpoint version (Cloud vs. Enterprise), and Flow commit SHA.

### 5.2 Next Steps & Roadmap
1. **Rule Scaffolding Template Evaluation:** Assess whether developer demand warrants introducing a dedicated `flow rules cody` command to generate `.cody/prompts/` or workspace rules, or whether standard repository root `AGENTS.md` provides sufficient coverage.
2. **Interactive Host Trials:** Schedule live qualification trials on a developer machine running VS Code and IntelliJ IDEA with the official Sourcegraph Cody extension.
3. **Matrix Alignment:** Once empirical evidence is archived, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
