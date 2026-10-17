// Pure standard-library semver helper for scripts and test harnesses.
// Zero external dependencies.
//
// Minimum version introducing the transactional ownership receipt (manifest-hashes.json)
// and the explicit/autodetected OMP install target (commit 5474907): 0.7.8.
export const RECEIPT_OMP_MIN_VERSION = '0.7.8';

/**
 * Parse a strict SemVer 2.0.0 string with optional leading 'v'.
 * @param {string} v
 * @returns {{ major: number, minor: number, patch: number, prerelease: string[] | null, build: string[] | null } | null}
 */
const SEMVER_RE =
  /^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/;

export function parseSemver(v) {
  if (typeof v !== 'string') return null;
  const match = v.trim().match(SEMVER_RE);
  if (!match) return null;
  const major = parseInt(match[1], 10);
  const minor = parseInt(match[2], 10);
  const patch = parseInt(match[3], 10);

  let prerelease = null;
  if (match[4] !== undefined) {
    prerelease = match[4].split('.');
    for (const id of prerelease) {
      // Numeric prerelease identifiers MUST NOT include leading zeroes (e.g. '01' is invalid, '0' is valid).
      if (/^\d+$/.test(id) && !/^(0|[1-9]\d*)$/.test(id)) {
        return null;
      }
    }
  }

  const build = match[5] !== undefined ? match[5].split('.') : null;
  return { major, minor, patch, prerelease, build };
}

/**
 * Compare two SemVer strings or parsed descriptors per SemVer 2.0.0 precedence rules.
 * Returns -1 if a < b, 0 if a == b, 1 if a > b.
 * Note: build metadata is ignored for precedence.
 *
 * @param {string | object} a
 * @param {string | object} b
 * @returns {number}
 */
export function compareSemver(a, b) {
  const pa = typeof a === 'string' ? parseSemver(a) : a;
  const pb = typeof b === 'string' ? parseSemver(b) : b;
  if (!pa || !pb) throw new Error(`Invalid semver: ${!pa ? a : b}`);

  if (pa.major !== pb.major) return pa.major > pb.major ? 1 : -1;
  if (pa.minor !== pb.minor) return pa.minor > pb.minor ? 1 : -1;
  if (pa.patch !== pb.patch) return pa.patch > pb.patch ? 1 : -1;

  // When major, minor, patch are equal:
  // A normal version has greater precedence than a pre-release version.
  if (pa.prerelease === null && pb.prerelease === null) return 0;
  if (pa.prerelease === null && pb.prerelease !== null) return 1;
  if (pa.prerelease !== null && pb.prerelease === null) return -1;

  // Both have pre-release tags: compare identifier by identifier.
  const len = Math.max(pa.prerelease.length, pb.prerelease.length);
  for (let i = 0; i < len; i++) {
    const idA = pa.prerelease[i];
    const idB = pb.prerelease[i];
    if (idA === undefined) return -1; // smaller set has lower precedence
    if (idB === undefined) return 1;
    if (idA === idB) continue;

    const numA = /^\d+$/.test(idA) ? parseInt(idA, 10) : null;
    const numB = /^\d+$/.test(idB) ? parseInt(idB, 10) : null;

    if (numA !== null && numB !== null) {
      return numA > numB ? 1 : -1;
    }
    // Numeric identifiers always have lower precedence than non-numeric identifiers.
    if (numA !== null && numB === null) return -1;
    if (numA === null && numB !== null) return 1;

    // Lexical ASCII comparison.
    return idA > idB ? 1 : -1;
  }
  return 0;
}

/**
 * Returns true if the package version supports transactional ownership receipt
 * (`manifest-hashes.json`) and the OMP install target.
 *
 * Rules:
 * - Stable 0.7.8 and later versions return true.
 * - 0.7.8 prereleases (e.g. 0.7.8-alpha, 0.7.8-rc.1) must not be assumed to support it (returns false).
 * - 0.7.9 prereleases (e.g. 0.7.9-next.0) and later prereleases do support it (returns true).
 * - Older versions (< 0.7.8, including 0.7.1-next.0) return false.
 *
 * @param {string} version
 * @returns {boolean}
 */
export function supportsReceiptAndOmp(version) {
  const parsed = parseSemver(version);
  if (!parsed) return false;
  return compareSemver(parsed, RECEIPT_OMP_MIN_VERSION) >= 0;
}
