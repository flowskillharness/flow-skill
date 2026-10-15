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

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, '..');

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
    if (out.split(/\r?\n/).filter(Boolean).includes(tagName)) return true;
  } catch {
    // fall through to remote check
  }
  // Remote check: if git is unavailable or the query fails (e.g. offline),
  // treat the tag as not existing so offline runs still work.
  try {
    const out = execFileSync('git', ['ls-remote', '--tags', 'origin', `refs/tags/${tagName}`], {
      cwd: repoRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    return out.length > 0;
  } catch {
    return false;
  }
}

function printReleaseInstructions(skill_v, npm_v) {
  const npmTag = `npm@${npm_v}`;
  const skillTag = `v${skill_v}`;
  const npmTagExists = gitTagExists(npmTag);
  const skillTagExists = gitTagExists(skillTag);

  console.log(`
================================================================================
Release Instructions (Dual-Axis Channels)
================================================================================
Skill Product: v${skill_v}
npm Package:   ${npm_v}
`);

  if (npmTagExists && skillTagExists) {
    console.log(`[NOTE] Both release tags already exist. This operation was metadata repair / synchronization, not a new release.\n`);
  }

  console.log('1. Channel 1 — npm installer release (triggers npm publish workflow):');
  if (npmTagExists) {
    console.log(`   [INFO] Git tag ${npmTag} ALREADY exists in repository (published). Skipping npm tag command.`);
  } else {
    console.log(`   git tag ${npmTag}`);
    console.log(`   git push origin ${npmTag}`);
  }

  console.log('\n2. Channel 2 — Skill product release (GitHub Release / tags):');
  if (skillTagExists) {
    console.log(`   [INFO] Git tag ${skillTag} ALREADY exists in repository. Skipping skill tag command.`);
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

function main() {
  const args = process.argv.slice(2);
  const isSync = args.includes('--sync');
  const isInstructions = args.includes('--instructions');
  const isCheck = args.includes('--check') || (!isSync && !isInstructions);
  const isHelp = args.includes('--help') || args.includes('-h');

  if (isHelp) {
    console.log(`Usage: node scripts/sync-release.mjs [--check | --sync | --instructions]

Options:
  --check         Validate release coherence across all versions, manifests, readmes, and changelogs (default)
  --sync          Synchronize documentation tables across README files, trigger npm-wrapper sync, and verify
  --instructions  Print release instructions and tag status for current versions without modifying files
  --help          Show this help message
`);
    process.exit(0);
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
