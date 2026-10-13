# Security policy

## Threat model

`@manhquy/flow-skill` is a **file-copy installer** written in pure Node.js. When you run `npx @manhquy/flow-skill`, the process:

- copies files from the tarball into one or more agent home directories, and
- exits.

There are no network calls, no shell/PowerShell invocations, no `postinstall` hooks, and no long-running daemons.

## What the installer WILL NOT do

- Run any script from the Internet at install time.
- Touch `settings.json`, `permissions`, `allowedMcpServers`, hooks, or any marketplace config.
- Modify MCP config, shell rc, PATH, or environment variables.
- Log in to npm, mint tokens, or publish anything.
- Log, save, or commit tokens, passwords, OTPs, or private keys.
- Touch any path outside the explicit list below:
  - `<home>/.claude/skills/flow`
  - `<home>/.codex/skills/flow`
  - `<home>/.agents/skills/flow`
  - `<home>/.omp/agent/skills/flow`
  - `<home>/.gemini/antigravity-cli/skills/flow`
  - `<home>/.gemini/config/skills/flow`
  - `<home>/.cursor/skills/flow`
  - `<project>/.claude/skills/flow` when `--project` is used
  - plus the transient sibling `<parent>/.flow-skill-stage-*` / `.flow-skill-backup-*` /
    `.flow-skill-failed-*` slots and the `<parent>/.flow-skill.installing.lock` used by the
    transaction (stage/backup/lock live next to the destination and are removed when the
    transaction completes; a failed rollback deliberately KEEPS the backup and reports it)
- Spawn `bash`, `sh`, `pwsh`, `powershell.exe`, or any child process (pure Node `node:fs`).

## What the installer WILL do

For each destination the user selects, the installer runs a **transaction** (wave-2 model;
the old rm-then-copy contract is gone):

1. Acquire a best-effort advisory lock: `<parent>/.flow-skill.installing.lock`. If the file
   exists and its recorded PID is alive, refuse and exit `2`.
2. Validate inputs strictly before touching anything: source and destination disjoint, no
   symlinks in the source tree (an upstream-planted symlink is hostile), no symlink among
   the destination's ancestors or in the destination tree, destination is a real directory.
3. Read-only ownership survey: the shipped `manifest-hashes.json` receipt is validated
   (schema, canonical paths, 64-hex digests, duplicate-key rejection) and re-verified
   against actual source bytes. The destination's previous receipt (if any) decides
   ownership. Refusals, all before any mutation:
   - a file the old receipt owns was edited in place and the new source still ships it →
     explicit conflict list, exit;
   - a receipted path is missing from the destination → receipt/root mismatch, exit;
   - no old receipt (legacy destination) and a new-source path collides with differing
     bytes → collision refusal, exit;
   - FIFO/socket/device entries in the destination → refused.
4. Build a staged candidate in a private random `<parent>/.flow-skill-stage-*` directory:
   every new source-owned file (each staged copy re-verified byte-for-byte), plus every
   user-created file from the destination — including inside previously-managed
   subdirectories — plus retired owned files the user modified. Retired owned files that
   are unmodified are pruned. A fresh receipt generated from the staged bytes is written;
   it owns only the new source files, so preserved customs are never pruned by future
   upgrades.
5. Swap: rename the old destination to a random `<parent>/.flow-skill-backup-*` slot,
   rename the candidate to the destination, then verify the promoted tree against the
   staged expectation (keyset + digests + bytes). Only after verification is the backup
   removed. Promotion/verification failure quarantines the candidate and renames the
   backup back; if that restore rename fails, the backup is kept and `recoveryPath` is
   reported (structured field in the `install:done` JSONL event and a human recovery line).
6. `chmod 755` the destination's `runner/flow.sh` if it exists. Release the lock.

Guarantees hold for returned failures. No crash/`SIGKILL` atomicity is promised: a hard
kill mid-transaction can leave the stage/backup slots behind; re-running the installer
repairs the destination, and the old tree remains intact inside any backup slot.

## Known limitations

- **Per-destination, not multi-destination atomic.** Antigravity has two destinations, each
  with its own transaction. If the second fails after the first succeeded, the first stays
  installed and the results report the partial state truthfully.
- **Windows `EBUSY`.** If a running agent holds a file handle inside the destination,
  rename/copy retries 3× with backoff (100/300/900 ms). If it still fails, the installer
  reports the target and asks you to close the agent.
- **Same-uid race surface.** The lock path is predictable, and path operations race with
  concurrent same-uid writers; no malicious-same-uid filesystem safety is claimed.
- **Empty directories are not carried across upgrades** (files are).

## Supply chain

- **Trusted publishing.** Every version is published from a tag-triggered GitHub Actions workflow (`.github/workflows/publish-npm-wrapper.yml`, or `workflow_dispatch` for validation) behind a required-reviewer environment gate. No long-lived npm token exists in CI; auth is via OIDC.
- **Provenance.** npm attaches an SLSA Build Level 2 attestation to every version published from the workflow. Verify with:
  ```
  npm view @manhquy/flow-skill@<version> dist.attestations.provenance
  ```
  **`v0.1.0-rc.1` exception**: this bootstrap version was published manually (Trusted Publisher requires the package to already exist before it can bind) and carries no attestation. `v0.1.0-rc.2` (2026-07-17) is the first version published from CI via OIDC — confirmed live with an SLSA Build Level 2 attestation. All versions from rc.2 onward are attested; if provenance is a hard requirement, pin `@0.1.0-rc.2` or later.
- **Publisher account.** npm 2FA `auth-and-writes` is enabled as defense-in-depth for the git + npm identity behind the workflow.
- **Pin your version.** During the RC window use `@rc` (dist-tag) or an explicit `@0.1.0-rc.N`. After stable ships, pin `@0.1.x` (or a specific version). `@latest` invites blind updates on a package that writes to your agent home.
- **Completeness signal (not tamper detection).** The tarball ships `skills-manifest.json` recording the synced skill's file count + list. The publish workflow re-counts the checked-out tree against this manifest to catch an incomplete sync. It is **not** a supply-chain integrity proof — that role belongs to npm provenance above. `.integrity` SHA-256 sidecar was intentionally not adopted because it would have been generated from the same source it hashed (circular trust).
- **No `postinstall`.** `package.json` has no `postinstall` script. `prepack` (dev-only) is not in the shipped tarball.

## Reporting a security issue

- Preferred: [GitHub Security Advisory](https://github.com/manhquydev/flow-skill/security/advisories/new)
- Email: `manhquy.mqy@gmail.com` (subject: `[flow-skill security]`)

Please do not publish exploits before a fix ships. Best-effort response SLA for v0.1.
