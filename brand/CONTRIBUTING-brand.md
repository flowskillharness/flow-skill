# Contributing brand assets and copy

Rules for extending or modifying the flow brand package in `brand/`.
Brand assets follow the same discipline as code: evidence before merge.

## Adding brand assets
- **Format:** Pure vector SVG only. Zero `<text>` tags, zero raster embeds, zero gradients.
- **Palette:** Strict token colors only (Ink `#0F172A`, Paper `#F8FAFC`, Mist `#E2E8F0`, Signal Teal `#1AA3C4`, Teal Deep `#0A4E5E`, Teal Bright `#5BC8DE`).
- **Functional colors:** Pass `#22C55E`, Warn `#F59E0B`, Fail `#EF4444` are reserved for telemetry and real status; never use them as decoration.

## Naming conventions
- Horizontal lockups: `brand-lockup-{light,dark}.svg`
- Mark glyphs: `brand-mark-{variant}.svg`
- Icons: `brand/icons/{name}-{dimensions}.{png,svg}`
- All filenames use lowercase kebab-case. No spaces, no camelCase.

## Light vs dark variants
- **Light (`brand-lockup-light.svg`):** For Paper `#F8FAFC` surfaces. Letters use Ink `#0F172A`.
- **Dark (`brand-lockup-dark.svg`):** For Ink `#0F172A` surfaces. Letters use Mist `#E2E8F0`.
- **Scaling:** Lockup height $\ge 24\text{px}$. Below 24px, collapse to `brand-mark-glyph.svg`.

## Proposing copy
- **Voice:** Blunt, declarative, proof over vibes. Numbers over adjectives.
- **No hype:** Never use words like "seamless", "supercharge", "effortless", or "10x".
- **Terms:** Keep technical terms in English (`gate`, `stage`, `receipt`, `runtime`).
- **Vietnamese:** Tiếng Việt phải có dấu đầy đủ và đúng quy chuẩn; không viết tắt thiếu dấu.

## Approval process
1. Open a pull request against `master` with your proposed asset or copy change.
2. Include visual side-by-side receipts or text diffs in the PR description.
3. Verify checks pass: `bash scripts/check-doc-budgets.sh && bash scripts/check-i18n-pairs.sh`.
4. Maintainer sign-off is required before merging. No unreviewed additions.
