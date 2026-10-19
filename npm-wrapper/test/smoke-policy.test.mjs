import test from 'node:test';
import assert from 'node:assert/strict';
import { assertProvenanceResult } from '../scripts/smoke-policy.mjs';

const packageName = '@manhquy/flow-skill';
const version = '0.8.0';

test('strict smoke policy accepts present provenance metadata', () => {
  assert.equal(assertProvenanceResult(0, '{"predicateType":"https://slsa.dev/provenance/v1"}', packageName, version), true);
});

test('strict smoke policy rejects missing provenance and failed registry queries', () => {
  for (const [status, stdout] of [[0, ''], [0, '  '], [0, '{"attestations":[]}'], [0, 'not-json'], [1, ''], [1, 'not found']]) {
    assert.throws(() => assertProvenanceResult(status, stdout, packageName, version), /has no SLSA v1 registry provenance metadata/);
  }
});
