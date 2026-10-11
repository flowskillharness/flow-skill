# Trends: Spec-driven development & plan/card discipline (2025–2026)

Research date: 2026-10-10. Live web access: YES.

## Summary

Spec-driven development (SDD) went mainstream in 2025–2026: "by 2026, every major AI
coding tool" has an SDD story. GitHub's Spec Kit (specify → plan → tasks → implement,
with constitution and evolve-spec workflows) is the reference open-source toolkit and
now documents "build with a spec, fix a bug, or assess an idea" — the assess-an-idea and
brownfield entries are newer additions. Community debate centers on spec evolution:
when code diverges from spec, is the spec still source of truth (Spec Kit discussion
#152)? SDD's promise: agent writes detailed spec → derives plan → atomic tasks → only
then code, which is structurally the same discipline flow enforces with gates and cards.

## Evidence

- GitHub spec-kit repo (workflows incl. constitution, specify/plan/tasks, evolve-spec
  directory): https://github.com/github/spec-kit — accessed 2026-10-10.
- Spec Kit docs: "Build with a spec, fix a bug, or assess an idea — with your coding
  agent": https://github.github.com/spec-kit/ — accessed 2026-10-10.
- "Spec-Driven Development (SDD): The Definitive 2026 Guide" — every major tool has SDD
  by 2026; spec → plan → atomic tasks → code:
  https://www.thebcms.com/blog/spec-driven-development/ — accessed 2026-10-10.
- Spec Kit discussion #152 "Evolving specs" — is the spec the source of truth when the
  system outgrows it; one-spec-per-feature churn concern:
  https://github.com/github/spec-kit/discussions/152 — accessed 2026-10-10.
- Practitioner piece on SDD as "designing before you code (again)", Spec-Kit blending
  classic specification rigor with agentic workflows:
  https://medium.com/@dave-patten/spec-driven-development-designing-before-you-code-again-21023ac91180 — accessed 2026-10-10.

## Implications for flow-skill

- **Flow is an SDD implementation with teeth.** Spec Kit's specify/plan/tasks maps to
  flow's Idea→…→Contract→Cards; the difference is flow's mechanical gate per stage
  (exit 0/1 flow.sh) plus world-state done-evidence — Spec Kit has artifacts but no
  cheatable-check layer. Positioning copy for README: "Spec Kit tells the agent what to
  write; flow refuses to advance until it's real." Docs-only, but a strong differentiator
  currently unstated.
- **Contract-as-seam vs spec-as-source-of-truth.** Spec Kit #152's spec-evolution pain is
  what flow's law 2 answers: "Amend the contract, then code" — the contract is amended,
  not silently diverged from. flow's `contract` drift gate (F3, merged) mechanically
  detects divergence. This is a direct, citable answer to the ecosystem's open debate;
  worth a paragraph in `docs/system-architecture.md` or gate-rules index.
- **"Assess an idea" and brownfield** entries in Spec Kit confirm flow's `flow assess`
  (F2, merged, brownfield 00-inspect pre-stage) hit the same gap others are now filling —
  external validation, cite when documenting assess.
- **Card discipline**: Spec Kit's atomic tasks ≈ flow cards, but flow's one-card-per-session,
  `## Allowed files`, pasted world-state proof are stricter. Keep flow stricter — the
  evidence above shows task-scoping is the accepted core; proof-of-done is flow's edge.
- No overlap conflict with the knowledge-upgrades roadmap (it mentions
  spec-driven-brownfield research only as motivation for F2).

## Open questions

- Should flow emit/import a Spec Kit-compatible spec shape (interop) or stay
  flow-native? Interop would ease migration but risks "second home for a fact".
- Does spec-evolution (#152) suggest flow needs a lightweight "spec amended, cards
  re-derived" verb beyond manual contract amendment?

## Sources quality

- primary/official: GitHub spec-kit repo, Spec Kit docs (github.github.com/spec-kit), Spec Kit discussion #152; vendor blog: The BCM blog; community: Medium (Dave Patten)
Overall confidence: high
