# Plan — AgentKit Engineer → Flow upgrade wave 261013 (Decision & Delivery Record)

Status: **targeted slices verified; full 66-suite result unverified**.
User-authorized revision of prior flat rejections is recorded in `docs/adr/0001-discipline-layer-identity.md` § Addendum (2026-10-13).
This file records delivery status, verified targeted evidence, and unverified master full-suite retention status.
## Delivered (tested enhancements)

### W1 — runner worker (source-workstream owner)
- `doctor --list`, `doctor --check <csv>`, `doctor --json` with envelope
  `schema_version: 1, kind: doctor.report` (healthy/summary/checks), argument pre-scan,
  unknown check name = loud error, dev-checkout receipt = advisory skip. **Doctor is the
  only JSON verb this wave** (broader read-only-verb envelopes were evaluated and NOT
  selected — narrowed scope per director).
- 12 named checks, exact registry: `os, bash, python, sqlite3, grep_p, git, cargo,
  templates, harness, timeout, bundled_tree_integrity, install_homes`.
- Full-tree integrity receipt: `npm-wrapper/scripts/sync.mjs` emits tree-wide
  `manifest-hashes.json` (schema_version 1, current-only); `doctor_helper.py` verifies
  tamper/missing/symlink/containment; runner-only legacy path removed (clean cutover).
- The `routing_registry` doctor check was dropped — not needed (routing validation lives
  in the semantic layer + W2 suite). Never built.
- Files (W1-owned): `runner/flow.sh`, `runner/doctor_helper.py`, `npm-wrapper/scripts/sync.mjs`,
  `scripts/pack-rehearsal.sh`, `tests/test_flow_doctor.sh`, `tests/manifest.txt` edits,
  `command-dispatch.md`, `docs/system-architecture.md`, `CHANGELOG.md`.

### W2 — host-context adapter + semantic map (this worker)
- ADR-0001 Addendum: accepted boundary for operator-installed, host-fired advisory context
  adapters (exact exception, zero interposition, sole private write, revision rule);
  roadmap non-goal 3 revised to point at it.
- `skills/flow/adapter-hooks/{flow-context-handler,context_handler.py,claude-settings-snippet.json}`:
  PreCompact = bounded `status` snapshot into private `.flow/context-handoff/snapshot.json`
  (stdout always empty — the host does not inject PreCompact stdout); SessionStart = fresh
  authoritative `status` recompute, source-labeled, validated snapshot as staleness
  reference or STALE-labeled fallback. Hardening: strict JSON (duplicate keys rejected),
  64 KiB/deadline stdin, strict UTF-8, env bounds (floor 1024), dir_fd O_NOFOLLOW
  ownership/mode traversal (write and read), saved-pgid group kill + reap with orphan
  evidence, `FLOW_PROJECT_ROOT` pinned + `FLOW_LOG_DISABLE` pinned (no telemetry, no
  cross-project leak), no raw payload/cwd/class/runner-stderr in any output or warning.
- Semantic map: live-host-registry authoritative resolution (exact name + accessible
  SKILL description when safe; active catalog metadata sufficient; no fixed home list or
  counts), `ak-security-scan` alias removed, scanner≠STRIDE honesty clause.
- Docs: `references/host-hooks.md` (honest event model, per-host disclosures incl. "no OMP
  runtime claim", verified-scope annotations), SKILL.md dispatch pointer, law/onehome
  cross-references reconciled.

## Evaluated, NOT selected this wave (no silent shrink — explicit rationale)

- **C4 installer safe-ownership slice** (snapshot + OMP home + `FLOW_VERSION` pin):
  deficiency corroborated in both channels (npm has no OMP support; `installer.mjs:203`
  documents install.sh's no-rollback weakness), but not selected for this wave — it is an
  independent candidate left open in `plans/research/agentkit-flow-upgrade/candidates.md`,
  to be reconsidered with its own slice owner. Not promised, not silently dropped.
- Broader read-only JSON envelopes, `ak onboard` conductor port, `doctor --fix`,
  test-impact playbook (C7), `usage --summary` (C8): evaluated in the gap matrix,
  not selected; rationale in `flow-gap-map.md` §2-3.
- Throwaway smoke manifest row: never requested; the throwaway smoke was retired after
  proof and replaced by the permanent suite below.

## Permanent regression suite

`tests/test_flow_host_hooks.sh` (44/44 PASS on Linux event replay): persistence
contract + modes, strict parser, ownership/mode/symlink refusals, cross-project refusal,
byte caps, saved-pgid timeout kill with orphan evidence, active secret token exclusion,
telemetry suppression, inherited-root shield, launcher no-python fail-open.
W1's suite: `tests/test_flow_doctor.sh` (40/40 PASS on behavioral/schema assertions).
## Rollback

- W1: revert the change set (receipt schema + doctor consumer move together; no data
  migration — the receipt is regenerated at pack time).
- W2 code: revert `adapter-hooks/` + SKILL/reference pointers.
- W2 operator-side removal: delete the two hook entries from host settings; optionally
  delete the adapter-owned `.flow/context-handoff/` directory. Nothing else persists.

## Verification status
- W2: `bash tests/test_flow_host_hooks.sh` → 44/44 PASS (Linux). Verified with safe
  owned-pid lifecycle (kill -0 observational only, zero pgrep/pkill) and secret token
  injection testing.
- W1: `tests/test_flow_doctor.sh` 40/40 PASS, `tests/test_manifest_runner.sh` 12/12 PASS,
  `tests/test_flow_runner.sh` 28/28 PASS, `npm test` 45/45 PASS, `scripts/pack-rehearsal.sh` 22/22 PASS,
  `scripts/check-doc-budgets.sh` PASS (5/5 files), `scripts/check-release-coherence.sh` PASS.
- Independent review status: `agentkit-review` conducted comprehensive read-only review
  (report in `plans/261013-agentkit-engineer-upgrade/integration-review.md`). 0 blocking P0/P1 issues.
  Controlled verification matrix passed 27/27 test scenarios.
- Master Full Suite (`tests/run_all.sh`): Initial run (`bg_73`) reached 384 lines covering
  first 10 suites before tool runner 300s deadline at `test_flow_eval.sh`. Re-spawned with
  `timeout: 0` (`bg_76`), but terminal exit receipt and full summary retention are unavailable
  in the session transcript. Status: **full 66-suite result unverified** (missing prerequisite:
  terminal exit summary retention).
- Reverse analysis honesty: REA evidence index retains 10 verified records and 4 residual
  unknowns; native decompilation truthfully noted as NONE (blocked by host toolchain prerequisites:
  Temurin JDK 17 vs JDK 21+ for Ghidra, REA_PWNTOOLS_PYTHON unset). No proprietary code copied.
## Constraints honored

Website/ untouched; `_eval_engine_run`/`_run_with_timeout` untouched; bash 3.2 launcher +
Python stdlib; zero new runtime dependencies; no billable calls; no verbatim AgentKit
content (license still unresolved — behavior-level only); no gate-enforced rule added
(fixture-pair rule not triggered).
