package com.example.flutterimagecompress

import android.graphics.Bitmap
import java.io.ByteArrayOutputStream

fun Bitmap.compress(minWidth: Int, minHeight: Int, quality: Int): ByteArray {
    val baos = ByteArrayOutputStream()

    val w = this.width
    val h = this.height

    val scaleW = w / minWidth
    val scaleH = h / minHeight
    val scale = Math.max(1, Math.max(scaleW, scaleH))

    print("scale = $scale")
    print("scaleW = $scaleW")
    print("scaleH = $scaleH")

    val destW = w / scale
    val destH = h / scale

    Bitmap.createScaledBitmap(this, destW, destH, true).compress(Bitmap.CompressFormat.JPEG, quality, baos)
    return baos.toByteArray()
}