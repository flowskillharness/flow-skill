import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
import { verifyRegistryChannel, verifyRunArtifact } from '../scripts/release-run-artifact.mjs';
import { reconcile } from '../scripts/release-workflow.mjs';

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

test('rejects untrusted artifact paths before reading any tarball', t => {
  const dir = fixture(t);
  const metadataPath = join(dir, 'release-artifact.json');
  const metadata = JSON.parse(readFileSync(metadataPath, 'utf8'));
  for (const name of ['../outside.tgz', '..\\outside.tgz', '/tmp/outside.tgz', 'sub/package.tgz', '', ' ', '.', '..', null, 42, 'bad\0name']) {
    writeFileSync(metadataPath, JSON.stringify({ ...metadata, name }));
    assert.throws(() => verifyRunArtifact(dir, dir, { runId: 777, runAttempt: 2, version, sha }), /non-empty basename/);
  }
});

test('recovery reads intent and manifest at retained SHA and accepts branch release hints only after tag verification', t => {
  const dir = fixture(t);
  const metadata = JSON.parse(readFileSync(join(dir, 'release-artifact.json'), 'utf8'));
  const validReport = structuredClone(report);
  const validStatement = structuredClone(statement);
  validStatement.subject[0].digest.sha512 = Buffer.from(metadata.integrity.slice(7), 'base64').toString('hex');
  validReport.verified[0].attestationBundles[1].bundle.dsseEnvelope.payload = Buffer.from(JSON.stringify(validStatement)).toString('base64');
  writeFileSync(join(dir, 'npm-audit-verified.json'), JSON.stringify(validReport));
  let skillVersion = '0.25.0'; let releaseTag = 'v0.25.0'; let tagSha = sha;
  const checkedTags = []; const releaseCalls = [];
  const io = {
    readFileSync,
    git: args => {
      if (args[0] === 'show') {
        if (args[1] === `${sha}:npm-wrapper/package.json`) return JSON.stringify({ name: '@manhquy/flow-skill', version });
        assert.equal(args[1], `${sha}:docs/release-intent.json`);
        return JSON.stringify({ schema_version: 1, intent: true, npm_version: version, skill_version: skillVersion });
      }
      if (args[0] === 'rev-parse') { checkedTags.push(args[1]); return tagSha; }
      assert.equal(args[0], 'ls-remote');
      return `${'b'.repeat(40)}\t${args[3]}\n${tagSha}\t${args[4]}`;
    },
    gh: path => { releaseCalls.push(path); return { tag_name: releaseTag, target_commitish: 'master' }; },
    npmView: (_spec, fields) => ({ present: true, value: fields[0] === 'version' ? version : fields[0] === 'dist.integrity' ? metadata.integrity : { latest: version } }),
    verifyWithGhAttestation: options => { assert.equal(options.sourceSha, sha); return []; },
  };
  reconcile(dir, dir, sha, 777, 2, io);
  assert.deepEqual(checkedTags, [`npm@${version}^{commit}`, 'v0.25.0^{commit}']);
  assert.equal(releaseCalls.length, 1);
  releaseTag = 'v9.9.9';
  assert.throws(() => reconcile(dir, dir, sha, 777, 2, io), /Release tag does not match/);
  releaseTag = 'v0.25.0'; tagSha = 'c'.repeat(40);
  assert.throws(() => reconcile(dir, dir, sha, 777, 2, io), /does not resolve exactly/);
  tagSha = sha; skillVersion = null; checkedTags.length = 0; releaseCalls.length = 0;
  reconcile(dir, dir, sha, 777, 2, io);
  assert.deepEqual(checkedTags, [`npm@${version}^{commit}`]);
  assert.equal(releaseCalls.length, 0);
});

test('client rejects registry version, integrity or channel changes after publisher run', () => {
  const valid = { version: '1.0.0', integrity: 'sha512-exact', versionValue: '1.0.0', integrityValue: 'sha512-exact', distTags: { latest: '1.0.0' } };
  assert.equal(verifyRegistryChannel(valid), 'latest');
  assert.throws(() => verifyRegistryChannel({ ...valid, distTags: { latest: '1.0.1' } }), /channel no longer points/);
  assert.throws(() => verifyRegistryChannel({ ...valid, versionValue: '1.0.1' }), /registry version differs/);
  assert.throws(() => verifyRegistryChannel({ ...valid, integrityValue: 'sha512-moved' }), /registry integrity differs/);
});
