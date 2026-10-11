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

## Effects inventory (2026-10-11, pass 2)

Programmatic extraction conducted via `bsk evaluate` on active session against live `https://omp.sh/`. Raw dumps and styleSheet walks preserved in `plans/research/assets/omp-dissection.json`. Visual crops preserved in `plans/research/assets/omp-crops/` (`hero.png`, `install-widget.png`, `marquee.png`, `numbered-section.png`, `omp-fullpage.png`).

### 1. Extracted Values from omp.sh

1. **Body Texture (Micro-mesh)**:
   - Selector: `body`
   - CSS: `background: conic-gradient(oklch(100% 0 0 / 0.03) 90deg, transparent 90deg 180deg, oklch(100% 0 0 / 0.03) 180deg 270deg, transparent 270deg) 0 0 / 2px 2px, var(--bg);`
   - Effect: Ultra-fine 2px checkerboard/stipple micro-grid overlaying the `#000000` base, removing clinical flatness without introducing visual clutter.

2. **CRT Scanlines Layer**:
   - Selector: `span.absolute.inset-0.pointer-events-none.opacity-35`
   - CSS: `background: repeating-linear-gradient(to bottom, rgba(0, 0, 0, 0.4) 0 1px, transparent 1px 3px);`
   - Computed: `rgba(0, 0, 0, 0.4)` black lines interleaved with transparent gaps every 3px, rendered at 35% opacity.

3. **Hero Atmosphere & Canvas Engine**:
   - Container: `div.[transform:scaleY(-1)]` (`position: absolute; inset: 0; pointer-events: none`)
   - Elements: Dual `<canvas>` tags with `style="position: absolute; inset: 0; width: 100%; height: 100%; image-rendering: pixelated"`.
   - Engine: WebGPU shader pipeline via WebAssembly module (`poster-DhyUf3v7.js`, `create_stencil`, `stencil_render`), generating procedural low-res ambient raster drift behind the hero text.

4. **Hero Kicker Sweep (`sunray-sweep`)**:
   - Selector: `.sunray` (computed on `p.sunray.mono-fig`)
   - Animation: `9s cubic-bezier(0.4, 0, 0.2, 1) infinite sunray-sweep`
   - Background: `linear-gradient(105deg, var(--ray-dim) 38%, var(--ray-lit) 50%, var(--ray-dim) 62%)`
   - Variables: `--ray-lit: var(--color-ink-9)` (`oklch(0.97 0 0)`), `--ray-dim: color-mix(in oklch, var(--accent-2) 42%, transparent)` (`oklch(0.81 0.14 200 / 0.42)`)
   - Text clip: `background-size: 320% 100%; -webkit-background-clip: text; background-clip: text; color: transparent;`
   - Keyframe Rule:
     ```css
     @keyframes sunray-sweep {
       0% { text-shadow: none; background-position: 100% 0; }
       8% { text-shadow: 0 0 16px color-mix(in oklch, var(--accent-2) 65%, transparent); }
       18%, 100% { text-shadow: none; background-position: 0 0; }
     }
     ```

5. **Marquee Track & Masking**:
   - Container: `.marquee`
   - Mask: `-webkit-mask-image: linear-gradient(90deg, rgba(0,0,0,0), rgb(0,0,0) 10%, rgb(0,0,0) 90%, rgba(0,0,0,0)); mask-image: linear-gradient(90deg, rgba(0,0,0,0), rgb(0,0,0) 10%, rgb(0,0,0) 90%, rgba(0,0,0,0));`
   - Color Variant Mask: `linear-gradient(90deg, rgba(0,0,0,0) 22%, rgb(0,0,0) 46% 54%, rgba(0,0,0,0) 78%)`
   - Track Animation: `60s linear infinite marquee-drift` (`@keyframes marquee-drift { to { transform: translate(-50%); } }`)
   - Interaction: `.marquee:hover .marquee-track { animation-play-state: paused; }`
   - Chip filter: `filter: grayscale(100%) brightness(125%); opacity: 0.5;`

6. **Install Terminal Window**:
   - Container: `bg-[var(--bg-elev)]` (`rgb(10, 10, 12)` / `#0A0A0C`), `border: 1px solid oklch(1 0 0 / 0.08)`
   - Tab buttons: `11px`, `uppercase`, tracking `0.22em`, `transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1)`
   - Active tab: High-contrast `oklch(0.97 0 0)` with bottom border `border-b border-[var(--accent)]` (`oklch(0.7 0.24 340)`)
   - Copy button: `border-l border-[var(--rule)]`, relative feedback overlay.

7. **Interactive Nav & Link Motion**:
   - Rule: `.link::after { transition: transform 0.32s cubic-bezier(0.2, 0.8, 0.2, 1); }`
   - General transitions: `150ms` (`duration-150`) for interactive colors and borders.

8. **Motion Safety Enforcement**:
   - All dynamic animations (`sunray-sweep`, `marquee-drift`) are strictly wrapped in `@media (prefers-reduced-motion: no-preference)`.

---

### 2. Translation Table (omp.sh → flow brand identity)

| omp.sh Effect Layer | omp.sh Implementation | flow Equivalent (Brand Guidelines Compliant) |
|---|---|---|
| **Background micro-mesh** | `conic-gradient(oklch(1 0 0 / 0.03) 90deg, ...) 0 0 / 2px 2px` on black | SVG data-URI / repeating dot pattern: `radial-gradient(rgba(226, 232, 240, 0.04) 1px, transparent 1px) 0 0 / 24px 24px` on Ink `#0F172A` (light mode: `rgba(15, 23, 42, 0.03)` on Paper `#F8FAFC`). |
| **Hero atmosphere & glow** | WebGPU pixelated canvas (`poster-DhyUf3v7.js`) | Multi-layered radial gradients in pure CSS: `radial-gradient(ellipse 60% 45% at 50% -10%, rgba(26, 163, 196, 0.16) 0%, rgba(91, 200, 222, 0.06) 45%, transparent 75%)` providing calm, disciplined teal radiance without heavy runtime deps. |
| **Scanlines overlay** | `repeating-linear-gradient(rgba(0,0,0,0.4) 0 1px, transparent 1px 3px)` at 35% | Subtle CRT scanline overlay: `repeating-linear-gradient(to bottom, rgba(0, 0, 0, 0.18) 0px, rgba(0, 0, 0, 0.18) 1px, transparent 1px, transparent 3px)` blended at low opacity in dark mode. |
| **Headline / text gradient** | `.sunray` gradient text sweep (`oklch(0.81 0.14 200)` to `oklch(0.97 0 0)`) | Headline gradient accent on "Hollow work" / "Việc ảo": `linear-gradient(110deg, var(--flow-teal-signal) 0%, var(--flow-teal-bright) 50%, var(--flow-teal-signal) 100%)`, `background-clip: text`, with subtle ambient sweep or luminous text-shadow. |
| **Install terminal window** | Minimalist 1px hairline box without titlebar chrome | Terminal window elevation: Titlebar chrome with 3 muted terminal window dots (close, minimize, expand in subdued monochrome/teal tones), JetBrains Mono prompt `$`, hairline border `rgba(226, 232, 240, 0.12)`, inner top highlight `inset 0 1px 0 rgba(226, 232, 240, 0.06)`, copy button with hover lift + check state transition. |
| **Marquee edge fade** | `mask-image: linear-gradient(90deg, transparent, black 10% 90%, transparent)` | Symmetrical edge fade mask: `-webkit-mask-image: linear-gradient(90deg, transparent 0%, black 8%, black 92%, transparent 100%); mask-image: ...;` with chip brightness lift on individual hover. |
| **Card elevation & hover** | Flat borders with 150ms color change | Disciplined engineering depth: `transform: translateY(-2px)`, `box-shadow: 0 12px 28px -6px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(26, 163, 196, 0.35)`, border transition `180ms cubic-bezier(0.16, 1, 0.3, 1)` on outcome cards and gate tiles. |
| **Gate tiles indexing** | Single digit button `01` with `bg-[#050507]` | Gate tiles with mono-index accent: tabular figures (`01`, `02`, ...), subtle badge ring, and hover teal surface highlight. |
| **Dividers & verdicts** | Sub-pixel `1px solid oklch(1 0 0 / 0.08)` rules | Center-faded gradient hairline dividers: `linear-gradient(90deg, transparent, rgba(26, 163, 196, 0.22) 50%, transparent)`. Verdict callout box with 3px solid Signal Teal left border + faint glow `box-shadow: 0 0 24px rgba(26, 163, 196, 0.08)`. |
| **CTA / Buttons** | Solid background with text hover | Signal Teal gradient CTA button with hover glow `box-shadow: 0 0 20px rgba(26, 163, 196, 0.35)` and arrow icon nudge `transform: translateX(3px)`. |
| **Entrance choreography** | Static rendering (no entrance motion) | Staggered CSS-only fade-up entrance: `@keyframes entrance-fade-up` (`opacity: 0, translateY(12px) → opacity: 1, translateY(0)`) staggered by 60ms across hero eyebrow, title, lead, and install widget. Completely disabled when `prefers-reduced-motion: reduce`. |

