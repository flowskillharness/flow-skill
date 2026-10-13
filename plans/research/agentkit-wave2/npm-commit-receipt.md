# npm Scoped Commit Receipt — Wave 2 (2026-10-13)

**Status:** Scoped npm channel commit complete; release publication and version mirrors held pending native workstream completion. No git push executed.

## Commit Details

- **Commit Hash:** `5474907543c2d77c0fc779209cff7fa151ce8020`
- **Branch:** `master`
- **Subject:** `feat(installer): transactional ownership upgrades and OMP target for npm channel`
- **Files Committed:** 20 files (+1883, −186):
  1. `npm-wrapper/src/constants.mjs` (OMP target added, CLEANUP_SUBDIRS deleted)
  2. `npm-wrapper/src/installer.mjs` (transactional ownership engine)
  3. `npm-wrapper/bin/cli.mjs` (OMP restart hint, install:done recovery fields)
  4. `npm-wrapper/test/cli.test.mjs` (OMP CLI tests, exact plan target set)
  5. `npm-wrapper/test/detect.test.mjs` (bare vs genuine OMP boundary)
  6. `npm-wrapper/test/installer.test.mjs` (26 tests for transactional ownership & recovery)
  7. `npm-wrapper/scripts/smoke.mjs` (scratch-HOME OMP smoke & receipt validation)
  8. `npm-wrapper/README.md` (OMP target & uninstall rows)
  9. `npm-wrapper/README_VN.md` (OMP target & uninstall rows)
  10. `npm-wrapper/SECURITY.md` (transactional integrity model)
  11. `npm-wrapper/CHANGELOG.md` (OMP & transactional installer unreleased entries)
  12. `CHANGELOG.md` (root, npm channel entries)
  13. `SECURITY.md` (root, npm channel integrity model)
  14. `docs/system-architecture.md` (npm channel transactional ownership upgrades)
  15. `plans/research/agentkit-flow-upgrade/candidates.md` (C4 superseded status update)
  16. `plans/research/agentkit-wave2/evidence-index.json` (wave 2 REA capture index)
  17. `plans/research/agentkit-wave2/omp-target-analysis.md` (host probe & target analysis)
  18. `plans/research/agentkit-wave2/safe-installer-plan.md` (approved architecture plan)
  19. `plans/research/agentkit-wave2/wave2-npm-report.md` (verified test evidence report)
  20. `plans/research/agentkit-wave2/wave2-plan.md` (wave 2 research notes)

## Security Evidence

- `git diff --cached` secret scan: 0 matches (clean).
- No API keys, credentials, or private keys committed.
- Raw REA bundle (`/tmp/rea-evidence-bundle-agentkit-wave2.json`, 49.4 MB) kept external; only sanitized index committed.
- No `~/.agentkit/auth` data committed.
- No proprietary code committed.

## Explicitly Excluded Unsafe / Native Paths

- `skills/flow/runner/installer_helper.py` (untracked, active native workstream file; excluded from commit)
- `install.sh` / `install.ps1` (clean on master; native workstream owner sole editor)
- Native bash integration suites (to be added by native workstream)
- Synced package distribution tree (not re-synced until native helper is verified)

## Verification Evidence (Reusable Unchanged)

- `node --test test/installer.test.mjs`: 26/26 pass.
- `npm test` (npm-wrapper full suite): 63/63 pass.
- Adversarial JSON receipt parser battery: 13/13 pass (duplicate keys, unicode escapes, proto keys, digest length/pattern).
- Real CLI temp-HOME e2e: fresh install, idempotent custom preservation, and conflict refusal verified on disk without real HOME mutation.
- `scripts/check-doc-budgets.sh`: PASS (5/5 files).
- `scripts/check-release-coherence.sh`: PASS.
- Master full-suite 66-suite run: terminal receipt remains unverified (prior wave baseline preserved).

## Release Readiness & External Gates Status

- **Publishing Held:** Version bump, tag creation (`npm@...` / `v...`), and push are held until `agentkit-native-install` finishes the shell/PowerShell/helper transaction parity, avoiding release of an incomplete or contaminated package artifact.
- **Publish Workflow:** Requires GitHub Environment `npm-publish` with required reviewer approval. Laptop `npm publish` is forbidden.
- **Website Pipeline:** Scheduled/release workflow dispatch authorized; master `website/` remains untouched.
