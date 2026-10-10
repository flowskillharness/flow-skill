# flow — brand brief

Product: gated build harness for coding agents. Terminal-first, chat is the
front door (`/flow`, `/flow next`, `/flow check`, `/flow doctor`). Standalone
npm installer `@manhquy/flow-skill`, MIT, bilingual EN + VI, site
[flowskill.io.vn](https://flowskill.io.vn).

## Positioning statement

For developers running AI coding agents who are tired of "done" that means
"the model said so", flow is the discipline layer that sits between the agent
and the claim: a mechanical gate (`flow.sh`) and a semantic gate (`SKILL.md`)
must both agree before a stage advances, and every transition leaves a
receipt. Flow owns the gates and the receipts — never the runtime. Unlike
workflow wrappers that make agents feel productive, flow makes progress
provable: done equals world-state evidence, and a kill at a gate is a valid,
honored outcome.

One line: **proof over vibes**.

## Target audience

- **Primary:** solo devs and small teams running Claude/Codex-style coding
  agents on real products, who have been burned by hollow completes —
  "tests pass" while the URL doesn't work.
- **Secondary:** maintainers retrofitting discipline onto brownfield repos
  (`/flow assess`); agent-power-users who want autonomous runs with hard
  stops (`/flow auto`) instead of unsupervised drift.
- **Not the audience:** people looking for a no-friction "vibe coding" autopilot.
  Flow deliberately adds friction at gates. Saying so is on-brand.

They are terminal residents, read diffs before accepting them, and switch
between English and Vietnamese casually. They distrust adjectives.

## Brand personality (5 adjectives)

1. **Disciplined** — gates over prompts; the ritual is the product.
2. **Transparent** — receipts, ledgers, and exit codes, not claims.
3. **Dependable** — boring tech (bash + sqlite), same gate on every path.
4. **Friction-honest** — says what's blocking, in one `NEXT ->` line.
5. **Unpretentious** — no hype, no confetti, no "10x" talk.

## Core values (tied to gates / receipts / discipline)

- **Two keys, one gate.** Mechanical and semantic checks must both agree.
  Neither alone is trusted; the cheatable part is ground-truth-enforced.
- **Done is a world-state, not a feeling.** A card is done when the live URL
  proves it. Every stage transition writes a durable receipt that survives
  sessions and context rot.
- **A kill is an outcome, not a failure of the tool.** Stopping at a gate is
  honored and recorded — the ledger says why, `DEBT.md` says what it cost.
- **Bounded power.** Flow never owns the runtime. It gates and records; it
  does not run your build.
- **Boring on purpose.** YAGNI/KISS applies to the brand too: the most
  reliable aesthetic is the one that renders in an 80-column terminal.

## Voice & tone

**English**
- Plain, precise, declarative. Short sentences. Verdicts are blunt:
  `GAP`, `CONVERGED`, `INVALID`, `NEXT ->`.
- Show evidence, then interpret. Never say "seamless", "supercharge",
  "effortless", or "10x". Friction is described honestly ("this gate will
  block you until…"), because surviving friction is the value.
- Dry humor is allowed at low frequency (release notes, doctor output);
  never inside a verdict or an error message.
- Numbers over adjectives: "3 OSes, 2 gates, 1 receipt per transition."

**Vietnamese (Tiếng Việt)**
- Gọi người dùng là "bạn"; giọng thân mật nhưng không tùy tiện.
- Thuật ngữ kỹ thuật giữ nguyên khi cộng đồng đã dùng tiếng Anh:
  gate, stage, receipt, runtime, card. Phần diễn giải dùng tiếng Việt tự nhiên.
- Dấu đầy đủ và đúng, luôn. Tiếng Việt không có dấu không phải phiên bản
  rút gọn — đó là lỗi thương hiệu.
- Câu khẳng định ngắn, ưu tiên mệnh lệnh: "Chạy `bash tests/run_all.sh`."

**Both**
- Never blame the user for a gate failure; the gate did its job.
- Error messages state the unmet condition and the exact next command.
- One language per document; never mix mid-sentence.

## Tagline options

| # | English | Tiếng Việt |
|---|---------|------------|
| 1 | Proof over vibes. | Bằng chứng hơn cảm hứng. |
| 2 | Discipline you can prove. | Kỷ luật bạn kiểm chứng được. |
| 3 | Done means proven. | Xong nghĩa là đã chứng minh. |

Recommendation: **#1** for marketing surfaces (site hero, npm keywords),
**#3** for product surfaces (README tagline, `/flow` banner footer) — it is
also the definition of card-done.

## Messaging pillars

1. **The dual gate.** A script can't judge a fabricated competitor quote,
   but it catches an unchecked box; the model can't fake an exit code.
   Only when both agree does a stage advance. → "Honesty has two keys."
2. **Receipts, not claims.** Every transition writes durable state — story,
   trace, decision, debt ledger — that survives context windows. "Done" is
   world-state proof on the live URL, and `/flow resume` reconstructs where
   you were from receipts alone. → "Progress you can audit."
3. **Calm command of autonomous agents.** Chat front door, typed verbs,
   pluggable agents, fixed gates, hard stops on security-class findings.
   The agent may improvise; the gate never does. → "The agent may drift;
   the gate won't."

## What flow is not (guardrails)

- Not a runtime, executor, or deployment tool — never imply ownership.
- Not a replacement for judgment — the semantic gate *is* judgment.
- Not enterprise "governance theater" — no dashboards-for-the-sake-of-it.
- Never sell "no effort"; sell *provable* effort.
