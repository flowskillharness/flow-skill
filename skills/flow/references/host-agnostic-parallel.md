# Host-agnostic parallel occupancy

Flow requires **no named multiplexer**. Parallel cards are a ready-gate +
worktrees + host-owned placement + world-state fan-in. Absence of Herdr, tmux,
in-process `Task`, or any other host **never fails a gate** and never changes
`flow.sh` exit.

Herdr and tmux appear below only as **examples, never as a dependency** or a
first-class adapter.

## Degrade ladder

| Rung | Primitive already in the process | Who binds occupants | Who waits |
|---|---|---|---|
| **0** | In-process subagents / `Task` | Hosting agent; cwd = the card's worktree | Host `Task` join |
| **1** | Operator extra terminals / tabs | Human pastes the print-enter block | Human |
| **2** | Process is **already inside** a mux (`HERDR_ENV=1` / `TMUX` set) | That mux's **own** skill/CLI; flow does not wrap or detect it | That mux's own wait |
| **3** | None of the above, or `/flow ready` overlap | Serial: one card | Hosting agent, one at a time |

Rung 2 is opt-in by the mux's own environment injection, never by `PATH`.
Inside-mux probe is the mux's own env (`HERDR_ENV=1`, `TMUX`), never
`command -v herdr` from outside (a CLI can talk to a same-uid socket without
`HERDR_ENV`). Absence of rungs 0–2 is the default path, not a degrade footnote.

## Gate parity

Host `idle` / `done` / `blocked` is **not a card pass**. `flow.sh check` still
judges, and it must run **in the card's worktree** (parent-tree check of main
is a false fail/pass). Screen output is not evidence.

Keep the four "blocked" senses distinct:

| Sense | Meaning | Home |
|---|---|---|
| **host-blocked** | mux/pane approval chrome or occupant stuck | the host |
| **subagent-BLOCKED** | scoped subagent status protocol | `agent-detection.md` |
| **ready-blocked** | deps unmet or allowed-files overlap | `flow.sh ready` |
| **Tier-C security halt** | security-class exposure; operator DEBT | `auto-run.md` |

Mixing them auto-answers a payments card or auto-halts a yes/no prompt.

## File-is-the-wait

The **HOST waits** (Task join / human / the mux's own wait). `flow.sh` **never waits on or polls** another agent. Fan-in is world-state: re-invoke `check` in
the card worktree after the host's wait returns.

## Forbidden (ADR-0001; not a nit)

`flow.sh` must not exec host control CLIs (`herdr agent start`, `herdr agent wait`, `herdr agent prompt`, `herdr server stop`, `tmux send-keys`, and equivalents).
Forbidden by name: `mux-up`, `mux-run-wave`, `mux-proxy`. No screen output as
evidence. No hook install into `~/.claude` or `~/.omp`. No long-lived socket subscribe (`events.subscribe`). `flow.sh` never spawns agents; placement is print-enter or the host's own Task/mux.

Own-runtime / own-PTY / own-wait is a successor ADR plus a separate product,
not a card in this skill.

## workspace port

Deterministic per-card port allocator for parallel worktree web verification (`flow workspace port <C-NNN>`).

- **Formula:** `port = FLOW_WORKSPACE_BASEPORT + port_offset` (where `port_offset` is the registered worktree offset from `.flow/workspaces.jsonl`). Stable per registration and matches `workspace enter`.
- **Port Bounds & Fail-Loud:** If `port = FLOW_WORKSPACE_BASEPORT + port_offset > 65535`, `workspace port` fails loudly with exit 2 (`FAIL - port range exhausted for '<card>' (baseport <b> + offset <o> = <raw> > 65535); lower FLOW_WORKSPACE_BASEPORT`) rather than wrapping or aliasing.
- **Environment Override:** `FLOW_WORKSPACE_BASEPORT` (defaults to `3000`; valid numeric range is `1..65535`). Out-of-range baseport exits 2.
- **Target File Contract:** Writes/overwrites strictly `<worktree>/.env.flow.local` inside the card's registered workspace root with:
  ```sh
  PORT=<port>
  FLOW_CARD=<C-NNN>
  ```
  Mutates only this single file; zero locks needed beyond standard workspace mechanics.
- **Exit Codes:**
  - `0`: Workspace resolved, port computed, `.env.flow.local` written.
  - `2`: Card argument invalid shape, no registered workspace in `.flow/workspaces.jsonl`, missing `port_offset`, baseport out of range, or port range exhausted > 65535 (never creates worktrees implicitly).

## resume output contract

`flow resume` is the external-orchestrator re-entry surface. It is read-only for planning/card state (event-tail + registry reads via
`inflight_display`; no lock, no plan/card mutation, no `next_verb`
execution) — but the runner's EXIT trap (`_log_on_exit` -> `_log_event`)
still appends telemetry on every invocation (a row to the project's
`events.jsonl` plus a compact row to the device-global log), so expect
those files to grow. The documented elements below describe shipped
behavior; anything not listed here is not to be parsed.

**Output shape, in order:**

1. **Header.** `flow resume`, then indented `project:` (repo root) and
   `auto:` (attestation auto state). If planning has not started
   (`current_stage_idx < 0`), resume emits only `nothing to resume - <next
   action>` + `NEXT_VERB=<verb>` and stops.
2. **Last-session telemetry block.** The most recent foreign session_id in
   `events.jsonl` (string inequality vs the current session), emitting that
   session's rows as `<ts> <command> ok|FAIL(n) [stage_from -> stage_to]`.
   Command **NAMES only — never raw args** (free-text args can carry
   unmasked secrets). Rows are capped `tail -5` (most recent wins). A
   `ppid:`-scheme session whose latest foreign row is < 900s from the anchor
   (this session's own first row if present, else wall-clock `now` — the
   no-own-row-yet case is exactly when resume runs) is labeled
   `recent activity` instead of `last session`, because PID reuse makes a
   "last session" that may never have existed. Absolute timestamps shown
   either way. If `events.jsonl` is empty/absent: `no telemetry - showing
   gate state only`, then gate state + NEXT, and no in-flight section.
3. **In-flight section.** `in flight:` header, then one line per todo card
   still registered in `$CARDS_DIR/.inflight` (`cards/.inflight`, per
   `_inflight_file`): `    <id> (in flight, started
   <Xm|Xh|Xd> ago)`. Stale ids (card file gone) self-skip; **completed cards
   are never listed** (only `status: todo` rows qualify).
4. **Gate state.** Identical block to `flow status` (`_gate_state_brief`):
   current stage only — `planning: at stage <s>` plus `gate: PASS|BLOCKED`.
   (In the rare earlier-stage-blocked state, NEXT may point at an earlier
   stage than this current-stage gate; that is by design.)
5. **Exactly one `NEXT -> <action>` + `NEXT_VERB=<verb>` line pair**, from
   the same `_next_action` ladder as `status` — the two verbs can never
   disagree.

**`--budget` semantics.** `resume --budget` caps the in-flight list at 5
lines plus one `    +M more in flight - see 'flow card'` summary line
(where M = hidden count). With ≤5 in-flight cards, `--budget` output is
**byte-identical to default resume output** (matching rule:
byte-identical-under-budget). No other section is affected; default resume
lists all in-flight cards and never emits the summary line. Extra arguments
to either form exit 2.

**`resume --json`.** Emits exactly one closed `flow_context/v1` object —
the same schema as `status --json`:
`{"v":"flow_context/v1","stage":...,"gate":"PASS|BLOCKED|none","next_verb":...,"card":...,"dwell":...,"load":...}`.
Display-only: it reports what to run next but never executes `next_verb`.

**Scope note (not a stability promise).** The elements above are parseable by external
orchestrators; parse only these, never ad-hoc prose. This documents shipped
behavior as of the current flow version (`version` in `skills/flow/SKILL.md`
— currently 0.33.0 — surfaced as `flow_version` in telemetry). The project
has not adopted a formal compatibility guarantee: when upgrading flow,
re-diff this contract against the runner (`cmd_resume`, `inflight_display`,
`_log_event`) before relying on it.
