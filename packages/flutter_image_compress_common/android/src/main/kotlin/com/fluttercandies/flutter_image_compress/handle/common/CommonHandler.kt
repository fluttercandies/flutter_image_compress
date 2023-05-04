package com.fluttercandies.flutter_image_compress.handle.common

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.fluttercandies.flutter_image_compress.exif.ExifKeeper
import com.fluttercandies.flutter_image_compress.ext.calcScale
import com.fluttercandies.flutter_image_compress.ext.compress
import com.fluttercandies.flutter_image_compress.ext.rotate
import com.fluttercandies.flutter_image_compress.handle.FormatHandler
import com.fluttercandies.flutter_image_compress.logger.log
import java.io.ByteArrayOutputStream
import java.io.OutputStream

class CommonHandler(override val type: Int) : FormatHandler {
    override val typeName: String = when (type) {
        1 -> "png"
        3 -> "webp"
        else -> "jpeg"
    }

    private val bitmapFormat: Bitmap.CompressFormat = when (type) {
        1 -> Bitmap.CompressFormat.PNG
        3 -> Bitmap.CompressFormat.WEBP
        else -> Bitmap.CompressFormat.JPEG
    }

    override fun handleByteArray(
        context: Context,
        byteArray: ByteArray,
        outputStream: OutputStream,
        minWidth: Int,
        minHeight: Int,
        quality: Int,
        rotate: Int,
        keepExif: Boolean,
        inSampleSize: Int
    ) {
        val result = compress(byteArray, minWidth, minHeight, quality, rotate, inSampleSize)
        if (keepExif && bitmapFormat == Bitmap.CompressFormat.JPEG) {
            val byteArrayOutputStream = ByteArrayOutputStream()
            byteArrayOutputStream.write(result)
            val resultStream = ExifKeeper(byteArray).writeToOutputStream(
                context,
                byteArrayOutputStream
            )
            outputStream.write(resultStream.toByteArray())
        } else {
            outputStream.write(result)
        }
    }

    private fun compress(
        arr: ByteArray,
        minWidth: Int,
        minHeight: Int,
        quality: Int,
        rotate: Int = 0,
        inSampleSize: Int
    ): ByteArray {
        val options = BitmapFactory.Options()
        options.inJustDecodeBounds = false
        options.inPreferredConfig = Bitmap.Config.RGB_565
        options.inSampleSize = inSampleSize
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
            @Suppress("DEPRECATION")
            options.inDither = true
        }
        val bitmap = BitmapFactory.decodeByteArray(arr, 0, arr.count(), options)
        val outputStream = ByteArrayOutputStream()
        val w = bitmap.width.toFloat()
        val h = bitmap.height.toFloat()
        log("src width = $w")
        log("src height = $h")
        val scale = bitmap.calcScale(minWidth, minHeight)
        log("scale = $scale")
        val destW = w / scale
        val destH = h / scale
        log("dst width = $destW")
        log("dst height = $destH")
        Bitmap.createScaledBitmap(
            bitmap, destW.toInt(),
            destH.toInt(),
            true
        ).rotate(rotate).compress(bitmapFormat, quality, outputStream)
        return outputStream.toByteArray()
    }


    override fun handleFile(
        context: Context,
        path: String,
        outputStream: OutputStream,
        minWidth: Int,
        minHeight: Int,
        quality: Int,
        rotate: Int,
        keepExif: Boolean,
        inSampleSize: Int,
        numberOfRetries: Int
    ) {
        try {
            if (numberOfRetries <= 0) return;
            val options = BitmapFactory.Options()
            options.inJustDecodeBounds = false
            options.inPreferredConfig = Bitmap.Config.RGB_565
            options.inSampleSize = inSampleSize
            if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
                @Suppress("DEPRECATION")
                options.inDither = true
            }
            val bitmap = BitmapFactory.decodeFile(path, options)
            val array = bitmap.compress(minWidth, minHeight, quality, rotate, type)
            if (keepExif && bitmapFormat == Bitmap.CompressFormat.JPEG) {
                val byteArrayOutputStream = ByteArrayOutputStream()
                byteArrayOutputStream.write(array)
                val tmpOutputStream = ExifKeeper(path).writeToOutputStream(
                    context,
                    byteArrayOutputStream
                )
                outputStream.write(tmpOutputStream.toByteArray())
            } else {
                outputStream.write(array)
            }
        } catch (e: OutOfMemoryError) {//handling out of memory error and increase samples size
            System.gc();
            handleFile(
                context,
                path,
                outputStream,
                minWidth,
                minHeight,
                quality,
                rotate,
                keepExif,
                inSampleSize * 2,
                numberOfRetries - 1
            );
        }
    }
}
