import test from 'node:test';
import assert from 'node:assert/strict';
import { assertProvenanceResult } from '../scripts/smoke-policy.mjs';

const packageName = '@manhquy/flow-skill';
const version = '0.8.0';

test('strict smoke policy accepts present provenance metadata', () => {
  assert.equal(assertProvenanceResult(0, '{"predicateType":"https://slsa.dev/provenance/v1"}', packageName, version), true);
});

test('strict smoke policy rejects missing provenance, malformed metadata and failed queries', () => {
  for (const stdout of ['', '  ', 'arbitrary output', '{broken', '{}', '{"attestations":[]}', 'null', '[]', 'true', '"https://slsa.dev/provenance/v1"', '{"predicateType":"https://slsa.dev/provenance/v0.2"}']) {
    assert.throws(() => assertProvenanceResult(0, stdout, packageName, version), /has no SLSA v1 registry provenance metadata/);
  }
  for (const status of [1, null]) {
    assert.throws(() => assertProvenanceResult(status, '{"predicateType":"https://slsa.dev/provenance/v1"}', packageName, version));
  }
});
