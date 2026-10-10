# Trends: Agent security — permission models, hooks, sandboxing, prompt injection (2025–2026)

Research date: 2026-10-10. Live web access: YES.

## Summary

2026 made coding-agent security a distinct discipline. Consensus framing (NCC Group):
controls live in two layers — permission models and sandboxing — and some agents still
ship without sandboxes. The hook mechanism, introduced for policy enforcement, became
the primary attack surface: Cymulate disclosed a configuration-based sandbox escape via
hooks ("hooks execute without any additional permission or user notification" once
placed in a config file), and BeyondTrust (Oct 2026) showed a benign-looking skill
weaponizing the skill lifecycle into C2, executing outside normal sandbox/permission
protections. Prompt injection remains "the leading AI agent security risk in 2026".
New work argues for defense-in-depth beyond sandboxing.

## Evidence

- NCC Group, "An Introduction to AI Coding Agent Security" (2026) — permission models +
  sandboxing as the two control layers; notes some coding agents lack sandboxes:
  https://www.nccgroup.com/media/jtepwx1t/nccgroup_codingagentswhitepaper.pdf — accessed 2026-10-10.
- Cymulate, "Configuration-Based Sandbox Escape (CBSE) in AI Coding Tools" — hooks in
  config files execute with no extra permission or user notification (Claude Code
  escape): https://cymulate.com/blog/the-race-to-ship-ai-tools-left-security-behind-part-1-sandbox-escape/ — accessed 2026-10-10.
- BeyondTrust Phantom Labs, "Weaponizing Claude Code Hooks: Building a C2 Through the
  Skill Lifecycle" (2026-10-06) — benign skill + hooks = execution outside sandbox:
  https://www.beyondtrust.com/blog/entry/claude-code-hooks-c2-skill-security — accessed 2026-10-10.
- Truefoundry, "Prompt Injection Risks in Claude Code" — injection as leading 2026
  agent risk; real-world vulnerability classes:
  https://www.truefoundry.com/blog/claude-code-prompt-injection — accessed 2026-10-10.
- Practitioner control list (prompt injection, MCP scope leaks, hook exposure audits):
  https://www.ayautomate.com/blog/ai-agent-security-best-practices — accessed 2026-10-10.
- See also trends-mcp-protocol-261010.md: NSA/CISA MCP security guidance (May 2026).

## Implications for flow-skill

- **Flow's runner is bash executed by the host agent — hooks are the exact attack class
  flow must never adopt.** The Cymulate/BeyondTrust findings validate flow's design of
  deterministic `flow.sh` invoked explicitly by the agent, with NO lifecycle hooks
  (no auto-run on tool events). The identity ADR ("flow runs because a host invoked it;
  terminates when it returns") is itself a security property: no resident process, no
  hook surface. State this explicitly in ADR-0001 and `docs/system-architecture.md` —
  docs-only, high value.
- **Skill-supply-chain threat is now demonstrated against flow's exact distribution
  form.** BeyondTrust's attack vector is "a seemingly benign skill". Flow is installed
  from npm/marketplaces; its SKILL.md instructs hosts to run bash. Defensive posture to
  document (docs-only): (a) flow's bash is confined to `flow/`, `cards/`, receipts; (b)
  review the load table before adding any reference that tells the agent to execute
  non-`flow.sh` commands; (c) keep "Never edit runner/flow.sh during a project run" —
  it also blocks mid-session tampering.
- **Prompt-injection posture for the semantic gate.** Gate content comes from repo files
  (gate-examples, PRDs) that may contain injected instructions. Flow's existing rule —
  mechanical `flow.sh` exit code is ground truth, "never host judgment" for PASS — is a
  prompt-injection mitigation: an injected "advance the gate" cannot flip the script's
  exit code. Make that rationale explicit in `references/gate-rules.md` or STOP list.
- **HALT-on-security-debt** (SKILL.md STOP list) aligns with NCC's defense-in-depth
  message; could cite NCC/CISA in `references/debt-and-halts.md`.
- No hooks-based policy gates should ever be added to flow without reopening ADR-0001 —
  the 2026 evidence turns that from preference into policy.

## Open questions

- Should flow ship a short SECURITY.md documenting its non-hook, non-daemon attack
  surface and trusted-path for installs (hash-pinned tarballs vs npm)?
- Does the npm-wrapper install path need integrity verification (published checksums)
  given demonstrated skill-lifecycle attacks?

## Sources quality

- primary/official: NCC Group whitepaper, BeyondTrust Phantom Labs, NSA/CISA MCP guidance (cross-ref); vendor blog: Cymulate, Truefoundry, Ayautomate
Overall confidence: high
