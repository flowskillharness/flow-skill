# omp.sh Design & Architecture Analysis

Screenshot reference: `plans/research/assets/omp-full.png`

## 1. Layout Skeleton
- **Navbar / Header**: Minimalist fixed top bar (`max-w-[1280px]`, `h-14`), logo lockup left, secondary nav links right (DOCS, community, repo).
- **Hero Unit**: Left-aligned headline hierarchy within a bounded reading measure (`max-w-[640px]`). Kicker badge ("OMP², SOON!"), tight monumental headline, concise thesis paragraph with struck-out anti-pattern.
- **Tabbed Install Snippet**: Positioned directly beneath hero copy. Method tabs (`curl`, `brew`, `bun`, `ps1`, `mise`) above a single consolidated terminal bar with prompt glyph `$`, selectable command, and interactive copy feedback button.
- **Provider / Integration Marquee**: Seamless horizontal logo carousel labeled "COMPATIBLE", running 26 provider badges in an infinite linear loop with hover pause.
- **Numbered Feature Sections (01–08)**: High-density feature grid/dock indexed with two-digit monospace numerals (`01`–`08`) and icon glyphs, switching contextual live proofs/demos.
- **Footer**: Low-key colophon with copyright and essential links.

## 2. Typography Scale & Hierarchy
- **Primary / Brand Font**: `Geist`, `ui-sans-serif`, `system-ui`.
- **Monospace Font**: `JetBrains Mono`, `ui-monospace`, `monospace` for commands, numbers, badges, and labels.
- **Scale**:
  - Hero Kicker / Subtitle: `11px`, `uppercase`, tracking `0.24em`, weight 500 mono.
  - Headline H1: `clamp(2.4rem, 1.2rem + 3.8vw, 4.4rem)`, weight 500, tight line-height `0.98`.
  - Body / Subhead: `clamp(0.98rem, 0.92rem + 0.3vw, 1.08rem)`, line-height `1.625` (`leading-relaxed`), measure `46ch`–`66ch`.
  - Code / Terminal: `clamp(0.85rem, 0.95vw, 1rem)`, `JetBrains Mono`.
  - Numeric Badges: `8px`–`11px`, tabular figures (`mono-fig`), letter-spacing `0.1em`–`0.22em`.

## 3. Color Roles (omp.sh Palette vs Translation)
- **Background**: Deep black `--color-ink-0: #000000`, elevated surface `--bg-elev: #0a0a0c`.
- **Foregound Text**: Lightest white/grey `--fg: oklch(97% 0 0)`, secondary `--fg-dim: oklch(82% .005 280)`, muted `--fg-faint: oklch(50% .008 280)`.
- **Hairlines / Rules**: Sub-pixel borders `--rule: oklch(100% 0 0 / 0.08)`, `--rule-strong: oklch(100% 0 0 / 0.14)`.
- **Accents**: Primary magenta `oklch(70% .24 340)` for focal headline words and active tabs; secondary cyan `oklch(81% .14 200)` for success feedback (`✓ copied`) and interactive borders.
- *(Translation Rule: flow will strictly reject magenta/black in favor of Ink `#0F172A`, Mist `#E2E8F0`, Signal Teal `#1AA3C4`, Teal Bright `#5BC8DE`, Paper `#F8FAFC`, Pass `#22C55E`).*

## 4. Spacing Rhythm & Geometry
- **Grid Scale**: 4px / 8px base units (`gap-1` = 4px, `px-2.5` = 10px, `px-3.5 py-3.5` = 14px, `mt-6`/`mt-7`/`mt-8` = 24–32px).
- **Hairline Borders**: Clean 1px solid borders separating prompt `$`, command text, and copy button.
- **Card Radius**: Subtle, crisp bounds (0–4px) maintaining high-precision engineering feel without bubbly curves.

## 5. Component Patterns
- **Tabbed Install Widget**:
  - Horizontal tab list: active tab marked with high-contrast text and solid underline; inactive tabs dimmed with hover brighten.
  - Command input box: monospace text with `overflow-x-auto whitespace-nowrap`, non-selectable prompt prefix `$`.
  - Copy button: fixed click target with transition between `copy` and `✓ copied`.
- **Logo Wall / Marquee**:
  - Dual identical tracks (`flex w-max items-center`) animated across 50% translation (`to { transform: translate(-50%); }`).
  - Logos filtered to monochrome/dim opacity (`opacity-50 grayscale`), brightening on interaction.
  - Hover halts animation (`animation-play-state: paused`).
- **Numbered Feature Sections (01–06 for flow)**:
  - Indexed 2-digit numeral prefix (`01`, `02`, ...) styling technical gates.
  - Compact monospace file labels or code badges alongside stage outcomes.

## 6. Motion & Accessibility
- **Transitions**: 150ms `cubic-bezier(0.4, 0, 0.2, 1)` duration for color, border, and opacity changes.
- **Reduced Motion**: Complete disabling of marquee drift and animated transitions via `@media (prefers-reduced-motion: reduce)`.
- **Interactive Copy Feedback**: Instant switch to copied checkmark state for 2000ms with fallback selection on clipboard restriction.
