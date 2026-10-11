# Security Policy

## Reporting a vulnerability

Please do **not** open a public GitHub issue for a security vulnerability.

Instead, either:

- use [GitHub's private security advisory](https://github.com/manhquydev/mq_flow/security/advisories/new), or
- email `manhquy.mqy@gmail.com` with a description, reproduction steps, and impact.

This is a solo-maintained project — no fixed SLA is promised, but reports are read and
acknowledged as soon as possible. Once a fix is available, a new release and an advisory
will be published; credit is given to the reporter unless anonymity is requested.

## Supported versions

Only the latest released version on `master` is supported.

## Attack surface

Flow is a discipline layer: mechanically, it is pure bash (`skills/flow/runner/flow.sh`)
invoked explicitly by the hosting agent or the operator. There is no daemon, no resident
process, and no automatic lifecycle hooks — flow runs because a host invoked it and
terminates when that invocation returns (ADR-0001). Its telemetry is local-only JSONL
under the project's `.flow/` directory and device-global `~/.claude/flow/`; it is never
transmitted anywhere.

## What flow deliberately refuses

Hooks-based policy gates and background watchers are rejected **by design**, not deferred.
The 2026 hook-escape class — configuration-based sandbox escape via hooks that execute
without extra permission or user notification, and skill-lifecycle C2 weaponizing a
benign-looking skill — is exactly the attack surface flow refuses to carry. Reopening
this requires a formal ADR: see `docs/adr/0001-discipline-layer-identity.md`.

## Integrity model (receipt = drift detection, NOT authenticity)

At prepack, `npm-wrapper/scripts/sync.mjs` writes `skills/flow/manifest-hashes.json`
containing the SHA256 of the runner. `flow doctor` compares the installed runner bytes
against that receipt and fails loudly on drift ("the harness may have been modified
mid-project").

Limits: an attacker who rewrites both the runner **and** the receipt together is
invisible to `doctor`. The receipt is drift detection only — package **authenticity**
remains the job of npm provenance and the registry.

Older installs without the receipt print an informational skip line.

## Install trusted path

- Preferred: `npx @manhquy/flow-skill@latest` (npm provenance applies).
- Direct: `bash scripts/install.sh` (POSIX) or `pwsh scripts/install.ps1` (Windows).
- Verify post-install: run `flow doctor` and check the `runner integrity: ok` line.
