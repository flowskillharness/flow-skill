import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { verifyNpmVerifiedOutput } from './release-provenance.mjs';

export function verifyRunArtifact(packageDirectory, evidenceDirectory, { runId, runAttempt, version, sha }) {
  const metadata = JSON.parse(readFileSync(join(packageDirectory, 'release-artifact.json'), 'utf8'));
  const tarball = join(packageDirectory, metadata.name);
  const integrity = `sha512-${createHash('sha512').update(readFileSync(tarball)).digest('base64')}`;
  if (metadata.version !== version || metadata.sha !== sha || metadata.integrity !== integrity || String(metadata.workflowRunId) !== String(runId) || Number(metadata.workflowRunAttempt) !== runAttempt) {
    throw new Error('downloaded publisher artifact does not match exact release SHA/version/run attempt');
  }
  const report = JSON.parse(readFileSync(join(evidenceDirectory, 'npm-audit-verified.json'), 'utf8'));
  const verified = verifyNpmVerifiedOutput(report, {
    packageName: '@manhquy/flow-skill', version, integrity,
    repository: 'https://github.com/manhquydev/flow-skill',
    workflowPath: '.github/workflows/publish-npm-wrapper.yml',
    ref: 'refs/heads/master', commit: sha,
  });
  return { tarball, integrity, verified };
}
