import { RELEASE_CONSTANTS, requireUnpublishedVersion, selectChannelBaseline, selectAuthoritativeJob, selectAuthoritativeRun, selectMergedMasterPr } from '../scripts/release-workflow.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { compareSemver } from '../npm-wrapper/scripts/semver.mjs';
import { compareVersions, evaluateRelease } from '../scripts/release-eligibility.mjs';

const base = () => ({
  mode: 'workflow_run', phase: 'eligibility',
  expected: { workflowId: 123, workflowPath: '.github/workflows/ci.yml', publisherWorkflowPath: '.github/workflows/publish-npm-wrapper.yml', masterSha: 'abc123', repository: 'owner/repo' },
  run: { workflowId: 123, workflowPath: '.github/workflows/ci.yml', event: 'push', branch: 'master', conclusion: 'success', id: 88, attempt: 2, latestAttempt: 2, headSha: 'abc123', authoritativeJob: { name: 'all-checks-passed', app: 'github-actions', conclusion: 'success' } },
  pullRequest: { merged: true, baseRepo: 'owner/repo', baseBranch: 'master', headSha: 'abc123' },
  release: { intent: true, npmVersion: '0.8.0', skillVersion: '0.25.0', channel: 'latest', npmChangelog: true, skillChangelog: true },
  artifact: { integrity: 'sha512-test', commit: 'abc123', workflowRunId: 88, workflowRunAttempt: 2 },
  registry: { state: 'absent', error: 'E404', channelVersion: '0.7.11' },
  currentMasterSha: 'abc123', autopublishEnabled: true,
});

test('returns eligible only for exact current successful CI, PR and release intent', () => {
  assert.equal(evaluateRelease(base()).decision, 'eligible');
});

test('manual dispatch is always dry-run and never eligible for publishing', () => {
  assert.equal(evaluateRelease({ mode: 'dispatch', dispatchMode: 'dry-run' }).decision, 'dry-run');
  assert.equal(evaluateRelease({ mode: 'dispatch', dispatchMode: 'publish' }).decision, 'refuse');
});

test('rejects wrong workflow/event/branch, stale master, old attempt, and failed authoritative job', () => {
  for (const mutate of [s => { s.run.workflowId = 999; }, s => { s.run.event = 'pull_request'; }, s => { s.run.branch = 'feature'; }, s => { s.expected.masterSha = 'newsha'; }, s => { s.run.latestAttempt = 3; }, s => { s.run.authoritativeJob.conclusion = 'failure'; }]) {
    const snapshot = base(); mutate(snapshot); assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  }
});

test('requires merged PR targeting this repository master and same SHA', () => {
  for (const field of ['merged', 'baseRepo', 'baseBranch', 'headSha']) {
    const snapshot = base(); snapshot.pullRequest[field] = field === 'merged' ? false : 'wrong';
    assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  }
});

test('no committed release intent is a no-op; malformed dual-axis intent refuses', () => {
  const absent = base(); absent.release.intent = false;
  assert.equal(evaluateRelease(absent).decision, 'noop-no-release-intent');
  for (const bad of [{ ...base().release, channel: 'next' }, { ...base().release, npmChangelog: false }, { ...base().release, skillChangelog: false }]) {
    const snapshot = base(); snapshot.release = bad; assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  }
});

test('fails closed on unknown registry, non-E404 absence, and API errors', () => {
  for (const registry of [null, { state: 'absent', error: 'E403' }, { state: 'unknown', error: 'timeout' }]) {
    const snapshot = base(); snapshot.registry = registry; assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  }
});

test('requires artifact identity bound to exact publisher run at publish boundary', () => {
  for (const field of ['commit', 'workflowRunId', 'workflowRunAttempt', 'integrity']) {
    const snapshot = base();
    snapshot.phase = 'publish';
    snapshot.publisherRunId = 9001;
    snapshot.publisherRunAttempt = 2;
    snapshot.artifact = { integrity: 'sha512-test', commit: 'abc123', workflowRunId: 9001, workflowRunAttempt: 2 };
    snapshot.prepublishMasterSha = 'abc123';
    snapshot.prepublishRegistryState = 'absent';
    snapshot.artifact[field] = field === 'integrity' ? '' : -1;
    assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  }
  const good = base();
  good.phase = 'publish';
  good.publisherRunId = 9001;
  good.publisherRunAttempt = 2;
  good.artifact = { integrity: 'sha512-test', commit: 'abc123', workflowRunId: 9001, workflowRunAttempt: 2 };
  good.prepublishMasterSha = 'abc123';
  good.prepublishRegistryState = 'absent';
  assert.equal(evaluateRelease(good).decision, 'publish');
});

test('publish artifact run ID and attempt must match exact publisher attempt', () => {
  const snapshot = base();
  snapshot.phase = 'publish';
  snapshot.publisherRunId = 9001;
  snapshot.publisherRunAttempt = 3;
  snapshot.artifact = { integrity: 'sha512-test', commit: 'abc123', workflowRunId: 9001, workflowRunAttempt: 3 };
  snapshot.prepublishMasterSha = 'abc123';
  snapshot.prepublishRegistryState = 'absent';
  assert.equal(evaluateRelease(snapshot).decision, 'publish');
  snapshot.artifact.workflowRunId = '9001';
  assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  snapshot.artifact.workflowRunId = 9001;
  snapshot.artifact.workflowRunAttempt = 2;
  assert.equal(evaluateRelease(snapshot).decision, 'refuse');
});

test('existing versions reconcile only in verify-only mode and exact identity', () => {
  const existing = base(); existing.phase = 'reconcile';
  existing.artifact = { integrity: 'sha512-test' };
  existing.reconciliation = { verified: true, expectedSha: 'abc123' };
  existing.registry = { state: 'present', integrity: 'sha512-test', channel: 'latest', tagTarget: 'abc123', releaseTarget: 'abc123', provenance: { repository: 'owner/repo', workflowPath: '.github/workflows/publish-npm-wrapper.yml', commit: 'abc123', integrity: 'sha512-test' } };
  assert.equal(evaluateRelease(existing).decision, 'already-published-exact-match');
  for (const key of ['integrity', 'channel', 'tagTarget', 'releaseTarget']) {
    const bad = structuredClone(existing); bad.registry[key] = 'wrong'; assert.equal(evaluateRelease(bad).decision, 'refuse');
  }
  const badProv = structuredClone(existing); badProv.registry.provenance.workflowPath = '.github/workflows/ci.yml';
  assert.equal(evaluateRelease(badProv).decision, 'refuse');
  const unauthorized = structuredClone(existing); unauthorized.phase = 'eligibility';
  assert.equal(evaluateRelease(unauthorized).decision, 'refuse');
  const noVerification = structuredClone(existing); noVerification.reconciliation.verified = false;
  assert.equal(evaluateRelease(noVerification).decision, 'refuse');
});

test('refuses downgrade, master movement, registry race and disabled publishing', () => {
  for (const mutate of [s => { s.release.npmVersion = '0.7.10'; }, s => { s.currentMasterSha = 'newsha'; }, s => { s.autopublishEnabled = false; }, s => { s.registry.channelVersion = '0.9.0'; }]) {
    const snapshot = base(); mutate(snapshot); assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  }
  const race = base(); race.phase = 'publish'; race.prepublishMasterSha = 'newsha'; race.prepublishRegistryState = 'absent';
  assert.equal(evaluateRelease(race).decision, 'refuse');
});

test('uses audited strict SemVer precedence, including numeric precision and hyphenated prerelease IDs', () => {
  for (const [left, right] of [['1.0.0', '1.0.0-rc.9'], ['1.0.0-rc.10', '1.0.0-rc.9'], ['1.0.0-alpha-beta.1', '1.0.0-alpha-beta'], ['9007199254740993.0.0', '9007199254740992.0.0']]) {
    assert.equal(compareVersions(left, right), compareSemver(left, right));
  }
  assert.equal(compareVersions('1.0.0-01', '1.0.0-1'), null);
});

test('selects exact real GitHub workflow-run, completed job, and merged PR response shapes', () => {
  const run = { id: 88, workflow_id: RELEASE_CONSTANTS.ciWorkflowId, path: RELEASE_CONSTANTS.ciWorkflowPath, head_sha: 'abc', head_branch: 'master', event: 'push', run_attempt: 2 };
  assert.deepEqual(selectAuthoritativeRun([run, { ...run, id: 89, head_sha: 'other' }], 'abc'), run);
  const jobs = [{ name: 'bash-suite (ubuntu-latest)', run_id: 88, run_attempt: 2, status: 'completed', conclusion: 'success' }, { name: 'all-checks-passed', run_id: 88, run_attempt: 2, status: 'completed', conclusion: 'success' }];
  assert.deepEqual(selectAuthoritativeJob(jobs, run), jobs[1]);
  const prs = [{ merged_at: '2026-10-19T00:00:00Z', merge_commit_sha: 'abc', base: { ref: 'master', repo: { full_name: 'owner/repo' } } }];
  assert.deepEqual(selectMergedMasterPr(prs, 'abc', 'owner/repo'), prs[0]);
});

test('rejects wrong workflow/path/SHA, old attempts, duplicate checks, and wrong PR base', () => {
  const run = { id: 88, workflow_id: RELEASE_CONSTANTS.ciWorkflowId, path: RELEASE_CONSTANTS.ciWorkflowPath, head_sha: 'abc', head_branch: 'master', event: 'push', run_attempt: 3 };
  assert.equal(selectAuthoritativeRun([{ ...run, path: '.github/workflows/old.yml' }], 'abc'), null);
  assert.equal(selectAuthoritativeJob([{ name: 'all-checks-passed', run_id: 88, run_attempt: 2, status: 'completed', conclusion: 'success' }], run), null);
  const check = { name: 'all-checks-passed', run_id: 88, run_attempt: 3, status: 'completed', conclusion: 'success' };
  assert.equal(selectAuthoritativeJob([check, check], run), null);
  assert.equal(selectMergedMasterPr([{ merged_at: 'yes', merge_commit_sha: 'abc', base: { ref: 'other', repo: { full_name: 'owner/repo' } } }], 'abc', 'owner/repo'), null);
});

test('exact registry version must be absent by explicit E404; existing immutable versions block eligibility', () => {
  assert.equal(requireUnpublishedVersion('0.8.0', () => ({ present: false, error: 'E404' })), undefined);
  assert.throws(() => requireUnpublishedVersion('0.8.0', () => ({ present: true, value: '0.8.0' })), /already exists.*Never republish/);
  for (const result of [{ present: false, error: 'E403' }, { present: false, error: 'timeout' }, { present: false }]) {
    assert.throws(() => requireUnpublishedVersion('0.8.0', () => result), /not proven by E404/);
  }
});

test('initial prereleases compare against latest until next exists, then use next', () => {
  assert.equal(selectChannelBaseline('next', { latest: '0.7.11' }), '0.7.11');
  assert.equal(selectChannelBaseline('next', { latest: '0.7.11', next: '0.8.0-beta.1' }), '0.8.0-beta.1');
  assert.equal(selectChannelBaseline('latest', { latest: '0.7.11', next: '0.9.0-beta.1' }), '0.7.11');
  assert.equal(selectChannelBaseline('next', {}), null);
});

test('publish phase binds exact artifact to publisher run, separate from CI run', () => {
  const snapshot = base();
  snapshot.phase = 'publish';
  snapshot.publisherRunId = 9001;
  snapshot.publisherRunAttempt = 3;
  snapshot.artifact = { integrity: 'sha512-test', commit: 'abc123', workflowRunId: 9001, workflowRunAttempt: 3 };
  snapshot.prepublishMasterSha = 'abc123';
  snapshot.prepublishRegistryState = 'absent';
  assert.equal(evaluateRelease(snapshot).decision, 'publish');
  snapshot.artifact.workflowRunId = '9001';
  assert.equal(evaluateRelease(snapshot).decision, 'refuse');
  snapshot.artifact.workflowRunId = 9001;
  snapshot.artifact.workflowRunAttempt = 2;
  assert.equal(evaluateRelease(snapshot).decision, 'refuse');
});

test('npm-only release intent permits null skill version and requires only npm changelog', () => {
  const snapshot = base();
  snapshot.release.skillVersion = null;
  snapshot.release.skillChangelog = false;
  assert.equal(evaluateRelease(snapshot).decision, 'eligible');
  snapshot.release.npmChangelog = false;
  assert.equal(evaluateRelease(snapshot).decision, 'refuse');
});
