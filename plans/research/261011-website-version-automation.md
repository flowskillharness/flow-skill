# Research & Design: Website Version Automation

## 1. Problem Statement & Goals
- **Incident**: The live site (`flowskill.io.vn`) serves stale release data: footer displays `skill 0.30.0 · npm installer 0.7.0` while npm latest is `0.7.3` and master skill is `0.33.0`.
- **Root cause**: Release metadata is hardcoded. Prior bumps required manual commits across 11 files (e.g. commit `c075927` bumping `@next` to `0.7.1-next.0`). When manual edits stopped, the site froze.
- **Goals**: Zero manual website edits for version bumps. Website code is committed exclusively for real content (docs, UI, copywriting). Automated rebuilds reflect npm and skill releases immediately.

## 2. Evidence
- **Stack**: Astro 7 (`astro ^7.1.6`), `@astrojs/starlight ^0.41.7`, Node 22, SSG (`astro build` -> `dist/`).
- **Hardcoded Locations**:
  - `website/src/pages/index.astro:5`: `const command = 'npx @manhquy/flow-skill@next';`
  - `website/src/pages/index.astro:33`: `content="... npx @manhquy/flow-skill@next. ..."` (mirrored in `src/pages/vi/index.astro:5,33`).
  - `website/src/components/InstallLockup.astro:17`: `<code class="cmd" translate="no" data-command>{command}</code>` (binds static prop).
  - `website/src/components/Colophon.astro:27-42,50`: `repoText('skills/flow/SKILL.md')` and `repoText('npm-wrapper/package.json')` read local disk via `readFileSync`. On isolated branch checkouts (`feat/flow-website`) or when parent trees are missing/stale, reads fail or return frozen metadata.
  - `website/src/layouts/Landing.astro:35`: HTML design note references `npx @manhquy/flow-skill@latest`.
- **Deploy Target Findings**:
  - `.github/workflows/website.yml:18-19`: States Cloudflare Pages Git integration owns previews/production (`# No deploy job — Cloudflare Pages Git integration owns preview/production`).
  - `website/README.md:25-34,69`: Notes Cloudflare Pages project `flow-website` connects to `master` with root `website` and watch paths `website/**`. Skill-only or npm-wrapper commits intentionally skip site builds, preventing version refreshes.

## 3. Options Comparison & Chosen Architecture

| Option | Freshness | Effort | Failure Modes | Maintenance |
|---|---|---|---|---|
| **A. Build-time registry fetch** | Per build | Low | Registry down breaks build | Low |
| **B. A + Actions cron (daily)** | ≤24h | Low | Failed cron delays sync | Minimal |
| **C. B + repository_dispatch** | Seconds | Med | Dispatch auth/payload error | Low |
| **D. Client/edge runtime fetch** | Real-time | High | CLS shift, no-JS failure, CORS | High (Rejected) |
| **E. Committed version-cache** | Static fallback | Low | Stale if offline long-term | Minimal |

- **Rejection of D**: Client-side fetch causes layout shifts (CLS), breaks without JavaScript, risks npm registry CORS/rate-limiting, and violates the deterministic static proof-sheet aesthetic.
- **Skill Version Sourcing Decision**: Fetch raw `SKILL.md` from `raw.githubusercontent.com` at build time.
  - *Justification*: `skills/flow/SKILL.md` frontmatter (`metadata.version`) is the canonical source of truth for the skill product version (`0.33.0`). The npm package description in `npm-wrapper/package.json` does not contain the skill version; parsing registry tarballs or scraping descriptions is brittle.
- **Chosen Architecture: Layered A + B + C + E**:
  - Registry & GitHub master are live sources of truth (A).
  - Main-repo release workflow triggers instant rebuilds via `repository_dispatch` (C).
  - Daily cron provides an automated safety net for dropped events or out-of-band publishes (B).
  - Committed `src/data/version-cache.json` guarantees offline and outage resilience (E).

## 4. Implementation Spec for `feat/flow-website`

### `src/lib/versions.ts`
```typescript
import fallback from '../data/version-cache.json';

export interface VersionInfo {
  installerVersion: string;
  skillVersion: string;
  command: string;
}

let memoized: Promise<VersionInfo> | null = null;

export function getVersions(): Promise<VersionInfo> {
  if (memoized) return memoized;
  memoized = (async () => {
    let installerVersion = fallback.installerVersion;
    let skillVersion = fallback.skillVersion;
    try {
      const res = await fetch('https://registry.npmjs.org/@manhquy/flow-skill/latest', {
        signal: AbortSignal.timeout(5000),
      });
      if (res.ok) {
        const pkg = (await res.json()) as { version?: string };
        if (pkg.version) installerVersion = pkg.version;
      }
    } catch {}
    try {
      const res = await fetch(
        'https://raw.githubusercontent.com/manhquydev/flow-skill/master/skills/flow/SKILL.md',
        { signal: AbortSignal.timeout(5000) }
      );
      if (res.ok) {
        const text = await res.text();
        const match = text.match(/^\s{2}version:\s*"([^"]+)"/m);
        if (match?.[1]) skillVersion = match[1];
      }
    } catch {}
    return {
      installerVersion,
      skillVersion,
      command: 'npx @manhquy/flow-skill@latest',
    };
  })();
  return memoized;
}
```

### Component Consumption Diff Sketch
```astro
// website/src/pages/index.astro & website/src/pages/vi/index.astro
+ import { getVersions } from '../lib/versions';
- const command = 'npx @manhquy/flow-skill@next';
+ const { command } = await getVersions();

// website/src/components/Colophon.astro
+ import { getVersions } from '../lib/versions';
- const skill = skillVersion();
- const installer = installerVersion();
+ const { skillVersion: skill, installerVersion: installer } = await getVersions();
```

### `.github/workflows/website-scheduled-rebuild.yml`
```yaml
name: Website Scheduled & Dispatch Rebuild
on:
  schedule:
    - cron: '0 6 * * *'
  repository_dispatch:
    types: [npm-published]
  workflow_dispatch:
jobs:
  rebuild:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: website/.node-version
      - name: Build
        working-directory: website
        run: npm ci && npm run build
      - name: Deploy
        # TODO: Trigger Cloudflare Pages deploy hook or wrangler pages deploy
        run: echo "Deploy hook triggered (see open questions)"
```

### Addition to `.github/workflows/publish-npm-wrapper.yml` (on master)
```yaml
      - name: Trigger website rebuild
        if: steps.meta.outputs.dry_run == 'false'
        run: |
          gh api repos/${{ github.repository }}/dispatches \
            -f event_type=npm-published
        env:
          GITHUB_TOKEN: ${{ secrets.WEBSITE_DISPATCH_TOKEN || github.token }}
```

## 5. Rollout Checklist (`feat/flow-website`)
1. **Immediate Hotfix**: Commit `website/src/data/version-cache.json` with `{ "installerVersion": "0.7.3", "skillVersion": "0.33.0" }`. Immediately resolves the 0.7.0 incident. (Acceptance: build outputs 0.7.3).
2. **Add Module**: Commit `website/src/lib/versions.ts`. (Acceptance: type checks cleanly in Astro 7).
3. **Refactor Landing & Colophon**: Consume `getVersions()` in `index.astro`, `vi/index.astro`, and `Colophon.astro`. (Acceptance: `npm run build` succeeds; dist HTML reflects 0.7.3 and 0.33.0).
4. **Add Rebuild Workflow**: Commit `.github/workflows/website-scheduled-rebuild.yml`. (Acceptance: manual `workflow_dispatch` run succeeds).
5. **Add Release Dispatch**: Add dispatch step to `.github/workflows/publish-npm-wrapper.yml` on `master`. (Acceptance: next npm release triggers rebuild).

## 6. Risks, Failure Modes & Open Questions
- **Registry / GitHub Outages**: Network aborts after 5s; builds safely fall back to `version-cache.json` without failing.
- **Build Minute Consumption**: Daily cron runs ~1 min/day (~30 min/month), negligible against GitHub free tier (2,000 min).
- **Raw GitHub CDN Caching**: `raw.githubusercontent.com` caches responses for ~300s (5 min). Instant dispatch builds within 5 min of push may fetch the previous version if not delayed by ~60s or cache-busted with a query param.
- **Open Questions**:
  1. *Deploy Method*: Cloudflare Pages uses Git integration with `website/**` watch path. Automatic builds require either a Cloudflare Deploy Hook URL invoked via curl in GHA, or switching to Direct Upload / Wrangler in CI.
  2. *Dispatch Auth*: Default `github.token` cannot trigger downstream workflows in some repository configurations; a fine-grained PAT or repo secret (`WEBSITE_DISPATCH_TOKEN`) may be required.

## 7. Sources
- [Astro Data Fetching](https://docs.astro.build/en/guides/data-fetching/)
- [npm Registry API Specs](https://github.com/npm/registry/blob/master/docs/REGISTRY-API.md)
- [GitHub Actions repository_dispatch Event](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#repository_dispatch)
- `raw.githubusercontent.com` Fastly CDN 300s TTL *(knowledge-based)*
- Cloudflare Pages Build Watch Paths & Deploy Hooks *(knowledge-based)*
