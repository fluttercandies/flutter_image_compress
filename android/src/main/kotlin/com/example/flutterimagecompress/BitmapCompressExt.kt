package com.example.flutterimagecompress

import android.graphics.Bitmap
import android.graphics.Matrix
import java.io.ByteArrayOutputStream

fun Bitmap.compress(minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0): ByteArray {
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

    Bitmap.createScaledBitmap(this, destW, destH, true)
            .rotate(rotate)
            .compress(Bitmap.CompressFormat.JPEG, quality, baos)

    return baos.toByteArray()
}

fun Bitmap.rotate(rotate: Int): Bitmap {
    if (rotate % 360 != 0) {
        val matrix = Matrix()
        matrix.setRotate(rotate.toFloat())
        // 围绕原地进行旋转
        return Bitmap.createBitmap(this, 0, 0, width, height, matrix, false)
    } else {
        return this
    }
}