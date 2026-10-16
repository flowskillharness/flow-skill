# Wave 5 Plan: AgentKit Extraction Wave (Next Candidates)

Scope: Open, non-architecturally-conflicting extraction candidates from `flow-gap-map.md` and `candidates.md`. Planning-only artifact.

## 1. Shipped-With-Proof Inventory (Prior Waves)

The following candidates from G1–G12 / C1–C8 are already shipped in master:
- **G1 / C1 (Authoritative skill resolution):** Live-host registry routing in `skills/flow/references/claudekit-skills.md:54-58,72-74` (`ak-security-scan` removed, `ak-loop` callable when verified); tests in `tests/test_flow_claudekit_integration.sh`.
- **G2 / C3 (Bundled tree integrity receipt):** Schema 1 tree receipt in `npm-wrapper/scripts/sync.mjs:223-227`, doctor verification in `skills/flow/runner/doctor_helper.py:180-265`, tracked in `manifest-hashes.json`.
- **G3 / C2 (Named doctor check registry):** 15 registered checks with `--list`, `--check`, `--json` in `skills/flow/runner/flow.sh:3029-3176`, `doctor-checks.tsv:1-15`, `tests/test_flow_doctor.sh`.
- **G5 / C6 (Host lifecycle context hooks):** ADR-0001 addendum + opt-in sidecars in `skills/flow/adapter-hooks/`, docs in `references/host-hooks.md`, verified in `tests/test_flow_host_hooks.sh`.
- **G6 / C4 part (Transactional installer):** Staged update, collision checks, rename backup/promote in `npm-wrapper/src/installer.mjs:200-720`, `test_install_safe_update.sh`.
- **G7 / C4 part (OMP install target):** `~/.omp/agent/skills/flow` explicit target and autodetection in `npm-wrapper/src/installer.mjs:161-178`, `npm-wrapper/scripts/smoke.mjs:153-157`.
- **C8 (`usage --summary`):** Implemented in `skills/flow/harness/flow_harness.py:1001-1006`, invoked by `flow recall` in `skills/flow/runner/flow.sh:2488`.
- **G11 (`audit` verb):** Folded into doctor `bundled_tree_integrity` and `install_homes` checks (`doctor-checks.tsv:11-12`).

---

## 2. Planned Work Items

### - [ ] Item 1: G4 Remainder — Read-Only `--json` Envelopes for `gate`, `debt list`, `usage`
- **Files to touch:**
  - `skills/flow/runner/flow.sh` (`cmd_gate`, `cmd_debt`, `cmd_usage`)
  - `skills/flow/harness/flow_harness.py` (`cmd_usage` JSON envelope normalization)
  - `skills/flow/references/command-dispatch.md` (dispatch table + exit code signatures)
  - `tests/test_flow_runner.sh` (runner slice tests)
- **Acceptance criteria:**
  1. `flow gate <stage> --json` and `flow gate --card C-NNN --json` emit closed envelope: `{"schema_version":1,"kind":"gate.report","target":"...","clean":true|false,"findings":[...]}`. Exit 0 on clean, exit 1 on findings, exit 2 on invalid target or missing card.
  2. `flow debt list --json` emits `{"schema_version":1,"kind":"debt.list","total":N,"open_count":M,"debts":[{"line":N,"text":"..."}]}`. Exit 0.
  3. `flow usage --json` emits `{"schema_version":1,"kind":"usage.report",...}` with identical envelope even when harness is disabled/unavailable (`available: false`). Exit 0.
  4. Display-only rule strictly preserved: no `next_verb` execution in JSON output.
  5. Unknown CLI arguments fail loudly (exit 2) with usage string; prose outputs unchanged when `--json` omitted.
- **Evidence protocol:** `bash tests/test_flow_runner.sh`, `bash tests/test_flow_usage_log.sh`, `bash scripts/check-doc-budgets.sh`.
- **Risks:** Bash 3.2 string escaping without `jq` dependency; must use `_json_str` helper for raw findings/lines to prevent JSON parse errors.

### - [ ] Item 2: G8 — `FLOW_VERSION` Install Pin + `version_coherence` Doctor Check
- **Files to touch:**
  - `install.sh` / `install.ps1` (respect optional `FLOW_VERSION` environment variable pin)
  - `skills/flow/runner/doctor-checks.tsv` (register check #16 `version_coherence`)
  - `skills/flow/runner/doctor_helper.py` (implement `version_coherence` check logic)
  - `skills/flow/runner/flow.sh` (`cmd_doctor` runner check integration)
  - `tests/test_flow_doctor.sh`, `tests/test_manifest_runner.sh`, `tests/test_install_safe_update.sh`
- **Acceptance criteria:**
  1. `install.sh` and `install.ps1` check `FLOW_VERSION`: when set, verifies git tag / release archive availability, echoes resolved pin, and aborts before install if version does not exist.
  2. `flow doctor --list` includes `version_coherence	integrity	Installed skill and packaging version alignment`.
  3. `flow doctor --check version_coherence` inspects `SKILL.md` frontmatter vs installed receipt / package metadata: PASS when aligned, advisory NOTE for git dev checkouts, FAIL on mismatched product version.
  4. Exit code 0/1 contract preserved: unknown check name exits 1 with loud error.
- **Evidence protocol:** `bash tests/test_flow_doctor.sh`, `bash tests/test_manifest_runner.sh`, `cd npm-wrapper && npm test`.
- **Risks:** False positives in dev checkouts where npm package files are not in the skill directory; must distinguish development roots from packaged installs.

### - [ ] Item 3: G9 — Test-Impact Advisory Playbook (`references/test-impact.md`)
- **Files to touch:**
  - `skills/flow/references/test-impact.md` (new advisory playbook)
  - `skills/flow/law/CODING.md` (link suggestion in card independent test law)
  - `docs/doc-budgets.txt` (budget tracking for new reference file)
- **Acceptance criteria:**
  1. `references/test-impact.md` maps repository subsystems (runner, harness, adapter-hooks, doctor, installer, references) to exact test suites in `tests/manifest.txt`.
  2. Provides `git diff --name-only` scoping guidelines to select targeted suites instead of running the full 3-OS suite.
  3. Strictly advisory: no mandatory mechanical gate added to `flow next` or `flow check` (zero new gates; fixture-pair rule not triggered).
  4. `scripts/check-doc-budgets.sh` passes with new file budgeted.
- **Evidence protocol:** `bash scripts/check-doc-budgets.sh`, `bash tests/test_doc_budgets.sh`.
- **Risks:** Scope creep into mandatory gating; must stay an advisory recommendation.

---

## 3. Candidates Sweep & Decision Table

| Candidate / Gap | Decision | Rationale |
|---|---|---|
| **G4 remainder** (`gate`, `debt`, `usage` `--json`) | **SHIP** | Completes read-only machine gating contract without host next_verb execution. |
| **G8** (`FLOW_VERSION` pin + doctor check) | **SHIP** | Reproducible shell installations and cross-axis version drift detection. |
| **G9** (`references/test-impact.md`) | **SHIP** | Reduces developer verification loop duration while preserving test rigor. |
| **G10** (State-aware onboarding conductor) | **DEFER** | Redundant with doctor checks + install receipt; adds state complexity without distinct value. |
| **G12** (One-shot dispatch `ak run` / `ak orchestrate`) | **CONFLICT (ADR-0001)** | Violates discipline-layer identity; flow never hosts/supervises agent loops. |
| **N1** (Resident MCP server / tool interposition) | **REJECT (ADR-0001)** | Interposition rejected; post-hoc gates provide necessary boundaries. |
| **N2** (Background watcher / daemon) | **REJECT (ADR-0001)** | Host-fired hooks (W2) fulfill context freshness without resident daemons. |
| **N4** (`flow-orch` runtime) | **REJECT (ADR-0001)** | Flow does not own agent process tokens; graph_executor covers opt-in plans. |
| **N5** (Compiled / native dependencies) | **REJECT** | Violates bash 3.2 + Python stdlib + zero runtime dependency invariant. |
| `doctor --fix` (Auto-repair command) | **DEFER** | Violates loud-relay doctrine; gates must never silently lower or auto-mutate. |
| Shell/PS1 transactional installer parity | **DEFER** | npm channel already covers transactional updates; shell installers remain lightweight. |

---

## 4. Constraints Honored

- `website/` remains untouched (owned exclusively by `feat/flow-website`).
- `_eval_engine_run` and `_run_with_timeout` STOP-zones in `runner/flow.sh` remain untouched.
- Bash 3.2 compatibility strictly enforced across all runner and installer scripts.
- Zero new runtime dependencies; relies only on POSIX utilities and Python 3.8+ stdlib.
- Zero billable Claude or LLM API calls; all logic is deterministic and offline.
- No verbatim proprietary AgentKit text; patterns independently re-authored for Flow.
- Gate fixture-pair rule (`eval/fixtures/`) not triggered: no new gate-enforced rule added (all new surfaces are read-only reports or advisory docs).

---

## 5. Verification Matrix

| Planned Item | Existing Suites Extended | New Suite / Manifest Row? |
|---|---|---|
| Item 1 (G4 `--json` envelopes) | `tests/test_flow_runner.sh`, `tests/test_flow_usage_log.sh` | No new suite; extends runner suite |
| Item 2 (G8 version pin + doctor) | `tests/test_flow_doctor.sh`, `tests/test_install_safe_update.sh` | Update `tests/test_manifest_runner.sh` for doctor registry row count |
| Item 3 (G9 test-impact playbook) | `tests/test_doc_budgets.sh` | No new suite; doc budget check only |

---

## 6. Ordered Execution Sequence (Wave 5 Implementation)

1. **Step 1 (Docs / Advisory):** Author `skills/flow/references/test-impact.md`, link from `skills/flow/law/CODING.md`, register in `docs/doc-budgets.txt`, verify via `bash scripts/check-doc-budgets.sh`.
2. **Step 2 (Runner JSON Envelopes):** Implement `--json` flag and closed envelope output for `cmd_gate`, `cmd_debt list`, and `cmd_usage` in `skills/flow/runner/flow.sh` and `flow_harness.py`.
3. **Step 3 (Dispatch Contract):** Document new `--json` flags and exit code table in `skills/flow/references/command-dispatch.md`.
4. **Step 4 (Version Pinning):** Implement `FLOW_VERSION` handling in `install.sh` and `install.ps1`.
5. **Step 5 (Doctor Check):** Add `version_coherence` check to `skills/flow/runner/doctor-checks.tsv`, implement verification in `skills/flow/runner/doctor_helper.py`, integrate into `cmd_doctor` in `flow.sh`.
6. **Step 6 (Tests & Evidence):** Add unit tests to `tests/test_flow_runner.sh`, `tests/test_flow_doctor.sh`, and `tests/test_manifest_runner.sh`; run targeted test evidence battery (`test_flow_runner.sh`, `test_flow_doctor.sh`, `check-doc-budgets.sh`, `check-release-coherence.sh`).
