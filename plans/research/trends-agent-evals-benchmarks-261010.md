# Trends: Agent coding benchmarks & eval harnesses (2025–2026)

Research date: 2026-10-10. Live web access: YES.

## Summary

SWE-bench family scores keep climbing (leaderboards show frontier agents at ~77%
resolved on SWE-bench; third-party Verified leaderboards report higher figures with
cheaper harnesses like mini-SWE-agent), pushing the field toward harder, more
realistic suites: terminal-bench positions itself as "measure and evolve with the
frontier of agent work", and new evals grade "senior engineer" behaviors rather than
patch application. Two harness trends matter for skills: (1) harness identity is now
reported alongside model (same model scores differently per harness), and (2)
regression evals for prompts/skills have become a product category — dedicated
skill-eval harnesses answer "which prompts improved, regressed, saturated?" across
model versions and repos.

## Evidence

- SWE-bench leaderboards (top entry ~76.8% resolved, mini-SWE-agent, per-harness cost
  columns): https://www.swebench.com/ — accessed 2026-10-10.
- Terminal-bench homepage ("measure and evolve with the frontier of agent work",
  resolution-rate/cost leaderboards): https://www.tbench.ai/ — accessed 2026-10-10.
- Vals AI SWE-bench Verified leaderboard (harness + cost-per-test reported; e.g. 97%
  with mini-SWE-agent at $1.29/test): https://www.vals.ai/benchmarks/swebench — accessed 2026-10-10.
- Snorkel "Senior SWE-Bench: Evaluating Coding Agents Like Senior Engineers"
  (2026-07-16) — agents still weak at senior-level behaviors; harness-fairness controls:
  https://snorkel.ai/blog/senior-swe-bench-evaluating-coding-agents-like-senior-engineers/ — accessed 2026-10-10.
- Reddit experiment: adding a reviewer agent lifted SWE-bench resolution 80%→90%
  (multi-agent review as measurable lift): https://www.reddit.com/r/ClaudeAI/comments/1qi2gh0/i_ran_100_swebench_tests_comparing_1_agent_vs_2/ — accessed 2026-10-10.
- Promptfoo guide "Evaluate Coding Agents" (multi-file feature-implementation eval
  cases in CI): https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/ — accessed 2026-10-10.
- skill-eval-harness — regression flags (improved/regressed/saturated/no-lift) per
  prompt case: https://skillsllm.com/skill/skill-eval-harness — accessed 2026-10-10.
- StackHawk "An Eval Harness for Agent Skills: How We Change Behavior on Purpose" —
  testing skill versions (v2.0 vs v2.1) across three repo fixtures:
  https://www.stackhawk.com/blog/eval-harness-agent-skills/ — accessed 2026-10-10.

## Implications for flow-skill

- **Flow's hollow/sound eval fixtures are the same idea the market productized.** AGENTS.md
  convention "a wave that adds a gate-enforced rule adds ≥1 hollow/sound eval fixture
  pair" matches skill-eval-harness's regression flags and StackHawk's before/after skill
  testing. Flow is ahead; the gap is reporting — fixtures pass/fail but there is no
  regressed/improved/saturated classification over time. An eval report verb (read-only,
  over existing `eval` fixtures) would close it without new deps.
- **Harness fairness matters to flow's eval claims.** SWE-bench lesson: report the harness
  with the number. `docs/quality-metrics.md` should state harness identity (bash version,
  OS, fixture set, model used for semantic evals) alongside any number it publishes.
- **Senior-engineer behaviors are the new eval frontier** — precisely flow's semantic gate
  territory (grade-laundering detection, honest-B vs fake-A). The trend says flow's
  gate-examples library is its most durable asset; benchmarks won't cover it, so flow's
  own fixture pairs are the differentiator.
- **Reviewer-agent lift (80→90%)** supports flow's Review stage and one-card-per-session
  discipline with external data; a citation candidate for `references/gate-eval.md`.
- Overlap note: roadmap file's Reflexion/ACE rows concern self-improvement loops; this
  file covers external benchmark landscape — complementary, no repetition.

## Open questions

- Can flow's bash fixtures be expressed in a portable format (e.g. promptfoo config)
  so others can regression-test flow forks — without adding a runtime dep?
- Should `tests/manifest.txt` rows carry a "category" tag (gate-rule vs regression) to
  enable improved/regressed/saturated reporting later?

## Sources quality

- primary/official: SWE-bench leaderboards, Terminal-bench homepage, Promptfoo guide; vendor blog: Vals AI leaderboard, Snorkel blog, StackHawk blog; community: Reddit reviewer-agent experiment, skill-eval-harness listing
Overall confidence: medium
Weak-basis implications: Reviewer-agent lift (80→90%) supports flow's Review stage (community Reddit experiment only)
