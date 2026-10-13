# Release Preparation Report — Wave 2 (2026-10-13)

**Status:** Release preparation complete. Version decisions finalized. CI updated for Windows PowerShell verification. External GitHub approval gate audited. Publication held pending native commit and version bump.

---

## 1. Remote GitHub Auth & Environment Audit (Read-Only)

- **GitHub Identity:** Logged in as `manhquydev` (token scopes: `gist`, `read:org`, `repo`, `workflow`).
- **Repository:** `manhquydev/flow-skill` (public).
- **Default Branch:** `master`. Branch protection: `HTTP 404: Branch not protected`. Direct push to `master` is accessible without bypass.
- **Publishing Environment Gate:**
  - Environment `npm-publish` is configured in `repos/manhquydev/flow-skill/environments`.
  - Protection rules: `required_reviewers` enabled with reviewer `manhquydev`.
  - `can_admins_bypass: true`, but GitHub Actions publish jobs (`publish-npm-wrapper.yml`) pause at the environment gate awaiting manual approval in the Actions UI before OIDC minting and `npm publish --provenance` can execute.
  - **External Blocker Identified:** Publishing to the npm registry cannot be completed headlessly without human approval at the GitHub Environment `npm-publish` gate. This gate is documented and respected; no attempt to bypass it will be made.

---

## 2. CI Workflow Hardening (.github/workflows/ci.yml)

- **Commit:** `ec5ad615a58f17bab280941b05b0225a63d445c3`
- **Enhancement:** Added native PowerShell verification step to the `bash-suite` matrix job on `windows-latest`:
  ```yaml
  - name: Run PowerShell installer suite (Windows only)
    if: matrix.os == 'windows-latest'
    run: |
      if (Test-Path tests/test_install_safe_update.ps1) {
        pwsh tests/test_install_safe_update.ps1
      } elseif (Test-Path install.ps1) {
        Write-Host "Running install.ps1 smoke check..."
        $scratch = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "flow-ps1-smoke-$([System.Guid]::NewGuid())")
        try {
          $env:USERPROFILE = $scratch.FullName
          pwsh install.ps1 global claude
          if (-not (Test-Path (Join-Path $scratch.FullName '.claude\skills\flow\SKILL.md'))) {
            throw "install.ps1 failed to install SKILL.md"
          }
        } finally {
          Remove-Item -Recurse -Force $scratch.FullName -ErrorAction SilentlyContinue
        }
      }
    shell: pwsh
  ```
- **Integrity:** `python3 -c "import yaml; yaml.safe_load(...)"` verified syntax OK.

---

## 3. Version Decision & Rationale (Two Axes, Boring Patch Semantics)

Per `docs/release-process.md` and repository semver standards:

1. **Skill Product Version:** `0.34.0` → **`0.34.1` (patch)**
   - **Declared in:** `skills/flow/SKILL.md` (`metadata.version`), `.claude-plugin/plugin.json`, `portable-manifest.json`.
   - **Rationale:** The Flow runner, card models, gate transitions, and harness durable layer remain 100% backwards-compatible. Changes in Wave 1 and Wave 2 (Doctor named registry, whole-tree integrity receipt, host-context adapter hooks under ADR-0001, transactional installer helper) are additive hardening. A patch bump provides boring, stable release semantics without breaking changes.
2. **npm Installer Version:** `0.7.7` → **`0.7.8` (patch)**
   - **Declared in:** `npm-wrapper/package.json`, `npm-wrapper/package-lock.json`.
   - **Rationale:** The installer CLI interface is strictly backwards-compatible. All existing options (`--yes`, `-t`, `--all`, `--project`, `--dir`, `--json`, `--dry-run`, `--help`) retain identical behavior and return codes. The addition of `--target omp` is additive. The internal engine upgrade from destructive pre-deletion to transactional ownership staging + atomic swap preserves user files. In pre-1.0 semver, patch bump avoids unnecessary downstream churn.
3. **Tags Planned:**
   - `npm@0.7.8` (triggers `publish-npm-wrapper.yml` for npm release with dist-tag `latest`).
   - `v0.34.1` (skill product release tag / GitHub Release).

---

## 4. Current Verification Summary

| Suite / Verification | Metrics | Status |
|---|---|---|
| `npm-wrapper` test suite (`node --test`) | **65 passed, 0 failed** | **PASS** |
| Native shell installer suite (`tests/test_install_safe_update.sh`) | **42 passed, 0 failed** | **PASS** |
| Manifest runner suite (`tests/test_manifest_runner.sh`) | **12 passed, 0 failed** | **PASS** |
| Doc budgets (`scripts/check-doc-budgets.sh`) | **5/5 files within budget** | **PASS** |
| Release coherence (`scripts/check-release-coherence.sh`) | All checks clean | **PASS** |
| Pack rehearsal (`scripts/pack-rehearsal.sh`) | **22 passed, 0 failed** | **PASS** |

---

## 5. Next Steps to Publish

1. Native workstream (`agentkit-native-install`) commits native files (`install.sh`, `install.ps1`, `skills/flow/runner/installer_helper.py`, `tests/test_install_safe_update.sh`, `tests/manifest.txt`).
2. Release owner bumps version mirrors in lockstep (`0.34.1` / `0.7.8`) and commits `chore(release): v0.34.1 / npm@0.7.8`.
3. Push `master` to origin.
4. Create and push tags: `git tag npm@0.7.8 && git tag v0.34.1 && git push origin npm@0.7.8 v0.34.1`.
5. GitHub Actions triggers `publish-npm-wrapper.yml`; workflow pauses at environment `npm-publish` for reviewer sign-off.
6. Create GitHub Release `v0.34.1` with release notes.
