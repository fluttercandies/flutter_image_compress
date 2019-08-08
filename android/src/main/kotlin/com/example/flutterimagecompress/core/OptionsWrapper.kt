package com.example.flutterimagecompress.core

import android.graphics.BitmapFactory

/// create 2019-08-08 by cai

class OptionsWrapper {
    val options = BitmapFactory.Options();

    init {
        options.inJustDecodeBounds = true
    }

    fun calculateInSampleSize(needWidth: Int, needHeight: Int) {
        val originalWidth = options.outWidth
        val originalHeight = options.outHeight
        var inSampleSize = 1
        if (originalHeight > needHeight || originalWidth > needHeight) {
            val halfHeight = originalHeight / 2
            val halfWidth = originalWidth / 2
            while (halfWidth / inSampleSize >= needHeight && halfHeight / inSampleSize >= needWidth) {
                inSampleSize *= 2
            }
        }
        options.inSampleSize = inSampleSize
        com.example.flutterimagecompress.ext.log("sample size = $inSampleSize")
        options.inJustDecodeBounds = false
    }
}