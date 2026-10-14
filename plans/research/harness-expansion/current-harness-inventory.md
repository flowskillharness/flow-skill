# Flow Current Harness, Agent, and Target Inventory

- **Date:** 2026-10-14
- **Audit Target:** Flow repository harness, agent, and target support
- **Audit Scope:** Complete codebase review across installers, runners, detection scripts, test suites, doctor checks, dispatch rules, and host hooks
- **Output File:** `plans/research/harness-expansion/current-harness-inventory.md`

---

## 1. Executive Summary & Inventory Overview

Flow is designed as a **Discipline Layer** (`docs/adr/0001-discipline-layer-identity.md`) rather than an agent runtime. It orchestrates the software engineering lifecycle:
$$\text{Idea} \rightarrow \text{Research} \rightarrow \text{Scope} \rightarrow \text{PRD} \rightarrow \text{ADR} \rightarrow \text{Contract} \rightarrow \text{Cards} \rightarrow \text{Build} \rightarrow \text{Review} \rightarrow \text{Deploy} \rightarrow \text{Verify-live} \rightarrow \text{Retro}$$

Flow never runs as a persistent daemon or background process. Instead, it relies on hosting agents and operators executing deterministic runner commands (`flow.sh` or `flow.cmd`) and honoring gate verdicts.

### 1.1 Support Matrix Summary

| Harness / Target Name | Installer Support (`npm-wrapper`) | Shell Installer (`install.sh`) | PowerShell Installer (`install.ps1`) | Doctor Detection (`install_homes`) | Host Hooks (`adapter-hooks`) | Invocation Style | Primary Global Path |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Claude Code** (`claude`) | **Full** (alwaysInclude, projectScopeAllowed) | **Full** (default) | **Full** (default) | **Full** | **Supported** (`SessionStart`, `PreCompact`) | Slash command: `/flow <verb>` | `~/.claude/skills/flow` |
| **Codex CLI** (`codex`) | **Full** | **Full** | **Full** | **Full** | Probed fallback path; hooks not supported | Prefix: `$flow <verb>` | `~/.codex/skills/flow` |
| **Agents Home** (`agents`) | **Full** (universal standard) | **Full** | **Full** | **Full** | Probed fallback path; hooks not supported | Tool-specific auto-discovery | `~/.agents/skills/flow` |
| **Antigravity** (`antigravity`) | **Full** (dual dest: CLI + IDE) | **Full** (dual dest: CLI + IDE) | **Full** (dual dest: CLI + IDE) | **Full** (reports CLI & Config separately) | Not supported; missing from hook search | Slash command: `/flow <verb>` / `agy` prompt | `~/.gemini/antigravity-cli/skills/flow` & `~/.gemini/config/skills/flow` |
| **OMP** (`omp`) | **Full** | **Full** | **Full** | **Full** | Probed fallback path; hooks inactive | Direct agent invocation: `flow` / `/flow` | `~/.omp/agent/skills/flow` |
| **Cursor** (`cursor`) | **Full** (npm-wrapper only) | <span style="color:red">**MISSING**</span> | <span style="color:red">**MISSING**</span> | <span style="color:red">**MISSING**</span> | Not supported; missing from hook search | Agent panel / Composer prompt | `~/.cursor/skills/flow` |

---

## 2. Exhaustive Implementation Audit by Component

### 2.1 Detection Engine: `npm-wrapper/src/constants.mjs` & `npm-wrapper/src/detect.mjs`

#### Target Definitions (`npm-wrapper/src/constants.mjs:3-73`)
The npm installer defines 6 distinct targets in `TARGETS`:

1. **`claude`** (`constants.mjs:4-12`):
   - `label`: `'Claude Code'`
   - `markers`: `['.claude']` (relative to `os.homedir()`)
   - `destTemplates`: `['~/.claude/skills/flow']`
   - `alwaysInclude`: `true` (always preselected in default selection)
   - `projectScopeAllowed`: `true` (only target permitted for `--project`)

2. **`codex`** (`constants.mjs:13-20`):
   - `label`: `'Codex CLI'`
   - `markers`: `['.codex/skills']`
   - `destTemplates`: `['~/.codex/skills/flow']`
   - `alwaysInclude`: `false`
   - `projectScopeAllowed`: `false`

3. **`agents`** (`constants.mjs:21-30`):
   - `label`: `'Agents home (~/.agents) — universal Agent-Skills home'`
   - `markers`: `['.agents/skills']`
   - `destTemplates`: `['~/.agents/skills/flow']`
   - `alwaysInclude`: `false`
   - `projectScopeAllowed`: `false`

4. **`antigravity`** (`constants.mjs:31-42`):
   - `label`: `'Antigravity (CLI + IDE)'`
   - `markers`: `['.gemini/antigravity-cli', '.gemini/config/skills']`
   - `destTemplates`: `['~/.gemini/antigravity-cli/skills/flow', '~/.gemini/config/skills/flow']`
   - `alwaysInclude`: `false`
   - `projectScopeAllowed`: `false`
   - *Design guard:* Never stats bare `~/.gemini` because that directory is shared by the Google Gemini CLI without Antigravity tooling.

5. **`cursor`** (`constants.mjs:43-57`):
   - `label`: `'Cursor'`
   - `markers`: `['.cursor/skills']`
   - `destTemplates`: `['~/.cursor/skills/flow']`
   - `alwaysInclude`: `false`
   - `projectScopeAllowed`: `false`
   - *Design guard:* Bare `~/.cursor` is rejected because it contains general editor configuration, settings, caches, and `argv.json`. Only `.cursor/skills` proves skill capability.

6. **`omp`** (`constants.mjs:58-72`):
   - `label`: `'OMP (~/.omp/agent/skills)'`
   - `markers`: `['.omp/agent/skills']`
   - `destTemplates`: `['~/.omp/agent/skills/flow']`
   - `alwaysInclude`: `false`
   - `projectScopeAllowed`: `false`
   - *Design guard:* Bare `~/.omp` contains logs, run state, and cache; only `.omp/agent/skills` indicates genuine agent skill installation.

#### Detection Logic (`npm-wrapper/src/detect.mjs`)
- `resolveDest(template, home)` (`detect.mjs:11-15`): Expands `~/` against `home` via `join(home, ...rest)` to avoid mixed separators on Windows.
- `detectAll({ home = homedir() })` (`detect.mjs:18-30`): Maps over `TARGETS`, checking existence of any marker via `statSync(join(home, m))`. Returns array of objects containing `{ ...t, detected, dests }`.
- `defaultSelection(entries)` (`detect.mjs:34-36`): Filters entries where `e.alwaysInclude || e.detected` and extracts target names.

#### Unit Test Verification (`npm-wrapper/test/detect.test.mjs`)
- `empty home`: Only `claude` is included in default selection (`detect.test.mjs:14-28`).
- `~/.claude present`: Claude is both `detected: true` and `alwaysInclude: true` (`detect.test.mjs:30-37`).
- `~/.codex/skills present`: Codex is `detected: true` (`detect.test.mjs:39-49`).
- `~/.gemini` alone: Does NOT trigger Antigravity (`detect.test.mjs:51-59`).
- `~/.gemini/antigravity-cli` or `~/.gemini/config/skills`: Triggers Antigravity (`detect.test.mjs:61-75`).
- `~/.cursor` bare: Does NOT trigger Cursor (`detect.test.mjs:84-92`).
- `~/.cursor/skills`: Triggers Cursor, dest is `~/.cursor/skills/flow` (`detect.test.mjs:94-102`).
- `~/.omp` bare: Does NOT trigger OMP (`detect.test.mjs:108-117`).
- `~/.omp/agent/skills`: Triggers OMP, dest is `~/.omp/agent/skills/flow` (`detect.test.mjs:119-129`).
- Multi-destination validation: Confirms Antigravity generates two distinct destinations (`detect.test.mjs:145-147`).

---

### 2.2 CLI & Installer Engine: `npm-wrapper/bin/cli.mjs` & `npm-wrapper/src/installer.mjs`

#### CLI Flags & Execution (`npm-wrapper/bin/cli.mjs`)
- **Node runtime guard** (`cli.mjs:23-36`): Enforces minimum Node version `22.14.0` at runtime (Node 20 EOL passed April 2026; npm >=11.5.1 bundled).
- **Options** (`cli.mjs:41-52`):
  - `-y, --yes`: Non-interactive default install (`alwaysInclude` + `detected`).
  - `-t, --target <name>`: Explicit target selection (repeatable or comma-separated).
  - `--all`: Installs to all 6 targets regardless of detection.
  - `--project`: Project scope install (restricted to `claude`).
  - `--dir <path>`: Project directory (defaults to `process.cwd()`).
  - `--json`: Emits newline-delimited JSON events (`plan`, `install:start`, `install:done`, `summary`).
  - `--dry-run`: Prints execution plan without modifying filesystem.
  - `-h, --help`: Displays CLI help (`npm-wrapper/src/help.mjs`).
- **Scope Enforcement** (`cli.mjs:112-119`):
  `enforceProjectScope()` drops any target where `projectScopeAllowed !== true`. When `--project` is set, only `claude` is retained; any non-claude target produces an error exit (code 2).
- **Destination Mapping** (`cli.mjs:122-130`):
  - Project scope: `[join(projectDir, '.claude', 'skills', 'flow')]`.
  - Global scope: Uses `t.dests` from `constants.mjs`.
- **Target Restart Hints** (`cli.mjs:154-167`):
  - `claude`: `Claude Code: type /flow`
  - `codex`: `Codex CLI: type $flow (restart Codex once to load a new skill)`
  - `antigravity`: `Antigravity: restart/reload the IDE (or restart agy) to load the new skill, then type /flow`
  - `agents`: `Agents home (~/.agents/skills/): restart/reload your tool if it does not auto-detect new skills`
  - `cursor`: `Cursor: restart/reload Cursor to load the new skill, then check the Agent panel for flow`
  - `omp`: `OMP: restart/reload the runtime to load the new skill, then invoke flow`

#### Files Placed & Transactional Mechanics (`npm-wrapper/src/installer.mjs`)
- **Source Directory**: `skills/flow` bundled within the package (`cli.mjs:15`).
- **Files Placed in Destination**:
  - `SKILL.md`: Main entrypoint metadata.
  - `runner/`: Runner engine (`flow.sh`, `flow.cmd`, `doctor_helper.py`, `installer_helper.py`, `doctor-checks.tsv`, etc.).
  - `references/`: Complete reference documentation (gates, dispatch, auto-run, etc.).
  - `law/`: Immutable rules (`CLAUDE.md`, `CODING.md`, `DESIGN.md`, `RETRO.md`).
  - `_templates/`: Stage and card markdown templates.
  - `adapter-hooks/`: Lifecycle hooks for Claude (`flow-context-handler`, `context_handler.py`, `claude-settings-snippet.json`).
  - `harness/`: Durable layer CLI and migration scripts.
  - `manifest-hashes.json`: Cryptographic SHA-256 ownership receipt (`installer.mjs:16`).
- **Transactional Protocol**:
  - Advisory lock (`.flow-install.lock`) with PID staleness detection (`installer.mjs:62-109`).
  - Strict symlink checks (`assertNoSymlinks`, `assertNoAncestorSymlinks`, `assertNoDestSymlinks`) (`installer.mjs:48-59, 338-394`).
  - Preservation of user-customized files not listed in the receipt (`installer.mjs:437`).
  - Staging candidate directory creation (`mkdtempSync`), rename-only atomic promotion, and rollback on verification failure (`installer.mjs:700-750`).
  - Dual-destination handling for Antigravity (`installAntigravity`, lines 839-877): each destination operates as an independent transaction.

---

### 2.3 Shell & PowerShell Installers: `install.sh` & `install.ps1`

#### `install.sh` Implementation
- **Modes** (`install.sh:3, 11-12, 263-299`):
  - `bash install.sh global [claude|codex|agents|antigravity|omp|all]`
  - `bash install.sh project [dir]` (installs to `<dir|pwd>/.claude/skills/flow`)
- **Detection & Paths**:
  - `claude`: `${HOME}/.claude/skills/flow` (always installed on `all` or `claude`).
  - `codex`: `${HOME}/.codex/skills/flow` (if targeted or `[ -d "${HOME}/.codex/skills" ]`).
  - `agents`: `${HOME}/.agents/skills/flow` (if targeted or `[ -d "${HOME}/.agents/skills" ]`).
  - `antigravity`: Installs to both `${HOME}/.gemini/antigravity-cli/skills/flow` AND `${HOME}/.gemini/config/skills/flow`.
    - **Detection heuristic (`install.sh:276`):** `[ -d "${HOME}/.gemini" ]`.
    - **Defect / Inconsistency:** Uses bare `~/.gemini` directory check, which violates the safer marker discipline in `constants.mjs`.
  - `omp`: `${HOME}/.omp/agent/skills/flow`.
    - **Detection heuristic (`install.sh:283`):** `[ -d "${HOME}/.omp/agent/skills" ]`.
- **Post-Install Verification (`install.sh:304-306`)**:
  Executes `bash "$LAST/runner/flow.sh" doctor || true`.
- **Critical Gap:** `cursor` is **completely absent** from `install.sh`.

#### `install.ps1` Implementation
- **Modes** (`install.ps1:10-11, 218-248`):
  - `pwsh install.ps1 global [claude|codex|agents|antigravity|omp|all]`
  - `pwsh install.ps1 project [dir]` (installs to `<dir|pwd>/.claude/skills/flow`)
- **Detection & Paths**:
  - User home resolution (`install.ps1:42`): `$env:HOME`, then `$env:USERPROFILE`, then `$HOME`.
  - `claude`: `Join-Path $UserHome '.claude/skills/flow'` (always).
  - `codex`: `Join-Path $UserHome '.codex/skills/flow'` (if targeted or `Test-Path ... '.codex/skills'`).
  - `agents`: `Join-Path $UserHome '.agents/skills/flow'` (if targeted or `Test-Path ... '.agents/skills'`).
  - `antigravity`: Installs to both `.gemini/antigravity-cli/skills/flow` and `.gemini/config/skills/flow`.
    - **Detection heuristic (`install.ps1:235`):** `Test-Path (Join-Path $UserHome '.gemini')` (bare `.gemini` check).
  - `omp`: `Join-Path $UserHome '.omp/agent/skills/flow'` (if targeted or `Test-Path ... '.omp/agent/skills'`).
- **Windows Runner Discovery (`install.ps1:251-266`)**:
  Probes explicitly for Git Bash:
  - `$env:ProgramFiles\Git\bin\bash.exe`
  - `${env:ProgramFiles(x86)}\Git\bin\bash.exe`
  - `$env:LOCALAPPDATA\Programs\Git\bin\bash.exe`
  Warns if Git Bash is missing because Windows WSL bash cannot handle `C:/` paths.
- **Critical Gap:** `cursor` is **completely absent** from `install.ps1`.

---

### 2.4 Documented Support Matrix: `skills/flow/references/agent-detection.md`

`agent-detection.md` defines how Flow orchestrates host agents and specialist roles:
- **Built-in First Principle (`agent-detection.md:7-20`)**: Inline/generic execution path is always available. Flow never assumes a proprietary multiplexer or specific vendor.
- **Agent Name Normalization (`agent-detection.md:11-13`)**: Specialists can be named unprefixed (e.g. `architect`), `ck-` prefixed (`ck:architect` / `ck-architect`), or `ak-` prefixed (`ak:architect` / `ak-architect`). Flow strips prefixes before matching.
- **Priority Ladder per Stage (`agent-detection.md:21-28`)**:
  1. **Host Specialist (Primary):** `planner`, `researcher`, `architect`, `fullstack-developer`, `code-reviewer`, `typescript-reviewer`, `python-reviewer`, `tester`, `ui-ux-designer`, `docs-manager`, `git-manager`, `debugger`, `scout`.
  2. **bmad-* skill (Alternative):** `bmad-prd`, `bmad-create-architecture`, `bmad-spec`, `bmad-create-story`, `bmad-dev-story`, `bmad-code-review`, `bmad-check-implementation-readiness`, `bmad-market-research`, `bmad-technical-research`, `bmad-qa-generate-e2e-tests`.
  3. **Built-in Fallback:** Inline draft by host agent, or spawn generic `Explore` / `general-purpose` / `task` subagent.
- **Cross-Vendor Second Engine: OpenAI Codex (`agent-detection.md:29-60`)**:
  - Roles: Deadlock rescue (`codex:codex-rescue`), cross-model review (`codex-companion.mjs review`), opt-in primary drafting.
  - States: **INSTALLED** (`codex:codex-rescue` in registry or `openai-codex` plugin dir) vs **USABLE** (INSTALLED + non-billable `codex-companion.mjs setup --json` returns `ready: true` and `auth.loggedIn: true`).
- **Cross-Vendor Third Engine: Antigravity / Gemini-3 (`agent-detection.md:61-78`)**:
  - Roles: Third independent lens, adversarial review, two-strikes escalation.
  - States: **INSTALLED** (`agy`/IDE/`~/.gemini` present) vs **USABLE** (INSTALLED + non-empty sentinel output on probe).
  - Non-TTY quirk: `agy -p` returns exit code 0 even when unauthenticated. Only non-empty output containing an expected token verifies usability.

---

### 2.5 Doctor Verification: `skills/flow/runner/flow.sh` & `doctor_helper.py`

- **Doctor Check Registration (`skills/flow/runner/doctor-checks.tsv:12`)**:
  - Check #12: `install_homes | install | Static detection of installed agent skill targets`
- **Execution in `skills/flow/runner/flow.sh:3127-3145`**:
  ```bash
  # 12. install_homes
  if _run_check "install_homes"; then
    local homes_found=""
    [ -d "$HOME/.claude/skills/flow" ] && homes_found="${homes_found:+$homes_found, }claude ($HOME/.claude/skills/flow)"
    [ -d "$HOME/.codex/skills/flow" ] && homes_found="${homes_found:+$homes_found, }codex ($HOME/.codex/skills/flow)"
    [ -d "$HOME/.agents/skills/flow" ] && homes_found="${homes_found:+$homes_found, }agents ($HOME/.agents/skills/flow)"
    [ -d "$HOME/.omp/agent/skills/flow" ] && homes_found="${homes_found:+$homes_found, }omp ($HOME/.omp/agent/skills/flow)"
    [ -d "$HOME/.gemini/antigravity-cli/skills/flow" ] && homes_found="${homes_found:+$homes_found, }antigravity-cli ($HOME/.gemini/antigravity-cli/skills/flow)"
    [ -d "$HOME/.gemini/config/skills/flow" ] && homes_found="${homes_found:+$homes_found, }antigravity-config ($HOME/.gemini/config/skills/flow)"
    [ -d "$ROOT/.claude/skills/flow" ] && homes_found="${homes_found:+$homes_found, }project ($ROOT/.claude/skills/flow)"
  ...
  ```
- **Observations & Gaps**:
  - `claude`, `codex`, `agents`, `omp`, `antigravity-cli`, and `antigravity-config` are checked.
  - Project level is only checked for `$ROOT/.claude/skills/flow`.
  - **`cursor` (`$HOME/.cursor/skills/flow`) is completely absent from `install_homes`.** Running `flow doctor` on a system with Flow installed only into Cursor reports: `install homes: none detected (local project or custom path)` (`skip`).

---

### 2.6 Command Dispatch & ClaudeKit Seam: `command-dispatch.md` & `claudekit-skills.md`

#### Command Dispatch (`skills/flow/references/command-dispatch.md`)
- Dispatch flow: User input -> Runner call -> Host duties.
- Core commands:
  - `/flow status`: `bash <skill>/runner/flow.sh status`
  - `/flow resume`: `bash <skill>/runner/flow.sh resume`
  - `/flow next`: `bash <skill>/runner/flow.sh next`
  - `/flow card`: `bash <skill>/runner/flow.sh card`
  - `/flow check C-NNN`: `bash <skill>/runner/flow.sh check C-NNN`
  - `/flow doctor`: `bash <skill>/runner/flow.sh doctor [--list] [--check <csv>] [--json]`
- Windows execution note (`command-dispatch.md:59-61`, `SKILL.md:61-68`):
  On Windows shells (PowerShell, cmd, Codex terminal), bare `bash` invokes WSL, which cannot resolve Windows drive paths (`C:/...`). Commands must run via `<skill-dir>\runner\flow.cmd <cmd>` to route through Git Bash.

#### Capability Seam (`skills/flow/references/claudekit-skills.md`)
- Whitelisted skills matched dynamically via host live registry:
  - `ck-predict` / `ak:predict` / `predict` (ADR stage 04)
  - `ck-scenario` / `ak:scenario` / `scenario` (Contract stage 05)
  - `repomix` / `ak:repomix` (Assess stage 00)
  - `ck-graphify` / `ak:graphify` (Assess/Build)
  - `review-pr` / `ak:review-pr` (Review/Ship)
  - `ck-security` / `ak:security` (Review security-class cards)
  - `security-scan` (Review/Deploy)
  - `retro` / `ak:retro` (Retro stage)
  - `xia` / `ak:xia` (Research/Build)
  - `ghpm` (Verify/Deploy)
  - `deploy` / `ak:deploy` (Deploy stage)
  - `web-testing` / `ak:web-testing` (Verify-live stage)
  - `docs-seeker` / `ak:docs-seeker` (Research/Build)
  - `scout` / `ak:scout` (Assess/any)
  - `ck-loop` / `ak:loop` (Build/Verify loop)
- Design rule (`claudekit-skills.md:25-37`): Skills **inform** the stage; `flow.sh` and `gate-rules.md` **judge** it. A missing skill never lowers a gate; it degrades to native rituals (`references/native-rituals.md`).

---

### 2.7 Lifecycle Context Adapters: `skills/flow/adapter-hooks/`

- **Purpose (`references/host-hooks.md:1-24`)**:
  Connects host lifecycle events (`SessionStart`, `PreCompact`) to Flow status without modifying the gate engine.
- **Claude Code Settings Snippet (`claude-settings-snippet.json`)**:
  Registers `flow-context-handler` under Claude Code's `hooks.SessionStart` and `hooks.PreCompact`.
- **Search Path Probing (`context_handler.py:271-280`)**:
  ```python
  base = _normalize_win_path(os.environ.get("FLOW_SKILL_DIR") or "")
  if not base:
      home = _normalize_win_path(os.environ.get("HOME", ""))
      for cand in (
          os.path.join(home, ".claude", "skills", "flow"),
          os.path.join(home, ".codex", "skills", "flow"),
          os.path.join(home, ".agents", "skills", "flow"),
          os.path.join(home, ".omp", "agent", "skills", "flow"),
      ):
          if os.path.isfile(os.path.join(cand, "runner", "flow.sh")):
              base = cand
              break
  ```
- **Gaps:** `context_handler.py` probes `.claude`, `.codex`, `.agents`, and `.omp/agent`, but **omits `.gemini` (Antigravity) and `.cursor`**.

---

## 3. Detailed Per-Harness Profiles

### 3.1 Claude Code

- **Category:** Primary First-Party Harness (Anthropic)
- **Files & Paths**:
  - Global home: `~/.claude/skills/flow` (`constants.mjs:9`, `install.sh:267`, `install.ps1:221`)
  - Project home: `<project-root>/.claude/skills/flow` (`cli.mjs:127`, `install.sh:293`, `install.ps1:246`)
  - Hook configuration: `~/.claude/settings.json` or `.claude/settings.json` (`host-hooks.md:27-31`)
  - Usage log: `~/.claude/flow/usage.jsonl` (`harness/README.md:146`)
  - Playbook promotion: `~/.claude/flow/playbooks/` (`command-dispatch.md:39`)
- **Detection Heuristics**:
  - Marker: Presence of `~/.claude` (`constants.mjs:8`).
  - Preselection: `alwaysInclude: true` (`constants.mjs:10`). Even if `~/.claude` does not exist, `claude` is always selected in default installer plans.
- **Invocation Style**:
  - Native slash command: `/flow`, `/flow next`, `/flow card`, `/flow check C-NNN`.
  - Subagents: Invokes in-process agents via `Task` tool (e.g., `planner`, `researcher`, `code-reviewer`).
- **Platform Quirks & Limitations**:
  - On macOS/Linux, executes directly via `bash <skill>/runner/flow.sh`.
  - On Windows cmd/PowerShell, Claude Code requires `flow.cmd` because bare `bash` invokes WSL, which fails on Windows absolute paths.

---

### 3.2 OpenAI Codex CLI & Plugin

- **Category:** Secondary Engine / Headless CLI (OpenAI GPT-5.x)
- **Files & Paths**:
  - Global home: `~/.codex/skills/flow` (`constants.mjs:17`, `install.sh:271`, `install.ps1:225`)
  - Project home: Not supported in installer (`projectScopeAllowed: false`).
  - Plugin location (when used as Claude plugin): `~/.claude/plugins/cache/openai-codex/...` (`codex-integration.md:20-22`).
- **Detection Heuristics**:
  - Marker: Presence of `~/.codex/skills` (`constants.mjs:16`, `install.sh:271`, `install.ps1:225`).
  - Bare `~/.codex` is not used as a marker; requires the `skills` subdirectory.
  - Usability check for companion plugin: `codex-companion.mjs setup --json` must return `ready: true` and `auth.loggedIn: true` (`codex-integration.md:24-27`).
- **Invocation Style**:
  - In Codex CLI: Prefix prompt `$flow <verb>` (e.g. `$flow status`, `$flow next`).
  - As Claude Code subagent: `Task(subagent_type="codex:codex-rescue", prompt=...)`.
  - As cross-model review lens: `node "$CODEX/scripts/codex-companion.mjs" review ...`.
- **Platform Quirks & Limitations**:
  - Requires session restart to load newly installed skills (`cli.mjs:156`).
  - Under Windows, Codex CLI defaults to cmd/PowerShell where `bash` calls WSL. Codex must execute `flow.cmd`.

---

### 3.3 Google Antigravity (Gemini-3 CLI + IDE)

- **Category:** Third Engine / Dual-Environment Harness (Google DeepMind)
- **Files & Paths**:
  - CLI Home: `~/.gemini/antigravity-cli/skills/flow` (`constants.mjs:37`)
  - IDE Home: `~/.gemini/config/skills/flow` (`constants.mjs:38`)
  - Binary locations: `agy` on `PATH` or `~/AppData/Local/agy/bin/agy`; IDE at `~/AppData/Local/Programs/Antigravity` (`antigravity-integration.md:23-24`).
- **Detection Heuristics**:
  - `npm-wrapper`: Requires either `.gemini/antigravity-cli` OR `.gemini/config/skills` (`constants.mjs:35`). Rejects bare `~/.gemini`.
  - `install.sh` / `install.ps1`: Stat bare `~/.gemini` (`install.sh:276`, `install.ps1:235`). **(Inconsistency with npm installer)**.
  - Usability probe: Must execute a probe and verify non-empty expected token in stdout (`antigravity-integration.md:25-28`).
- **Invocation Style**:
  - Slash command in IDE: `/flow <verb>`.
  - Headless CLI: `agy -p "<prompt>"`.
  - Interactive mode (supported default): Operator runs review in IDE Agent Manager and pastes `ReviewResult` back (`antigravity-integration.md:32-37`).
- **Platform Quirks & Limitations**:
  - **Lying Exit Code:** `agy -p` returns exit code 0 even when unauthenticated ("You are not logged into Antigravity"); error only appears in `--log-file`. Non-TTY stdout capture is empty in headless pipes and winpty on Windows Git Bash.
  - Two global destinations must be managed independently; failure in one must not corrupt the other (`installer.mjs:839-877`).

---

### 3.4 OMP (Oh My Pi)

- **Category:** Autonomous Terminal Agent Runtime
- **Files & Paths**:
  - Global home: `~/.omp/agent/skills/flow` (`constants.mjs:68`, `install.sh:284`, `install.ps1:240`)
  - Subagent roster: Uses `task` tool with `agent` selectors (`researcher`, `debugger`, `sonic`, `planner`, etc.).
- **Detection Heuristics**:
  - Marker: Presence of `~/.omp/agent/skills` (`constants.mjs:67`, `install.sh:283`, `install.ps1:239`).
  - Bare `~/.omp` rejected because it holds general caches, logs, and session sockets.
- **Invocation Style**:
  - Invocation via agent prompt: `invoke flow`, `/flow <verb>`, or direct bash execution of `runner/flow.sh`.
- **Platform Quirks & Limitations**:
  - OMP lifecycle hooks ship inactive on observed installs; `host-hooks.md` explicitly disclaims live OMP hook support (`host-hooks.md:49`).
  - Requires reload/restart to index newly placed skills.

---

### 3.5 Universal Agents Home (`~/.agents`)

- **Category:** Open Universal Standard (`agentskills.io` specification)
- **Files & Paths**:
  - Global home: `~/.agents/skills/flow` (`constants.mjs:26`, `install.sh:272`, `install.ps1:230`)
- **Detection Heuristics**:
  - Marker: Presence of `~/.agents/skills` (`constants.mjs:25`).
- **Invocation Style**:
  - Universal discovery by compliant runtimes (32+ compliant tools including Devin, Cursor symlinks, etc.).
- **Platform Quirks & Limitations**:
  - Acts as a shared storage hub. Some tools (like Cursor) create symlinks from their local configuration into `~/.agents/skills/`.

---

### 3.6 Cursor

- **Category:** AI Code Editor (Composer / Agent)
- **Files & Paths**:
  - Global home: `~/.cursor/skills/flow` (`constants.mjs:53`)
  - Live layout: On actual systems, `~/.cursor/skills/<name>` is frequently populated as a symlink pointing to `~/.agents/skills/<name>` (`constants.mjs:48-51`).
- **Detection Heuristics**:
  - Marker in `npm-wrapper`: `~/.cursor/skills` (`constants.mjs:52`).
  - Bare `~/.cursor` rejected (editor settings, caches, telemetry).
- **Invocation Style**:
  - Natural language or slash command inside Cursor Composer / Agent panel.
- **Gaps & Discrepancies**:
  - **Missing from `install.sh`**: Cannot be installed via bash script.
  - **Missing from `install.ps1`**: Cannot be installed via PowerShell script.
  - **Missing from `flow.sh doctor`**: `install_homes` check #12 does not inspect `~/.cursor/skills/flow`.
  - **Missing from `adapter-hooks`**: `context_handler.py` does not include Cursor in candidate probing.
  - No headless CLI probe exists for Cursor to verify skill discovery post-install (`cli.mjs:163-165`).

---

## 4. Cross-Harness Comparison & Gap Matrix

The following matrix highlights the exact implementation coverage and identifies critical discrepancies across the codebase:

```
┌─────────────────┬──────────────────┬────────────────┬─────────────────┬─────────────────┬──────────────────┐
│ Harness         │ npm-wrapper      │ install.sh     │ install.ps1     │ flow.sh doctor  │ context_handler  │
├─────────────────┼──────────────────┼────────────────┼─────────────────┼─────────────────┼──────────────────┤
│ Claude Code     │ YES (Always)     │ YES (Always)   │ YES (Always)    │ YES             │ YES              │
│ Codex           │ YES (Marker)     │ YES (Marker)   │ YES (Marker)    │ YES             │ YES              │
│ Agents Home     │ YES (Marker)     │ YES (Marker)   │ YES (Marker)    │ YES             │ YES              │
│ Antigravity     │ YES (Safe Subdir)│ YES (Bare Dir!)│ YES (Bare Dir!) │ YES (Dual Dest) │ NO (Missing)     │
│ OMP             │ YES (Safe Subdir)│ YES (Safe Sub) │ YES (Safe Sub)  │ YES             │ YES              │
│ Cursor          │ YES (Safe Subdir)│ NO (MISSING)   │ NO (MISSING)    │ NO (MISSING)    │ NO (Missing)     │
└─────────────────┴──────────────────┴────────────────┴─────────────────┴─────────────────┴──────────────────┘
```

### Key Technical Gaps Identified

1. **Cursor Omission Across Native Scripts**:
   - Cursor was added to `npm-wrapper` in v0.23 (`constants.mjs`, `detect.mjs`, `cli.mjs`), but the shell scripts (`install.sh`, `install.ps1`) and the doctor check (`skills/flow/runner/flow.sh:3127-3145`) were never updated.
   - Consequence: Users installing via `bash install.sh global all` or checking health via `/flow doctor` get false-negative reporting on Cursor.

2. **Antigravity Marker Discrepancy**:
   - `npm-wrapper/src/constants.mjs:35` strictly requires `.gemini/antigravity-cli` or `.gemini/config/skills` to avoid false positives on systems with vanilla Google Gemini CLI.
   - `install.sh:276` and `install.ps1:235` check bare `~/.gemini`.
   - Consequence: Running `bash install.sh global all` on a machine with only the Gemini CLI creates unwanted Antigravity skill folders.

3. **Adapter Hook Search Gaps (`skills/flow/adapter-hooks/context_handler.py:276-278`)**:
   - When `FLOW_SKILL_DIR` is not explicitly exported, the hook handler scans:
     `~/.claude/skills/flow`, `~/.codex/skills/flow`, `~/.agents/skills/flow`, `~/.omp/agent/skills/flow`.
   - It omits `~/.gemini/antigravity-cli/skills/flow`, `~/.gemini/config/skills/flow`, and `~/.cursor/skills/flow`.

4. **Windows Pathing & WSL Traps**:
   - On Windows, bare `bash` invokes WSL, which fails on Windows filesystem paths (`C:/...`).
   - `flow.cmd` solves this for interactive terminals and Codex by locating Git Bash.
   - PowerShell installer (`install.ps1:251-266`) checks for Git Bash, but if Git Bash is missing, `flow.sh doctor` cannot run.

---

## 5. Summary & Next Steps for Harness Expansion

Flow's current codebase demonstrates high architectural discipline around immutability, receipt verification, and fail-open execution. However, harness support is unevenly synchronized between the modern npm installer and legacy shell/runner scripts.

### Priorities for Future Harness Expansion:
1. **Synchronize Cursor**: Bring `install.sh`, `install.ps1`, `flow.sh` doctor check 12, and `context_handler.py` to parity with `npm-wrapper`.
2. **Align Antigravity Marker**: Update `install.sh` and `install.ps1` to test subdirectories instead of bare `~/.gemini`.
3. **Expand Tier-1 Market Harnesses**: Implement candidate profiles from `plans/research/harness-expansion/market-harness-survey.md` (Cursor rules, Windsurf Cascade, Roo Code, Cline) while adhering strictly to ADR-0001 principles (no daemons, no tool interposition, honest execution via `runner/flow.sh`).
