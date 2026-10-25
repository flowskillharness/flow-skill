#!/usr/bin/env bash
# Receipt chain ledger: append on mint, verify detects tamper (sidecar only,
# receipt schema v1 untouched).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
RUN="$HERE/../skills/flow/runner/flow.sh"
unset FLOW_HARNESS_DISABLE
export FLOW_LOG_DISABLE=1
pass=0; fail=0
ck()  { if [ "$1" = "$2" ]; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3] expected=$1 got=$2"; fail=$((fail+1)); fi; }
has() { if printf '%s' "$1" | grep -qE "$2"; then echo "  ok   [$3]"; pass=$((pass+1)); else echo "  FAIL [$3]"; fail=$((fail+1)); fi; }

setup_repo() {
  SB="$(mktemp -d)"; export FLOW_PROJECT_ROOT="$SB"
  mkdir -p "$SB/flow" "$SB/cards" "$SB/bin"
  for s in 00-idea 01-research 02-scope 03-prd 04-adr 05-contract; do
    printf '# %s\n## Gate\n- [x] ok\n\ncontract body for %s\n' "$s" "$s" > "$SB/flow/$s.md"
  done
  printf '# C-001\nstatus: todo\ndeps: none\nimplements: none\nrisk: standard\nrisk-reason: ordinary feature work\nrisk-ack: none\n## Scope\none\n## Allowed files\nbin/\n## Verify\n- [ ] true\n## Done-evidence\ncli runs\n## Evidence\n(empty until done)\n' > "$SB/cards/C-001.md"
  cat > "$SB/bin/semantic_owner.sh" <<'EOS'
#!/usr/bin/env bash
set -u
fp=""; while [ $# -gt 0 ]; do case "$1" in --subject-fingerprint) shift; fp="${1:-}";; esac; shift 2>/dev/null || true; done
printf 'schema: flow-semantic-result/v1\nsubject_fingerprint: %s\nverdict: pass\ncritical_count: 0\nhigh_count: 0\nevidence_ref: none\n' "$fp"
EOS
  chmod +x "$SB/bin/semantic_owner.sh"
  cat > "$SB/bin/owner_semantic_stage.txt" <<EOF
schema: flow-attestation-owner/v1
kind: semantic_gate
subject_id: 05-contract
target_id: none
command: repo:bin/semantic_owner.sh
revision_oracle: none
EOF
  cat > "$SB/bin/owner_semantic_card.txt" <<EOF
schema: flow-attestation-owner/v1
kind: semantic_gate
subject_id: C-001
target_id: none
command: repo:bin/semantic_owner.sh
revision_oracle: none
EOF
  git -C "$SB" init -q
  git -C "$SB" config user.email "t@example.com"
  git -C "$SB" config user.name "T"
  git -C "$SB" add -A && git -C "$SB" commit -qm init
  BASE="$(git -C "$SB" rev-parse HEAD)"
}

echo "A) verify-chain with no ledger reports NO-LEDGER, nonzero"
setup_repo
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
ck 2 "$rc" "no-ledger exit 2"
has "$out" 'NO-LEDGER' "no-ledger message"
rm -rf "$SB"

echo "B) one mint appends one chain line, verify OK"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
ck 0 $? "stage mint"
ledger="$SB/.flow/attestations/chain.log"
[ -f "$ledger" ]; ck 0 $? "ledger exists"
ck 1 "$(wc -l < "$ledger" | tr -d ' ')" "ledger has 1 line"
out="$(bash "$RUN" attest verify-chain 2>&1)"; ck 0 $? "verify exit 0"
has "$out" 'chain: OK 1 entries' "verify OK message"
rm -rf "$SB"

echo "C) second mint chains seq 2 onto first link, verify OK"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
# Card semantic requires base != revision, so advance HEAD with an empty commit.
git -C "$SB" commit -qm second --allow-empty
bash "$RUN" attest semantic --card C-001 --base "$BASE" --revision HEAD --owner bin/owner_semantic_card.txt >/dev/null 2>&1
ck 0 $? "card mint"
ledger="$SB/.flow/attestations/chain.log"
ck 2 "$(wc -l < "$ledger" | tr -d ' ')" "ledger has 2 lines"
first_link="$(awk 'NR==1{print $4}' "$ledger")"
second_prev="$(awk 'NR==2{print $3}' "$ledger")"
ck "$first_link" "$second_prev" "second prev equals first link"
out="$(bash "$RUN" attest verify-chain 2>&1)"; ck 0 $? "verify exit 0 after 2 mints"
has "$out" 'chain: OK 2 entries' "verify OK 2 message"
rm -rf "$SB"

echo "D) tampered receipt reports MISMATCH, nonzero"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
printf 'tamper\n' >> "$SB/.flow/attestations/semantic_gate/stage-05-contract.receipt"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on tamper"
has "$out" 'MISMATCH' "mismatch message"
rm -rf "$SB"

echo "E) tampered ledger link reports BROKEN, nonzero"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
ledger="$SB/.flow/attestations/chain.log"
awk '{$4="0000000000000000000000000000000000000000"; print}' "$ledger" > "$ledger.tmp" && mv "$ledger.tmp" "$ledger"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on ledger tamper"
has "$out" 'BROKEN' "broken message"
rm -rf "$SB"

echo "F) deleted receipt reports MISSING, nonzero"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
rm "$SB/.flow/attestations/semantic_gate/stage-05-contract.receipt"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on delete"
has "$out" 'MISSING' "missing message"
rm -rf "$SB"

echo "G) chain append failure never fails a mint (ledger path blocked by a directory)"
setup_repo
mkdir -p "$SB/.flow/attestations/chain.log"
out="$(bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt 2>&1)"; ck 0 $? "mint succeeds despite chain failure"
has "$out" 'WARNING: receipt chain append failed' "chain warning printed"
rm -rf "$SB"

echo "H) corrupt ledger tail never kills a later mint"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
printf 'garbage line\n' >> "$SB/.flow/attestations/chain.log"
out="$(bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt 2>&1)"; ck 0 $? "mint succeeds despite corrupt ledger tail"
has "$out" 'WARNING: receipt chain append failed' "corrupt-tail warning printed"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on corrupt ledger"
has "$out" 'BROKEN' "corrupt ledger broken message"
rm -rf "$SB"

echo "I) blank ledger line reports BROKEN, not OK 0 entries"
setup_repo
ledger="$SB/.flow/attestations/chain.log"
mkdir -p "$SB/.flow/attestations"
printf '\n' > "$ledger"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on newline-only ledger"
has "$out" 'BROKEN' "newline-only broken message"
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
printf '\n' >> "$ledger"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on blank line after entries"
has "$out" 'BROKEN' "blank line broken message"
rm -rf "$SB"

echo "J) extra trailing token on a ledger line reports BROKEN"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
ledger="$SB/.flow/attestations/chain.log"
awk '{$10="extra"; print}' "$ledger" > "$ledger.tmp" && mv "$ledger.tmp" "$ledger"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on extra token"
has "$out" 'BROKEN' "extra token broken message"
rm -rf "$SB"

echo "K) latest-entry index build failure is a verification failure, not OK"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
out="$(TMPDIR="$SB/no-such-dir" bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero when temp index cannot be built"
has "$out" 'BROKEN' "temp index broken message"
rm -rf "$SB"

echo "L) receipt with no ledger entry reports UNTRACKED"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
cp "$SB/.flow/attestations/semantic_gate/stage-05-contract.receipt" "$SB/.flow/attestations/semantic_gate/stage-04-adr.receipt"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on copied receipt without entry"
has "$out" 'UNTRACKED' "copied receipt untracked message"
rm -rf "$SB"

echo "L2) dropping the last ledger line leaves its receipt UNTRACKED"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
git -C "$SB" commit -qm second --allow-empty
bash "$RUN" attest semantic --card C-001 --base "$BASE" --revision HEAD --owner bin/owner_semantic_card.txt >/dev/null 2>&1
ledger="$SB/.flow/attestations/chain.log"
head -n 1 "$ledger" > "$ledger.tmp" && mv "$ledger.tmp" "$ledger"
out="$(bash "$RUN" attest verify-chain 2>&1)"; rc=$?
[ "$rc" -ne 0 ]; ck 0 $? "verify nonzero on dropped last line"
has "$out" 'UNTRACKED' "dropped line untracked message"
rm -rf "$SB"

echo "M) leading-zero seq in ledger tail never kills a later mint"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
ledger="$SB/.flow/attestations/chain.log"
awk '{$2="08"; print}' "$ledger" > "$ledger.tmp" && mv "$ledger.tmp" "$ledger"
out="$(bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt 2>&1)"; ck 0 $? "mint succeeds despite leading-zero seq tail"
has "$out" 'WARNING: receipt chain append failed' "leading-zero warning printed"
rm -rf "$SB"

echo "N) receipt hash-object failure warns, mint still valid"
setup_repo
SHIMD="$(mktemp -d)"
realgit="$(command -v git)"
cat > "$SHIMD/git" <<EOS
#!/usr/bin/env bash
case "\$*" in *.receipt*) exit 1;; esac
exec "$realgit" "\$@"
EOS
chmod +x "$SHIMD/git"
out="$(PATH="$SHIMD:$PATH" bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt 2>&1)"; ck 0 $? "mint succeeds despite hash failure"
has "$out" 'WARNING: receipt chain append failed' "hash failure warning printed"
rm -rf "$SB" "$SHIMD"

echo "O) verify-chain positional arg is not persisted to events log"
setup_repo
bash "$RUN" attest semantic --stage 05-contract --revision HEAD --owner bin/owner_semantic_stage.txt >/dev/null 2>&1
FLOW_LOG_DISABLE= bash "$RUN" attest verify-chain /tmp/marker-chain-xyz >/dev/null 2>&1
events="$SB/.flow/events.jsonl"
[ -f "$events" ]; ck 0 $? "events log exists"
has "$(cat "$events")" 'verify-chain' "verify-chain verb logged"
if grep -q "marker-chain-xyz" "$events"; then echo "  FAIL [verify-chain arg not logged]"; fail=$((fail+1)); else echo "  ok   [verify-chain arg not logged]"; pass=$((pass+1)); fi
rm -rf "$SB"

echo "P) command-dispatch attest row lists verify-chain"
if grep -qF 'attest semantic\|live-verify\|status\|recover\|verify-chain' "$HERE/../skills/flow/references/command-dispatch.md"; then echo "  ok   [dispatch lists verify-chain]"; pass=$((pass+1)); else echo "  FAIL [dispatch lists verify-chain]"; fail=$((fail+1)); fi

echo "Q) docs state trailing newline, UNTRACKED, and the deletion gap"
doc="$HERE/../skills/flow/references/attestations.md"
has "$(cat "$doc")" 'newline-terminated' "doc trailing newline"
has "$(cat "$doc")" 'UNTRACKED' "doc untracked status"
has "$(cat "$doc")" 'deletions escape' "doc deletion gap"

echo "RESULT pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
