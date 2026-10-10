# /flow tech-trends upgrades — research + roadmap (2026-10-10)

Grounding for the 2026 discipline-layer upgrades. Synthesizes findings across 7 trend areas
crawled in `plans/research/trends-*.md` and the architecture gap analysis in
`plans/research/gap-analysis-261010.md`. Order is sequential across 4 waves.

## New core concepts captured (the learning)

| Term | One-line | Source |
|---|---|---|
| **Context rot / Compaction penalty** | Summarization destroys signal; durable on-disk state wins | `trends-context-engineering` |
| **Longitudinal skill regression** | Tracking fixture verdicts across runs over time | `trends-agent-evals-benchmarks` |
| **Senior-engineer eval tier** | Judging subtle engineering judgment, not patch mechanics | `trends-agent-evals-benchmarks` |
| **Hook-less attack surface** | Security posture from rejecting lifecycle hooks | `trends-agent-security-hooks` |
| **Adversarial gate injection** | Jailbreaks hidden in artifacts forcing gate PASS | `trends-agent-security-hooks` |
| **Spec-as-seam (SDD with teeth)** | Contract-first specs enforced by mechanical gates | `trends-spec-driven-dev` |
| **Worktree parallel execution** | Spec-scoped tasks isolated in git worktrees | `trends-multi-agent-orchestration` |
| **Protocol-agnostic discipline** | Consuming host MCP tools without hosting a server | `trends-mcp-protocol` |

**Design principles preserved:** Host-invoked only (ADR-0001), bash 3.2-safe, zero new runtime deps,
degrade loudly, never lower a gate, doc budgets, untouchable eval STOP zones.

## Relation to 260614 roadmap "remaining nice-to-haves"

- **Auto-promote playbooks from `propose`**: **Superseded & scheduled** by Candidate 7 (`flow promote --suggest`).
- **SEMANTIC doc-coherence**: **Partially extended** by Candidate 6 (`flow consistency --contract` endpoint audit).
- **Tree-sitter AST dependency graph**: **Untouched**; file-glob scanners remain adequate and zero-dep.
- **Rust-backend parity tests**: **Untouched**; Python+sqlite3 durable layer remains stable under ADR-0001.

## Explicit non-goals (rejected per ADR-0001)

1. **Resident MCP Server / Tool Interposition Wrapper**: Rejected; *requires reopening ADR 0001*.
2. **Background Watcher / Resident Daemon**: Rejected; *requires reopening ADR 0001*.
3. **Automatic Lifecycle Event Hooks**: Rejected; *requires reopening ADR 0001* and expands CBSE attack surface.
4. **Autonomous Orchestration Runtime (`flow-orch`)**: Rejected; *requires reopening ADR 0001* and tripwire 5 capacity.
5. **Compiled/Native Dependencies** (tree-sitter, docker APIs): Rejected; violates zero new runtime deps.

## Traceability & Status

Candidates defined in `plans/research/gap-analysis-261010.md` §6:

| Candidate | Trend Anchor | Surface | Effort | Status |
|---|---|---|---|---|
| **C1: Eval regression diff (`eval --diff`)** | `trends-agent-evals-benchmarks` | `runner/flow.sh`, `refs/gate-eval.md` | Med | Wave 2 — shipped on branch (correctness-relative classifier vs expected verdicts; semantics: references/gate-eval.md ## eval --diff) |
| **C2: Bounded context handoff (`resume --budget`)** | `trends-context-engineering` | `runner/flow.sh`, `docs/doc-budgets.txt` | Low | Wave 1 — shipped on branch (rescoped: in-flight cap; see §6 C2) |
| **C3: Adversarial injection fixtures** | `trends-agent-security-hooks` | `eval/fixtures/`, `eval/manifest.tsv` | Low | Wave 2 — shipped on branch (fixtures f06_*; mocked-suite validated; live-model untested) |
| **C4: Worktree port allocator (`workspace port`)** | `trends-multi-agent-orchestration` | `runner/flow.sh`, `refs/host-agnostic-parallel` | Low-Med | Wave 3 — shipped on branch (reads registered port_offset; fail-loud overflow; see §6 C4) |
| **C5: Runner self-integrity verification** | `trends-agent-security-hooks` | `runner/flow.sh` (`cmd_doctor`) | Med | Wave 1 — shipped on branch (pack-time hash; doctor verifies, older installs skip; see §6 C5) |
| **C6: Contract-to-card coverage (`consistency`)** | `trends-spec-driven-dev` | `runner/flow.sh` (`cmd_consistency`) | Med | Wave 4 — shipped on branch (advisory contract-to-card endpoint audit; see §6 C6) |
| **C7: Automated ACE playbook drafting (`promote`)** | `trends-context-engineering`, 260614 | `harness/flow_harness.py`, `runner/flow.sh` | Med | Wave 4 — shipped on branch (read-only draft suggestions, ACE >=2 bar; see §6 C7) |

## Sequential Waves

### Wave 1: Context Budget & Runner Integrity (C2 + C5)
*Rationale: Hardens execution hygiene and prevents context rot with zero eval-engine or test-matrix risk.*
- **C2 (`flow resume --budget (in-flight cap)`):** no wave-internal deps — design: gap-analysis-261010.md §6 Candidate 2
- **C5 (Runner integrity check):** shipped on branch (pack-time hash; doctor verifies, older installs skip; see §6 C5)

### Wave 2: Eval Intelligence & Adversarial Resilience (C1 + C3)
*Rationale: Equips maintainers to detect prompt/gate regressions safely before introducing new mechanical scanners.*
- **C1 (`flow eval --diff`):** no wave-internal deps — design: gap-analysis-261010.md §6 Candidate 1
- **C3 (Adversarial injection fixtures):** no wave-internal deps — design: gap-analysis-261010.md §6 Candidate 3

### Wave 3: Worktree Localhost Port Isolation (C4)
*Rationale: Resolves localhost port collisions during live verification across parallel multi-agent builds.*
- **C4 (`flow workspace port C-NNN`):** no wave-internal deps — design: gap-analysis-261010.md §6 Candidate 4

### Wave 4: Spec Seam Alignment & Knowledge Promotion (C6 + C7)
*Rationale: Closes the contract-to-card gap and delivers the remaining 260614 ACE knowledge promotion loop.*
- **C6 (`flow consistency --contract`):** no wave-internal deps — design: gap-analysis-261010.md §6 Candidate 6
- **C7 (`flow promote --suggest`):** no wave-internal deps — design: gap-analysis-261010.md §6 Candidate 7

---

## Verification & Sources

Drawn from:
- `plans/260614-flow-knowledge-upgrades-roadmap.md` (baseline style & nice-to-haves inventory)
- `docs/adr/0001-discipline-layer-identity.md` (constitutional bounds)
- `skills/flow/runner/flow.sh` (command dispatch, eval STOP zones, midtier scanners)
- `plans/research/gap-analysis-261010.md` (architectural gaps & candidate designs §6)
- `plans/research/trends-*.md` (7 research files: agent-skills, mcp, evals, context-eng, spec-driven, security, orchestration)
