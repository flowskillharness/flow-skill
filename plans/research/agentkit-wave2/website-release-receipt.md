# Website Release Preflight & Deployment Receipt

**Date:** 2026-10-13  
**Target Platform:** Cloudflare Pages (`flow-website`)  
**Primary Domain:** https://flowskill.io.vn  
**Author / Role:** UX Researcher + Frontend Builder (Website Preflight/Deploy Ownership)  
**Status:** Preflight Complete — Awaiting Source Release Confirmation (npm @manhquy/flow-skill@0.7.8 & skill v0.34.1)

---

## 1. Scope & Governance Boundaries
- **Ownership:** Website preflight, deployment execution, live verification, and rollback readiness ONLY.
- **Independence:** Independent of source code changes, git tagging, or npm publication.
- **Master Branch Policy:** Zero edits to `website/` or root files on `master` (strict adherence to root AGENTS law).
- **Gate Discipline:** Unreleased versions are NOT deployed prematurely. npm registry and GitHub release tag must be observed before production deployment is triggered.

---

## 2. Current Live Production Baseline

Live observation conducted against `https://flowskill.io.vn` on 2026-10-13 08:06 UTC:

| Metric / Asset | Live Production Value | Evidence / Source |
|---|---|---|
| **HTTP Status (EN)** | `HTTP/2 200 OK` | `curl -sI https://flowskill.io.vn/` (`cf-ray: a49cd803bb6dfd73-SIN`) |
| **HTTP Status (VI)** | `HTTP/2 200 OK` | `curl -sI https://flowskill.io.vn/vi/` (`cf-ray: a49cd8346b8f0af4-SIN`) |
| **Colophon Skill Version** | `0.34.0` | Observed in footer colophon text (`skill 0.34.0`) |
| **Colophon Installer Version** | `0.7.7` | Observed in footer colophon text (`npm installer 0.7.7`) |
| **Hero Install Command** | `npx @manhquy/flow-skill@latest` | Observed in live DOM and copy snippet |
| **Known Successful Deploy ID (Ref)** | `56a65d0e` | `https://56a65d0e.flow-website-apg.pages.dev` (from workflow run `38265931656`; note: production alias `flowskill.io.vn` verified by live colophon versions `skill 0.34.0 · npm installer 0.7.7`) |
| **Prior Successful Deploy ID (Rollback Ref)** | `7cb5ae33` | `https://7cb5ae33.flow-website-apg.pages.dev` (from workflow run `38255549298`) |
| **Brand Logo Dark Asset** | `HTTP/2 200 OK` (`image/svg+xml`) | `https://flowskill.io.vn/brand/brand-lockup-dark.svg` |
| **Brand Logo Light Asset** | `HTTP/2 200 OK` (`image/svg+xml`) | `https://flowskill.io.vn/brand/brand-lockup-light.svg` |
| **Favicon Asset** | `HTTP/2 200 OK` (`image/svg+xml`) | `https://flowskill.io.vn/brand/icons/favicon.svg` |
| **Primary CSS Bundle** | `HTTP/2 200 OK` (`text/css`) | `https://flowskill.io.vn/_astro/500.Cc3tQmq1.css` |

---

## 3. Upstream Release Verification Gate

Verification conducted against npm public registry and GitHub repository releases:

| Verification Target | Query Command | Observed Result | Release Gate Status |
|---|---|---|---|
| **npm Registry latest** | `npm view @manhquy/flow-skill version` | `0.7.7` | **PENDING** (0.7.8 not yet published) |
| **npm Registry dist-tags** | `npm view @manhquy/flow-skill dist-tags` | `{"latest": "0.7.7", "next": "0.7.1-next.0"}` | **PENDING** |
| **GitHub Latest Release** | `gh release list --limit 1` | `flow-skill 0.7.7` (`npm@0.7.7`) | **PENDING** (`npm@0.7.8` not yet released) |
| **Upstream CI Matrix** | `gh run view 38364821630` | In progress on commit `c052b4e` | **IN PROGRESS** by `agentkit-source` |

*Policy Check:* Per mandate, unreleased versions are not faked. The website rebuild will be dispatched only after npm registry propagates `0.7.8` and the GitHub release tag is established.

---

## 4. Cloudflare Pages Deployment Infrastructure & Secret Metadata

Inspection of deployment workflow and authentication configuration:

- **Workflow File:** `.github/workflows/website-scheduled-rebuild.yml`
- **Job Name:** `rebuild`
- **Action:** `cloudflare/wrangler-action@v3`
- **Deploy Command:** `pages deploy dist --project-name=flow-website`
- **Working Directory:** `website`
- **Required Repository Secrets (Read-Only Name Audit):**
  - `CLOUDFLARE_ACCOUNT_ID` — **CONFIRMED PRESENT** (created 2026-10-11)
  - `CLOUDFLARE_API_TOKEN` — **CONFIRMED PRESENT** (created 2026-10-11)
- **Automated Trigger Chain:**
  - `publish-npm-wrapper.yml` emits repository dispatch event `event_type=npm-published` upon successful publication.
  - `website-scheduled-rebuild.yml` handles `repository_dispatch: types: [npm-published]` automatically.
  - In addition, manual `workflow_dispatch` is available for immediate trigger.

---

## 5. Execution Procedure (Armed for Release Confirmation)

When release confirmation is signaled (npm `0.7.8` visible on registry + GitHub release tag `npm@0.7.8` / `v0.34.1`):

### Step 1: Verification of Registry Availability
```bash
npm view @manhquy/flow-skill@latest version
# Expect: 0.7.8
```

### Step 2: Trigger GitHub Workflow Dispatch
```bash
gh workflow run website-scheduled-rebuild.yml --ref master
```

### Step 3: Monitor Workflow Run to Completion
```bash
gh run list --workflow=website-scheduled-rebuild.yml --limit 1
gh run watch <run-id>
```

### Step 4: Live Verification Protocol
1. **Live Header & HTML Check:**
   ```bash
   curl -sI https://flowskill.io.vn/
   curl -sI https://flowskill.io.vn/vi/
   ```
2. **Colophon Version Verification:**
   ```bash
   curl -s https://flowskill.io.vn/ | grep -oE "skill [0-9.]+ · npm installer [0-9.]+"
   # Expected: skill 0.34.1 · npm installer 0.7.8
   ```
3. **Asset & Layout Integrity:**
   - Verify 200 OK on brand logos and favicon.
   - Verify new Cloudflare deployment URL (`https://<new-deploy-id>.flow-website-apg.pages.dev`).
4. **Rollback Readiness:**
   If any discrepancy occurs, previous deployment `56a65d0e` remains intact and immediately accessible.
