# Trends: Model Context Protocol (2025–2026)

Research date: 2026-10-10. Live web access: YES.

## Summary

MCP moved from Anthropic-led launch to cross-vendor agent infrastructure within ~18
months. The spec now runs on a dated-release cadence (2025-06-18 → 2025-11-25
"first anniversary" release → 2026-07-28 release), with an official registry concept,
agent-identity standardization, and security as first-class roadmap items. Security
attention has escalated to government level: NSA/CISA published "MCP: Security Design
Considerations" (May/June 2026). Adoption stats sites track it as infrastructure
(modelcontextprotocol/servers at 86k stars / 10.8k forks at verification time).

## Evidence

- Official MCP roadmap: identity standardization for servers, "continue improving
  security by adopting existing standards", registry work:
  https://modelcontextprotocol.io/development/roadmap — accessed 2026-10-10.
- MCP blog, 2026-07-28 spec release ("growth as the data and interactivity layer"):
  https://blog.modelcontextprotocol.io/posts/2026-07-28/ — accessed 2026-10-10.
- Spec version timeline (Nov 2024 → 2025-06-18 → 2025-11-25 → 2026-07-28) with adoption
  milestones per version: https://hidekazu-konishi.com/entry/mcp_specification_version_timeline.html — accessed 2026-10-10.
- MCP adoption statistics 2026 (servers repo 86,148★/10,799★ forks; cross-vendor):
  https://www.digitalapplied.com/blog/mcp-adoption-statistics-2026-model-context-protocol — accessed 2026-10-10.
- NSA/CISA CSI "Model Context Protocol (MCP): Security Design Considerations for MCP
  Servers" (May 2026 ver., posted 2026-06-02):
  https://media.defense.gov/2026/Jun/02/2003943289/-1/-1/0/CSI_MCP_SECURITY.PDF — accessed 2026-10-10.

## Implications for flow-skill

- **Identity ADR is validated from outside**: the MCP roadmap itself is converging on
  "standardized agent identities" — flow's process-token invariant (flow runs only when
  a host/operator invokes it; no daemon) is the same conservative instinct regulators
  and the spec now push. Cite this in ADR-0001 discussions if identity is ever
  challenged; no change needed.
- **Dated spec releases vs flow's versioning**: flow already separates skill version
  from npm version (`docs/release-process.md`). MCP's date-versioned spec (`2026-07-28`)
  is further evidence date-versioning aids drift discussions — relevant to `flow
  coherence` (F7), which scans declared version fields; it could someday flag
  date-versioned deps too, but that is an idea, not a task.
- **Security-guidance surface**: CISA guidance gives flow's HALT-on-security-debt rule
  (SKILL.md STOP list: "Security-class skip/debt → HALT until operator accepts in
  DEBT.md") external authority. A pointer in `references/debt-and-halts.md` to the CISA
  doc would ground the law — docs-only change, fits doc budgets.
- **Flow stays protocol-agnostic**: flow is a discipline layer, not an MCP server and
  not a tool wrapper. The correct posture is: consume MCP-based host capabilities, never
  become one. Any PR proposing an MCP server reopens ADR-0001 — say this explicitly in
  the ADR's "what would reopen this" note if not already present.
- Overlap note: the knowledge-upgrades roadmap does not cover MCP; this is new ground.

## Open questions

- Does the 2026-07-28 spec's registry change how skills/references should be packaged
  (would flow ever be registry-listed, and does that conflict with npm dual-versioning)?
- Which CISA recommendations (if any) map to flow's hook-less, bash-only runner surface?

## Sources quality

- primary/official: MCP official roadmap, MCP blog (modelcontextprotocol.io), NSA/CISA CSI PDF; vendor blog: Digital Applied stats blog; community: Hidekazu Konishi personal site
Overall confidence: high
