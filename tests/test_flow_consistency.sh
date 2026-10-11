#!/usr/bin/env bash
# Regression suite for the cross-artifact consistency audit (flow.sh consistency):
# every PRD FRn must be claimed by a card (implements:) and served by a contract interface;
# numeric success metric; placeholder sweep. Advisory, ID-based, project-type agnostic.
# Run: bash tests/test_flow_consistency.sh   (exit 0 = all pass, 1 = any fail)

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
RUN="$HERE/../skills/flow/runner/flow.sh"
pass=0; fail=0
ck()  { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected '$1' got '$2'"; fi; [ "$1" = "$2" ] || fail=$((fail+1)); }
has() { if printf '%s' "$1" | grep -q "$2"; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] (missing: $2)"; fail=$((fail+1)); fi; }
no()  { if printf '%s' "$1" | grep -q "$2"; then echo "  FAIL [$3] (unexpected: $2)"; fail=$((fail+1)); else echo "  ok   [$3]"; pass=$((pass+1)); fi; }
newsb() { SB="$(mktemp -d)"; export FLOW_PROJECT_ROOT="$SB"; mkdir -p "$SB/flow" "$SB/cards"; }

# minimal PRD with FR ids + a numeric success metric
prd() { # $1=root  $2=success-metric-body
  cat > "$1/flow/03-prd.md" <<EOF
# Stage 03 - PRD
## Features
- FR1: As a user, I list X, I see X.
- FR2: As a user, I search X, I see filtered X.
## Success metric (numbers only)
$2
EOF
}
contract() { # $1=root  $2=FR refs present in the map
  cat > "$1/flow/05-contract.md" <<EOF
# Stage 05 - Contract
## Feature -> interface map
$2
EOF
}
card() { # $1=root  $2=id  $3=implements-value
  cat > "$1/cards/$2.md" <<EOF
# $2 - x
status: todo
deps: none
implements: $3
EOF
}

echo "A) no PRD -> graceful skip, exit 0"
newsb
out="$(bash "$RUN" consistency)"; ck 0 $? "exit 0 with no PRD"
has "$out" "planning incomplete" "skip message shown"
rm -rf "$SB"

echo "B) clean: every FR covered by a card + contract, numeric metric -> PASS exit 0"
newsb
prd "$SB" "10 items listed in week 1"
contract "$SB" "- FR1 -> GET /x
- FR2 -> GET /x?q="
card "$SB" C-001 "FR1"
card "$SB" C-002 "FR2"
out="$(bash "$RUN" consistency)"; ck 0 $? "clean -> exit 0"
has "$out" "PASS" "reports PASS"
rm -rf "$SB"

echo "C) FR2 has no card -> CRITICAL, exit 1"
newsb
prd "$SB" "10 items listed in week 1"
contract "$SB" "- FR1 -> GET /x
- FR2 -> GET /x?q="
card "$SB" C-001 "FR1"
out="$(bash "$RUN" consistency)"; ck 1 $? "uncovered FR -> exit 1"
has "$out" "CRITICAL" "severity CRITICAL present"
has "$out" "FR2 has no card" "names the uncovered feature"
rm -rf "$SB"

echo "D) card implements an FR absent from PRD -> HIGH, exit 1"
newsb
prd "$SB" "10 items listed in week 1"
contract "$SB" "- FR1 -> GET /x
- FR2 -> GET /x?q="
card "$SB" C-001 "FR1"
card "$SB" C-002 "FR2"
card "$SB" C-003 "FR9"
out="$(bash "$RUN" consistency)"; ck 1 $? "phantom FR -> exit 1"
has "$out" "FR9 is not declared" "names the phantom feature"
rm -rf "$SB"

echo "E) FR not in contract map -> HIGH, exit 1"
newsb
prd "$SB" "10 items listed in week 1"
contract "$SB" "- FR1 -> GET /x"
card "$SB" C-001 "FR1"
card "$SB" C-002 "FR2"
out="$(bash "$RUN" consistency)"; ck 1 $? "FR missing from contract -> exit 1"
has "$out" "absent from the contract" "names the seam gap"
rm -rf "$SB"

echo "F) success metric with no number -> HIGH, exit 1"
newsb
prd "$SB" "save users a lot of time and improve UX"
contract "$SB" "- FR1 -> GET /x
- FR2 -> GET /x?q="
card "$SB" C-001 "FR1"
card "$SB" C-002 "FR2"
out="$(bash "$RUN" consistency)"; ck 1 $? "vibes metric -> exit 1"
has "$out" "no number" "flags the non-numeric metric"
rm -rf "$SB"

echo "G) PRD without FR ids -> info, coverage skipped, exit 0"
newsb
cat > "$SB/flow/03-prd.md" <<EOF
# Stage 03 - PRD
## Features
- As a user, I list X.
## Success metric (numbers only)
10 items in week 1
EOF
out="$(bash "$RUN" consistency)"; ck 0 $? "no FR ids -> exit 0"
has "$out" "no FR ids found" "info message shown"
rm -rf "$SB"

echo "H) placeholder sweep across planning set -> LOW finding (no CRITICAL/HIGH -> exit 0)"
newsb
prd "$SB" "10 items in week 1"
contract "$SB" "- FR1 -> GET /x
- FR2 -> GET /x?q="
card "$SB" C-001 "FR1"
card "$SB" C-002 "FR2"
printf '# Stage 02\n- [FILL: a leftover]\n' > "$SB/flow/02-scope.md"
out="$(bash "$RUN" consistency)"; ck 0 $? "only LOW -> exit 0"
has "$out" "LOW" "LOW placeholder finding present"
no "$out" "FLAGGED" "not FLAGGED (no CRITICAL/HIGH)"
rm -rf "$SB"

echo "I) FR1 + FR10 co-declared, contract has FR1 only -> flags FR10, never FR1 (boundary, not substring)"
newsb
cat > "$SB/flow/03-prd.md" <<EOF
# Stage 03 - PRD
## Features
- FR1: As a user, I list X, I see X.
- FR10: As an admin, I see the admin view.
## Success metric (numbers only)
10 items in week 1
EOF
contract "$SB" "- FR1 -> GET /x"
card "$SB" C-001 "FR1"
card "$SB" C-010 "FR10"
out="$(bash "$RUN" consistency)"; ck 1 $? "FR10 missing from contract -> exit 1"
has "$out" "FR10 is absent" "FR10 flagged"
no "$out" "FR1 is absent" "FR1 NOT falsely flagged (FR1 must not match the FR10 line)"
rm -rf "$SB"

echo "J) FR id mentioned only in PRD prose (outside Features) is NOT treated as a declared feature"
newsb
cat > "$SB/flow/03-prd.md" <<EOF
# Stage 03 - PRD
## Features
- FR1: As a user, I list X, I see X.
## Context
This replaces the old FR9 approach we abandoned.
## Success metric (numbers only)
10 items in week 1
EOF
contract "$SB" "- FR1 -> GET /x"
card "$SB" C-001 "FR1"
out="$(bash "$RUN" consistency)"; ck 0 $? "prose FR9 ignored -> clean exit 0"
no "$out" "FR9" "FR9 (prose-only) is not in the declared set"
rm -rf "$SB"

echo "K) multiple FRs on one implements line: 'implements: FR1, FR2, FR3' -> all covered, exit 0"
newsb
cat > "$SB/flow/03-prd.md" <<EOF
# PRD
## Features
- FR1: a
- FR2: b
- FR3: c
## Success metric (numbers only)
10 in wk1
EOF
contract "$SB" "- FR1 -> /a
- FR2 -> /b
- FR3 -> /c"
card "$SB" C-001 "FR1, FR2, FR3"
out="$(bash "$RUN" consistency)"; ck 0 $? "one card covering 3 FRs -> exit 0"
has "$out" "PASS" "PASS reported"
rm -rf "$SB"

echo "L) 'implements: infra' card must NOT be flagged as a phantom FR"
newsb
prd "$SB" "10 in wk1"
contract "$SB" "- FR1 -> /a
- FR2 -> /b"
card "$SB" C-001 "FR1"
card "$SB" C-002 "FR2"
card "$SB" C-003 "infra"
out="$(bash "$RUN" consistency)"; ck 0 $? "infra card -> exit 0"
no "$out" "infra" "infra never appears as a finding"
rm -rf "$SB"

echo "M) no cards/ dir at all + a declared FR -> CRITICAL, exit 1, no crash"
newsb; rmdir "$SB/cards"
cat > "$SB/flow/03-prd.md" <<EOF
# PRD
## Features
- FR1: a
## Success metric (numbers only)
10 in wk1
EOF
out="$(bash "$RUN" consistency 2>&1)"; ck 1 $? "missing cards/ -> exit 1"
has "$out" "CRITICAL" "FR1 flagged CRITICAL"
no "$out" "No such file" "no shell error leaked"
rm -rf "$SB"

echo "N) contract absent, FR covered by a card -> coverage clean, contract check skipped, exit 0"
newsb
cat > "$SB/flow/03-prd.md" <<EOF
# PRD
## Features
- FR1: a
## Success metric (numbers only)
10 in wk1
EOF
card "$SB" C-001 "FR1"
out="$(bash "$RUN" consistency)"; ck 0 $? "no contract -> exit 0"
has "$out" "PASS" "PASS (contract check gracefully skipped)"
rm -rf "$SB"

echo "O) FR1 + FR10 + FR100 three-way: no substring collision anywhere -> exit 0"
newsb
cat > "$SB/flow/03-prd.md" <<EOF
# PRD
## Features
- FR1: a
- FR10: b
- FR100: c
## Success metric (numbers only)
10 in wk1
EOF
contract "$SB" "- FR1 -> /a
- FR10 -> /b
- FR100 -> /c"
card "$SB" C-001 "FR1, FR10, FR100"
out="$(bash "$RUN" consistency)"; ck 0 $? "3-way numeric boundary -> exit 0"
has "$out" "PASS" "no false collision finding"
rm -rf "$SB"

echo "P) CRLF line endings (Windows) must not break matching -> exit 0"
newsb
printf '# PRD\r\n## Features\r\n- FR1: a\r\n- FR2: b\r\n## Success metric (numbers only)\r\n10 in wk1\r\n' > "$SB/flow/03-prd.md"
printf '# Contract\r\n## Feature -> interface map\r\n- FR1 -> /a\r\n- FR2 -> /b\r\n' > "$SB/flow/05-contract.md"
printf '# C-001\r\nstatus: todo\r\ndeps: none\r\nimplements: FR1, FR2\r\n' > "$SB/cards/C-001.md"
out="$(bash "$RUN" consistency)"; ck 0 $? "CRLF artifacts -> exit 0"
has "$out" "PASS" "matching robust to trailing CR"
rm -rf "$SB"

echo "Q) combined: FR1 uncovered (CRITICAL) + card FR9 phantom (HIGH) reported together, exit 1"
newsb
prd "$SB" "10 in wk1"
contract "$SB" "- FR1 -> /a
- FR2 -> /b"
card "$SB" C-001 "FR2, FR9"
out="$(bash "$RUN" consistency)"; ck 1 $? "two findings -> exit 1"
has "$out" "CRITICAL" "FR1 CRITICAL present"
has "$out" "FR9 is not declared" "FR9 HIGH present"
rm -rf "$SB"

echo "R) DF6-3 nudge: planning complete + PRD declares FRn -> status & next nudge consistency"
newsb
for s in 00-idea 01-research 02-scope 04-adr 05-contract; do printf '#%s\n## Gate\n- [x] ok\n' "$s" > "$SB/flow/$s.md"; done
printf '# PRD\n## Gate\n- [x] ok\n## Features\n- FR1: a\n## Success metric (numbers only)\n10\n' > "$SB/flow/03-prd.md"
out="$(bash "$RUN" status)"
has "$out" "FR->card->contract" "status nudges consistency when PRD declares FR"
out2="$(bash "$RUN" next)"
has "$out2" "FR->card->contract" "next (planning complete) nudges consistency"
rm -rf "$SB"

echo "S) no nudge when PRD declares no FR ids"
newsb
for s in 00-idea 01-research 02-scope 03-prd 04-adr 05-contract; do printf '#%s\n## Gate\n- [x] ok\n' "$s" > "$SB/flow/$s.md"; done
out="$(bash "$RUN" status)"
no "$out" "FR->card->contract" "no consistency nudge without FR ids"
rm -rf "$SB"

echo "T) consistency --contract: contract-to-card endpoint coverage audit (C6)"
# (c) no contract => note + exit 0
newsb
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 0 "$rc" "no contract -> exit 0"
has "$out" "no flow/05-contract.md found" "skip note printed when contract missing"
rm -rf "$SB"

# (a) contract with 3 endpoints, cards covering 2 => warning lists exactly the 1 uncovered, summary line correct, exit 1
newsb
cat > "$SB/flow/05-contract.md" << 'EOF'
# Stage 05 - Contract
| Method/Interface | Path/Name | Access/Effects | Input shape | Output shape |
|---|---|---|---|---|
| GET | /healthz | public | none | 200 |
| POST | /api/login | public | creds | 200 token |
| DELETE | /api/users/:id | admin | none | 204 |
EOF
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: none
## Scope
Build the GET /healthz health check endpoint.
EOF
cat > "$SB/cards/C-002.md" << 'EOF'
# C-002
status: todo
implements: none
## Scope
Build the authentication flow at /api/login with token response.
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 1 "$rc" "uncovered endpoint -> exit 1"
has "$out" "DELETE /api/users/:id" "lists uncovered endpoint"
no "$out" "GET /healthz" "covered endpoint /healthz not in warning list"
no "$out" "POST /api/login" "covered endpoint /api/login not in warning list"
has "$out" "3 endpoint(s), 2 covered, 1 uncovered" "summary line correct"
has "$out" "FLAGGED" "FLAGGED on uncovered endpoints"

# (b) all covered => no warning, exit 0
cat > "$SB/cards/C-003.md" << 'EOF'
# C-003
status: todo
implements: none
## Scope
Admin endpoint to delete user at /api/users/:id
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 0 "$rc" "all endpoints covered -> exit 0"
no "$out" "FLAGGED" "no FLAGGED when all covered"
has "$out" "PASS" "PASS when all covered"
has "$out" "3 endpoint(s), 3 covered, 0 uncovered" "summary line reflects 0 uncovered"

# (d) no --contract => output byte-identical to pre-change behavior on the same sandbox
prd "$SB" "10 items in week 1"
cat >> "$SB/flow/05-contract.md" << 'EOF'
## Feature -> interface map
- FR1 -> GET /healthz
- FR2 -> POST /api/login
EOF
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: FR1
## Scope
Build the GET /healthz health check endpoint.
EOF
cat > "$SB/cards/C-002.md" << 'EOF'
# C-002
status: todo
implements: FR2
## Scope
Build the authentication flow at /api/login with token response.
EOF
out_plain="$(bash "$RUN" consistency 2>&1)"; rc_plain=$?
ck 0 "$rc_plain" "plain consistency exit 0 on clean sandbox"
has "$out_plain" "cross-artifact consistency audit (flow/02-05 + cards/)" "plain consistency runs FR audit"
no "$out_plain" "endpoint coverage audit" "plain consistency does not run endpoint audit"

# (e) missing args / unknown flag handling
out_unk="$(bash "$RUN" consistency --bogus 2>&1)"; rc_unk=$?
ck 1 "$rc_unk" "unknown flag -> exit 1"
has "$out_unk" "usage: /flow consistency [--contract]" "usage printed on unknown flag"
rm -rf "$SB"

echo "U) --contract endpoint matching is exact-token (no prefix/substring false coverage)"
# (a)+(c) prefix collision: card Scope mentions only /api/users/:id and /api/users-list
newsb
cat > "$SB/flow/05-contract.md" << 'EOF'
# Stage 05 - Contract
| Method/Interface | Path/Name | Access/Effects | Input shape | Output shape |
|---|---|---|---|---|
| GET | /api/users | public | none | 200 |
| GET | /api/users/:id | public | none | 200 |
EOF
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: none
## Scope
List view hits /api/users/:id
Detail view also covers /api/users-list naming
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 1 "$rc" "prefix-collision -> /api/users uncovered -> exit 1"
has "$out" "^ *GET /api/users\$" "/api/users flagged uncovered (":id" and "-list" do not cover it)"
no "$out" "GET /api/users/:id" "/api/users/:id covered, not in warning list"
has "$out" "2 endpoint(s), 1 covered, 1 uncovered" "summary counts correct"

# (b) same card also mentioning /api/users plainly => both covered, exit 0
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: none
## Scope
List view hits /api/users directly (GET /api/users?limit=10 also implied).
Detail view covers /api/users/:id
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 0 "$rc" "plain /api/users mention covers both -> exit 0"
has "$out" "2 endpoint(s), 2 covered, 0 uncovered" "both endpoints covered"
rm -rf "$SB"

# (d) regex metacharacters in the path are escaped: /v1/config.max must not match /v1/configXmax
newsb
cat > "$SB/flow/05-contract.md" << 'EOF'
# Stage 05 - Contract
| Method/Interface | Path/Name | Access/Effects | Input shape | Output shape |
|---|---|---|---|---|
| GET | /v1/config.max | public | none | 200 |
EOF
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: none
## Scope
Reads /v1/configXmax (wrong path - must not satisfy the contract).
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 1 "$rc" "'.' in path treated literally -> exit 1"
has "$out" "GET /v1/config.max" "config.max flagged uncovered (no regex dot wildcard)"
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: none
## Scope
Reads /v1/config.max on boot.
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 0 "$rc" "exact /v1/config.max -> exit 0"
has "$out" "1 endpoint(s), 1 covered, 0 uncovered" "literal dot path covered"
rm -rf "$SB"

# (e) closing brace is path continuation: /api/users} must not cover /api/users
newsb
cat > "$SB/flow/05-contract.md" << 'EOF'
# Stage 05 - Contract
| Method/Interface | Path/Name | Access/Effects | Input shape | Output shape |
|---|---|---|---|---|
| GET | /api/users | public | none | 200 |
EOF
cat > "$SB/cards/C-001.md" << 'EOF'
# C-001
status: todo
implements: none
## Scope
Callback hits /api/users}
EOF
out="$(bash "$RUN" consistency --contract 2>&1)"; rc=$?
ck 1 "$rc" "'/api/users}' is path continuation -> exit 1"
has "$out" "GET /api/users" "/api/users flagged uncovered (trailing } continues path)"
rm -rf "$SB"

echo
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
