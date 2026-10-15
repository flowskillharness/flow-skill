# Harness Intake Evaluation: Continue.dev (VS Code & JetBrains Extension)

- **Document Version:** 1.0.0
- **Evaluation Status:** `Deferred Candidate (Desk Intake Complete; Tool-Loop & Schema Verification Pending)`
- **Evaluation Date:** 2026-10-15
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Governing Process:** `docs/harness-qualification-process.md` (Harness Research & Qualification Process SOP)
- **Related References:**
  - `plans/research/harness-expansion/architecture-compatibility-matrix.md` (§3.4.2)
  - `plans/research/harness-expansion/market-harness-survey.md`
  - `plans/research/harness-expansion/current-harness-inventory.md`
  - `plans/research/harness-expansion/evidence/README.md`
  - `docs/doc-budgets.txt`
  - **Vendor Documentation References:**
    - Continue.dev Official Portal: https://continue.dev (accessed 2026-10-15)
    - Continue.dev Documentation: https://docs.continue.dev (accessed 2026-10-15)
    - Continue.dev GitHub Repository: https://github.com/continuedev/continue (Apache-2.0, accessed 2026-10-15)

---

## Section 1: Executive Summary & Deferred Candidate Classification (Pending Verification)

### 1.1 Executive Summary & "Support Thật" Qualification Status
Continue.dev (developed by Continue Dev, Inc.; official portal: https://continue.dev, documentation: https://docs.continue.dev, source repository: https://github.com/continuedev/continue) is an open-source AI code assistant extension available for Visual Studio Code and JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm, etc.). Continue enables developers to connect commercial LLMs (Anthropic Claude, OpenAI GPT-4o, Google Gemini) or locally hosted models (via Ollama, LM Studio, vLLM, or llama.cpp) to power inline code completions (tab autocomplete), conversational sidebar chat, slash commands, custom context providers (`@code`, `@docs`, `@folder`, `@diff`), and emerging experimental tool and agent features.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Deferred Candidate (Pending Schema & Tool-Loop Verification)**.
- **Qualification Status:** **`DEFERRED CANDIDATE (Schema & Tool-Loop Unverified; Live Trials Pending)`**.
- **Qualification Rationale:**
  - Continue.dev has undergone multiple configuration schema revisions across minor releases (transitioning across `config.json`, `config.yaml`, `.continue/rules/`, and `.continue/prompts/`), without a pinned, backward-compatible workspace rule schema guaranteed across versions.
  - In standard developer usage, Continue functions primarily as an inline completion engine and conversational chat panel. Its autonomous multi-turn tool execution loop—specifically the ability to dispatch shell commands autonomously, inspect non-zero integer exit codes ($\text{exit} \neq 0$), and reliably halt on mechanical gate failure—has not been empirically verified against running hosts.
  - In strict compliance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1) and `architecture-compatibility-matrix.md` §3.4.2, advertising Continue.dev support without verified schema stability and tool loop fidelity violates Flow's "Support Thật" mandate.
  - Flow's `flow rules` command is strictly restricted to **seven verified harness templates** (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). Continue.dev is explicitly excluded from `flow rules` until it satisfies the 4-Point Live Verification Protocol.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                      CONTINUE.DEV EXTENSION EVALUATION SUMMARY                         │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Deferred Candidate (Pending Schema & Tool-Loop)        │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Evolving config (`config.yaml` / `.continue/rules/` /   │
│                              │ prompt files)                                           │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Tool API           │ Unverified autonomous terminal tool loop                │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero     │
│                              │ daemons, host holds token                               │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ DEFERRED CANDIDATE (Schema & Tool-Loop Unverified;      │
│                              │ Unverified; Live Trials Pending)                        │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In desk design review, prospective integration with Continue.dev aligns with ADR-0001's fundamental invariants:
1. **Zero Resident Daemons:** Flow requires no persistent background daemon, server process, or resident listening socket inside or outside the host IDE. While Continue runs a local extension core process (a Node/TypeScript background service managing LLM streams and context providers), Flow must never run as a persistent daemon inside or alongside that service. Flow operates strictly as an ephemeral executable.
2. **Process Token Ownership:** The IDE extension host and Continue runtime hold the process token and manage the conversational event loop. Flow executes strictly as an ephemeral subprocess invoked via terminal commands, terminating immediately upon returning its exit status code.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Continue's model communications, context provider dispatches, or extension IPC. Gate evaluations are performed post-hoc by re-reading on-disk ground truth (`flow/`, `cards/`, `manifest-hashes.json`).
4. **Deterministic Shell Contract:** Stage transitions, gate validations, and card checks occur strictly via `bash skills/flow/runner/flow.sh <verb>` (or `flow.cmd <verb>` on native Windows), returning an unambiguous integer exit code ($0$ for pass, $1$ for failure) with plain-text diagnostics.
5. **Rejection of Resident MCP / LSP Server Daemons:** While Continue supports Model Context Protocol (MCP) servers, exposing Flow as a resident MCP server daemon is constitutionally prohibited under ADR-0001. Flow's state lives on disk in Git and bounded markdown files, never in volatile memory heaps of resident server daemons.

### 1.3 Architectural Classification: Why Category D and Not Category B (or Category A)?
Flow categorizes harness integrations into four distinct architectural tiers:
- **Category A (Native Skill Target):** Harnesses natively implementing directory-based skill discovery where the agent reads `SKILL.md` from a standard home (e.g., Claude Code reading `~/.claude/skills/flow`, Codex CLI reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).
  - *Why Continue is not Category A:* Continue does not implement directory-based skill discovery conforming to the universal Agent Skills standard or `SKILL.md` specifications.
- **Category B (Workspace Rule Scaffolding):** Harnesses providing documented, stable repository-level instruction files (such as `.cursor/rules/*.mdc`, `.windsurf/rules/*.md`, `.roomodes`, `.clinerules`, or `.github/copilot-instructions.md`) paired with a verified terminal execution loop.
  - *Why Continue is deferred from Category B to Category D:* Continue lacks both a verified, backward-compatible rule schema across minor versions and an empirically verified autonomous terminal tool-loop execution engine that halts on non-zero exit codes.
- **Category D (Deferred / Pending Verification):** Harnesses currently lacking either schema stability, autonomous tool loop execution, or live empirical verification.
  - *Verdict:* Continue.dev is classified strictly as **Category D (Deferred Candidate)**.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization Scoring
- **Market Share & Developer Adoption:** Continue.dev has established a strong, active open-source mindshare across both Visual Studio Code and JetBrains IDEs. It is widely recognized as a flexible, vendor-neutral extension, particularly favored by developers deploying local open-weight models (via Ollama, LM Studio, vLLM) or organizations adhering to strict data sovereignty policies. However, in enterprise desktop penetration and autonomous agent usage, it trails proprietary leaders such as GitHub Copilot and Cursor.
- **Agentic Autonomy & Capability (Constrained / Experimental Loop):** Continue primarily operates as an interactive conversational sidebar assistant and inline code completion engine. While it provides slash commands (e.g., `/edit`, `/cmd`) and experimental agent modes, its autonomous task execution loop—disagreeing with hallucinated passes on mechanical exit code $\neq 0$—is unverified.
- **Ecosystem Openness & Stability:** Continue is fully open-source under the Apache-2.0 license, developed publicly on GitHub (`continuedev/continue`), with transparent issue tracking, an active community, and open integration with standard model APIs.
- **Priority Tier Score:** **Tier 2 (Provisional Internal Estimate: 64/100)**.
  - **Score Classification:** `Provisional Internal Estimate (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **28/40**. Active open-source mindshare in VS Code and JetBrains ecosystems, strong popularity among developers seeking local model integration, though total developer install base trails GitHub Copilot.
    2. **Agentic Autonomy & Capability (40 Points Max):** **16/40**. Evolving slash commands and experimental agent mode; primarily functions as conversational sidebar and inline completion; lacks verified autonomous terminal tool loop.
    3. **Ecosystem Openness & Stability (20 Points Max):** **20/20**. Open-source Apache-2.0 license, public GitHub development, standard API compatibility, zero proprietary lock-in.
  - **Total Score:** **64/100** $\rightarrow$ Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74; classified as Deferred Candidate).

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Extension Architecture & Core Process Communication
Continue operates via a split architecture:
1. **IDE Client Layer:** Extension packages for VS Code and JetBrains that manage UI surfaces (sidebar chat webview, inline diff decorations, editor keybindings).
2. **Continue Core Process:** A local background server (TypeScript / Node runtime) that handles configuration loading, context provider indexing, slash command routing, and LLM API streaming over JSON-RPC.
3. **Execution Boundary:** The core process interacts with the host filesystem and subshells. However, command execution is historically surfaced as an interactive prompt or suggested shell command for user confirmation, rather than an unprompted autonomous execution loop.

#### 2.2.2 Rule & Prompt Ingestion Evolution: The Multi-Format Churn
Continue has iterated across multiple configuration mechanisms throughout its release history:
- **`config.json` (Legacy):** Early versions of Continue relied exclusively on a monolithic JSON configuration file located at `~/.continue/config.json`, defining models, custom slash commands, and system messages.
- **`config.yaml` (Modern / Hub):** Recent versions migrated configuration to YAML format (`~/.continue/config.yaml` and workspace-scoped `.continue/config.yaml`), introducing structured blocks for models, context providers, and experimental rules.
- **`.continue/rules/` Directory:** Experimental support for workspace rules placed as Markdown files under `<workspace-root>/.continue/rules/*.md`.
- **`.continue/prompts/` Directory:** Custom slash commands defined as `.prompt` files containing prompt templates with frontmatter.
- **Schema Fragility Assessment:** The lack of a frozen, backward-compatible workspace rule specification across minor versions creates significant integration risk. A rule file written for one minor release may be ignored by another.

#### 2.2.3 Tool Execution API & Terminal Subsystem Reality
- **Interactive Command Suggestions vs. Autonomous Loops:** In standard operation, when a user asks Continue to run a command, Continue typically outputs a markdown code fence with a suggested terminal command or invokes the `/cmd` slash command. The developer must manually copy, paste, or click to execute the command in the IDE terminal.
- **Experimental Agent Mode & MCP Tools:** Recent Continue builds experiment with agentic tool calling, including MCP tool servers and built-in terminal tools. However:
  - Tool execution in Continue does not provide standardized, battle-tested feedback guarantees regarding subshell exit code propagation.
  - If a subshell command returns an exit code of `1`, Continue's conversational stream frequently treats the non-zero status as informational error text to explain, rather than a hard halting condition that blocks further task execution.
- **Absence of Headless Evaluation Mode:** Continue does not offer a headless, non-interactive CLI evaluation harness (analogous to Codex's `codex exec` or Claude Code's headless evaluation). Qualification must therefore occur through live interactive host trials.

#### 2.2.4 Context Budgeting & Token Dynamics
- **Local Model Usage Hazards:** A significant proportion of Continue installations utilize local models (e.g., Llama 3 8B, Qwen 2.5 7B, Mistral 7B via Ollama). These models have smaller effective context windows and significantly degraded instruction-following capabilities compared to frontier models (Claude 3.7 Sonnet, GPT-4o).
- **Instruction Dilution:** Injecting monolithic, multi-kilobyte rule files into Continue's prompt context rapidly consumes token budgets on local models, causing severe prompt dilution, failure to respect card file boundaries, and hallucinated gate completions.
- **Progressive Disclosure Necessity:** Any eventual Continue rule scaffold must strictly follow Flow's ultra-lean rule architecture (< 100 tokens), delegating all deep stage guidance to on-disk reference playbooks (`skills/flow/references/*.md`).

---

## Section 3: Latent Bug Analysis & Failure Modes (Anti-Illusion Protocol)

This section grounds the evaluation in `plans/research/harness-expansion/architecture-compatibility-matrix.md` §3.4.2 ("Why Continue.dev Was Deferred") and the Anti-Illusion Protocol (`docs/harness-qualification-process.md` §2).

### 3.1 Latent Trap 1: Evolving Configuration Schema Fragility (The Churn Trap)
- **The Failure Mode:**
  - Continue.dev has iterated across `config.json`, `config.yaml`, `.continue/rules/`, and `.continue/prompts/`.
  - If Flow prematurely introduces an unpinned rule template into `flow rules` (e.g., `flow rules continue --write` creating `.continue/rules/flow.md`):
    - Users running older Continue versions (relying on `config.json`) will have the file silently ignored.
    - Users running newer versions configured via `config.yaml` or Continue Hub may have workspace rules disabled or overridden by global configurations.
    - If Continue alters its rule file naming convention, metadata frontmatter, or discovery path in a subsequent minor point release, the materialized `.continue/rules/flow.md` becomes a phantom file.
- **The Anti-Illusion Mitigation:**
  - Under Flow's "Support Thật" mandate, scaffolding must **never** be added to `flow rules` based on speculative or unpinned schemas.
  - Continue.dev support remains deferred until the Continue project formalizes and documents a stable, long-term workspace rule specification.

### 3.2 Latent Trap 2: Tool Execution Loop Fidelity & Hallucinated Passes (The Pass Hallucination Trap)
- **The Failure Mode:**
  - In standard usage, Continue functions primarily as an inline/sidebar completion and chat interface.
  - When prompted with:
    > *"Advance to the next Flow stage."*
  - An assistant lacking an autonomous tool execution loop will read `flow/00-idea.md` via file-context tools, observe that the prose appears coherent, and generate a conversational response:
    > *"Stage 00-idea looks complete! You are ready to move to stage 01-research."*
  - In reality:
    - Unfilled `[FILL]` placeholders and open checklist items (`- [ ]`) remain in `flow/00-idea.md`.
    - Mechanical gate check `bash skills/flow/runner/flow.sh next` was never executed.
    - No on-disk receipt was created, and `flow/01-research.md` remains locked.
  - Even in experimental agent mode, if Continue executes a terminal command but ignores or misinterprets the non-zero integer exit code ($\text{exit} \neq 0$), the agent may apologize for the error while simultaneously hallucinating that the stage advanced.
- **The Anti-Illusion Mitigation:**
  - Flow requires empirical verification that Continue's tool execution loop treats $\text{exit} \neq 0$ as an unconditional, non-negotiable halting event (Gate 3: Gate-Stop Audit).

### 3.3 Latent Trap 3: The Illusion Trap ("Quảng Cáo Ảo" vs. "Support Thật")
- **The Failure Mode:**
  - AI tooling vendors frequently claim "universal IDE support" by generating unverified markdown files or claiming compatibility with every extension.
  - If Flow were to list Continue.dev as a supported harness in `flow rules` or marketing documentation without verified schema stability and tool loop fidelity, developers would trust that Flow's discipline is active.
  - When the agent silently ignores the unverified rules and edits files outside `cards/C-NNN.md` `## Allowed files`, the developer suffers silent corruption of their repository.
- **The Anti-Illusion Mitigation:**
  - Flow explicitly defers Continue.dev to Category D in `plans/research/harness-expansion/architecture-compatibility-matrix.md` §3.4.2:
    > *"Under the Four-Point Live Verification Protocol, scaffolding cannot be added to `flow rules` without authoritative schema documentation and live tool-loop execution verification. Speculative inclusion would introduce unverified, hollow compatibility."*

### 3.4 Latent Trap 4: Local Model Instruction Decay & Boundary Breaches
- **The Failure Mode:**
  - When Continue is operated with local models (e.g., 7B or 8B parameter models), the model has limited attention capacity for complex system prompts.
  - When presented with a card-governed workflow (`cards/C-NNN.md`), local models frequently exhibit boundary breaches: modifying files outside `## Allowed files`, skipping verification commands under `## Verify`, or inventing synthetic passes.
- **The Anti-Illusion Mitigation:**
  - Continue evaluation must explicitly test model fidelity and token budgeting, documenting whether smaller models can reliably follow Flow's mechanical instructions or if integration requires frontier-tier models.

### 3.5 Latent Trap 5: Cross-IDE Inconsistencies (VS Code vs. JetBrains)
- **The Failure Mode:**
  - Continue is distributed as both a VS Code extension and a JetBrains plugin.
  - The underlying capabilities of the two extension targets are not identical: terminal tool integration, webview execution, and subshell dispatch differ between VS Code's extension API and JetBrains's IntelliJ platform SDK.
  - Scaffolding that functions in VS Code may fail completely in JetBrains due to differing subshell environments or terminal focus handling.
- **The Anti-Illusion Mitigation:**
  - Live verification for Continue must test both VS Code and JetBrains host environments before granting Category B status across both platforms.

---

## Section 4: 4-Point Live Verification Runbook (Category D to Category B Graduation Requirements)

This runbook specifies the exact empirical requirements for Continue.dev to graduate from **Category D (Deferred Candidate)** to **Category B (Workspace Rule Scaffolding)**.

### 4.0 Interactive Qualification Invariant & Prerequisites for Graduation
Because Continue.dev does not provide a headless CLI evaluation interface for automated CI pipelines, qualification strictly requires an interactive session in VS Code and JetBrains with the Continue extension active.

**Prerequisites for Graduation from Category D to Category B:**
1. **Schema Pinning:** The Continue project must provide official, authoritative documentation specifying a stable, pinned workspace rule ingestion format (e.g., `.continue/rules/*.md` or a stable section in `.continue/config.yaml`) that is guaranteed backward-compatible across minor releases.
2. **Autonomous Tool Loop:** Continue must possess an active, verified terminal tool execution capability where the agent autonomously invokes shell commands, captures stdout and stderr, and reliably receives the integer exit status code.
3. **Pass the Four-Point Live Verification Protocol:** Live host trials must pass all four gates below without hallucination or manual intervention.

---

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   Create an isolated temporary git worktree with no prior Flow state:
   ```bash
   git worktree add /tmp/flow-continue-eval -b test/continue-eval-intake
   cd /tmp/flow-continue-eval
   ```

2. **Ensure Runner Availability:**
   Ensure `skills/flow/runner/flow.sh` is present in the workspace and executable:
   ```bash
   chmod +x skills/flow/runner/flow.sh
   bash skills/flow/runner/flow.sh status
   ```

3. **Stage Candidate Rule Configuration:**
   Create the candidate workspace rule file according to the pinned vendor specification under test (e.g., `.continue/rules/flow.md`):
   ```markdown
   # Flow Discipline Rules for Continue.dev

   This repository enforces Flow discipline:
   - Planning artifacts live under `flow/` (`00-idea.md` through `05-contract.md`).
   - Units of work are tracked as atomic markdown cards in `cards/C-NNN.md`.
   - Never modify files outside a card's declared `## Allowed files`.
   - Verification requires reproducible commands documented under `## Verify`.
   - Mechanical ground truth is `bash skills/flow/runner/flow.sh check C-NNN`.
   ```

4. **Launch IDE & Continue Extension:**
   Open `/tmp/flow-continue-eval` in VS Code or JetBrains with Continue installed. Document the host environment details:
   - Host IDE: `[VS Code v1.x.x / IntelliJ IDEA 2026.x]`
   - Continue Extension Version: `[e.g., v0.8.x / v1.x.x]`
   - Underlying Model Identifier: `[e.g., Claude 3.7 Sonnet / GPT-4o / Ollama Qwen 2.5 7B]`
   - Operating System: `[Linux x64 / macOS arm64 / Windows x64]`
   - Active Nonce: `[e.g., nonce-continue-20261015-cnt88v]`

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Context Loading & Rule Discovery)
- **Objective:** Verify Continue natively discovers and ingests the candidate rule file without parsing errors, syntax crashes, or silent truncation.
- **Test Input (Canary Query in a fresh Continue chat thread):**
  ```text
  What software development discipline governs this repository, what commands are available to inspect status, and what is our current stage?
  ```
- **Evaluation Criteria:**
  - [ ] Continue explicitly identifies Flow as the governing development discipline.
  - [ ] Continue references `skills/flow/runner/flow.sh` (or `flow.cmd`) as the mechanical execution tool.
  - [ ] Continue identifies artifacts under `flow/` and atomic cards under `cards/C-NNN.md`.
  - [ ] Continue does not report YAML/JSON parsing errors or silently drop the rule context.
- **Empty Capture Placeholder:**
  ```text
  [RAW CONTINUE INGESTION CANARY RESPONSE CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

#### Gate 2: Invocation Audit (Terminal Execution Fidelity)
- **Objective:** Verify Continue autonomously dispatches or directly executes a terminal tool call for `flow.sh status`, correctly receiving stdout and integer exit code `0`.
- **Test Input:**
  ```text
  Check the status of the current build lifecycle using the project terminal command.
  ```
- **Evaluation Criteria:**
  - [ ] Continue invokes `bash skills/flow/runner/flow.sh status` via its terminal execution tool.
  - [ ] The command executes in the integrated terminal without path resolution errors (`ENOENT`).
  - [ ] The runner exits with integer code `0`.
  - [ ] Continue receives stdout and accurately reports the current stage (`00-idea`) and next recommended step.
- **Empty Capture Placeholder:**
  ```text
  [RAW TERMINAL TOOL EXECUTION & STDOUT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that Continue strictly halts when `flow.sh` exits with non-zero status ($\text{exit} \neq 0$) and strictly refuses to hallucinate that a failed gate passed.
- **Test Setup:**
  Install the standard forced-failure Stage 00 fixture into the workspace:
  ```bash
  cp plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md flow/00-idea.md
  ```
  Confirm `flow/00-idea.md` contains unfilled `[FILL]` markers and open checklist items (`- [ ]`).
- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```
- **Evaluation Criteria:**
  - [ ] Continue invokes `bash skills/flow/runner/flow.sh next`.
  - [ ] The runner outputs failure diagnostics (e.g., `[FILL] marker remains in flow/00-idea.md`) and exits with status code `1`.
  - [ ] **MANDATORY GATE-STOP:** Continue strictly **HALTS**. It does **NOT** synthesize or declare that the stage passed.
  - [ ] Continue quotes the runner diagnostic failure and advises repairing the unfilled markers in `flow/00-idea.md`.
  - *(Note: If Continue claims the stage advanced despite exit code 1, the candidate is immediately marked **DISQUALIFIED**).*
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE-STOP TOOL EXECUTION & HALT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

#### Gate 4: State Integrity Audit (Persistence & Readback)
- **Objective:** Verify that `flow.sh next` unlocks `flow/01-research.md` on disk, and a fresh Continue chat session reads the unlocked stage directly from disk across sessions without state loss.
- **Test Setup:**
  Fill all `[FILL]` placeholders and check all boxes in `flow/00-idea.md` with complete, valid requirements.
- **Test Input 1 (Advancement):**
  ```text
  Re-run the stage gate command in the terminal to advance.
  ```
- **Evaluation Criteria (Advancement):**
  - [ ] Continue invokes `bash skills/flow/runner/flow.sh next`.
  - [ ] Runner exits with code `0` and outputs: `PASS: stage 00-idea gate clean -> unlocked stage 1 (flow/01-research.md)`.
  - [ ] Artifact `flow/01-research.md` is unlocked and confirmed present on disk.
- **Test Input 2 (Session Restart & Fresh Readback):**
  Close the active chat panel and start a completely fresh Continue chat session. Issue:
  ```text
  Resume our Flow session and report our position.
  ```
- **Evaluation Criteria (Readback):**
  - [ ] Continue invokes `bash skills/flow/runner/flow.sh status`.
  - [ ] Continue reads back stage `01-research` directly from disk without state loss.
  - [ ] Zero resident daemons were required to maintain state between sessions.
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE 4 ADVANCEMENT & FRESH SESSION READBACK CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

### 4.3 Graduation Checklist from Category D to Category B
To graduate Continue.dev from **Category D (Deferred Candidate)** to **Category B (Workspace Rule Scaffolding)**, all the following conditions must be met:

- [ ] **Authoritative Schema Pinning:** Continue.dev upstream documentation formally freezes and documents a workspace-level rule configuration path (e.g., `.continue/rules/*.md`) with verified backward compatibility across minor releases.
- [ ] **Autonomous Tool Execution:** Continue's autonomous tool loop executes terminal commands without requiring operator copy-paste interaction, reliably propagating integer exit codes to the agent context.
- [ ] **Live Host Verification:** An engineer conducts the live host trial documented in §4.2 across both VS Code and JetBrains IDEs.
- [ ] **Zero Hallucination Proof:** The Gate 3 forced-failure trial confirms that Continue halts unconditionally on $\text{exit} \neq 0$ and does not fabricate stage advancement.
- [ ] **Archived Qualification Record:** The completed verification record is committed to `plans/research/harness-expansion/evidence/continue-<version>-qualification-record.md`.
- [ ] **Matrix Update:** `plans/research/harness-expansion/architecture-compatibility-matrix.md` and `evidence/README.md` are updated to reflect the transition from Category D to Category B.
- [ ] **Implementation of `flow rules continue`:** Only after all preceding steps pass may `flow rules continue` and associated tests in `tests/test_flow_rules.sh` be authored and merged.

---

## Section 5: Conclusion & Honest Disclosure

Continue.dev represents an important and promising open-source AI extension project, distinguished by its Apache-2.0 licensing and flexible model connectivity. However, Flow's non-negotiable **"Support Thật"** discipline categorically rejects marketing theater and speculative support.

Until Continue.dev stabilizes its workspace rule schema and demonstrates an empirically verified, kill-honest autonomous tool execution loop, it remains classified as a **Deferred Candidate (Pending Schema & Tool-Loop Verification)**. Flow will not introduce unverified rule scaffolding into `flow rules` or make premature compatibility claims that could mislead developers into unconstrained, unverified agent executions.
