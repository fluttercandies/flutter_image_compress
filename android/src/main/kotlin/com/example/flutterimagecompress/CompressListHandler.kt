package com.example.flutterimagecompress

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class CompressListHandler(var call: MethodCall, result: MethodChannel.Result) : ResultHandler(result) {

    companion object {
        @JvmStatic
        private val executor = Executors.newFixedThreadPool(5)
    }

    fun handle() {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val arr = args[0] as ByteArray
            val minWidth = args[1] as Int
            val minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            val autoCorrectionAngle = args[5] as Boolean
            try {
                reply(compress(arr, minWidth, minHeight, quality, rotate, autoCorrectionAngle))
            } catch (e: Exception) {
                if (FlutterImageCompressPlugin.showLog) e.printStackTrace()
                reply(null)
            }
        }
    }

    private fun compress(arr: ByteArray, minWidth: Int, minHeight: Int, quality: Int, rotate: Int = 0, autoCorrectionAngle: Boolean): ByteArray {
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

        val exifRotate = if (autoCorrectionAngle) Exif.getRotationDegrees(arr) else 0

        Bitmap.createScaledBitmap(bitmap, destW.toInt(), destH.toInt(), true)
                .rotate(rotate + exifRotate)
                .compress(Bitmap.CompressFormat.JPEG, quality, outputStream)

        return outputStream.toByteArray()
    }

}

private fun log(any: Any?) {
    if (FlutterImageCompressPlugin.showLog) {
        println(any ?: "null")
    }
}