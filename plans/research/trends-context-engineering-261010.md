# Trends: Context engineering — compaction, memory, budgets, calibration (2025–2026)

Research date: 2026-10-10. Live web access: YES.

## Summary

"Context engineering" replaced "prompt engineering" as the operating discipline in
2025–2026. Anthropic's canonical framing: context is a finite working memory with
curvature — the skill is curation, not stuffing. The lab toolbox converged on three
levers — compaction (summarize history), tool-result clearing, and external memory —
and Claude Code ships all three in production. Practitioner findings in 2026 add two
counter-intuitive results: (1) naive auto-compaction can hurt (context rot: quality
degrades as the window fills, and summarize-then-restart loses signal), leading some
teams to stop compacting and instead keep authoritative state in files; (2) the fix is
"a disciplined budget", not a bigger window.

## Evidence

- Anthropic, "Effective context engineering for AI agents" (working-memory analogy,
  curation over accumulation): https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — accessed 2026-10-10.
- Claude Cookbook, "Memory vs. Compaction vs. Tool Clearing" — Claude Code uses all
  three strategies in production: https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools — accessed 2026-10-10.
- Louis Bouchard, "Context Engineering in 2026: Why We Stopped Compacting" — compaction
  "didn't pay" in their evals; files/index as durable state instead:
  https://www.louisbouchard.ai/context-engineering-2026/ — accessed 2026-10-10.
- "The fix is not a bigger window; it is a disciplined budget":
  https://cruxdigits.nl/blog/context-engineering-ai-agents-2026/ — accessed 2026-10-10.
- Context rot mechanics + auto-compaction behavior in Claude Code:
  https://vincentvandeth.nl/blog/context-rot-claude-code-automatic-rotation — accessed 2026-10-10.
- Compaction as the 2026 lab-wide convergence for long-running agents:
  https://medium.com/@pankaj_pandey/compaction-how-long-running-agents-beat-the-context-rot-problem-fc12d4cdeb7b — accessed 2026-10-10.
- Sourcegraph practical guide (prompt vs context engineering, four pillars):
  https://sourcegraph.com/blog/context-engineering — accessed 2026-10-10.

## Implications for flow-skill

- **Flow's file-on-disk state model is the winning pattern.** The "stop compacting, keep
  state in files" result validates flow's design: `flow/` planning artifacts + `cards/` +
  `resume` story are exactly "authoritative state outside the window". `flow resume`
  (session-story, last session, in-flight, dwell) is flow's compaction replacement —
  say this explicitly in `references/concierge.md` or the resume docs; it is a strong
  design argument, currently implicit.
- **PTC_ONLY load table = context budget discipline.** "Load one extra reference per verb"
  is a per-call context budget. The 2026 literature says budgets beat windows; flow
  should state its load table in budget terms (≤1 reference + 1 dispatch row) so
  contributors don't grow it casually — a doc-budgets-style rule for SKILL.md includes.
- **Calibration**: covered in the knowledge-upgrades roadmap (predicted-vs-actual,
  Brier/calibration row — merged via `harness audit`/`decision outcome`). This file adds:
  the industry framing now calls this "calibration" too, and context budgets are the
  input side of the same loop (what the agent saw ↔ what it predicted). Keep the merged
  design; no rework indicated.
- **Deterministic consolidation** (roadmap's count-based ≥2 rule) aligns with the finding
  that summarization destroys signal — another external confirmation, citable in
  `harness/README.md`.
- Token budgets: `docs/doc-budgets.txt` enforces repo-doc budgets; the same philosophy
  could one day extend to a stated token budget for SKILL.md + references, but no code
  change is warranted now.

## Open questions

- Does flow's SKILL.md (fixed ~1600-word budget) measurably reduce context-rot vs
  typical always-loaded CLAUDE.md? Would need a fixture-based eval to claim.
- Should `resume` output be explicitly bounded (token/line cap) as a budget guarantee?

## Sources quality

- primary/official: Anthropic engineering blog, Claude Cookbook; vendor blog: Louis Bouchard, Cruxdigits, Vincent van Deth, Sourcegraph; community: Medium (Pankaj Pandey)
Overall confidence: medium
Weak-basis implications: "Stop compacting, keep state in files" / context-rot findings (file-on-disk validation, deterministic consolidation) rest on independent blogs and a Medium post, not primary research
