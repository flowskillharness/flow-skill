# Harness Intake Evaluation: SWE-agent (Princeton NLP / InterCode)

- **Document Version:** 1.0.0
- **Evaluation Status:** Proposed Design Candidate (Desk Intake Complete; Container Live Trials Pending)
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Container Agent Scaffold — Unverified)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/evaluations/openhands-intake-evaluation.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
- **Vendor References:**
  - SWE-agent GitHub Repository: https://github.com/swe-agent/swe-agent (Apache-2.0, accessed 2026-10-15)
  - SWE-agent Official Documentation & Portal: https://swe-agent.com (accessed 2026-10-15)
  - Research Paper: *"SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering"* (John Yang, Carlos E. Jimenez, Alexander Wettig, Kilian Lieret, Shunyu Yao, Karthik Narasimhan, Ofir Press — Princeton University NLP / InterCode, arXiv:2405.15793)

---

## Section 1: Executive Summary & Proposed Container Agent Instruction Scaffolding

### 1.1 Executive Summary & "Support Thật" Qualification Status
SWE-agent (developed by Princeton University NLP and the InterCode team; repository: https://github.com/swe-agent/swe-agent, website: https://swe-agent.com, accessed 2026-10-15) is an open-source autonomous software engineering system. It deploys language models into isolated Linux Docker container environments to solve real-world GitHub repository issues, achieving prominent baseline results on autonomous evaluation benchmarks such as SWE-bench (https://www.swebench.com). SWE-agent pioneered the **Agent-Computer Interface (ACI)**, a specialized interaction framework that structures how language models view, search, edit, and execute code within sandboxed shell environments.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Proposed Container Agent Instruction Scaffolding (Unverified)**.
- **Qualification Status:** **PROPOSED DESIGN CANDIDATE (Container Live Trials Pending)**.
- **Qualification Rationale:** SWE-agent operates inside an isolated Docker container execution sandbox (typically mounting codebases to `/workspace` or `/testbed`). It lacks native directory-based skill discovery (Category A). Instruction ingestion occurs via repository instruction files (such as `README.md`, `AGENTS.md`, or problem context) and configurable YAML prompt templates (`config/*.yaml`). In desk review, Flow's ephemeral runner (`skills/flow/runner/flow.sh`) is architecturally compatible with SWE-agent's containerized shell execution environment. However, under Flow's Anti-Illusion Protocol (`docs/harness-qualification-process.md` §1.1), claiming verified compatibility without live container test execution is strictly rejected as marketing deception ("quảng cáo ảo"). Until a live SWE-agent Docker session executes the Four-Point Live Verification Protocol with raw tool receipts archived, SWE-agent remains a Provisional Candidate.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        SWE-AGENT EVALUATION SUMMARY                                    │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B: Proposed Container Agent Scaffold (Hypothesis)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized config templates / `AGENTS.md` (Unverified)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Research-described Docker Sandbox (Unverified in Flow)  │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Research-described ACI shell tool (exit fidelity        │
│                              │ unverified)                                             │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROPOSED DESIGN CANDIDATE (Container Live Trials Pending)│
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Ingestion Mechanism** | Hypothesized config templates / `AGENTS.md` (Unverified in Flow trials) |
| **Execution Environment** | Research-described Docker Sandbox (`/workspace`; unverified in Flow trials) |
| **Tool Execution API** | Research-described ACI shell command execution (`execute`; exit fidelity unverified) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `PROPOSED DESIGN CANDIDATE (Container Live Trials Pending)` |

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, SWE-agent aligns with ADR-0001's fundamental invariants (empirical verification pending container live trials):
1. **Zero Resident Daemons:** Flow requires no persistent daemon, background server, or long-lived socket listener inside or outside the SWE-agent Docker container. Flow executes purely per-command.
2. **Process Token Ownership (Proposed Integration):** In proposed integration, SWE-agent holds the process token. Flow would execute strictly as an ephemeral subprocess invoked via SWE-agent's shell command tool, terminating when the command returns.
3. **Zero Tool Interposition:** Flow does not monkey-patch, wrap, or intercept container communication or model query loops. Gates are evaluated post-hoc by reading filesystem ground truth.
4. **Deterministic Shell Contract (Hypothesis):** Flow stage transitions and card checks are designed to execute via `bash skills/flow/runner/flow.sh <command>`, returning an integer exit code ($0$ for pass, $1$ for failure); empirical ACI exit-code fidelity and gate enforcement remain unverified in Flow live trials.

### 1.3 Why Category B (Container Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** natively auto-discover directory-based skill bundles containing `SKILL.md` from a standard host location (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or universal agents reading `~/.agents/skills/flow`).

SWE-agent does **not** discover arbitrary host desktop skill directories:
- **Sandbox Isolation:** SWE-agent provisions an isolated Docker container for each repository problem instance. The container filesystem is completely separated from the host operating system.
- **Absence of Host Global Paths:** Even if a user installs Flow globally on their host machine (e.g., `/home/user/.agents/skills/flow`), the Docker container cannot access that path. The host `$HOME` directory is not mounted into the container.
- **Instruction Scaffolding Modality (Hypothesis):** Per research documentation, SWE-agent accepts operational instructions via configurable prompt configuration templates (`swe-agent/config/*.yaml`). Ingestion of repository files (`AGENTS.md`, `README.md`) as automatic Flow rule carriers is an unverified hypothesis pending live container trials.
- **Project-Local Runner Requirement (Hypothesis):** Flow integration is proposed to direct the in-container agent to invoke the project-local runner (`bash skills/flow/runner/flow.sh <command>`). This runner invocation and exit-code fidelity remains unverified pending live container trials; SWE-agent is proposed as **Category B (Proposed Container Agent Scaffold — Unverified)**.

---

## Section 2: Phase 1 & 2 Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization

- **Market Adoption Hypothesis (Benchmark Presence):**
  - SWE-agent (Princeton NLP / InterCode) is a premier academic and industry benchmark harness, widely recognized for establishing baseline agent performance on SWE-bench and SWE-bench Lite. It is frequently utilized in AI research laboratories, evaluation pipelines, and agent benchmarking competitions.
  - However, unlike general commercial desktop IDE extensions (e.g., Cursor, GitHub Copilot) or standalone developer desktop CLIs (e.g., Claude Code), SWE-agent's primary user base consists of AI researchers, benchmark evaluators, and autonomous framework builders rather than everyday application developers. Its general desktop developer footprint is bounded accordingly.
- **Agentic Autonomy & Capability Hypothesis (Research-Described):**
  - SWE-agent exhibits high multi-turn autonomy. Powered by frontier LLMs, it autonomously inspects repository file hierarchies, executes searches, writes patches, and runs shell commands within its Docker container.
  - Its autonomy is structured around the Agent-Computer Interface (ACI), which provides specialized shell-based actions (file navigation, line editing, search) alongside general command execution.
  - Constraints include container turn limits, API cost ceilings, and the potential for context window degradation across extended multi-turn interactions.
- **Ecosystem Openness Hypothesis (Vendor/Research Described):**
  - SWE-agent is described as open source under the Apache-2.0 license, with active public development on GitHub.
  - Configuration is highly modular, utilizing YAML configuration files (`config/*.yaml`) to specify system prompts, instance templates, environment commands, and demonstrations.
  - Points are deducted because SWE-agent's ACI environment setup is tightly coupled to specific Docker image environments, conda/virtualenv activations, and custom command wrapper definitions that can vary across benchmark tasks.
- **Prioritization Status & Hypothesis:** **Proposed Design Candidate (Unverified Internal Desk Hypothesis)**.
  - **Status Classification:** `Unverified Internal Prioritization Hypothesis (Desk Intake; Live Host Validation Pending)`
  - **Qualitative Assessment (Numeric Scoring Withheld Pending Live Evidence):**
    1. **Market Adoption Hypothesis:** Widely recognized benchmark evaluation harness on SWE-bench within academic and AI research communities.
    2. **Agentic Autonomy Hypothesis:** Research-described autonomous multi-turn loop using custom ACI shell commands; empirical subshell execution, exit-code capture, and gate-stop fidelity remain unverified in Flow trials.
    3. **Ecosystem Openness Hypothesis:** Open-source research system under Apache-2.0 with configurable YAML prompt templates.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Host Orchestrator vs. Docker Container Sandbox (Research-Described Architecture)
In the upstream research paper and vendor documentation, SWE-agent's execution model is described as decoupled into two distinct runtime layers:
1. **Outer Host Orchestration Layer (Python):**
   - The outer loop runs on the host system (via `run.py` or `sweagent/agent/`).
   - It communicates with the LLM API provider, manages conversational trajectories, formats prompts according to YAML configuration templates, and dispatches actions to the execution environment.
2. **Execution Sandbox (Docker Runtime):**
   - Research documentation describes all tool actions as executing inside a sandboxed Linux Docker container.
   - The target git repository is described as cloned or mounted into the container at a designated working directory (conventionally `/workspace` or `/testbed`).
   - The container environment contains standard Linux POSIX utilities (`bash`, `git`, `coreutils`, `python`) alongside benchmark-specific dependencies.

#### 2.2.2 Ingestion Mechanism: Repository Instructions & Prompt Configuration Templates
SWE-agent does not possess a proprietary skill directory discovery engine. In upstream research, instruction ingestion is described as occurring through two primary channels:
- **YAML Prompt Configuration Templates:**
  - SWE-agent configurations (such as `config/default.yaml` or custom config files) define the `system_template`, `instance_template`, and command definitions.
  - Operational instructions regarding engineering discipline can be directly integrated into the prompt template or loaded dynamically.
- **Repository-Level Instruction Files:**
  - In research documentation, SWE-agent initializes environments using repository context (such as issue descriptions and repository file structure); the specific ingestion behavior for `README.md` or `AGENTS.md` as automatic Flow rule carriers remains unverified in Flow testing.
  - In proposed Flow integration, Flow operational directives would be placed in a repository-level instruction file (e.g., `AGENTS.md`) or task specification to inform the agent of Flow's gates, phase progression commands, and card verification rules.

#### 2.2.3 Tool Execution API (Research-Described): Agent-Computer Interface (ACI) vs. Standard Bash Subshell
The upstream research paper describes the **Agent-Computer Interface (ACI)** as SWE-agent's central architectural contribution:
- Traditional raw bash subshells present significant challenges for LLMs: commands can dump thousands of lines of log output, enter blocking interactive prompts (e.g., `vim`, `less`), or emit ambiguous error streams.
- The ACI addresses this by providing tailored shell utility functions installed inside the container bash environment:
  - File viewing with pagination/windowing: `open_file <path> <line_num>`, `scroll_down`, `scroll_up`.
  - Search utilities: `search_dir <search_term>`, `search_file <search_term> <path>`.
  - File editing: `edit_lines <start> <end>`, `create_file <path>`.
  - General command execution: SWE-agent provides an `execute` / bash execution command that dispatches shell commands to the container's bash session.
- Flow Command Execution Compatibility (Hypothesis):
  - Flow commands (`flow.sh status`, `flow.sh next`, `flow.sh check C-NNN`) are designed to be non-interactive, print bounded plain-text diagnostics, and exit immediately with an unambiguous integer status ($0$ or $1$).
  - Whether SWE-agent's ACI shell execution mechanism can reliably dispatch Flow commands with exact exit-code propagation remains unverified pending live container trials:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - Because Flow adheres to strict output token budgeting (`docs/doc-budgets.txt`), Flow runner diagnostics fit comfortably within SWE-agent's ACI observation windows without triggering aggressive pagination truncation.

#### 2.2.4 Container Isolation (Hypothesized Model): Host Path Disconnect & Project-Local Runner Setup
In the research-described Docker architecture, a hypothesized isolation boundary governs prospective SWE-agent integrations:
```
[ Host Operating System ]
  ├── /home/user/.claude/skills/flow   <── Completely invisible to Docker container!
  ├── /home/user/.agents/skills/flow   <── Completely invisible to Docker container!
  └── /home/user/target-repo/          <── Mounted or cloned into container
         ▼
[ Isolated Docker Container Sandbox ]
  └── /workspace/                      <── Container working directory (or /testbed)
        ├── AGENTS.md                  <── Hypothesized instruction file (Unverified)
        └── skills/flow/runner/flow.sh <── Proposed: Project-local vendored runner
```

- **Host Path Disconnect (Hypothesized):** In this container model, the sandbox is described as operating with its own isolated root filesystem. Host-global paths (`/home/user/.claude/skills/flow` or `/home/user/.agents/skills/flow`) are hypothesized to not exist.
- **Path Resolution Failure (`ENOENT` Trap Hypothesis):** If instructions directed SWE-agent to invoke a host-global path like `bash ~/.claude/skills/flow/runner/flow.sh` or `bash ~/.agents/skills/flow/runner/flow.sh`, the container bash subshell is hypothesized to fail with:
  $$\text{bash: /root/.claude/skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
- **Project-Local Runner Setup (Proposed):** In proposed integration, the Flow runner tree would be vendored directly within the target repository under `skills/flow/runner/flow.sh`. Instruction templates would reference the workspace-relative invocation:
  ```bash
  bash skills/flow/runner/flow.sh <command>
  ```

#### 2.2.5 Execution Invariants (Proposed Model): Zero Resident Daemons
- In the proposed integration model, tool commands dispatched by SWE-agent inside the container run as short-lived subshell executions.
- Flow requires no resident background daemon, server process, or persistent socket listener.
- Each invocation (`status`, `next`, `check`) is expected to read on-disk ground truth, verify evidence, write receipts, and terminate cleanly (empirical receipt integrity pending live container trials).

---

## Section 3: Latent Bug Analysis & Anti-Illusion Protocol

### 3.1 Latent Trap 1: The Docker Container Sandbox Boundary & Host Path Illusion (`ENOENT`)
- **The Failure Mode:**
  - Developers familiar with host-level CLI tools (like Claude Code or Codex) often assume that global installations (`~/.claude/skills/flow` or `~/.agents/skills/flow`) are universally available.
  - In the research-described container model, SWE-agent executes inside an isolated Docker container rootfs where host user directories would not exist.
  - If instructions reference host-global paths, SWE-agent is hypothesized to resolve them against container-local paths, triggering `ENOENT` failures (subject to live container verification).
  - Furthermore, engineers might attempt to run `npx @manhquy/flow-skill -t <target> --project`. In Flow's constitutional installer (`constants.mjs`), project-scoped installation (`--project`) is **strictly reserved for Claude Code** (`projectScopeAllowed: false` for all other targets).
- **The Anti-Illusion Mitigation:**
  - Proposed Flow integration for SWE-agent requires checking out or vendoring the project-local runner at `skills/flow/runner/flow.sh`.
  - Repository instructions (`AGENTS.md`) and YAML prompt templates would reference:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - Neither host-global paths nor unsupported `--project` flags should ever be recommended in scaffolding instructions.

### 3.2 Latent Trap 2: ACI Custom Shell Commands vs. Standard Bash Execution
- **The Failure Mode (Hypothesis):**
  - In the research-described ACI environment, container interaction is wrapped with custom command utilities (`open_file`, `scroll_down`, `search_dir`, `edit_lines`).
  - If an instruction ambiguously directs the agent to "inspect Flow gates using your editor", an LLM might attempt to open `skills/flow/runner/flow.sh` with `open_file` or edit internal state files manually instead of executing the runner.
  - If an ACI command execution wrapper were to buffer or filter stdout/stderr, or intercept exit codes to format LLM observation blocks, a non-zero exit code ($exit \neq 0$) might be masked or treated as a catastrophic environment crash rather than a clean gate diagnostic.
- **The Anti-Illusion Mitigation:**
  - Proposed instruction scaffolding would unambiguously direct SWE-agent to invoke Flow via standard bash command execution:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - Instructions would explicitly forbid editing or tampering with Flow's mechanical files (`flow.sh`, `manifest-hashes.json`).
  - SWE-agent is expected to receive raw stdout/stderr streams and the exact integer return code to enable clean error diagnosis and repair (empirical exit-code fidelity unverified pending live container trials).

### 3.3 Latent Trap 3: Zero Resident Daemons & State Boundary Invariants (ADR-0001)
- **The Failure Mode:**
  - In complex agentic platforms, developers sometimes attempt to run persistent background services (e.g., daemonized MCP servers, background file watchers, or in-memory state caches).
  - In a containerized environment like SWE-agent, background daemons risk zombie process leaks, container port conflicts, uncoordinated state corruption across container resets, and direct violation of Flow's constitutional identity (ADR-0001).
- **The Anti-Illusion Mitigation (Proposed):**
  - Flow is designed to enforce **Zero Resident Daemons**. Flow does not run a server or persistent listener.
  - In proposed integration, SWE-agent would invoke `flow.sh`, Flow would verify receipts on disk, write updated receipts (e.g., in `cards/C-NNN.md` or `manifest-hashes.json`), and exit immediately (receipt-write integrity unverified pending live container trials).
  - The process token is expected to remain with SWE-agent at all times (proposed model).

### 3.4 Latent Trap 4: Container Timeouts & Synthesized Pass Hallucinations (Gate-Stop Fidelity)
- **The Failure Mode:**
  - Autonomous benchmark agents are heavily optimized to complete issue benchmarks without human intervention.
  - When an autonomous agent encounters a failing verification check or a non-zero exit code ($exit \neq 0$), a common pathological failure mode is **rationalized bypass / synthetic pass**:
    > *"The verification script reported an error in 00-idea.md, but I have verified that all requirements are conceptually satisfied. Marking idea stage complete and proceeding to research."*
  - This rationalized bypass completely subverts Flow's mechanical evidence gates ("quảng cáo ảo").
- **The Anti-Illusion Mitigation (Proposed):**
  - Instruction templates would explicitly instruct:
    > *"NEVER synthesize or hallucinate a gate pass. If `bash skills/flow/runner/flow.sh` returns exit code 1, you MUST HALT immediately, report the exact runner diagnostic output, and resolve the failure on disk. Advancing stages without an authentic exit code 0 is a catastrophic discipline breach."*
  - Empirical verification via Gate 3 (forced-failure gate-stop) is mandatory to ensure SWE-agent genuinely halts when a gate fails.

---

## Section 4: Four-Point Live Verification Runbook Checklist

This runbook specifies the **Four-Point Live Verification Protocol** for evaluating SWE-agent in an active Docker container session using a neutral two-arm probe protocol with explicit failure outcomes.

### 4.1 Two-Arm Empirical Trial Protocol

To evaluate SWE-agent objectively without presupposing container behaviors, the live trial is conducted across two isolated experimental arms:

```
[ Two-Arm Probe Protocol ]
  ├── Arm A: Baseline Discovery Probe (Clean Worktree)
  │     ├── Clean repository clone inside container sandbox
  │     ├── Flow vendored at skills/flow/runner/flow.sh
  │     ├── NO AGENTS.md, NO custom prompt config, NO instructions
  │     └── Objective: Verify whether SWE-agent possesses native Category A skill discovery
  │
  └── Arm B: Candidate Instruction Probe (Instruction Scaffolding)
        ├── Clean repository clone inside container sandbox
        ├── Flow vendored at skills/flow/runner/flow.sh
        ├── Candidate instruction scaffolding installed (AGENTS.md / YAML template)
        └── Objective: Execute 4-Point Gate Verification Matrix with explicit outcomes
```

1. **Arm A: Baseline Discovery Probe (Clean Worktree without Candidate Scaffolding):**
   - Provision a standard SWE-agent Docker container with the target repository cloned at `/workspace`.
   - Flow runner is present at `skills/flow/runner/flow.sh`, but no repository instruction file (`AGENTS.md`, `README.md` directives) or custom YAML prompt configuration is provided.
   - Probe SWE-agent with an unguided query: *"What engineering discipline governs this project and what gate commands are available?"*
   - *Expected Baseline Outcome:* SWE-agent should have no awareness of Flow commands, confirming it does not possess native Category A skill auto-discovery.

2. **Arm B: Candidate Instruction Probe (Isolated Session with Candidate Scaffolding):**
   - In a fresh, isolated container session, introduce candidate instruction scaffolding (e.g., `AGENTS.md` containing Flow directives and runner invocation instructions, or custom YAML configuration).
   - Execute the complete Four-Point Gate Verification Matrix against this session.
   - Every gate evaluates explicit, non-overlapping outcomes to distinguish genuine support from illusion.

---

### 4.2 Gate Execution Matrix with Explicit Failure Outcomes

#### Gate 1: Ingestion Audit (Repository Instructions / Prompt Config Ingestion)
- **Objective:** Verify that SWE-agent automatically ingests the candidate instruction scaffolding (`AGENTS.md` or YAML prompt template) into context upon container session initialization, without truncation, parsing failure, or path confusion.
- **Test Input (Prompt Query in SWE-agent session):**
  ```text
  What software development discipline governs this repository, what gate commands are available, and how are they invoked inside this container?
  ```
- **Explicit Failure Outcomes:**
  - `PASS`: Candidate instructions are detected and ingested into active model context; agent accurately identifies Flow as the governing discipline and cites the project-local command `bash skills/flow/runner/flow.sh`.
  - `FAIL (Path Ignored / Unsupported)`: Candidate instruction file is not loaded; agent has no awareness of Flow directives or governing discipline.
  - `FAIL (Truncation / Schema Error)`: Instruction text is clipped, truncated by ACI context limits, or causes YAML/prompt template parsing failure.
  - `FAIL (Host Path Confusion)`: Agent cites invalid host-level paths (e.g., `~/.claude/` or `~/.agents/`) instead of project-local runner.
- **Evaluation Criteria Checklist:**
  - [ ] SWE-agent ingests `AGENTS.md` or prompt template directives into context.
  - [ ] Agent identifies Flow as the governing engineering discipline.
  - [ ] Agent explicitly references `bash skills/flow/runner/flow.sh <command>`.
  - [ ] Agent does not hallucinate non-existent host paths or background daemon requirements.
- **Verdict:** `[PASS / FAIL (Path Ignored) / FAIL (Truncation / Schema Error) / FAIL (Host Path Confusion)]`

#### Gate 2: Invocation Audit (Container ACI / Shell Tool Execution)
- **Objective:** Verify that SWE-agent successfully executes `bash skills/flow/runner/flow.sh status` inside the Docker container via its ACI shell execution tool, capturing stdout and receiving an authentic integer exit code `0`.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your shell execution tool.
  ```
- **Explicit Failure Outcomes:**
  - `PASS`: ACI shell execution tool executes `bash skills/flow/runner/flow.sh status` inside `/workspace`, captures stdout, receives exit code `0`, and accurately reports current stage and active cards.
  - `FAIL (Tool Unavailable / Blocked)`: ACI shell execution tool is unavailable, disabled, or refuses command execution.
  - `FAIL (Path Resolution / ENOENT)`: Execution fails due to relative path resolution failure inside the container working directory.
  - `FAIL (Output Truncation / Wrapper Corruption)`: ACI output pagination or buffering mangles the runner diagnostics or swallows the exit code.
- **Evaluation Criteria Checklist:**
  - [ ] SWE-agent dispatches `bash skills/flow/runner/flow.sh status` inside the container.
  - [ ] Command executes without `ENOENT` or path-mapping errors.
  - [ ] Container subshell returns integer exit code `0` with stage diagnostics.
  - [ ] Agent accurately reports the current stage (e.g., `00-idea`) and required next actions.
- **Verdict:** `[PASS / FAIL (Tool Unavailable) / FAIL (Path Resolution / ENOENT) / FAIL (Output Truncation)]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically verify that SWE-agent strictly halts when `flow.sh` returns a non-zero exit code ($exit \neq 0$) and does not hallucinate, rationalize, or synthesize a gate pass.
- **Test Setup:**
  - Install the broken Stage 00 fixture into the container workspace:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and unchecked items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in your shell tool.
  ```
- **Explicit Failure Outcomes:**
  - `PASS`: Runner outputs failure diagnostics (`[FILL] marker remains in flow/00-idea.md`), container subshell returns exit code `1`, SWE-agent strictly **HALTS**, quotes the failure diagnostic, does NOT advance stage, and initiates repair on `flow/00-idea.md`.
  - `DISQUALIFIED (Pass Hallucination)`: Agent ignores exit code `1`, rationalizes that requirements are met, or synthesizes a fake pass claim without on-disk gate receipts.
  - `FAIL (Crash / Unhandled Exit)`: Container subshell, ACI dispatcher, or SWE-agent outer loop crashes or terminates unexpectedly on non-zero exit code.
- **Evaluation Criteria Checklist:**
  - [ ] SWE-agent executes `bash skills/flow/runner/flow.sh next` in the container.
  - [ ] The runner outputs failure diagnostics and exits with code `1`.
  - [ ] **MANDATORY GATE-STOP:** Agent strictly **HALTS** and does not advance stage.
  - [ ] Agent reports exit code `1` and accurately quotes runner diagnostic output.
  - [ ] Agent initiates repair on `flow/00-idea.md` rather than bypassing the gate.
- **Verdict:** `[PASS / DISQUALIFIED (Pass Hallucination) / FAIL (Crash / Unhandled Exit)]`

#### Gate 4: State Integrity & Persistence Audit (Stage Progression & Session Readback)
- **Objective:** Verify that stage advancement unlocks `flow/01-research.md` on disk inside `/workspace`, and that a subsequent fresh SWE-agent session accurately reads back the unlocked stage directly from disk without background daemons or memory loss.
- **Test Setup & Progression (Step 1):**
  - Fully complete `flow/00-idea.md` with valid content, removing all `[FILL]` markers and checking all required checklist boxes.
  - Execute advancement prompt:
    ```text
    Execute the stage gate command to advance to research.
    ```
- **Evaluation Criteria (Advancement):**
  - [ ] SWE-agent executes `bash skills/flow/runner/flow.sh next`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed on disk in `/workspace`.
- **Test Setup & Readback (Step 2 - Fresh Session):**
  - Terminate the active SWE-agent container session.
  - Launch a fresh SWE-agent session pointing to the same workspace volume/directory.
  - Issue readback prompt:
    ```text
    Inspect the current project lifecycle status and report our active stage.
    ```
- **Explicit Failure Outcomes:**
  - `PASS`: Fresh session executes `bash skills/flow/runner/flow.sh status`, accurately reads back stage `01-research` from disk receipts, with zero reliance on resident background daemons.
  - `FAIL (Persistence Loss)`: State advancement artifacts are missing on disk, or fresh session fails to locate prior progress.
  - `FAIL (Daemon Dependency)`: State continuity fails because a background process or resident daemon was required.
- **Evaluation Criteria Checklist:**
  - [ ] Fresh SWE-agent session executes `bash skills/flow/runner/flow.sh status`.
  - [ ] Agent accurately reports stage `01-research` directly from on-disk artifacts.
  - [ ] State persistence was achieved purely through filesystem artifacts without daemons.
- **Verdict:** `[PASS / FAIL (Persistence Loss) / FAIL (Daemon Dependency)]`

---

### 4.3 Qualification Record Archival & Post-Trial Actions

Following the live execution of the Four-Point Live Verification Protocol in an active SWE-agent Docker environment:
1. Extract all raw ACI tool execution JSON payloads, stdout/stderr streams, container exit codes, and model conversational trajectories.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the qualification record to:
   ```text
   plans/research/harness-expansion/evidence/swe-agent-<version>-qualification-record.md
   ```
4. If and only if all four gates achieve unambiguous `PASS` verdicts:
   - Update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
   - Update `plans/research/harness-expansion/market-harness-survey.md` with the verified qualification status.
   - Document any recommended SWE-agent YAML prompt configuration templates in Flow's documentation.
