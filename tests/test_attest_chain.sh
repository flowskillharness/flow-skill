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

echo "RESULT pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
