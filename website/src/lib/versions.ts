import fallback from '../data/version-cache.json';

export interface VersionInfo {
  installerVersion: string;
  skillVersion: string;
  command: string;
}

let memoized: Promise<VersionInfo> | null = null;

export function getVersions(): Promise<VersionInfo> {
  if (memoized) return memoized;
  memoized = (async () => {
    let installerVersion = fallback.installerVersion;
    let skillVersion = fallback.skillVersion;
    try {
      const res = await fetch('https://registry.npmjs.org/@manhquy/flow-skill/latest', {
        signal: AbortSignal.timeout(5000),
      });
      if (res.ok) {
        const pkg = (await res.json()) as { version?: string };
        if (pkg.version) installerVersion = pkg.version;
      }
    } catch {}
    try {
      const res = await fetch(
        'https://raw.githubusercontent.com/manhquydev/flow-skill/master/skills/flow/SKILL.md',
        { signal: AbortSignal.timeout(5000) }
      );
      if (res.ok) {
        const text = await res.text();
        const match = text.match(/^\s{2}version:\s*"([^"]+)"/m);
        if (match?.[1]) skillVersion = match[1];
      }
    } catch {}
    return {
      installerVersion,
      skillVersion,
      command: 'npx @manhquy/flow-skill@latest',
    };
  })();
  return memoized;
}
