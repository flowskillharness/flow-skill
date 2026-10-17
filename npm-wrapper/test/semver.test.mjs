import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  parseSemver,
  compareSemver,
  supportsReceiptAndOmp,
  RECEIPT_OMP_MIN_VERSION,
} from '../scripts/semver.mjs';

test('parseSemver parses standard SemVer 2.0.0 strings correctly', () => {
  assert.deepEqual(parseSemver('0.7.8'), {
    major: 0,
    minor: 7,
    patch: 8,
    prerelease: null,
    build: null,
  });

  assert.deepEqual(parseSemver('0.7.1-next.0'), {
    major: 0,
    minor: 7,
    patch: 1,
    prerelease: ['next', '0'],
    build: null,
  });

  assert.deepEqual(parseSemver('v1.2.3-rc.1+build.42'), {
    major: 1,
    minor: 2,
    patch: 3,
    prerelease: ['rc', '1'],
    build: ['build', '42'],
  });

  assert.equal(parseSemver(''), null);
  assert.equal(parseSemver(null), null);
  assert.equal(parseSemver(undefined), null);
  assert.equal(parseSemver('not-a-version'), null);
  assert.equal(parseSemver('1.2'), null);
  assert.equal(parseSemver('1.2.3.4'), null);
});

test('compareSemver respects major, minor, and patch precedence', () => {
  assert.equal(compareSemver('1.0.0', '0.9.9'), 1);
  assert.equal(compareSemver('0.9.9', '1.0.0'), -1);
  assert.equal(compareSemver('0.8.0', '0.7.9'), 1);
  assert.equal(compareSemver('0.7.9', '0.8.0'), -1);
  assert.equal(compareSemver('0.7.8', '0.7.7'), 1);
  assert.equal(compareSemver('0.7.7', '0.7.8'), -1);
  assert.equal(compareSemver('0.7.8', '0.7.8'), 0);
});

test('compareSemver gives normal versions higher precedence than prereleases of the same tuple', () => {
  assert.equal(compareSemver('0.7.8', '0.7.8-rc.1'), 1);
  assert.equal(compareSemver('0.7.8-rc.1', '0.7.8'), -1);
  assert.equal(compareSemver('0.7.8', '0.7.8-alpha'), 1);
  assert.equal(compareSemver('0.7.8-0', '0.7.8'), -1);
});

test('compareSemver compares prerelease identifiers per SemVer 2.0.0', () => {
  assert.equal(compareSemver('0.7.8-alpha', '0.7.8-beta'), -1);
  assert.equal(compareSemver('0.7.8-alpha.1', '0.7.8-alpha.2'), -1);
  assert.equal(compareSemver('0.7.8-1', '0.7.8-alpha'), -1); // numeric < non-numeric
  assert.equal(compareSemver('0.7.8-alpha', '0.7.8-alpha.1'), -1); // shorter set < longer set
  assert.equal(compareSemver('0.7.8-rc.1', '0.7.8-rc.1'), 0);
});

test('compareSemver ignores build metadata for precedence', () => {
  assert.equal(compareSemver('0.7.8+exp.sha.5114f85', '0.7.8'), 0);
  assert.equal(compareSemver('0.7.8-rc.1+123', '0.7.8-rc.1+456'), 0);
});

test('RECEIPT_OMP_MIN_VERSION constant is 0.7.8', () => {
  assert.equal(RECEIPT_OMP_MIN_VERSION, '0.7.8');
});

test('supportsReceiptAndOmp: stable threshold boundary at 0.7.8', () => {
  assert.equal(supportsReceiptAndOmp('0.7.8'), true);
  assert.equal(supportsReceiptAndOmp('0.7.7'), false);
  assert.equal(supportsReceiptAndOmp('0.7.0'), false);
  assert.equal(supportsReceiptAndOmp('0.6.9'), false);
  assert.equal(supportsReceiptAndOmp('0.1.0'), false);
  assert.equal(supportsReceiptAndOmp('0.7.1-next.0'), false);
});

test('supportsReceiptAndOmp: 0.7.8 prereleases must NOT be assumed to support receipt/OMP', () => {
  assert.equal(supportsReceiptAndOmp('0.7.8-0'), false);
  assert.equal(supportsReceiptAndOmp('0.7.8-alpha'), false);
  assert.equal(supportsReceiptAndOmp('0.7.8-alpha.1'), false);
  assert.equal(supportsReceiptAndOmp('0.7.8-beta'), false);
  assert.equal(supportsReceiptAndOmp('0.7.8-rc.1'), false);
  assert.equal(supportsReceiptAndOmp('0.7.8-next.0'), false);
  assert.equal(supportsReceiptAndOmp('0.7.8-rc.1+build123'), false);
});

test('supportsReceiptAndOmp: 0.7.9 prereleases DO support receipt/OMP', () => {
  assert.equal(supportsReceiptAndOmp('0.7.9-0'), true);
  assert.equal(supportsReceiptAndOmp('0.7.9-alpha'), true);
  assert.equal(supportsReceiptAndOmp('0.7.9-rc.1'), true);
  assert.equal(supportsReceiptAndOmp('0.7.9-next.0'), true);
  assert.equal(supportsReceiptAndOmp('0.7.9-next.1'), true);
  assert.equal(supportsReceiptAndOmp('0.7.9'), true);
});

test('supportsReceiptAndOmp: subsequent versions and prereleases support receipt/OMP', () => {
  assert.equal(supportsReceiptAndOmp('0.8.0-alpha.0'), true);
  assert.equal(supportsReceiptAndOmp('0.8.0'), true);
  assert.equal(supportsReceiptAndOmp('0.8.1'), true);
  assert.equal(supportsReceiptAndOmp('0.10.0'), true);
  assert.equal(supportsReceiptAndOmp('1.0.0-alpha'), true);
  assert.equal(supportsReceiptAndOmp('1.0.0'), true);
  assert.equal(supportsReceiptAndOmp('2.1.3'), true);
});

test('supportsReceiptAndOmp: build metadata behavior is ignored for precedence', () => {
  assert.equal(supportsReceiptAndOmp('0.7.8+build.1'), true);
  assert.equal(supportsReceiptAndOmp('0.7.8+sha.abcdef'), true);
  assert.equal(supportsReceiptAndOmp('0.7.8-alpha.1+build.1'), false);
  assert.equal(supportsReceiptAndOmp('0.7.7+build.1'), false);
  assert.equal(supportsReceiptAndOmp('0.8.0+build.999'), true);
});

test('supportsReceiptAndOmp: invalid and non-semver inputs return false', () => {
  assert.equal(supportsReceiptAndOmp(''), false);
  assert.equal(supportsReceiptAndOmp(null), false);
  assert.equal(supportsReceiptAndOmp(undefined), false);
  assert.equal(supportsReceiptAndOmp('latest'), false);
  assert.equal(supportsReceiptAndOmp('next'), false);
  assert.equal(supportsReceiptAndOmp('invalid.version'), false);
});
