# OMP Target Analysis — npm installer explicit + autodetect (wave 2 pre-plan)

Date: 2026-10-13. Analysis phase complete; **implementation of my owned slice landed same session
(director GO)**: `src/constants.mjs` (omp entry), `bin/cli.mjs` (RESTART_HINTS.omp),
`test/detect.test.mjs` (bare/genuine boundary), `test/cli.test.mjs` (help wording test deleted;
`--all` exact set updated to include omp; explicit `-t omp` plan; `--project -t omp` exit 2;
real scratch-HOME install with node:crypto receipt-vs-bundled-source-and-install hash check),
`scripts/smoke.mjs` (explicit omp install + receipt self-check + bare/genuine detection boundary,
all in scratch HOMEs), `README.md`/`README_VN.md` (target table + uninstall pointers, EN/VI
matched), `CHANGELOG.md` (Unreleased omp entry only — safeupdate entry section left for source
owner). `CLEANUP_SUBDIRS`/`adapter-hooks` NOT touched (source-owned after transactional rework).
Verification: detect+cli 23/23, full wrapper `npm test` 49/49, live CLI `-t omp` dry-run plan,
real temp-HOME install (materialized, frontmatter `name: flow` read back, `doctor_helper.py
verify-receipt` → `OK:126`, restart hint observed once as throwaway check), pack rehearsal
22/22 + installed-artifact doctor integrity ok. Shell/PS1 + installer transactional safe-update:
source owner's slice, pending; final combined smoke-package pass deferred until both slices
land. New wave uncommitted (per steering: commit only after source transaction merged + review).

## 1. Live host evidence (read-only probes, 2026-10-13)

- `~/.omp/agent/skills/` **exists** and is the genuine skills dir on this host: contains the
  installed ak kit skills (149 per `plans/research/agentkit-engineer-installed/REPORT.md` §1.3;
  spot-checked `ak-ab-test-setup`, `ak-ads-management`, … present on disk).
- `~/.omp/skills/` does **NOT exist** on this host (probed: no such dir).
- `~/.omp` itself exists (runtime data: `agent/`, `cache/`, `logs/`, `autoqa.db`, …) — a bare
  `~/.omp` marker would true-positive on every OMP runtime user regardless of skills support,
  exactly the false-positive class the red-team C1 Cursor guard and the bare-`~/.gemini`
  Antigravity guard already reject in `constants.mjs`.
- Research-doc variance, resolved: ak public docs research (`docs-research.md` §runtime-adapters)
  describes adapter projections to `.omp/skills/ak-<slug>` — a **distribution/adapter
  convention**; the actual installed runtime on this machine projects kit skills to
  `~/.omp/agent/skills` (component-analysis.json `runtime_status` ×N, live `ls`). G7 in
  `flow-gap-map.md` already resolves to `~/.omp/agent/skills/flow`. **Decision: marker and dest
  use `.omp/agent/skills`; no bare-`.omp` marker; no `~/.omp/skills` dest.**
- Package-level corroboration that nothing exists today: grep of `npm-wrapper/src` + `bin` finds
  no OMP support; `TARGETS` in `constants.mjs` lists exactly claude/codex/agents/antigravity/cursor.

## 2. Current target behavior (inspected, not modified)

### `src/constants.mjs`
- `TARGETS[]` drives everything: `name`, `label`, `markers[]` (relative to home),
  `destTemplates[]` (`~/…`), `alwaysInclude`, `projectScopeAllowed`. Adding an entry is the
  single source-of-truth edit; detect/help/prompt/plan all derive from it.
- `TARGET_NAMES` derived; `CLEANUP_SUBDIRS` target-agnostic; `PKG_VERSION`/`SKILL_VERSION`
  unaffected.
- Precedent guards embedded in entries: antigravity (never stat bare `~/.gemini`), cursor
  (red-team C1: marker must be the skills subdir). OMP entry must carry the same discipline:
  marker `.omp/agent/skills`.

### `src/detect.mjs`
- `detectAll({home})` stats each marker under the given home; `defaultSelection` =
  `alwaysInclude || detected`. OMP: `alwaysInclude: false` (never auto-install on bare runtime
  presence unless the genuine skills dir exists — marker already encodes this),
  `projectScopeAllowed: false`. Marker/dest resolution is `~/`-template-aware and separator-safe
  (Windows mixed-separator guard) — nothing OMP-specific needed here; the entry just flows
  through.

### `src/help.mjs`
- Fully derived from `TARGETS` (`targetRows`, `targetCount`) — no hardcoded count. Notes section
  says "--project supports only \"claude\"" — stays true and must stay worded as-is (we are NOT
  broadening project scope). One candidate line to add: OMP restart/hint note if needed.

### `bin/cli.mjs` (bin name `flow-skill` — only spelling used anywhere; package `bin` field → `bin/cli.mjs`)
- `parseCliArgs`: `-t/--target` repeatable + comma-form → `validateTargetNames` against
  `TARGET_NAMES`, unknown → exit 2. OMP spelled `omp` will validate once in `TARGETS`.
- **Explicit target already bypasses detection**: `selectNonInteractive` uses explicit `-t`
  verbatim; installer `install_to`/`install()` does `mkdir -p` dest. So explicit `--target omp`
  succeeds even when `~/.omp/agent/skills` doesn't exist — matches existing claude (created if
  missing) and codex-explicit behavior. No special-casing needed.
- Project scope: `enforceProjectScope` keeps only `projectScopeAllowed` targets; with
  `projectScopeAllowed: false`, `-t omp --project` → exit 2 with the existing claude-only error.
  Desired.
- `RESTART_HINTS` map: add an `omp` hint line (e.g. "OMP: restart/reload the runtime to load the
  new skill, then invoke flow"); `doneLine` filters — absent key would just print nothing, but
  per-target hints are the v0.23 A0 contract, so add one.
- `buildPlan` project branch hardcodes `.claude` — untouched (omp is not project-allowed).

### Shell / PS1 (`install.sh`, `install.ps1`) — **SOURCE OWNER SOLE EDITOR (entire files)**
- Current behavior (inspected 2026-10-13): `global` installs claude always + codex/agents
  conditionally (`-d ~/.codex/skills`) + antigravity (`-d ~/.gemini`); explicit
  `global <target>` installs unconditionally via `install_to` (`mkdir -p`); `project [dir]` →
  `.claude` only; `done_line`/`$RestartHints` per-target hints; `usage()` spelling.
- Per director steering: the **source owner edits these two files in full** (OMP branch, reload
  hint, usage, plus their transactional safe-update rework of `install_to()` in the shell
  scripts AND `src/installer.mjs` + installer tests). I make **no edits** to `install.sh`,
  `install.ps1`, `src/installer.mjs`, or installer tests — zero concurrent-edit overlap. My
  npm-side explicit `--target omp` is independent of shell behavior.
- Note recorded for the source owner: install.sh antigravity autodetect keys on bare
  `~/.gemini` (looser than npm constants); OMP condition there should be `~/.omp/agent/skills`
  (the tight marker), not the bare-dir pattern.

### Preserve model / test ownership
- Preserve model stays: rm only the 6 owned `CLEANUP_SUBDIRS`, merge-copy, user files outside
  owned subdirs preserved (`installer.mjs` core install; parity `install.sh:24-27`). OMP target
  inherits this unchanged — no new write semantics from my side.
- I do **not** echo or duplicate the source owner's installer/transactional tests; my scope is
  the npm target tests only (`detect.test.mjs`, `cli.test.mjs`, smoke omp pass).

## 4. Baseline runtime probes (current CLI, temp HOME only — no code changed, no real-HOME install)

- `HOME=<temp> node npm-wrapper/bin/cli.mjs --yes -t omp --dry-run --json` →
  `{"event":"error","message":"unknown target(s): omp. Valid: claude, codex, agents, antigravity, cursor","exitCode":2}`, exit 2.
  Confirms current absence and the exact contract my change must turn into a plan event.
- `HOME=<temp> node npm-wrapper/bin/cli.mjs --yes -t claude --dry-run --json` →
  plan event `targets:["claude"]`, exit 0. Confirms the temp-HOME explicit-target probe harness
  works; the post-implementation `-t omp` dry-run + real install + materialization check will
  reuse this scratch-HOME pattern (never the user's real `~/.omp`).

## 5. Discoverability evidence (frontmatter, read-only)

- Bundled `skills/flow/SKILL.md` frontmatter: `name: flow`, `description`, `user-invocable: true`,
  `when_to_use`, `argument-hint`, `keywords`, `license: MIT` — same frontmatter shape as live
  OMP-installed kit skills (spot-check `~/.omp/agent/skills/ak-bro/SKILL.md`:
  `name: ak-bro`, `description`, `user-invocable`, `when_to_use`, `category`).
- Therefore OMP discovery needs no SKILL.md edit: installing the bundle to
  `~/.omp/agent/skills/flow` yields a top-level `name: flow` skill, the same discovery surface
  the 149 kit skills already use. Post-install verification step (after go): read the installed
  copy's frontmatter at the temp dest and assert `name: flow` + description present.

## 6. Ownership split (director-revised 2026-10-13)

- Mine: `src/constants.mjs`, `src/detect.mjs`, `src/help.mjs`, `bin/cli.mjs` (target spelling
  only), `test/detect.test.mjs`, `test/cli.test.mjs`, `scripts/smoke.mjs` (omp pass),
  affected-test reruns + temp-CLI run; README install-frontdoor docs **only after go**.
- Source owner (wave-2 plan pending): **entire** `install.sh` + `install.ps1` (OMP branch,
  reload hint, usage) and the transactional safe-update slice in `src/installer.mjs` +
  installer tests. I do not edit those files concurrently or at all.
- Director: says go; no new workers spawned. No release/version bump/push; old-wave commits are
  the clean base (master `557d19f`), full-suite status unchanged (66-suite unverified).

### Tests / smoke (current behavior baseline)
- `test/cli.test.mjs`: hardcodes "5 targets" twice (`--help lists 5 targets`,
  `--all --json plan … 5 targets` sorted `['agents','antigravity','claude','codex','cursor']`)
  → must become 6 with `omp` added (mechanical, target-spelling only).
- `test/detect.test.mjs`: per-target detection cases incl. the bare-dir negative tests
  (`.gemini`, `.cursor`) → add: bare `~/.omp` does NOT detect omp; `~/.omp/agent/skills` present
  DOES detect omp with dest `~/.omp/agent/skills/flow`; dest resolved against given home.
- `test/cli.test.mjs` real-install tests use scratch HOME (`fakeHome`) — the OMP real-install
  test must also use a scratch HOME; **no real `~/.omp` install/activation**.
- `scripts/smoke.mjs` installs `-t claude` into scratch HOME and asserts 6 subdirs — extend with
  a `-t omp` pass into the same scratch HOME (temp isolated; asserts same materialization).
- `npm test` = 5 suites, `--test-concurrency=1`, `pretest` runs `sync.mjs`. Current 45 pass;
  new/updated assertions are the only count change expected; no old unchanged suite re-runs
  beyond what `npm test` necessarily executes as its normal unit (affected-file tests only
  where the runner allows file selection).

## 3. Proposed design (for wave-2 plan acceptance — not implemented)

1. `constants.mjs`: append target after `cursor`:
   `{ name: 'omp', label: 'OMP (~/.omp/agent/skills)', markers: ['.omp/agent/skills'],
      destTemplates: ['~/.omp/agent/skills/flow'], alwaysInclude: false,
      projectScopeAllowed: false }` with a red-team-style comment citing the live probe and the
   bare-`~/.omp` guard rationale.
2. `help.mjs`: no count edit needed (derived); optionally one OMP note line; help test count
   update only.
3. `cli.mjs`: add `RESTART_HINTS.omp`; nothing else — explicit-target/project-scope/unknown
   handling already generic.
4. `detect.mjs`: zero changes (entry-driven).
5. Tests: detect (3 new cases), cli (2 count updates + `--dry-run -t omp --json` plan contains
   omp + `-t omp --project` exit 2 + scratch-HOME real install Done-line hint), smoke (`-t omp`
   scratch-HOME pass). Affected-only reruns + smoke; no full-suite rerun of unchanged suites.
6. Non-goals: no project-scope OMP; no `~/.omp/skills` dest; no bare-`.omp` marker; no rules/
   agents projection (G7 defers); no release/version bump/push; no real-HOME install.

## 4. Ownership split

- Mine: `src/constants.mjs`, `src/detect.mjs`, `src/help.mjs`, `bin/cli.mjs` (target spelling
  only), `test/detect.test.mjs`, `test/cli.test.mjs`, `scripts/smoke.mjs` (omp pass), test-count
  updates.
- Source owner (wave-2 plan pending): installer safe-update/snapshot design; `install.sh` /
  `install.ps1` OMP branches only if not absorbed into their shared slice — coordinate before
  either of us edits.
- Director: says go; no new workers spawned.
