# Trends: Multi-agent orchestration — orchestrator/worker, handoff, worktree isolation (2025–2026)

Research date: 2026-10-10. Live web access: YES.

## Summary

Multi-agent coding went from experiment to default workflow for parallel work, but the
infrastructure has NOT converged: one 2026 survey of orchestration approaches found
"four approaches, no convergence" (agent teams, orchestrator/worker spawns, pane
managers, task queues). What HAS converged is the operating recipe: decompose into
spec-scoped, independently testable tasks; isolate each agent in its own git worktree;
require tests/automated gates before merge. Port allocation, shared-file conflicts, and
session state are called out as the concrete resource-isolation gaps. Handoff (passing
continuation state between sessions/agents) remains ad hoc — mostly convention files
and session-story dumps.

## Evidence

- "Designing the Multi-Agent Development Environment" — four orchestration approaches,
  no convergence; layer model ending in resource isolation (ports, worktrees); Claude
  Code agent-teams layout `~/.claude/teams/{team}/`:
  https://alexlavaee.me/blog/parallel-agent-sessions-infrastructure-gap/ — accessed 2026-10-10.
- Augment Code guide (2026): TL;DR recipe — spec-scoped tasks, git worktree per agent,
  tests + automated gates before merge:
  https://www.augmentcode.com/guides/how-to-run-a-multi-agent-coding-workspace — accessed 2026-10-10.
- Practitioner thread on orchestration tooling: parallel tasks via good tooling + git
  worktrees; one UI showing per-task state:
  https://www.reddit.com/r/ClaudeCode/comments/1q9dmxd/multiagent_orchestration_for_parallel_work_tools/ — accessed 2026-10-10.
- Conflict-avoidance as the core coding-specific problem (two agents editing the same
  file): https://www.tembo.io/blog/ai-agent-orchestration-tools — accessed 2026-10-10.
- Curated list of orchestrator frameworks (swarms, teams, queues — breadth of the space):
  https://github.com/andyrewlee/awesome-agent-orchestrators — accessed 2026-10-10.

## Implications for flow-skill

- **Flow's parallel-occupancy design matches the converged recipe almost line-for-line.**
  Flow already has: `workspace add|list|enter` (worktree isolation), `ready` marking
  cards safe for parallel build, one-card-per-session, "never build two cards in
  parallel before `ready`", and `## Allowed files` per card (spec-scoped conflict
  avoidance — Tembo's core problem, answered structurally). Document this mapping in
  `references/host-agnostic-parallel.md` with the Augment recipe as external validation.
- **`FLOW_SESSION_ID` + `.lock` + FLOW_LOCK_TTL is flow's answer to the "no convergence"
  state layer.** The infrastructure-gap article's layer model (teams → spawns →
  isolation) puts state/lock coordination at the unsolved layer; flow's lock with TTL
  auto-reclaim and refuse-on-fresh-foreign-lock is a real implementation of that layer —
  a differentiator worth stating in `docs/system-architecture.md`.
- **Handoff is flow's `resume` verb** (read-only session-story: last session, in-flight +
  dwell, gate state, one NEXT line). The ecosystem lacks a handoff standard; flow's
  session-story is its candidate. Keep the story format stable and documented — it is
  de-facto flow's interop surface. [INFERENCE: no external standard to align to yet.]
- **Gates-before-merge is consensus** ("tests plus automated gates before merge") — flow's
  card `check` + Review stage is that gate at card granularity. No change needed; cite
  when explaining why the Review gate exists.
- Orchestration tools are runtimes/host-side; flow must remain the discipline layer they
  call, never become an orchestrator (ADR-0001 boundary). A future host could use flow
  workspaces as its isolation layer — that is integration, not new flow code.

## Open questions

- Does `ready`'s parallel-safety marking correspond to any emerging standard (or is
  flow ahead of the market here)?
- Should the `resume` story format be versioned/stable-documented as a public contract
  so external orchestrators can consume it?

## Sources quality

- primary/official: none; vendor blog: Alex Lavaee blog, Augment Code guide, Tembo blog; community: Reddit r/ClaudeCode thread, awesome-agent-orchestrators list
Overall confidence: low
Weak-basis implications: All four implications (worktree recipe, session/lock layer, handoff-resume, gates-before-merge) rest solely on vendor blogs and community threads; no primary/official source in the file
