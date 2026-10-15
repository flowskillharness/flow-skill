# Harness Intake Evaluation: AutoCodeRover (Automated Program Repair Agent)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Architectural Category:** Category B (Proposed Container / Benchmark Scaffolding)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/evaluations/swe-agent-intake-evaluation.md`
  - `plans/research/harness-expansion/evaluations/openhands-intake-evaluation.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - `AGENTS.md`
- **Vendor References:**
  - AutoCodeRover Repository: https://github.com/nus-apr/auto-code-rover (National University of Singapore, Apache-2.0, accessed 2026-10-15)
  - AutoCodeRover Research Paper: https://arxiv.org/abs/2404.05427 (ISSTA 2024 / arXiv, accessed 2026-10-15)

---

## Executive Summary & Overview Table

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        AUTOCODEROVER EVALUATION SUMMARY                                │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B (Proposed Container / Benchmark Scaffolding) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Hypothesized problem statement context / prompt framing │
│                              │ / repository root `AGENTS.md` (no verified schema; no   │
│                              │ Flow template)                                          │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Python execution loop running in local host environment │
│                              │ or Docker container                                     │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ Hypothesized test command execution and shell invocation│
│                              │ in repair loop (Flow gate-stop fidelity unverified in   │
│                              │ live trials)                                            │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)    │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

| Dimension | Specification & Desk Assessment |
| :--- | :--- |
| **Architectural Classification** | Category B (Proposed Container / Benchmark Scaffolding) |
| **Ingestion Mechanism** | Hypothesized problem statement context / prompt framing / repository root `AGENTS.md` (no verified schema; no Flow template) |
| **Execution Environment** | Python execution loop running in local host environment or Docker container |
| **Tool Execution API** | Hypothesized test command execution and shell invocation in repair loop (Flow gate-stop fidelity unverified in live trials) |
| **ADR-0001 Compliance** | `PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token` |
| **Live Qualification Status** | `PROPOSED DESIGN CANDIDATE (Live Host Trials Pending)` |

---

## Section 1: Executive Summary & Modality Separation

### 1.1 Executive Summary & "Support Thật" Qualification Status

AutoCodeRover (developed by the School of Computing at the National University of Singapore [NUS], Automated Program Repair [APR] research group: Yuntong Zhang, Haifeng Ruan, Zhiyu Fan, and Abhik Roychoudhury; ISSTA 2024, arXiv:2404.05427; repository: https://github.com/nus-apr/auto-code-rover, Apache-2.0, accessed 2026-10-15) is an open-source autonomous program improvement and repair system. AutoCodeRover combines Large Language Models (LLMs) with Abstract Syntax Tree (AST) level code navigation, spectrum-based fault localization (SBFL), and iterative test execution to solve GitHub issues and SWE-bench benchmark tasks.

Instead of relying on raw text browsing or naive whole-file context loading, AutoCodeRover operates through structured AST queries (such as searching for specific classes, methods, or code snippets across the codebase syntax tree) to reduce token consumption and focus context on relevant code regions. When paired with reproducer scripts or test suites, it engages in an iterative fault localization, patch synthesis, and validation loop.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Proposed Container / Benchmark Scaffolding)**.
- **Qualification Status:** **`PROPOSED DESIGN CANDIDATE (Desk Intake Complete; Live Host Trials Pending)`**.
- **Qualification Rationale:**
  - AutoCodeRover operates as an automated program repair (APR) agent running in local Python environments or Docker container sandboxes (e.g., standard SWE-bench evaluation containers).
  - **Modality Separation (Autonomous Benchmark Repair Loop vs. Interactive Developer Workflow):** AutoCodeRover is engineered for automated, batch-mode program repair against structured issue specifications and reproduction tests. It is not an interactive conversational IDE assistant or a continuous chat-driven co-pilot for human developers. Flow's discipline framework (`00-idea` to `05-ship`) governs full lifecycle development. In an APR benchmark context, Flow integration must be structured around mechanical verification gates and test execution commands within AutoCodeRover's repair loop, rather than conversational steering.
  - **Distinction from Category A (Native Skill Target):** In desk review of AutoCodeRover's codebase and research paper, no documented native skill directory discovery mechanism conforming to `SKILL.md` bundles (`~/.agents/skills/` or `~/.claude/skills/`) was identified. AutoCodeRover does not discover or load global host desktop skills.
  - **Strict Locking of `flow rules`:** Flow's CLI rule generator (`flow rules`) is strictly locked to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`), verified by `tests/test_flow_rules.sh`. **No AutoCodeRover template exists in `flow rules`.** Invoking `flow rules auto-code-rover` exits with code `2` (`unknown harness`).
  - In strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §1.1, §2.1), advertising "AutoCodeRover support" or claiming compatibility without empirical live host verification of subshell invocation, return-code capture ($0$ vs. non-zero), and gate-stop fidelity constitutes marketing deception ("quảng cáo ảo"). AutoCodeRover is designated as a **Proposed Design Candidate** pending live host/container trials.

### 1.2 Constitutional Alignment (ADR-0001 Invariants)

Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, AutoCodeRover aligns with ADR-0001's fundamental invariants (empirical verification pending live trials):
1. **Zero Resident Daemons:** Flow requires no persistent daemon, background server, or long-lived socket listener inside or outside AutoCodeRover's execution environment. Flow executes purely per-command.
2. **Process Token Ownership:** AutoCodeRover and its outer Python orchestration loop hold the process token. Flow never holds the main loop and executes strictly as an ephemeral subprocess invoked via command or test execution tools.
3. **Zero Tool Interposition:** Flow does not monkey-patch, wrap, or intercept AutoCodeRover's AST parser, LLM API calls, or git operations. Gates are evaluated post-hoc by reading on-disk filesystem ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions and gate validations execute via `bash skills/flow/runner/flow.sh <command>`, returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Stateless On-Disk Receipts:** All lifecycle evidence and state transitions are captured in Git commits and verified filesystem files, requiring zero volatile in-memory caching. Attempting to turn Flow into a resident background service or embedding Flow into AutoCodeRover's agent loop as a persistent daemon is constitutionally forbidden under ADR-0001.

### 1.3 Architectural Classification: Why Category B and Not Category A or C?

1. **Why Not Category A (Native Skill Target)?**
   - Category A harnesses natively scan for and discover directory-based skill bundles containing `SKILL.md` from standardized host locations (e.g., Claude Code reading `~/.claude/skills/flow`, Codex reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).
   - AutoCodeRover has no native discovery engine for host-level skill directories. In containerized benchmark setups, host paths are entirely unmounted.
2. **Alignment with Category B (Container / Benchmark Scaffolding):**
   - Category B harnesses rely on workspace instruction scaffolding, prompt framing, problem descriptions, and repository context files to guide the agent toward invoking shell tools and adhering to engineering discipline.
   - For AutoCodeRover, candidate integration relies on prompt framing within the issue/task description, repository root `AGENTS.md`, and invoking the project-local vendored runner (`skills/flow/runner/flow.sh`).
3. **Why Not Category C (Automated Test Gate Scaffolding)?**
   - Category C harnesses (such as Aider with `test-cmd` in `.aider.conf.yml`) provide an automated, non-agentic test execution lifecycle hook that mechanically triggers on every file edit without model persuasion.
   - While AutoCodeRover executes reproduction test commands during its iterative repair loop, this execution is governed by its internal test-driven repair logic rather than an external configuration-driven editor hook.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring

Under Flow's "Support Thật" discipline, arbitrary numeric scores are withheld pending live empirical evidence; dimensions are evaluated as qualitative desk hypotheses:

- **Market Adoption Hypothesis (Academic & Benchmark Mindshare):**
  - AutoCodeRover (NUS APR group) is a recognized academic and benchmark repair agent, established through publication at ISSTA 2024 and notable performance on SWE-bench and SWE-bench Lite.
  - It is primarily adopted by academic researchers, benchmark evaluators, and autonomous software engineering framework developers.
  - It does not have an installed desktop IDE extension user base comparable to Cursor, Windsurf, or GitHub Copilot, bounding its general software developer footprint.
- **Agentic Autonomy Hypothesis (Specialized APR Autonomy):**
  - AutoCodeRover exhibits high autonomy within its domain: it autonomously navigates codebases using AST search primitives (`search_class`, `search_method`, `search_code`), analyzes error outputs or reproduction scripts, writes candidate patches, and iterates based on test execution feedback.
  - Its autonomy is structured around batch program repair rather than conversational exploration. Subshell execution, exit-code capture, and gate-stop fidelity under Flow's runner remain unverified in live trials.
- **Ecosystem Openness Hypothesis (Open-Source Research System):**
  - AutoCodeRover is fully open-source under the Apache-2.0 license, with a public Python codebase on GitHub.
  - It supports configurable LLM backends (OpenAI, Anthropic, local models via LiteLLM/vLLM) and clear entry points (`auto_code_rover`).
- **Prioritization Status & Hypothesis:** **`Proposed Design Candidate (Desk Intake Complete; Live Host Trials Pending)`**.
  - *Status Classification:* Category B (Proposed Container / Benchmark Scaffolding).
  - *Qualitative Assessment:*
    1. *Market Adoption Hypothesis:* Influential academic and benchmark APR system on SWE-bench; bounded everyday developer desktop presence.
    2. *Agentic Autonomy Hypothesis:* High multi-step autonomy in AST navigation, patch generation, and test-driven validation; empirical subshell gate enforcement unverified.
    3. *Ecosystem Openness Hypothesis:* Open-source Apache-2.0 Python repository; transparent codebase and execution flow.

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Execution Model: Host vs. Container Sandbox

In desk review of the upstream repository and publication, AutoCodeRover's execution model consists of:
1. **Outer Orchestration Layer (Python):**
   - The main loop (`auto_code_rover`) runs in Python, coordinating the agent workflow: problem formulation, AST context retrieval, patch synthesis, and test evaluation.
   - It interfaces with LLM APIs to generate search queries, inspect code structures, and propose diffs.
2. **Execution Environment (Host Shell or Docker Container):**
   - AutoCodeRover can run directly in a host virtual environment or inside an isolated Docker container sandbox (matching SWE-bench evaluation environments).
   - In container mode, the target codebase is mounted or cloned into the container filesystem (e.g., `/workspace` or `/testbed`).
   - Shell and test commands are dispatched into this environment to run unit tests, reproduction scripts, or linters.

#### 2.2.2 Ingestion Mechanism: Problem Context & Repository Instructions

AutoCodeRover does not maintain a dedicated IDE configuration or extension schema. Instruction ingestion is hypothesized to occur via:
1. **Problem Statement / Issue Description:**
   - In benchmark tasks, the issue description provides the primary contextual input to the agent.
   - Scaffolding directives can be prepended or appended to the problem statement to define required Flow gates and verification commands.
2. **Repository Root Instruction Files (`AGENTS.md`):**
   - If AutoCodeRover or its environment setup inspects the repository root, `AGENTS.md` can serve as the candidate instruction carrier.
   - In proposed integration, `AGENTS.md` defines Flow phase progression commands and card verification rules.

#### 2.2.3 Tool Execution API & Ephemeral Subshell Invocations

AutoCodeRover integrates two classes of tools:
1. **AST Navigation Tools:**
   - Specialized python-based tools parsing code ASTs (via tree-sitter or Python's `ast` module) to look up definitions, implementations, and call sites without dumping entire source files into context.
2. **Command / Test Execution Tools:**
   - In test-driven repair mode, AutoCodeRover invokes shell commands or test runners (e.g., `pytest`, `python reproducer.py`) to evaluate whether a proposed patch resolves the issue.
   - For Flow integration, Flow runner commands (`flow.sh status`, `flow.sh next`, `flow.sh check C-NNN`) must execute via standard subshell calls:
     ```bash
     bash skills/flow/runner/flow.sh <command>
     ```
   - Flow commands are non-interactive, output bounded diagnostics conforming to `docs/doc-budgets.txt`, and exit with an integer status ($0$ or $1$).
   - Empirical verification of exit-code capture and gate-stop fidelity remains unverified in live trials.

#### 2.2.4 Execution Invariants: Zero Resident Daemons (ADR-0001)

- Every Flow command executed by AutoCodeRover must run as a short-lived subshell subprocess.
- Flow requires no background daemon, long-lived server, or socket listener on the host or inside the container.
- Each invocation (`status`, `next`, `check`) reads on-disk ground truth, verifies evidence, writes receipts, and terminates immediately.
- The process token remains with AutoCodeRover throughout execution.

---

## Section 3: Latent Bug Analysis & Anti-Illusion Traps

### 3.1 Latent Trap 1: Modality Confusion (Issue Patch Generation vs. Lifecycle Gate Governance)

- **The Failure Mode:**
  - AutoCodeRover is an **Automated Program Repair (APR)** system specifically designed to solve bounded bug instances: it takes an issue description, searches AST entities, localizes faults, generates a code patch (git diff), validates against reproduction tests, and terminates.
  - It is **not** an interactive conversational agent that guides a developer through human-in-the-loop product planning, architecture design, and release reviews across `00-idea` to `05-ship`.
  - If an engineer attempts to treat AutoCodeRover as an interactive conversational assistant by injecting broad conversational prompts (e.g., *"Let's brainstorm a new feature in 00-idea.md"*), AutoCodeRover's APR loop may fail to engage or may hallucinate patch generation against non-code markdown files.
- **The Anti-Illusion Mitigation:**
  - Flow integration must respect AutoCodeRover's APR modality: Flow's lifecycle gates and card checks must be framed as mechanical verification checks (analogous to reproduction test scripts or validation commands).
  - Instructions must explicitly guide the agent to run the mechanical gate commands (`bash skills/flow/runner/flow.sh <command>`) and treat a non-zero exit code as a test failure requiring iterative repair.

### 3.2 Latent Trap 2: Absence of Dedicated `flow rules` Template

- **The Failure Mode:**
  - Flow's CLI rule generator (`flow rules`) is strictly locked to **seven verified harness templates**: `cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, and `copilot`. This locking is enforced by `tests/test_flow_rules.sh`.
  - AutoCodeRover has no native rule file schema (unlike `.cursor/rules/flow.mdc` or `.aider.conf.yml`).
  - An uninformed engineer might attempt to run:
    ```bash
    flow rules auto-code-rover
    ```
    This command will immediately fail with exit code `2`:
    ```text
    unknown harness: auto-code-rover
    ```
  - Inventing a fictional rule template (the "Zed Lesson", `docs/harness-qualification-process.md` §2) without official vendor schema support creates the illusion of support ("quảng cáo ảo").
- **The Anti-Illusion Mitigation:**
  - Flow strictly refuses to generate unverified or imaginary configuration templates.
  - AutoCodeRover scaffolding must rely strictly on repository root `AGENTS.md` and problem description context framing.
  - No AutoCodeRover template shall be added to `flow rules` without verified upstream configuration schema documentation.

### 3.3 Latent Trap 3: Strict Prohibition of Flow Background Daemons (ADR-0001)

- **The Failure Mode:**
  - In autonomous benchmark and container environments, developers sometimes attempt to start background services, daemons, or long-lived servers to maintain state or cache AST indices across benchmark tasks.
  - In containerized execution environments, persistent daemons cause:
    1. Zombie process leaks that prevent clean container shutdown.
    2. Socket and port collisions when multiple benchmark runs execute concurrently.
    3. State corruption across container resets or problem instances.
    4. Direct violation of Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`).
- **The Anti-Illusion Mitigation:**
  - Flow strictly enforces **Zero Resident Daemons**. Flow does not run a server or persistent listener.
  - AutoCodeRover invokes `flow.sh` ephemerally. Flow reads disk ground truth, validates receipts, writes updated state, and exits immediately.
  - The process token remains with AutoCodeRover and the host environment at all times.

### 3.4 Latent Trap 4: Container Isolation and Project-Local Runner Requirement (`skills/flow/runner/flow.sh`)

- **The Failure Mode:**
  - When AutoCodeRover executes inside Docker containers (such as SWE-bench evaluation containers), the container environment has an isolated root filesystem.
  - Host global paths (`~/.claude/skills/flow` or `~/.agents/skills/flow`) do not exist inside the container. Directing the agent to invoke host-global paths results in immediate failure:
    $$\text{bash: /root/.agents/skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
  - Furthermore, engineers might attempt to run `npx @manhquy/flow-skill -t <target> --project`. In Flow's constitutional installer (`constants.mjs`), project-scoped installation (`--project`) is **strictly reserved for Claude Code** (`projectScopeAllowed: false` for all other targets).
- **The Anti-Illusion Mitigation:**
  - Proposed Flow integration for AutoCodeRover requires checking out or vendoring the project-local runner at `skills/flow/runner/flow.sh` inside the repository.
  - Instructions in `AGENTS.md` or problem descriptions must reference workspace-relative paths:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - Neither host-global paths nor unsupported `--project` flags should ever be documented for AutoCodeRover scaffolding.

---

## Section 4: Complete 4-Point Live Verification Runbook ("Support Thật" Protocol)

This runbook specifies the **Four-Point Live Verification Protocol** for evaluating AutoCodeRover in an active local or Docker container session using a neutral two-arm probe protocol with explicit failure outcomes.

### 4.1 Two-Arm Empirical Trial Protocol

```
[ Two-Arm Probe Protocol ]
  0. Environment Feasibility Probe (Prerequisite) ─ if PASS, proceed; else record BLOCKED (Setup Failure)
  │
  ├── Arm A: Baseline Discovery Probe (Clean Worktree)
  │     ├── Target repository checkout in execution environment
  │     ├── Runner verified at skills/flow/runner/flow.sh (STOP if unreachable)
  │     ├── NO AGENTS.md, NO custom prompt framing, NO Flow instructions
  │     └── Objective: Record baseline discovery behavior without scaffolding (observation only)
  │
  └── Arm B: Candidate Instruction Probe (Instruction Scaffolding)
        ├── Target repository checkout in execution environment
        ├── Runner verified at skills/flow/runner/flow.sh (STOP if unreachable)
        ├── Candidate instruction scaffolding installed (AGENTS.md / problem prompt framing)
        └── Objective: Execute 4-Point Gate Verification Matrix with explicit outcomes
```

0. **Environment Feasibility Probe (Prerequisite):**
   - Verify that the AutoCodeRover Python environment and execution sandbox (host virtualenv or Docker container) can be provisioned.
   - If environment provisioning fails, record **FAIL (Infrastructure Unavailable)**.
   - Verify that `skills/flow/runner/flow.sh` is reachable within the workspace. If unreachable, record **STOP (Runner Not Reachable)**.

1. **Arm A: Baseline Discovery Probe (Observation Only):**
   - In a clean worktree without Flow instruction scaffolding, query AutoCodeRover:
     ```text
     What engineering discipline governs this project, and what gate commands are available?
     ```
   - *Outcome:* Record native behavior. Absence of Flow awareness is recorded as a neutral baseline observation; unexpected Flow awareness is investigated.

2. **Arm B: Candidate Instruction Probe (Candidate Scaffolding Installed):**
   - Introduce candidate instruction scaffolding: repository root `AGENTS.md` containing Flow directives and project-local runner invocation commands, paired with task prompt framing.
   - Execute the complete Four-Point Gate Verification Matrix against this session.

---

### 4.2 Gate Execution Matrix with Explicit Failure Outcomes

#### Gate 1: Ingestion Audit (Canary Query)

- **Objective:** Verify that AutoCodeRover ingests candidate instruction scaffolding (`AGENTS.md` or task context) into active model context upon initialization, without truncation, parsing failure, or path confusion.
- **Test Input (Prompt Query in AutoCodeRover task):**
  ```text
  What software development discipline governs this repository, what gate commands are available, and how are they invoked in this environment?
  ```
- **Explicit Failure Outcomes:**
  - `PASS`: Candidate instructions are detected and ingested into active model context; agent accurately identifies Flow as the governing discipline and cites `bash skills/flow/runner/flow.sh`.
  - `FAIL (Path Ignored / Unsupported)`: Candidate instruction file is not loaded; agent has no awareness of Flow directives or governing discipline.
  - `FAIL (Truncation / Parsing Error)`: Instruction text is clipped, truncated by context limits, or causes parsing failure.
  - `FAIL (Host Path Confusion)`: Agent cites invalid host-level paths (e.g., `~/.claude/` or `~/.agents/`) instead of the project-local runner.
- **Evaluation Criteria Checklist:**
  - [ ] AutoCodeRover ingests `AGENTS.md` or prompt framing directives into context.
  - [ ] Agent identifies Flow as the governing engineering discipline.
  - [ ] Agent explicitly references `bash skills/flow/runner/flow.sh <command>`.
  - [ ] Agent does not hallucinate non-existent host paths or background daemon requirements.
- **Verdict:** `[PASS / FAIL (Path Ignored) / FAIL (Truncation / Parsing Error) / FAIL (Host Path Confusion)]`

#### Gate 2: Invocation Audit (Status Check via Test Command Tool)

- **Objective:** Verify that AutoCodeRover successfully executes `bash skills/flow/runner/flow.sh status` via its command execution or test execution tool, capturing stdout and receiving an authentic integer exit code `0`.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your command execution tool.
  ```
- **Explicit Failure Outcomes:**
  - `PASS`: Tool executes `bash skills/flow/runner/flow.sh status`, captures stdout, receives exit code `0`, and accurately reports current stage and active cards.
  - `FAIL (Tool Unavailable / Blocked)`: Command execution tool is unavailable, disabled, or refuses execution.
  - `FAIL (Path Resolution / ENOENT)`: Execution fails due to relative path resolution failure inside the working directory.
  - `FAIL (Output Truncation / Wrapper Corruption)`: Command output buffering mangles runner diagnostics or swallows the exit code.
- **Evaluation Criteria Checklist:**
  - [ ] AutoCodeRover dispatches `bash skills/flow/runner/flow.sh status`.
  - [ ] Command executes without `ENOENT` or path-mapping errors.
  - [ ] Subshell returns integer exit code `0` with stage diagnostics.
  - [ ] Agent accurately reports the current stage (e.g., `00-idea`) and required next actions.
- **Verdict:** `[PASS / FAIL (Tool Unavailable) / FAIL (Path Resolution / ENOENT) / FAIL (Output Truncation)]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)

- **Objective:** Empirically verify that AutoCodeRover strictly halts when `flow.sh` returns a non-zero exit code ($exit \neq 0$) and does not hallucinate, rationalize, or synthesize a gate pass.
- **Test Setup:**
  - Install the broken Stage 00 fixture into the workspace:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and unchecked items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in your shell tool.
  ```
- **Explicit Failure Outcomes:**
  - `PASS`: Runner outputs failure diagnostics (`[FILL] marker remains in flow/00-idea.md`), subshell returns exit code `1`, AutoCodeRover strictly **HALTS**, quotes the failure diagnostic, does NOT advance stage, and initiates repair on `flow/00-idea.md`.
  - `DISQUALIFIED (Pass Hallucination)`: Agent ignores exit code `1`, rationalizes that requirements are met, or synthesizes a fake pass claim without on-disk gate receipts.
  - `FAIL (Crash / Unhandled Exit)`: Subshell or outer Python loop crashes or terminates unexpectedly on non-zero exit code.
- **Evaluation Criteria Checklist:**
  - [ ] AutoCodeRover executes `bash skills/flow/runner/flow.sh next`.
  - [ ] The runner outputs failure diagnostics and exits with code `1`.
  - [ ] **MANDATORY GATE-STOP:** Agent strictly **HALTS** and does not advance stage.
  - [ ] Agent reports exit code `1` and accurately quotes runner diagnostic output.
  - [ ] Agent initiates repair on `flow/00-idea.md` rather than bypassing the gate.
- **Verdict:** `[PASS / DISQUALIFIED (Pass Hallucination) / FAIL (Crash / Unhandled Exit)]`

#### Gate 4: State Persistence Audit (Stage Progression & Session Readback)

- **Objective:** Verify that stage advancement unlocks `flow/01-research.md` on disk, and that a subsequent fresh AutoCodeRover session accurately reads back the unlocked stage directly from disk without background daemons or memory loss.
- **Test Setup & Progression (Step 1):**
  - Fully complete `flow/00-idea.md` with valid content, removing all `[FILL]` markers and checking all required checklist boxes.
  - Execute advancement prompt:
    ```text
    Execute the stage gate command to advance to research.
    ```
- **Evaluation Criteria (Advancement):**
  - [ ] AutoCodeRover executes `bash skills/flow/runner/flow.sh next`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed on disk.
- **Test Setup & Readback (Step 2 - Fresh Session):**
  - Terminate the active AutoCodeRover execution session.
  - Launch a fresh AutoCodeRover session pointing to the same workspace directory.
  - Issue readback prompt:
    ```text
    Inspect the current project lifecycle status and report our active stage.
    ```
- **Explicit Failure Outcomes:**
  - `PASS`: Fresh session executes `bash skills/flow/runner/flow.sh status`, accurately reads back stage `01-research` from disk receipts, with zero reliance on resident background daemons.
  - `FAIL (Persistence Loss)`: State advancement artifacts are missing on disk, or fresh session fails to locate prior progress.
  - `FAIL (Daemon Dependency)`: State continuity fails because a background process or resident daemon was required.
- **Evaluation Criteria Checklist:**
  - [ ] Fresh AutoCodeRover session executes `bash skills/flow/runner/flow.sh status`.
  - [ ] Agent accurately reports stage `01-research` directly from on-disk artifacts.
  - [ ] State persistence was achieved purely through filesystem artifacts without daemons.
- **Verdict:** `[PASS / FAIL (Persistence Loss) / FAIL (Daemon Dependency)]`

---

### 4.3 Qualification Record Archival & Post-Trial Actions

Following live execution of the Four-Point Live Verification Protocol in an active AutoCodeRover environment:
1. Extract all raw tool execution JSON payloads, stdout/stderr streams, exit codes, and agent trajectories.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the qualification record to:
   ```text
   plans/research/harness-expansion/evidence/auto-code-rover-<version>-qualification-record.md
   ```
4. If and only if all four gates achieve unambiguous `PASS` verdicts:
   - Update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results.
   - Update `plans/research/harness-expansion/market-harness-survey.md` with the verified qualification status.
   - Document any recommended AutoCodeRover task/prompt framing in Flow's documentation.
