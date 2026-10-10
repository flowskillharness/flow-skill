# Trends: Agent skill ecosystems & conventions (2025–2026)

Research date: 2026-10-10. Live web access: YES (search + fetched snippets below).

## Summary

The "skill" pattern — a discoverable, installable bundle of instructions a host agent
loads on demand — has consolidated into a cross-vendor norm in 2025–2026. Claude Code's
plugin/skill marketplace became a real distribution channel (Anthropic marketplace page
lists 342 plugins; community marketplaces and skill registries proliferate). AGENTS.md
moved from convention to de-facto standard: adopted by OpenAI Codex, Cursor, GitHub
Copilot and others, reported across 60,000+ open-source repos and ~two dozen coding
tools by mid-2026. Meanwhile 90% of professional developers report weekly AI-agent use
(JetBrains, May–Jul 2026), so skill ecosystems are now a mainstream distribution surface,
not an Anthropic side channel.

## Evidence

- Claude plugin marketplace with 342 plugins incl. "Superpowers" (skill authoring, TDD,
  subagent code review): https://claude.com/marketplace/plugins — accessed 2026-10-10.
- "The Only 11 Claude Plugins You Need in 2026" — plugin marketplace as mainstream
  distribution: https://pub.towardsai.net/the-only-11-claude-plugins-you-need-in-2026-i-tested-them-all-ea60bb2e31ea — accessed 2026-10-10.
- Community skill marketplace repos (tons-of-skills-marketplace) show third-party
  marketplace ecosystems forming: https://github.com/jeremylongshore/tons-of-skills-marketplace — accessed 2026-10-10.
- AGENTS.md adopted by Codex, Cursor, Copilot; 60,000+ repos (mid-2026):
  https://techwithibrahim.medium.com/top-ai-agent-standards-to-know-in-2026-c4a53f4b6bfd — accessed 2026-10-10.
- AGENTS.md standard guide: "runs across 60,000+ repos and two dozen coding tools",
  nested AGENTS.md per directory:
  https://www.buildmvpfast.com/blog/agents-md-standard-battle-tested-guide-2026 — accessed 2026-10-10.
- 90% of pro devs use AI agents weekly (JetBrains State of Developers, Aug 2026):
  https://blog.jetbrains.com/research/2026/08/ai-coding-agent-adoption-2026/ — accessed 2026-10-10.
- AGENTS.md still "the essential context file" mid-2026 practitioner review:
  https://www.reddit.com/r/AgentContext_dev/comments/1vrkakw/agentsmd_in_summer_2026_still_the_essential/ — accessed 2026-10-10.

## Implications for flow-skill

- **Install homes validate flow's multi-host strategy.** Flow already installs to
  `~/.claude`, `~/.codex`, `~/.agents`, Antigravity paths (`SKILL.md` load table). The
  `~/.agents/skills/` convention spreading beyond Codex means AGENTS.md-rooted hosts are
  converging; flow's agent-detection references should stay table-driven, not name-cased.
- **Nested AGENTS.md adoption supports flow's "one home per fact" + law/ split**: the
  ecosystem norm is now hierarchical instruction files; flow's `law/CLAUDE.md` vs root
  `AGENTS.md` distinction (project law vs build-session law) maps cleanly onto it — keep
  documenting that separation, it is now idiomatic rather than exotic.
- **Marketplace distribution** (Anthropic plugin marketplace, community registries) is a
  plausible future channel for `npm-wrapper`/`sync.mjs` packing — worth a release-process
  note, not code, per the identity ADR (flow is not a runtime; a marketplace entry is a
  distribution artifact only).
- **Skill-discovery pressure**: with 342+ plugins, host agents face discovery noise. Flow's
  PTC_ONLY "always-on SKILL.md + one reference per verb" load table is ahead of the
  average skill on token discipline; this is a marketable differentiator worth surfacing
  in README/docs.
- AGENTS.md adoption was already cited in `plans/260614-flow-knowledge-upgrades-roadmap.md`
  (github.blog copilot agents.md row, 40% hallucination reduction) — this file extends
  rather than repeats it: the new signal is marketplace scale + cross-vendor install paths.

## Open questions

- Do community skill marketplaces impose any manifest/quality requirements flow's
  `sync.mjs` output would need (beyond SKILL.md frontmatter)?
- Is `~/.agents/skills/` becoming an actual standard (agents.md spec?) or per-tool habit?
- Does Anthropic marketplace listing change the dual-version (skill vs npm) release story?

## Sources quality

- primary/official: Claude plugin marketplace (Anthropic), JetBrains State of Developers; vendor blog: Towards AI piece, TechWithIbrahim (Medium), BuildMVPFast blog; community: tons-of-skills-marketplace repo, Reddit r/AgentContext_dev thread
Overall confidence: medium
Weak-basis implications: Install-homes / nested-AGENTS.md / AGENTS.md adoption claims rest on vendor-community blog posts and a Reddit thread (no primary standard source)
