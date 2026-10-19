import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
import { verifyRunArtifact } from '../scripts/release-run-artifact.mjs';

const sha = 'a'.repeat(40);
const version = '0.7.11';
const integrity = 'sha512-fD3SNLE/ghyfA9SNbxiQfkIfpcTAcrDuPRdgNl942S2WcQfYmS7lbtz6Uj5HbVuzYEqIyhaK24xWvep2CVwS7g==';
const digest = Buffer.from(integrity.slice('sha512-'.length), 'base64').toString('hex');
const statement = {
  predicateType: 'https://slsa.dev/provenance/v1',
  subject: [{ name: `pkg:npm/%40manhquy/flow-skill@${version}`, digest: { sha512: digest } }],
  predicate: { buildDefinition: {
    externalParameters: { workflow: { repository: 'https://github.com/manhquydev/flow-skill', path: '.github/workflows/publish-npm-wrapper.yml', ref: 'refs/heads/master' } },
    resolvedDependencies: [{ digest: { gitCommit: sha } }],
  } },
};
const report = { invalid: [], missing: [], verified: [{ name: '@manhquy/flow-skill', version, registry: 'https://registry.npmjs.org/', attestationBundles: [
  { predicateType: 'https://github.com/npm/attestation/tree/main/specs/publish/v0.1', bundle: { dsseEnvelope: { payloadType: 'application/vnd.in-toto+json', payload: Buffer.from(JSON.stringify({ predicateType: 'https://github.com/npm/attestation/tree/main/specs/publish/v0.1' })).toString('base64'), signatures: [{ sig: 'npm-signature' }] } } },
  { predicateType: 'https://slsa.dev/provenance/v1', bundle: { dsseEnvelope: { payloadType: 'application/vnd.in-toto+json', payload: Buffer.from(JSON.stringify(statement)).toString('base64'), signatures: [{ sig: 'npm-signature' }] } } },
]}] };

function fixture(t) {
  const dir = mkdtempSync(join(tmpdir(), 'flow-run-artifact-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const bytes = Buffer.from('exact published package bytes');
  const name = 'manhquy-flow-skill-0.7.11.tgz';
  const actualIntegrity = `sha512-${createHash('sha512').update(bytes).digest('base64')}`;
  writeFileSync(join(dir, name), bytes);
  writeFileSync(join(dir, 'release-artifact.json'), JSON.stringify({ name, version, sha, integrity: actualIntegrity, workflowRunId: '777', workflowRunAttempt: 2 }));
  writeFileSync(join(dir, 'npm-audit-verified.json'), JSON.stringify(report));
  return dir;
}

test('verifies exact run artifact and target-only npm evidence', t => {
  const dir = fixture(t);
  const metadata = JSON.parse(readFileSync(join(dir, 'release-artifact.json'), 'utf8'));
  const actual = `sha512-${createHash('sha512').update(readFileSync(join(dir, metadata.name))).digest('base64')}`;
  const validStatement = structuredClone(statement);
  validStatement.subject[0].digest.sha512 = Buffer.from(actual.slice('sha512-'.length), 'base64').toString('hex');
  const validReport = structuredClone(report);
  validReport.verified[0].attestationBundles[1].bundle.dsseEnvelope.payload = Buffer.from(JSON.stringify(validStatement)).toString('base64');
  writeFileSync(join(dir, 'npm-audit-verified.json'), JSON.stringify(validReport));
  assert.equal(verifyRunArtifact(dir, dir, { runId: 777, runAttempt: 2, version, sha }).integrity, actual);
});

test('rejects mismatched publisher attempt and source evidence', t => {
  const dir = fixture(t);
  assert.throws(() => verifyRunArtifact(dir, dir, { runId: 777, runAttempt: 1, version, sha }), /run attempt/);
  const invalidReport = structuredClone(report);
  invalidReport.invalid.push({ name: '@manhquy/flow-skill' });
  writeFileSync(join(dir, 'npm-audit-verified.json'), JSON.stringify(invalidReport));
  assert.throws(() => verifyRunArtifact(dir, dir, { runId: 777, runAttempt: 2, version, sha }), /invalid or missing/);
});
