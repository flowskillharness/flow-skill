# Architecture Compatibility Matrix: Harness Expansion & ADR-0001 Alignment

- **Document Version:** 1.1.0 (Phase 2 Architectural Synthesis — Evidence-First Revision)
- **Status:** Un-implemented Design Specification (Provisional Candidate Evaluation)
- **Date:** 2026-10-14
- **Target File:** `plans/research/harness-expansion/architecture-compatibility-matrix.md`
- **Constitutional Anchor:** `docs/adr/0001-discipline-layer-identity.md` (Discipline-Layer Identity)
- **Preceding Research:** 
  - `plans/research/harness-expansion/current-harness-inventory.md` (Phase 1 Internal Audit)
  - `plans/research/harness-expansion/market-harness-survey.md` (Phase 1 Market Survey)

---

## 1. Executive Summary & Evidence-First Discipline

This document synthesizes findings from the internal technical audit and market survey into a formal architecture compatibility matrix and implementation roadmap.

### 1.1 Constitutional Invariant & Status Disclosure
Flow’s architectural identity is non-negotiable, governed by **ADR-0001**:
> **Identity Statement:** *"Flow owns the gates and the receipts, never the runtime: a host-agnostic discipline layer that turns any coding agent into an evidence-gated, kill-honest build process — flow never holds the process token."*

**Explicit Design Specification Notice:**
All target expansions, parity additions, and rule scaffolding profiles presented in this document represent **DESIGN PROPOSALS AND ARCHITECTURAL EVALUATIONS ONLY**. They do NOT constitute verified live support. In accordance with Flow's evidence-first discipline, no candidate target will be labeled or advertised as "supported" until it has successfully undergone the mandatory **Four-Point Live Verification Protocol** against a real, running host runtime.

### 1.2 The Four-Point Live Verification Protocol
Before any harness or target can be promoted from *Provisional Candidate* to *Verified Supported*, it must pass four empirical verification gates:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        FOUR-POINT LIVE VERIFICATION PROTOCOL                           │
├─────────────────────────┬──────────────────────────────────────────────────────────────┤
│ 1. Ingestion Check      │ Host runtime actually reads the skill bundle or rule file    │
│                         │ without truncation, character-limit clipping, or JSON errors. │
├─────────────────────────┼──────────────────────────────────────────────────────────────┤
│ 2. Invocation Check     │ Host agent actively invokes `runner/flow.sh` (or `flow.cmd`) │
│                         │ during lifecycle actions (status, next, check, etc.).         │
├─────────────────────────┼──────────────────────────────────────────────────────────────┤
│ 3. Gate-Stop Check      │ Host halts and initiates repair on mechanical exit != 0.     │
│                         │ The agent NEVER hallucinates that a failed gate passed.       │
├─────────────────────────┼──────────────────────────────────────────────────────────────┤
│ 4. State Integrity      │ Verified stage progression artifacts (`flow/01-research.md`  │
│                         │ unlocked, fresh `flow status` readback from disk/git).       │
└─────────────────────────┴──────────────────────────────────────────────────────────────┘
```

---

## 2. Architectural Categorization: Skills vs. Rule Scaffolding

To prevent confusion between directory-level tool extensions and prompt guidelines, all targets across Flow are strictly partitioned into two distinct architectural categories:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                               ARCHITECTURAL PARTITION                                  │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ Category A: Native Skill Targets         │ Category B: Workspace Rule Scaffolding      │
│ (Directory discovery with SKILL.md)      │ (Project-level instruction injection)        │
├──────────────────────────────────────────┼─────────────────────────────────────────────┤
│ • Claude Code (~/.claude/skills/flow)    │ • Cursor Rules (.cursor/rules/*.mdc)        │
│ • Codex CLI (~/.codex/skills/flow)       │ • Windsurf Cascade (.windsurf/rules/*.md)   │
│ • Universal Agents (~/.agents/skills/fl) │ • Cline (.clinerules)                       │
│ • Antigravity CLI & IDE (~/.gemini/...)  │ • Roo Code (.roomodes)                      │
│ • OMP (~/.omp/agent/skills/flow)         │ • Aider (.aider.conf.yml test hook)         │
│ • Cursor Native (~/.cursor/skills/flow)* │ • OpenHands (.openhands/microagents/*.md)   │
│ • Zed (via ~/.agents/skills/flow)        │ • GitHub Copilot (.github/*instructions.md) │
│   *Proposed parity target                │                                             │
│ Nature: Real skill installation. Agent   │ Nature: Markdown instruction guidance.      │
│ runtime registers slash commands/tools.  │ Rule scaffolding is NOT native skill        │
│ Flow codebase placed in dedicated home.  │ installation. Injects prompts into context. │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

---

## 3. Constitutional Audit against ADR-0001

### 3.1 Testable Invariants of ADR-0001
Every harness integration candidate must satisfy the four inviolable rules:
1. **Invocation Invariant:** Every Flow byte executes because a hosting agent or human operator invoked it (`bash <skill>/runner/flow.sh <cmd>` or `<skill>\runner\flow.cmd <cmd>`), and Flow terminates when that invocation returns.
2. **Process Token Invariant:** Flow never holds the process token; it never schedules agent loops or tool dispatches.
3. **No Resident Background Services:** Mechanically forbidden: daemons, servers, background watchers, or lingering threads.
4. **No Tool Interposition:** Flow never wraps or intercepts the host's tool execution pipeline. Flow may re-run checks and verify ground truth; it never sits between the host and the filesystem/terminal.

### 3.2 Rejection of Resident MCP Server Daemons
A recurring suggestion in the ecosystem is exposing Flow as an MCP (Model Context Protocol) server. While MCP tools are well-suited for static queries, implementing Flow as a persistent MCP daemon is **constitutionally rejected** under ADR-0001 for four technical reasons:

1. **State Lifetime & Resident Daemon Prohibition:** An MCP server is a persistent, long-lived background process (resident stdio or SSE server). ADR-0001 explicitly bans resident processes and daemons. Flow state lives in Git, SQLite, and bounded filesystem files (`flow/`, `cards/`, `.flow/`), not in memory heaps.
2. **Execution Path & Tool Interposition:** An MCP wrapper interposes between the LLM and the filesystem/terminal, hiding mechanical execution behind abstract tool calls. Flow requires deterministic, auditable shell execution where the exit code ($0$ or $1$) is the uncheatable ground truth.
3. **Multi-Tenant Concurrency Traps:** Resident daemons create state synchronization hazards across parallel worktrees and terminal tabs. Flow relies on atomic file locking (`.lock` with PID/TTL) and stateless command execution (`flow.sh status`, `flow.sh check`).
4. **Failure Transparency:** If an MCP daemon crashes or desynchronizes, the host agent loses access to the entire discipline layer. By contrast, a plain shell runner (`flow.sh`) is universally invokable, debuggable, and recoverable via standard POSIX pipelines.

*Permissible MCP Exception:* Only ephemeral, single-command or client-invoked MCP bridge tools (where the host controls the lifecycle and Flow terminates immediately) would be constitutionally valid; however, direct shell tool execution is universally supported across modern agents and remains the primary standard.

### 3.3 Provisional Candidate Profiles: Architectural Evaluation

The following table presents the architectural evaluation of candidate harnesses. These are **provisional design profiles**, pending execution of the Four-Point Live Verification Protocol.

| Candidate Harness | Category | Constitutional Compliance | Invariant Adherence Analysis | Provisional Status |
| :--- | :---: | :---: | :--- | :---: |
| **Cursor Native** | A | **PASS** | Installer, doctor, and hook parity implemented on master (`c050950a`). | **Provisional Candidate (Code Parity Verified; Host Trial Pending)** |
| **Zed Assistant** | A | **PASS** | Evaluated as native Agent Skills target (`~/.agents/skills/flow`) + `AGENTS.md`. No pseudo-rules. | **Category A Native Standard (Not Category B Rules)** |
| **Cursor Rules** | B | **PASS** | Workspace rule scaffolding (`.cursor/rules/flow.mdc`). Directs Composer/Agent to run `flow.sh`. | **Provisional Candidate (Rule Scaffold)** |
| **Roo Code** | B | **PASS** | Custom mode prompt (`.roomodes`) with explicit `command` execution group permissions. | **Provisional Candidate (Rule Scaffold)** |
| **Cline** | B | **PASS** | Workspace prompt instructions (`.clinerules`) requesting terminal approval for runner calls. | **Provisional Candidate (Rule Scaffold)** |
| **Windsurf** | B | **PASS** | Compact project rules (`.windsurf/rules/flow.md`, <6,000 chars) directing Cascade execution tool. | **Provisional Candidate (Rule Scaffold)** |
| **Aider** | C | **PASS** | Config hook (`.aider.conf.yml`) setting `test-cmd: "bash runner/flow.sh check"` with `auto-test: true`. | **Provisional Candidate (Test Hook Scaffold)** |
| **OpenHands** | B | **CONDITIONAL** | Microagent prompt (`.openhands/microagents/flow.md`) restricted to project-local paths inside Docker. | **Provisional Candidate (Container Scaffold)** |
| **GitHub Copilot** | B | **CONDITIONAL** | Context instructions (`.github/copilot-instructions.md`) restricted to interactive developer guidance. | **Provisional Candidate (Interactive Guidance)** |


### 3.4 Case Study: Rejection of Pseudo-Rules (`.zed/rules.md`) and Unverified Scaffolding (`continue`) — The Anti-Illusion ("Support Thật") Principle

Flow's constitutional integrity under ADR-0001 requires mechanical honesty. Inventing configuration files that a host runtime never loads constitutes false marketing ("quảng cáo ảo") and an **Illusion Trap**:

#### 1. Why `.zed/rules.md` Was Constitutionally Rejected
- **Non-Existent Target Path:** Zed Editor does not possess a `.zed/rules.md` configuration mechanism or arbitrary `.zed/rules/` directory (Zed documentation confirms no such rules engine; official rules URLs return 404). Creating `.zed/rules.md` produces an inert, unread file.
- **Zed's Authentic Architecture (Category A Native Standard):** Zed integrates natively with the open Agent Skills standard. Zed's agent panel discovers skills from `~/.agents/skills/` (user-level) and `.agents/skills/` (project-level), paired with `AGENTS.md` at workspace root for global instruction prompts.
- **Existing Flow Support:** Flow already installs to `~/.agents/skills/flow` via the `agents` installation target (`npx flow-skill -t agents` or `install.sh -t agents`). Zed uses its native terminal tool to execute `bash runner/flow.sh`.
- **Architectural Verdict:** Zed is strictly **Category A (Native Skill Target + `AGENTS.md`)**. Adding a faux `.zed/rules.md` scaffolding in `flow rules` was rejected as an illusion trap that violates Flow's evidence-first discipline.

#### 2. Why Continue.dev (`continue`) Was Deferred
- **Unverified Schema & Tool-Loop Execution:** Continue.dev features multiple evolving configuration mechanisms (`config.yaml`, `.continue/rules/`, `.continue/prompts/`). More fundamentally, Continue.dev's active tool-loop execution capability (autonomous execution of terminal commands, parsing non-zero exit codes, and halting on gate failure) has not been empirically verified against real running hosts.
- **Architectural Verdict:** Under the Four-Point Live Verification Protocol, scaffolding cannot be added to `flow rules` without authoritative schema documentation and live tool-loop execution verification. Speculative inclusion would introduce unverified, hollow compatibility.

#### 3. Strict Boundary of `flow rules`
`flow rules` is locked to the 7 implemented scaffolding templates (cursor, windsurf, roo, cline, openhands, copilot in Category B; aider in Category C), where templates are mechanically tested locally, while live host and schema behaviors remain provisional pending Phase 4 trials.
### 3.5 Empirical Workstation Runtime Probe & Host-Access Blocker Disclosure

In accordance with Flow's "Support Thật" (Honest Support) discipline, an empirical probe of the host development workstation (Linux x64, 2026-10-14) was executed to determine whether live Phase 4 trials could be run locally:

| Candidate Harness | Host Binary Status | Configuration Path | Live Host Trial Feasibility on Current Workstation |
| :--- | :--- | :--- | :--- |
| **Windsurf Cascade** | `NOT DETECTED` on PATH | `~/.codeium` ABSENT | **BLOCKED on this workstation:** Windsurf binary/config not detected by local probes. Live trials require an operator workstation running Windsurf. |
| **OpenHands** | `docker` NOT DETECTED on PATH | Daemon / socket ABSENT | **BLOCKED for local Docker trial:** Docker runtime not detected by local probes. Container live trials require an environment with Docker and OpenHands. |
| **Zed Editor** | `NOT DETECTED` on PATH | `~/.config/zed` ABSENT | **BLOCKED on this workstation:** Zed binary/config not detected by local probes. Live trials require an operator workstation running Zed. |
| **Cursor** | `cursor` NOT DETECTED on PATH | `~/.cursor/skills` DETECTED | **PROVISIONAL:** Skills directory detected (Flow bundle presence not checked by probe); Composer live trial requires an interactive Cursor session. |
| **Aider** | `aider` NOT DETECTED on PATH | `~/.aider.conf.yml` ABSENT | **BLOCKED on this workstation:** Aider binary/config not detected by local probes. Live test hook trial requires an Aider environment. |

**Constitutional Disclosure:**
Desk evaluations and local test-suite passes (`tests/test_flow_rules.sh`, `pack-rehearsal.sh`) cannot substitute for empirical host verification. All non-Claude/Codex targets remain **Provisional Candidates** until genuine host trials are captured and committed to `plans/research/harness-expansion/evidence/`.
---

## 4. Target Expansion Specification (Design Proposals)

*Notice: Action 1 has been implemented and verified in code on master (`c050950a`). Actions 2 and 3 below remain architectural design specifications pending execution in Phase 3.*

### Action 1: Fix Internal Parity Gap (Cursor Native Skill Target) — [IMPLEMENTED & VERIFIED ON MASTER `c050950a`]
*Category: Category A (Native Skill Target)*

The Phase 1 audit revealed that Cursor was integrated into `npm-wrapper` (`constants.mjs:43-57`), but was omitted from shell scripts (`install.sh`), PowerShell scripts (`install.ps1`), doctor checks (`skills/flow/runner/flow.sh:3127-3145`), and adapter hook search paths (`context_handler.py:276-280`).

**Implementation & Verification Status:**
Action 1 has been implemented on master in commit `c050950a` and verified locally via `tests/test_install_safe_update.sh:43 pass` and `tests/test_flow_doctor.sh:62 pass`. Live four-point runtime gate enforcement remains provisional pending real Cursor Composer/Agent host execution.

#### 1. Shell Installer Parity (`install.sh`)
- **Specification:** Add `cursor` target to `install.sh`:
  ```bash
  # cursor: explicit target or autodetected only when ~/.cursor/skills exists (never bare ~/.cursor)
  if [ "$TARGET" = "cursor" ] || { [ "$TARGET" = "all" ] && [ -d "${HOME}/.cursor/skills" ]; }; then
    install_to "${HOME}/.cursor/skills/flow"
    INSTALLED="$INSTALLED cursor"
  fi
  ```
- **Restart Hint (`done_line`):**
  `cursor) out="$out Cursor: restart/reload Cursor to load the new skill, then check the Agent panel for flow |" ;;`

#### 2. PowerShell Installer Parity (`install.ps1`)
- **Specification:** Add `cursor` target to `install.ps1`:
  ```powershell
  # cursor: explicit target or autodetected only when ~/.cursor/skills exists
  if ($target -eq 'cursor' -or ($target -eq 'all' -and (Test-Path (Join-Path $UserHome '.cursor/skills')))) {
    $last = Install-To (Join-Path $UserHome '.cursor/skills/flow')
    $installed += 'cursor'
  }
  ```
- **Restart Hint (`$RestartHints`):**
  `cursor = 'Cursor: restart/reload Cursor to load the new skill, then check the Agent panel for flow'`

#### 3. Doctor Verification Parity (`skills/flow/runner/flow.sh:3127-3145`)
- **Specification:** Update Check #12 (`install_homes`) in `flow.sh`:
  ```bash
  [ -d "$HOME/.cursor/skills/flow" ] && homes_found="${homes_found:+$homes_found, }cursor ($HOME/.cursor/skills/flow)"
  ```

#### 4. Adapter Hook Parity (`skills/flow/adapter-hooks/context_handler.py:276-280`)
- **Specification:** Include Cursor and Antigravity paths in fallback candidate probing:
  ```python
  for cand in (
      os.path.join(home, ".claude", "skills", "flow"),
      os.path.join(home, ".codex", "skills", "flow"),
      os.path.join(home, ".agents", "skills", "flow"),
      os.path.join(home, ".omp", "agent", "skills", "flow"),
      os.path.join(home, ".cursor", "skills", "flow"),
      os.path.join(home, ".gemini", "antigravity-cli", "skills", "flow"),
      os.path.join(home, ".gemini", "config", "skills", "flow"),
  ):
  ```

---

### Action 2: Universal Native Target & Tier 1 Rule Scaffolding

#### 1. Formalize `zed` Target (Category A: Native Skill Target)
- **Concept:** Zed adheres to the universal Agent Skills standard (`~/.agents/skills/`). Zed reads skills directly from `~/.agents/skills/` and workspace instructions from root `AGENTS.md`. Zed does NOT support `.zed/rules.md` (rejected as an illusion trap).
- **Target Specification in `constants.mjs`**:
  - `name`: `'zed'`
  - `label`: `'Zed Editor (~/.agents/skills/flow via .config/zed)'`
  - `markers`: `['.config/zed', '.agents/skills']`
  - `destTemplates`: `['~/.agents/skills/flow']`
  - `alwaysInclude`: `false`
  - `projectScopeAllowed`: `false`
- **Execution Mechanism:** In Zed, the assistant panel dispatches terminal commands directly or pulls context using slash commands. Aliasing `zed` directly to `~/.agents/skills/flow` avoids duplicating byte trees on disk while providing a first-class CLI selector (`npx flow-skill -t zed`). Instructions are provided by `AGENTS.md` at workspace root.

#### 2. Project Rule Scaffolding for Cursor (Category B: Rule Scaffold)
- **Specification:** `<project-root>/.cursor/rules/flow.mdc`
- **Frontmatter:**
  ```yaml
  ---
  description: Flow buildflow discipline layer and gated execution engine
  globs: flow/**,cards/**,*.md,src/**
  alwaysApply: false
  ---
  ```
- **Content:**
  ```markdown
  # Flow Discipline Layer Invariants (Cursor Rule Guidance)
  Notice: This is markdown rule scaffolding guiding Composer/Agent behavior.
  
  1. NEVER mark a card done without real world-state verification.
  2. Before editing code, run:
     - On POSIX: `bash skills/flow/runner/flow.sh status`
     - On Windows: `skills\flow\runner\flow.cmd status`
  3. Advance stages only when mechanical gate returns exit 0:
     - Stage gate: `flow.sh next`
     - Card gate: `flow.sh check C-NNN`
  4. If the gate fails (exit 1), STOP and fix the reported errors immediately.
  ```

#### 3. Project Configuration for Roo Code (Category B: Rule Scaffold)
- **Specification:** `<project-root>/.roomodes`
- **Content:**
  ```json
  {
    "customModes": [
      {
        "slug": "flow",
        "name": "Flow Builder",
        "roleDefinition": "You are a disciplined software engineer operating under the Flow gated methodology. You strictly follow Idea->Research->Scope->PRD->ADR->Contract->Cards->Build->Review->Deploy. You never bypass mechanical gates.",
        "groups": [
          "read",
          "edit",
          "browser",
          ["command", { "commands": ["bash*", "*flow.sh*", "*flow.cmd*"] }]
        ]
      }
    ]
  }
  ```

#### 4. Project Rules for Cline (Category B: Rule Scaffold)
- **Specification:** `<project-root>/.clinerules`
- **Content:**
  ```markdown
  # Flow System Rules for Cline (Rule Guidance)
  - Always inspect `flow/` and `cards/` before authoring code.
  - Execute `bash skills/flow/runner/flow.sh status` at the start of any task.
  - Card progression rule: Execute `bash skills/flow/runner/flow.sh check <CARD_ID>`.
  - If `flow.sh check` exits 1, parse the output, resolve all failing checks, and re-run.
  - Never forge done-evidence or check off incomplete criteria.
  ```

---

### Action 3: Tier 2 Interactive & Container Rule Scaffolding

*Clarification: All items in Action 3 belong strictly to Category B (Workspace Rule Scaffolding). They do not install skills into host registries.*

#### 1. Windsurf Cascade (Category B: Rule Scaffold)
- **Context Budget Guard:** Must remain strictly under **6,000 characters** to prevent Cascade truncation.
- **Specification:** `<project-root>/.windsurf/rules/flow.md` (~2,200 characters):
  ```markdown
  # Flow Engineering Discipline (Windsurf Cascade Rule Guidance)
  
  Flow orchestrates software development through strict, evidence-gated lifecycle stages:
  Idea -> Research -> Scope -> PRD -> ADR -> Contract -> Cards -> Build -> Review -> Deploy -> Verify-live -> Retro.
  
  ## Primary Directives
  1. Mechanical Authority: Flow runner scripts are the absolute ground truth.
     - Run `bash skills/flow/runner/flow.sh status` to inspect current project status.
     - Run `bash skills/flow/runner/flow.sh next` to evaluate stage gates.
     - Run `bash skills/flow/runner/flow.sh check C-NNN` to evaluate card completion.
     - On Windows cmd/PowerShell: use `skills\flow\runner\flow.cmd <command>`.
  2. Exit Code Invariant:
     - Exit 0 = PASS. You may proceed.
     - Exit 1 = FAIL. You MUST halt, inspect the failure list, and fix issues.
  3. Work Division:
     - Planning artifacts live strictly in `flow/` (00-inspect.md through 05-contract.md).
     - Shipping cards live strictly in `cards/` (C-001.md, etc.).
     - Do not start writing code until Stage 05 (Contract) passes.
  4. Done Proof:
     - Never tick `- [x]` in cards without pasting real terminal, test, or URL evidence into `## Done-evidence`.
  ```

#### 2. Aider (Category B: Test Hook Scaffold)
- **Specification:** `<project-root>/.aider.conf.yml`
- **Content:**
  ```yaml
  # Flow integration for Aider (Automatic Gate Verification)
  auto-test: true
  test-cmd: "bash skills/flow/runner/flow.sh check"
  test-timeout: 60
  
  # Read-only architectural context
  read:
    - flow/05-contract.md
    - law/CLAUDE.md
    - law/CODING.md
  ```

#### 3. OpenHands Container Environment (Category B: Container Scaffold)
- **Docker Isolation Warning:** Host global paths (`~/.claude/skills/flow`, etc.) are unmapped inside Docker sandboxes (`docker-exec`) and produce `ENOENT`. OpenHands requires project-local runners (`<project-root>/skills/flow` or `<project-root>/.claude/skills/flow`).
- **Specification:** `<project-root>/.openhands/microagents/flow.md`
- **Content:**
  ```markdown
  ---
  name: flow
  agent: CodeActAgent
  triggers:
    - flow
    - buildflow
    - /flow
  ---
  # OpenHands Flow Execution Protocol (Container Guidance)
  
  Flow runs inside this container using the local project runner.
  Do NOT attempt to call host paths like `~/.claude/skills/flow`.
  
  1. Locate the runner:
     `test -f skills/flow/runner/flow.sh && RUNNER="bash skills/flow/runner/flow.sh" || RUNNER="bash .claude/skills/flow/runner/flow.sh"`
  2. Check project state:
     `$RUNNER status`
  3. Validate gates mechanically before submitting work:
     `$RUNNER check <CARD_ID>`
  4. Only submit PR/finish task when `$RUNNER check` exits 0.
  ```

#### 4. GitHub Copilot (Category B: Interactive Guidance)
- **Discipline Boundary:** Copilot lacks an autonomous task loop. This file provides interactive advice to developers using Copilot chat.
- **Specification:** `<project-root>/.github/copilot-instructions.md`
- **Content:**
  ```markdown
  # Flow Gated Development Guidelines for GitHub Copilot
  
  When assisting the developer in this repository:
  1. Check `flow/` directory to understand the current stage before proposing architecture.
  2. Respect the contract in `flow/05-contract.md` as the authoritative interface specification.
  3. When working on a card in `cards/`:
     - Only implement functionality defined in the card's Scope.
     - Remind the developer to run `bash skills/flow/runner/flow.sh check <CARD>` to verify gates.
  4. Never advise skipping security-class checks or modifying `runner/flow.sh`.
  ```

---

## 5. Detection Heuristics & False-Positive Guards

### 5.1 False-Positive Failure Modes
1. **Silent Poisoning via `--yes`:** Inaccurate marker detection triggers unintended file writes during non-interactive installations.
2. **Orphaned State:** Creating skill trees in unused harness folders causes doctor check warnings and clutter.

### 5.2 Marker Specification Table

| Target Name | Target Category | Checked Path (`relative to $HOME`) | Avoided Path (Bare Dir) | Technical Rationale for False-Positive Guard |
| :--- | :---: | :--- | :--- | :--- |
| **`claude`** | A | `.claude` | *None* | `alwaysInclude: true`. Claude Code is the primary first-party harness. |
| **`codex`** | A | `.codex/skills` | `.codex` | Bare `~/.codex` may hold auth/logs; skills require `skills/` subdir. |
| **`agents`** | A | `.agents/skills` | `.agents` | Universal standard requires `skills/` subdir. |
| **`antigravity`**| A | `.gemini/antigravity-cli`<br>`.gemini/config/skills` | `.gemini` | **Strict Guard:** Bare `~/.gemini` is shared by Google Gemini CLI (non-Antigravity). |
| **`omp`** | A | `.omp/agent/skills` | `.omp` | Bare `~/.omp` contains runtime state; skills live in `.omp/agent/skills`. |
| **`cursor`** | A | `.cursor/skills` | `.cursor` | **Strict Guard:** Bare `~/.cursor` exists for all Cursor editor users (settings, argv.json). Only `.cursor/skills` proves skill execution. |
| **`zed`** | A | `.config/zed`<br>`.agents/skills` | *None* | Zed stores configuration in `~/.config/zed` and shares `~/.agents/skills`. |
| **`windsurf`** | B | `.windsurf` | *None* | Scaffolds `.windsurf/rules/flow.md`. |
| **`roo-code`** | B | Project `.roomodes` | *None* | Scaffolds `.roomodes`. |
| **`cline`** | B | Project `.clinerules` | *None* | Scaffolds `.clinerules`. |

---

## 6. Implementation Roadmap (Phases 3.1 – 3.4)

All phases below are unexecuted design plans. Promotion of any target requires passing the Four-Point Live Verification Protocol.

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                               PHASE 3 EXECUTION ROADMAP                                 │
├──────────────────────────────┬──────────────────────────────┬───────────────────────────┤
│ PHASE 3.1: Parity Fixes      │ PHASE 3.2: Target Expansion  │ PHASE 3.3: Rule Gen       │
├──────────────────────────────┼──────────────────────────────┼───────────────────────────┤
│ • Patch install.sh (cursor)  │ • Add zed target to          │ • Add `flow harness init` │
│ • Patch install.ps1 (cursor) │   constants.mjs & scripts    │   command to flow.sh      │
│ • Update flow.sh check #12   │ • Align antigravity markers  │ • Scaffolds .cursor/rules │
│ • Update context_handler.py  │   in install.sh/ps1          │ • Scaffolds .roomodes     │
│ • Run installer tests        │ • Expand restart hints       │ • Scaffolds .clinerules   │
└──────────────────────────────┴──────────────────────────────┴───────────────────────────┘
                                              │
                                              ▼
                               ┌──────────────────────────────┐
                               │ PHASE 3.4: Four-Point Verif  │
                               ├──────────────────────────────┤
                               │ • 1. Ingestion verification  │
                               │ • 2. Invocation verification │
                               │ • 3. Gate-stop verification  │
                               │ • 4. Receipt verification    │
                               │ • Cross-platform CI matrix   │
                               └──────────────────────────────┘
```

### Phase 3.1: Installer & Doctor Parity (Cursor Target Parity)
1. Edit `install.sh`: Add `cursor` target and restart hints (`install.sh:263-299`).
2. Edit `install.ps1`: Add `cursor` target and restart hints (`install.ps1:218-248`).
3. Edit `skills/flow/runner/flow.sh`: Update Check #12 (`install_homes`) to detect `~/.cursor/skills/flow`.
4. Edit `skills/flow/adapter-hooks/context_handler.py`: Add Cursor to fallback probing candidates.

### Phase 3.2: Native Target Expansion (Zed & Marker Alignment)
1. Update `npm-wrapper/src/constants.mjs`: Add `zed` target aliased to `~/.agents/skills/flow`.
2. Harmonize `install.sh` & `install.ps1` for Antigravity: Replace bare `~/.gemini` check with subdirectory checks.
3. Update shell/PowerShell installers for `zed`.

### Phase 3.3: Project Template & Rule Generators
1. Create scaffolding templates in `skills/flow/_templates/harness/`:
   - `cursor.mdc`, `roomodes.json`, `clinerules.md`, `windsurf.md`, `aider.yml`, `openhands.md`, `copilot.md`.
2. Implement `flow harness init <target>` command in `skills/flow/runner/flow.sh` for non-destructive project rule generation.

### Phase 3.4: Four-Point Live Verification & CI
1. Execute the Four-Point Live Verification Protocol for each candidate target:
   - Ingestion check (no clipping/parsing failure).
   - Invocation check (agent calls `runner/flow.sh`).
   - Gate-stop check (agent halts on mechanical exit != 0).
   - Receipt check (deterministic hashes verified).
2. Validate automated test suites in `npm-wrapper/test/detect.test.mjs` and `npm-wrapper/test/installer.test.mjs`.
3. Verify cross-platform matrix on Ubuntu, macOS, and Windows Server (PowerShell + Git Bash).

---

## 7. Conclusion

This revised matrix establishes a clear boundary between **Category A: Native Skill Targets** and **Category B: Workspace Rule Scaffolding**. By treating all upcoming expansions as **provisional design specifications** subject to the **Four-Point Live Verification Protocol**, Flow maintains absolute fidelity to **ADR-0001** and prevents hollow compatibility claims.
