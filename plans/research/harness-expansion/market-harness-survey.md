# Market Harness Survey: Expanding Flow to Leading Coding-Agent Harnesses

- **Status:** Research Deliverable (Provisional Candidate Architecture Evaluation)
- **Date:** 2026-10-14
- **Author:** Flow Architecture Research Team
- **Target File:** `plans/research/harness-expansion/market-harness-survey.md`
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Flow Discipline Layer Identity)

---

## 1. Executive Summary & Core Mandate

### 1.1 Context & The Non-Negotiable Constraint
The user requirement sets a strict standard for expanding Flow's compatibility across market harnesses:
> *"Cần có quy trình nghiên cứu các harness phổ biến trên thị trường để hỗ trợ từ đó mới đáp ứng được người dùng để họ sẵn sàng sử dụng sản phẩm khi thấy nền tảng tương thích với harness họ đang sử dụng. Cần lưu ý triển khai phải chắc chắn support thật tránh quảng cáo có mà không hỗ trợ hoặc lỗi tiềm ẩn."*

Flow's identity is defined by its constitution (`docs/adr/0001-discipline-layer-identity.md`):
- **Flow is a DISCIPLINE LAYER**, not an agent runtime. It orchestrates the lifecycle:
  `Idea -> Research -> Scope -> PRD -> ADR -> Contract -> Cards -> Build -> Review -> Deploy/Ship -> Verify-live -> Retro`.
- **Flow owns the gates and the receipts, never the runtime.** Flow never holds the process token.
- **Mechanically forbidden:** Daemons, resident background processes, servers, owned agent loops, and tool-execution wrappers/interposition.
- **The Invariant:** Every flow byte executes because a hosting agent or human operator invoked it (`bash skills/flow/runner/flow.sh <cmd>` or `<skill-dir>\runner\flow.cmd <cmd>` on Windows), and Flow terminates when that invocation returns.

### 1.2 "Support Thật" (Honest Support) vs. "Illusion" (Marketing Theater)
In the AI tooling ecosystem, many tools claim "universal compatibility" by simply dropping an empty or superficial prompt file into a repository, regardless of whether the target agent can actually execute the underlying tools or enforce contracts.

| Dimension | "Support Thật" (Honest Support) | "Illusion" (Marketing Theater) |
| :--- | :--- | :--- |
| **Mechanical Enforcement** | The host agent actively invokes `runner/flow.sh <command>`, parses stdout and exit codes, and **halts** when a gate fails (exit $\neq 0$). | The harness is given a prompt telling it to "follow Flow", but the agent lacks bash execution tools or ignores exit codes, hallucinating that gates passed. |
| **Context Hygiene** | Instructions are scoped, under token/character limits, and injected at the right lifecycle moments (via frontmatter globs or active modes). | A massive 20,000-token prompt is dumped into a single global file, causing the host model to silently truncate or ignore rules due to context limits. |
| **Runtime Portability** | Global vs. project-level boundaries are respected; containerized environments (Docker/sandboxes) have local binaries rather than unreachable host paths. | Claiming global support (`~/.claude/skills/...`) in containerized or remote runners (e.g., OpenHands, GitHub Codespaces) where host paths fail with `ENOENT`. |
| **Shell Awareness** | Explicitly accounts for OS differences (POSIX bash vs. Windows Git Bash via `flow.cmd`). | Blindly injecting `bash .../runner/flow.sh` on Windows cmd/PowerShell where `bash` resolves to WSL with unmapped drive paths. |

### 1.3 Feasibility Tier Classification
- **Tier 1 (High Priority — Native Architecture Fit):** Harness natively possesses clean file placement (global skills or project rule hooks) AND autonomous/semi-autonomous terminal tool execution. The agent can run `flow.sh` directly.
- **Tier 2 (Medium Priority — Workspace Rule Scaffolding):** Harness operates primarily via project-level configuration (`.windsurf/rules/`, `.roomodes`, `.aider.conf.yml`, `.github/copilot-instructions.md`) and can execute commands when operating in agent mode or paired with terminal hooks.
- **Tier 3 (Incompatible or Deferred):** Harness lacks terminal execution capability, requires a persistent background daemon/server (forbidden by ADR 0001), or only supports conversational chat with no tool invocation.

> **Empirical Support Mandate:** All tier assignments reflect architectural capability and market research priority. In accordance with Flow's Anti-Illusion Protocol (ADR-0001, SOP §4), no candidate is designated as "Verified Supported" until it successfully completes the Four-Point Live Verification Protocol on a running host runtime.

---

## 2. Comprehensive Candidate Investigations

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                MARKET HARNESS SPECTRUM                                                │
├─────────────────────────────────────┬──────────────────────────────────────────────┬──────────────────────────────────┤
│ TIER 1: Priority Native Fit         │ TIER 2: Project Rule Fit                     │ TIER 3: Deferred / Constrained   │
├─────────────────────────────────────┼──────────────────────────────────────────────┼──────────────────────────────────┤
│ • Cursor (Native ~/.cursor/skills)  │ • Roo Code (.roomodes)                       │ • GitHub Copilot CLI (Unassessed query utility)   │
│ • Zed Agent (~/.agents/skills)      │ • Windsurf (Cascade)                         │ • Zed Inline Editor (no bash)    │
│ • Trae (Dual Category A Native Skills & Category B Agent Mode Scaffold) │ • Cline (.clinerules)                        │ • Amazon Q CLI (Historical query utility; successor capability unassessed)         │
│                                     │ • Aider (Test Hook)                          │                                  │
│                                     │ • OpenHands (Docker)                         │                                  │
│                                     │ • Copilot VSCode Agent                       │                                  │
│                                     │ • Goose (.goosehints)                        │                                  │
│                                     │ • Amazon Q Developer (/dev) (Proposed design)│                                  │
│                                     │ • Devin (DEVIN.md / Cloud Sandbox)           │                                  │
│                                     │ • SWE-agent (Docker / ACI)                   │ • GitLab Duo Chat (Historical query utility; unassessed)          │
│                                     │ • GitLab Duo Workflow (Proposed design)      │                                                  │
│                                     │ • Sourcegraph Cody (Proposed IDE Scaffold)   │                                                  │
│                                     │ • Augment Code (Proposed IDE Scaffold)       │ • Tabnine Inline (Completions only)              │
│                                     │ • Tabnine (Proposed Chat Scaffold)           │                                                  │
│                                     │ • Plandex (Proposed CLI / Sandboxed Plan Scaffold)│                                                  │
└─────────────────────────────────────┴──────────────────────────────────────────────┴──────────────────────────────────┘
```

---

### Candidate 1: Cursor

#### 1. System Overview & Harness Architecture
Cursor (by Anysphere) is a leading AI-first code editor forked from VS Code. Its core agentic capabilities reside in **Cursor Composer** (specifically "Agent Mode"), which can inspect files, create diffs, and execute terminal commands.

#### 2. Extension & Integration Mechanism
- **Global Integration:**
  - Modern Cursor (v0.40+) supports the open Agent Skills standard via `~/.cursor/skills/` (and universal `~/.agents/skills/`).
  - Already recognized in Flow's `npm-wrapper/src/constants.mjs` target list.
- **Project-Level Integration:**
  - **Modern Standard (Cursor 0.42+ / 0.45+):** `.cursor/rules/*.mdc` files.
    - MDC format is Markdown with YAML frontmatter.
    - **Frontmatter Schema:**
      ```yaml
      ---
      description: "Enforce Flow gated build discipline and runner verification"
      globs: "flow/**,cards/**,*.md,src/**"
      alwaysApply: false
      ---
      ```
    - `alwaysApply: false` ensures the discipline rules are scoped specifically to the declared globs without becoming an unintended always-on global prompt.
  - **Legacy Standard:** `.cursorrules` located at the workspace root. Treated as plain markdown and appended to system instructions.

#### 3. Execution Capability & Terminal Autonomy
- Cursor Composer in **Agent Mode** possesses the `run_terminal_cmd` tool.
- **Autonomy Settings:**
  - Normal mode: Prompts operator with a "Run command" confirmation dialog.
  - Auto-run mode ("YOLO mode"): Executes commands autonomously, capturing exit codes and streaming stdout/stderr into the model's context window.
- Can run: `bash <skill-dir>/runner/flow.sh <command>` or `<skill-dir>\runner\flow.cmd <command>` on Windows.

#### 4. Detection Heuristics
- **Global Markers:**
  - Linux: `~/.cursor/skills` (presence of skills dir) or binary `cursor` in `PATH`.
  - macOS: `~/Library/Application Support/Cursor` or `~/.cursor/skills`.
  - Windows: `%APPDATA%\Cursor` or `%USERPROFILE%\.cursor\skills`.
  - *False Positive Guard:* Bare `~/.cursor` exists for all Cursor editor users (cache, telemetry, argv.json). Detection MUST check for `.cursor/skills` or check project-level markers to avoid installing unrequested skills under `--yes`.
- **Project Markers:**
  - `.cursor/rules/` directory or `.cursorrules` file at workspace root.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Global skill in `~/.cursor/skills/flow/SKILL.md` (or project rule `.cursor/rules/flow.mdc` with `alwaysApply: false`).
  - Rule explicitly instructs Composer Agent: *"Before creating or modifying code, run `bash runner/flow.sh status` and `bash runner/flow.sh check`. When working on card C-NNN, verify gate exit codes. An exit code $\neq 0$ is a strict STOP."*
  - Tested in Composer Agent mode with terminal auto-run enabled.
- **The Marketing Illusion to Avoid:**
  - Putting a generic `.cursorrules` file in a project where the user only uses basic Cursor Chat (Cmd+L) without Agent mode. In standard Chat, Cursor cannot execute shell commands, leading to hallucinated gate passes.
- **Feasibility Verdict:** **Tier 1 (High-Priority Candidate — Native Architecture Fit; Live Host Trials Pending).**

---

### Candidate 2: Windsurf (Codeium Cascade)

#### 2. System Overview & Harness Architecture
Windsurf is Codeium's AI-native IDE featuring **Cascade**, a multi-step agentic assistant capable of reading files, proposing diffs, and executing shell commands in its integrated workspace terminal.

#### 2. Extension & Integration Mechanism
- **Global Integration:**
  - Cascade Global Rules: `~/.codeium/windsurf/memories/global_rules.md` (or macOS `~/Library/Application Support/Windsurf/rules/*.md`).
  - Windsurf does *not* natively auto-discover arbitrary tool folders in `~/.windsurf/skills/` without explicit rule pointers.
- **Project-Level Integration:**
  - **Modern Standard:** `.windsurf/rules/*.md` (markdown files placed in `.windsurf/rules/` directory).
    - Per-rule character limit: 12,000 characters.
    - Format: Markdown, with optional YAML frontmatter for triggers.
  - **Standard / Legacy:** `.windsurfrules` at workspace root. Cascade automatically loads this file into the system prompt at the beginning of each session.

#### 3. Execution Capability & Terminal Autonomy
- Cascade in **Write / Agent Mode** has native access to the `run_command` tool.
- Cascade can execute arbitrary shell commands, receive standard output/error, and inspect the numeric exit status.
- Cascade can be configured to prompt before execution or auto-execute commands.

#### 4. Detection Heuristics
- **Global Markers:**
  - Linux: `~/.codeium/windsurf`, `~/.config/Windsurf`, or binary `windsurf` in `PATH`.
  - macOS: `~/Library/Application Support/Windsurf` or `~/.codeium`.
  - Windows: `%APPDATA%\Windsurf` or `%USERPROFILE%\.codeium`.
- **Project Markers:**
  - `.windsurfrules` file or `.windsurf/` directory at workspace root.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Flow installer places `.windsurf/rules/flow.md` (or `.windsurfrules`) at the workspace root.
  - The rule file is concise (under 6,000 characters to prevent attention degradation), pointing Cascade to the project runner (`bash skills/flow/runner/flow.sh` or local runner).
  - Cascade executes `flow.sh` via `run_command` to inspect card progress and halts when a gate fails.
- **The Marketing Illusion to Avoid:**
  - Claiming a global `~/.windsurf/skills/flow` installation without an active rule in Cascade. Cascade will never execute a standalone skill directory without a rule telling it where to find it.
  - Exceeding character limits: Dumping Flow's full multi-file documentation into `.windsurfrules` exceeds the 12,000 character limit, causing Cascade to silently truncate or drop project context.
- **Feasibility Verdict:** **Tier 2 (Project-Level Rule Support).**

---

### Candidate 3: Cline / Roo Code

#### 1. System Overview & Harness Architecture
Cline (formerly Claude Dev) and its advanced fork Roo Code are autonomous AI coding agent extensions for VS Code, Cursor, and VSCodium. Roo Code introduces specialized **custom modes** (`.roomodes`), role definitions, and tool group permissions.

#### 2. Extension & Integration Mechanism
- **Cline Standard:**
  - `.clinerules` in workspace root, or modular `.clinerules/*.md`.
  - Injected directly into the system prompt for all tasks.
- **Roo Code Advanced Standard:**
  - `.roomodes` (JSON configuration file at workspace root).
  - Supports declaring a dedicated `flow` mode with custom instructions and assigned tool groups:
    ```json
    {
      "customModes": [
        {
          "slug": "flow",
          "name": "Flow Disciplined Builder",
          "roleDefinition": "You are a disciplined software engineer operating under the Flow Discipline Layer. Every stage and card requires mechanical gate verification via runner/flow.sh.",
          "groups": ["read", "edit", "browser", "command"],
          "customInstructions": "Always execute 'bash runner/flow.sh <command>' before marking cards done or advancing stages. Exit code 0 is mandatory.",
          "fileRegex": "flow/.*|cards/.*"
        }
      ]
    }
    ```
- **MCP Server Support:** Both Cline and Roo Code support MCP (`cline_mcp_settings.json`, `roo_mcp_settings.json`).
  - *Constitutional Note:* Flow explicitly rejects running MCP servers or resident daemons (ADR 0001). Flow integrates strictly via instruction rules and terminal tool calls.

#### 3. Execution Capability & Terminal Autonomy
- Both Cline and Roo Code possess the `execute_command` tool.
- Supports autonomous execution with operator auto-approval checkboxes for commands.
- The agent streams terminal output and strictly inspects exit codes.

#### 4. Detection Heuristics
- **Global Markers:**
  - Extension directories in VS Code / Cursor:
    - `~/.vscode/extensions/saoudrizwan.claude-dev*` (Cline)
    - `~/.vscode/extensions/rooveterinaryinc.roo-cline*` (Roo Code)
  - Global configuration storage:
    - Linux: `~/.config/Code/User/globalStorage/rooveterinaryinc.roo-cline`
    - macOS: `~/Library/Application Support/Code/User/globalStorage/rooveterinaryinc.roo-cline`
- **Project Markers:**
  - `.roomodes`, `.roo/`, `.clinerules`, or `.cline/` in workspace root.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Generating `.roomodes` with a dedicated `flow` mode granting `command` tool permissions, or writing a clear `.clinerules`.
  - When the user selects "Flow" mode, Roo Code autonomously executes `flow.sh` commands, halts on gate failures, and manages card lifecycle faithfully.
- **The Marketing Illusion to Avoid:**
  - Promising an MCP server bridge: Building an MCP daemon to bridge Flow violates ADR 0001 invariants, adds latency, and creates sync bugs.
  - Creating a mode without the `"command"` tool group: If `"command"` is omitted, the agent cannot execute `flow.sh` and will simulate fake gates.
- **Feasibility Verdict:** **Tier 2 (Priority Candidate — Workspace Rule Scaffolding) for Roo Code (via `.roomodes`) and Cline (via `.clinerules`) (Provisional Candidate; Live Trials Pending).**

---

### Candidate 4: Aider

#### 1. System Overview & Harness Architecture
Aider (by Paul Gauthier) is the premier terminal-based AI pair programming tool. It operates directly in the operator's shell, tightly integrated with git history, auto-committing edits, and utilizing repository maps.

#### 2. Extension & Integration Mechanism
- **Configuration Files:**
  - `.aider.conf.yml` loaded from workspace root, git root, or `~/.aider.conf.yml`.
  - Key configuration directives:
    ```yaml
    # .aider.conf.yml
    test-cmd: "bash -c 'cid=$(tr -d \" \\r\\n\" < cards/.inflight 2>/dev/null); if [[ \"$cid\" =~ ^C-[0-9]+$ ]]; then bash skills/flow/runner/flow.sh check \"$cid\"; else bash skills/flow/runner/flow.sh status; fi'"
    auto-test: true
    ```
- **Conventions File:** `CONVENTIONS.md` placed at repo root (standard conventions file read by Aider).
- **Prompt Injection:** `--system-prompt-file` or `system-prompt-file` setting in `.aider.conf.yml`.

#### 3. Execution Capability & Terminal Autonomy
- Aider is an **interactive pair programmer**, not an unprompted autonomous loop agent.
- It executes terminal commands through:
  1. `test-cmd`: Run via `/test` or automatically after file edits when `auto-test: true`.
  2. `lint-cmd`: Run via `/lint` (Flow intentionally omits `lint-cmd` to avoid assumptions about internal repo scripts).
  3. Direct shell execution: `/run <command>` or `!<command>`.
- Aider does not autonomously run a multi-stage planning DAG without human input.

#### 4. Detection Heuristics
- **Global Markers:**
  - Binary `aider` in `PATH` (`command -v aider` / `where aider`).
  - Global config: `~/.aider.conf.yml` or `~/.aider/`.
- **Project Markers:**
  - `.aider.conf.yml`, `.aider.chat.history.md`, `.aider.tags.cache.v3` in repository.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Generating `.aider.conf.yml` hooking `test-cmd` to `bash runner/flow.sh check` and `auto-test: true`.
  - When Aider implements changes for a card, it immediately runs `flow.sh check`. If the gate fails (e.g. unfilled template fields, unverified tests, unchecked boxes), Aider treats it as a test failure and attempts to self-correct.
- **The Marketing Illusion to Avoid:**
  - Claiming "Aider autonomously plans your project from Idea to PRD". Aider is an interactive editing assistant, not a multi-agent planner. Claiming autonomous Flow stage progression in Aider is false marketing.
- **Feasibility Verdict:** **Tier 2 (Project-Level Pair-Programming Hook).**

---

### Candidate 5: OpenHands (formerly OpenDevin)

#### 1. System Overview & Harness Architecture
OpenHands is an open-source autonomous AI software development platform. It runs autonomous agents (primarily `CodeActAgent`) inside Docker containers or sandboxed cloud environments.

#### 2. Extension & Integration Mechanism
- **Microagents Architecture:**
  - OpenHands utilizes **Microagents** located in `.openhands/microagents/*.md`.
  - Schema:
    ```markdown
    ---
    name: flow-discipline
    type: repo
    version: 1.0.0
    agent: CodeActAgent
    triggers:
      - "flow"
      - "gate"
      - "card"
      - "build"
    ---
    # Flow Discipline Instructions
    Before marking tasks done, invoke `bash skills/flow/runner/flow.sh check`.
    ```
- **Instruction Files:** `.openhands_instructions` at the workspace root, read on session initialization.

#### 3. Execution Capability & Terminal Autonomy
- `CodeActAgent` has full autonomous terminal execution via `execute_bash`.
- Commands execute inside an isolated container sandbox with complete stdout/stderr capture and exit code checks.

#### 4. Detection Heuristics
- **Global Markers:**
  - Docker container running OpenHands or `openhands` Python package.
  - Configuration directory: `~/.openhands/`.
- **Project Markers:**
  - `.openhands/` directory or `.openhands_instructions` file at project root.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - **Project-Local Installation is Mandatory:** Because OpenHands runs inside Docker/sandboxes, global host paths (`~/.claude/skills/flow`, `~/.agents/skills/flow`) on the user's host machine are **completely inaccessible** inside the container.
  - Flow runner must be installed within the repository worktree (e.g., `<project>/skills/flow` or `<project>/.flow/runner/`).
  - `.openhands/microagents/flow.md` instructs the agent to run `./skills/flow/runner/flow.sh`.
- **The Marketing Illusion to Avoid:**
  - Selling global installation for OpenHands. Running `npx flow-skill install global` will leave OpenHands unable to find `flow.sh` inside its container, producing immediate execution failures (`ENOENT`).
- **Feasibility Verdict:** **Tier 2 (Project-Scoped Installation + Microagent Definition).**

---

### Candidate 6: GitHub Copilot (CLI & VS Code Agent Mode)

#### 1. System Overview & Harness Architecture
GitHub Copilot spans multiple surfaces:
1. **VS Code Copilot (Agent Mode / Edits / Chat):** Multi-file editing assistant inside VS Code.
2. **GitHub Copilot CLI (`gh copilot`):** Command-line explanation and suggestion tool.

#### 2. Extension & Integration Mechanism
- **VS Code Copilot Instructions:**
  - Project-level standard: `.github/copilot-instructions.md` at workspace root. Automatically ingested by Copilot Chat and Agent Mode.
  - Workspace settings: `github.copilot.chat.customInstructions` in `.vscode/settings.json`.
- **GitHub Copilot CLI:**
  - Historically functions as an interactive command suggestion utility; instruction ingestion and autonomous tool loops under current extensions remain unassessed pending dedicated verification.

#### 3. Execution Capability & Terminal Autonomy
- In VS Code **Copilot Agent Mode**, Copilot can propose terminal commands to run in the VS Code terminal.
- However, execution is **semi-autonomous**: commands typically require manual user confirmation (clicking "Run" or pressing Enter). It lacks an autonomous loop for iterative self-correction across multiple subagents.
- Copilot CLI's autonomous execution capability remains unassessed in verified testing (historically suggestion-only).

#### 4. Detection Heuristics
- **Global Markers:**
  - GitHub CLI extension: `gh extension list | grep copilot`.
  - VS Code extensions: `~/.vscode/extensions/github.copilot*`.
- **Project Markers:**
  - `.github/copilot-instructions.md` in repository.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Providing a clean `.github/copilot-instructions.md` instructing Copilot to format changes around Flow cards and prompt the user to execute `bash runner/flow.sh check`.
  - Flow serves as an interactive guide.
- **The Marketing Illusion to Avoid:**
  - Advertising "Full Autonomous Buildflow in GitHub Copilot". Copilot Agent Mode cannot run the complete Idea->Retro pipeline autonomously without constant human driving. Copilot CLI historically functioned as an interactive suggestion helper; its tool execution loop under modern extensions remains unassessed.
- **Feasibility Verdict:** **Tier 2 for VS Code Copilot (.github/copilot-instructions.md) / Tier 3 Deferred for Copilot CLI (Unassessed / Pending Verification).**

---

### Candidate 7: Zed

#### 1. System Overview & Harness Architecture
Zed is a high-performance, Rust-built code editor (Zed Industries). Its modern AI stack includes the **Zed Agent Panel**, **Agent Skills**, and **External Agents (ACP - Agent Client Protocol)**.

#### 2. Extension & Integration Mechanism
- **Agent Skills (Open Standard):**
  - **Authoritative Zed Documentation (`https://zed.dev/docs/ai/skills`):** Zed natively implements the Agent Skills standard!
  - **Global Path:** `~/.agents/skills/` (applies to all projects).
  - **Project Path:** `<worktree>/.agents/skills/` (applies to current project).
  - *Critical Discovery:* Flow's existing `agents` target (`~/.agents/skills/flow`) in `constants.mjs` is **already natively recognized by Zed Agent** without any modifications!
- **Agent Instructions:**
  - Global: `~/.config/zed/AGENTS.md` (Linux/macOS) or `%APPDATA%\Zed\AGENTS.md` (Windows).
  - Project: `AGENTS.md` at workspace root.
- **Settings:** `.zed/settings.json`.

#### 3. Execution Capability & Terminal Autonomy
- Zed's Agent Panel includes the built-in `terminal` tool alongside `read_file` and `edit_file`.
- Command execution is governed by tool permissions (`agent.tool_permissions` in `settings.json`) or sandboxing.
- When permitted, Zed Agent can execute terminal commands and inspect stdout/stderr.
- *Limitation:* Zed Inline Assistant (Ctrl+Enter inline editor) does *not* possess terminal capabilities. Only the Zed Agent Panel supports tool invocation.

#### 4. Detection Heuristics
- **Global Markers:**
  - Linux: `~/.config/zed` or binary `zed` in `PATH`.
  - macOS: `~/Library/Application Support/Zed`, `/Applications/Zed.app`, or binary `zed`.
  - Windows: `%APPDATA%\Zed`.
- **Project Markers:**
  - `.zed/settings.json` or `.zed/` directory in workspace root.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Flow installed to `~/.agents/skills/flow` (already supported by Flow `agents` target).
  - Project `AGENTS.md` reinforces the discipline: *"Load skill 'flow'. Verify all stage transitions with `runner/flow.sh`."*
  - Zed Agent Panel executes `flow.sh` via its built-in `terminal` tool.
- **The Marketing Illusion to Avoid:**
  - Claiming Zed Inline Assistant supports Flow. Inline Assistant only generates text diffs in editor buffers; it cannot invoke Flow gates.
- **Feasibility Verdict:** **Tier 1 Candidate (Provisional Native Skill Target via Universal `~/.agents/skills/flow` + `AGENTS.md`; Live Host Trial Pending).**


### Candidate 8: Goose

#### 1. System Overview & Harness Architecture
Goose (developed by Block, Inc.; open-source under Apache-2.0, repository: https://github.com/block/goose, docs: https://block.github.io/goose) is an autonomous software engineering agent available as both a high-performance CLI (`goose cli` / `goose session`) and a desktop application (Goose Desktop). Written primarily in Rust, Goose operates in an autonomous multi-turn reasoning and execution loop, utilizing tool extensions (prominently leveraging the Model Context Protocol - MCP) alongside built-in developer tools.

#### 2. Extension & Integration Mechanism
- **Workspace Instruction Scaffolding:**
  - Goose ingests project-level instructions via `.goosehints` located at the repository root.
  - On session start, Goose loads `.goosehints` into the active system context window to guide tool usage and project-level operational discipline.
- **Developer Extension & Tool Execution:**
  - Goose features a built-in `developer` extension providing shell execution capabilities via `developer__shell` (or `execute`).
  - Terminal subshell commands run directly on the host operating system, capturing stdout, stderr, and integer exit codes.

#### 3. Constitutional Audit: Rejection of Resident MCP Server Daemons
- While Goose extensively uses MCP extensions, implementing Flow as a persistent, resident MCP server daemon is **constitutionally forbidden** under ADR-0001 (Zero Resident Daemons, Process Token Ownership).
- Flow's state lives strictly on disk (`flow/*.md`, `cards/C-NNN.md`) and in git.
- Goose interacts with Flow **strictly ephemerally** via its developer shell tool (`developer__shell` / `execute`) executing `bash skills/flow/runner/flow.sh <command>`, terminating on return.

#### 4. Execution Capability & Mechanical Gate Enforcement
- **Terminal Invocation:** The autonomous agent dispatches Flow lifecycle verbs (`status`, `next`, `check C-NNN`) via the developer shell tool.
- **Gate-Stop Invariant:** Non-zero exit codes ($exit \neq 0$) from `flow.sh` are captured and returned to the model loop, mandating an immediate halt and preventing hallucinated gate passes.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - A lightweight `.goosehints` file binds Goose to Flow's gated buildflow.
  - Goose executes `bash skills/flow/runner/flow.sh` via its built-in shell tool and strictly respects non-zero exit codes.
- **The Marketing Illusion to Avoid:**
  - Building a resident MCP daemon that runs in the background, violating ADR-0001 and causing state-desynchronization traps.
- **Feasibility Verdict:** **Tier 2 Priority Candidate (Provisional Category B Instruction Scaffold; Score 72/100; Live Host Trial Pending).**

### Candidate 9: Amazon Q Developer (IDE /dev Agent vs CLI)

#### 1. System Overview & Harness Architecture: Dual Modality
Amazon Q Developer (developed by Amazon Web Services; vendor portal: https://aws.amazon.com/q/developer/, documentation: https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/) is an AI-powered software development assistant integrated across IDEs (VS Code, JetBrains IDEs via AWS Toolkit), command-line environments (`q` CLI), and AWS cloud workspaces. Under Flow's architecture taxonomy, Amazon Q Developer exhibits two distinct execution modalities:
1. **IDE `/dev` Agent (Proposed Category B Design Candidate):** In VS Code and JetBrains IDEs, invoking `/dev` is described by AWS as engaging a feature development agent. In desk research, it is hypothesized to ingest workspace context and dispatch build/terminal commands (empirical tool-loop verification pending live trials).
2. **Standalone `q` CLI (Unassessed / Pending Verification):** The standalone `q` CLI utility (`q chat`, `q translate`) is designed strictly for interactive developer Q&A, code completions, and shell translations. It historically functioned as an interactive query utility; current CLI capability remains unassessed pending current AWS/Kiro documentation.

#### 2. Extension & Integration Mechanism
- **Workspace Instruction Scaffolding & Prompt Context:**
  - Amazon Q Developer does not support directory-based skill discovery (Category A) such as `~/.agents/skills/` or `~/.claude/skills/`.
  - Amazon Q Developer has no established `.amazonq/rules/` vendor schema. Scaffolding is NOT implemented in `flow rules` (which is locked to 7 templates). Integration is purely a hypothetical design concept relying on manual prompt/workspace context (or generic root instruction files like `AGENTS.md`).
  - Candidate instruction guidance must remain compact (strictly under 1,000 characters and 150 words) to prevent context clipping and prompt dilution during multi-file `/dev` tasks.
- **Project-Local Runner Requirement:**
  - In containerized dev environments (such as AWS CodeCatalyst), host global paths (`~/.claude/skills/flow`, `~/.agents/skills/flow`) would produce `ENOENT` failures; repository-local runners are required.
  - The repository must vendor Flow locally (`skills/flow/runner/flow.sh` or `skills\flow\runner\flow.cmd` on Windows) for reliable execution.
#### 3. Constitutional Audit: Rejection of AWS Cloud Daemons & Background Services
- Attempting to implement Flow as a resident cloud daemon, persistent AWS Lambda background service, Amazon ECS background task, or resident socket daemon is **constitutionally forbidden** under ADR-0001 (Zero Resident Daemons, Process Token Ownership).
- Flow maintains zero resident services. State lives strictly in Git, filesystem markdown artifacts (`flow/*.md`, `cards/C-NNN.md`), and deterministic exit codes.
- In this proposed integration, Amazon Q Developer holds the process token. Flow would execute ephemerally as a subprocess when invoked via workspace terminal/build tools (`bash skills/flow/runner/flow.sh <command>`) and terminate immediately upon returning.

#### 4. Execution Capability & Mechanical Gate Enforcement
- **Terminal & Build Tool Invocation (Hypothesis):** In `/dev` mode, the agent is hypothesized to dispatch Flow lifecycle commands (`status`, `next`, `check C-NNN`) via its workspace execution tool.
- **Gate-Stop Invariant (Pending Verification):** Flow's non-zero exit codes ($exit \neq 0$) must be captured and returned to the `/dev` agent loop to mandate an immediate halt, preventing hallucinated gate passes (subject to Phase 4 live verification).
- **CLI Limitation:** The standalone `q` CLI historically functions as an interactive command query utility; an autonomous multi-turn tool execution loop remains unassessed pending current AWS/Kiro documentation.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:**
  - Manual prompt or workspace context directing `/dev` to invoke a repository-vendored runner (`skills/flow/runner/flow.sh`), since no `.amazonq/` template exists in `flow rules`.
  - In IDE `/dev` mode, Amazon Q is hypothesized to run `flow.sh status` and `flow.sh check C-NNN` (empirical verification pending live trial).
- **The Marketing Illusion to Avoid:**
  - Advertising universal "Amazon Q support" without disambiguating the IDE `/dev` agent from the standalone `q` CLI (whose autonomous tool loop has not been verified in testing).
  - Claiming an `.amazonq/rules/` rule template or generator exists in Flow when `flow rules` is locked to seven verified templates.
  - Referencing unreachable host paths (`~/.agents/skills/...`) inside cloud containerized sandboxes.
- **Feasibility Verdict:**
  - **Amazon Q (/dev Agent): Tier 2 Priority Candidate (Provisional Un-implemented Design Proposal; Score 66/100; Live Host Trial Pending).**
  - **Amazon Q CLI: Unassessed / Pending Verification (historically query utility; current Kiro successor tool-loop capability unassessed).**
---

### Candidate 10: Devin Autonomous Software Engineer (Cognition AI)

#### 1. System Overview & Harness Architecture
Devin (developed by Cognition AI; vendor portal: https://cognition.ai/devin, documentation: https://docs.devin.ai/) is an autonomous software engineering agent shown in vendor demonstrations operating in a cloud sandbox environment, where task planning, code editing, and terminal commands are executed under an autonomous agent loop (empirical runtime integration with Flow remains an unverified hypothesis).

#### 2. Execution Environment: Cloud Sandbox Environment (Hypothesized)
- In desk research, Devin is hypothesized to execute inside a cloud sandbox provisioned with shell, editor, and browser tools.
- The cloud sandbox is isolated from local developer workstations: global host paths (`~/.claude/skills/flow`, `~/.agents/skills/flow`) would be inaccessible inside the remote environment.
- Sandbox persistence and lifecycle dynamics remain unverified in Flow testing; state is assumed to require git persistence.

#### 3. Extension & Integration Mechanism: DEVIN.md / AGENTS.md
- Devin is hypothesized in desk review to discover repository instruction files (`DEVIN.md` / `AGENTS.md`), subject to live host verification.
- In proposed integration, instruction files would direct Devin's autonomous loop toward project conventions; no proprietary rule schema (`flow rules` template) exists for Devin, and `flow rules` remains locked to the 7 implemented templates.
- Scaffolding guidance must therefore live in `DEVIN.md` / `AGENTS.md`, kept compact to avoid context dilution across long autonomous sessions.

#### 4. Project-Local Runner Requirement
- Because Devin runs in an isolated cloud environment, the repository would require Flow vendored locally at **`skills/flow/runner/flow.sh`** for reliable execution.
- A global installer targeting developer host registries is hypothesized to leave remote cloud environments unable to locate the runner (hypothesized `ENOENT` failure).
- In proposed integration, Devin would invoke Flow ephemerally via its sandbox terminal (`bash skills/flow/runner/flow.sh <command>`); the Devin process would hold the process token and Flow would terminate immediately upon returning.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** A proposed `DEVIN.md` / `AGENTS.md` entry directing Devin to invoke the repository-vendored runner (`skills/flow/runner/flow.sh status`, `check C-NNN`), where Devin is hypothesized to honor Flow's non-zero exit codes and halt the autonomous loop at gate failures (subject to Phase 4 live trials).
- **The Marketing Illusion to Avoid:** Claiming a `DEVIN.md` template or generator exists in `flow rules` (it does not; `flow rules` is locked to seven verified templates), or referencing host-global skill paths inside the cloud sandbox.
- **Feasibility Verdict:**
  - **Devin: Proposed Design Candidate (Unverified Category B Cloud Scaffold Hypothesis; Live Cloud Trials Pending).**

---

### Candidate 11: SWE-agent (Princeton NLP / InterCode)

#### 1. System Overview & Harness Architecture
SWE-agent (Princeton NLP; derived from the InterCode research line; source: https://github.com/SWE-agent/SWE-agent, documentation: https://swe-agent.com/) is an open research agent that operates an autonomous issue-resolution loop inside an isolated Docker container. Its defining design principle is the **Agent-Computer Interface (ACI)**: a deliberately simplified set of file-viewing, file-editing, and shell tools exposed to the model instead of raw interactive shell sessions.

#### 2. Execution Environment: Docker Container / ACI (Desk-Reviewed)
- SWE-agent executes inside a per-instance Docker container; all tool invocations (including the ACI shell `execute` tool) run against the containerized filesystem.
- The container is isolated from the developer workstation: host-global skill paths (`~/.claude/skills/flow`, `~/.agents/skills/flow`) do not exist inside the container and would produce `ENOENT` failures.
- Container lifecycle and state persistence dynamics are desk-reviewed against the upstream repository but remain **unverified in live Flow testing**; state is assumed to require git persistence.

#### 3. Extension & Integration Mechanism: Prompt Templates / `AGENTS.md`
- SWE-agent is driven by prompt templates and per-run configuration (YAML config files selecting tools and model); it has no proprietary workspace rule schema akin to `.roomodes` or `.clinerules`.
- Repository instructions are hypothesized to be discovered via `AGENTS.md`-style project instructions embedded in prompts; no `flow rules` template exists for SWE-agent (`flow rules` remains locked to the 7 implemented templates).
- Scaffolding guidance must therefore live in compact prompt/config template text or `AGENTS.md`, kept small to survive the agent's bounded context.

#### 4. Project-Local Runner Requirement
- Because SWE-agent executes inside Docker, Flow must be vendored into the repository at **`skills/flow/runner/flow.sh`** before the container is provisioned (or mounted into the workspace).
- A host-global installer leaves the container unable to locate the runner (hypothesized `ENOENT` failure at `~/.agents/skills/flow/runner/flow.sh`).
- In proposed integration, SWE-agent would invoke Flow ephemerally via the ACI shell tool (`execute` → `bash skills/flow/runner/flow.sh <command>`); the agent holds the process token and Flow terminates immediately upon returning, satisfying ADR-0001.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** A `config/`-level prompt template plus `AGENTS.md` entry directing SWE-agent's ACI shell tool to invoke the repository-vendored runner (`skills/flow/runner/flow.sh status`, `check C-NNN`), where the agent honors non-zero exit codes and halts the autonomous Docker loop at gate failures — **subject to Phase 4 live container trials**.
- **The Marketing Illusion to Avoid:** Claiming a `flow rules swe-agent` template exists (it does not), or referencing host-global skill paths inside the Docker container.
- **Feasibility Verdict:**
  - **SWE-agent: Proposed Design Candidate (Unverified Category B Container/ACI Scaffold Hypothesis; Live Container Trials Pending).**

---

### Candidate 12: GitLab Duo (Duo Workflow vs Duo Chat)

#### 1. System Overview & Modality Separation
GitLab Duo (GitLab Inc.; documentation: https://docs.gitlab.com/ee/user/gitlab_duo/) spans two divergent modalities that must be strictly separated under Flow's taxonomy (full desk intake: `evaluations/gitlab-duo-intake-evaluation.md`):
- **GitLab Duo Workflow:** In vendor documentation, described as an emerging multi-step execution agent. In desk review, its capability to formulate plans, modify files, and invoke terminal subshells in local IDEs or remote CI/CD runner sandboxes is evaluated as an **unverified Category B candidate hypothesis**.
- **GitLab Duo Chat:** A conversational query assistant in the Web UI, IDE sidebars, and Web IDE. In standard usage, it operates as an interactive query utility; autonomous tool execution and runner exit-code handling remain unassessed pending dedicated live verification (classified as Unassessed / Deferred Pending Verification).

#### 2. Execution Environment (Hypothesized for Duo Workflow)
- Duo Workflow is hypothesized to execute in a local IDE workspace (GitLab Workflow extension in VS Code) or an ephemeral GitLab CI/CD runner container. Host-global paths are absent in runner sandboxes; only the cloned repository under `/builds/<group>/<project>/` exists.
- In vendor documentation and desk analysis, Duo Chat historically operates as a conversational query utility; its current execution environment and tool-loop capabilities remain unassessed pending dedicated live verification.

#### 3. Extension & Integration Mechanism: Proposed `.gitlab/duo_workflow.yml` / `AGENTS.md`
- A `.gitlab/duo_workflow.yml` workflow configuration and repository-root `AGENTS.md` instructions are **proposed ingestion mechanisms**; their existence, schema, and parsing by the execution client are unverified desk hypotheses.
- No `flow rules` template exists for GitLab Duo; `flow rules` remains locked to the 7 implemented templates.

#### 4. Project-Local Runner Requirement (Proposed)
- Any Duo Workflow instruction set would strictly mandate `bash skills/flow/runner/flow.sh <command>`; invoking host-global paths inside a CI runner container fails with `ENOENT`.
- The hypothesized execution subshell would return integer exit codes ($0$/$1$) to the agent; this return path is an unverified hypothesis pending live host trials.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** Live evidence — raw transcripts, tool payloads, and integer exit codes from a Duo Workflow session — demonstrating ingestion of the scaffolding and mechanical halt on gate failure, archived under `plans/research/harness-expansion/evidence/`.
- **The Marketing Illusion to Avoid:** Advertising generic "GitLab Duo support" (conflating historically conversational Duo Chat (current tool-loop capability unassessed) with the unverified Duo Workflow agent), or claiming a `.gitlab/duo_workflow.yml` template exists in `flow rules` (it does not).
- **Feasibility Verdict:**
  - **GitLab Duo Workflow: Proposed Design Candidate (Unverified Category B Rule Scaffold Hypothesis; Live Host Trials Pending).**
  - **GitLab Duo Chat: Unassessed / Deferred Pending Verification (Historically query utility; tool loop unassessed).**

---

### Candidate 13: Sourcegraph Cody (Cody IDE Extension vs Web Search)

#### 1. System Overview & Modality Separation
Sourcegraph Cody (Sourcegraph Inc.; documentation: https://sourcegraph.com/docs/cody, source: https://github.com/sourcegraph/cody, Apache-2.0) spans two distinct modalities that must be strictly separated under Flow's taxonomy (full desk intake: `evaluations/cody-intake-evaluation.md`):
- **Cody IDE Extension (VS Code / JetBrains / Neovim):** In desk review, evaluated as a **proposed un-implemented Category B design hypothesis**. Cody supports repository-scoped context ingestion via workspace prompt configuration, OpenCTX context providers, and root `AGENTS.md` instructions, alongside multi-file `Cody Edits` and interactive terminal command suggestions.
- **Web Cody (Sourcegraph Web Search / Chat):** Functions as a web-based enterprise code search interface; its workspace tool execution capabilities remain unassessed pending dedicated verification (classified as Unassessed / Deferred).

#### 2. Execution Environment (Hypothesized for IDE Extension)
- The IDE extension is hypothesized to execute in the local developer workspace, where the extension host holds the process token and Flow would execute ephemerally via the project-local runner (`bash skills/flow/runner/flow.sh <command>` or `flow.cmd` on Windows).
- Web Cody operates within Sourcegraph Cloud / Enterprise web infrastructure with no verified access to the developer's local filesystem; terminal tool execution and gate enforcement remain unassessed.

#### 3. Extension & Integration Mechanism: Workspace Prompt Config / OpenCTX / `AGENTS.md`
- Workspace prompt configuration, OpenCTX context providers, and root `AGENTS.md` instructions are **proposed ingestion mechanisms**; their parsing of Flow scaffolding is an unverified desk hypothesis.
- No `flow rules` template exists for Sourcegraph Cody; `flow rules` remains locked to the 7 implemented templates.

#### 4. Project-Local Runner Requirement (Proposed)
- Any Cody instruction set would strictly mandate `bash skills/flow/runner/flow.sh <command>`; the hypothesized terminal tool return path (integer exit codes, $0$/$1$) is an unverified hypothesis pending live host trials.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** Live evidence — raw transcripts, terminal tool payloads, and integer exit codes from a Cody IDE session — demonstrating ingestion of the scaffolding and mechanical halt on gate failure, archived under `plans/research/harness-expansion/evidence/`.
- **The Marketing Illusion to Avoid:** Advertising generic "Sourcegraph Cody support" (conflating the web-based search modality (tool execution unassessed) with the unverified IDE extension agent), or claiming a Cody template exists in `flow rules` (it does not).
- **Feasibility Verdict:**
  - **Cody IDE Extension: Proposed Design Candidate (Unverified Category B Rule Scaffold Hypothesis; Live Host Trials Pending).**
  - **Web Cody: Unassessed / Deferred Pending Verification (Web-based search interface; tool execution unassessed).**

---

### Candidate 14: Augment Code (VS Code & JetBrains)

#### 1. System Overview & Harness Architecture
Augment Code (Augment Inc.; documentation: https://docs.augmentcode.com) is an AI-first developer assistant providing codebase-aware context and code generation across VS Code and JetBrains IDE extensions (full desk intake: `evaluations/augment-code-intake-evaluation.md`). In desk review, Augment Code's IDE agent and chat capabilities are evaluated as a **proposed un-implemented Category B design hypothesis**.

#### 2. Execution Environment (Hypothesized for IDE Extensions)
- Augment Code executes within the developer's local IDE workspace (VS Code or JetBrains IDE family). Flow would execute ephemerally via the project-local runner (`bash skills/flow/runner/flow.sh <command>` or `flow.cmd` on Windows), terminating immediately upon return to satisfy ADR-0001.
- Host-global installation paths remain unverified for Augment Code; project-scoped instruction discovery and repository-vendored runner execution represent the primary hypothesis.

#### 3. Extension & Integration Mechanism: Prompt Context / `AGENTS.md` (Proposed)
- Augment Code ingests repository context and workspace conventions. In desk evaluation, project-level instruction injection via repository-root `AGENTS.md` or system prompt context configuration is the **proposed ingestion mechanism**; its parsing by Augment Code's context engine is an unverified desk hypothesis.
- No `flow rules` template exists for Augment Code; `flow rules` remains locked to the 7 implemented templates.

#### 4. Project-Local Runner Requirement (Proposed)
- Any Augment Code instruction set would mandate invoking the repository-vendored runner (`bash skills/flow/runner/flow.sh <command>`). The hypothesized terminal tool execution loop and return path (capturing integer exit codes $0$/$1$) remain unverified design hypotheses pending live host trials.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** Live empirical evidence — raw session transcripts, terminal tool execution logs, and verified halts on non-zero exit codes during an Augment Code IDE session — captured and archived under `plans/research/harness-expansion/evidence/`.
- **The Marketing Illusion to Avoid:** Claiming existing or verified "Augment Code support", or asserting a `flow rules augment` template exists (it does not).
- **Feasibility Verdict:**
  - **Augment Code: Proposed Design Candidate (Unverified Category B Rule Scaffold Hypothesis; Live Host Trials Pending).**

---

### Candidate 15: Tabnine (Chat & Workspace Agent vs Inline Completions)

#### 1. System Overview & Modality Separation
Tabnine (Tabnine Inc.; documentation: https://docs.tabnine.com) encompasses two sharply divergent modalities that must be strictly separated under Flow's taxonomy (full desk intake: `evaluations/tabnine-intake-evaluation.md`):
- **Tabnine Chat & Workspace Agent:** An interactive chat and workspace agent modality available in VS Code and JetBrains IDEs that ingests repository context, answers queries, and proposes edits or shell operations. In desk review, evaluated as an **unverified Category B design hypothesis**.
- **Tabnine Inline (Completions only):** An inline code completion utility operating on editor buffers. Evaluated as a completion modality outside Flow's candidate scope and classified as **Unassessed / Deferred Pending Verification** (completion-only mode outside Flow's integration scope; broader tool capabilities unassessed pending verification).

#### 2. Execution Environment (Hypothesized for Chat & Workspace Agent)
- Tabnine Chat executes within the local IDE extension host (VS Code / JetBrains). Flow would execute ephemerally via the project-local runner (`bash skills/flow/runner/flow.sh <command>` or `flow.cmd` on Windows), terminating immediately upon return.
- Tabnine Inline operates within editor buffer events (keystrokes / LSP ghost text) as a code completion modality; broader terminal execution and autonomous tool capabilities remain unassessed.

#### 3. Extension & Integration Mechanism: Workspace Context / `AGENTS.md`
- For Tabnine Chat, project-level context ingestion via workspace instructions or repository-root `AGENTS.md` is the **proposed ingestion mechanism**; parsing by Tabnine's context engine is an unverified desk hypothesis. Tabnine Inline configuration is outside Flow's build-gate integration scope.
- No `flow rules` template exists for Tabnine; `flow rules` remains locked to the 7 implemented templates.

#### 4. Project-Local Runner Requirement (Proposed)
- Any Tabnine Chat instruction set would strictly mandate `bash skills/flow/runner/flow.sh <command>`. The hypothesized terminal tool execution loop, subshell invocation, and exit code capture ($0$/$1$) remain unverified hypotheses pending live host trials.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** Live empirical transcripts and tool execution traces demonstrating that Tabnine Chat ingests the scaffolding, invokes `flow.sh`, and mechanically halts when a gate fails with exit code 1.
- **The Marketing Illusion to Avoid:** Conflating Tabnine Inline completions (a completion-only mode outside Flow candidate scope) with Tabnine Chat agentic capabilities, or claiming a `flow rules tabnine` template exists (it does not).
- **Feasibility Verdict:**
  - **Tabnine (Chat & Workspace Agent): Proposed Design Candidate (Unverified Category B Rule Scaffold Hypothesis; Live Host Trials Pending).**
  - **Tabnine (Inline Completions): Unassessed / Deferred Pending Verification (Completion-only mode outside Flow candidate scope; broader tool capabilities unassessed).**

---

### Candidate 16: Plandex (Terminal AI Coding Engine)

#### 1. System Overview & Harness Architecture
Plandex (Plandex Inc.; repository: https://github.com/plandex-ai/plandex, documentation: https://docs.plandex.ai) is an open-source (Apache-2.0) terminal-based AI coding engine written in Go, designed for complex software development tasks spanning multiple files and directories (full desk intake: `evaluations/plandex-intake-evaluation.md`). Plandex operates through an isolated, git-backed sandbox branch model combined with built-in command execution and auto-debugging under configurable autonomy. Its active deployment model centers on a self-hosted server deployment (run locally via binary or Docker container; Plandex Cloud is winding down and closed to new users per official README). In desk review, Plandex is evaluated as a **proposed un-implemented Category B design hypothesis**.

#### 2. Execution Environment: Local Terminal / CLI
- Plandex executes within the developer's local terminal via its Go CLI client communicating with the self-hosted engine server.
- Flow would execute ephemerally via project-local runner invocation (`bash skills/flow/runner/flow.sh <command>` or `flow.cmd` on Windows), terminating immediately upon return.
- Flow Process Boundary: While Plandex utilizes an underlying background engine or server in its client-server model, Flow execution must remain strictly an ephemeral subshell invocation; Flow will not run as or spawn persistent background daemons or socket listeners (ADR-0001).

#### 3. Extension & Integration Mechanism: Project Plan Context / `AGENTS.md`
- Hypothesized Ingestion Mechanism: Project-level instruction ingestion via repository-root `AGENTS.md` (e.g. loaded via `plandex load` or referenced in plan prompts) represents an unverified integration hypothesis. Plandex vendor documentation defines no directory-based skill discovery standard (`~/.agents/skills/`).
- Crucially, no `flow rules` template exists for Plandex; `flow rules` remains locked to seven implemented scaffolding templates (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). Attempting `flow rules plandex` fails with exit code 2.

#### 4. Project-Local Runner Requirement
- Project-Local Runner Requirement: Proposed integration mandates invoking the project-vendored runner (`bash skills/flow/runner/flow.sh <command>`). Host-global skill directory resolution remains unverified for Plandex, requiring the Flow runner tree to be present in the project workspace.
- The built-in command tool execution loop and exit-code fidelity (capturing integer exit codes $0$/$1$, halting on non-zero exit, and strictly refusing to hallucinate a pass) remain an unverified hypothesis pending live host trials.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** Live empirical transcripts, command execution receipts, and gate-stop verification — raw session transcripts demonstrating that Plandex loads `AGENTS.md`, invokes `bash skills/flow/runner/flow.sh <command>`, captures real exit codes, and strictly halts when a gate fails — captured and archived under `plans/research/harness-expansion/evidence/`.
- **The Marketing Illusion to Avoid:** Claiming verified support or a non-existent `flow rules plandex` template, or conflating sandboxed plan generation / diff creation with Flow gate enforcement. Staging diffs in a Plandex sandbox does not satisfy Flow gates without real on-disk materialized receipts.
- **Feasibility Verdict:**
  - **Plandex: Proposed Design Candidate (Unverified Category B Rule/Plan Scaffold Hypothesis; Live Host Trials Pending).**

---

### Candidate 17: Trae (Dual Category A Native Skills & Category B Agent Mode)

#### 1. System Overview & Harness Architecture
Trae (ByteDance; official portal: https://www.trae.ai, documentation: https://docs.trae.ai) is an adaptive, AI-first code editor built upon a VS Code foundation (full desk intake: `evaluations/trae-intake-evaluation.md`). Official Trae documentation identifies a merged environment featuring **Agent Mode** (the autonomous agent capability, formerly named "Builder" or "Builder Mode" in early preview releases before being merged into Agent Mode) alongside **IDE Mode** (Chat and editor completions). Trae provides multiple interaction modalities: an interactive Chat panel, autonomous multi-turn **Agent Mode** with integrated terminal execution and workspace editing capabilities across local workspace directories or remote SSH environments, and inline code completion. Architecturally, Trae presents a unique dual-category integration profile:
- **Category A (Native Skill Target):** Documented support for directory-based dynamic skill discovery via `SKILL.md` located at user-global (`~/.trae/skills/`) and project-local (`.trae/skills/`) paths.
- **Category B (Project Rules Scaffolding):** Documented project rules support at `.trae/rules/*.md` and user-level global rules at `~/.trae/user_rules`, complemented by repository-root `AGENTS.md`.

In desk review, Trae is evaluated as a **proposed un-implemented Dual Category A / Category B candidate**, pending live empirical verification of Agent Mode terminal execution and gate enforcement.

#### 2. Execution Environment: Local Workspace or Remote SSH with Chat & Agent Mode
- Trae executes locally on the developer's workstation or across remote SSH environments within an integrated IDE environment offering Chat and Agent Mode (formerly Builder Mode).
- Flow executes ephemerally via project-local runner invocation (`bash skills/flow/runner/flow.sh <command>` or `<skill-dir>\runner\flow.cmd <command>` on Windows) in the active shell environment, terminating immediately upon completion.
- Zero Flow Daemons (ADR-0001): In strict adherence to ADR-0001, Flow operates exclusively as a stateless, host-invoked discipline layer. Flow will not run as or spawn persistent background daemons, language servers, or socket listeners within Trae. The Trae Agent Mode host holds the execution process token.

#### 3. Extension & Integration Mechanism: Documented `SKILL.md` Paths & Project Rules
- **Arm A (Category A Native Skill Discovery):** Documented `SKILL.md` paths (`.trae/skills/flow/SKILL.md` at project level or `~/.trae/skills/flow/SKILL.md` globally) provide a host-native target for Flow's standard skill bundle.
- **Arm B (Category B Project Rules):** Documented project rules (`.trae/rules/flow.md` or `.trae/rules/*.md`) allow injecting discipline constraints and runner invocation instructions into the Agent Mode context.
- Crucially, no `flow rules` template exists for Trae; `flow rules` remains strictly locked to seven implemented scaffolding templates (`cursor`, `windsurf`, `roo`, `cline`, `aider`, `openhands`, `copilot`). Attempting `flow rules trae` fails with exit code 2. Workspace rules must be staged manually for evaluation.

#### 4. Project-Local Runner Requirement
- Project-Local Runner Requirement: Proposed integration mandates invoking the project-vendored runner (`bash skills/flow/runner/flow.sh <command>`). Host-global skill directory resolution remains unverified in live execution, requiring the Flow runner tree to be present in the project workspace.
- The Agent Mode's integrated terminal execution tool (unverified API name / host trial pending), exit-code capture fidelity (capturing integer exit codes $0$/$1$, halting on non-zero exit, and strictly refusing to hallucinate a pass), and refusal to proceed on gate failure remain an unverified hypothesis pending live host trials.

#### 5. Authenticity Evaluation (Support Thật vs. Illusion)
- **What Real Support Looks Like:** Live empirical transcripts across Arm A (native skill discovery) and Arm B (project rules), capturing command execution receipts, integer exit codes, and verified gate-stop behavior — raw session transcripts demonstrating that Trae Agent Mode discovers the skill or ingests `.trae/rules/`, invokes `bash skills/flow/runner/flow.sh <command>`, captures real exit codes, and strictly halts when a gate fails — captured and archived under `plans/research/harness-expansion/evidence/`.
- **The Marketing Illusion to Avoid:** Claiming verified support or a non-existent `flow rules trae` template, or assuming that vendor documentation of `SKILL.md` support translates to verified execution without live empirical transcripts.
- **Feasibility Verdict:**
  - **Trae: Proposed Design Candidate (Unverified Dual Category A / Category B Hypothesis; Live Host Trials Pending).**
---

## 3. Cross-Harness Comparison & Technical Matrix

| Harness | Primary Configuration | Global Path | Project Path | Terminal Tool | Execution Autonomy | Feasibility Tier |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Cursor** | `.cursor/rules/*.mdc` | `~/.cursor/skills/` | `.cursor/rules/flow.mdc` | `run_terminal_cmd` | Autonomous (YOLO) / Prompted | **Tier 1 (Priority Native Fit Candidate)** |
| **Roo Code** | `.roomodes` (JSON) | N/A (VSCode Storage) | `.roomodes` | `execute_command` | Autonomous (Auto-approve) | **Tier 2 (Priority Rule Scaffold Candidate)** |
| **Zed** | `SKILL.md` / `AGENTS.md` | `~/.agents/skills/` | `.agents/skills/` / `AGENTS.md`| `terminal` | Autonomous (Permissions) | **Tier 1 (Provisional Candidate)** |
| **Windsurf** | `.windsurf/rules/*.md`| `global_rules.md` | `.windsurf/rules/flow.md` | `run_command` | Autonomous / Prompted | **Tier 2** |
| **Cline** | `.clinerules` | N/A (VSCode Storage) | `.clinerules` | `execute_command` | Autonomous (Auto-approve) | **Tier 2** |
| **Aider** | `.aider.conf.yml` | `~/.aider.conf.yml` | `.aider.conf.yml` | `test-cmd` / `/run` | Semi-autonomous (Pair hook) | **Tier 2** |
| **OpenHands** | Microagent (`.md`) | N/A (Isolated Docker) | `.openhands/microagents/` | `execute_bash` | Autonomous (Container) | **Tier 2** |
| **Copilot (VSCode)**| `copilot-instructions.md` | Settings | `.github/copilot-instructions.md` | Terminal proposal | Semi-autonomous (Prompted) | **Tier 2** |
| **Goose** | `.goosehints` | `~/.config/goose/` | `.goosehints` | `developer__shell` / `execute` | Autonomous (Multi-turn loop) | **Tier 2 (Provisional Candidate)** |
| **Copilot CLI** | None | N/A | N/A | None | Unassessed (Query utility) | **Tier 3 (Deferred / Unassessed; pending CLI probe)** |
| **Amazon Q (/dev)** | Manual prompt context (No flow rules template) | N/A | Manual prompt context | Terminal/Build tool | Hypothesized autonomous (/dev mode; live trial pending) | **Tier 2 (Provisional Un-implemented Design Proposal)** |
| **Devin** | Hypothesized `DEVIN.md` / `AGENTS.md` (No template) | N/A (Cloud Sandbox; unverified) | Hypothesized `DEVIN.md` / `AGENTS.md` (Proposed) | `bash` (Cloud sandbox terminal; unverified) | Hypothesized autonomous (Cloud loop; live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **SWE-agent** | Prompt templates / `AGENTS.md` | N/A (Docker Container) | Config templates / `AGENTS.md` | ACI shell (`execute`) | Hypothesized autonomous (Docker loop; live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **GitLab Duo Workflow** | Proposed `.gitlab/duo_workflow.yml` (No template) | N/A | Proposed config / `AGENTS.md` | Hypothesized terminal tool | Hypothesized autonomous (Live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **GitLab Duo Chat** | None | N/A | N/A | None | Unassessed (Query utility) | **Tier 3 (Deferred / Unassessed; pending verification)** |
| **Sourcegraph Cody** | Workspace prompt config / OpenCTX / `AGENTS.md` | N/A | Prompt config / `AGENTS.md` | Hypothesized terminal tool | Hypothesized autonomous (Live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **Augment Code** | Prompt context / `AGENTS.md` (No template) | N/A | Proposed prompt / `AGENTS.md` | Hypothesized terminal tool | Hypothesized autonomous (Live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **Tabnine (Chat)** | Workspace context / `AGENTS.md` (No template) | N/A | Proposed prompt / `AGENTS.md` | Hypothesized terminal tool | Hypothesized autonomous (Live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **Tabnine (Inline)** | None | N/A | N/A | Unassessed | Completion-only modality (outside Flow scope) | **Unassessed / Deferred Pending Verification** |
| **Plandex** | Project plan context / `AGENTS.md` (No template) | N/A | Proposed plan / `AGENTS.md` | Built-in command tool (`exec`) | Autonomous (Configurable auto-debug; live trial pending) | **Proposed B (Design Hypothesis; Unverified)** |
| **Trae** | \`.trae/skills/\` (\`SKILL.md\`) & \`.trae/rules/\` | \`~/.trae/skills/\` & \`~/.trae/user_rules\` | \`.trae/skills/flow/\` & \`.trae/rules/flow.md\` | Integrated terminal tool (unverified API name / host trial pending) | Autonomous (Agent Mode; live trial pending) | **Tier 1 / Tier 2 (Dual A/B Proposed Candidate)** |
| **Amazon Q CLI** | None | N/A | N/A | None | Unassessed (Query utility; successor unassessed) | **Unassessed (Historical query utility; current successor capability unassessed)** |

---

## 4. Critical Environmental Realities & Pitfalls

### 4.1 The Container / Sandbox Boundary (OpenHands & Devcontainers)
```
[ Host Operating System ]
  ├── ~/.claude/skills/flow          <── Completely unreachable from inside Docker!
  └── ~/.agents/skills/flow          <── Completely unreachable from inside Docker!
         │
         ▼ (Docker Volume Mount)
[ Container / Sandbox Environment (OpenHands / Codespaces) ]
  └── /workspace/my-project/
        ├── .openhands/microagents/flow.md
        └── skills/flow/runner/flow.sh <── MUST BE LOCATED HERE (Repository-vendored runner)
```
- **The Pitfall:** If an installer only places Flow in `~/.claude/` or `~/.agents/` on the developer's laptop, containerized agents like OpenHands will crash with:
  `bash: /home/user/.agents/skills/flow/runner/flow.sh: No such file or directory`.
- **The Requirement:** For containerized and sandboxed harnesses (where project-scoped installation via `npm-wrapper` is reserved exclusively for Claude Code per codebase policy), repositories must vendor the Flow runner tree locally (`skills/flow/runner/flow.sh`) so container subshells can access the runner without depending on unreachable host global registries.

### 4.2 The Windows Shell Trap (`flow.sh` vs. `flow.cmd`)
- In Windows environments (common across Cursor, Windsurf, VS Code Copilot):
  - Typing `bash runner/flow.sh` in PowerShell or CMD often invokes Microsoft WSL `bash.exe`.
  - WSL `bash` operates in an isolated Linux root mount and cannot resolve Windows paths like `C:\Users\...` properly, causing script crashes.
- **The Requirement:** In all Windows instructions generated for harnesses, Flow must instruct the agent:
  - If running on Windows PowerShell/CMD: invoke `runner\flow.cmd <command>`.
  - If running in Git Bash / POSIX: invoke `bash runner/flow.sh <command>`.

---

## 5. Architectural Implementation Plan

### 5.1 Updates to Installer Detection (`npm-wrapper/src/constants.mjs`)
Cursor target parity has already landed (`c050950a`) in `npm-wrapper/src/constants.mjs`, while candidates like `zed` alias are design proposals:

```javascript
// Additions to npm-wrapper/src/constants.mjs
export const TARGETS = [
  // ... Existing Claude, Codex, Agents, Antigravity, Cursor, OMP ...
  {
    name: 'zed',
    label: 'Zed Editor (~/.agents/skills/flow + ~/.config/zed/AGENTS.md)',
    // Zed consumes universal ~/.agents/skills/ natively
    markers: ['.config/zed', '.agents/skills'],
    destTemplates: ['~/.agents/skills/flow'],
    alwaysInclude: false,
    projectScopeAllowed: true,
  },
  {
    name: 'windsurf',
    label: 'Windsurf / Cascade (.windsurf/rules/flow.md)',
    markers: ['.codeium/windsurf', '.windsurf'],
    destTemplates: ['~/.codeium/windsurf/memories/global_rules.md'],
    alwaysInclude: false,
    projectScopeAllowed: true,
  },
  {
    name: 'cline',
    label: 'Cline / Roo Code (.roomodes / .clinerules)',
    markers: [
      '.vscode/extensions',
      '.config/Code/User/globalStorage/rooveterinaryinc.roo-cline',
      '.config/Code/User/globalStorage/saoudrizwan.claude-dev'
    ],
    destTemplates: [], // Primarily project-scoped
    alwaysInclude: false,
    projectScopeAllowed: true,
  },
  {
    name: 'aider',
    label: 'Aider (.aider.conf.yml)',
    markers: ['.aider.conf.yml'],
    destTemplates: ['~/.aider.conf.yml'],
    alwaysInclude: false,
    projectScopeAllowed: true,
  },
  {
    name: 'openhands',
    label: 'OpenHands (.openhands/microagents/flow.md)',
    markers: ['.openhands', '.openhands_instructions'],
    destTemplates: [], // Strictly project-scoped
    alwaysInclude: false,
    projectScopeAllowed: true,
  },
];
```

### 5.2 Project-Level Scaffolding Command (`flow rules <harness> [--write]`)
To guarantee "Support Thật", Flow's CLI provides the scaffolding command `flow rules <harness> [--write]` (not `flow init`). Flow provides `flow rules <harness>` to preview verified rule templates, and `flow rules <harness> --write` creates the rule file with atomic write and strict overwrite refusal (exits 1 if file already exists) to protect user configuration.

1. **For Cursor (`flow rules cursor [--write]`):**
   Writes `.cursor/rules/flow.mdc` with the exact hardened template:
   ```markdown
   ---
   description: Flow buildflow discipline layer and gated execution engine
   globs: flow/**,cards/**,*.md,src/**
   alwaysApply: false
   ---

   # Flow Discipline Rules for Cursor

   You are operating inside a repository managed by Flow (`/flow`).
   Flow turns coding agents into evidence-gated, kill-honest build processes.

   ## Rules of Engagement
   1. **Never edit files without an active card.** Check in-flight cards via `bash skills/flow/runner/flow.sh status`.
   2. **Always inspect gates before coding.** Run `bash skills/flow/runner/flow.sh next` or `bash skills/flow/runner/flow.sh check C-NNN`.
   3. **Respect Allowed Files.** Only modify files explicitly listed in the active card's `## Allowed files` section.
   4. **Never fake verify proof.** Paste real terminal output, exit codes, and URLs into `## Evidence`.
   ```

2. **For Roo Code (`flow rules roo [--write]`):**
   Materializes `.roomodes` with customMode `flow` and tool permissions if absent (refuses overwrite if exists):
   ```json
   {
     "customModes": [
       {
         "slug": "flow",
         "name": "Flow Discipline",
         "roleDefinition": "You are a disciplined software engineer operating under Flow gates. You never write code without an active card and you verify all changes against card criteria.",
         "groups": [
           "read",
           ["edit", { "fileRegex": "^(cards/.*|src/.*|tests/.*|flow/.*)$", "description": "Flow and source directories" }],
           ["command", { "commandRegex": "^bash skills/flow/runner/flow\\.sh.*", "description": "Flow runner execution" }]
         ]
       }
     ]
   }
   ```

3. **For Windsurf (`flow rules windsurf [--write]`):**
   Writes `.windsurf/rules/flow.md` with concise runner execution rules under 6,000 characters.

4. **For Cline (`flow rules cline [--write]`):**
   Writes `.clinerules` with runner execution rules.

5. **For Aider (`flow rules aider [--write]`):**
   Generates `.aider.conf.yml` with the exact hardened `test-cmd` (and no `lint-cmd`):
   ```yaml
   # Aider configuration for Flow discipline layer
   test-cmd: "bash -c 'cid=$(tr -d \" \\r\\n\" < cards/.inflight 2>/dev/null); if [[ \"$cid\" =~ ^C-[0-9]+$ ]]; then bash skills/flow/runner/flow.sh check \"$cid\"; else bash skills/flow/runner/flow.sh status; fi'"
   auto-test: true
   ```

6. **For OpenHands (`flow rules openhands [--write]`):**
   Writes project microagent guidance at `.openhands/microagents/flow.md` (requires a project-local runner `skills/flow/runner/flow.sh` already present inside the container).

7. **For GitHub Copilot (`flow rules copilot [--write]`):**
   Writes `.github/copilot-instructions.md`.
---

## 6. Authenticity Verification Protocol (The 4-Point Gate Test)

Before declaring any harness "Supported" in official documentation or marketing, the integration must pass the following 4-point verification battery:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   4-POINT HARNESS VERIFICATION BATTERY                 │
├────────────────────────────────────────────────────────────────────────┤
│ 1. INGESTION TEST    │ Harness successfully parses rule/skill without  │
│                      │ truncation or syntax rejection.                 │
├──────────────────────┼─────────────────────────────────────────────────┤
│ 2. INVOCATION TEST   │ Agent autonomously runs `flow.sh status` via    │
│                      │ its native terminal tool.                       │
├──────────────────────┼─────────────────────────────────────────────────┤
│ 3. NEGATIVE STOPPING │ Agent encounters an exit code 1 (failed gate)   │
│    TEST              │ and STRICTLY HALTS without writing code.        │
├──────────────────────┼─────────────────────────────────────────────────┤
│ 4. RECEIPT INTEGRITY │ Agent completes a card and commits valid        │
│    TEST              │ world-state evidence to `cards/C-NNN.md`.       │
└──────────────────────┴─────────────────────────────────────────────────┘
```

1. **Ingestion Test:** Does the harness load the file? Check context inspector (Cursor MDC panel, Windsurf rules inspector, Roo mode selector) to confirm the rule is active and not truncated.
2. **Invocation Test:** Does the agent actually call `runner/flow.sh` or `runner/flow.cmd`? Confirm via shell logs that the binary was invoked with arguments.
3. **Negative Stopping Test (Critical):** Artificially introduce a gate failure (e.g., leave an unchecked box `- [ ]` in PRD or set card status to `blocked`). Prompt the agent to advance. **The agent MUST halt and report the gate failure.** If the agent claims success or continues coding, the test FAILS (illusion detected).
4. **Receipt Integrity Test:** Prompt the agent to complete a card. Verify that the agent runs `runner/flow.sh card-done C-NNN`, records world-state evidence, and does not alter Flow templates or runner scripts.

---

## 7. Authoritative References & Technical Documentation

1. **Flow Constitution:**
   - `docs/adr/0001-discipline-layer-identity.md` (Flow Discipline Layer Identity, Host-Fired Context Adapters).
2. **Cursor Documentation:**
   - Cursor Rules & MDC Specification: [https://cursor.com/docs/rules](https://cursor.com/docs/rules)
   - Cursor Composer Agent Architecture: [https://cursor.com/docs/agent](https://cursor.com/docs/agent)
3. **Windsurf / Cascade Documentation:**
   - Windsurf Official Portal: [https://codeium.com/windsurf](https://codeium.com/windsurf)
   - Windsurf Rules Documentation: [https://docs.codeium.com/windsurf/rules](https://docs.codeium.com/windsurf/rules)
4. **Cline & Roo Code Documentation:**
   - Roo Code Modes & Custom Rules: [https://github.com/RooVetGit/Roo-Cline](https://github.com/RooVetGit/Roo-Cline)
   - Cline Command Execution Standards: [https://github.com/cline/cline](https://github.com/cline/cline)
5. **Aider Documentation:**
   - Aider Configuration & Testing Hooks: [https://aider.chat/docs/config/aider_conf.html](https://aider.chat/docs/config/aider_conf.html)
   - Options Reference (`test-cmd`, `auto-test`): [https://aider.chat/docs/config/options.html](https://aider.chat/docs/config/options.html)
6. **OpenHands Documentation:**
   - OpenHands Microagents Framework: [https://github.com/All-Hands-AI/OpenHands](https://github.com/All-Hands-AI/OpenHands)
   - CodeActAgent Architecture: [https://docs.all-hands.dev/](https://docs.all-hands.dev/)
7. **Zed Documentation:**
   - Zed Agent Skills Specification: [https://zed.dev/docs/ai/skills](https://zed.dev/docs/ai/skills)
   - Zed Agent Instructions & AGENTS.md: [https://zed.dev/docs/ai/instructions](https://zed.dev/docs/ai/instructions)
   - Zed AI Tool Permissions & Sandboxing: [https://zed.dev/docs/ai/sandboxing](https://zed.dev/docs/ai/sandboxing)
8. **GitHub Copilot Documentation:**
   - Custom Instructions for GitHub Copilot in VS Code: [https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
9. **Amazon Q Developer Documentation:**
   - Amazon Q Developer User Guide: [https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/](https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/)
   - Amazon Q /dev Software Development Agent: [https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/dev-agent.html](https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/dev-agent.html)
   - Amazon Q CLI Reference: [https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/command-line.html](https://docs.aws.amazon.com/amazonq/latest/aws-builder-use-ug/command-line.html)
10. **Devin Documentation (Cognition AI):**
   - Devin Official Portal: [https://cognition.ai](https://cognition.ai)
   - Devin Documentation: [https://docs.devin.ai](https://docs.devin.ai)
11. **Augment Code Documentation:**
   - Augment Code Official Portal & Documentation: [https://docs.augmentcode.com](https://docs.augmentcode.com)
12. **Tabnine Documentation:**
   - Tabnine Official Portal & Documentation: [https://docs.tabnine.com](https://docs.tabnine.com)
13. **Plandex Documentation:**
   - Plandex Official Portal: [https://plandex.ai](https://plandex.ai)
   - Plandex GitHub Repository: [https://github.com/plandex-ai/plandex](https://github.com/plandex-ai/plandex)
   - Plandex Documentation: [https://docs.plandex.ai](https://docs.plandex.ai)
14. **Trae Documentation & Official Site:**
   - **Trae Documentation & Official Site:** https://www.trae.ai · https://docs.trae.ai (ByteDance, accessed 2026-10-15)
