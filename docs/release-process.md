# Release process — skill product + npm installer

Canonical runbook for shipping future versions. Release policy: [`docs/adr/0002-unattended-release-policy.md`](adr/0002-unattended-release-policy.md).

## Two version axes

| Axis | Declared in | Bump when | Installed as |
|---|---|---|---|
| Skill product | `skills/flow/SKILL.md` metadata.version | Flow behavior/content changes | Installed skill tree |
| Skill mirrors | `.claude-plugin/plugin.json`, `portable-manifest.json` | Same skill change | `/flow coherence` enforces parity |
| npm installer | `npm-wrapper/package.json` | Installer CLI/targets/sync/release behavior changes | `npx @manhquy/flow-skill@latest` or exact version; prerelease `@next` |

`flow-skill` reports both npm package and bundled skill version. Each release PR updates the intended axes, changelogs, synchronized docs, and release intent. `skill_version: null` explicitly selects npm-only installer publication and must not recreate a prior skill tag/Release; a non-null skill version selects both npm and skill axes. Loop ticks without a version/changelog change do not publish. Breaking compatibility or expanding security/service rights needs a separate owner decision.

## Automatic release path

A reviewed release-preparation PR merges to `master`; exact-master CI passes; OMP invokes `bash scripts/release.sh --yes`. The canonical script dispatches `.github/workflows/publish-npm-wrapper.yml` with the full expected master SHA and npm version. The publisher independently validates the request, latest authoritative CI run and `all-checks-passed` job, merged PR base/repository, dual-axis version/changelog coherence, SemVer monotonicity, and registry state. Only exact E404 means absent. Other errors fail closed.

Publisher dispatch defaults to `dry-run`. Live mode requires `FLOW_AUTOPUBLISH_ENABLED=true`, passing eligibility, and master-only `npm-publish` environment. The eligibility job has no OIDC permission or environment; only the publish job has OIDC. There is no tag-push publish trigger. Tags are created after npm registry/provenance/install verification and never authorize publication.

`npm-publish` currently has exactly one branch deployment rule, `master`, no tag rules. Controller verified historical `npm@0.7.11` dispatch rejection before job execution/OIDC: run `39210527539`, job `117922661201`, with zero steps and environment-protection denial annotation. Evidence: `.omp/flow-maintenance/backups/release-remote-20261019T055718Z/`. This historical probe does not prove a new publisher path is safe; implementation review, exact CI, default-off/dry-run proof and controller readback remain required before enabling live publishing.

## Phase 1: release preparation PR

1. Bump only the versions required for a meaningful release. Skill version is declared in `skills/flow/SKILL.md`; keep `.claude-plugin/plugin.json` and `portable-manifest.json` coherent. npm installer version is `npm-wrapper/package.json`.
2. Add exact release headings/notes in root `CHANGELOG.md` (skill axis) and `npm-wrapper/CHANGELOG.md` (installer axis). Ensure compatibility classification and no unapproved breaking/security-rights expansion.
3. Synchronize docs and bundled tree; run `node scripts/sync-release.mjs --sync`, `node scripts/sync-release.mjs --check`, `bash scripts/release-preflight.sh`, i18n verification and relevant package tests.
4. Merge through repository review/thread-resolution/required-CI gates. Do not tag, publish or change remote settings in the PR.

## Phase 2: OMP promotion

```bash
bash scripts/release.sh --dry-run
bash scripts/release.sh --yes
```

`--yes` requires clean working tree, local `master == origin/master`, dual-axis coherence/changelog entries, zero sync drift, i18n integrity, unused tags, exact-HEAD authoritative CI, and read-only verification battery. It dispatches with a unique request UUID through the workflow-dispatch REST endpoint using `return_run_details=true`, then validates the returned repository-bound `workflow_run_id` and watches that exact run. A 204/missing/invalid response is an ambiguous dispatch: fail closed and do not redispatch blindly. After the run succeeds, re-read and verify its workflow path, ref, SHA, event, title, attempt and conclusion, then require successful eligibility and live publish jobs from that exact attempt (dry-run requires publish to be skipped). Finally verify registry integrity/provenance/install smoke; only then create/push tags and the GitHub Release.

Stable releases publish to `latest`; prereleases to `next`. Stable versions are never downgraded. A prerelease does not automatically move `latest` backward or promote itself to `latest`.

## Artifact and post-publish verification

The publisher packs exactly once because `npm-wrapper/scripts/sync.mjs` writes nondeterministic `skills-manifest.json.syncedAt`. It publishes that exact `.tgz`; retries must verify the same artifact identity. After publish, require exact registry version, SHA-512 integrity, provenance binding repository/workflow/ref/commit, expected dist-tag, and run:

```bash
node npm-wrapper/scripts/smoke.mjs <exact-version>
npm view @manhquy/flow-skill dist-tags --json
npm view @manhquy/flow-skill@<exact-version> dist.integrity dist.attestations.provenance
```

The smoke runs against the public registry from a clean temporary working directory. Missing/mismatched provenance or failed install/CLI/skill checks is a failed release verification; never republish the immutable version to hide partial state.

## Failure and rollback

- Any non-E404 registry error, incomplete GitHub API/pagination, stale master, failed/newer CI attempt, missing/wrong-base merged PR, version/channel mismatch, integrity/provenance mismatch, or failed smoke stops the release.
- Existing npm version is verify-only. Reconcile only exact artifact integrity, provenance, channel and expected tag/Release target. Missing/mismatched tags/releases require owner action; no automatic repair.
- To pause automation, controller disables `FLOW_AUTOPUBLISH_ENABLED` or disables the publisher dispatch path. Never unpublish or move existing versions/tags.
- Same-owner credentials can change workflow/variable/environment; OIDC/SLSA provides traceability, not an independent identity boundary.

## Related files

| File | Role |
|---|---|
| `scripts/release.sh` | Canonical OMP-invoked promotion gate and publisher-run verifier |
| `scripts/sync-release.mjs` | Release coherence and promotion implementation |
| `scripts/release-eligibility.mjs` | Pure fail-closed eligibility evaluator |
| `scripts/release-workflow.mjs` | GitHub/npm adapter and artifact verification |
| `.github/workflows/publish-npm-wrapper.yml` | Master-only OIDC publisher; no tag trigger |
| `.github/workflows/ci.yml` | Cross-OS authoritative CI (`all-checks-passed` job) |
| `npm-wrapper/scripts/smoke.mjs` | Public-registry installed-artifact smoke |
| `docs/adr/0002-unattended-release-policy.md` | Accepted unattended-release decision and gates |
