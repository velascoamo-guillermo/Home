# App Icon Design — Home (iOS 26 Liquid Glass)

## Concept: Warm Hearth

Amber-to-terracotta gradient background with a liquid glass house glyph. Warm palette reads "home" immediately; stands out on most iOS wallpapers. Three Xcode-required variants: default (light), dark, tinted.

---

## Visual Layers (bottom to top)

1. **Gradient background** — radial-adjusted linear gradient at 145°
2. **House glyph** — translucent white fill + white stroke (see Glyph section)
3. **Glass overlay** — diagonal fade, heavy at top-left, transparent at bottom-right
4. **Specular highlight** — blurred white pill anchored near top edge
5. **Inner edge rim** — bright top edge + subtle shadow at bottom, simulates glass thickness

---

## Glyph

Shape: classic house silhouette (pitched roof, rectangular body), arched door, chimney top-right.

| Element | Fill | Stroke |
|---------|------|--------|
| House body | `rgba(255,255,255,0.28)` | `rgba(255,255,255,0.65)` 1.4pt |
| Arched door | `rgba(255,255,255,0.42)` | `rgba(255,255,255,0.70)` 1.2pt |
| Chimney | `rgba(255,255,255,0.20)` | `rgba(255,255,255,0.50)` 1.2pt |

Glyph occupies ~55% of icon width, centred slightly above vertical centre.

---

## Colour Palettes

### Default (light)
| Stop | Colour | Position |
|------|--------|----------|
| Start | `#f7ca82` | 0% |
| Mid | `#e8834a` | 52% |
| End | `#c0411e` | 100% |

### Dark
| Stop | Colour | Position |
|------|--------|----------|
| Start | `#e8a840` | 0% |
| Mid | `#c0541a` | 52% |
| End | `#7a1e08` | 100% |

### Tinted
Flat mid-tone grey background (`#888888`). iOS 26 desaturates and re-tints with the user's wallpaper colour automatically. Glyph and glass stack identical to default variant.

---

## Glass Effect Parameters

| Layer | Value |
|-------|-------|
| Overlay start | `rgba(255,255,255,0.52)` at top-left (0%) |
| Overlay end | `rgba(0,0,0,0.07)` at bottom-right (100%) |
| Overlay mid-stop | `rgba(255,255,255,0.0)` at 55% |
| Specular width | 180px (at 1024px canvas) |
| Specular height | 60px |
| Specular blur | 20px Gaussian |
| Specular opacity | 0.78 |
| Specular position | 8% from top, horizontally centred |
| Top rim | `rgba(255,255,255,0.72)` 1px inset |

---

## Output Files

All PNGs rendered at **1024 × 1024 px**, corner radius NOT applied (Xcode masks automatically).

| File | Variant |
|------|---------|
| `AppIcon-light.png` | Default |
| `AppIcon-dark.png` | Dark |
| `AppIcon-tinted.png` | Tinted |

Written to: `Home/Assets.xcassets/AppIcon.appiconset/`

`Contents.json` updated to reference all three files.

---

## Implementation

Python script using **Pillow** (`pip install pillow`):

1. Draw gradient background via pixel-by-pixel linear interpolation (Pillow has no native gradient fill).
2. Draw glyph shapes (polygon for roof+body, rectangle for chimney, arc+lines for door) using `ImageDraw`.
3. Composite glass overlay as a separate RGBA layer blended with `Image.alpha_composite`.
4. Draw specular pill with Gaussian blur via `ImageFilter.GaussianBlur`.
5. Save PNGs, update `Contents.json`.

Script lives at: `scripts/generate_icon.py` (not committed to Xcode target, scripts-only).

---

## Worktree & PR

Work done on branch `feature/app-icon-liquid-glass` via git worktree. PR opened against `main` once all 3 PNGs render correctly and Xcode shows the icon in the asset catalogue.
