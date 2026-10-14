# Harness Intake Evaluation: OpenHands

- **Document Version:** 1.0.0
- **Evaluation Status:** Provisional Candidate (Desk Intake Complete; Container Live Trials Pending)
- **Evaluation Date:** 2026-10-14
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md`
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `skills/flow/references/workspace-rules.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation Reference:** OpenHands Documentation (Microagents: https://docs.all-hands-ai.com/modules/usage/microagents, Installation: https://docs.all-hands-ai.com/modules/usage/installation, accessed 2026-10-14)

---

## Section 1: Executive Summary & Category B (Container Microagent Scaffolding) Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
OpenHands (formerly OpenDevin, developed by All-Hands AI; vendor documentation: https://docs.all-hands-ai.com, GitHub repository: https://github.com/All-Hands-AI/OpenHands, accessed 2026-10-14) is an open-source platform for autonomous software engineering agents. It coordinates language models operating in multi-turn feedback loops to solve real-world development tasks, executing tools inside sandboxed Docker containers, and is evaluated on autonomous benchmarks such as SWE-bench (https://www.swebench.com).

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category B (Container Microagent Scaffolding)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE** (Desk Intake Complete; Container Live Trials Pending).
- **Qualification Rationale:** Flow generates OpenHands repository microagent scaffolding via `flow rules openhands --write` (materializing `.openhands/microagents/flow.md`). However, under Flow's Anti-Illusion Protocol, claiming verified compatibility based solely on generating a microagent markdown file is strictly prohibited ("quảng cáo ảo"). Harnesses in Category B provide repository-scoped prompt instruction scaffolding rather than native directory-based skill discovery (Category A). OpenHands runs within an isolated Docker container where host-level filesystems are invisible. Until an active OpenHands container session executes the Four-Point Live Verification Protocol inside a real Docker sandbox and archives raw tool execution payloads and receipts to `plans/research/harness-expansion/evidence/`, OpenHands must be truthfully designated as a **provisional candidate**.
```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         OPENHANDS EVALUATION SUMMARY                                   │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category B: Container Microagent Scaffolding            │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Repository Microagent (`.openhands/microagents/flow.md`) │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Environment        │ Isolated Linux Docker Container (`/workspace`)          │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Tool Execution API           │ `execute_bash` / `cmd_run` inside Docker subshell       │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, host holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Container Live Trials Pending)   │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In design review, OpenHands aligns with ADR-0001's fundamental invariants (empirical verification pending container live trial):
1. **Zero Resident Daemons:** Flow requires no persistent daemon, server process, or background socket listener inside or outside the OpenHands Docker container.
2. **Process Token Ownership:** The OpenHands agent (`CodeActAgent`) holds the event loop and process token. Flow is an ephemeral CLI invoked via the agent's bash execution tool, terminating as soon as the command returns.
3. **Zero Tool Interposition:** Flow does not wrap, intercept, or monkey-patch OpenHands's tool invocation pipeline. Gates are evaluated by re-reading filesystem ground truth (`flow/*.md`, `cards/C-NNN.md`, `manifest-hashes.json`) inside the mounted workspace.
4. **Deterministic Shell Contract:** Invocations occur strictly via `bash skills/flow/runner/flow.sh <command>`, returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.

### 1.3 Why Category B (Container Scaffolding) and Not Category A (Native Skill Target)?
Harnesses in **Category A (Native Skill Targets)** implement native directory-based skill discovery (e.g., Claude Code reading `~/.claude/skills/flow`, Codex reading `~/.codex/skills/flow`, or universal agents reading `~/.agents/skills/flow`).

OpenHands does **not** discover arbitrary skill bundles natively:
- OpenHands utilizes **Repository Microagents** (`.openhands/microagents/*.md`) triggered dynamically by prompt keywords.
- OpenHands runs tools inside an isolated Docker sandbox. Even if a user installs Flow globally on their host machine (e.g., `/home/user/.agents/skills/flow`), the Docker container cannot access that path.
- Flow interacts with OpenHands strictly by providing a triggered microagent definition that directs the in-container agent to invoke the project-local runner (`bash skills/flow/runner/flow.sh`). OpenHands is therefore categorized as **Category B (Container Microagent Scaffolding)**.

---

## Section 2: Phase 1 & 2 Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):** OpenHands represents an active open-source agent platform recognized within research and autonomous benchmark evaluation environments such as SWE-bench (vendor portal: https://docs.all-hands-ai.com, repo: https://github.com/All-Hands-AI/OpenHands, accessed 2026-10-14). While broad commercial desktop IDE market share among enterprise developers is distinct from standalone autonomous agent platforms, OpenHands has established active GitHub community interest and serves as a primary reference containerized agent harness.
- **Agentic Autonomy & Capability:** OpenHands agents (specifically `CodeActAgent`) possess high autonomy, executing actions in multi-turn loops, writing code, running bash commands inside container sandboxes, and diagnosing failures.
- **Ecosystem Openness & Stability:** OpenHands provides public documentation for its microagent architecture (`.openhands/microagents/`), allowing clean repository-scoped instruction injection.
- **Priority Tier & Feasibility Score:** **Tier 2 (Provisional Internal Estimate: 68/100)**.
  - **Score Classification:** `Provisional Internal Estimates (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **22/40**. Qualitative adoption hypothesis grounded in active GitHub community engagement and SWE-bench benchmark citations; smaller general-developer desktop footprint than commercial IDEs.
    2. **Agentic Autonomy & Capability (40 Points Max):** **32/40**. High multi-turn agentic autonomy via `CodeActAgent` executing bash subshell tools inside Linux Docker sandboxes, but constrained by container isolation boundaries and execution latency.
    3. **Ecosystem Openness & Stability (20 Points Max):** **14/20**. Fully open-source platform (MIT license) with documented repository microagent schema (`.openhands/microagents/`), but configuration is sensitive to Docker volume mounting topologies and prompt trigger keyword matching.
    - **Total Score:** **68/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74).
### 2.2 Phase 2: Architecture Probing

#### 2.2.1 OpenHands Architecture: CodeActAgent in Docker Containers
OpenHands architecture is split into two primary layers:
1. **Agent Orchestration Layer:** The outer host loop (running via Python backend or Web UI) orchestrates conversations, model queries, and event streams.
2. **Execution Sandbox (Docker Runtime):** Every tool execution (file editing, directory traversal, shell commands) is dispatched into an isolated Docker container.
   - The user's workspace directory is mounted into the container, typically at `/workspace` (or `/workspace/<repo-name>`).
   - The primary execution agent is `CodeActAgent`, which translates model actions into executable bash commands within the container.
   - The shell environment inside the container is a real Linux subshell (typically Debian/Ubuntu-based), providing standard POSIX utilities (`bash`, `git`, `coreutils`).

#### 2.2.2 Ingestion Mechanism: Repository Microagent Schema & Template Alignment
OpenHands implements an explicit **Microagent** specification located under `.openhands/microagents/*.md`:
- **Format:** Markdown file with a YAML frontmatter block defining the microagent identity and activation triggers.
- **Flow Template Alignment with `flow rules openhands`:** Flow's `.openhands/microagents/flow.md` template (materialized via `flow rules openhands --write` and tested in `tests/test_flow_rules.sh`) emits the following exact microagent definition:

```yaml
---
name: flow
triggers:
  - "/flow"
  - "flow"
  - "card"
  - "gate"
---

# Flow Microagent for OpenHands

When working on this repository, execute all Flow commands using the project-local script inside the container:
`bash skills/flow/runner/flow.sh <command>`

Key commands:
- `bash skills/flow/runner/flow.sh status` — inspect current stage and in-flight cards.
- `bash skills/flow/runner/flow.sh next` — advance planning stage.
- `bash skills/flow/runner/flow.sh check C-NNN` — verify card criteria and gates.
```

- **Template Metrics & Trigger Verification:**
  - Characters: **522 characters** (raw byte length).
  - Lines: **18 lines**, Words: **69 words**.
  - Triggers: Verified list matches `flow rules openhands` in order: `"/flow"`, `"flow"`, `"card"`, `"gate"`.
- **Triggering Lifecycle:**
  - OpenHands monitors incoming user queries and conversation context.
  - When a trigger keyword (e.g., `flow`, `gate`, `card`, `/flow`) is detected in the prompt, OpenHands automatically injects the microagent's Markdown body into the model's active context window.
  - If no trigger keyword is matched, the microagent remains unloaded, conserving context window tokens.
#### 2.2.3 Container Isolation Reality: The Host Path Disconnect & Isolation Boundary
A critical technical reality governs OpenHands integrations due to its container isolation boundary:
```
[ Host Operating System ]
  ├── /home/user/.claude/skills/flow   <── Completely invisible to container!
  ├── /home/user/.agents/skills/flow   <── Completely invisible to container!
  └── /home/user/my-project/           <── Mounted into Docker via -v
         ▼
[ Isolated Docker Container ]
  └── /workspace/                      <── Container working directory
        ├── .openhands/microagents/flow.md
        └── skills/flow/runner/flow.sh <── MUST BE LOCATED HERE (Project-local)
```

- **Docker Local Paths:** In standard OpenHands deployments, the user's project repository is mounted into the container at `/workspace` (or `/workspace/<repo>`). The container operates in an isolated Linux rootfs; host filesystem paths outside the mounted workspace directory do not exist.
- **Rejection of Host-Global Path Mapping:**
  - Developers commonly install Flow globally on their host machine for Claude Code (`/home/user/.claude/skills/flow`) or universal agents (`/home/user/.agents/skills/flow`).
  - Inside the OpenHands container, the user's home directory resolves to `/root` (or `/home/openhands`). Neither `/home/user/.claude/` nor `/home/user/.agents/` exists.
  - If the agent or prompt attempts to invoke `bash ~/.claude/skills/flow/runner/flow.sh` or `bash ~/.agents/skills/flow/runner/flow.sh`, the container fails immediately with:
    $$\text{bash: /root/.claude/skills/flow/runner/flow.sh: No such file or directory (ENOENT)}$$
- **Project-Local Runner Requirement:**
  - Because host global paths are unreachable, the Flow runner tree (`skills/flow/runner/flow.sh`) **must be present directly within the mounted workspace root** (`/workspace/skills/flow/runner/flow.sh`).
  - The microagent explicitly instructs the agent to execute the project-local relative path:
    ```bash
    bash skills/flow/runner/flow.sh <command>
    ```
  - This relative invocation guarantees path resolution inside `/workspace` regardless of container user ID or mount target.

#### 2.2.4 Evaluated Container Architecture Patterns (Provisional)

In architectural evaluation, OpenHands integration relies on two provisional design patterns (subject to Phase 4 live container trials):
1. **Repository-Vendored Runner (Primary Standard):**
   - The project repository includes the Flow runner tree under `skills/flow/runner/flow.sh`.
   - The microagent strictly specifies the workspace-relative path:
     ```bash
     bash skills/flow/runner/flow.sh <command>
     ```
   - Because the repository root is mounted at `/workspace`, this relative path resolves deterministically inside the container.
2. **Container-Internal Global Install (Advanced Setup):**
   - If the user prefers a global installation inside the container, `npx @manhquy/flow-skill@latest -t agents` must be executed **inside** the container lifecycle (e.g., via Dockerfile build or container initialization script), populating `/root/.agents/skills/flow` within the container filesystem.
#### 2.2.5 Execution Invariants: Zero Resident Daemons
- Tool commands dispatched by `CodeActAgent` execute as short-lived subshells inside the Docker container.
- Flow requires no resident daemon or background process. Each command (`flow.sh status`, `flow.sh next`, `flow.sh check C-NNN`) runs to completion, writes receipts to disk, and exits.
- Integer exit codes ($0$ vs. non-zero) and stdout/stderr streams are fed directly back to `CodeActAgent`, enabling mechanical gate enforcement.

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: Misleading Users with `--project` (Claude-Only Restriction)
- **The Pitfall:**
  - An engineer configuring OpenHands might assume they can run `npx @manhquy/flow-skill -t openhands --project` or `npx @manhquy/flow-skill -t agents --project` to install Flow locally into the project.
- **The Grounded Technical Reality:**
  - In Flow's codebase (`constants.mjs` and `install.sh`), project-scoped installation (`--project`) is **strictly reserved for Claude Code** (`.claude/skills/flow`).
  - In `constants.mjs`, all other targets (`codex`, `agents`, `antigravity`, `cursor`, `omp`) have:
    ```javascript
    projectScopeAllowed: false
    ```
  - Attempting to run `--project` against any target other than Claude Code is immediately rejected by the installer validation logic.
- **The Anti-Illusion Mitigation:**
  - Documentation and microagent guidance must **never** instruct users to run `flow install --project` for OpenHands.
  - OpenHands integration is achieved either by checking out `skills/flow/` inside the repository or by generating the rule file via `flow rules openhands --write` alongside a vendored runner.

### 3.2 Latent Trap 2: Container Permission Boundaries (Root vs. Non-Root)
- **The Failure Mode:**
  - Docker containers in OpenHands may execute as `root` (UID 0) or as a non-privileged user (e.g., `openhands` with UID 1000).
  - **Permission Trap A (Executable Bit):** If git clones or file transfers strip the execute permission from `skills/flow/runner/flow.sh`, executing `./skills/flow/runner/flow.sh` fails with `Permission denied (EACCES)`. Executing via `bash skills/flow/runner/flow.sh` bypasses the execute bit requirement, but `chmod +x` is still recommended.
  - **Permission Trap B (Host Mount Ownership):** When OpenHands runs as `root` inside the container, any files created or modified by Flow (such as `flow/01-research.md` or `cards/C-001.md`) will be owned by `root:root`. If the host developer on Linux runs as UID 1000, subsequent local git commands on the host machine may fail with permission errors.
- **The Anti-Illusion Mitigation:**
  - The microagent instructions explicitly invoke the runner with `bash skills/flow/runner/flow.sh <command>` rather than bare executable `./skills/flow/runner/flow.sh`.
  - When configuring OpenHands Docker environments, operators should ensure container user UID matches the host user UID (`--user $(id -u):$(id -g)`), or ensure workspace ownership is reconciled.

### 3.3 Latent Trap 3: Container Timeouts & Synthesized Pass Hallucinations
- **The Failure Mode:**
  - If a test command inside a card verification (`## Verify`) triggers an interactive prompt, hangs on a network socket, or times out, OpenHands's execution sandbox may terminate the subshell with a generic timeout or abort.
  - The LLM agent, attempting to satisfy the user prompt, may inspect the card checklist, assume the tests would have passed, and declare:
    > *"All verification checks complete. Marking card C-001 as done."*
- **The Anti-Illusion Mitigation:**
  - Microagent scaffolding explicitly enforces:
    > *"NEVER mark a card done or advance a stage without an authentic exit code 0 returned by `flow.sh check C-NNN`. Hallucinating a pass without on-disk runner receipts is a catastrophic discipline breach."*
  - Card verification requires verified receipts written to `cards/C-NNN.md` and validated by `flow.sh check`.

---

## Section 4: Live Verification Runbook Checklist

This runbook provides step-by-step instructions for executing the **Four-Point Live Verification Protocol** in an active OpenHands container session.

### 4.1 Pre-Verification Environment Provisioning

1. **Host Worktree Preparation:**
   ```bash
   git clone <repo-url> /tmp/flow-openhands-eval
   cd /tmp/flow-openhands-eval
   git checkout -b test/openhands-qualification
   ```
2. **Generate Microagent Scaffolding:**
   ```bash
   bash skills/flow/runner/flow.sh rules openhands --write
   test -f .openhands/microagents/flow.md && echo "OpenHands microagent present."
   ```
3. **Verify Project Runner Availability:**
   - Confirm `skills/flow/runner/flow.sh` is present in the repository root.
   - Set execution permissions:
     ```bash
     chmod +x skills/flow/runner/flow.sh
     ```
4. **Launch OpenHands Workspace:**
   - Deploy OpenHands using the operator's standard environment per official OpenHands documentation (`https://docs.all-hands-ai.com/modules/usage/installation`).
   - Ensure the test repository is mounted as the active workspace (`/workspace`). Container deployment topology (Docker, Podman, Kubernetes, or remote sandboxes) is operator-specific; Flow does not mandate mounting `/var/run/docker.sock` or granting container host daemon access.
   - Open the OpenHands web UI (or CLI session).
   - Record exact OpenHands container tag, agent class (`CodeActAgent`), and model string (e.g., Claude 3.7 Sonnet).

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Microagent Trigger & Context Loading)
- **Objective:** Verify OpenHands ingests `.openhands/microagents/flow.md` when triggered by keywords and loads the directives into context.
- **Test Input (Trigger Query in OpenHands session):**
  ```text
  What software development discipline governs this flow project, what gate commands are available, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] OpenHands detects trigger keywords (`/flow`, `flow`, `card`, `gate`) and loads `.openhands/microagents/flow.md`.
  - [ ] OpenHands identifies Flow as the governing engineering discipline.
  - [ ] OpenHands explicitly cites the project-local command `bash skills/flow/runner/flow.sh` rather than an invalid host path like `~/.claude/skills/flow` or `~/.agents/skills/flow`.
- **Verdict:** `[PASS / FAIL]`

#### Gate 2: Invocation Audit (Container Subshell Execution)
- **Objective:** Verify `CodeActAgent` executes `flow.sh` inside the Docker container and correctly parses the returned stdout and exit code.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your bash command execution tool.
  ```
- **Evaluation Criteria:**
  - [ ] `CodeActAgent` executes `bash skills/flow/runner/flow.sh status` inside `/workspace`.
  - [ ] The command resolves the relative path without `ENOENT` or path-mapping errors.
  - [ ] Container subshell returns exit code `0` along with stage status output.
  - [ ] Agent reports the current stage (e.g., `00-idea`) and next action accurately.
- **Verdict:** `[PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically verify that `CodeActAgent` halts when `flow.sh` exits with non-zero status and does not hallucinate a pass.
- **Test Setup:**
  - Install the broken Stage 00 fixture into the workspace:
    ```bash
    cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
    ```
  - Verify `flow/00-idea.md` contains unfilled `[FILL]` markers and unchecked items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in bash.
  ```
- **Evaluation Criteria:**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` in the container.
  - [ ] The runner outputs failure diagnostics (`[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Agent strictly **HALTS**. It does **NOT** synthesize or hallucinate that the stage advanced.
  - [ ] Agent reports the exit code `1`, quotes the runner diagnostic, and initiates repair on `flow/00-idea.md`.
  - *(Note: Any hallucinated advance or fake pass immediately results in **DISQUALIFIED** status).*
- **Verdict:** `[PASS / FAIL]`

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that successful stage advancement unlocks `flow/01-research.md` on disk in `/workspace` and a fresh `flow status` invocation reads the unlocked stage directly from disk without state loss.
- **Test Setup:**
  - Fully complete `flow/00-idea.md` with valid content, removing all `[FILL]` markers and checking all required boxes.
- **Test Input 1:**
  ```text
  Execute the stage gate command again to advance to research.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh next` in the container.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and accessible on disk in `/workspace`.
- **Test Input 2 (Session Persistence & Readback):**
  - Terminate the agent session and start a new conversation/session within OpenHands.
  - Issue readback query:
    ```text
    Resume our Flow session and report our position.
    ```
- **Evaluation Criteria (Readback):**
  - [ ] Agent executes `bash skills/flow/runner/flow.sh status`.
  - [ ] Agent accurately reads back stage `01-research` directly from disk.
  - [ ] State continuity was achieved entirely through on-disk artifacts without background daemons.
- **Verdict:** `[PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Following the execution of the live container trial:
1. Extract all raw container bash execution JSON payloads, stdout/stderr logs, and agent conversational turns.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/openhands-<version>-qualification-record.md
   ```
4. Update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to reflect verified live qualification results if all four gates pass.
