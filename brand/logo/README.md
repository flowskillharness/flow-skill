# flow — Logo System & Brand Directions

This directory contains the comprehensive logo identity system for **flow** (`flowskill.io.vn`), the gated build harness for coding agents. Flow enforces two independent gates before any stage advances: a mechanical gate (`flow.sh`) and a semantic gate (`SKILL.md`).

All marks and lockups adhere strictly to the external logo design skill standards (`kaankiziltug/logo-design-skill`): zero `<text>` dependencies (all letters constructed as geometric vector shapes), integer canvases, exact angles (multiples of 15°), no embedded rasters or scripts, and crisp legibility down to 24px across light and dark modes.

## Brand Directions Overview

| Direction | Concept | Files | Best Use |
|---|---|---|---|
| **[direction-a-gate/](./direction-a-gate/)** | **Dual-Gate Threshold**: Architectural checkpoint stanchions (mechanical `flow.sh` + semantic `SKILL.md`) opening into an advancing terminal chevron `>`. | `mark.svg`<br>`lockup.svg`<br>`mono.svg`<br>`README.md` | Primary product branding, CLI tool header, technical docs, IDE status bars, CI/CD pipeline summaries. |
| **[direction-b-current/](./direction-b-current/)** | **Verified Flow Current**: Continuous laminar flow stream sweeping dynamically through execution and surging upward into a passing checkmark `✓`. | `mark.svg`<br>`lockup.svg`<br>`mono.svg`<br>`README.md` | Marketing website, developer community avatar, app icon, social media banners, animations. |
| **[direction-c-wordmark/](./direction-c-wordmark/)** | **Command Wordmark (`/flow`)**: Shape-built lowercase logotype with an integrated 75° command slash `/`, paired with the `/f` companion monogram. | `mark.svg`<br>`lockup.svg`<br>`mono.svg`<br>`README.md` | Terminal prompts, CLI documentation headers, navbar logo, developer merchandise, minimal headers. |
| **[direction-d-emblem/](./direction-d-emblem/)** | **Receipt Seal**: Gate-pass receipt seal (verified build outcome) housing the dual gates and verified pass stamp within a security seal ring. | `mark.svg`<br>`lockup.svg`<br>`mono.svg`<br>`README.md` | GitHub README sticker / badge, release receipt stickers, package certificates. |

## Brand Palette Specification

| Token | Hex | Role | Contrast on Ink (`#0F172A`) | Contrast on Paper (`#F8FAFC`) |
|---|---|---|---|---|
| **Signal Teal** | `#1AA3C4` | Primary brand accent & structural elements | 5.6:1 (AA text; graphics-safe) | 3.0:1 (Graphical objects) |
| **Gate Green** | `#22C55E` | Semantic pass indicator / verification apex | 6.8:1 (AA text; graphics-safe) | 2.3:1 (Graphical pass accent) |
| **Deep Ink** | `#0F172A` | Terminal background / dark-mode foundation | Ground | 18.2:1 (AAA text) |
| **Paper** | `#F8FAFC` | Light-mode canvas / high-contrast fill | 18.2:1 (AAA text) | Ground |
| **Warn Amber** | `#F59E0B` | Functional gate warning / blocking state | 5.8:1 (AA text; graphics-safe) | 2.2:1 (Functional UI) |
| **Fail Red** | `#EF4444` | Functional gate kill / verification failure | 4.6:1 (AA text; graphics-safe) | 3.5:1 (Functional UI) |

*Note: Text-contrast compliance rules per `brand/brand-guidelines.md` §1 (teal text on light backgrounds uses Teal Deep `#0A4E5E` at 7.4:1 AAA).*

## File Standards & Deliverables

Per direction:
- `mark.svg`: 512×512 icon mark. Fully vector, scalable, self-contained.
- `lockup.svg`: 960×256 horizontal mark + shape-built wordmark. Pure vector shapes without font dependencies.
- `mono.svg`: 512×512 single-color version utilizing `currentColor` for seamless light/dark embedding.
- `README.md`: Direction rationale, style taxonomy classification, and usage guidelines.
- `previews/<direction>-mark.png`: High-resolution 512×512 PNG render for human visual inspection.
- `gallery.html`: Self-contained browser gallery (file:// review page) covering all directions, comparison sheet, swatches, and typography specimens.
- `wordmark-studies/`: Typographic wordmark explorations: 12 vector variants, grid invariants, and `study.html` review sheet.
