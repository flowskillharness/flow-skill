# flow — logo usage examples

Usage boundaries for `brand/brand-lockup-light.svg`,
`brand/brand-lockup-dark.svg`, and `brand/brand-mark-glyph.svg`.

## Clear-space perimeter

Clear-space on all 4 sides equals 1× mark height ($H$).
No text, badges, borders, or container edges inside this exclusion perimeter.

```
       +---------------------------------------------+
       |                  1× H space                 |
       |     +---------------------------------+     |
  1× H | 1×H |  [MARK]   f l o w               | 1×H | 1× H
 space |     +---------------------------------+     | space
       |                  1× H space                 |
       +---------------------------------------------+
```

## Minimum sizes

| Tier | File | Min height | Rule |
|---|---|---|---|
| Horizontal lockup | `brand-lockup-light.svg` / `brand-lockup-dark.svg` | 24px | Below 24px, collapse to glyph |
| Gate mark glyph | `brand-mark-glyph.svg` | 16px | Favicon / status indicator floor |

Below 24px height, never squeeze the wordmark. Drop the letters and use the glyph.

## Correct vs incorrect usage

| Status | Usage | Reason |
|---|---|---|
| ✓ | `brand-lockup-light.svg` on Paper `#F8FAFC` | Ink text provides 15.6:1 contrast on Paper. |
| ✓ | `brand-lockup-dark.svg` on Ink `#0F172A` | Mist text provides 12.8:1 contrast on Ink. |
| ✓ | `brand-mark-glyph.svg` at 16–23px | Maintains structural clarity without wordmark. |
| ✗ | `brand-lockup-light.svg` on Ink `#0F172A` | Ink letters disappear on dark backgrounds. |
| ✗ | Lockup rendered under 24px height | Letter strokes distort; collapse to glyph tier. |
| ✗ | Wordmark recolored with gate colors | Pass `#22C55E` / Fail `#EF4444` are status data, not brand. |
| ✗ | Mark enclosed in filled teal box or pill | Mark is stroke-first; do not box in solid fills. |
| ✗ | Text or badge inside 1× H perimeter | Clear-space violation compromises recognition. |
