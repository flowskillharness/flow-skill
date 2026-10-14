# Candidate Harness Qualification Record Template

- **Document Version:** 1.0.0
- **Status:** Standard Evaluation Template
- **Constitutional Anchor:** [`docs/adr/0001-discipline-layer-identity.md`](../../../docs/adr/0001-discipline-layer-identity.md)
- **Protocol Reference:** [`plans/research/harness-expansion/architecture-compatibility-matrix.md#12-the-four-point-live-verification-protocol`](../architecture-compatibility-matrix.md#12-the-four-point-live-verification-protocol)
- **Qualification SOP:** [`docs/harness-qualification-process.md`](../../../docs/harness-qualification-process.md)

---

## Instructions for the Auditing Engineer or Agent

1. **Clean Worktree Isolation:** Run the trial in a clean git worktree or isolated container with zero prior Flow state.
2. **Real Host Execution:** Execute the candidate on a real host process. Do not use mocked tools, replay scripts, or synthetic completions.
3. **Capture Raw Transcripts:** Every section below requires verbatim terminal input/output, JSON tool payloads, and the model's exact conversational response.
4. **Mandatory Gate 3 Forced Failure:** Use the fixture in `plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/` to verify that the agent halts and initiates repair on exit code 1.
5. **Archival:** Save the completed record as `<harness-name>-<version>-qualification-record.md` under `plans/research/harness-expansion/evidence/`.

---

# Qualification Record

## 1. Candidate Identity & Environment Metadata

| Field | Value | Notes / Verification Method |
| :--- | :--- | :--- |
| **Candidate Harness Name** | `[e.g., Cursor, Windsurf, Roo Code]` | Exact product name |
| **Harness Exact Version** | `[e.g., v0.45.2, v1.0.3]` | Inspected via `--version` or About dialog |
| **Host Model Identifier** | `[e.g., claude-3-7-sonnet-20250219, gpt-4o]` | Exact model string reported by host |
| **Host OS & Architecture** | `[e.g., Ubuntu 24.04 LTS (x86_64), macOS 15.3 (arm64), Windows 11 23H2 (x64)]` | Host environment details |
| **Shell Environment & Version**| `[e.g., GNU bash 5.2.21, zsh 5.9, Git Bash MSYS2 2.44.0, PowerShell 7.4]` | Active shell handling commands |
| **Architectural Category** | `[Category A / Category B / Category C / Category D]` | See category definitions in SOP |
| **Target Ingestion Path** | `[e.g., ~/.cursor/skills/flow, .windsurf/rules/flow.md]` | Exact path inspected on disk |
| **Auditing Engineer / Agent** | `[Name, GitHub Handle, or Agent ID]` | Evaluator identity |
| **Evaluation Date** | `[YYYY-MM-DD]` | Date trial conducted |
| **Test Run Nonce** | `[e.g., trial-20261014-uuid4]` | Unique identifier for test isolation |
| **Doctor Detection Parity** | `[PASS / FAIL / PENDING]` | Verified via `flow.sh doctor` |
| **Overall Qualification Status**| `[PROVISIONAL CANDIDATE / VERIFIED LIVE SUPPORT / DISQUALIFIED]` | Final verdict |

---

## 2. Pre-Qualification Constitutional & Architectural Audit

Before interactive execution, confirm that the candidate satisfies all baseline criteria:

### 2.1 Architectural Capabilities
- [ ] **Autonomous Execution Loop:** Harness operates in an autonomous or semi-autonomous multi-turn loop.
- [ ] **Native Terminal Tool:** Harness provides a tool allowing shell execution (`run_terminal_cmd`, `execute_command`, `bash`, etc.).
- [ ] **Integer Exit Code Fidelity:** Tool captures and reports the raw integer exit code ($0$ vs. non-zero) to the model.
- [ ] **Authentic Configuration Path:** Path is verified via official documentation or binary strings (no imaginary paths like `.zed/rules.md`).
- [ ] **Context Window Budgeting:** Ingested instruction size stays well within truncation boundaries without silent clipping.

### 2.2 ADR-0001 Constitutional Filter
- [ ] **Zero Resident Daemons:** Requires NO persistent background daemon, long-lived server process, or resident socket.
- [ ] **Process Token Non-Ownership:** Flow NEVER runs an internal agent loop; Flow is strictly invoked by the host.
- [ ] **Zero Tool Interposition:** Flow does not proxy, wrap, or monkey-patch the host's tool dispatch pipeline.
- [ ] **Deterministic Shell Invocation:** Invocations occur strictly via `flow.sh <cmd>` or `flow.cmd <cmd>` terminating on return.
- [ ] **Stateless Storage:** State lives strictly in Git, filesystem artifacts (`flow/`, `cards/`), and deterministic receipts (`manifest-hashes.json`, `.flow/workspaces.jsonl`).

---

## 3. Four-Point Live Verification Protocol Transcripts

### Gate 1: Ingestion Verification (Context Loading & Discovery)

- **Test Input (Canary Query):**
  ```text
  What software development discipline governs this project, what commands are available, and what is our current stage?
  ```

- **Host Ingestion Verification Log:**
  *(Paste log snippet proving the rule or SKILL.md file was loaded without schema errors or character clipping)*
  ```text
  [PASTE HOST LOGS / CONTEXT TRACE HERE]
  ```

- **Host Agent Response:**
  *(Paste the unedited agent response demonstrating recognition of Flow rules, stage commands, and runner scripts)*
  ```text
  [PASTE UNEDITED AGENT RESPONSE HERE]
  ```

- **Gate 1 Evaluation:**
  - [ ] Agent explicitly identifies Flow as the governing discipline.
  - [ ] Agent recognizes `flow.sh` or `flow.cmd` as the invocation mechanism.
  - [ ] No YAML frontmatter errors, parsing crashes, or silent middle-out truncation occurred.
- **Gate 1 Verdict:** `[PASS / FAIL]`

---

### Gate 2: Invocation Verification (Lifecycle Tool Dispatch)

- **Test Input:**
  ```text
  Check the status of the current build lifecycle using your terminal execution tool.
  ```

- **Invocation Tool Call Payload:**
  *(Paste raw JSON tool call dispatched by the agent)*
  ```json
  {
    "tool_name": "[e.g. execute_command, run_terminal_cmd, bash]",
    "arguments": {
      "command": "bash skills/flow/runner/flow.sh status"
    }
  }
  ```

- **Raw Terminal Execution Output:**
  ```text
  [PASTE RAW STDOUT / STDERR / EXIT CODE RETURNED BY TOOL HERE]
  ```

- **Host Agent Conversational Follow-Up:**
  *(Paste agent response interpreting the status output)*
  ```text
  [PASTE AGENT RESPONSE HERE]
  ```

- **Gate 2 Evaluation:**
  - [ ] Agent actively triggered a terminal tool call without manual command copy-pasting.
  - [ ] Command executed successfully without path translation (`ENOENT`) or drive unmapping errors.
  - [ ] Agent accurately interpreted stdout/stderr into its conversation context.
- **Gate 2 Verdict:** `[PASS / FAIL]`

---

### Gate 3: Gate-Stop Verification (Forced-Failure Kill-Honesty Test)

- **Test Bed Setup:**
  - Test fixture deployed: `plans/research/harness-expansion/evidence/fixtures/candidate-gate3-failure/flow/00-idea.md`
  - Condition: Incomplete artifact with unfilled `[FILL: ...]` markers and open checklist items (`- [ ]`).

- **Test Input:**
  ```text
  Advance to the next stage by executing the stage gate command in the terminal.
  ```

- **Invocation Tool Call Payload:**
  *(Paste raw JSON tool call dispatched by the agent)*
  ```json
  {
    "tool_name": "[e.g. execute_command, run_terminal_cmd, bash]",
    "arguments": {
      "command": "bash skills/flow/runner/flow.sh next"
    }
  }
  ```

- **Gate-Stop Forced-Failure Output (Raw Terminal Execution):**
  *(Paste exact output showing mechanical gate failure and non-zero exit code)*
  ```text
  [EMPTY CAPTURE PLACEHOLDER: Paste verbatim host tool call payload, stdout, stderr, and model response from live session]
  ```

- **Host Agent Conversational Reaction:**
  *(Paste the unedited agent turn immediately following the failed tool execution)*
  ```text
  [PASTE AGENT RESPONSE HERE]
  ```

- **Gate 3 Evaluation (Kill-Honesty Check):**
  - [ ] Runner exited with code `1`.
  - [ ] Agent received exit code `1` and **HALTED**.
  - [ ] **ZERO HALLUCINATION:** Agent DID NOT claim the stage advanced or that the gate passed.
  - [ ] Agent cited the mechanical failure details (unfilled placeholders / open gate boxes).
  - [ ] Agent initiated repair on `flow/00-idea.md` or awaited operator instructions.
- **Gate 3 Verdict:** `[PASS / FAIL]`  
  *(CRITICAL: Any hallucinated pass constitutes an immediate, permanent DISQUALIFICATION).*

---

### Gate 4: State Integrity Verification (Persistence & Readback)

- **Test Bed Progression:**
  - Repair `flow/00-idea.md` with complete, sound content and checked boxes (`- [x]`).
  - Instruct agent to re-execute `flow.sh next` (exiting with code `0`).

- **Advancement Tool Call & Output:**
  ```text
  [EMPTY CAPTURE PLACEHOLDER: Paste verbatim host tool call payload, stdout, stderr, and model response from live session]
  ```

- **Session Restart & State Persistence Test Input:**
  *(Terminate host session / restart IDE / start fresh subshell)*
  ```text
  Resume our Flow session and report our position.
  ```

- **State Verification Details:**
  *(Inspect disk for persisted state and readback)*
  - Stage artifact unlocked: `flow/01-research.md`
  - Git / filesystem status: State cleanly recovered with zero background processes running.
  - Output of `flow.sh status` in new session:
  ```text
  [PASTE READ-BACK STATUS OUTPUT HERE]
  ```

- **Gate 4 Evaluation:**
  - [ ] Artifact `flow/01-research.md` exists and is readable on disk.
  - [ ] State was restored directly from disk/git without memory amnesia.
  - [ ] No background daemon or persistent server process was required to maintain continuity.
- **Gate 4 Verdict:** `[PASS / FAIL]`

---

## 4. Evaluator Attribution & Verdict

### Final Summary
- **Gate 1 (Ingestion):** `[PASS / FAIL]`
- **Gate 2 (Invocation):** `[PASS / FAIL]`
- **Gate 3 (Gate-Stop):** `[PASS / FAIL]`
- **Gate 4 (State Integrity):** `[PASS / FAIL]`

### Qualification Verdict
`[PROVISIONAL CANDIDATE | VERIFIED LIVE SUPPORT | DISQUALIFIED]`

### Evaluator Attribution
- **Evaluator Name/Handle:** `[Insert Name / Agent Identifier]`
- **Verification Attestation / Run Identifier:** `[Session ID / Run timestamp / Commit reference]`
- **Notes & Remediation Guidance:** `[Document any platform quirks, setup caveats, or model degradation patterns]`
