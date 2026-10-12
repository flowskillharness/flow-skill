# flow — social media brand templates

Asset specifications and safe-zones for social platforms.
All dark banners use Ink `#0F172A` background to match the CLI identity.

## Platform specifications

| Platform | Dimensions | Safe-zone | Asset | Background |
|---|---|---|---|---|
| Avatar (X / GitHub / LinkedIn) | 512×512 | Central 70% circle (diameter 358px) | `brand/icons/icon-512.png` | Ink `#0F172A` |
| Twitter / X banner | 1500×500 | Central 1200×360 (clear bottom-left avatar overlap) | `brand/brand-lockup-dark.svg` | Ink `#0F172A` |
| GitHub social preview | 1280×640 | Central 1200×600 (20px edge margin) | `brand/icons/og-image-1200x630.png` | Ink `#0F172A` |
| LinkedIn banner | 1584×396 | Central 1350×300 (clear left avatar overlap) | `brand/brand-lockup-dark.svg` | Ink `#0F172A` |

## Production rules

1. **Avatar centering:** Always use `brand/icons/icon-512.png`. The gate mark glyph
   is pre-centered with 15% margin so circular crops never clip the stanchions.
2. **Banner typography:** Headline uses JetBrains Mono (`font.mono`). Tagline:
   "Proof over vibes." in Mist `#E2E8F0` or Teal Bright `#5BC8DE`.
3. **No decoration:** Zero gradient overlays, zero decorative confetti, zero drop
   shadows. Keep surfaces terminal-clean: 60% Ink, 30% Mist, 10% Teal Signal.
4. **Export formats:** PNG-24 for raster uploads; SVG source where supported.
   Secondary favicon/badge assets are located in `brand/icons/`.
