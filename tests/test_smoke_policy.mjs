import test from 'node:test';
import assert from 'node:assert/strict';
import { assertProvenanceResult } from '../npm-wrapper/scripts/smoke-policy.mjs';

const provenance = JSON.stringify({ predicateType: 'https://slsa.dev/provenance/v1' });
test('requires successful JSON registry metadata declaring SLSA v1', () => {
  assert.equal(assertProvenanceResult(0, provenance, '@manhquy/flow-skill', '1.0.0'), true);
  for (const output of ['', ' ', 'arbitrary output', '{broken', '{}', '{"attestations":[]}', 'null', '[]', 'true', '"https://slsa.dev/provenance/v1"', '{"predicateType":"https://slsa.dev/provenance/v0.2"}']) {
    assert.throws(() => assertProvenanceResult(0, output, '@manhquy/flow-skill', '1.0.0'), /no SLSA v1 registry provenance metadata/);
  }
  for (const status of [1, null]) {
    assert.throws(() => assertProvenanceResult(status, provenance, '@manhquy/flow-skill', '1.0.0'));
  }
});
