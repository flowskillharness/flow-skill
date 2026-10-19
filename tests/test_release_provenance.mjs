import test from 'node:test';
import assert from 'node:assert/strict';
import { verifyNpmVerifiedOutput } from '../scripts/release-provenance.mjs';
import { verifyTargetAuditOutput, npmAttestationUrl } from '../scripts/npm-attestation-audit.mjs';

const expected = { packageName: '@manhquy/flow-skill', version: '0.7.11', integrity: 'sha512-fD3SNLE/ghyfA9SNbxiQfkIfpcTAcrDuPRdgNl942S2WcQfYmS7lbtz6Uj5HbVuzYEqIyhaK24xWvep2CVwS7g==', repository: 'https://github.com/manhquydev/flow-skill', workflowPath: '.github/workflows/publish-npm-wrapper.yml', ref: 'refs/tags/npm@0.7.11', commit: 'e69171c115a0cb120331e489a39c3298711f4204' };
const digest = Buffer.from(expected.integrity.slice('sha512-'.length), 'base64').toString('hex');
const statement = { predicateType: 'https://slsa.dev/provenance/v1', subject: [{ name: 'pkg:npm/%40manhquy/flow-skill@0.7.11', digest: { sha512: digest } }], predicate: { buildDefinition: { externalParameters: { workflow: { repository: expected.repository, path: expected.workflowPath, ref: expected.ref } }, resolvedDependencies: [{ digest: { gitCommit: expected.commit } }] } } };
const report = { invalid: [], missing: [], verified: [{ name: expected.packageName, version: expected.version, registry: 'https://registry.npmjs.org/', attestationBundles: [{ predicateType: 'https://github.com/npm/attestation/tree/main/specs/publish/v0.1', bundle: { dsseEnvelope: { payloadType: 'application/vnd.in-toto+json', payload: Buffer.from(JSON.stringify({ predicateType: 'https://github.com/npm/attestation/tree/main/specs/publish/v0.1' })).toString('base64'), signatures: [{ sig: 'npm-verified-signature' }] } } }, { predicateType: 'https://slsa.dev/provenance/v1', bundle: { dsseEnvelope: { payloadType: 'application/vnd.in-toto+json', payload: Buffer.from(JSON.stringify(statement)).toString('base64'), signatures: [{ sig: 'npm-verified-signature' }] } } }] }] };

test('checks source and digest policy after npm signature verification', () => {
  assert.equal(verifyNpmVerifiedOutput(report, expected).commit, expected.commit);
  assert.equal(verifyTargetAuditOutput(report, expected).workflowPath, expected.workflowPath);
});

test('rejects invalid/missing signatures and every source/digest mismatch', () => {
  for (const field of ['repo', 'workflow', 'ref', 'commit', 'digest']) {
    const bad = structuredClone(report);
    const payload = JSON.parse(Buffer.from(bad.verified[0].attestationBundles[1].bundle.dsseEnvelope.payload, 'base64'));
    if (field === 'repo') payload.predicate.buildDefinition.externalParameters.workflow.repository = 'https://github.com/evil/repo';
    if (field === 'workflow') payload.predicate.buildDefinition.externalParameters.workflow.path = '.github/workflows/other.yml';
    if (field === 'ref') payload.predicate.buildDefinition.externalParameters.workflow.ref = 'refs/heads/other';
    if (field === 'commit') payload.predicate.buildDefinition.resolvedDependencies[0].digest.gitCommit = '1111111111111111111111111111111111111111';
    if (field === 'digest') payload.subject[0].digest.sha512 = '00'.repeat(64);
    bad.verified[0].attestationBundles[1].bundle.dsseEnvelope.payload = Buffer.from(JSON.stringify(payload)).toString('base64');
    if (field === 'repo' || field === 'workflow' || field === 'ref' || field === 'commit' || field === 'digest') assert.throws(() => verifyNpmVerifiedOutput(bad, expected));
  }
  const badSignatureReport = structuredClone(report); badSignatureReport.invalid.push({ name: expected.packageName });
  assert.throws(() => verifyNpmVerifiedOutput(badSignatureReport, expected), /invalid or missing/);
});

test('scoped npm attestation URL keeps scope marker literal and encodes separator once', () => {
  assert.equal(npmAttestationUrl('@manhquy/flow-skill', '0.8.0'), 'https://registry.npmjs.org/-/npm/v1/attestations/@manhquy%2fflow-skill@0.8.0');
  assert.equal(npmAttestationUrl('left-pad', '1.3.0'), 'https://registry.npmjs.org/-/npm/v1/attestations/left-pad@1.3.0');
});

