# PNG-8 POC (issue #315)

Standalone Java POC exploring PNG-8 (indexed color) support for the Android
side of `flutter_image_compress`. **Not on the ship path** — this exists to
answer "is it feasible, and what's the size / quality / speed cost?" before
committing to a design.

## Run

Java 17+ single-file source mode. From this directory:

```sh
java Png8Poc.java                          # synthetic images (gradient / icon / photo)
java Png8Poc.java path/to/image.png ...    # any PNG/JPEG the JVM's ImageIO can read
```

Outputs land under `out/` (gitignored) for eyeballing artifacts side-by-side
against the truecolor baseline.

## What it does

- `MedianCut` — RGBA median-cut quantizer, up to 256 palette entries. Splits
  the box with the largest `volume × pixelCount` along its widest channel.
- `mapToPalette` — nearest-palette lookup, alpha-weighted 2× (mismatches on
  opacity read as more visible than any single RGB channel). Optional
  Floyd-Steinberg dither.
- `writePng8` — hand-rolled PNG chunks (IHDR / PLTE / tRNS / IDAT / IEND)
  using `java.util.zip.Deflater` + `CRC32`. No third-party deps.
- Baseline for comparison = `javax.imageio` truecolor PNG (behavior-equivalent
  to `Bitmap.compress(Bitmap.CompressFormat.PNG, ...)` on Android — both
  encode PNG-32).

## Headline numbers (see the writeup on the branch for the full table)

| Content | PNG-8 / baseline | Notes |
|---|---|---|
| UI icon, ≤256 colors | 5–15% | lossless |
| PNG-32 logo/header w/ alpha | ~40% | visually near-lossless |
| Smooth gradient, no dither | 4% ⚠️ | severe posterization |
| Smooth gradient, FS dither | 26% | dither restores gradient at 7× the no-dither size |
| Photo (real, 4K) | 22–42% | visible banding without dither |

Encode cost on JVM: ~2.5s quantize + ~2.5s map for a 4K photo. Real Android
implementation must run off the main thread and should downscale first.
Long-term speed/quality upgrade path: NDK `libimagequant` (license: BSD-2
under recent versions; verify before shipping).

## Why Java (not Kotlin)?

`kotlinc` isn't in this environment; `java Png8Poc.java` runs the single file
directly. The algorithm has no Kotlin-specific idioms — porting to
`handle/png8/*.kt` for real integration is mechanical.
