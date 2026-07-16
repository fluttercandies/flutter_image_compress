// POC for issue #315 — PNG-8 (indexed color) support on Android.
//
// Pure-JVM Java, no third-party deps. Uses javax.imageio for source decoding
// and java.util.zip for the DEFLATE stream inside IDAT. This is the same
// algorithm shape we'd port to Kotlin under handle/png8/ for real integration.
//
// Run (Java 17+ single-file source mode):
//   java Png8Poc.java                      # synthetic test images
//   java Png8Poc.java image1.png image2.jpg
//
// What we measure:
//   - Baseline size = javax.imageio PNG output (truecolor RGBA, comparable to
//     Bitmap.compress(PNG,...) on Android — both encode PNG-32).
//   - PNG-8 size   = our output (indexed, up to 256 colors, optional
//     Floyd-Steinberg dither).
//   - Encode time  = wall-clock for the PNG-8 path.
//
// Not measured here (see writeup): perceptual quality — needs eyeballing or
// SSIM against the truecolor original.

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.zip.CRC32;
import java.util.zip.Deflater;

public class Png8Poc {

    // ---------- Median-cut quantizer (RGBA) ----------
    // Boxes hold indices into a shared pixel array. Split repeatedly along the
    // widest channel until we hit `maxColors` boxes, then take each box's mean
    // color as the palette entry.

    static final class Box {
        int[] pixelIdx; // indices into `pixels` (packed ARGB)
        int rMin, rMax, gMin, gMax, bMin, bMax, aMin, aMax;
        long rSum, gSum, bSum, aSum;

        Box(int[] pixelIdx, int[] pixels) {
            this.pixelIdx = pixelIdx;
            rMin = gMin = bMin = aMin = 255;
            rMax = gMax = bMax = aMax = 0;
            for (int idx : pixelIdx) {
                int p = pixels[idx];
                int a = (p >>> 24) & 0xFF;
                int r = (p >>> 16) & 0xFF;
                int g = (p >>> 8) & 0xFF;
                int b = p & 0xFF;
                if (r < rMin) rMin = r; if (r > rMax) rMax = r;
                if (g < gMin) gMin = g; if (g > gMax) gMax = g;
                if (b < bMin) bMin = b; if (b > bMax) bMax = b;
                if (a < aMin) aMin = a; if (a > aMax) aMax = a;
                rSum += r; gSum += g; bSum += b; aSum += a;
            }
        }

        int longestAxis() {
            int r = rMax - rMin, g = gMax - gMin, b = bMax - bMin, a = aMax - aMin;
            int m = Math.max(Math.max(r, g), Math.max(b, a));
            if (m == a) return 3;
            if (m == r) return 0;
            if (m == g) return 1;
            return 2;
        }

        int volume() {
            return Math.max(1, rMax - rMin) * Math.max(1, gMax - gMin) *
                   Math.max(1, bMax - bMin) * Math.max(1, aMax - aMin);
        }

        // Priority for splitting: color-volume × pixel-count. Empirically this
        // devotes palette entries to regions that are both "large in gamut"
        // and "cover many pixels" — better than pure volume or pure count.
        long priority() {
            return (long) volume() * (long) pixelIdx.length;
        }

        int[] mean() {
            int n = pixelIdx.length;
            return new int[]{
                (int) (rSum / n),
                (int) (gSum / n),
                (int) (bSum / n),
                (int) (aSum / n),
            };
        }
    }

    static int[][] medianCut(int[] pixels, int maxColors) {
        int[] all = new int[pixels.length];
        for (int i = 0; i < pixels.length; i++) all[i] = i;

        List<Box> boxes = new ArrayList<>();
        boxes.add(new Box(all, pixels));

        while (boxes.size() < maxColors) {
            Box target = null;
            int targetI = -1;
            long best = -1;
            for (int i = 0; i < boxes.size(); i++) {
                Box b = boxes.get(i);
                if (b.pixelIdx.length < 2) continue;
                long p = b.priority();
                if (p > best) { best = p; target = b; targetI = i; }
            }
            if (target == null) break;

            int axis = target.longestAxis();
            int[] idxs = target.pixelIdx.clone();
            // Sort by chosen channel.
            Integer[] boxed = new Integer[idxs.length];
            for (int i = 0; i < idxs.length; i++) boxed[i] = idxs[i];
            Arrays.sort(boxed, (x, y) -> Integer.compare(channel(pixels[x], axis), channel(pixels[y], axis)));
            for (int i = 0; i < idxs.length; i++) idxs[i] = boxed[i];

            int mid = idxs.length / 2;
            int[] left = Arrays.copyOfRange(idxs, 0, mid);
            int[] right = Arrays.copyOfRange(idxs, mid, idxs.length);
            if (left.length == 0 || right.length == 0) break;

            boxes.remove(targetI);
            boxes.add(new Box(left, pixels));
            boxes.add(new Box(right, pixels));
        }

        int[][] palette = new int[boxes.size()][4];
        for (int i = 0; i < boxes.size(); i++) palette[i] = boxes.get(i).mean();
        return palette;
    }

    static int channel(int argb, int axis) {
        switch (axis) {
            case 0: return (argb >>> 16) & 0xFF;
            case 1: return (argb >>> 8) & 0xFF;
            case 2: return argb & 0xFF;
            case 3: return (argb >>> 24) & 0xFF;
            default: throw new IllegalArgumentException();
        }
    }

    // ---------- Nearest-palette lookup with optional Floyd-Steinberg dither ----------
    // Returns per-pixel palette index (byte value).

    static byte[] mapToPalette(int[] pixels, int width, int height, int[][] palette, boolean dither) {
        byte[] out = new byte[pixels.length];
        if (!dither) {
            for (int i = 0; i < pixels.length; i++) {
                out[i] = (byte) nearest(pixels[i], palette);
            }
            return out;
        }

        // Floyd-Steinberg on a mutable float buffer (per-channel).
        float[] r = new float[pixels.length];
        float[] g = new float[pixels.length];
        float[] b = new float[pixels.length];
        float[] a = new float[pixels.length];
        for (int i = 0; i < pixels.length; i++) {
            int p = pixels[i];
            a[i] = (p >>> 24) & 0xFF;
            r[i] = (p >>> 16) & 0xFF;
            g[i] = (p >>> 8) & 0xFF;
            b[i] = p & 0xFF;
        }

        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int i = y * width + x;
                int cr = clamp((int) Math.round(r[i]));
                int cg = clamp((int) Math.round(g[i]));
                int cb = clamp((int) Math.round(b[i]));
                int ca = clamp((int) Math.round(a[i]));
                int packed = (ca << 24) | (cr << 16) | (cg << 8) | cb;
                int idx = nearest(packed, palette);
                out[i] = (byte) idx;

                float er = cr - palette[idx][0];
                float eg = cg - palette[idx][1];
                float eb = cb - palette[idx][2];
                float ea = ca - palette[idx][3];

                spread(r, g, b, a, width, height, x + 1, y,     er, eg, eb, ea, 7f / 16f);
                spread(r, g, b, a, width, height, x - 1, y + 1, er, eg, eb, ea, 3f / 16f);
                spread(r, g, b, a, width, height, x,     y + 1, er, eg, eb, ea, 5f / 16f);
                spread(r, g, b, a, width, height, x + 1, y + 1, er, eg, eb, ea, 1f / 16f);
            }
        }
        return out;
    }

    static void spread(float[] r, float[] g, float[] b, float[] a,
                       int w, int h, int x, int y,
                       float er, float eg, float eb, float ea, float f) {
        if (x < 0 || x >= w || y < 0 || y >= h) return;
        int i = y * w + x;
        r[i] += er * f;
        g[i] += eg * f;
        b[i] += eb * f;
        a[i] += ea * f;
    }

    static int clamp(int v) { return v < 0 ? 0 : (v > 255 ? 255 : v); }

    static int nearest(int argb, int[][] palette) {
        int a = (argb >>> 24) & 0xFF;
        int r = (argb >>> 16) & 0xFF;
        int g = (argb >>> 8) & 0xFF;
        int b = argb & 0xFF;
        int bestIdx = 0;
        int bestDist = Integer.MAX_VALUE;
        for (int i = 0; i < palette.length; i++) {
            int[] p = palette[i];
            int dr = r - p[0], dg = g - p[1], db = b - p[2], da = a - p[3];
            // Weight alpha more heavily — a mismatch on opacity is more
            // visible than on any single RGB channel.
            int d = dr * dr + dg * dg + db * db + 2 * da * da;
            if (d < bestDist) { bestDist = d; bestIdx = i; }
        }
        return bestIdx;
    }

    // ---------- PNG-8 writer ----------
    // Format:
    //   89 50 4E 47 0D 0A 1A 0A      signature
    //   IHDR (bit depth = 8, color type = 3 indexed)
    //   PLTE (R,G,B triplets)
    //   tRNS (per-palette alpha bytes; omitted if all opaque)
    //   IDAT (deflate of filter-byte + row-of-indices for each row; filter 0 = None)
    //   IEND

    static byte[] writePng8(byte[] indices, int width, int height, int[][] palette) {
        try {
            ByteArrayOutputStream buf = new ByteArrayOutputStream();
            DataOutputStream out = new DataOutputStream(buf);
            out.write(new byte[]{(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A});

            // IHDR
            ByteArrayOutputStream ihdr = new ByteArrayOutputStream();
            DataOutputStream d = new DataOutputStream(ihdr);
            d.writeInt(width);
            d.writeInt(height);
            d.writeByte(8);   // bit depth
            d.writeByte(3);   // color type = indexed
            d.writeByte(0);   // compression = deflate
            d.writeByte(0);   // filter method = adaptive
            d.writeByte(0);   // interlace = none
            writeChunk(out, "IHDR", ihdr.toByteArray());

            // PLTE (must be present for color type 3, up to 256 entries)
            ByteArrayOutputStream plte = new ByteArrayOutputStream();
            for (int[] p : palette) {
                plte.write(p[0]);
                plte.write(p[1]);
                plte.write(p[2]);
            }
            writeChunk(out, "PLTE", plte.toByteArray());

            // tRNS — only if any palette entry is non-opaque. Trailing 255s
            // can be omitted (per PNG spec) but we keep it simple.
            boolean hasAlpha = false;
            for (int[] p : palette) if (p[3] != 255) { hasAlpha = true; break; }
            if (hasAlpha) {
                int lastNonOpaque = -1;
                for (int i = 0; i < palette.length; i++) {
                    if (palette[i][3] != 255) lastNonOpaque = i;
                }
                byte[] trns = new byte[lastNonOpaque + 1];
                for (int i = 0; i <= lastNonOpaque; i++) trns[i] = (byte) palette[i][3];
                writeChunk(out, "tRNS", trns);
            }

            // IDAT — filter byte 0 + row of indices, deflated.
            ByteArrayOutputStream raw = new ByteArrayOutputStream();
            for (int y = 0; y < height; y++) {
                raw.write(0); // filter = None
                raw.write(indices, y * width, width);
            }
            byte[] rawBytes = raw.toByteArray();
            Deflater deflater = new Deflater(Deflater.BEST_COMPRESSION);
            deflater.setInput(rawBytes);
            deflater.finish();
            ByteArrayOutputStream comp = new ByteArrayOutputStream();
            byte[] chunk = new byte[64 * 1024];
            while (!deflater.finished()) {
                int n = deflater.deflate(chunk);
                comp.write(chunk, 0, n);
            }
            deflater.end();
            writeChunk(out, "IDAT", comp.toByteArray());

            writeChunk(out, "IEND", new byte[0]);
            return buf.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    static void writeChunk(DataOutputStream out, String type, byte[] data) throws Exception {
        out.writeInt(data.length);
        byte[] typeBytes = type.getBytes("US-ASCII");
        out.write(typeBytes);
        out.write(data);
        CRC32 crc = new CRC32();
        crc.update(typeBytes);
        crc.update(data);
        out.writeInt((int) crc.getValue());
    }

    // ---------- Baseline: javax.imageio truecolor PNG (comparable to Bitmap.compress(PNG)) ----------

    static byte[] baselinePng(BufferedImage img) throws Exception {
        ByteArrayOutputStream buf = new ByteArrayOutputStream();
        ImageIO.write(img, "png", buf);
        return buf.toByteArray();
    }

    // ---------- Bench harness ----------

    static int[] extractPixels(BufferedImage img) {
        int w = img.getWidth(), h = img.getHeight();
        int[] pixels = new int[w * h];
        img.getRGB(0, 0, w, h, pixels, 0, w);
        return pixels;
    }

    static BufferedImage ensureArgb(BufferedImage src) {
        if (src.getType() == BufferedImage.TYPE_INT_ARGB) return src;
        BufferedImage argb = new BufferedImage(src.getWidth(), src.getHeight(), BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = argb.createGraphics();
        g.drawImage(src, 0, 0, null);
        g.dispose();
        return argb;
    }

    // Synthetic test images so the POC has something to run against with no
    // args. Each targets a different content class.

    static BufferedImage synthGradient(int w, int h) {
        BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int r = (int) (255.0 * x / (w - 1));
                int g = (int) (255.0 * y / (h - 1));
                int b = (int) (255.0 * ((x + y) % (w + h)) / (w + h - 1));
                img.setRGB(x, y, (0xFF << 24) | (r << 16) | (g << 8) | b);
            }
        }
        return img;
    }

    static BufferedImage synthIcon(int w, int h) {
        // Sharp UI-icon-like: 6 flat colors + transparent background. This is
        // the sweet spot for PNG-8 — palette naturally covers all colors, so
        // encoding should be lossless AND much smaller than PNG-32.
        BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setBackground(new Color(0, 0, 0, 0));
        g.clearRect(0, 0, w, h);
        Color[] palette = {
            new Color(0x1E88E5), new Color(0x43A047),
            new Color(0xE53935), new Color(0xFDD835),
            new Color(0x8E24AA), new Color(0xFB8C00),
        };
        int cell = w / palette.length;
        for (int i = 0; i < palette.length; i++) {
            g.setColor(palette[i]);
            g.fillRect(i * cell, h / 4, cell, h / 2);
        }
        g.dispose();
        return img;
    }

    static BufferedImage synthPhoto(int w, int h) {
        // Photo-like: many unique colors from sinusoidal + noise. This
        // stresses the quantizer.
        BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
        java.util.Random rng = new java.util.Random(42);
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                double u = (double) x / w, v = (double) y / h;
                int r = clamp((int) (128 + 100 * Math.sin(u * 8) + rng.nextGaussian() * 15));
                int g = clamp((int) (128 + 100 * Math.cos(v * 6) + rng.nextGaussian() * 15));
                int b = clamp((int) (128 + 100 * Math.sin((u + v) * 5) + rng.nextGaussian() * 15));
                img.setRGB(x, y, (0xFF << 24) | (r << 16) | (g << 8) | b);
            }
        }
        return img;
    }

    static int uniqueColors(int[] pixels) {
        HashMap<Integer, Boolean> seen = new HashMap<>();
        for (int p : pixels) seen.put(p, Boolean.TRUE);
        return seen.size();
    }

    static void run(String label, BufferedImage img) throws Exception {
        int w = img.getWidth(), h = img.getHeight();
        int[] pixels = extractPixels(img);
        int unique = uniqueColors(pixels);

        byte[] baseline = baselinePng(img);

        long t0 = System.nanoTime();
        int[][] palette = medianCut(pixels, 256);
        long tQuant = System.nanoTime() - t0;

        long t1 = System.nanoTime();
        byte[] indicesND = mapToPalette(pixels, w, h, palette, false);
        long tMapND = System.nanoTime() - t1;
        byte[] png8ND = writePng8(indicesND, w, h, palette);

        long t2 = System.nanoTime();
        byte[] indicesFS = mapToPalette(pixels, w, h, palette, true);
        long tMapFS = System.nanoTime() - t2;
        byte[] png8FS = writePng8(indicesFS, w, h, palette);

        System.out.printf(
            "%-24s %4dx%-4d  unique=%-7d  baseline=%-8d  png8(nodither)=%-8d (%.0f%%)  png8(FS)=%-8d (%.0f%%)  quant=%.1fms  map(nd)=%.1fms  map(fs)=%.1fms%n",
            label, w, h, unique,
            baseline.length,
            png8ND.length, 100.0 * png8ND.length / baseline.length,
            png8FS.length, 100.0 * png8FS.length / baseline.length,
            tQuant / 1e6, tMapND / 1e6, tMapFS / 1e6
        );

        // Emit files so we can eyeball artifacts.
        File dir = new File("out");
        dir.mkdirs();
        String base = label.replaceAll("[^A-Za-z0-9]+", "_");
        java.nio.file.Files.write(new File(dir, base + "_baseline.png").toPath(), baseline);
        java.nio.file.Files.write(new File(dir, base + "_png8_nodither.png").toPath(), png8ND);
        java.nio.file.Files.write(new File(dir, base + "_png8_fs.png").toPath(), png8FS);
    }

    public static void main(String[] args) throws Exception {
        System.out.println("=== PNG-8 POC (issue #315) ===");
        System.out.println("Palette size: 256 (median-cut, RGBA-weighted). Baseline: javax.imageio truecolor PNG.");
        System.out.println();

        if (args.length == 0) {
            run("synth-gradient", synthGradient(512, 512));
            run("synth-icon",     synthIcon(512, 512));
            run("synth-photo",    synthPhoto(512, 512));
        } else {
            for (String a : args) {
                BufferedImage src = ensureArgb(ImageIO.read(new File(a)));
                run(new File(a).getName(), src);
            }
        }
        System.out.println();
        System.out.println("Wrote sample outputs under ./out/ for visual inspection.");
    }
}
