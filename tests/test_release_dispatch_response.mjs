import test from 'node:test';
import assert from 'node:assert/strict';
import { publisherRunIdFromDispatch, publisherWatchArgs, publisherWatchTimeoutError, verifyPublisherJobs } from '../scripts/release-dispatch-response.mjs';
import { readFileSync, mkdtempSync, mkdirSync, rmSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import vm from 'node:vm';
import { assertGhAttestationCapability } from '../scripts/verify-attestation-with-gh.mjs';

const clientUrl = new URL('../scripts/sync-release.mjs', import.meta.url);
const clientSource = readFileSync(clientUrl, 'utf8');
function clientFunction(name, nextName, globals) {
  const start = clientSource.indexOf(`function ${name}(`);
  const end = clientSource.indexOf(`\nfunction ${nextName}(`, start);
  assert.ok(start >= 0 && end > start);
  return vm.runInNewContext(`${clientSource.slice(start, end)}\n${name}`, globals);
}

test('CLI realpath fallback tolerates an absent caller path when imported', () => {
  const result = spawnSync(process.execPath, ['--input-type=module', '-e', `process.argv[1] = '/nonexistent/flow-client-entry.mjs'; await import(${JSON.stringify(clientUrl.href)});`], { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
});

test('retained artifact directories use Node filesystem without an external mkdir', () => {
  const stop = new Error('stop before verification');
  let downloads = 0;
  const verify = clientFunction('verifyPublishedRun', 'npmViewJson', {
    mkdtempSync, mkdirSync, rmSync, join, tmpdir, repoRoot: '/fixture',
    execFileSync() { assert.fail('no external command before downloads'); },
    execGh(args) {
      assert.equal(args[0], 'run');
      const directory = args[args.indexOf('--dir') + 1];
      assert.ok(existsSync(directory));
      downloads++;
      if (downloads === 2) throw stop;
    },
  });
  assert.throws(() => verify(7, 1, '1.0.0', 'a'.repeat(40)), error => error === stop);
  assert.equal(downloads, 2);
});

test('reconcile delegates its bounded retry budget without a shorter outer timeout', () => {
  let invocation;
  const main = clientFunction('main', 'isCliEntry', {
    process: { argv: ['node', 'client', '--reconcile', 'package', 'evidence', 'a'.repeat(40), '7', '2'], execPath: process.execPath, env: {} },
    join, repoRoot: '/fixture',
    execFileSync(...args) { invocation = args; },
  });
  main();
  assert.equal(invocation[1][1], 'reconcile');
  assert.equal(invocation[2].timeout, undefined);
  assert.equal(invocation[2].env.EXPECTED_RUN_ID, '7');
  assert.equal(invocation[2].env.EXPECTED_RUN_ATTEMPT, '2');
});

test('live and dry-run dispatch both fail closed on old or incomplete gh before API calls', () => {
  const options = ['--bundle', '--digest-alg', '--repo', '--signer-workflow', '--source-ref', '--source-digest'];
  for (const dryRun of [false, true]) {
    for (const missing of ['old-version', ...options]) {
      const calls = [];
      const dispatch = clientFunction('dispatchPublisher', 'checkSyncNonDrift', {
        getRepoCoordinates: () => ({ ok: true, owner, repo }), repoRoot: '/fixture', assertGhAttestationCapability,
        execGh(args) {
          calls.push(args);
          if (args[0] === '--version') return missing === 'old-version' ? 'gh version 2.46.0' : 'gh version 2.68.0';
          if (args[0] === 'attestation') return options.filter(option => option !== missing).join(' ');
          assert.fail('no API calls with an incapable verifier');
        },
      });
      assert.throws(() => dispatch('a'.repeat(40), '1.0.0', dryRun), /controller must provision a project-local portable gh/);
      assert.equal(calls.some(args => args[0] === 'api'), false);
    }
  }
  const calls = [];
  assertGhAttestationCapability({ run(args) { calls.push(args); return args[0] === '--version' ? 'gh version 2.68.0' : options.join(' '); } });
  assert.equal(calls.length, 2);
});

test('live confirmation honors intent:false without release commands', () => {
  const messages = [];
  const ship = clientFunction('shipRelease', 'main', {
    readFileSync: () => JSON.stringify({ intent: false }),
    join, repoRoot: '/fixture', console: { log: message => messages.push(message) },
  });
  ship({ isYes: true });
  assert.match(messages.join('\n'), /NO-OP: release intent is false/);
});

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
  for (const suffix of ['15', '5/5', '05', '5?run=5', '5#5', '5/']) {
    assert.throws(() => publisherRunIdFromDispatch(JSON.stringify({ workflow_run_id: 5, run_url: `${prefix}${suffix}` }), owner, repo), /repository-bound run ID/);
  }
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
