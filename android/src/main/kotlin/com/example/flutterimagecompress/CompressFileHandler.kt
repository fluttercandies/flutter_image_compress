package com.example.flutterimagecompress

import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class CompressFileHandler(private var call: MethodCall, result: MethodChannel.Result) : ResultHandler(result) {

    companion object {
        @JvmStatic
        private val executor = Executors.newFixedThreadPool(5)
    }

    fun handle() {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val file = args[0] as String
            val minWidth = args[1] as Int
            val minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            val autoCorrectionAngle = args[5] as Boolean

            val exifRotate =
                    if (autoCorrectionAngle) {
                        val bytes = File(file).readBytes()
                        Exif.getRotationDegrees(bytes)
                    } else {
                        0
                    }

            try {
                val bitmap = BitmapFactory.decodeFile(file)
                val array = bitmap.compress(minWidth, minHeight, quality, rotate + exifRotate)
                reply(array)
            } catch (e: Exception) {
                if (FlutterImageCompressPlugin.showLog) e.printStackTrace()
                reply(null)
            }
        }
    }

    fun handleGetFile() {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val file = args[0] as String
            val minWidth = args[1] as Int
            val minHeight = args[2] as Int
            val quality = args[3] as Int
            val targetPath = args[4] as String
            val rotate = args[5] as Int
            val autoCorrectionAngle = args[6] as Boolean
            val exifRotate =
                    if (autoCorrectionAngle) {
                        val bytes = File(file).readBytes()
                        Exif.getRotationDegrees(bytes)
                    } else {
                        0
                    }
            try {
                val bitmap = BitmapFactory.decodeFile(file)
                val outputStream = File(targetPath).outputStream()
                outputStream.use {
                    bitmap.compress(minWidth, minHeight, quality, rotate + exifRotate, outputStream)
                }
                reply(targetPath)
            } catch (e: Exception) {
                if (FlutterImageCompressPlugin.showLog) e.printStackTrace()
                reply(null)
            }
        }
    }

}