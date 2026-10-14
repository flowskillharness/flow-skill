# Phase 1 Deep REA Reverse-Engineering Analysis: AgentKit Engineer Hooks & Flow Upgrade Architecture

**Date:** 2026-10-14  
**Investigator:** Flow Architecture & Discipline Engineering Workstream  
**Target Installation Path:** `/home/manhquy/.agentkit/cache/kits/engineer/omp/2.18.1/engineer/`  
**Target Files Analyzed:**
1. `hooks/secret-output-guardrail.cjs` & `hooks/lib/secret-keywords.cjs`
2. `hooks/privacy-block.cjs` & `hooks/lib/privacy-checker.cjs`
3. `hooks/scout-block.cjs` & `hooks/scout-block/` (`broad-pattern-detector.cjs`, `pattern-matcher.cjs`, `path-extractor.cjs`, `error-formatter.cjs`)
4. `hooks/agent-behavior-linter.cjs` & `hooks/lib/agent-behavior-linter/` (`detectors.cjs`, `store.cjs`, `event-schema.cjs`, `report.cjs`)
5. `hooks/hooks.json`
6. `skills/ak-agentkit/references/subagent-timing.md`

---

## 1. Concrete Mechanism & Specification Analysis

### 1.1 `secret-output-guardrail.cjs` & `lib/secret-keywords.cjs`

#### Execution Event & Lifecycle Point
- **Event:** `UserPromptSubmit` (intercepts incoming user prompt before model inference).
- **Control Pattern:** Soft reminder injection (`hookSpecificOutput.additionalContext`). Does not block execution. Returns exit code 0.

#### Exact Matcher Regexes & Keyword Patterns (`lib/secret-keywords.cjs:9-23`)
```javascript
const SECRET_KEYWORD_PATTERNS = [
  /\.env(?:\b|$)/i,
  /(?:^|[^A-Za-z0-9])credentials?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])secrets?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])api[\s_-]*keys?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])access[\s_-]*keys?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])tokens?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])bearer(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])jwts?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])private[\s_-]*keys?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])oauth(?:[\s_-]+client)?[\s_-]*secrets?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])client[\s_-]*secrets?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])cloud[\s_-]*keys?(?:$|[^A-Za-z0-9])/i,
  /(?:^|[^A-Za-z0-9])env[\s_-]+files?(?:$|[^A-Za-z0-9])/i,
];
```

#### Injected Output Text
```text
Security reminder: do not print raw credentials, API keys, tokens, JWTs, private keys, or secret values into the conversation. Use [redacted], variable names, counts, or high-level status. Approval to read a sensitive file or command output does not grant permission to print raw values. If a value is needed for a machine action, pass it through a non-echoing path and report only success or failure.
```

---

### 1.2 `privacy-block.cjs` & `lib/privacy-checker.cjs`

#### Execution Event & Lifecycle Point
- **Event:** `PreToolUse` (matchers: `Read|Write|Edit|Bash`).
- **Control Pattern:** Hard blocking (`process.exit(2)`).
- **Bypass Mechanism:** Requires explicit user approval represented by the `APPROVED:` path prefix (`APPROVED:.env`).

#### Sensitive vs Safe Patterns (`lib/privacy-checker.cjs:35-53`)
- **Safe Patterns (Exempt):**
  - `/\.example$/i` (e.g., `.env.example`, `config.example`)
  - `/\.sample$/i` (e.g., `.env.sample`)
  - `/\.template$/i` (e.g., `.env.template`)
- **Privacy-Sensitive Patterns (Blocked):**
  - `/^\.env$/` (exact `.env`)
  - `/^\.env\./` (`.env.local`, `.env.production`)
  - `/\.env$/` (`path/to/.env`)
  - `/\/\.env\./` (`path/to/.env.local`)
  - `/credentials/i` (`credentials.json`, etc.)
  - `/secrets?\.ya?ml$/i` (`secrets.yaml`, `secret.yml`)
  - `/\.pem$/` (PEM private keys)
  - `/\.key$/` (private key files)
  - `/id_rsa/` (RSA SSH keys)
  - `/id_ed25519/` (Ed25519 SSH keys)

#### Command Parsing & Path Extraction (`lib/privacy-checker.cjs:135-212`)
- Custom shell lexer (`lexShellWords`) handles escaped quotes and delimiter separation (`<>()|;&`).
- Inspects subshell commands, `env -S` / `env --split-string` options, and evaluates scripts (`node -e`, `python -c`).
- Checks path normalization and decodes percent-encoded characters (`decodeURIComponent`) to prevent URL-encoding traversal bypasses.

---

### 1.3 `scout-block.cjs` & `scout-block/`

#### Execution Event & Lifecycle Point
- **Event:** `PreToolUse` (matchers: `Bash|Read|Glob`).
- **Control Pattern:** Hard blocking (`process.exit(2)`).

#### Broad Pattern Detection (`scout-block/broad-pattern-detector.cjs:18-37`)
Flags and blocks queries matching:
```javascript
const BROAD_PATTERN_REGEXES = [
  /^\*\*$/,                     // **
  /^\*$/,                      // *
  /^\*\*\/\*$/,                // **/*
  /^\*\*\/\.\*$/,              // **/.
  /^\*\.\w+$/,                 // *.ext at root
  /^\*\.\{[^}]+\}$/,           // *.{ext1,ext2} at root
  /^\*\*\/\*\.\w+$/,           // **/*.ext everywhere
  /^\*\*\/[^*/]+\.\w+$/,       // **/name.ext everywhere
  /^\*\*\/\*\.\{[^}]+\}$/,     // **/*.{ext1,ext2} everywhere
];
```

#### Safe Directory Exception (`scout-block/broad-pattern-detector.cjs:40-45`)
Permitted if scoped under specific source subdirectories:
`src`, `lib`, `app`, `apps`, `packages`, `components`, `pages`, `api`, `server`, `client`, `web`, `mobile`, `shared`, `common`, `utils`, `helpers`, `services`, `hooks`, `store`, `routes`, `models`, `controllers`, `views`, `tests`, `__tests__`, `spec`.

#### Build Command Whitelist in Bash (`lib/scout-checker.cjs`)
Allows commands containing ignored directory paths (`node_modules`, `dist`, `target`) if the root command is an approved build command:
`npm`, `pnpm`, `yarn`, `bun`, `go`, `cargo`, `make`, `mvn`, `gradle`, `docker`, `kubectl`, `terraform`.

---

### 1.4 `agent-behavior-linter.cjs` & `lib/agent-behavior-linter/`

#### Execution Event & Lifecycle Point
- **Event:** `Stop` (runs when the session ends; non-blocking).
- **Control Pattern:** Non-blocking post-hoc aggregation (`{"continue": true}`). Outputs diagnostic summary to model context via `systemMessage`.

#### Detectors & Thresholds (`lib/agent-behavior-linter/detectors.cjs:32-38`)
1. **`detectRepeatedUnchangedRead` (D1):**
   - Threshold: $\ge 3$ reads of an unchanged file (`entry.reads >= 3 && entry.mutatedAt === null`).
   - Principle: *Reuse verified facts*.
2. **`detectDeterministicRetry` (D2):**
   - Threshold: $\ge 2$ attempts on a deterministic failure without file mutations in between.
   - Principle: *Bounded retry*.
3. **`detectBroadSearchAccumulation` (D3):**
   - Threshold: $\ge 4$ broad searches (`entry.broad === true`).
   - Principle: *Search before large reads*.
4. **`detectOutputAccumulation` (D4):**
   - Threshold: $\ge 200\text{ KiB}$ cumulative tool stdout without state mutation.
   - Principle: *Bound output limits*.

---

### 1.5 `hooks.json`

#### Hook Registry Event Matrix
- `PreToolUse`:
  - `Write`: `descriptive-name.cjs`
  - `Read|Write|Edit|Bash`: `privacy-block.cjs`
  - `Bash|Read`: `scout-block.cjs`
  - `Bash|Read|Grep|Glob`: `context-firewall.cjs`
- `PostToolUse`:
  - `*`: usage-quota, statusline-session-cache, agent-behavior-linter event capture
- `PreCompact`:
  - `precompact-capture.cjs` (records branch/HEAD/state snapshot)
- `SessionStart`:
  - `session-init.cjs` / `context-builder.cjs` (surfaces orientation context)
- `Stop`:
  - `agent-behavior-linter.cjs`, `notifications/notify.cjs`
- `UserPromptSubmit`:
  - `secret-output-guardrail.cjs`

---

### 1.6 `skills/ak-agentkit/references/subagent-timing.md`

#### Seven-Point Subagent Delegation Contract
Every subagent dispatch must be self-contained and carry all 7 fields:
1. **Task** — Exactly one verifiable outcome.
2. **Files to read** — Exact paths; no unbounded browsing.
3. **Files it may modify** — Explicit disjoint ownership; empty for read-only roles.
4. **Acceptance criteria** — Precise condition for completion.
5. **Constraints** — Patterns to follow, boundaries not to touch, no unauthorized commit/push.
6. **Report path** — Machine/human readable finding destination.
7. **Status line contract** — Standardized termination state machine:
   ```text
   Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
   Summary: <one or two sentences>
   ```

#### Anti-Patterns (When NOT to Delegate)
- Single small edits or simple lookups.
- Tasks requiring full conversational history.
- Uncoordinated concurrent access to identical file paths.

---

## 2. Portability Evaluation vs Flow Discipline Layer (ADR-0001)

| AgentKit Mechanism | AgentKit Execution Context | Flow ADR-0001 Compatibility | Target Flow Component & Form |
|---|---|---|---|
| **Secret Output Guardrail** | Host hook `UserPromptSubmit` | **Fully Compatible** (stateless output hygiene) | `context_handler.py`: sanitizes captured stdout/stderr and snapshot streams. |
| **Privacy Block** | Host hook `PreToolUse` (tool interception) | **Forbidden as runtime tool wrapper; Portable as CLI gate check** | `flow.sh` (`status`, `resume`, `check`): refuses to print/leak `.env*`, `.ssh/*`, private keys.<br>`doctor_helper.py`: `privacy_guard` check. |
| **Scout / Broad Pattern Detector** | Host hook `PreToolUse` (tool interception) | **Forbidden as runtime tool wrapper; Portable as static check** | `doctor_helper.py`: `scout_bounds` check ensuring search queries and glob patterns remain bounded. |
| **Behavior Linter** | Host hook `Stop` + state aggregation | **Partially Portable** (stateless post-mortem audit) | Extends `flow.sh usage` & `flow doctor` to surface repetitive read/retry diagnostics from `.flow/events.jsonl`. |
| **Subagent Timing & Contract** | Prompt reference in `ak-agentkit` | **Fully Compatible** (prompt law / discipline rule) | `skills/flow/references/agent-stage-mapping.md`: canonical subagent dispatch contract and safety rules. |

---

## 3. Concrete Flow Implementation Blueprint

### 3.1 `skills/flow/adapter-hooks/context_handler.py`
- **Output Sanitization:** Incorporate regex redactors from `secret-keywords.cjs` and `redaction-patterns.md` into stdout/stderr processing during `flow.sh status` capture.
- **Fail-Safe Streams:** Guarantee snapshots under `.flow/context-handoff/snapshot.json` never contain unmasked bearer tokens, JWTs, private keys, or `.env` credential lines.

### 3.2 `skills/flow/runner/flow.sh`
- **Privacy Shield on Verbs:**
  - `cmd_resume`, `cmd_status`, `cmd_check`: Enforce refusal or automatic omission if target card, allowed files, or verify commands attempt to directly output `.env`, `*.pem`, `id_rsa`, or `credentials.json`.
  - Replace detected values with `[REDACTED:<category>]`.

### 3.3 `skills/flow/references/agent-stage-mapping.md`
- **Subagent Delegation Section:**
  - Embed the 7-point contract (Task, Files to read, Files to modify, Acceptance criteria, Constraints, Report path, 4-state Status machine).
  - Define parallel disjoint-ownership invariants.

### 3.4 `skills/flow/runner/doctor-checks.tsv` & `doctor_helper.py`
- **`privacy_guard` Check:** Scans project root for committed unencrypted `.env`, `.pem`, `id_rsa` keys, warning if sensitive files lack `.gitignore` coverage.
- **`scout_bounds` Check:** Audits verification scripts and test commands for dangerous unbounded recursive sweeps (`find .`, `grep -r .`, `**/*`).

---
*Report generated and grounded in exact cache files. Ready for review before implementing.*
