# flow — brand package

Strategy + guidelines + design tokens for the flow brand (gated build
harness for coding agents; flowskill.io.vn). Nothing here is wired into the
build — it is the reference package.

## Files

| File | What it is |
|---|---|
| `brand-brief.md` | Strategy: positioning, audience, personality, values, voice & tone (EN + VI), taglines, messaging pillars. |
| `brand-guidelines.md` | Visual rules: palette + usage ratios, typography, logo usage, application notes (README/badges/ASCII banner), light/dark rules. **Source of truth.** |
| `tokens.json` | Flat `color.*` / `font.*` tokens matching the guidelines exactly. |
| `tokens.css` | `:root { --flow-* }` custom properties mirroring `tokens.json` exactly. |
| `logo/gallery.html` | Self-contained visual review gallery of the logo directions, palette, and typography. |
| `identity-system.md` | Identity system blueprint: geometry grammar, logo tiers, responsive behavior, platform icons, terminal spec, adoption checklist. |
| `logo/wordmark-studies/` | Typographic wordmark explorations: 12 vector variants, grid invariants, study.html review sheet. |
| `brand-lockup-light.svg` | Production horizontal lockup on light surfaces (Direction A mark + flow-04-gate-o-v2 wordmark, baked colors). |
| `brand-lockup-dark.svg` | Production horizontal lockup on dark surfaces (Mist letters, baked accents). |
| `brand-mark-glyph.svg` | Standalone gate mark glyph tier (512×512 baked vector). |
| `icons/` | Complete production icon suite: vector favicon, 16/32px PNGs, apple-touch-icon, PWA 512, squircle 1024, og-image, die-cut sticker. |
| `WEBSITE-HANDOFF.md` | Implementation handoff for `feat/flow-website` (asset inventory, navbar `<picture>` markup, metadata snippets). |
| `CONTRIBUTING-brand.md` | Brand contribution guide: asset rules, naming conventions, light/dark usage, copy approval. |
| `usage-examples.md` | Logo usage examples with clear-space diagrams, minimum sizes, correct vs incorrect rules. |
| `social-templates.md` | Social media avatar and banner specifications (X, GitHub, LinkedIn) with safe-zones. |
| `email-signature.html` | Production table-based HTML email signature with inline CSS and brand lockup. |
| `press-kit.md` | One-page summary for journalists/partners: key stats, logo downloads, color palette, boilerplate. |

## Reading order

1. `brand-brief.md` — why the brand says what it says.
2. `brand-guidelines.md` — how it looks and where each rule applies.
3. `tokens.json` — pull exact values into tooling.
4. `tokens.css` — drop-in for web surfaces; keep in sync with `tokens.json`.

## Change rules

- `brand-guidelines.md` is normative: edit values there first, then mirror
  the same change in `tokens.json` and `tokens.css` in the same commit.
- Colors are reserved as documented — gate colors (`pass`/`warn`/`fail`)
  never appear as decoration; Teal Signal never renders body-size text on
  light backgrounds (use Teal Deep).
