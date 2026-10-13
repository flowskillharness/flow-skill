W2 result report — host-context adapter (2026-10-13)

Status: **targeted slices verified; full 66-suite result unverified**. Permanent suite `tests/test_flow_host_hooks.sh` 44/44 PASS (Linux event replay, PID-reuse safe observational `kill -0`, secret token injection tested). Independent integration review completed by `agentkit-review` (27/27 test scenarios passed, 0 blocking issues). Master full-suite 66/66 terminal exit receipt remains unverified due to missing retention in transcript. Final decision record: `plans/261013-agentkit-engineer-upgrade/plan.md`.

## Implemented in working tree (not git-published, not activated)

All items below exist in the working tree only. No commit, push, release, or version bump was performed, and no host hook activation was performed.

- `docs/adr/0001-discipline-layer-identity.md` — Addendum "Host-fired lifecycle context adapters (2026-10-13)": accepted boundary, user-authorized revision provenance, exact exception (host-invoked, advisory, fail-open, never gate-bearing, zero tool interposition, sole private write, operator-owned registration, no new deps, revision rule).
- `plans/261010-tech-trends-upgrade-roadmap.md` — non-goal 3 now points at the addendum (flow-registered/gate-coupled hooks stay rejected).
- `skills/flow/adapter-hooks/flow-context-handler` — launcher: probes a genuinely usable python3 (version-checked; py2 rejected), fail-open warn+exit 0 when absent; execs the module with the host's stdin passed through.
- `skills/flow/adapter-hooks/context_handler.py` — core. PreCompact: stdout EMPTY on every branch; one bounded `status` snapshot into private `.flow/context-handoff/snapshot.json` (existing `.flow` only; private dir exact 0700, created only if absent; symlink/owner/mode refusals; O_EXCL random staged write; os.replace by dir_fd; serialized document hard-capped 1 MiB incl. JSON overhead; refuse-if-oversized). SessionStart: fresh authoritative `status` recompute, source-labeled; validated snapshot (O_NOFOLLOW+fstat regular/owner/0600, strict JSON, project match) as staleness reference or STALE-labeled fallback. Runner invocations pin `FLOW_PROJECT_ROOT` to the payload project and set the runner's own `FLOW_LOG_DISABLE=1` (no telemetry, no cross-project leak). Timeout: saved-pgid process-group kill + reap, event marked rc 124 → stale fallback. Strict JSON (duplicate keys rejected), 64 KiB + deadline stdin, strict UTF-8, env bounds (length-checked, floor 1024 on output cap), UTF-8-safe byte caps incl. labels, fail-open exit 0 on every error path, no raw payload/cwd/event-class/runner-stderr echoed anywhere.
- `skills/flow/adapter-hooks/claude-settings-snippet.json` — opt-in Claude Code template (SessionStart + PreCompact, quoted command, recommended 20 s timeout); operator-merged; flow never registers anything.
- `skills/flow/references/host-hooks.md` — honest event model (PreCompact stdout NOT injected by the host, citing the host's own hook implementation), Claude Code install incl. spaces-safe quoting and `FLOW_SKILL_DIR` pin, per-host support disclosures (Codex/OMP/Antigravity unsupported or unclaimed — no OMP runtime claim), env knobs, verified-scope annotations (Linux replay; wrong-owner/platform-missing paths not exercised and not claimed).
- `skills/flow/references/claudekit-skills.md`, `agent-detection.md` — live-host-registry authoritative resolution (exact name; accessible SKILL description when safe; active catalog metadata sufficient; no fixed home list/count), `ak-security-scan` alias removed, scanner≠STRIDE honesty clause, static counts removed. SKILL.md dispatch row for host-hooks.md (word budget respected).
- Permanent suite: `tests/test_flow_host_hooks.sh` — row registered in `tests/manifest.txt` (this worker is the sole manifest owner; registered row confirmed by direct read of `tests/manifest.txt`).

## Known limitations (disclosed, not worked around)

- Platforms without O_NOFOLLOW/O_DIRECTORY: snapshot refused; fresh-only handoff.
- Group/world-writable existing `.flow` or non-0700 `context-handoff` refused, never repaired (note: the runner itself can create `.flow` group-writable under umask 002 → those installs get fresh-only handoff until modes are tightened).
- Cross-project forged snapshots refused; wrong-owner (non-euid) refusal path is implemented but not exercised by the suite.
- Windows: untested, no runtime claim (POSIX shell + python3 required).

## Coordination

- W1 (source worker) delivered doctor named checks + doctor-only JSON + full-tree receipt; independent review by `agentkit-review` verified 0 blocking issues.
- Integration: manifest row registered in `tests/manifest.txt`; targeted slices verified; full 66-suite master run terminal summary unverified; docs and evidence index fully aligned.
