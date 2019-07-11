package com.example.flutterimagecompress.core

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.example.flutterimagecompress.FlutterImageCompressPlugin
import com.example.flutterimagecompress.exif.Exif
import com.example.flutterimagecompress.exif.ExifKeeper
import com.example.flutterimagecompress.ext.calcScale
import com.example.flutterimagecompress.ext.convertFormatIndexToFormat
import com.example.flutterimagecompress.ext.rotate
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class CompressListHandler(private val call: MethodCall, result: MethodChannel.Result) : ResultHandler(result) {

    companion object {
        @JvmStatic
        private val executor = Executors.newFixedThreadPool(5)
    }

    fun handle(registrar: PluginRegistry.Registrar) {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val arr = args[0] as ByteArray
            var minWidth = args[1] as Int
            var minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            val autoCorrectionAngle = args[5] as Boolean
            val format = args[6] as Int
            val keepExif = args[7] as Boolean

            val exifRotate = if (autoCorrectionAngle) Exif.getRotationDegrees(arr) else 0

            if (exifRotate == 270 || exifRotate == 90) {
                val tmp = minWidth
                minWidth = minHeight
                minHeight = tmp
            }

            try {
                val bytes = compress(arr, minWidth, minHeight, quality, rotate + exifRotate, format)

                if (keepExif) {
                    val keeper = ExifKeeper(arr)
                    val outputStream = ByteArrayOutputStream().apply { write(bytes) }
                    val resultStream = keeper.writeToOutputStream(
                            registrar.context().applicationContext,
                            outputStream
                    )
                    reply(resultStream.toByteArray())
                    return@execute
                }

                reply(bytes)
            } catch (e: Exception) {
                if (FlutterImageCompressPlugin.showLog) e.printStackTrace()
                reply(null)
            }
        }
    }

    private fun compress(arr: ByteArray, minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0, format: Int): ByteArray {
        val bitmap = BitmapFactory.decodeByteArray(arr, 0, arr.count())
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

        Bitmap.createScaledBitmap(bitmap, destW.toInt(), destH.toInt(), true)
                .rotate(rotate)
                .compress(convertFormatIndexToFormat(format), quality, outputStream)

        return outputStream.toByteArray()
    }

}

private fun log(any: Any?) {
    if (FlutterImageCompressPlugin.showLog) {
        println(any ?: "null")
    }
}