#!/usr/bin/env node
/**
 * scripts/sync-release.mjs
 *
 * Unified release synchronization & coherence tool for flow-skill.
 *
 * Inspects and validates dual-axis release coherence across skill and npm channels,
 * synchronizes documentation tables, re-materializes bundled assets, and prints
 * exact release/tag commands.
 *
 * Usage:
 *   node scripts/sync-release.mjs [--check]
 *   node scripts/sync-release.mjs --sync
 */

import { readFileSync, writeFileSync, existsSync, readdirSync, statSync, mkdirSync, rmSync } from 'node:fs';
import { resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, '..');

// Directories whose transient churn (VCS metadata, installed dependencies) is never
// part of the zero-mutation guarantee enforced for --dry-run.
const ZERO_MUTATION_EXCLUDED_DIRS = new Set(['.git', 'node_modules']);

function snapshotTree(root) {
  const map = new Map();
  (function walk(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        if (ZERO_MUTATION_EXCLUDED_DIRS.has(entry.name)) continue;
        walk(join(dir, entry.name));
      } else if (entry.isFile()) {
        map.set(join(dir, entry.name), readFileSync(join(dir, entry.name)));
      }
    }
  })(root);
  return map;
}

function restoreTree(root, snapshot) {
  let restored = 0;
  const seen = new Set();
  (function walk(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        if (ZERO_MUTATION_EXCLUDED_DIRS.has(entry.name)) continue;
        walk(join(dir, entry.name));
      } else if (entry.isFile()) {
        const p = join(dir, entry.name);
        seen.add(p);
        const original = snapshot.get(p);
        if (original === undefined) {
          rmSync(p); // file created during the dry-run
          restored += 1;
        } else if (!original.equals(readFileSync(p))) {
          writeFileSync(p, original); // file modified during the dry-run
          restored += 1;
        }
      }
    }
  })(root);
  for (const [p, content] of snapshot) {
    if (!seen.has(p)) {
      mkdirSync(dirname(p), { recursive: true }); // file deleted during the dry-run
      writeFileSync(p, content);
      restored += 1;
    }
  }
  return restored;
}

function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function getSkillVersion() {
  const p = join(repoRoot, 'skills', 'flow', 'SKILL.md');
  if (!existsSync(p)) return null;
  const content = readFileSync(p, 'utf8');
  const m = content.match(/^[ \t]*version:[ \t]*"?([0-9][.0-9A-Za-z-]*)"?/m);
  return m ? m[1] : null;
}

function getPluginVersion() {
  const p = join(repoRoot, '.claude-plugin', 'plugin.json');
  if (!existsSync(p)) return null;
  try {
    const json = JSON.parse(readFileSync(p, 'utf8'));
    return json.version || null;
  } catch {
    return null;
  }
}

function getPortableVersion() {
  const p = join(repoRoot, 'portable-manifest.json');
  if (!existsSync(p)) return null;
  try {
    const json = JSON.parse(readFileSync(p, 'utf8'));
    return json.version || null;
  } catch {
    return null;
  }
}

function getNpmVersion() {
  const p = join(repoRoot, 'npm-wrapper', 'package.json');
  if (!existsSync(p)) return null;
  try {
    const json = JSON.parse(readFileSync(p, 'utf8'));
    return json.version || null;
  } catch {
    return null;
  }
}

function getRunnerHashes() {
  const runnerPath = join(repoRoot, 'skills', 'flow', 'runner', 'flow.sh');
  const manifestPath = join(repoRoot, 'portable-manifest.json');
  let liveHash = null;
  let manifestHash = null;

  if (existsSync(runnerPath)) {
    const bytes = readFileSync(runnerPath);
    liveHash = createHash('sha256').update(bytes).digest('hex');
  }

  if (existsSync(manifestPath)) {
    try {
      const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
      manifestHash = manifest.hashes?.['skills/flow/runner/flow.sh'] || null;
    } catch {
      manifestHash = null;
    }
  }

  return { liveHash, manifestHash };
}

function runChecks() {
  const skill_v = getSkillVersion();
  const plugin_v = getPluginVersion();
  const portable_v = getPortableVersion();
  const npm_v = getNpmVersion();
  const { liveHash, manifestHash } = getRunnerHashes();

  const results = [];

  // 1. Skill version in SKILL.md
  results.push({
    surface: 'Skill version (skills/flow/SKILL.md)',
    expected: 'Valid semver',
    actual: skill_v || 'MISSING',
    pass: Boolean(skill_v),
  });

  // 2. Mirror version in .claude-plugin/plugin.json
  results.push({
    surface: 'Plugin mirror (.claude-plugin/plugin.json)',
    expected: skill_v || 'N/A',
    actual: plugin_v || 'MISSING',
    pass: Boolean(skill_v && plugin_v && skill_v === plugin_v),
  });

  // 3. Mirror version in portable-manifest.json
  results.push({
    surface: 'Portable manifest mirror (portable-manifest.json)',
    expected: skill_v || 'N/A',
    actual: portable_v || 'MISSING',
    pass: Boolean(skill_v && portable_v && skill_v === portable_v),
  });

  // 4. npm version in npm-wrapper/package.json
  results.push({
    surface: 'npm package version (npm-wrapper/package.json)',
    expected: 'Valid semver',
    actual: npm_v || 'MISSING',
    pass: Boolean(npm_v),
  });

  // 5. Dual-axis non-equality (npm_v !== skill_v)
  const dualAxisDiff = Boolean(skill_v && npm_v && skill_v !== npm_v);
  results.push({
    surface: 'Dual-axis separation (npm_v !== skill_v)',
    expected: 'npm_v !== skill_v',
    actual: skill_v && npm_v ? (dualAxisDiff ? `${npm_v} !== ${skill_v}` : `${npm_v} === ${skill_v} (EQUAL)`) : 'N/A',
    pass: dualAxisDiff,
  });

  // 6. SHA-256 runner hash of skills/flow/runner/flow.sh vs portable-manifest.json
  const hashMatches = Boolean(liveHash && manifestHash && liveHash === manifestHash);
  results.push({
    surface: 'Runner SHA-256 (flow.sh vs portable-manifest)',
    expected: manifestHash ? manifestHash.slice(0, 12) + '...' : 'Present in manifest',
    actual: liveHash ? (hashMatches ? liveHash.slice(0, 12) + '... (matches)' : liveHash.slice(0, 12) + '... (mismatch)') : 'MISSING',
    pass: hashMatches,
  });

  // 7. Root README.md table rows (Skill product and npm installer)
  const rootReadmePath = join(repoRoot, 'README.md');
  if (!existsSync(rootReadmePath)) {
    results.push({
      surface: 'Root README.md (Skill product row)',
      expected: `| **Skill product** | **v${skill_v || 'N/A'}** |`,
      actual: 'FILE MISSING',
      pass: false,
    });
    results.push({
      surface: 'Root README.md (npm installer row)',
      expected: `| **npm installer** | ... ${npm_v || 'N/A'} ships the skill above) |`,
      actual: 'FILE MISSING',
      pass: false,
    });
  } else {
    const text = readFileSync(rootReadmePath, 'utf8');
    const skillRegex = skill_v
      ? new RegExp(`^[ \\t]*\\|\\s*\\*\\*Skill product\\*\\*\\s*\\|\\s*\\*\\*v${escapeRegExp(skill_v)}\\*\\*\\s*\\|`, 'm')
      : null;
    const npmRegex = npm_v
      ? new RegExp(`^[ \\t]*\\|\\s*\\*\\*npm installer\\*\\*\\s*\\|.*${escapeRegExp(npm_v)}\\s+ships the skill above\\)\\s*\\|`, 'm')
      : null;
    const skillPass = Boolean(skillRegex && skillRegex.test(text));
    const npmPass = Boolean(npmRegex && npmRegex.test(text));
    results.push({
      surface: 'Root README.md (Skill product row)',
      expected: skill_v ? `| **Skill product** | **v${skill_v}** |` : 'N/A',
      actual: skillPass ? 'Found exact row' : 'MISSING / ROW MISMATCH',
      pass: skillPass,
    });
    results.push({
      surface: 'Root README.md (npm installer row)',
      expected: npm_v ? `| **npm installer** | ... ${npm_v} ships the skill above) |` : 'N/A',
      actual: npmPass ? 'Found exact row' : 'MISSING / ROW MISMATCH',
      pass: npmPass,
    });
  }

  // 8. Root README_VN.md table rows (Skill product and npm installer)
  const rootReadmeVnPath = join(repoRoot, 'README_VN.md');
  if (!existsSync(rootReadmeVnPath)) {
    results.push({
      surface: 'Root README_VN.md (Skill product row)',
      expected: `| **Skill product** | **v${skill_v || 'N/A'}** |`,
      actual: 'FILE MISSING',
      pass: false,
    });
    results.push({
      surface: 'Root README_VN.md (npm installer row)',
      expected: `| **npm installer** | ... ${npm_v || 'N/A'} ship skill ở trên) |`,
      actual: 'FILE MISSING',
      pass: false,
    });
  } else {
    const text = readFileSync(rootReadmeVnPath, 'utf8');
    const skillRegex = skill_v
      ? new RegExp(`^[ \\t]*\\|\\s*\\*\\*Skill product\\*\\*\\s*\\|\\s*\\*\\*v${escapeRegExp(skill_v)}\\*\\*\\s*\\|`, 'm')
      : null;
    const npmRegex = npm_v
      ? new RegExp(`^[ \\t]*\\|\\s*\\*\\*npm installer\\*\\*\\s*\\|.*${escapeRegExp(npm_v)}\\s+ship skill ở trên\\)\\s*\\|`, 'm')
      : null;
    const skillPass = Boolean(skillRegex && skillRegex.test(text));
    const npmPass = Boolean(npmRegex && npmRegex.test(text));
    results.push({
      surface: 'Root README_VN.md (Skill product row)',
      expected: skill_v ? `| **Skill product** | **v${skill_v}** |` : 'N/A',
      actual: skillPass ? 'Found exact row' : 'MISSING / ROW MISMATCH',
      pass: skillPass,
    });
    results.push({
      surface: 'Root README_VN.md (npm installer row)',
      expected: npm_v ? `| **npm installer** | ... ${npm_v} ship skill ở trên) |` : 'N/A',
      actual: npmPass ? 'Found exact row' : 'MISSING / ROW MISMATCH',
      pass: npmPass,
    });
  }

  // 9. npm-wrapper/README.md table row
  const isPrerelease = Boolean(npm_v && npm_v.includes('-'));
  const wrapperReadmePath = join(repoRoot, 'npm-wrapper', 'README.md');
  const expectedWrapperRow = isPrerelease
    ? `| **Prerelease** | **${npm_v}** — ships skill product **v${skill_v}** |`
    : `| **Current GA** | **${npm_v}** — ships skill product **v${skill_v}** |`;
  if (!existsSync(wrapperReadmePath)) {
    results.push({
      surface: 'npm-wrapper/README.md table row',
      expected: expectedWrapperRow,
      actual: 'FILE MISSING',
      pass: false,
    });
  } else {
    const text = readFileSync(wrapperReadmePath, 'utf8');
    const expectedRegex = (npm_v && skill_v)
      ? (isPrerelease
        ? new RegExp(`^[ \\t]*\\|\\s*\\*\\*Prerelease\\*\\*\\s*\\|\\s*\\*\\*${escapeRegExp(npm_v)}\\*\\*\\s*—\\s*ships skill product\\s*\\*\\*v${escapeRegExp(skill_v)}\\*\\*\\s*\\|`, 'm')
        : new RegExp(`^[ \\t]*\\|\\s*\\*\\*Current GA\\*\\*\\s*\\|\\s*\\*\\*${escapeRegExp(npm_v)}\\*\\*\\s*—\\s*ships skill product\\s*\\*\\*v${escapeRegExp(skill_v)}\\*\\*\\s*\\|`, 'm'))
      : null;
    const matched = Boolean(expectedRegex && expectedRegex.test(text));
    results.push({
      surface: 'npm-wrapper/README.md table row',
      expected: (npm_v && skill_v) ? expectedWrapperRow : 'N/A',
      actual: matched ? 'Found exact row' : 'MISSING / ROW MISMATCH',
      pass: matched,
    });
  }

  // 10. npm-wrapper/README_VN.md table row
  const wrapperReadmeVnPath = join(repoRoot, 'npm-wrapper', 'README_VN.md');
  const expectedWrapperVnRow = isPrerelease
    ? `| **Bản thử nghiệm** | **${npm_v}** — ships skill product **v${skill_v}** |`
    : `| **GA hiện tại** | **${npm_v}** — ships skill product **v${skill_v}** |`;
  if (!existsSync(wrapperReadmeVnPath)) {
    results.push({
      surface: 'npm-wrapper/README_VN.md table row',
      expected: expectedWrapperVnRow,
      actual: 'FILE MISSING',
      pass: false,
    });
  } else {
    const text = readFileSync(wrapperReadmeVnPath, 'utf8');
    const expectedRegex = (npm_v && skill_v)
      ? (isPrerelease
        ? new RegExp(`^[ \\t]*\\|\\s*\\*\\*(?:Bản thử nghiệm|Prerelease)\\*\\*\\s*\\|\\s*\\*\\*${escapeRegExp(npm_v)}\\*\\*\\s*—\\s*ships skill product\\s*\\*\\*v${escapeRegExp(skill_v)}\\*\\*\\s*\\|`, 'm')
        : new RegExp(`^[ \\t]*\\|\\s*\\*\\*GA hiện tại\\*\\*\\s*\\|\\s*\\*\\*${escapeRegExp(npm_v)}\\*\\*\\s*—\\s*ships skill product\\s*\\*\\*v${escapeRegExp(skill_v)}\\*\\*\\s*\\|`, 'm'))
      : null;
    const matched = Boolean(expectedRegex && expectedRegex.test(text));
    results.push({
      surface: 'npm-wrapper/README_VN.md table row',
      expected: (npm_v && skill_v) ? expectedWrapperVnRow : 'N/A',
      actual: matched ? 'Found exact row' : 'MISSING / ROW MISMATCH',
      pass: matched,
    });
  }

  // 11. Entry for skill version in CHANGELOG.md
  const changelogPath = join(repoRoot, 'CHANGELOG.md');
  let changelogHasSkill = false;
  if (existsSync(changelogPath) && skill_v) {
    const text = readFileSync(changelogPath, 'utf8');
    changelogHasSkill = new RegExp(`^##\\s+\\[?${escapeRegExp(skill_v)}\\]?`, 'm').test(text);
  }
  results.push({
    surface: 'CHANGELOG.md entry for skill version',
    expected: skill_v ? `## [${skill_v}]` : 'N/A',
    actual: changelogHasSkill ? 'Found' : 'MISSING',
    pass: changelogHasSkill,
  });

  // 12. Entry for npm version in npm-wrapper/CHANGELOG.md
  const wrapperChangelogPath = join(repoRoot, 'npm-wrapper', 'CHANGELOG.md');
  let wrapperChangelogHasNpm = false;
  if (existsSync(wrapperChangelogPath) && npm_v) {
    const text = readFileSync(wrapperChangelogPath, 'utf8');
    wrapperChangelogHasNpm = new RegExp(`^##\\s+\\[?${escapeRegExp(npm_v)}\\]?`, 'm').test(text);
  }
  results.push({
    surface: 'npm-wrapper/CHANGELOG.md entry for npm version',
    expected: npm_v ? `## [${npm_v}]` : 'N/A',
    actual: wrapperChangelogHasNpm ? 'Found' : 'MISSING',
    pass: wrapperChangelogHasNpm,
  });

  return {
    skill_v,
    npm_v,
    results,
    allPass: results.every(r => r.pass),
  };
}

function formatDiagnosticTable(results) {
  const rows = results.map(r => [
    r.surface,
    r.expected,
    r.actual,
    r.pass ? 'PASS' : 'FAIL',
  ]);

  const headers = ['Surface / Check', 'Expected', 'Observed', 'Status'];
  const colWidths = [
    Math.max(headers[0].length, ...rows.map(r => r[0].length)),
    Math.max(headers[1].length, ...rows.map(r => r[1].length)),
    Math.max(headers[2].length, ...rows.map(r => r[2].length)),
    Math.max(headers[3].length, ...rows.map(r => r[3].length)),
  ];

  const pad = (str, len) => str + ' '.repeat(Math.max(0, len - str.length));
  const sep = colWidths.map(w => '-'.repeat(w)).join('  ');
  const headerLine = headers.map((h, i) => pad(h, colWidths[i])).join('  ');

  const lines = [
    '',
    '=== Release Coherence Diagnostic Table ===',
    headerLine,
    sep,
  ];
  for (const row of rows) {
    lines.push(row.map((cell, i) => pad(cell, colWidths[i])).join('  '));
  }
  lines.push(sep);
  return lines.join('\n');
}

function syncRelease(skill_v, npm_v) {
  console.log(`\nSynchronizing release surfaces for skill v${skill_v} and npm ${npm_v}...`);
  const npmSeriesMatch = npm_v.match(/^(\d+\.\d+)/);
  const npmSeries = npmSeriesMatch ? npmSeriesMatch[1] : npm_v;
  const isPrerelease = npm_v.includes('-');

  // 1. npm-wrapper/README.md
  const wrapperReadmePath = join(repoRoot, 'npm-wrapper', 'README.md');
  if (existsSync(wrapperReadmePath)) {
    let content = readFileSync(wrapperReadmePath, 'utf8');
    if (!isPrerelease) {
      content = content.replace(
        /^[ \t]*\|\s*\*\*Current GA\*\*\s*\|[^\r\n]*/m,
        `| **Current GA** | **${npm_v}** — ships skill product **v${skill_v}** |`
      );
      content = content.replace(/^[ \t]*\|\s*\*\*Prerelease\*\*\s*\|[^\r\n]*\r?\n?/m, '');
    } else {
      // Prerelease protection: preserve existing GA row, add or update Prerelease row
      if (/^[ \t]*\|\s*\*\*Prerelease\*\*\s*\|[^\r\n]*/m.test(content)) {
        content = content.replace(
          /^[ \t]*\|\s*\*\*Prerelease\*\*\s*\|[^\r\n]*/m,
          `| **Prerelease** | **${npm_v}** — ships skill product **v${skill_v}** |`
        );
      } else {
        content = content.replace(
          /^([ \t]*\|\s*\*\*Current GA\*\*\s*\|[^\r\n]*)/m,
          `$1\n| **Prerelease** | **${npm_v}** — ships skill product **v${skill_v}** |`
        );
      }
    }
    writeFileSync(wrapperReadmePath, content, 'utf8');
    console.log('✓ Synchronized npm-wrapper/README.md');
  }

  // 2. npm-wrapper/README_VN.md
  const wrapperReadmeVnPath = join(repoRoot, 'npm-wrapper', 'README_VN.md');
  if (existsSync(wrapperReadmeVnPath)) {
    let content = readFileSync(wrapperReadmeVnPath, 'utf8');
    if (!isPrerelease) {
      content = content.replace(
        /^[ \t]*\|\s*\*\*GA hiện tại\*\*\s*\|[^\r\n]*/m,
        `| **GA hiện tại** | **${npm_v}** — ships skill product **v${skill_v}** |`
      );
      content = content.replace(/^[ \t]*\|\s*\*\*(?:Bản thử nghiệm|Prerelease)\*\*\s*\|[^\r\n]*\r?\n?/m, '');
    } else {
      // Prerelease protection: preserve existing GA row, add or update prerelease row
      if (/^[ \t]*\|\s*\*\*(?:Bản thử nghiệm|Prerelease)\*\*\s*\|[^\r\n]*/m.test(content)) {
        content = content.replace(
          /^[ \t]*\|\s*\*\*(?:Bản thử nghiệm|Prerelease)\*\*\s*\|[^\r\n]*/m,
          `| **Bản thử nghiệm** | **${npm_v}** — ships skill product **v${skill_v}** |`
        );
      } else {
        content = content.replace(
          /^([ \t]*\|\s*\*\*GA hiện tại\*\*\s*\|[^\r\n]*)/m,
          `$1\n| **Bản thử nghiệm** | **${npm_v}** — ships skill product **v${skill_v}** |`
        );
      }
    }
    writeFileSync(wrapperReadmeVnPath, content, 'utf8');
    console.log('✓ Synchronized npm-wrapper/README_VN.md');
  }

  // 3. root README.md
  const rootReadmePath = join(repoRoot, 'README.md');
  if (existsSync(rootReadmePath)) {
    let content = readFileSync(rootReadmePath, 'utf8');
    content = content.replace(
      /^[ \t]*\|\s*\*\*Skill product\*\*\s*\|[^\r\n]*/m,
      `| **Skill product** | **v${skill_v}** |`
    );
    const tagRef = isPrerelease ? '`@next`' : '`@latest`';
    content = content.replace(
      /^[ \t]*\|\s*\*\*npm installer\*\*\s*\|[^\r\n]*/m,
      `| **npm installer** | [\`@manhquy/flow-skill\`](https://www.npmjs.com/package/@manhquy/flow-skill) **${npmSeries}.x** (${tagRef} ${npm_v} ships the skill above) |`
    );
    writeFileSync(rootReadmePath, content, 'utf8');
    console.log('✓ Synchronized root README.md');
  }

  // 4. root README_VN.md
  const rootReadmeVnPath = join(repoRoot, 'README_VN.md');
  if (existsSync(rootReadmeVnPath)) {
    let content = readFileSync(rootReadmeVnPath, 'utf8');
    content = content.replace(
      /^[ \t]*\|\s*\*\*Skill product\*\*\s*\|[^\r\n]*/m,
      `| **Skill product** | **v${skill_v}** |`
    );
    const tagRef = isPrerelease ? '`@next`' : '`@latest`';
    const isVnPhrase = content.includes('ship skill ở trên');
    const tailPhrase = isVnPhrase ? 'ship skill ở trên' : 'ships the skill above';
    content = content.replace(
      /^[ \t]*\|\s*\*\*npm installer\*\*\s*\|[^\r\n]*/m,
      `| **npm installer** | [\`@manhquy/flow-skill\`](https://www.npmjs.com/package/@manhquy/flow-skill) **${npmSeries}.x** (${tagRef} ${npm_v} ${tailPhrase}) |`
    );
    writeFileSync(rootReadmeVnPath, content, 'utf8');
    console.log('✓ Synchronized root README_VN.md');
  }

  // 5. Trigger npm run sync inside npm-wrapper
  console.log('\nRunning "npm run sync" inside npm-wrapper...');
  const npmCmd = process.platform === 'win32' ? 'npm.cmd' : 'npm';
  execFileSync(npmCmd, ['run', 'sync'], {
    cwd: join(repoRoot, 'npm-wrapper'),
    stdio: 'inherit',
  });
  console.log('✓ Re-materialized skills/flow and updated manifest-hashes.json');
}

function gitTagExists(tagName) {
  try {
    const out = execFileSync('git', ['tag', '-l', tagName], {
      cwd: repoRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    if (out.split(/\r?\n/).filter(Boolean).includes(tagName)) {
      return { exists: true, source: 'local' };
    }
  } catch {
    // local check failed
  }
  try {
    const out = execFileSync('git', ['ls-remote', '--tags', 'origin', `refs/tags/${tagName}`], {
      cwd: repoRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    return { exists: out.length > 0, source: 'remote' };
  } catch {
    return { exists: false, source: 'unconfirmed' };
  }
}

function printReleaseInstructions(skill_v, npm_v) {
  const npmTag = `npm@${npm_v}`;
  const skillTag = `v${skill_v}`;
  const npmCheck = gitTagExists(npmTag);
  const skillCheck = gitTagExists(skillTag);

  console.log(`
================================================================================
Release Instructions (Dual-Axis Channels)
================================================================================
Skill Product: v${skill_v}
npm Package:   ${npm_v}
`);

  if (npmCheck.exists && skillCheck.exists) {
    console.log(`[NOTE] Both release tags already exist. This operation was metadata repair / synchronization, not a new release.\n`);
  }

  console.log('1. Channel 1 — npm installer release (triggers npm publish workflow):');
  if (npmCheck.exists) {
    console.log(`   [INFO] Git tag ${npmTag} ALREADY exists (${npmCheck.source}). Skipping npm tag command.`);
  } else if (npmCheck.source === 'unconfirmed') {
    console.log(`   [WARN] Remote tag check for ${npmTag} unconfirmed (remote inaccessible). Tag creation commands suppressed for safety; verify remote tags manually.`);
  } else {
    console.log(`   git tag ${npmTag}`);
    console.log(`   git push origin ${npmTag}`);
  }

  console.log('\n2. Channel 2 — Skill product release (GitHub Release / tags):');
  if (skillCheck.exists) {
    console.log(`   [INFO] Git tag ${skillTag} ALREADY exists (${skillCheck.source}). Skipping skill tag command.`);
  } else if (skillCheck.source === 'unconfirmed') {
    console.log(`   [WARN] Remote tag check for ${skillTag} unconfirmed (remote inaccessible). Tag creation commands suppressed for safety; verify remote tags manually.`);
  } else {
    console.log(`   git tag ${skillTag}`);
    console.log(`   git push origin ${skillTag}`);
  }

  console.log(`
Commit recommendation:
   git add skills/flow/SKILL.md .claude-plugin/plugin.json portable-manifest.json \\
     npm-wrapper/package.json npm-wrapper/skills/ README.md README_VN.md \\
     npm-wrapper/README.md npm-wrapper/README_VN.md CHANGELOG.md npm-wrapper/CHANGELOG.md
   git commit -m "chore(release): v${skill_v} / npm@${npm_v}"
   git push origin master
================================================================================
`);
}

const ALLOWED_RELEASE_FILES = new Set([
  'skills/flow/SKILL.md',
  '.claude-plugin/plugin.json',
  'portable-manifest.json',
  'npm-wrapper/package.json',
  'npm-wrapper/package-lock.json',
  'CHANGELOG.md',
  'npm-wrapper/CHANGELOG.md',
  'README.md',
  'README_VN.md',
  'npm-wrapper/README.md',
  'npm-wrapper/README_VN.md',
  'docs/i18n-pairs.txt',
]);

function isAllowedReleaseFile(filePath) {
  if (ALLOWED_RELEASE_FILES.has(filePath)) return true;
  if (filePath.startsWith('npm-wrapper/skills/')) return true;
  if (filePath === 'npm-wrapper/node_modules' || filePath.startsWith('npm-wrapper/node_modules/')) return true;
  return false;
}

function getWorkingTreeStatus() {
  const out = execFileSync('git', ['status', '--porcelain'], {
    cwd: repoRoot,
    encoding: 'utf8',
  });
  if (!out.trim()) return [];
  return out.split(/\r?\n/).filter(Boolean).map(line => {
    const match = line.match(/^(.{2})\s+(.*)$/);
    const status = match ? match[1] : line.slice(0, 2);
    let p = match ? match[2].trim() : line.slice(3).trim();
    if (p.includes(' -> ')) {
      p = p.split(' -> ').pop().trim();
    }
    if (p.startsWith('"') && p.endsWith('"')) {
      p = p.slice(1, -1);
    }
    p = p.replace(/\\/g, '/');
    return { status, path: p };
  });
}

function shipRelease({ isDryRun = false, isYes = false } = {}) {
  // If neither --dry-run nor --yes is specified:
  // Print planned release actions and exit 0 immediately with ZERO file modifications, ZERO commits, ZERO writes!
  if (!isYes && !isDryRun) {
    const skill_v = getSkillVersion();
    const npm_v = getNpmVersion();
    const npmTag = npm_v ? `npm@${npm_v}` : 'npm@<unknown>';
    const skillTag = skill_v ? `v${skill_v}` : 'v<unknown>';
    const npmTagStatus = npm_v ? gitTagExists(npmTag) : { exists: false, source: 'unknown' };
    const skillTagStatus = skill_v ? gitTagExists(skillTag) : { exists: false, source: 'unknown' };

    console.log(`
================================================================================
RELEASE SHIP CONFIRMATION REQUIRED
================================================================================
Planned live release:
  Skill version: ${skill_v ? `v${skill_v}` : 'MISSING'}
  npm version:   ${npm_v ?? 'MISSING'}
  Tags:
    - ${npmTag} ${npmTagStatus.exists ? `(already exists: ${npmTagStatus.source})` : '(new tag to create)'}
    - ${skillTag} ${skillTagStatus.exists ? `(already exists: ${skillTagStatus.source})` : '(new tag to create)'}
  Branch:
    - master -> origin/master

Confirmation flag (--yes / -y) was not provided. Live mutations, tag creation,
and pushing are paused for safety.

To preview release readiness without mutations:
  node scripts/sync-release.mjs --ship --dry-run
  bash scripts/release.sh --dry-run

To execute this release live, re-run with --yes:
  node scripts/sync-release.mjs --ship --yes
  bash scripts/release.sh --yes
================================================================================
`);
    process.exit(0);
  }

  console.log(`\n================================================================================`);
  console.log(`Starting Flow Skill Unified Release Pipeline${isDryRun ? ' (DRY-RUN)' : ''}`);
  console.log(`================================================================================\n`);
  // a. Checks if working tree is clean (or has only release files modified).
  console.log('Step 1/8: Checking working tree status...');
  const statusFiles = getWorkingTreeStatus();
  const nonReleaseFiles = statusFiles.filter(f => !isAllowedReleaseFile(f.path));
  if (nonReleaseFiles.length > 0) {
    if (!isDryRun) {
      console.error('FAIL: Working tree contains uncommitted changes outside release files. Clean working tree before running --ship.');
      for (const f of nonReleaseFiles) {
        console.error(`  ${f.status} ${f.path}`);
      }
      process.exit(1);
    } else {
      console.log('[WARN] Working tree contains uncommitted changes outside release files (non-mutating --dry-run continues):');
      for (const f of nonReleaseFiles) {
        console.log(`  ${f.status} ${f.path}`);
      }
    }
  } else {
    console.log('✓ Working tree is clean or has only release files modified.');
  }
  // b. Reads skill version and npm version.
  console.log('\nStep 2/8: Reading skill and npm versions...');
  const skill_v = getSkillVersion();
  const npm_v = getNpmVersion();
  if (!skill_v) {
    console.error('FAIL: Missing skill version in skills/flow/SKILL.md');
    process.exit(1);
  }
  if (!npm_v) {
    console.error('FAIL: Missing npm version in npm-wrapper/package.json');
    process.exit(1);
  }
  console.log(`✓ Skill product version: v${skill_v}`);
  console.log(`✓ npm package version:   ${npm_v}`);

  // c. Validates CHANGELOG entries exist for both versions.
  console.log('\nStep 3/8: Validating CHANGELOG entries...');
  const changelogPath = join(repoRoot, 'CHANGELOG.md');
  if (!existsSync(changelogPath) || !new RegExp(`^##\\s+\\[?${escapeRegExp(skill_v)}\\]?`, 'm').test(readFileSync(changelogPath, 'utf8'))) {
    console.error(`FAIL: CHANGELOG.md is missing an entry for skill version v${skill_v}`);
    process.exit(1);
  }
  const wrapperChangelogPath = join(repoRoot, 'npm-wrapper', 'CHANGELOG.md');
  if (!existsSync(wrapperChangelogPath) || !new RegExp(`^##\\s+\\[?${escapeRegExp(npm_v)}\\]?`, 'm').test(readFileSync(wrapperChangelogPath, 'utf8'))) {
    console.error(`FAIL: npm-wrapper/CHANGELOG.md is missing an entry for npm version ${npm_v}`);
    process.exit(1);
  }
  console.log('✓ CHANGELOG entries exist for both versions.');


  if (!isDryRun) {
    // d. Runs syncRelease(skill_v, npm_v) to update all 4 READMEs and re-materialize npm-wrapper/skills with npm run sync.
    console.log('\nStep 4/8: Synchronizing READMEs and npm-wrapper skills...');
    syncRelease(skill_v, npm_v);

    // e. If release files are dirty:
    //    - Commits them: `chore(release): prepare v${skill_v} / npm@${npm_v}`
    console.log('\nStep 5/8: Checking for uncommitted release preparation files...');
    const statusAfterSync = getWorkingTreeStatus();
    const dirtyReleaseFiles = statusAfterSync
      .map(f => f.path)
      .filter(p => p !== 'docs/i18n-pairs.txt' && isAllowedReleaseFile(p));

    if (dirtyReleaseFiles.length > 0) {
      console.log('Committing release preparation files:');
      for (const f of dirtyReleaseFiles) {
        console.log(`  + ${f}`);
      }
      execFileSync('git', ['add', '--', ...dirtyReleaseFiles], { cwd: repoRoot, stdio: 'inherit' });
      execFileSync('git', ['commit', '-m', `chore(release): prepare v${skill_v} / npm@${npm_v}`], { cwd: repoRoot, stdio: 'inherit' });
      console.log(`✓ Committed release files: chore(release): prepare v${skill_v} / npm@${npm_v}`);
    } else {
      console.log('✓ Release preparation files are already clean / committed.');
    }

    // f. Records i18n pair hashes using bash scripts/check-i18n-pairs.sh record npm-wrapper/README.md and bash scripts/check-i18n-pairs.sh record README.md.
    console.log('\nStep 6/8: Recording i18n pair hashes...');
    execFileSync('bash', ['scripts/check-i18n-pairs.sh', 'record', 'npm-wrapper/README.md'], {
      cwd: repoRoot,
      stdio: 'inherit',
    });
    execFileSync('bash', ['scripts/check-i18n-pairs.sh', 'record', 'README.md'], {
      cwd: repoRoot,
      stdio: 'inherit',
    });
    console.log('✓ Recorded i18n pair hashes.');

    // g. If docs/i18n-pairs.txt is dirty, commits it: `docs(i18n): update pair hashes for v${skill_v} / ${npm_v}`
    console.log('\nStep 7/8: Checking docs/i18n-pairs.txt status...');
    const statusAfterRecord = getWorkingTreeStatus();
    const i18nDirty = statusAfterRecord.some(f => f.path === 'docs/i18n-pairs.txt');
    if (i18nDirty) {
      console.log('Committing updated docs/i18n-pairs.txt...');
      execFileSync('git', ['add', 'docs/i18n-pairs.txt'], { cwd: repoRoot, stdio: 'inherit' });
      execFileSync('git', ['commit', '-m', `docs(i18n): update pair hashes for v${skill_v} / ${npm_v}`], { cwd: repoRoot, stdio: 'inherit' });
      console.log(`✓ Committed docs/i18n-pairs.txt: docs(i18n): update pair hashes for v${skill_v} / ${npm_v}`);
    } else {
      console.log('✓ docs/i18n-pairs.txt is already clean / up to date.');
    }
  } else {
    console.log('\n[DRY-RUN] Verifying release surface coherence (non-mutating mode)...');
    const checkState = runChecks();
    if (!checkState.allPass) {
      console.error(formatDiagnosticTable(checkState.results));
      console.error('\nFAIL: Release surfaces show drift during dry-run validation.');
      process.exit(1);
    }
    console.log('✓ Release surfaces coherent.');
    console.log('[DRY-RUN] Skipping git commits and i18n record (non-mutating mode).');
  }
  // h. Runs the entire verification battery:
  //    - check-release-coherence.sh
  //    - release-preflight.sh
  //    - pack-rehearsal.sh
  //    - check-doc-budgets.sh
  //    - test_doc_budgets.sh
  //    - test_flow_rules.sh
  //    - npm test --prefix npm-wrapper
  // i. If any check fails, aborts immediately.
  console.log('\nStep 8/8: Running entire verification battery...');
  // In dry-run mode, avoid scripts that invoke `npm run sync` (release-preflight.sh
  // and `npm test` via its `pretest` hook); use strictly read-only equivalents instead.
  const npmCmd = process.platform === 'win32' ? 'npm.cmd' : 'npm';
  const battery = isDryRun
    ? [
        { name: 'check-release-coherence', cmd: 'bash', args: ['scripts/check-release-coherence.sh'] },
        { name: 'check-doc-budgets', cmd: 'bash', args: ['scripts/check-doc-budgets.sh'] },
        { name: 'test_doc_budgets', cmd: 'bash', args: ['tests/test_doc_budgets.sh'] },
        { name: 'test_flow_rules', cmd: 'bash', args: ['tests/test_flow_rules.sh'] },
        { name: 'test_release_coherence', cmd: 'bash', args: ['tests/test_release_coherence.sh'] },
        {
          name: 'npm-wrapper tests (read-only)',
          cmd: 'node',
          args: ['--test', '--test-concurrency=1', 'test/installer.test.mjs', 'test/detect.test.mjs', 'test/cli.test.mjs', 'test/lock-atomicity.test.mjs', 'test/sync-manifest.test.mjs'],
          cwd: 'npm-wrapper', // bypasses `pretest` sync hook
        },
      ]
    : [
        { name: 'check-release-coherence', cmd: 'bash', args: ['scripts/check-release-coherence.sh'] },
        { name: 'release-preflight', cmd: 'bash', args: ['scripts/release-preflight.sh'] },
        { name: 'pack-rehearsal', cmd: 'bash', args: ['scripts/pack-rehearsal.sh'] },
        { name: 'check-doc-budgets', cmd: 'bash', args: ['scripts/check-doc-budgets.sh'] },
        { name: 'test_doc_budgets', cmd: 'bash', args: ['tests/test_doc_budgets.sh'] },
        { name: 'test_flow_rules', cmd: 'bash', args: ['tests/test_flow_rules.sh'] },
        { name: 'npm test --prefix npm-wrapper', cmd: npmCmd, args: ['test', '--prefix', 'npm-wrapper'] },
      ];

  let preRunTree = null;
  if (isDryRun) {
    // Some read-only-equivalent checks (test_flow_rules.sh flow-harness invocations,
    // sync-manifest.test.mjs receipt writes) touch runtime state files (.flow/,
    // manifest receipts). Snapshot the tree so the dry-run can restore any byte and
    // guarantee strict zero-mutation across the whole repository.
    preRunTree = snapshotTree(repoRoot);
  }

  const mutatedPaths = [];
  for (const step of battery) {
    console.log(`\n>>> Running ${step.name}...`);
    try {
      execFileSync(step.cmd, step.args, {
        cwd: step.cwd ? join(repoRoot, step.cwd) : repoRoot,
        stdio: 'inherit',
      });
      console.log(`✓ ${step.name} PASSED`);
    } catch (err) {
      console.error(`\nFAIL: Verification step "${step.name}" failed (exit code ${err.status ?? 1}). Aborting release.`);
      process.exit(err.status ?? 1);
    }
  }

  if (isDryRun && preRunTree) {
    const restored = restoreTree(repoRoot, preRunTree);
    if (restored > 0) {
      console.log(`\n[DRY-RUN] Restored ${restored} runtime-state file(s); repository left byte-identical (zero-mutation guarantee).`);
    }
  }

  // j. If --dry-run: prints "DRY-RUN SUCCESS: All gates passed. The release is 100% verified and ready to ship." and exits 0.
  if (isDryRun) {
    console.log('\nDRY-RUN SUCCESS: All gates passed. The release is 100% verified and ready to ship.\n');
    process.exit(0);
  }

  // k. If live:
  //    - Verifies if tags npm@${npm_v} and v${skill_v} already exist. If either exists, prints warning/info and does not duplicate.
  //    - If tags are new: creates git tag npm@${npm_v} and git tag v${skill_v}.
  //    - Pushes master and tags: git push origin master and git push origin npm@${npm_v} / git push origin v${skill_v}.
  //    - Prints instructions for approving the GitHub Actions npm-publish environment.
  const npmTag = `npm@${npm_v}`;
  const skillTag = `v${skill_v}`;
  const npmTagStatus = gitTagExists(npmTag);
  const skillTagStatus = gitTagExists(skillTag);


  let createdNpmTag = false;
  let createdSkillTag = false;

  console.log('\n================================================================================');
  console.log('Tagging Release');
  console.log('================================================================================\n');

  if (npmTagStatus.exists) {
    console.log(`[INFO] Git tag ${npmTag} already exists (${npmTagStatus.source}). Skipping npm tag creation.`);
  } else {
    console.log(`Creating git tag ${npmTag}...`);
    execFileSync('git', ['tag', npmTag], { cwd: repoRoot, stdio: 'inherit' });
    createdNpmTag = true;
    console.log(`✓ Created tag ${npmTag}`);
  }

  if (skillTagStatus.exists) {
    console.log(`[INFO] Git tag ${skillTag} already exists (${skillTagStatus.source}). Skipping skill tag creation.`);
  } else {
    console.log(`Creating git tag ${skillTag}...`);
    execFileSync('git', ['tag', skillTag], { cwd: repoRoot, stdio: 'inherit' });
    createdSkillTag = true;
    console.log(`✓ Created tag ${skillTag}`);
  }

  console.log('\n================================================================================');
  console.log('Pushing to Remote');
  console.log('================================================================================\n');

  console.log('Pushing master branch to origin...');
  execFileSync('git', ['push', 'origin', 'master'], { cwd: repoRoot, stdio: 'inherit' });
  console.log('✓ Pushed master to origin');

  if (createdNpmTag || !npmTagStatus.exists) {
    console.log(`Pushing tag ${npmTag} to origin...`);
    execFileSync('git', ['push', 'origin', npmTag], { cwd: repoRoot, stdio: 'inherit' });
    console.log(`✓ Pushed tag ${npmTag} to origin`);
  } else {
    console.log(`[INFO] Tag ${npmTag} already exists on remote/local. Skipping tag push.`);
  }

  if (createdSkillTag || !skillTagStatus.exists) {
    console.log(`Pushing tag ${skillTag} to origin...`);
    execFileSync('git', ['push', 'origin', skillTag], { cwd: repoRoot, stdio: 'inherit' });
    console.log(`✓ Pushed tag ${skillTag} to origin`);
  } else {
    console.log(`[INFO] Tag ${skillTag} already exists on remote/local. Skipping tag push.`);
  }

  console.log(`
================================================================================
RELEASE SHIP SUCCESSFUL
================================================================================
Skill Product: v${skill_v}
npm Package:   ${npm_v}

Pushed to origin:
  Branch: master
  Tags:   ${npmTag}${createdNpmTag ? ' (newly created)' : ' (already existed)'}
          ${skillTag}${createdSkillTag ? ' (newly created)' : ' (already existed)'}

NEXT STEPS (GitHub Actions Approval):
  1. Go to GitHub Actions:
     https://github.com/manhquydev/flow-skill/actions
  2. Locate the "Publish npm-wrapper to npm" workflow run triggered by tag ${npmTag}.
  3. Review and approve the "npm-publish" environment deployment prompt (requires reviewer approval).
  4. Once published, verify the published package:
     npm view @manhquy/flow-skill dist-tags --json
     npx --yes @manhquy/flow-skill@latest --help
================================================================================
`);
}

function main() {
  const args = process.argv.slice(2);
  const isShip = args.includes('--ship');
  const isDryRun = args.includes('--dry-run');
  const isYes = args.includes('--yes') || args.includes('-y');
  const isSync = args.includes('--sync');
  const isInstructions = args.includes('--instructions');
  const isCheck = args.includes('--check') || (!isShip && !isSync && !isInstructions);
  const isHelp = args.includes('--help') || args.includes('-h');

  if (isHelp) {
    console.log(`Usage: node scripts/sync-release.mjs [--check | --sync | --instructions | --ship [--dry-run] [--yes]]

Options:
  --check         Validate release coherence across all versions, manifests, readmes, and changelogs (default)
  --sync          Synchronize documentation tables across README files, trigger npm-wrapper sync, and verify
  --instructions  Print release instructions and tag status for current versions without modifying files
  --ship          Full release pipeline: sync, commit prep & i18n hashes, run battery, tag, and push
  --dry-run       When used with --ship, run full validation checks without modifying files, committing, tagging, or pushing
  --yes, -y       Confirm live tag creation and pushing when executing --ship
  --help          Show this help message
`);
    process.exit(0);
  }

  if (isShip) {
    shipRelease({ isDryRun, isYes });
    return;
  }

  if (isInstructions) {
    const skill_v = getSkillVersion();
    const npm_v = getNpmVersion();
    if (!skill_v) {
      console.error('FAIL: Missing skill version in skills/flow/SKILL.md');
      process.exit(1);
    }
    if (!npm_v) {
      console.error('FAIL: Missing npm version in npm-wrapper/package.json');
      process.exit(1);
    }
    printReleaseInstructions(skill_v, npm_v);
    process.exit(0);
  }

  if (isSync) {
    const skill_v = getSkillVersion();
    const npm_v = getNpmVersion();
    if (!skill_v) {
      console.error('FAIL: Missing skill version in skills/flow/SKILL.md');
      process.exit(1);
    }
    if (!npm_v) {
      console.error('FAIL: Missing npm version in npm-wrapper/package.json');
      process.exit(1);
    }

    syncRelease(skill_v, npm_v);

    console.log('\nRe-running verification check after synchronization:');
    const checkState = runChecks();
    console.log(formatDiagnosticTable(checkState.results));

    if (!checkState.allPass) {
      console.error('\nFAIL: Release surfaces still show drift after synchronization.');
      process.exit(1);
    }

    printReleaseInstructions(skill_v, npm_v);
    console.log('SUCCESS: All release surfaces are synchronized and coherent.\n');
    process.exit(0);
  }

  // Default: --check
  const checkState = runChecks();
  console.log(formatDiagnosticTable(checkState.results));

  if (!checkState.allPass) {
    const failedCount = checkState.results.filter(r => !r.pass).length;
    console.error(`\nFAIL: Release coherence check failed (${failedCount} drift(s) detected).`);
    console.error('Tip: Run "node scripts/sync-release.mjs --sync" to synchronize README tables and npm-wrapper assets.\n');
    process.exit(1);
  }

  console.log(`\nPASS: All release surfaces coherent (skill v${checkState.skill_v}, npm ${checkState.npm_v}).\n`);
  process.exit(0);
}

main();
