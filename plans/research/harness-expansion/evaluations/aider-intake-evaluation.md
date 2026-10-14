# Harness Intake Evaluation: Aider AI Pair Programmer

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
  - **Vendor References:**
    - Aider Official Portal: https://aider.chat
    - Aider Configuration Options: https://aider.chat/docs/config/options.html

---

## Section 1: Executive Summary & Category C (Automated Test Gate Scaffolding) Classification

### 1.1 Executive Summary & "Support Thật" Qualification Status
Aider (created by Paul Gauthier; official portal: https://aider.chat, documentation: https://aider.chat/docs/config/options.html, accessed 2026-10-14) is a widely adopted terminal-based AI pair programming tool. Operating directly in the developer's shell and tightly coupled with Git version control, Aider enables an engineer to pair with large language models to edit code across local repositories, automatically committing coherent changes and utilizing repository symbol maps.

Under Flow's **"Support Thật" (Honest Support)** principle codified in `docs/harness-qualification-process.md`:
- **Classification:** **Category C (Automated Hook / Test Gate Scaffolding)**.
- **Qualification Status:** **PROVISIONAL CANDIDATE (Desk Intake Complete; Live Host Trials Pending)**.
- **Qualification Rationale:**
  - Unlike Category A harnesses (which auto-discover directory-based skills) or Category B harnesses (which inject conversational markdown prompts), Aider integrates with Flow primarily through its **mechanical test execution lifecycle hook** (`test-cmd` in `.aider.conf.yml` with `auto-test: true`).
  - Flow generates verified `.aider.conf.yml` scaffolding via `flow rules aider --write`. This configuration hooks Aider's automated testing loop directly into Flow's card checking mechanism (`bash skills/flow/runner/flow.sh check "$cid"` or `flow.sh status`).
  - When Aider applies code edits, it immediately executes the test command. If Flow's runner returns exit code `1` (indicating an unfilled card section, unverified tests, or unpassed gates), Aider treats the failure as a broken test, halts git auto-commit, and enters its reflection/repair loop.
  - However, in strict accordance with Flow's **Anti-Illusion Protocol** (`docs/harness-qualification-process.md` §2.1), generating `.aider.conf.yml` and passing local synthetic test scripts (`tests/test_flow_rules.sh`) do **not** constitute empirical proof of live host enforcement ("quảng cáo ảo").
  - Until an active terminal session running Aider executes the Four-Point Live Verification Protocol with raw tool transcripts, terminal payloads, exit codes, and fresh nonces committed to `plans/research/harness-expansion/evidence/`, Aider must be transparently disclosed as a **provisional candidate**.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        AIDER AI PAIR PROGRAMMER EVALUATION SUMMARY                     │
├──────────────────────────────┬─────────────────────────────────────────────────────────┤
│ Architectural Classification │ Category C: Automated Hook / Test Gate Scaffolding      │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Ingestion Mechanism          │ Workspace YAML Configuration (`.aider.conf.yml`)        │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Execution Hook API           │ `test-cmd` (Invoked automatically via `auto-test: true`)│
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ ADR-0001 Compliance          │ PROVISIONAL (Desk-Reviewed): Ephemeral runner, zero daemons, operator/pair holds token │
├──────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Live Qualification Status    │ PROVISIONAL CANDIDATE (Desk Intake Complete; Host Trials Req) │
└──────────────────────────────┴─────────────────────────────────────────────────────────┘
```

### 1.2 Constitutional Alignment (ADR-0001 Invariants)
Flow's constitutional identity (`docs/adr/0001-discipline-layer-identity.md`) establishes that Flow is a **discipline layer**, never an agent runtime:
> *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

In design review, Aider aligns with ADR-0001's fundamental invariants (empirical verification pending live trial):
1. **Zero Resident Daemons:** Flow requires no persistent daemon, server process, or listening socket. Flow's runner executes on-demand when triggered by Aider's `test-cmd` and terminates immediately.
2. **Process Token Ownership:** The human developer and the Aider CLI hold the process token and drive the editing loop. Flow executes strictly as a subprocess invoked by Aider's test runner.
3. **Zero Tool Interposition:** Flow does not monkey-patch, proxy, or intercept Aider's git or model communications. Gates are evaluated by inspecting filesystem artifacts (`flow/`, `cards/`, `manifest-hashes.json`) and running real verification commands.
4. **Deterministic Shell Contract:** All checks execute via `bash skills/flow/runner/flow.sh check <card>` or `flow.sh status`, returning unambiguous integer exit codes ($0$ for pass, $1$ for failure).
5. **Stateless On-Disk Storage:** All state transitions are captured in Git commits and verified filesystem files, requiring zero volatile in-memory caching.

### 1.3 Architectural Classification: Why Category C (Automated Test Gate Hook) and Not Category A or B?
Understanding Aider's classification requires examining how it differs from other harness categories:
1. **Why Not Category A (Native Skill Target)?**
   - Category A harnesses natively scan for and discover directory-based skill bundles containing `SKILL.md` (e.g., Claude Code reading `~/.claude/skills/flow`, Codex reading `~/.codex/skills/flow`, or Zed reading `~/.agents/skills/flow`).
   - Aider does **not** implement directory-based skill discovery. It does not parse or execute `SKILL.md` tool bundles. Advertising Aider as a native skill target would be an illusion trap.
2. **Why Not Category B (Workspace Rule Scaffolding)?**
   - Category B harnesses (such as Cursor with `.cursor/rules/flow.mdc`, Windsurf with `.windsurf/rules/flow.md`, or Roo Code with `.roomodes`) are autonomous chat/agent environments where natural language prompt instructions are injected into the model's system context to persuade the agent to invoke tools.
   - While Aider can accept instruction files (via `--read CONVENTIONS.md`), its primary enforcement mechanism in Flow is **mechanical rather than conversational**. Flow hooks directly into Aider's automated testing loop (`test-cmd`).
3. **The Category C Standard:**
   - Category C encompasses harnesses that provide deterministic, non-agentic automated test/execution hooks. Flow binds directly to Aider's `test-cmd`, converting card checklists and gates into automated build-test gates that run after every code modification.

---

## Section 2: Phase 1 & 2 Technical Probing: Execution Model & Architecture

### 2.1 Phase 1: Market Intelligence & Prioritization
- **Market Share & Developer Adoption (Qualitative Adoption Hypothesis):** Aider is one of the most prominent open-source CLI coding assistants, with tens of thousands of GitHub stars, active releases, and an enthusiastic developer following among terminal-centric programmers, DevOps engineers, and CLI enthusiasts.
- **Agentic Autonomy & Capability:** Aider is explicitly architected as an **interactive pair programming assistant**, not an unprompted, long-horizon autonomous agent. It excels at applying diffs, refactoring code, and auto-committing git changes based on human prompts. It does **not** run an unprompted multi-turn planning loop across stages (`00-idea` to `05-contract`) without direct developer steering.
- **Ecosystem Openness & Stability:** Aider is fully open-source under the Apache-2.0 license. Its configuration is cleanly defined in `.aider.conf.yml` using standard YAML, with well-documented CLI options and transparent git integration.
- **Priority Tier Score (Provisional Internal Estimate (Desk Intake)):**
  - **Score Classification:** `Provisional Internal Estimates (Desk Intake)`
  - **3-Dimension Breakdown per `docs/harness-qualification-process.md` §1.1:**
    1. **Market Share & Developer Adoption (40 Points Max):** **26/40**. Strong mindshare and adoption among terminal and CLI power users; smaller overall footprint than mainstream visual IDEs (VS Code, Cursor).
    2. **Agentic Autonomy & Capability (40 Points Max):** **22/40**. Excellent interactive pair-programming code editing, git integration, and test-driven self-correction loop, but fundamentally lacks an autonomous multi-stage planning loop.
    3. **Ecosystem Openness & Stability (20 Points Max):** **20/20**. 100% open-source (Apache-2.0), transparent codebase, publicly documented YAML configuration options, and predictable CLI execution behavior.
    - **Total Score:** **68/100** -> Priority Tier 2 (Evaluated / Scaffolding Target, range 50–74).

### 2.2 Phase 2: Architecture Probing

#### 2.2.1 Aider Architecture & Pair-Programming Execution Loop
Aider's architecture is built around terminal interactivity and Git:
1. **Interactive Chat Loop:** The developer enters commands or prompts in the Aider terminal UI.
2. **Repository Map (`repo_map.py`):** Aider analyzes repository symbols using tree-sitter or AST tags to inject high-relevance code context into the prompt (a technique Flow draws inspiration from in its own `skills/flow/harness/repo_map.py`).
3. **File Editing & Git Commits:** When the model proposes changes, Aider applies the diff directly to the working tree. By default, if tests pass, Aider automatically commits the changes to Git with a descriptive commit message.
4. **Auto-Test Loop (`auto-test: true`):** Immediately after applying edits, Aider executes the command specified by `test-cmd`. If the command exits with a non-zero exit code ($1$), Aider captures the failure output, injects it back into the conversation context, and prompts the model to repair the code.

#### 2.2.2 Scaffolding Specification: `.aider.conf.yml`
Flow materializes `.aider.conf.yml` via `flow rules aider --write`. The template matches the implementation tested in `tests/test_flow_rules.sh` verbatim:

```yaml
# Aider configuration for Flow discipline layer
test-cmd: "bash -c 'cid=$(tr -d \" \\r\\n\" < cards/.inflight 2>/dev/null); if [[ \"$cid\" =~ ^C-[0-9]+$ ]]; then bash skills/flow/runner/flow.sh check \"$cid\"; else bash skills/flow/runner/flow.sh status; fi'"
auto-test: true
```

#### 2.2.3 Analysis of `test-cmd` Mechanics & Sanitization
The command string is engineered to provide robust, fail-safe test hook integration:
1. **In-Flight Card Extraction:**
   ```bash
   cid=$(tr -d " \r\n" < cards/.inflight 2>/dev/null)
   ```
   Reads the active card ID from `cards/.inflight`, stripping trailing whitespace, carriage returns, and newlines. If `cards/.inflight` does not exist, stderr is redirected to `/dev/null` and `$cid` evaluates to an empty string.
2. **Strict Regex Validation (Anti-Injection Hardening):**
   ```bash
   if [[ "$cid" =~ ^C-[0-9]+$ ]]
   ```
   Ensures `$cid` strictly matches the canonical Flow card ID format (`C-` followed by one or more digits). If a malicious or malformed payload is present in `cards/.inflight` (e.g., `C-001; touch /tmp/pwned`), the regex rejects it immediately.
3. **Conditional Execution Branching:**
   - **Active Card Branch:** When a valid card ID is detected, Aider executes `bash skills/flow/runner/flow.sh check "$cid"`. This runs the full suite of card verification checks (`## Allowed files`, `## Verify` commands, and checklist item completion).
   - **Fallback Branch:** When no card is active (or if `cards/.inflight` contains invalid data), Aider falls back to `bash skills/flow/runner/flow.sh status`, which inspects repository stage gates without failing the test run.
4. **Automatic Test Trigger:**
   `auto-test: true` instructs Aider to execute `test-cmd` automatically after every file edit without requiring the human operator to manually type `/test`.

#### 2.2.4 The Intentional Removal of `lint-cmd` & Script Assumptions
In earlier exploration, consideration was given to configuring Aider's `lint-cmd` option. However, Flow's design discipline strictly removed `lint-cmd` from `.aider.conf.yml`:
- **The Internal Script Assumption Trap:** Setting `lint-cmd: "bash scripts/check-doc-budgets.sh"` assumes that every repository using Flow possesses Flow's internal development scripts. When an external consumer repository uses Flow, `scripts/check-doc-budgets.sh` does not exist, causing Aider to fail on every `/lint` call with `ENOENT`.
- **Clean Boundary:** Flow does not assume external repositories have specific linters. Repository-specific linting belongs in the project's own CI or card `## Verify` sections, not in Flow's generic harness scaffolding.

#### 2.2.5 Context & Token Budgeting
- `.aider.conf.yml` lives outside the prompt context; it acts purely as CLI configuration and consumes **0 tokens** from the model's context window.
- If optional workspace instructions are supplied (e.g., via `CONVENTIONS.md`), they follow Flow's standard doc-budgeting principles, remaining under 500 words.

---

## Section 3: Latent Bug Analysis & Failure Modes

### 3.1 Latent Trap 1: The Autonomous Loop Illusion (Pair Programmer vs. Autonomous DAG Planner)
- **The Failure Mode:**
  - An over-eager developer or marketing claim proclaims: *"Flow turns Aider into a fully autonomous software engineering agent that drives your project from Idea to PRD to Implementation!"*
  - In practice, Aider is an **interactive pair programmer**. It does not maintain an autonomous multi-stage planning loop. It does not independently navigate stage DAGs (`00-idea` -> `01-research` -> `02-scope` -> `03-prd` -> `04-arch` -> `05-contract`).
  - Attempting to run Aider unattended on high-level lifecycle planning leads to confusion, stalled sessions, or superficial text generation without human validation.
- **The Anti-Illusion Mitigation:**
  - Flow's documentation and harness survey explicitly disclose Aider as an **interactive pair programming tool (Category C)**.
  - Flow's stage progression (`00-idea` through `05-contract`) requires interactive developer participation. Aider's role is focused on implementing specific code modifications for active cards (`cards/C-NNN.md`) while `test-cmd` ensures mechanical gate compliance.

### 3.2 Latent Trap 2: Command Injection Trap in `cards/.inflight`
- **The Failure Mode:**
  - An earlier, naive implementation of `test-cmd` might have read `cards/.inflight` directly via command substitution:
    ```bash
    # VULNERABLE PATTERN:
    bash skills/flow/runner/flow.sh check $(cat cards/.inflight)
    ```
  - If `cards/.inflight` contained unvalidated input or hostile commands (e.g., `C-001; rm -rf /`), subshell evaluation would execute the injected payload with host permissions.
- **The Anti-Illusion Mitigation:**
  - Flow hardened the `test-cmd` scaffold (validated in `tests/test_flow_rules.sh` section D):
    1. Whitespace and newlines are sanitized: `cid=$(tr -d " \r\n" < cards/.inflight 2>/dev/null)`.
    2. Input is strictly checked against the regex `^C-[0-9]+$`.
    3. Any string failing this pattern is rejected, safely falling back to `flow status`.
  - In automated test suite runs, a hostile injection probe (`C-001; touch /tmp/marker`) is proven to execute safely without creating the marker file.

### 3.3 Latent Trap 3: The Internal Script Assumption Trap (`lint-cmd` & `check-doc-budgets.sh`)
- **The Failure Mode:**
  - Scaffolding generators that hardcode project-internal scripts (e.g., `check-doc-budgets.sh` or `pack-rehearsal.sh`) into consumer configs cause severe friction when deployed into real-world projects.
  - When Aider attempts to run `lint-cmd`, it crashes with `scripts/check-doc-budgets.sh: No such file or directory`.
- **The Anti-Illusion Mitigation:**
  - Flow's `rules aider` template strictly confines `test-cmd` to Flow's vendored runner (`skills/flow/runner/flow.sh`), which is guaranteed to exist in Flow-managed repositories.
  - `lint-cmd` is intentionally omitted from `.aider.conf.yml` to prevent spurious failures in downstream projects.

### 3.4 Latent Trap 4: Subshell Execution & Windows Path Mapping
- **The Failure Mode:**
  - On Windows systems, Aider may invoke `test-cmd` through `cmd.exe` or PowerShell. If `bash` resolves to WSL (`C:\Windows\System32\bash.exe`) instead of Git Bash, Windows drive paths may fail to map, causing `skills/flow/runner/flow.sh` to fail with path errors.
- **The Anti-Illusion Mitigation:**
  - On Windows host systems, developers can adapt `test-cmd` to utilize Flow's native Windows batch runner (`skills\flow\runner\flow.cmd check ...`).
  - Documentation clearly notes the distinction between POSIX bash environments and Windows cmd/PowerShell execution.

---

## Section 4: Live Verification Runbook Checklist

This runbook specifies the step-by-step procedure for executing the **Four-Point Live Verification Protocol** adapted for Aider's pair-programming test hook invocation.

### 4.0 Interactive Pair Programming Qualification Invariant
Aider operates as an interactive terminal pair programmer. Qualification requires an active terminal session running Aider:
1. The evaluating engineer must clone the test repository and launch Aider in a genuine terminal shell (`aider`).
2. A unique trial run nonce (e.g., `nonce-aider-20261014-<uuid>`) must be generated and embedded in the test transcript.
3. Raw terminal transcripts, auto-test execution logs, git commit hashes, and exit codes must be captured and committed to `plans/research/harness-expansion/evidence/aider-<version>-qualification-record.md`.

### 4.1 Pre-Verification Environment Provisioning

1. **Clean Worktree Isolation:**
   ```bash
   git clone <repo-url> /tmp/flow-aider-eval
   cd /tmp/flow-aider-eval
   git checkout -b test/aider-qualification
   ```
2. **Generate Scaffolding:**
   ```bash
   # Materialize .aider.conf.yml
   bash skills/flow/runner/flow.sh rules aider --write
   # Verify creation and contents
   test -f .aider.conf.yml && echo ".aider.conf.yml present."
   grep -q "auto-test: true" .aider.conf.yml && echo "auto-test enabled."
   ```
3. **Verify Runner Permissions:**
   ```bash
   chmod +x skills/flow/runner/flow.sh
   ```
4. **Provision Test Card:**
   ```bash
   # Set up a test card in cards/
   mkdir -p cards
   echo "C-001" > cards/.inflight
   ```
5. **Launch Aider Session:**
   - Launch Aider: `aider`
   - Record environment metadata:
     - Aider Version: `[Capture from aider --version, e.g., 0.58.0]`
     - Underlying Model Identifier: `[e.g., Claude 3.7 Sonnet, GPT-4o]`
     - Operating System: `[e.g., Linux x64 / macOS arm64]`
     - Active Nonce: `[e.g., nonce-aider-20261014-a1d2e3]`

---

### 4.2 Four-Point Live Verification Protocol Execution

#### Gate 1: Ingestion Audit (Configuration & Hook Discovery)
- **Objective:** Verify Aider ingests `.aider.conf.yml` cleanly, recognizes `auto-test: true`, and loads the configured `test-cmd` without YAML parsing errors.
- **Test Input:** In the active Aider terminal, run:
  ```text
  /test
  ```
- **Evaluation Criteria:**
  - [ ] Aider executes the configured `test-cmd` without YAML syntax errors.
  - [ ] Because `cards/.inflight` contains `C-001`, Aider evaluates `flow.sh check C-001`.
  - [ ] Terminal output confirms Flow runner executed cleanly.
- **Empty Capture Placeholder:**
  ```text
  [RAW AIDER INGESTION & /TEST EXECUTION CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 2: Invocation Audit (Auto-Test Hook Execution Fidelity)
- **Objective:** Verify that when code edits are applied in response to a prompt, Aider automatically invokes `test-cmd` via `auto-test: true` and parses the returned exit code.
- **Test Input (Pair Prompt in Aider):**
  ```text
  Update the implementation file listed in cards/C-001.md to satisfy the card's requirements.
  ```
- **Evaluation Criteria:**
  - [ ] Aider applies the file diff to the repository.
  - [ ] Immediately upon applying the diff, Aider automatically runs `test-cmd`.
  - [ ] The command evaluates `cards/.inflight` and runs `bash skills/flow/runner/flow.sh check C-001`.
  - [ ] Aider displays test execution output in the terminal session.
- **Empty Capture Placeholder:**
  ```text
  [RAW AUTO-TEST INVOCATION CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 3: Gate-Stop Audit (Forced-Failure Kill-Honesty Test)
- **Objective:** Empirically prove that when `flow.sh check` exits with non-zero status ($\text{exit} \neq 0$) due to an invalid card state or failing verify command, Aider recognizes it as a test failure, halts git auto-commit, and enters the self-correction loop.
- **Test Setup:**
  - Install a broken card fixture or ensure `flow.sh check C-001` fails (e.g., unfilled `[FILL]` marker or unchecked box in `cards/C-001.md`).
- **Test Input:**
  ```text
  Attempt to finalize the card and commit the changes.
  ```
- **Evaluation Criteria:**
  - [ ] Auto-test triggers `flow.sh check C-001`.
  - [ ] Flow runner exits with code `1` and prints failure diagnostic (e.g., open checklist items).
  - [ ] **MANDATORY GATE-STOP:** Aider detects non-zero exit code and treats it as a failed test suite.
  - [ ] Aider strictly **REFUSES** to auto-commit the broken changes to Git.
  - [ ] Aider presents the test failure to the model and proposes self-correction.
  - *(Note: If Aider auto-commits the changes or claims the check passed despite exit code 1, the candidate is immediately marked **DISQUALIFIED**).*
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE-STOP AUTO-TEST FAILURE & COMMIT HALT CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

#### Gate 4: State Integrity Audit (Verified Card Passage & Git Persistence)
- **Objective:** Verify that when card checks genuinely pass (`flow.sh check C-001` returns code `0`), Aider automatically commits the verified changes to Git, preserves state on disk, and fresh sessions read back accurate status.
- **Test Setup:**
  - Satisfy all verification commands and check all boxes in `cards/C-001.md`.
- **Test Input:**
  ```text
  Re-run the test to verify card completion.
  ```
- **Evaluation Criteria:**
  - [ ] `test-cmd` executes and `flow.sh check C-001` exits with code `0`.
  - [ ] Aider acknowledges that all tests passed.
  - [ ] Aider creates an authenticated Git commit with a clean commit message.
  - [ ] Exit Aider (`/exit`) and launch a fresh session (`aider`).
  - [ ] Run `/test` or status check; fresh session confirms the card is verified and repository state is intact.
  - [ ] Zero resident daemons were required to maintain state between sessions.
- **Empty Capture Placeholder:**
  ```text
  [RAW GATE 4 PASSAGE, GIT COMMIT & FRESH SESSION READBACK CAPTURE]
  ```
- **Verdict:** `[UNVERIFIED / PASS / FAIL]`

---

### 4.3 Qualification Record Archival
Upon completion of the live verification trial:
1. Capture all raw terminal transcripts, auto-test execution logs, git commit hashes, and exit codes.
2. Complete the standardized qualification record using `plans/research/harness-expansion/evidence/template-qualification-record.md`.
3. Save and commit the record to:
   ```text
   plans/research/harness-expansion/evidence/aider-<version>-qualification-record.md
   ```
4. If and only if all four gates pass, update `plans/research/harness-expansion/architecture-compatibility-matrix.md` to transition Aider from `PROVISIONAL CANDIDATE` to `VERIFIED LIVE SUPPORT (Category C)`.
