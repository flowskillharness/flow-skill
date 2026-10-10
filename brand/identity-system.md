# flow — Identity System Specification

Boring, disciplined identity system for **flow** (`flowskill.io.vn`) — a gated build harness for coding agents. Flow owns gates and receipts, never the runtime. Terminal-first, MIT, bilingual (EN/VI).

## 1. System principles

Enterprise identity systems (Microsoft, Google) achieve scale through four structural properties: fixed geometry grammar, status-isolated color, silhouette-first responsive scaling, and rigid token slots for product families. Flow adopts these engineering invariants while rejecting corporate excess:

- **Single product, terminal-first:** Every asset must resolve cleanly in an 80-column terminal down to plain monospace ASCII and ANSI escapes.
- **Status decoupling:** Red, green, and amber are reserved strictly for operational verdicts (`GAP`, `CONVERGED`, `INVALID`). Brand marks never use functional colors as decoration.
- **Bash-safe and asset-lean:** Zero runtime font dependencies; vector marks are shape-built paths; no external scripts or heavy raster assets.

### Deliberately rejected patterns
1. **Multi-color marks (Google 4-color G, MSFT 4-quadrant):** Multi-color marks collide with operational status colors (`#22C55E`, `#F59E0B`, `#EF4444`), corrupting terminal and dashboard telemetry clarity.
2. **Tile-grid cargo cult:** Square grids serve multi-app operating systems; flow is a linear pipeline discipline layer governed by dual gates.
3. **Motion-heavy logos:** Continuous morphing and bouncing dots waste CPU cycles, fail in CLI terminals, and violate the boring-on-purpose principle.

## 2. Logo architecture

Three distinct tiers serve the display ladder across terminal, web, and OS surfaces:

| Tier | Contexts | Min Size | Clearspace Formula |
|---|---|---|---|
| **Primary Lockup** | README header, docs site navbar, release announcements | 24px height (width ~90px; print 8mm) | $S = 1.0 \times H_{\text{mark}}$ on all 4 sides |
| **Compact Mark** | CLI header banner, app icon, social avatar, repo card | 24px height (print 6mm) | $S = 1.0 \times H_{\text{mark}}$ ($0.5 \times H$ in CLI) |
| **Glyph** | IDE status bar, 16px/32px favicon, terminal prompt | 16px height (print 4mm) | $S = 0.5 \times H_{\text{mark}}$ |

- **Clearspace formula:** Formula $S = N \times H_{\text{mark}}$ defines an exclusion perimeter free of text, borders, and badges. $N = 1.0$ on web/print; $N = 0.5$ in constrained CLI/IDE viewports.
- **Legibility constraint:** The shape-built wordmark `flow` is never rendered below 24px height. Below 24px, the lockup collapses to the glyph.

## 3. Construction grammar (ownable core)

All brand marks (current directions A–D and future assets) derive from invariant geometric constants on a 512×512 unit master canvas:

| Parameter | Value | Mathematical Ratio | Purpose / Invariant |
|---|---|---|---|
| **Modular grid** | 64px major grid (8×8 modules), 16px minor grid | Canvas / 8; sub-grid Canvas / 32 | Integer coordinate snapping; zero subpixel jitter |
| **Stroke width** | 48 units | $48/512 = 3/32 = 0.09375$ | Crisp downscaling: 1.5px @ 16px, 2.25px @ 24px, 6px @ 64px |
| **Canonical angles** | Multiples of 15° ($15^\circ, 30^\circ, 45^\circ, 60^\circ, 75^\circ, 90^\circ$) | $n \times 15^\circ$ | Eliminates arbitrary diagonal drift across marks |
| **Command slash (`/`)** | 75° angle | $\tan(75^\circ) \approx 3.732$ ($\Delta x = 85.74, \Delta y = 320$) | Matches CLI prompt invocation (`/flow`) |
| **Chevron angle** | 90° vertex aperture (two 45° arms) | $2 \times 45^\circ$ (multiples of 15°) | Directional terminal forward motion (`>`) |
| **Gate notch depth** | 48 units | $1.0 \times \text{stroke width}$ | Architectural bracket indentation for stanchions |
| **Gate corridor gap** | 96 units | $2.0 \times \text{stroke width}$ (1.5 grid modules) | Negative space channel representing gate threshold |
| **Corner treatment** | Outer radii 16–48px; inner vertices sharp (0px) | Explicit radius tokens | Architectural solidity; avoids pill-shaped softening |

## 4. Responsive behavior

Visual hierarchy follows: **Silhouette > Structure > Detail**.

- **512px–128px (Display/Master):** Full detail. Stanchion notches, command slash bevels, receipt boundary bars, dual bracket offsets.
- **64px–32px (App/Icon):** Structural core. Inner corridor and primary chevron/slash/check remain visible; hairline gaps simplify.
- **24px–16px (Glyph/Favicon):** Silhouette only. Micro-notches collapse into solid contours to prevent raster blurring. Direction A–D downscale proof in `brand/logo/gallery.html` validates zero hairline dropout at 16px and 24px.
- **Collapse rules:**
  - Lockup $\rightarrow$ Compact Mark: When container width $< 320\text{px}$ or container height $< 32\text{px}$.
  - Compact Mark $\rightarrow$ Glyph: When render target $\le 20\text{px}$ (IDE status bars, 16px browser tab).

## 5. Product-family architecture

Flow is a single product today. Future extensions (cloud services, companion tools) must follow a 2-slot schema rather than arbitrary sub-brands:

$$\text{Asset} = [\text{Shared Glyph}] + [\text{Single Modifier Slot}]$$

- **Slot 1 (Shared Glyph):** Invariant 512×512 mark constructed via §3 grammar.
- **Slot 2 (Single Modifier):** Exactly one of two variations:
  1. *Typographic modifier:* JetBrains Mono Bold descriptor at fixed baseline in Ink Soft `#334155` (light) or Mist `#E2E8F0` (dark).
  2. *Color accent:* Single tint drawn strictly from brand tokens: Signal Teal `#1AA3C4`, Teal Bright `#5BC8DE`, Ink `#0F172A`, or Mist `#E2E8F0`.
- **Hard restriction:** Gate colors (`#22C55E`, `#F59E0B`, `#EF4444`) are strictly forbidden as product identifiers. Gradients and unlisted hues are rejected.

## 6. App icon & avatar spec

| Platform | Canvas | Safe Zone | Crop Geometry | Direction Notes |
|---|---|---|---|---|
| **macOS** | 1024×1024 | 820×820 (80%) | Squircle (radius 228px continuous) | Center mark; keep stroke within 820px box |
| **Windows** | 1024×1024 | 676×676 (66%) | Square (0px radius) | Unclipped square canvas; high contrast |
| **iOS** | 180×180 | 144×144 (80%) | Squircle (~18% radius masked by OS) | Full-bleed background fill; no transparency |
| **Android** | 108×108dp | Circle $\varnothing$ 66dp (61.1%) | Adaptive circle/squircle/teardrop | Outer 42dp is parallax/mask bleed |
| **Favicon** | 32×32 / 16×16 | 100% full bleed | Square (0px margin) | Glyph tier only; integer pixel alignment |
| **Social Avatar** | 512×512 | Circle $\varnothing$ 358px (70%) | Circular crop | Direction D ring fits 1:1; A/B/C require inset |
| **Sticker** | 512 master | Safe $\ge 1\text{mm}$ from cut | Die-cut contour + 3mm bleed | Ink `#0F172A` contour or Paper `#F8FAFC` border |

*Circle-crop resilience:* Direction D (Receipt Seal) naturally conforms to circular crops without corner clipping. Directions A, B, and C have square/rectangular bounds and must be inset within the 70% safe circle ($\le 358\text{px}$) to prevent bracket/slash truncation. Note: Direction D acts symbolically as an outcome receipt stamp; capture-time tamper-evident provenance remains an unmet roadmap item per ADR 0001.

## 7. Motion principles

Specifications for UI and web interactions (spec only; zero decorative runtime files):

- **Gate transitions:** Binary open/close state machine ($0 \rightarrow 1$ flip). No analog half-open easing; gates are either open or closed.
- **Verification mark:** Chevron or checkmark draws once along its vector path (`stroke-dashoffset` reveal). Never loops or bounces.
- **Timing:** Total duration $\le 200\text{ms}$. Easing curve: `cubic-bezier(0, 0, 0.2, 1)` (ease-out deceleration snap).
- **Reduced motion:** Strictly honors `@media (prefers-reduced-motion: reduce)`. Animations resolve instantly at $0\text{ms}$.
- **Guardrail:** The wordmark is never animated. Motion belongs exclusively to functional gate and status transitions.

## 8. Terminal / ASCII identity as first-class channel

The terminal prompt is flow's primary interface (`/flow`, `/flow next`, `/flow doctor`).

- **Banner constraints:** Monospace only (`JetBrains Mono`), $\le 5$ lines height, $\le 60$ columns width.
- **Color tokens & contrast:**
  - Brand line: Signal Teal `#1AA3C4` (ANSI 256: 38, or 24-bit `\x1b[38;2;26;163;196m`). Contrast on Paper `#F8FAFC` is ~2.9:1 (decorative/graphic only); teal text on light uses Teal Deep `#0A4E5E` (~7.4:1 AAA). On Ink `#0F172A`: Signal Teal is ~5.6:1 (AA $\ge 18\text{px}$), small teal text uses Teal Bright `#5BC8DE` (~8.9:1).
  - Terminal ground: Inherits host terminal (Ink `#0F172A` / Paper `#F8FAFC`). Primary text uses Ink on Paper (~18.2:1 AAA) or Mist `#E2E8F0` on Ink (~18.2:1 AAA).
  - Gate status telemetry: Pass `#22C55E` (~2.3:1 decorative on Paper), Warn `#F59E0B`, Fail `#EF4444` appear only when rendering verified gate states ($\le 5\%$ surface area), never as banner decoration.
  - Plaintext compliance: When `NO_COLOR` is set or stdout is not a TTY, all ANSI escapes are stripped.
- **Bilingual footer line:** Tagline follows session locale (`LANG` / environment):
  - EN: `Proof over vibes.` or `Done means proven.`
  - VI: `Bằng chứng hơn cảm hứng.` hoặc `Xong nghĩa là đã chứng minh.` (Dấu tiếng Việt đầy đủ; line-height mono $\ge 1.5$ đảm bảo dấu thanh không bị đè).

## 9. Adoption checklist

Ordered execution pipeline once a final direction (A, B, C, or D) is selected:

1. **Master vector assets:** Produce finalized `mark.svg` (512×512), `lockup.svg` (960×256), `mono.svg` (512×512 `currentColor`). Acceptance: Zero `<text>` tags, shape-built vectors, integer coordinates.
2. **Favicon suite:** Generate `favicon.ico` (16, 32, 48px), `favicon.svg` (theme-adaptive), `apple-touch-icon.png` (180×180). Acceptance: Crisp legibility at 16×16 in browser tab.
3. **README `<picture>` headers:** Render `light-header.svg` (Paper `#F8FAFC` canvas, Ink `#0F172A` type) and `dark-header.svg` (Ink `#0F172A` canvas, Mist `#E2E8F0` type). Acceptance: Automatic GitHub theme toggle via `#gh-light-mode-only` / `#gh-dark-mode-only`.
4. **Platform icon set:** Export 1024×1024 macOS squircle, Android adaptive fg/bg layers, and iOS 180px PNG. Acceptance: Passes platform safe-zone templates without clipping.
5. **OpenGraph social card:** Generate 1200×630px `og-image.png` featuring mark, mono command, and locale tagline. Acceptance: Legible on Twitter/Discord cards under 500px preview width.
6. **Terminal banner asset:** Encode ASCII banner into `flow.sh` greeting. Acceptance: Renders $\le 5$ lines, $\le 60$ cols, clean bypass when `NO_COLOR=1`.
7. **Physical sticker artwork:** Export die-cut vector with 3mm bleed margin. Acceptance: Minimum stroke width $\ge 1\text{mm}$.
