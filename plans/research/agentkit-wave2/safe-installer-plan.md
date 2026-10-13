# Wave 2 Architecture & Implementation Plan: Boring, Reliable Transactional Installer with Safe Ownership & OMP Parity

**Plan File Path:** `plans/research/agentkit-wave2/safe-installer-plan.md`  
**Date:** 2026-10-13 (v3 — director-corrected)  
**Status:** Implementation in progress; acceptance pending. Sections below are the proposed design and the verification that is REQUIRED — they become "as-built/as-executed" only when the production code, tests, and real integration runs listed in §5 have actually landed and passed. Progress ledger at the bottom of §5.  

---

## 1. Core Principles & Non-Goals (v2, binding)

1. **Zero Destructive Pre-Deletion:** the old `rm -rf`-subdirs-then-copy pattern is removed repo-wide (clean cutover: `CLEANUP_SUBDIRS`, `cleanupSubdirs` params and all callers deleted — the constant is NOT extended with `adapter-hooks`; ownership governs freshness now).
2. **Strict Conflict Refusal (no silent overwrite, no `--force`, no fallback bypass):**
   - A dest file that the **old receipt owns** and that the **new source still ships**, but whose bytes differ from the old receipt digest (user edited an owned file) → **abort before touching the original dest**; list every conflicted path.
   - An old-receipt path that is **missing from the dest** → the receipt does not describe this tree (root mismatch) → refuse loud.
   - No old receipt at all and dest exists (legacy/dev install): any new-source path colliding with a dest file of **differing bytes** → refuse loud; identical bytes → fine (idempotent).
3. **Preservation of user files everywhere in the dest:** files not owned by the old receipt — including inside previously-managed subdirs — are carried into the candidate and reported. A **retired** old-owned file (absent from new source) that still matches its old digest is pruned; one whose bytes differ (user-modified) is **preserved** into the candidate and reported, never silently deleted (cleanup never removes sole old bytes).
4. **Ownership = all source files except the receipt itself.** Source receipt policy (director-authorized choice): an **authored source checkout without a receipt is acceptable** — the engine then builds its ownership manifest by hashing the read-only source bytes (no fixture bypass; real trees only). A source receipt that EXISTS must be strictly valid (schema_version 1, canonical paths, 64-hex digests, duplicate-key rejection) and its digests re-verified against actual source bytes; invalid → reject loud. The installed candidate always receives a **freshly generated** `manifest-hashes.json` computed from the staged bytes, so doctor integrity never flags preserved user customs and the receipt always describes the installed tree exactly. An **installed dest without a receipt is NOT given this allowance** — legacy dests go through the collision guard (principle 2).
5. **Transactional swap with rename-only backup:** stage candidate in a private random `mkdtemp` dir **in the dest's parent** (same-filesystem rename; never `Date.now`-predictable names); existing dest → `renameSync` to a random sibling backup slot; candidate → `renameSync` to dest; verify promoted receipt; only then remove backup. Promotion failure → rename backup back; **if rollback itself fails, the backup is kept and its recovery path reported**. Return-failure guarantee only: no crash/`SIGKILL`-survival promise is made.
6. **Per-destination transactions:** Antigravity's two destinations each carry their own receipt/backup; if the second fails after the first succeeded, results say exactly that — never a multi-dest global-atomic claim.
7. **Cross-channel parity:**
   - **Node (`installer.mjs`):** built-ins only; fault-injection seam limited to an injectable `rename` (used solely by failure tests).
   - **Shell (`install.sh`):** **fresh installs are also staged+promoted** (pure POSIX `mktemp -d` + `mv` — never bare `mkdir`+`cp` that can leave partials), and are Node/Python-free. Python 3 is an OPTIONAL runtime for flow, not a requirement; when it happens to be present, the fresh path additionally writes the ownership receipt via the helper (`gen-receipt` from the staged bytes). Without Python the fresh install completes **without a receipt** and prints an explicit advisory that future in-place updates may refuse unknown collisions. **Updating an existing dest uses the Python 3 stdlib helper performing the full transaction in one process** (single walk — no separate preflight/build passes, no path-race window); Python absent → loud refusal, dest untouched. Nothing new is required for fresh installs; the update path relies on an already-optional tool.
   - **PowerShell (`install.ps1`):** native implementation — receipt JSON via the .NET `System.Text.Json` parser with an explicit per-object duplicate-property walk (a repeated property name at any object level refuses the receipt; the parser's last-wins behavior is never relied on), `Get-FileHash` (SHA-256), stage copy + `Rename-Item` swap — no new dependency and no Python duplication. If `System.Text.Json` is unavailable in the host's .NET, the update refuses loudly (never a silent lenient parse). Disclosure: this host has no `pwsh`, so the PS path is implemented per this spec but **not executed here**; no untested-equivalence security claim is made for it.
8. **OMP target parity:** `omp` target in all channels, marker/dest `.omp/agent/skills` (bare `~/.omp` never triggers). Label stays plain `OMP` — no unverified product expansion.

## 2. Bounded Tool Probing (`je`)

* Probed across host `$PATH` (`/home/manhquy/.local/bin`, `/usr/local/bin`, `/usr/bin`): returned `je not found`.
* Checked global npm catalog (`npm list -g je`) and Python runtime (`import je`): not found / uninstalled.
* **Resolution:** defined limitation: `je` is not installed on this host. Not-found is sufficient state; no session-history mining, IME speculation, or alias guessing. Proceed using Flow's native toolset.

## 3. File Ownership (v2 — sole implementer)

| Component | Owner |
|---|---|
| `npm-wrapper/src/installer.mjs`, `npm-wrapper/src/constants.mjs`, `npm-wrapper/bin/cli.mjs`, `npm-wrapper/src/detect.mjs`, `npm-wrapper/src/help.mjs` | wave-2 implementer |
| `npm-wrapper/test/installer.test.mjs`, `test/cli.test.mjs`, `test/detect.test.mjs`, `scripts/smoke.mjs` | wave-2 implementer |
| `skills/flow/runner/installer_helper.py` (shipped; enables future updates of installed trees) | wave-2 implementer |
| `install.sh`, `install.ps1` | wave-2 implementer (source instructed no edits; source draft §3 superseded) |
| Docs: `SECURITY.md`, `docs/system-architecture.md`, root + wrapper `CHANGELOG.md`, `plans/research/agentkit-flow-upgrade/candidates.md` correction | wave-2 implementer |

## 4. Technical Implementation (v2 — as built)

### 4.1 Node engine (`npm-wrapper/src/installer.mjs`)
1. Input separation: resolved source/dest must be disjoint (neither contains the other, not equal); dest path ancestors and dest itself must not be symlinks.
2. Source: `SKILL.md` present; `assertNoSymlinks`; strict receipt parse; every receipted digest re-verified against actual source bytes.
3. Dest survey (read-only): old receipt strict-parsed or absent; conflicts/missing-root/collisions collected → single loud abort before mutation.
4. Candidate: private random `mkdtemp` stage in dest parent; copy receipted source files (dirs 0755, files 0644); carry preserved customs + retired-modified bytes from the old dest; prune retired-unmodified; **generate fresh receipt from staged bytes**; `chmod +x runner/flow.sh`.
5. Swap: optional injectable `rename` seam → backup rename → promote rename → verify promoted receipt → remove backup (non-fatal warning if removal fails, path reported). Restore-failure keeps backup and reports the recovery path.
6. Advisory lock per destination (`acquireLock`) unchanged; results report `preserved` / `retiredRemoved` / `retiredPreserved` / `receiptGenerated`.

### 4.2 Shipped Python helper (`skills/flow/runner/installer_helper.py`, stdlib-only)
- `gen-receipt <root>` — strict walk (symlink → loud error), canonical ownership receipt on stdout (single walk).
- `upgrade <src_root> <dest_dir>` — the **entire** update transaction in one process: survey, conflict/collision/root-mismatch refusal, stage, preserve/prune, receipt generation, backup/promote/rollback, verify. Exit codes: 0 ok, 3 conflict, 4 invalid receipt, 5 collision, 6 io failure with backup retained (recovery path on stdout). No separate preflight double-walk.

### 4.3 Shell (`install.sh`) — fresh: POSIX stage+promote (`mktemp -d` in dest parent, `cp` into stage, optional `gen-receipt`, random urandom backup suffix, `mv` swap with rollback); update: delegate to `installer_helper.py upgrade` (Python absent → loud refusal preserving dest). OMP: explicit `global omp` + `all`-autodetect on `-d ~/.omp/agent/skills`, `omp` done-line hint, usage string. Antigravity second-destination failure reports the first as installed (per-dest truth).

### 4.4 PowerShell (`install.ps1`) — native full parity (fresh stage+promote with native receipt via `Get-FileHash`/`ConvertTo-Json`; update transaction with `ConvertFrom-Json` strict shape/canonical/digest validation). Duplicate-key strictness: enforced in Node and doctor (Python); PS parser quirk disclosed. Not executed on this host (no `pwsh`) — disclosed in the file header.

## 5. Verification (REQUIRED before as-built claims)

1. npm suite: installer behavior tests — fresh install, idempotent update, custom-file preservation (inside managed dirs), retired-unmodified pruned, retired-modified preserved, user-conflict abort pre-touch, legacy collision refusal, invalid/missing receipt rejection, ancestor-symlink refusal, dest-symlink refusal, injected promotion failure → rollback, injected rollback failure → backup kept + recovery path, injected quarantine failure → candidate kept at dest + both paths reported, per-dest Antigravity partial truth, no real-HOME mutation anywhere.
2. CLI roundtrips in temp HOMEs: install → update → conflict → recovery via real `bin/cli.mjs`.
3. Shell actuals: `install.sh global omp` fresh + update into temp HOMEs, with and without Python on PATH; helper `gen-receipt`/`upgrade` real runs.
4. `npm test`, `scripts/pack-rehearsal.sh`, doc budgets, manifest coherence.

### Progress ledger (2026-10-13, sole implementer)
- [x] npm engine `installer.mjs` transactional rewrite (contract §4.1 incl. quarantine-by-rename-only rule; `rmSync` at destination path forbidden and absent).
- [x] `CLEANUP_SUBDIRS`/`cleanupSubdirs` clean cutover (engine, constants, tests).
- [x] installer.test.mjs 26/26; full `npm test` 63/63 (post-OMP + transaction tests).
- [x] OMP target (constants/RESTART_HINTS/tests/README EN+VI/wrapper CHANGELOG) — earlier slice.
- [x] Real-CLI temp-HOME e2e: fresh / idempotent-update custom preserved / conflict refusal (exact `install:done` payload captured).
- [x] Docs: root + wrapper CHANGELOG Unreleased entries, `SECURITY.md` (root + wrapper), `docs/system-architecture.md` upgrade-transaction section; candidates.md C4 superseded-note.
- [x] Receipt contract + findings handed to native workstream via director (2026-10-13); `skills/flow/runner/installer_helper.py` draft in tree is native-owned (helper `rmtree(dst)` defect reported).
- [ ] Shell `install.sh` / `install.ps1` OMP + transaction parity — native workstream, PENDING.
- [ ] Final `npm run sync` + `npm test` + `scripts/pack-rehearsal.sh` re-run after native helper final form — PENDING (blocked on native).
- [ ] Cross-review of native code on return — PENDING.
- Commit: deferred until native merged + review (standing steering). No push/release/version bump.

## 6. Threat-model notes (short, honest)
- Lock path is predictable and created `wx`; an existing path is read to decide staleness — a same-uid local attacker could pre-place/symlink it. Accepted same-uid limitation (pre-existing, out of scope unless it fails bounds); no malicious-same-uid filesystem safety is claimed anywhere (Node/POSIX path ops race with concurrent same-uid writers).
- No daemon, no crash-atomicity: guarantees hold for returned failures only.
- Stale-PID lock recovery retains its existing (documented) re-entrancy semantics.

## 7. Divergences from the source draft (director-mandated)
| Source draft | Final (v2) |
|---|---|
| `CLEANUP_SUBDIRS` + `adapter-hooks` | constant deleted repo-wide (clean cutover); receipt ownership governs |
| `Date.now()` staging names | random `mkdtemp` / `urandom` suffixes only |
| backup via copy, mutation in place | full-dest **rename** backup, rename promote, verified cleanup |
| helper split `preflight-conflict` + `build-candidate` | single-process full-transaction `upgrade` (no double walk) |
| shell fresh = `mkdir -p && cp -r` | shell fresh = POSIX stage+promote; receipt via helper when Python present; advisory without |
| OMP label "Oh My Pi (OMP)" | plain `OMP` (expansion unverified) |
| conflict rule without missing-path case | missing old-receipt path = root mismatch → refuse |
