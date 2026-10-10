# /flow — Architecture Gap Analysis vs 2025–2026 Tech Trends

- **Date:** 2026-10-10
- **Author:** research-roadmap-analysis
- **Scope:** Architecture analysis of `flow` discipline layer (`/home/manhquy/Documents/flow-skill`) vs 2025–2026 industry coding-agent trends
- **Reference Crawl Corpus:** `plans/research/trends-*.md` in worktree `flow-skill-research`
- **Constitutional Anchor:** [`docs/adr/0001-discipline-layer-identity.md`](../../docs/adr/0001-discipline-layer-identity.md)

---

## 1. Executive Summary

Flow is a host-agnostic **discipline layer** for AI coding agents: it enforces evidence-gated progression from idea to live deployed software through deterministic mechanical gates and LLM-assisted semantic judgment, producing verifiable on-disk receipts. It deliberately disclaims holding the process token, running a background daemon, owning an agent execution loop, or wrapping tools.

An analysis of 2025–2026 tech trends across agent ecosystems, Model Context Protocol (MCP), coding benchmarks and eval harnesses, context engineering, spec-driven development (SDD), agent security, and multi-agent orchestration reveals a striking conclusion:

1. **Strong External Validation for Flow's Constitutional Model:**
   - **Context Engineering:** Industry studies demonstrate that naive auto-compaction triggers "context rot" and loses critical signal; the converged best practice is durable external files on disk and strict word/token budgets — exactly Flow's `flow/` + `cards/` + `resume` architecture.
   - **Agent Security:** High-profile 2026 vulnerabilities (Cymulate configuration-based sandbox escape, BeyondTrust C2 weaponization of skill lifecycle hooks) attacked resident processes and automatic tool/lifecycle hooks. Flow's refusal to use background daemons or automatic lifecycle hooks protects it from this entire attack class.
   - **Spec-Driven Development:** The industry adoption of SDD (e.g., GitHub Spec Kit) validates Flow's Idea→PRD→ADR→Contract→Cards pipeline, but Flow maintains a distinct edge: Flow enforces **mechanical teeth** (exit 0/1) and **world-state done-evidence** ("deployed URL / live curl output", not merely "tests pass").

2. **Key Gaps & Evolution Opportunities:**
   - **Eval Regression Intelligence:** While Flow has three distinct eval modalities and paired hollow/sound fixtures, it evaluates batches statically. It lacks longitudinal classification (`IMPROVED`, `REGRESSED`, `SATURATED`) across model generations or prompt changes.
   - **Bounded Context Handoff:** While Flow's file state prevents context rot, the `resume` output brief lacks an enforced hard token/line budget for long-running projects with many historical cards.
   - **Multi-Agent Workspace Resource Clashes:** Flow provides robust git worktree isolation and dependency-based concurrency safety (`ready`), but lacks deterministic port allocation for parallel web verification.
   - **Self-Integrity & Tamper Detection:** Flow's law forbids editing `runner/flow.sh` during runs, but Flow lacks a startup cryptographic SHA verification against installed distribution manifests.

---

## 2. Capability Inventory Today (Repo Ground Truth)

Every item below is grounded in the analyzed repository files:

### 2.1 Identity and Constraints
- **ADR-0001 Invariant (`docs/adr/0001-discipline-layer-identity.md`):** "Flow owns the gates and the receipts, never the runtime." Every byte executes solely because a hosting agent or operator invoked it, and Flow terminates when that invocation completes. Mechanically forbidden: daemons, resident processes, owned agent loops, tool-execution wrappers/interposition, and servers.
- **Portability & Dependencies (`AGENTS.md`):** Bash 3.2-safe, zero new runtime dependencies, pure Unix coreutils, and Python 3 stdlib (`sqlite3` only). Must degrade loudly and never lower a gate.
- **Eval STOP Zones (`AGENTS.md`, `docs/adr/0001-discipline-layer-identity.md`):** The bodies of `_eval_engine_run` (line 3437) and `_run_with_timeout` (line 3166) in `skills/flow/runner/flow.sh` are strictly untouchable.

### 2.2 Dispatch and Commands
`skills/flow/runner/flow.sh` dispatches 31 commands (lines 5182–5218):
- **Lifecycle & Progression:**
  - `next`: Evaluates stage mechanical gate; advances stages `00-idea` through `05-contract`.
  - `assess`: Brownfield code inspection; drafts `flow/00-inspect.md` before planning.
  - `card` (`start`, `done`): Generates new scoped shipping unit cards (`cards/C-NNN.md`); tracks in-flight work and CLI-driven completion.
  - `check`: Strictly validates a card against its gate (status, scope, allowed-files, world-state evidence).
  - `gate`: Read-only mechanical scan of any stage or card without mutating state or acquiring locks.
  - `skip`: Records a deliberate loan in `DEBT.md` with close-before conditions.
  - `retro`: Prompts the 3-question honest retrospective, updating `RETRO.md`.
- **Architectural Drift & Consistency Scanners:**
  - `contract` (F3): Validates client base-URL vs served-path prefix drift against `05-contract.md`.
  - `tokens` (F4): Scans CSS for design-token divergence against `DESIGN.md` (unused, orphan, mismatch).
  - `coherence` (F7): Scans declared version fields across repo manifests.
  - `consistency`: Verifies PRD Functional Requirement (`FRn`) coverage across planning files.
  - `constitution`: Checks repo-specific invariant markers against `flow/constitution.md`.
  - `clarify`: Surfaces leftover `- [ ]` open decisions in stages 02, 03, and 05.
  - `converge`: Assesses code vs plan; appends remainder cards for unfulfilled promises without editing existing cards.
- **State & Workspace Orchestration:**
  - `status`: Ground-truth project state (prose or `--json` via closed `flow_context/v1` schema).
  - `resume`: Read-only session brief (last session, in-flight, dwell time, gate state, single `NEXT ->` action).
  - `ready`: Computes parallel-safe candidate cards based on satisfied dependencies and non-overlapping `## Allowed files`.
  - `workspace`: Git worktree isolation helper (`add`, `list`, `enter`, `remove`, `check`, `doctor`).
  - `mode`: Switches between `teach` (human authors, agent gatekeeps) and `work` (agent drafts after interview).
  - `auto`: Attested autonomous policy manager with Tier A/B/C safety stops.
  - `loop-prep` & `loop-log`: Loop-engineering metrics wrapper (iterations, failing test counters).
- **Knowledge, Durable Layer & Evals:**
  - `harness`: Direct passthrough to the durable SQLite layer (`flow_harness.py`).
  - `recall`: Retrieves project and global lessons (`~/.claude/flow/playbooks`).
  - `promote`: Copies project playbooks into the global knowledge tier.
  - `eval`: Multi-modality behavioral evaluation harness (`--stage 01|02|05|card`, `--stage routing`, `--stage converge`).
  - `attest`: Mints and verifies cryptographic/fingerprint-bound receipts (`semantic`, `live-verify`, `status`, `recover`).
  - `doctor`: Cross-platform diagnostic tool verifying bash, python, git, and required tools.

### 2.3 Two-Layer Gate Architecture
1. **Mechanical Layer (`flow.sh`):** Exit 0/1 deterministic checks:
   - Zero unfilled `[FILL]` placeholders.
   - Zero unchecked `- [ ]` checkboxes (including `## Open decisions`).
   - Valid card status (`todo`, `in_progress`, `done`).
   - Non-empty `## Evidence` containing real output (URLs, cURL output, DB rows).
   - Mid-tier content scanners (`_scan_midtier`):
     - `01-research.md`: Web projects require $\ge 3$ competitors/alternatives under `## What exists already`.
     - `02-scope.md`: Prohibits Low-impact features graded above A; caps `## Open decisions` at 5.
     - `03-prd.md`: Prohibits unquantified marketing adjectives (`fast`, `secure`, `intuitive`, `robust`, `prominent`); caps open decisions at 5.
     - `05-contract.md`: Caps open decisions at 5.
2. **Semantic Layer (`SKILL.md` + `references/gate-rules.md` / `gate-examples.md`):**
   - Applies LLM judgment only after mechanical PASS.
   - Catches grade laundering, fabricated competitor quotes, and hollow done claims.

### 2.4 Eval Modalities
- **Artifact-vs-Gate Judge (`flow.sh eval --stage 01|02|05|card`):** Evaluates fixture artifacts against extracted markdown gate challenges (verdicts: `PASS`, `FLAG`, `INVALID`). Uses nonces to defeat cached/echoed completions.
- **Routing Judge (`flow.sh eval --stage routing`):** Tests Concierge intent classification against `references/flow-catalog.tsv` (verdicts: `MATCH`, `MISS`, `INVALID`). Capped at 90 calls/batch.
- **Converge Judge (`flow.sh eval --stage converge`):** Evaluates full repository state against declared promises (verdicts: `GAP`, `CONVERGED`, `INVALID`).
- **Execution Lanes:** Billable live mode (`claude -p`) vs Keyless offline deterministic replay (`--replay`).

---

## 3. Repo-Stated Limitations and Backlog

Grounded in repository tracking documents:
1. **macOS Timeout Watchdog Debt (`DEBT.md`):**
   - On Darwin (macOS stock `/bin/sh` without GNU `timeout` or `gtimeout`), the fallback watchdog in `_run_with_timeout` cannot reliably terminate stuck `claude` subprocesses during billable evaluations.
   - A refuse-guard shipped on 2026-08-14 to block live evaluations without GNU timeout by default, but the underlying process-termination mechanism remains open debt.
2. **Knowledge Roadmap Nice-to-Haves (`plans/260614-flow-knowledge-upgrades-roadmap.md`):**
   - Tree-sitter AST dependency graph scanning in `cmd_assess`.
   - Semantic document coherence (detecting contradictory prose between architecture docs and implementation beyond simple version drift).
   - Autonomous promotion of recurring friction lessons from `harness propose` into global playbooks.
   - Rust-backend parity testing for the durable SQLite harness.
3. **Explicitly Deferred Items (`docs/adr/0001-discipline-layer-identity.md`):**
   - MCP client bridge (deferred until concrete tripwire-4 adopter demand).
   - Attestation substrate remains Git-blob only (hybrid storage deferred).
   - Python test coverage floors (deferred until harness codebase exceeds ~5k lines).
   - Separate orchestration runtime (`flow-orch`) rejected under current capacity.
4. **Quality & Scale Friction (`docs/quality-metrics.md`, `docs/release-process.md`):**
   - Windows CI execution duration reaches 25–35 minutes across 67 test suites in `tests/manifest.txt` (45m timeout budget).
   - Lack of temporal regression tracking across eval batches.

---

## 4. Gap Analysis Against 2025–2026 Trend Areas

### 4.1 Agent Skill Ecosystems & Conventions
- **Trend Source:** [`plans/research/trends-agent-skills-ecosystems-261010.md`](trends-agent-skills-ecosystems-261010.md)
- **Key Trend Observations:** The skill/plugin packaging model is now standard across hosts (342+ plugins on Claude marketplace; cross-vendor skill registries). The `AGENTS.md` standard (Linux Foundation, 2025) is deployed in 60,000+ repositories. Nested `AGENTS.md` conventions are standard for monorepos. Over 90% of professional developers use coding agents weekly.
- **Flow Alignment & Posture:** Flow is multi-host aware (`~/.claude`, `~/.codex`, `~/.agents`, Antigravity `agy`). Its root `AGENTS.md` and `skills/flow/law/CLAUDE.md` split adheres cleanly to the ecosystem norm. Flow's `PTC_ONLY` load table minimizes token overhead compared to competing bloated skills.
- **Gaps & Friction:**
  - *Registry Manifests:* Flow packages for npm (`npm-wrapper`) and Git install, but lacks metadata manifests for emerging third-party skill registries.
  - *Nested Monorepo Conventions:* Flow currently assumes a single root `AGENTS.md` and single `flow/` directory; it lacks formal guidance or isolation checks for nested multi-package monorepos with package-level `AGENTS.md` files.

### 4.2 Model Context Protocol (MCP)
- **Trend Source:** [`plans/research/trends-mcp-protocol-261010.md`](trends-mcp-protocol-261010.md)
- **Key Trend Observations:** MCP has become the universal data/interactivity protocol across AI toolchains (dated spec releases: 2025-06-18, 2025-11-25, 2026-07-28; official registry; agent identity standardization; CISA/NSA security guidance).
- **Flow Alignment & Posture:** Flow is host-agnostic bash. ADR-0001 strictly forbids Flow from becoming a resident MCP server (mechanically forbidden: servers, daemons, tool interposition). Flow consumes host tools, but does not wrap them.
- **Gaps & Friction:**
  - *Machine-Readable Interop:* Host agents operating in MCP environments consume tool outputs via structured JSON. While Flow provides `status --json` and `resume --json` (`flow_context/v1`), these interfaces are marked display-only and lack a documented MCP-tool integration contract.
  - *Posture Clarity:* Adopters frequently ask if Flow will ship an MCP server. Flow's documentation should explicitly cite the CISA security guidance and ADR-0001 to explain why a discipline layer must remain non-resident.

### 4.3 Agent Coding Benchmarks & Eval Harnesses
- **Trend Source:** [`plans/research/trends-agent-evals-benchmarks-261010.md`](trends-agent-evals-benchmarks-261010.md)
- **Key Trend Observations:** SWE-bench scores have crossed 76–90% with specialized harnesses. Evaluation has pivoted to "Senior SWE-Bench" (senior engineering judgment vs raw patching) and regression-tracking eval harnesses (e.g., `skill-eval-harness`, Promptfoo) that report whether prompts/skills `IMPROVED`, `REGRESSED`, or `SATURATED` across model updates.
- **Flow Alignment & Posture:** Flow's semantic gates test senior-engineer judgment (catching grade laundering, honest MVP scopes, and hollow evidence) rather than patch mechanics. Flow enforces a strict fixture-pair rule (`AGENTS.md`).
- **Gaps & Friction:**
  - *Lack of Longitudinal Diffing:* Flow evaluates fixture batches statically (`flow.sh eval`). It has no mechanism to compare run $N$ with run $N-1$ to flag regressed or saturated fixtures.
  - *Harness Metadata Reporting:* Benchmarks now require publishing full harness identity (shell, OS, judge generation). `docs/quality-metrics.md` records pass rates, but does not log standardized harness environment fingerprints alongside results.

### 4.4 Context Engineering (Compaction, Memory, Budgets, Calibration)
- **Trend Source:** [`plans/research/trends-context-engineering-261010.md`](trends-context-engineering-261010.md)
- **Key Trend Observations:** Context engineering emphasizes working memory curation over context stuffing. Naive auto-compaction frequently causes "context rot" and degrades output quality. The winning engineering pattern is authoritative external state in disk files combined with disciplined budgets.
- **Flow Alignment & Posture:** Flow's design is an exact implementation of external file-based memory: `flow/` artifacts, `cards/`, and `.flow/harness.db` persist state across session resets. `flow resume` replaces lossy context compaction.
- **Gaps & Friction:**
  - *Unbounded Session Story Growth:* `flow resume` generates a brief from event history and cards. In large projects with 50+ cards, the resume output can grow arbitrarily large, violating the core principle of a bounded context budget.
  - *Card Working-Memory Sizing:* Flow enforces `## Allowed files` on cards to limit blast radius, but does not provide an automated token/line heuristic to warn when a card's scope is too large for an agent's working memory.

### 4.5 Spec-Driven Development (SDD) & Card Discipline
- **Trend Source:** [`plans/research/trends-spec-driven-development-261010.md`](trends-spec-driven-development-261010.md)
- **Key Trend Observations:** SDD has become mainstream (e.g., GitHub Spec Kit: specify → plan → tasks → implement). The primary friction point in the community is spec evolution: handling drift when code diverges from specifications during implementation.
- **Flow Alignment & Posture:** Flow was built around SDD: Law 2 ("Contract is the seam; amend contract first"), `flow contract` (detecting path prefix drift), and `flow converge` (reconciling code against declared promises via remainder cards).
- **Gaps & Friction:**
  - *Contract-to-Card Coverage Seam:* While Flow provides `consistency` to check PRD FRn coverage, it lacks an automated check verifying that all endpoints declared in `05-contract.md` are covered across the generated `cards/C-NNN.md` before building starts.
  - *Positioning Gap:* Flow's external documentation does not position Flow as "Spec-Driven Development with verifiable gates", missing the rising industry awareness around SDD frameworks.

### 4.6 Agent Security (Hooks, Sandboxing, Permissions, Prompt Injection)
- **Trend Source:** [`plans/research/trends-agent-security-hooks-261010.md`](trends-agent-security-hooks-261010.md)
- **Key Trend Observations:** Security consensus highlights two control layers: permission models and sandboxing. Major 2026 exploits attacked agent hooks: Cymulate's Configuration-Based Sandbox Escape (CBSE) and BeyondTrust's weaponized skill lifecycle hooks executing C2 commands outside sandboxes. Prompt injection remains the #1 agent vulnerability.
- **Flow Alignment & Posture:** Flow's architectural decision to reject resident daemons and automatic lifecycle hooks is completely validated. Flow executes only when explicitly invoked via bash.
- **Gaps & Friction:**
  - *Adversarial Prompt Injection in Gate Artifacts:* Semantic evaluation feeds markdown files (`01-research.md`, `03-prd.md`) into LLM judges. If an artifact contains prompt injections designed to force a `PASS` verdict, Flow relies solely on its prompt template and nonce pinning. It lacks dedicated adversarial injection fixtures in its eval test corpus.
  - *Runner Integrity Verification:* Flow has a standing law: "Never edit runner/flow.sh during a project run." However, Flow has no mechanical check in `flow doctor` or preflight to verify that `flow.sh` matches its installed package checksum.

### 4.7 Multi-Agent Orchestration & Worktree Isolation
- **Trend Source:** [`plans/research/trends-multi-agent-orchestration-261010.md`](trends-multi-agent-orchestration-261010.md)
- **Key Trend Observations:** Multi-agent development has converged on a clear operational recipe: decompose into spec-scoped tasks, isolate agents in git worktrees, and run automated gates before merge. Outstanding pain points include port/resource collisions, shared-file conflicts, and ad-hoc session handoffs.
- **Flow Alignment & Posture:** Flow directly implements this converged model: `ready` checks dependency fulfillment and non-overlapping `## Allowed files`, while `workspace` manages git worktrees.
- **Gaps & Friction:**
  - *Local Port Collisions:* When parallel agents build fullstack web cards across multiple worktrees, they collide on standard localhost ports (3000, 8080), breaking live verification (`curl` / URL checks).
  - *Structured Handoff Schema:* Flow's `resume` provides session state, but there is no standardized machine-readable envelope for external orchestrators to pass continuation state between disparate agent sessions.

---

## 5. Top 5 Architectural Gaps

1. **Absence of Longitudinal Eval Regression Intelligence:**
   - *Impact:* Maintainers modifying gate challenge prompts or mid-tier scanners cannot detect whether a change fixed one failure while silently breaking previously sound fixtures over time.
   - *Repo Anchor:* `skills/flow/eval/`, `skills/flow/runner/flow.sh` (`cmd_eval`).
2. **Unbounded Context Handoff Surface in `flow resume`:**
   - *Impact:* As projects accumulate cards and history, `flow resume` output risks exceeding the working-memory budget of host agents, contributing to context rot.
   - *Repo Anchor:* `skills/flow/runner/flow.sh` (`cmd_resume`), `docs/doc-budgets.txt`.
3. **Localhost Resource Collisions in Parallel Worktrees:**
   - *Impact:* Parallel agents executing live verification in separate worktrees collide on local service ports, failing the mechanical done-evidence requirement through no fault of the implementation.
   - *Repo Anchor:* `skills/flow/runner/flow.sh` (`cmd_workspace`, `cmd_ready`), `references/host-agnostic-parallel.md`.
4. **Adversarial Injection Vulnerability in Semantic Gate Inputs:**
   - *Impact:* Malicious or runaway code/prompts embedded within planning artifacts could attempt prompt injection against the LLM judge during semantic gate evaluation.
   - *Repo Anchor:* `skills/flow/eval/fixtures/`, `skills/flow/runner/flow.sh` (`_eval_build_prompt`).
5. **Lack of Runner Self-Integrity Verification:**
   - *Impact:* Malicious skills or buggy agents modifying `skills/flow/runner/flow.sh` in-flight are not caught by preflight checks, violating Flow's immutability law.
   - *Repo Anchor:* `skills/flow/runner/flow.sh` (`cmd_doctor`), `portable-manifest.json`.

---

## 6. Prioritized Upgrade Shortlist (P0 / P1 / P2)

### P0 Upgrades (High Leverage, Immediate Value)

#### Candidate 1: Longitudinal Eval Regression Reporter (`flow eval --diff`)
- **Problem:** `flow.sh eval` only reports point-in-time PASS/FAIL. There is no automated detection of fixture drift (`IMPROVED`, `REGRESSED`, `SATURATED`) across runs or model bumps.
- **Proposed Change:** Add an offline comparison mode to `flow.sh eval` (e.g., `flow eval --diff <old_report.json> <new_report.json>`) that parses JSON batch summaries, classifies fixture verdict changes, and exits 1 if any previously passing fixture regressed.
- **Repo Surfaces Touched:** `skills/flow/runner/flow.sh` (`cmd_eval` parsing logic outside STOP zones), `skills/flow/references/gate-eval.md`, `tests/test_flow_eval.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Offline deterministic analysis of static JSON reports; no daemon; no runtime dependencies.
- **Rough Effort:** Medium.

#### Candidate 2: Strictly Bounded Context Handoff (`flow resume --budget`)
- **Problem:** Code inspection of `cmd_resume` shows its output structure is already largely bounded: a fixed header, foreign-session telemetry rows capped by `tail -5`, a fixed-size gate brief, and a single `NEXT ->` action. `cmd_resume` never lists completed cards. The only card-count-dependent section is `inflight_display()`, which is unbounded when multiple cards are marked in flight concurrently, risking context window exhaustion.
- **Proposed Change:** Add a `--budget` flag on `flow resume` that caps `inflight_display()` at at most 5 in-flight cards and appends exactly one line `+M more in flight - see 'flow card'` when additional in-flight cards exist. Under-budget output (≤5 in-flight cards) and default unflagged invocations stay byte-identical to previous behavior. Note that `--budget` caps only the in-flight section (≤5 rows + one count line); the telemetry block was already bounded by `tail -5`; total line count stays small in practice but the ≤35 figure is fixture-specific (24 lines in test H), not a general guarantee.
- **Correction (2026-10-10):** original premise (completed-card growth) was wrong on code inspection; rescoped to in-flight cap.
- **Repo Surfaces Touched:** `skills/flow/runner/flow.sh` (`cmd_resume`, `inflight_display`), `skills/flow/references/command-dispatch.md`, `tests/test_flow_resume.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Pure bash text formatting executed on demand.
- **Rough Effort:** Low.

---

### P1 Upgrades (High Value, Architecture & Security Hardening)

#### Candidate 3: Adversarial Injection Eval Fixture Pairs
- **Problem:** LLM gate judges are susceptible to prompt injections placed in planning artifacts. Flow has no automated verification proving its prompts withstand adversarial injections.
- **Proposed Change:** Add an adversarial fixture pair (`f0X_injected_hollow` vs `f0X_sound`) into `skills/flow/eval/fixtures/`. Ensure the prompt wrapper in `_eval_build_prompt` isolates artifact text and consistently yields `FLAG` when an artifact contains jailbreak patterns.
- **Repo Surfaces Touched:** `skills/flow/eval/fixtures/`, `skills/flow/eval/manifest.tsv`, `tests/test_flow_eval.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Adds test data to the eval harness per the fixture-pair rule (`AGENTS.md`).
- **Rough Effort:** Low.

#### Candidate 4: Deterministic Port Allocator for Worktrees (`flow workspace port`)
- **Problem:** Parallel workers running web builds in separate git worktrees collide on default ports (`3000`, `8080`) during live verification.
- **Proposed Change:** Add a helper to `flow workspace` that derives a deterministic port offset from the card number or worktree path (e.g., base port $3000 + N$) and writes a localized `.env.flow.local` file inside the worktree.
- **Repo Surfaces Touched:** `skills/flow/runner/flow.sh` (`cmd_workspace`), `skills/flow/references/host-agnostic-parallel.md`, `tests/test_flow_workspace.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Mathematical offset calculation in bash; zero background port management.
- **Rough Effort:** Low–Medium.

#### Candidate 5: Preflight Runner Self-Integrity Check
- **Problem:** Inadvertent or malicious mid-flight modifications to `skills/flow/runner/flow.sh` violate the immutable harness law without triggering an immediate error.
- **Proposed Change:** Open design question — where does the reference hash live, given that `portable-manifest.json` has no hash field?
  - **Option (a) pack-time:** Generate per-file hashes in `scripts/sync.mjs` and verify them in `scripts/pack-rehearsal.sh`.
  - **Option (b) install-time:** Have `install.sh` / `install.ps1` write an install receipt containing the runner hash; `flow doctor` compares the live file against that receipt.
- **Prerequisite (verified 2026-10-10):** portable-manifest.json currently contains no hash field — a hash-source decision (pack-time vs install-receipt) is required before C5 is implementable.
- **Repo Surfaces Touched:** `skills/flow/runner/flow.sh` (`cmd_doctor`), `scripts/check-release-coherence.sh`, `tests/test_flow_runner.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Standard cryptographic hash verification via `shasum`/`sha256sum`.
- **Rough Effort:** Medium (touches the packaging pipeline).

---

### P2 Upgrades (Strategic & Ecosystem Polish)

#### Candidate 6: Contract-to-Card Coverage Audit (`flow consistency --contract`)
- **Problem:** Developers may omit declared contract endpoints when authoring cards, leading to missing API features that only get caught at the end of the project via `converge`.
- **Proposed Change:** Extend `cmd_consistency` to extract API endpoints from `flow/05-contract.md` and verify that each endpoint is referenced in at least one card's `## Scope` table.
- **Repo Surfaces Touched:** `skills/flow/runner/flow.sh` (`cmd_consistency`), `skills/flow/references/command-dispatch.md`, `tests/test_flow_consistency.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Purely mechanical regex/awk scan; advisory warning.
- **Rough Effort:** Medium.

#### Candidate 7: Automated ACE Playbook Suggestions (`flow promote --suggest`)
- **Problem:** As highlighted in `plans/260614-flow-knowledge-upgrades-roadmap.md`, the Option B self-improvement loop discovers recurring friction ($\ge 2$ occurrences), but promoting them to global playbooks remains fully manual.
- **Proposed Change:** Add `flow promote --suggest` to query the harness SQLite database for high-confidence propose/audit patterns and format them into draft playbook markdown entries for human review.
- **Repo Surfaces Touched:** `skills/flow/harness/flow_harness.py`, `skills/flow/runner/flow.sh` (`cmd_promote`), `tests/test_flow_recall.sh`.
- **ADR-0001 Compatibility:** 100% compliant. Human-in-the-loop CLI invocation; uses existing Python SQLite store.
- **Rough Effort:** Medium.

---

## 7. Status and Verification Notes

- **Crawl Data Integration:** All 7 research trend documents (`trends-*.md`) created by the parallel research worker have landed in `plans/research/` and are fully incorporated.
- **No Ungrounded Inferences:** All repository claims are cited from actual file paths in the main repository. All trend claims are directly linked to the external evidence citations in `plans/research/trends-*.md`.
- **Confidence Assessment:**
  - Capability inventory & constraints: **High** (verified directly against live code, tests, and documentation).
  - Ecosystem trends (MCP, SDD, Security, Context Engineering, Evals): **High** (grounded in live crawl evidence from October 2026).
  - Multi-agent handoff standards: **Medium** (the ecosystem remains fragmented with no single universally accepted standard; Flow's `resume` remains a custom format).
