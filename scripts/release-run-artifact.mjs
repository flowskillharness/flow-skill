import { verifyNpmVerifiedOutput } from './release-provenance.mjs';
import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { parseSemver } from '../npm-wrapper/scripts/semver.mjs';

export function artifactTarballPath(packageDirectory, name) {
  if (typeof name !== 'string' || !name.trim() || name === '.' || name === '..' || /[/\\\0]/.test(name)) throw new Error('artifact name must be a non-empty basename');
  return join(packageDirectory, name);
}

export function verifyRunArtifact(packageDirectory, evidenceDirectory, { runId, runAttempt, version, sha }) {
  const metadata = JSON.parse(readFileSync(join(packageDirectory, 'release-artifact.json'), 'utf8'));
  const tarball = artifactTarballPath(packageDirectory, metadata.name);
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

export function verifyRegistryChannel({ version, integrity, versionValue, integrityValue, distTags }) {
  const channel = parseSemver(version)?.prerelease ? 'next' : 'latest';
  if (versionValue !== version) throw new Error('current registry version differs from the retained release version');
  if (integrityValue !== integrity) throw new Error('current registry integrity differs from the retained artifact');
  if (!distTags || typeof distTags !== 'object' || distTags[channel] !== version) throw new Error(`current registry ${channel} channel no longer points to the retained release version`);
  return channel;
}
