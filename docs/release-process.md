# Release process — skill product + npm installer

Canonical runbook for shipping future versions without re-learning CI/OIDC/dist-tag traps.
Ops detail and token hygiene live in [`npm-wrapper/RELEASE_CHECKLIST.md`](../npm-wrapper/RELEASE_CHECKLIST.md).

## Two version axes (do not merge them)

| Axis | Where declared | Bump when | Install / pin |
|---|---|---|---|
| **Skill product** | `skills/flow/SKILL.md` → `metadata.version` | Behavior change in flow runner/harness/refs | Content inside agent homes after install |
| **Skill mirrors** | `.claude-plugin/plugin.json`, `portable-manifest.json` | Same as skill product | `/flow coherence` enforces agreement |
| **npm installer** | `npm-wrapper/package.json` | Installer CLI, targets, sync, publish pipeline | `npx @manhquy/flow-skill@latest` or `@X.Y.Z` (prerelease: `@next`) |

- CLI help prints both: `flow-skill v<pkg> (ships skill v<skill>)`.
- JSONL `plan` event: `version` = npm package, `skillVersion` = skill product.
- Git tags: **`npm@0.1.0-next.N`** triggers npm publish; **`v0.22.0`** is skill product history / GitHub Release — **does not** publish npm.

## Pipelines (automation map)

```
skills/flow/**  ──sync──►  npm-wrapper/skills/flow  (prepack / CI Materialize)
       │
       ├── push master (paths) ──► CI: bash-suite 3-OS + npm-wrapper Node matrix
                            Windows bash-suite timeout = 80m; macOS 25m; others 15m
       │
       └── git tag npm@X.Y.Z + push ──► publish-npm-wrapper.yml
                                         environment: npm-publish (required reviewer)
                                         OIDC + npm publish --provenance --tag next|latest
                                         dist-tag ADD is NOT automated (manual token)

Nightly (cron) ──► smoke.mjs vs dist-tags next + latest (clean cwd, no npm-wrapper shadow)
```

### CI facts (measured)

| Job | Typical duration | Timeout budget |
|---|---|---|
| bash-suite ubuntu | ~8 min | 15m |
| bash-suite macOS | ~11–15 min (measured 14m51s suite + post-job need, previous ~11–13m typical) | **25m** |
| bash-suite Windows | ~54–60 min (measured 54m37s–59m53s across full registered suite) | **80m** |
| npm-wrapper matrix | ~15–40s / cell | 10m |

`tests/run_all.sh` prints `wall_s` per suite + `TOTAL wall_s` for timeout forensics.

### Publish facts

- Pre-release tag (`npm@0.1.0-next.N`) → workflow dist-tag **`next`** only.
- Stable tag (`npm@0.1.0`) → dist-tag **`latest`**.
- `promote_to` workflow input: **manual-only early exit** (prints `npm dist-tag add …`); OIDC cannot dist-tag (E401).
- After every pre-release: decide whether `latest` should follow. If yes → manual promote (checklist).
- **GitHub Release boundary:**
  - GitHub Releases belong to the Skill Product axis (`v<skill_v>`). A GitHub Release with release notes is created for `v<skill_v>` (e.g. `gh release create v0.34.2 --notes-file CHANGELOG.md`).
  - The npm installer axis (`npm@<version>`) triggers the OIDC npm publish pipeline to npmjs.com. It does NOT automatically generate a GitHub Release; any installer GitHub Release is optional and manual.
  - This eliminates confusion between npm publishing and GitHub Releases.

## Harness preflight (every release — skill and/or npm)

From **repo root** (uses dogfood `.flow/` if present; does not require a clean tree):

```bash
bash scripts/release-preflight.sh
# Expect: PREFLIGHT PASS
# Checks: flow coherence · doctor READY · dual-version help · optional harness.db · live dist-tags
```

| Surface | What preflight checks |
|---|---|
| **Docs versions** | SKILL.md ↔ plugin.json ↔ portable-manifest (must match) |
| **Engine** | `flow.sh doctor` READY + harness path present |
| **Memory** | Soft: `.flow/harness.db`, `.flow/events.jsonl` if dogfood exists |
| **npm-wrapper** | `ships skill v…` on `--help` after sync |
| **Registry** | Soft: compare local package.json vs dist-tag `next` / `latest` lag |

`marketplace.json` → `metadata.version` is the **catalog** version, not skill product — do not force it equal to `0.22.x`.

### Release synchronization & coherence tool (`scripts/sync-release.mjs`)

From repo root:

```bash
# Validate release coherence across skill and npm channels with a diagnostic table:
node scripts/sync-release.mjs --check

# Synchronize documentation table rows, re-materialize npm-wrapper/skills, and re-verify:
node scripts/sync-release.mjs --sync
```

`node scripts/sync-release.mjs --check` validates version alignment across `skills/flow/SKILL.md`, `.claude-plugin/plugin.json`, `portable-manifest.json`, `npm-wrapper/package.json`, root and wrapper READMEs (EN and VN), changelogs, runner hash, and dual-axis non-equality (`npm_v !== skill_v`).

## Canonical Two-Phase Release Workflow

Releases follow a strict two-phase lifecycle: **Phase 1 (Preparation in PR)** followed by **Phase 2 (Promotion of Pre-Verified Master HEAD)**.

> **RELEASE BLOCKER NOTICE (Environment Protection):**
> GitHub Actions environment `npm-publish` currently reports `protection_rules: []` (no required reviewers configured).
> A repository owner must configure required reviewers in GitHub Repository **Settings → Environments → npm-publish** before live promotion (`--ship --yes`) can be authorized.
> A passing CI check (`all-checks-passed`) on `master` HEAD validates test and build correctness only; it does **not** authorize automated npm publishing without environment reviewer protection rules.

### Phase 1: Release Preparation (PR Branch)

All changes, documentation updates, version bumps, and synchronizations are performed in a pull request branch before merging to `master`:

1. **Bump versions and update changelogs**:
   - Skill product: `skills/flow/SKILL.md`, `.claude-plugin/plugin.json`, `portable-manifest.json`, and `CHANGELOG.md`.
   - npm installer: `npm-wrapper/package.json` and `npm-wrapper/CHANGELOG.md`.
2. **Synchronize release surfaces**:
   ```bash
   node scripts/sync-release.mjs --sync
   ```
3. **Record i18n pair hashes**:
   ```bash
   bash scripts/check-i18n-pairs.sh record npm-wrapper/README.md
   bash scripts/check-i18n-pairs.sh record README.md
   ```
4. **Validate release coherence locally**:
   ```bash
   node scripts/sync-release.mjs --check
   ```
5. **Commit and open PR**: Commit all release preparation files and merge to `master` once CI passes.

### Phase 2: Release Promotion (Master HEAD)

Once the preparation PR is merged to `master` and the GitHub Actions CI suite (`all-checks-passed`) passes on `origin/master`, execute release promotion:

```bash
# Preview promotion readiness, simulate checks, and verify gates non-mutatingly:
bash scripts/release.sh --dry-run

# Execute live promotion (requires 100% clean master matching origin/master with green CI):
bash scripts/release.sh --yes
```

### Promotion Gates Automated by `scripts/release.sh`:

1. **Cleanliness Gate**: The working tree and index must be 100% clean (zero uncommitted, staged, or untracked files).
2. **Version & Changelog Gate**: Versions exist in manifests and changelog entries exist for both versions in `CHANGELOG.md` and `npm-wrapper/CHANGELOG.md`.
3. **Branch & Remote Equality Gate**: Current branch must be `master`, and local `HEAD` commit SHA must match live remote `origin/master`.
4. **Tag Preconditions Gate**: Release tags `npm@<npm_v>` and `v<skill_v>` must not already exist locally or remotely. Remote connectivity must be confirmed.
5. **Coherence & Non-Drift Gate**: All release surfaces are coherent, synchronization produces zero drift (no file modifications), and committed i18n pair hashes match.
6. **Exact-HEAD CI Status Gate**: GitHub Actions check `all-checks-passed` on the exact `master` HEAD commit must be completed with `conclusion: success`.
7. **Verification Battery**: Runs `check-release-coherence.sh`, `release-preflight.sh`, `pack-rehearsal.sh`, `check-doc-budgets.sh`, `test_doc_budgets.sh`, `test_flow_rules.sh`, and `npm test --prefix npm-wrapper`.
8. **Tagging, Pushing & GitHub Release**: Creates git tags `npm@<npm_v>` and `v<skill_v>`, pushes `master` and tags to origin, creates the official GitHub Release for `v<skill_v>`, and displays next steps. Zero file modifications occur on `master`.
## Skill product release (e.g. v0.24.0)

1. **Implement + tests**
   - `bash tests/run_all.sh` green locally (or rely on CI).
   - Touch only needed suites under `tests/test_flow_*.sh`.
2. **Version coherence (harness gate)**
   - Bump **together**:
     - `skills/flow/SKILL.md` → `metadata.version`
     - `.claude-plugin/plugin.json` → `version`
     - `portable-manifest.json` → `version`
   - `bash scripts/release-preflight.sh` (preferred) or
     `bash skills/flow/runner/flow.sh coherence` from repo root.
   - Expect: single agreed version, no drift warning.
3. **Docs**
   - Root `CHANGELOG.md` skill entry.
   - `docs/quality-metrics.md` status line.
   - Optional: `docs/journals/YYMMDD-…-vi.md`.
4. **Ship skill homes**
   - Dev: `bash install.sh global` / `pwsh install.ps1 global`, or
   - Users: next npm-wrapper release that re-syncs and publishes (below).
5. **Optional git tag**
   - `git tag v0.24.0 && git push origin v0.24.0` + GitHub Release notes.
   - **Does not** publish npm.

### Bundled tree integrity receipt (Full-tree manifest-hashes.json)

`npm-wrapper/scripts/sync.mjs` generates a deterministic tree-wide receipt (`skills/flow/manifest-hashes.json`, `schema_version: 1`) covering all shipped assets across `runner`, `harness`, `templates`, `references`, `law`, and `eval`.
`portable-manifest.json` also carries the runner reference hash in its `hashes` map for checkout coherence; `scripts/pack-rehearsal.sh` and `scripts/check-release-coherence.sh` verify both before packing.
At runtime, `flow doctor` validates every file in the installed tree against `manifest-hashes.json` (failing loudly with exit 1 on drift, missing files, symlinks, duplicate keys, or path traversal; un-receipted local development checkouts print an advisory skip instead). No legacy runner-only fallback path remains.

## npm installer release (e.g. 0.1.0-next.N or 0.1.0)

### A. Pre-flight (local)

```bash
# From repo root — synchronize release docs and verify coherence
node scripts/sync-release.mjs --sync
node scripts/sync-release.mjs --check

# From repo root — harness + coherence + dual-version
bash scripts/release-preflight.sh

cd npm-wrapper
npm run sync          # skills/flow → npm-wrapper/skills/flow
npm test              # 41+ tests; pretest re-syncs
# Dual-version sanity
node bin/cli.mjs --help | head -3
# expect: flow-skill vX.Y.Z (ships skill vA.B.C)

# Bump installer only (use --no-git-tag-version to prevent npm from creating a conflicting v* tag)
npm version prerelease --preid=next --no-git-tag-version   # or patch|minor|major for stable
# Create the npm trigger tag explicitly (npm@* triggers publish-npm-wrapper.yml; v* is skill-only):
git tag npm@$(node -p "require('./package.json').version")

Also:

- Align `npm-wrapper/CHANGELOG.md` Unreleased → versioned section.
- Root README status table: npm package version line.
- `npm-wrapper/README.md` and `npm-wrapper/README_VN.md`: verified by `check-release-coherence.sh` (and `node scripts/sync-release.mjs --check`) and must always match `npm_v` and `skill_v` (run `node scripts/sync-release.mjs --sync` to synchronize automatically).
- Secret grep empty (see RELEASE_CHECKLIST).
- Confirm `bin/cli.mjs` stays mode `100755` in git.

### B. Push code then tag

```bash
git push origin master
git push origin npm@0.1.0-next.N    # example
```

### C. Approve environment

GitHub Actions → **Publish npm-wrapper to npm** → run for the tag → approve **`npm-publish`**.

### D. Post-publish verify (mandatory)

```bash
npm view @manhquy/flow-skill versions --json
npm view @manhquy/flow-skill dist-tags --json
# Pre-release: expect next → new version; latest may lag

npx --yes @manhquy/flow-skill@next --help
# expect: flow-skill v<new> (ships skill v<product>)

npx --yes @manhquy/flow-skill@<exact> --yes --all --dry-run --json
# expect skillVersion field

npm view @manhquy/flow-skill@<exact> dist.attestations.provenance
```

Optional smoke (from **empty temp cwd**, not inside `npm-wrapper/`):

```bash
cd /tmp   # or $env:TEMP empty dir
node /path/to/flow-skill/npm-wrapper/scripts/smoke.mjs <exact-version>
```

### E. Dist-tag policy

| Situation | Action |
|---|---|
| Ship RC for testers | Keep `next` only; document `@next` in README |
| Want bare `npm i` / untagged `npm view` on new RC | Manual: `npm dist-tag add @manhquy/flow-skill@VER latest` (token flow in RELEASE_CHECKLIST) |
| Ship stable `0.1.0` | Tag without preid; workflow sets `latest` |

## Harness / durable layer notes

- Runtime telemetry field `flow_version` in usage events comes from the **installed skill** product version, not npm package version.
- Schema migrations live under `skills/flow/harness/schema/` — bump skill product version when schema/behavior changes; do not bump npm-only for pure skill content unless you also want a new tarball on npm.
- `flow_harness.py` / schema numbers (009–012, …) are independent of npm semver.

## Anti-patterns (learned 2026-07)

| Don't | Why |
|---|---|
| Run nightly smoke / `npx @manhquy/flow-skill@…` with cwd = `npm-wrapper/` | Same package name → local workspace shadows registry |
| Expect `npm dist-tag add` in GHA OIDC | E401; use manual bootstrap token |
| Publish skill version as npm version (`@0.22.0`) | Does not exist; confuses users |
| `npm i` alone for end users | No postinstall; must **run** the CLI |
| Assume Windows bash suite < 15m | Full suite measured ~54–64m; budget is 80m |
| Re-add `NODE_AUTH_TOKEN must be empty` CI guard | Breaks setup-node OIDC (0% pass) |
| Tag `v*` expecting npm publish | Wrong tag shape; need `npm@*` |

## Quick reference — next prerelease

```bash
# 1) skill content already on master, coherent
# 2) installer
cd npm-wrapper && npm run sync && npm test
npm version prerelease --preid=next
# fix tag to npm@X.Y.Z-rc.N if needed
# 3) docs bump CHANGELOG + README status
git push origin master
git push origin npm@$(node -p "require('./package.json').version")
# 4) Approve npm-publish environment
# 5) Post-publish verify @next dual-version + provenance
# 6) Optional: promote latest via manual dist-tag
```

## Related files

| File | Role |
|---|---|
| `npm-wrapper/RELEASE_CHECKLIST.md` | Auth, token, step-by-step publish |
| `.github/workflows/publish-npm-wrapper.yml` | OIDC publish |
| `.github/workflows/ci.yml` | Cross-OS gates |
| `.github/workflows/nightly-registry-health.yml` | Live registry smoke |
| `npm-wrapper/scripts/smoke.mjs` | Post-publish / nightly verifier |
| `CONTRIBUTING.md` | Version sync rule for contributors |
