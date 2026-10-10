# flow — Website Asset Package & Implementation Handoff

> **BRANCH CONSTRAINTS NOTICE:**  
> **Adopt on `feat/flow-website`; not applied here.** The `website/` directory is strictly off-limits on this working branch. This document provides the complete, pre-verified production asset inventory, HTML/CSS markup patterns, and brand invariant rules for downstream implementation on `feat/flow-website`.

---

## 1. Production Asset Inventory

All production assets are pre-built, vector-checked, and raster-validated in `brand/`:

| File Path | Dimensions / Type | Background | Primary Role & Intended Surface |
|---|---|---|---|
| `brand/brand-lockup-light.svg` | 1040 × 256 vector | Transparent | Primary horizontal brand lockup on light surfaces (Paper `#F8FAFC`). Letters Ink `#0F172A`, gate stanchions Signal Teal `#1AA3C4`, pass chevron Gate Green `#22C55E`. |
| `brand/brand-lockup-dark.svg` | 1040 × 256 vector | Transparent | Primary horizontal brand lockup on dark/terminal surfaces (Ink `#0F172A`). Letters Mist `#E2E8F0`, accents unchanged. |
| `brand/brand-mark-glyph.svg` | 512 × 512 vector | Transparent | Direction A standalone gate mark glyph. Used for compact UI viewports, mobile headers, and collapsed navigation states. |
| `brand/icons/favicon.svg` | 512 × 512 vector | Transparent | Modern SVG vector favicon for browsers supporting vector tab icons. |
| `brand/icons/favicon-32.png` | 32 × 32 raster PNG | Transparent | Standard desktop browser tab favicon (Retina / standard display). |
| `brand/icons/favicon-16.png` | 16 × 16 raster PNG | Transparent | Classic 16px legacy browser tab and bookmark favicon. |
| `brand/icons/apple-touch-icon-180.png` | 180 × 180 raster PNG | Paper `#F8FAFC` solid | iOS home screen / Safari bookmark icon with glyph inset to 70% safe circle. |
| `brand/icons/icon-512.png` | 512 × 512 raster PNG | Ink `#0F172A` solid | PWA webmanifest / Android home screen icon with glyph inset to 70% safe circle. |
| `brand/icons/icon-1024-squircle.png` | 1024 × 1024 raster PNG | Transparent (Ink squircle) | macOS-style squircle app container ($r=228\text{px}$) with mark scaled to 60%. |
| `brand/icons/og-image-1200x630.png` | 1200 × 630 raster PNG | Ink `#0F172A` solid | OpenGraph & Twitter card banner: centered dark lockup (~55% width) with "Proof over vibes." mono tagline. |
| `brand/icons/sticker.svg` | 512 × 512 vector | Transparent | Physical die-cut sticker artwork with 3mm-equivalent Paper `#F8FAFC` outer backing contour and clean $45^\circ$ angles. |

---

## 2. HTML Markup Recipes for `flowskill.io.vn`

### 2.1 Responsive Navbar Brand Lockup (`<picture>`)
Use the `<picture>` element with CSS media queries to automatically switch between light and dark themes without client-side JavaScript flashes:

```html
<!-- Site Navbar Brand Lockup -->
<a href="/" class="navbar-brand" aria-label="flow homepage">
  <picture>
    <source srcset="/brand/brand-lockup-dark.svg" media="(prefers-color-scheme: dark)">
    <img src="/brand/brand-lockup-light.svg" 
         alt="flow — gated build harness for coding agents" 
         width="130" 
         height="32" 
         class="brand-lockup-img">
  </picture>
</a>
```

### 2.2 Complete `<head>` Favicon & PWA Suite
Insert into the HTML document `<head>`:

```html
<!-- Vector Favicon (modern browsers) -->
<link rel="icon" type="image/svg+xml" href="/brand/icons/favicon.svg">

<!-- Standard PNG Favicons -->
<link rel="icon" type="image/png" sizes="32x32" href="/brand/icons/favicon-32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/brand/icons/favicon-16.png">

<!-- Apple Touch Icon (iOS Home Screen) -->
<link rel="apple-touch-icon" sizes="180x180" href="/brand/icons/apple-touch-icon-180.png">

<!-- Manifest for PWA & Android -->
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0F172A">
```

### 2.3 OpenGraph & Social Sharing Meta Tags
Configure social card previews for Discord, Twitter/X, GitHub, and Slack:

```html
<!-- OpenGraph / Social Metadata -->
<meta property="og:type" content="website">
<meta property="og:url" content="https://flowskill.io.vn/">
<meta property="og:title" content="flow — Gated build harness for coding agents">
<meta property="og:description" content="Proof over vibes. Flow owns the gates and receipts, never the runtime. A mechanical gate (flow.sh) and semantic gate (SKILL.md) must both agree.">
<meta property="og:image" content="https://flowskill.io.vn/brand/icons/og-image-1200x630.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="flow — Gated build harness for coding agents">
<meta name="twitter:description" content="Proof over vibes. Flow owns the gates and receipts, never the runtime.">
<meta name="twitter:image" content="https://flowskill.io.vn/brand/icons/og-image-1200x630.png">
```

---

## 3. Brand Invariant Rules & Guardrails

When integrating on `feat/flow-website`, maintain the engineering rules from `brand/brand-guidelines.md`:

1. **Lockup Minimum Display Size ($\ge 24\text{px}$)**:
   - The horizontal lockup (`brand-lockup-light.svg` / `brand-lockup-dark.svg`) must **never** be rendered at a container height below 24px ($H < 24\text{px}$).
   - Below 24px height (mobile condensed status bars, collapsed breadcrumbs), the lockup must collapse to the glyph mark (`brand-mark-glyph.svg`).
2. **Clearspace Exclusion Perimeter ($1 \times H_{\text{mark}}$)**:
   - Maintain a minimum clear zone around the lockup equal to the height of the mark on all four sides. No text, navigation links, buttons, or border dividers may intrude.
3. **Contrast Discipline (brand-guidelines §1)**:
   - Signal Teal (`#1AA3C4`) and Gate Green (`#22C55E`) have contrast ratios of ≈ 2.9:1 and 2.3:1 on Paper (`#F8FAFC`). They are permitted only as graphical shapes and status indicators.
   - For teal body/prose text on light backgrounds, use **Teal Deep `#0A4E5E`** (7.4:1 AAA).
   - On dark surfaces (Ink `#0F172A`), Signal Teal achieves 5.6:1 (AA normal / AAA large text; graphics-safe).
4. **Status Decoupling**:
   - Never recolor the wordmark with operational status colors (`#22C55E`, `#F59E0B`, `#EF4444`). Operational colors represent live telemetry (`GAP`, `CONVERGED`), not brand decoration.
