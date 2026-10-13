# Structured candidates — AgentKit→Flow upgrade wave (ranked, evidence-backed)

Ranking standard: verified code+source evidence first, then user-visible outcome, then effort. Each candidate is an independent, implementable slice; no runtime growth, no website/, no eval-STOP bodies, no new deps, bash 3.2, no billable calls. Gap-row refs point at `flow-gap-map.md`.

---

## Rank 1 — C1: Live-host registry authoritative skill resolution (semantic map slice)

- **Gap rows:** G1 · **Effort:** M · **Conflict:** none · **ADR:** none · **Owner:** second worker (host-context adapter + semantic map)
- **Evidence (code):** `skills/flow/references/claudekit-skills.md:49` (`ck-loop → ak:loop, ak-loop, loop`), `:52` (`security-scan → ak:security-scan, ak-security-scan`) — static alias strings, no live verification [V].
- **Evidence (source, authoritative):** peer inventory `plans/research/agentkit-engineer-installed/inventory.json` — **102 kit skills; `ak-loop` IS a genuine kit export; `ak-security` is the scanning skill; `ak-security-scan` does not exist** [V jq select on components.skills]. Disk listing alone is NOT the registry and never justifies "stale/orphan" labels; the live host registry (`ak skills` catalog / installed `SKILL.md` equivalence) is authoritative.
- **Flow location:** `references/claudekit-skills.md` (Name resolution), `references/agent-detection.md`, `references/agent-stage-mapping.md`, `tests/test_flow_claudekit_integration.sh`.
- **Smallest coherent adaptation:** exact alias resolution against the live host registry: resolve each deep-wire row by exact name (`ak-loop`, `ak-security`), preserving `ak-loop` when callable, offering it only when the registry/SKILL.md equivalence verifies; remove the never-existing `ak-security-scan` alias. **Honesty rule:** native STRIDE (`references/native-rituals.md`) is a semantic adversarial-review ritual, NOT a mechanical secret scanner — never present it as an equivalent substitute for `ak-security`/scan behavior; the loop protocol baseline claim stays (numeric loop is genuinely native). No `ak-autoresearch`/`ak-codex-goal` substitution for loop (no equivalence evidence).
- **Tests (no tautologies):** delete existing assertions that merely re-assert the source wording (alias strings echoed back); replace with a throwaway routing smoke: temp fixture skill homes (present/absent/wrong-name variants) exercising the actual resolution path, asserting offered-vs-withheld outcomes. Suite additions go through `tests/manifest.txt`.
- **Acceptance scenarios:** (a) registry has `ak-loop` → row offers `ak-loop` (callable), native loop protocol as guaranteed baseline; (b) registry lacks it → baseline only, no fabricated alternative, no "stale" language; (c) any request for security scanning resolves exact `ak-security` or says absent — never `ak-security-scan`, never STRIDE-presented-as-scanner.
- **Independent test:** throwaway routing smoke suite (new, manifest-registered); delete replaced tautological tests in the same change.

## Rank 2 — C2: Named-check doctor registry (`doctor --list` / `doctor --check …`)

- **Gap rows:** G3 (+G10 outcomes, G8 drift check) · **Effort:** M · **Conflict:** exit semantics — keep flow's exit 0/1 ground truth (no ak-style default-0-healthy) · **ADR:** none
- **Evidence (code):** `cmd_doctor` @flow.sh:2683 is monolithic prose; only integrity is individually checkable [V]. **Source:** ak doctor named-check contract (`--list`, `--check a,b`, advisory Notes vs actionable warnings, unknown name = error, `--offline`); peer: 33 named checks incl. legacy-CK-artifact and `.agentkit`-managed-marker detection [D][P].
- **Flow location:** `cmd_doctor` + new checks; `tests/` new suite + `tests/manifest.txt` row (same change, per AGENTS.md).
- **Smallest coherent adaptation:** refactor existing checks into a named registry (names stable, listed via `--list`, runnable via `--check n1,n2`, unknown name = **loud command error, exit 1, fix hint — never silent pass**). Add NEW checks only where flow has verified gaps: `install_homes` (enumerate flow copies across `~/.claude`, `~/.codex`, `~/.agents`, agy paths, project `.claude` [V homes]; report shadow/dup with precedence note), `routing_registry` (C1's live-registry probe surface, no orphan heuristics), `receipt_present` (advisory only; dev checkout), `version_coherence` (npm wrapper version vs bundled SKILL version). Default no-flag invocation byte-identical behavior; failures keep loud exit 1.
- **Acceptance scenarios:** (a) `flow.sh doctor --list` prints registry; (b) `flow.sh doctor --check install_homes` on a machine with project+global copies reports both + shadow warning, exit still 0/1 by finding severity; (c) unknown name exits 1 with fix hint; (d) full suite green cross-OS.
- **Independent test:** new `tests/test_flow_doctor_checks.sh` + manifest row; `bash tests/run_all.sh` slice.

## Rank 3 — C3: Full-distribution integrity receipt (tree-wide drift audit)

- **Gap rows:** G2 · **Effort:** M · **Conflict:** none (read-only) · **ADR:** none
- **Evidence (code):** `npm-wrapper/scripts/sync.mjs` trust-model comment: co-shipped `manifest-hashes.json` detects "POST-INSTALL drift of the **runner only**… does NOT establish package authenticity" [V]; `cmd_doctor` @2724-2751 verifies `flow.sh` only [V]. **Source:** ak records byte fingerprints for every managed path; drift classes clean/modified/unknown; read-only `ak audit` [D].
- **Flow location:** `npm-wrapper/scripts/sync.mjs` (receipt writer), `skills/flow/manifest-hashes.json` (consumer schema), `cmd_doctor` integrity branch, `scripts/pack-rehearsal.sh`, `tests/test_manifest_runner.sh`.
- **Smallest coherent adaptation:** **clean cutover, no legacy fallback shim**: receipt schema becomes current (whole bundled tree) in the same change across sync.mjs + doctor; the runner-only old path is removed, not shimmied. An absent/stale-schema receipt is an **advisory** finding ("dev checkout — install receipt not present"), not a FAIL and not a compatibility branch. Doctor integrity check classifies per-file clean/modified/missing; runner drift stays loud FAIL. Tamper honesty caveat stays documented (attacker rewriting bytes+receipt is out of scope — same as today).
- **Acceptance scenarios:** (a) npm install, edit `references/gate-rules.md` in place → `flow.sh doctor` names the modified file; (b) pristine install → no findings; (c) dev checkout without receipt → single advisory line, exit unchanged, no runner-only code path remains; (d) `npm-wrapper && npm test` + pack-rehearsal green.
- **Independent test:** `cd npm-wrapper && npm test`; `bash scripts/pack-rehearsal.sh`; doctor slice of `tests/run_all.sh`.

## Rank 4 — C4: Safe install ownership (snapshot + OMP home + version pin) — SUPERSEDED by wave-2 implementation (2026-10-13)

- **Status update (2026-10-13):** the npm-channel portion of this candidate is IMPLEMENTED beyond the original sketch, with a stronger design than the `.prev-YYYYMMDDHHMMSS` snapshot idea below. What landed in `npm-wrapper/src/installer.mjs`: a receipt-driven transactional upgrade (strict conflict/collision/root-mismatch refusals with no `--force`, preservation of user files everywhere in the destination, prune-only-unmodified retired files, rename-only backup/promote with promoted-tree verification, `recoveryPath` reporting on failed rollback) — the timestamped-snapshot sketch is obsolete because the receipt proves ownership exactly, and `Date.now()`-predictable slots were explicitly rejected. The OMP target (`~/.omp/agent/skills`, live-probed) is implemented in the npm channel; the shell/PowerShell parity portion belongs to the dedicated native installer workstream (ownership receipt contract handed off 2026-10-13). `FLOW_VERSION` pin remains UNIMPLEMENTED (not selected this wave; still open here).
- **Gap rows:** G6 + G7 + G8 · **Effort:** S each, one installer slice · **Conflict:** none (installer-side, host/operator-invoked) · **ADR:** none
- **Evidence (code, at research time):** `install.sh`: global → `~/.claude/skills/flow` always + `~/.codex`/`~/.agents` conditionally + agy; **no `~/.omp/agent/skills` home, no pre-overwrite snapshot, no version pin** [V + pattern-scan S]. **npm-wrapper corroboration [V] at research time:** no OMP support at all; `src/installer.mjs` documented that install.sh "makes 2 separate install_to calls with no rollback if the 2nd fails". **Source:** ak pre-install recovery snapshot default (`--no-backup` opt-out) [D][P]; OMP native projection `.omp/skills/…` [D runtime-adapters — note: the live host's real skills home is `~/.omp/agent/skills`, which is what shipped]; `AK_VERSION` pin + idempotent re-run [D docs].
- **Original sketch (historical):** (a) `.prev-…` snapshot + restore hint; (b) conditional `~/.omp/agent/skills/flow` global home; (c) `FLOW_VERSION` pin. (a) and (b) superseded as above; (c) open.
- **Acceptance scenarios (updated):** update over receipted install preserves customs and prunes only unmodified retired files [npm: PASS — installer.test.mjs]; user-modified owned file aborts before touching the original [npm: PASS]; OMP explicit target installs with correct files + receipt, bare-`~/.omp` never autodetects [npm: PASS — detect/cli tests + temp-HOME CLI e2e]; failed promote/verify restores the original exactly; failed restore keeps the backup and reports `recoveryPath` [npm: PASS — injected-failure tests]. Shell/PS1 equivalents: native workstream, pending.

## Rank 5 — C5: Read-only verb JSON envelopes + exit-code table (contract docs)

- **Gap rows:** G4 · **Effort:** M · **Conflict:** must preserve display-only rule (hosts never exec `next_verb`) · **ADR:** none
- **Evidence:** ak uniform `--json` envelope (`schema_version`/`kind`/`data`) + three-base-exit-code table [D cli-conventions, doctor]; flow today: `status/resume --json` only, display-only `flow_context/v1` [V].
- **Flow location:** `flow.sh` read-only verbs (`doctor`, `gate`, `debt list`, `usage` first), `references/command-dispatch.md` (exit table), `tests/test_flow_status_legibility.sh` pattern.
- **Smallest coherent adaptation:** document per-verb exit table; add opt-in `--json` envelopes for read-only verbs reusing the `flow_context/v1` envelope style. No mutation verbs in v1; prose remains default.
- **Acceptance:** `flow.sh doctor --json` parses; hosts gate on exit codes per documented table; suite green.

## Rank 6 — C6: Opt-in host-hook adapter sidecar (CONDITIONAL — ADR-0001 addendum first)

- **Gap rows:** G5 · **Effort:** M · **Conflict:** ADR-0001 adjacent — requires an explicit ADR-0001 reevaluation/addendum recording the boundary (host-invoked, terminating, never gate-bearing, never PreToolUse) BEFORE implementation. Attribution: director-ordered re-evaluation of the flat rejection; the ADR-reopen/reevaluation gate itself remains a hard developer constraint, not a preference.
- **Evidence:** ak ships hooks as disclosed, inactive-by-default sidecars with per-target drop/narrow disclosures; "a Hook is not a security boundary"; peer observed `hook_registration="skip"` (sidecars only) on OMP/Claude here [D][P]. Prior flow rejection was flat (roadmap non-goal 3).
- **Flow location (proposed):** `skills/flow/adapter-hooks/` (templates, NOT registered by any installer) + `references/host-hooks.md` (per-runtime disclosure table); operator copies into their runtime config themselves.
- **Shape:** SessionStart → `flow.sh status` (display-only), PreCompact → `flow.sh resume --budget`; fail-open; never gate-bearing; no PreToolUse; no daemon (host fires them; bytes terminate on return — invariant wording holds).
- **Acceptance:** with hook installed by operator, a compacted session opens with fresh `NEXT ->` context without manual `/flow`; with nothing installed, flow behavior identical; ADR addendum merged first.
- **Sequencing:** implement only after the ADR addendum lands in the same wave; if the addendum stalls, C6 drops out without blocking C1–C5.

## Rank 7 — C7: Test-impact advisory playbook

- **Gap rows:** G9 · **Effort:** S · **Conflict:** none (advisory; no new gate ⇒ no fixture-pair obligation) · **ADR:** none
- **Evidence:** `ak test optimize/classify-e2e/benchmark` [D cli index]; flow has card `## Independent test` but no slice→suite mapping guidance [V].
- **Flow location:** `references/test-impact.md` + one pointer in `law/CODING.md`.
- **Acceptance:** a card touching `runner/flow.sh` verbs lists the affected suites from `tests/manifest.txt` instead of defaulting to the full 3-OS suite; advisory only — gates unchanged.

## Rank 8 — C8: `usage --summary` (verify-before-build)

- **Gap rows:** G-matrix usage note · **Effort:** S (after verification) · **Conflict:** none · **ADR:** none
- **Evidence:** ak exposes usage/insights surfaces [D]; flow has `cmd_usage` @flow.sh:5605 — **shape unread this session**; build only if aggregation is genuinely absent (do not duplicate an existing summary).

---

## Not candidates this wave (evaluated, retained)

Resident MCP server / interposition; watcher/daemon; flow-orch runtime; graph-executor default-on (reopen only on measured task fit); one-shot runtime dispatch (`ak run` analogue — ADR-0001 reopen entry point, no adopting evidence); `doctor --fix` auto-repair (relay-only retained); full `ak onboard` conductor (covered by C2 checks); compiled deps. Rationale table: `flow-gap-map.md` §3.

## Verification main agent should run after implementation slices

Per AGENTS.md test-evidence protocol: C1 → `bash tests/test_flow_claudekit_integration.sh`; C2/C3/C4 → their new suites + `cd npm-wrapper && npm test` (C3) + `bash scripts/pack-rehearsal.sh` (C3/C4); cross-cutting → `bash tests/run_all.sh`; docs-touching → `bash scripts/check-doc-budgets.sh`.
