# Market Harness Survey: Expanding Flow to Leading Coding-Agent Harnesses

- **Status:** Complete Technical Deliverable
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
- **Tier 1 (Immediate Native Harness Support):** Harness natively possesses clean file placement (global skills or project rule hooks) AND autonomous/semi-autonomous terminal tool execution. The agent can run `flow.sh` directly.
- **Tier 2 (Project-Level Rule / Config Support):** Harness operates primarily via project-level configuration (`.windsurf/rules/`, `.roomodes`, `.aider.conf.yml`, `.github/copilot-instructions.md`) and can execute commands when operating in agent mode or paired with terminal hooks.
- **Tier 3 (Incompatible or Deferred):** Harness lacks terminal execution capability, requires a persistent background daemon/server (forbidden by ADR 0001), or only supports conversational chat with no tool invocation.

---

## 2. Comprehensive Candidate Investigations

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             MARKET HARNESS SPECTRUM                              │
├──────────────────────┬────────────────────────┬──────────────────────────────────┤
│ TIER 1: Native Auto  │ TIER 2: Project Rules  │ TIER 3: Deferred / Constrained   │
├──────────────────────┼────────────────────────┼──────────────────────────────────┤
│ • Cursor (Composer)  │ • Windsurf (Cascade)   │ • GitHub Copilot CLI (no loop)   │
│ • Roo Code (Modes)   │ • Cline (.clinerules)  │ • Zed Inline Editor (no bash)    │
│ • Zed Agent (Skills) │ • Aider (Test Hook)    │                                  │
│                      │ • OpenHands (Docker)   │                                  │
│                      │ • Copilot VSCode Agent │                                  │
└──────────────────────┴────────────────────────┴──────────────────────────────────┘
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
      alwaysApply: true
      ---
      ```
    - `alwaysApply: true` ensures the discipline rules are loaded into every Composer session regardless of open files.
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
  - Global skill in `~/.cursor/skills/flow/SKILL.md` (or project rule `.cursor/rules/flow.mdc` with `alwaysApply: true`).
  - Rule explicitly instructs Composer Agent: *"Before creating or modifying code, run `bash runner/flow.sh status` and `bash runner/flow.sh check`. When working on card C-NNN, verify gate exit codes. An exit code $\neq 0$ is a strict STOP."*
  - Tested in Composer Agent mode with terminal auto-run enabled.
- **The Marketing Illusion to Avoid:**
  - Putting a generic `.cursorrules` file in a project where the user only uses basic Cursor Chat (Cmd+L) without Agent mode. In standard Chat, Cursor cannot execute shell commands, leading to hallucinated gate passes.
- **Feasibility Verdict:** **Tier 1 (Immediate Native Support).**

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
- **Feasibility Verdict:** **Tier 1 for Roo Code (via `.roomodes`) / Tier 2 for Cline (via `.clinerules`).**

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
    read:
      - ".flow/rules.md"
    test-cmd: "bash skills/flow/runner/flow.sh check"
    auto-test: true
    lint-cmd: "bash skills/flow/runner/flow.sh status"
    ```
- **Conventions File:** `CONVENTIONS.md` placed at repo root (standard conventions file read by Aider).
- **Prompt Injection:** `--system-prompt-file` or `system-prompt-file` setting in `.aider.conf.yml`.

#### 3. Execution Capability & Terminal Autonomy
- Aider is an **interactive pair programmer**, not an unprompted autonomous loop agent.
- It executes terminal commands through:
  1. `test-cmd`: Run via `/test` or automatically after file edits when `auto-test: true`.
  2. `lint-cmd`: Run via `/lint`.
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
  - Does *not* have an instruction ingestion mechanism or agentic loop. It only suggests one-off shell commands.

#### 3. Execution Capability & Terminal Autonomy
- In VS Code **Copilot Agent Mode**, Copilot can propose terminal commands to run in the VS Code terminal.
- However, execution is **semi-autonomous**: commands typically require manual user confirmation (clicking "Run" or pressing Enter). It lacks an autonomous loop for iterative self-correction across multiple subagents.
- Copilot CLI has zero autonomous execution capability.

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
  - Advertising "Full Autonomous Buildflow in GitHub Copilot". Copilot Agent Mode cannot run the complete Idea->Retro pipeline autonomously without constant human driving. Copilot CLI cannot participate in Flow at all.
- **Feasibility Verdict:** **Tier 2 for VS Code Copilot (.github/copilot-instructions.md) / Tier 3 for Copilot CLI (Unsupported).**

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
- **Feasibility Verdict:** **Tier 1 (Immediate Native Support via Universal `~/.agents/skills/flow` + Agent Panel).**

---

## 3. Cross-Harness Comparison & Technical Matrix

| Harness | Primary Configuration | Global Path | Project Path | Terminal Tool | Execution Autonomy | Feasibility Tier |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Cursor** | `.cursor/rules/*.mdc` | `~/.cursor/skills/` | `.cursor/rules/flow.mdc` | `run_terminal_cmd` | Autonomous (YOLO) / Prompted | **Tier 1** |
| **Roo Code** | `.roomodes` (JSON) | N/A (VSCode Storage) | `.roomodes` / `.clinerules` | `execute_command` | Autonomous (Auto-approve) | **Tier 1** |
| **Zed** | `SKILL.md` / `AGENTS.md` | `~/.agents/skills/` | `.agents/skills/` / `AGENTS.md`| `terminal` | Autonomous (Permissions) | **Tier 1** |
| **Windsurf** | `.windsurf/rules/*.md`| `global_rules.md` | `.windsurf/rules/flow.md` | `run_command` | Autonomous / Prompted | **Tier 2** |
| **Cline** | `.clinerules` | N/A (VSCode Storage) | `.clinerules` | `execute_command` | Autonomous (Auto-approve) | **Tier 2** |
| **Aider** | `.aider.conf.yml` | `~/.aider.conf.yml` | `.aider.conf.yml` | `test-cmd` / `/run` | Semi-autonomous (Pair hook) | **Tier 2** |
| **OpenHands** | Microagent (`.md`) | N/A (Isolated Docker) | `.openhands/microagents/` | `execute_bash` | Autonomous (Container) | **Tier 2** |
| **Copilot (VSCode)**| `copilot-instructions.md` | Settings | `.github/copilot-instructions.md` | Terminal proposal | Semi-autonomous (Prompted) | **Tier 2** |
| **Copilot CLI** | None | N/A | N/A | None | Non-agentic (Query only) | **Tier 3** |

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
        └── skills/flow/runner/flow.sh <── MUST BE LOCATED HERE (Project-scoped)
```
- **The Pitfall:** If an installer only places Flow in `~/.claude/` or `~/.agents/` on the developer's laptop, containerized agents like OpenHands will crash with:
  `bash: /home/user/.agents/skills/flow/runner/flow.sh: No such file or directory`.
- **The Requirement:** Flow must provide first-class **project-scoped installation** (`flow-skill install project .`) for containerized and sandboxed harnesses.

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
We expand `TARGETS` with accurate markers and labels:

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

### 5.2 Project-Level Scaffolding Command (`flow init --harness <name>`)
To guarantee "Support Thật", Flow's CLI should provide a command to generate verified project-level rule files:

1. **For Cursor (`--harness cursor`):**
   Writes `.cursor/rules/flow.mdc`:
   ```markdown
   ---
   description: "Flow Gated Build Discipline"
   globs: "flow/**,cards/**,src/**,*.md"
   alwaysApply: true
   ---
   # Flow Discipline Layer
   Before coding, run mechanical gates: `bash runner/flow.sh status` and `bash runner/flow.sh check`.
   ```

2. **For Roo Code (`--harness roo`):**
   Generates or updates `.roomodes` with the dedicated `flow` mode and `"command"` permissions.

3. **For Windsurf (`--harness windsurf`):**
   Writes `.windsurf/rules/flow.md` with concise runner execution rules under 6,000 characters.

4. **For Aider (`--harness aider`):**
   Generates `.aider.conf.yml` with `test-cmd: "bash runner/flow.sh check"` and `auto-test: true`.

5. **For OpenHands (`--harness openhands`):**
   Installs `skills/flow/` into project and writes `.openhands/microagents/flow.md`.

6. **For GitHub Copilot (`--harness copilot`):**
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
   - Windsurf Rules & Memories: [https://docs.devin.ai/desktop/cascade/memories](https://docs.devin.ai/desktop/cascade/memories)
   - Codeium Cascade Customizations: [https://devin.ai/blog/windsurf-wave-8-cascade-customization-features](https://devin.ai/blog/windsurf-wave-8-cascade-customization-features)
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
