import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import { mkdtempSync, rmSync, readdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { execFileSync } from 'node:child_process';
import { parseSemver } from '../npm-wrapper/scripts/semver.mjs';
import { verifyNpmVerifiedOutput } from './release-provenance.mjs';

const PACKAGE = '@manhquy/flow-skill';
const NPM_VERSION = '11.21.0';
const SLSA_V1 = 'https://slsa.dev/provenance/v1';

export function extractVerifiedSlsaBundle(report, packageName, version) {
  const matches = (report?.verified || []).filter(item => item.name === packageName && item.version === version && item.registry?.replace(/\/$/, '') === 'https://registry.npmjs.org');
  if (matches.length !== 1) throw new Error(`npm audit signatures did not verify exactly one ${packageName}@${version}`);
  const slsa = (matches[0].attestationBundles || []).filter(item => item.predicateType === SLSA_V1 && item.bundle?.dsseEnvelope);
  if (slsa.length !== 1) throw new Error('expected exactly one npm-verified SLSA provenance bundle');
  return slsa[0].bundle;
}

export function verifyTargetAuditOutput(report, expected) {
  return verifyNpmVerifiedOutput(report, expected);
}

function auditOnce({ packageName, version, integrity, repository, workflowPath, ref, commit, bundlePath }) {
  const root = mkdtempSync(join(tmpdir(), 'flow-npm-attest-'));
  const cliRoot = mkdtempSync(join(tmpdir(), 'flow-npm-cli-'));
  try {
    const metadata = JSON.parse(execFileSync('npm', ['view', `${packageName}@${version}`, '--json'], { encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 }));
    if (metadata.name !== packageName || metadata.version !== version || metadata.dist?.integrity !== integrity) throw new Error('target package registry identity/integrity mismatch');
    execFileSync('npm', ['init', '-y'], { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    execFileSync('npm', ['install', '--prefix', root, '--ignore-scripts', '--no-audit', '--no-fund', `${packageName}@${version}`], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    execFileSync('npm', ['install', '--prefix', cliRoot, '--no-save', '--no-audit', '--no-fund', `npm@${NPM_VERSION}`], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    const npmPath = join(cliRoot, 'node_modules', '.bin', 'npm');
    const npmVersion = execFileSync(npmPath, ['--version'], { encoding: 'utf8' }).trim();
    const parsedNpm = parseSemver(npmVersion);
    if (!parsedNpm || parsedNpm.major !== 11 || parsedNpm.minor !== 21 || parsedNpm.patch !== 0) throw new Error(`verified npm audit CLI must be exactly ${NPM_VERSION}; found ${npmVersion}`);
    for (const entry of readdirSync(join(root, 'node_modules'))) {
      if (entry === packageName.split('/')[0] || entry === '.bin' || entry === '.package-lock.json') continue;
      rmSync(join(root, 'node_modules', entry), { recursive: true, force: true });
    }
    const report = JSON.parse(execFileSync(npmPath, ['audit', 'signatures', '--json', '--include-attestations'], { cwd: root, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 }));
    const verified = verifyTargetAuditOutput(report, { packageName, version, integrity, repository, workflowPath, ref, commit });
    const bundle = extractVerifiedSlsaBundle(report, packageName, version);
    if (bundlePath) writeFileSync(bundlePath, JSON.stringify(bundle));
    return { verified, report };
  } finally {
    rmSync(root, { recursive: true, force: true });
    rmSync(cliRoot, { recursive: true, force: true });
  }
}

function retryable(error) {
  const text = `${error.code || ''} ${error.stderr || ''} ${error.message || ''}`;
  return /E404|E429|HTTP 404|HTTP 429|HTTP 500|HTTP 502|HTTP 503|HTTP 504/.test(text);
}

export function npmAttestationUrl(packageName, version) {
  const packageRef = packageName.startsWith('@')
    ? `@${encodeURIComponent(packageName.slice(1)).replace(/%2F/gi, '%2f')}`
    : encodeURIComponent(packageName);
  return `https://registry.npmjs.org/-/npm/v1/attestations/${packageRef}@${version}`;
}
export function waitForSlsaBundle({ packageName, version }) {
  const url = npmAttestationUrl(packageName, version);
  const waits = [0, 15000, 15000, 15000, 15000, 15000, 15000, 15000, 15000];
  let lastStatus = 0;
  for (const delay of waits) {
    if (delay) Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, delay);
    const result = execFileSync('curl', ['-sS', '-L', '--max-time', '15', '-H', 'Accept: application/json', '-H', 'Cache-Control: no-cache', '-w', '\n%{http_code}', url], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    const match = result.match(/\n(\d{3})$/);
    if (!match) throw new Error('npm attestation endpoint returned no HTTP status');
    lastStatus = Number(match[1]);
    const bodyText = result.slice(0, match.index);
    if (lastStatus === 200) {
      let body;
      try { body = JSON.parse(bodyText); } catch { throw new Error('npm attestation endpoint returned invalid JSON'); }
      if (body.attestations?.some(item => item.predicateType === SLSA_V1 && item.bundle)) return;
    } else if (![404, 429, 500, 502, 503, 504].includes(lastStatus)) throw new Error(`npm attestation endpoint failed non-retryably: HTTP ${lastStatus}`);
  }
  throw new Error(`npm SLSA attestation not available after bounded propagation retries (last HTTP ${lastStatus})`);
}

export function runTargetAudit(options) {
  const delays = [0, 15000, 15000, 15000, 15000, 15000, 15000, 15000, 15000];
  let lastError;
  for (let attempt = 0; attempt < delays.length; attempt += 1) {
    if (delays[attempt]) Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, delays[attempt]);
    try {
      waitForSlsaBundle({ packageName: options.packageName, version: options.version });
      const result = auditOnce(options);
      if (options.reportPath) writeFileSync(options.reportPath, JSON.stringify(result.report));
      return result;
    } catch (error) {
      lastError = error;
      if (!retryable(error) || attempt === delays.length - 1) throw error;
    }
  }
  throw lastError || new Error('target provenance verification exhausted its retry window');
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const [version, metadataPath, expectedSha, bundlePath, sourceRef = 'refs/heads/master', reportPath] = process.argv.slice(2);
  try {
    const metadata = JSON.parse((await import('node:fs')).readFileSync(metadataPath, 'utf8'));
    console.log(JSON.stringify(runTargetAudit({ packageName: PACKAGE, version, integrity: metadata.integrity, repository: 'https://github.com/manhquydev/flow-skill', workflowPath: '.github/workflows/publish-npm-wrapper.yml', ref: sourceRef, commit: expectedSha, bundlePath, reportPath }), null, 2));
  } catch (error) {
    console.error(`FAIL: ${error.message}`);
    process.exitCode = 1;
  }
}
