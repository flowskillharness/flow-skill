# Wave 2 — npm-channel implementation report (transactional ownership installer + OMP target)

Date: 2026-10-13. Owner of record for this slice: npm engine/tests/CLI constants/docs-common workstream (`agentkit-handoff-final`).
Status: npm slice implemented and green; native channels (install.sh / install.ps1 / installer_helper.py final form) owned by the dedicated native workstream — **not part of this report's claims**. Commit deferred until native merged + review (standing steering). No push / release / version bump.

## Scope landed (files)

- `npm-wrapper/src/installer.mjs` — full transactional rewrite (ownership-receipt engine).
- `npm-wrapper/src/constants.mjs` — `omp` target added; `CLEANUP_SUBDIRS` deleted (clean cutover).
- `npm-wrapper/bin/cli.mjs` — `RESTART_HINTS.omp`; `install:done` JSONL now carries `code`, `recoveryPath`, `failedCandidatePath`, `partialState`, `preserved`, `retiredRemoved`, `retiredPreserved`; human recovery line on rollback-keep failures.
- `npm-wrapper/test/installer.test.mjs` — rewritten to the ownership/transaction contract (26 tests).
- `npm-wrapper/test/detect.test.mjs`, `test/cli.test.mjs` — omp boundary/plan/project-reject/real-install tests; stale `--help lists 5 targets` wording test deleted; `--all` exact-set consumer test updated.
- `npm-wrapper/scripts/smoke.mjs` — explicit-omp scratch-HOME install + receipt self-hash + bare/genuine detection boundary (post-publish harness).
- `npm-wrapper/README.md`, `README_VN.md` — target table + uninstall rows (EN/VI matched).
- `npm-wrapper/CHANGELOG.md`, `CHANGELOG.md`, `npm-wrapper/SECURITY.md`, `SECURITY.md`, `docs/system-architecture.md` — transaction + omp entries (Unreleased).
- `skills/flow/runner/installer_helper.py` exists in-tree as the native workstream's handoff draft (NOT claimed working; one defect already reported — see findings log).

## Actual verification evidence (commands run, this session)

| Check | Result |
|---|---|
| `node --test test/installer.test.mjs` | 26/26 pass |
| `npm test` (pretest sync runs; full wrapper) | 63/63 pass |
| Receipt parser focused cases (13 adversarial inputs) | all correct: dup top-key / dup path key / unicode-escape-equivalent dup rejected; escaped-quote keys, colons-in-values, nested objects+arrays, `__proto__` own-data accepted; 64-hex length+pattern enforced (trailing-newline digest rejected); self-listing and traversal paths rejected; malformed JSON rejected before semantic walk |
| Real CLI temp-HOME e2e | fresh `--target omp` install OK (materialized tree + fresh receipt); custom file `my-note.txt` survives idempotent update; user-edit of owned `SKILL.md` + regenerated upstream → exit 1 with exact `install:done` payload `install refused before touching <dest>: - user-modified owned file: SKILL.md`, destination bytes untouched; `npm run sync` restored the bundled tree afterwards |
| Earlier temp-HOME probe (pre-implementation baseline) | `-t omp` → `unknown target(s): omp` exit 2; `-t claude` temp dry-run plan OK |
| pack rehearsal (post-OMP, pre-native) | 22/22 + installed-artifact doctor `OK:126` → re-baselined at 127 files after helper draft landed; final re-run deferred until native final form |
| Injected-failure coverage (in tests, real fs + rename seam only) | promote failure → original restored exactly, zero residue; promote+receipt-corruption → verify catches substitution (compared against immutable staged expectation), restore exact; restore-rename failure → `code: EROLLBACK`, `recoveryPath` kept and byte-readable; quarantine-rename failure → candidate left at dest, `failedCandidatePath: dest`, backup preserved (destination rmtree is absent from the engine — forbidden operation) |

## Contract handed to the native workstream (2026-10-13, via director)

Result shape: `{success, dest, error?, code?, recoveryPath?, failedCandidatePath?, partialState?, warnings[], files?, receiptGenerated?, preserved[], retiredRemoved[], retiredPreserved[]}`.
Transaction order + recovery rules + strict receipt schema as specified in the handoff message: validate-before-lock; receipt coverage == source tree minus receipt; read-only survey (dest symlinks first via lstat; broken receipt link = reject not legacy; special files refuse; missing receipted path = root mismatch; user-modified owned = conflict; unowned/legacy differing collision = conflict); stage = new source files only (re-hashed) + preserved customs + retired-modified, NEVER the old receipt; fresh receipt owns only new source files; swap = rename dest→backup, rename stage→dest, verify promoted against immutable staged expectation, rm backup only after verification. Quarantine by rename only; quarantine-rename failure ⇒ candidate stays at dest, no restore onto occupied dest, no rmtree at the destination path; failed restore keeps backup and reports `recoveryPath` + `failedCandidatePath` + `partialState`. Return-failure guarantee only.

## Known pending (not claims)

- Shell/PS1 parity + native test suite: native workstream in progress. Independent read-only review + scratch-HOME smoke to run on their checkpoint; manifest row registration only on the exact filename they provide; final `npm run sync` + `npm test` + `scripts/pack-rehearsal.sh` after their final revision.
- Full 66-suite master run: terminal receipt still unavailable from the prior session — status remains "targeted slices verified; full 66-suite result unverified". No full-suite rerun of unchanged suites; new shell-behavior tests will run specifically when they exist.
- No new features; no host config changes; no real-HOME installs; no billable calls; no commit/push/release.
