import test from 'node:test';
import assert from 'node:assert/strict';
import { publisherRunIdFromDispatch, publisherWatchArgs, publisherWatchTimeoutError, verifyPublisherJobs } from '../scripts/release-dispatch-response.mjs';

const owner = 'manhquydev';
const repo = 'flow-skill';
const prefix = `https://api.github.com/repos/${owner}/${repo}/actions/runs/`;

test('accepts exact GitHub returned run ID/URLs from a workflow_dispatch response', () => {
  const response = JSON.stringify({ workflow_run_id: 39212657544, run_url: `${prefix}39212657544`, html_url: `https://github.com/${owner}/${repo}/actions/runs/39212657544` });
  assert.equal(publisherRunIdFromDispatch(response, owner, repo), 39212657544);
});

test('no-details 204 and invalid response refuse without guessing a run', () => {
  for (const response of ['', '  ', 'not-json', '{}', '{"workflow_run_id":0,"run_url":""}']) {
    assert.throws(() => publisherRunIdFromDispatch(response, owner, repo));
  }
});

test('rejects mismatched run IDs and URLs outside the expected repository', () => {
  assert.throws(() => publisherRunIdFromDispatch(JSON.stringify({ workflow_run_id: 5, run_url: `${prefix}6` }), owner, repo), /repository-bound run ID/);
  assert.throws(() => publisherRunIdFromDispatch(JSON.stringify({ workflow_run_id: 5, run_url: 'https://api.github.com/repos/other/repo/actions/runs/5' }), owner, repo), /repository-bound run ID/);
});

test('requires exact successful eligibility and mode-appropriate publish job outcome', () => {
  const jobs = (publishConclusion, publishStatus = 'completed') => ({
    total_count: 2,
    jobs: [
      { run_id: 7, run_attempt: 2, name: 'eligibility', status: 'completed', conclusion: 'success' },
      { run_id: 7, run_attempt: 2, name: 'publish', status: publishStatus, conclusion: publishConclusion },
    ],
  });
  assert.equal(verifyPublisherJobs(jobs('success'), 7, 2, false), true);
  assert.equal(verifyPublisherJobs(jobs('skipped'), 7, 2, true), true);
  assert.throws(() => verifyPublisherJobs(jobs('skipped'), 7, 2, false), /conclusion must be success/);
  assert.throws(() => verifyPublisherJobs(jobs('success'), 7, 2, true), /conclusion must be skipped/);
  assert.throws(() => verifyPublisherJobs({ total_count: 3, jobs: jobs('success').jobs }, 7, 2, false), /incomplete/);
  assert.throws(() => verifyPublisherJobs({ total_count: 2, jobs: jobs('success').jobs.map(job => ({ ...job, run_attempt: 1 })) }, 7, 2, false), /eligibility job/);
});

test('publisher watch is exact-run and timeout fails closed before tags', () => {
  assert.deepEqual(publisherWatchArgs(777), ['run', 'watch', '777', '--exit-status']);
  const timedOut = Object.assign(new Error('timed out'), { code: 'ETIMEDOUT' });
  assert.match(publisherWatchTimeoutError(timedOut, '777', 45, true).message, /45-minute watch limit.*publication may have completed and cancel was requested/);
  assert.match(publisherWatchTimeoutError(timedOut, '777', 45, false).message, /cancellation failed/);
  const sigterm = Object.assign(new Error('watch terminated'), { killed: true, signal: 'SIGTERM' });
  assert.match(publisherWatchTimeoutError(sigterm, '777', 45, true).message, /45-minute watch limit/);
  const failed = Object.assign(new Error('bad credentials'), { code: 'E401' });
  assert.equal(publisherWatchTimeoutError(failed, '777'), failed);
});
