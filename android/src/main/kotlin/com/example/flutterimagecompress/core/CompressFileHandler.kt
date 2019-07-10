package com.example.flutterimagecompress.core

import android.graphics.BitmapFactory
import com.example.flutterimagecompress.FlutterImageCompressPlugin
import com.example.flutterimagecompress.exif.Exif
import com.example.flutterimagecompress.exif.ExifKeeper
import com.example.flutterimagecompress.ext.compress
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

class CompressFileHandler(private val call: MethodCall, result: MethodChannel.Result) : ResultHandler(result) {

    companion object {
        @JvmStatic
        private val executor = Executors.newFixedThreadPool(5)
    }

    fun handle(registrar: PluginRegistry.Registrar) {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val file = args[0] as String
            var minWidth = args[1] as Int
            var minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            val autoCorrectionAngle = args[5] as Boolean
            val format = args[6] as Int
            val keepExif = args[7] as Boolean

            val exifRotate =
                    if (autoCorrectionAngle) {
                        val bytes = File(file).readBytes()
                        Exif.getRotationDegrees(bytes)
                    } else {
                        0
                    }

            try {
                if (exifRotate == 270 || exifRotate == 90) {
                    val tmp = minWidth
                    minWidth = minHeight
                    minHeight = tmp
                }

                val bitmap = BitmapFactory.decodeFile(file)
                val array = bitmap.compress(minWidth, minHeight, quality, rotate + exifRotate, format)

                if (keepExif) {
                    val byteArrayOutputStream = ByteArrayOutputStream()
                    byteArrayOutputStream.write(array)
                    val outputStream = ExifKeeper(file).writeToOutputStream(
                            registrar.context().applicationContext,
                            byteArrayOutputStream
                    )
                    reply(outputStream.toByteArray())
                    return@execute
                }

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
            var minWidth = args[1] as Int
            var minHeight = args[2] as Int
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
            val format = args[7] as Int
            val keepExif = args[8] as Boolean

            try {
                val bitmap = BitmapFactory.decodeFile(file)
                val outputStream = File(targetPath).outputStream()
                outputStream.use {
                    if (exifRotate == 270 || exifRotate == 90) {
                        val tmp = minWidth
                        minWidth = minHeight
                        minHeight = tmp
                    }
                    bitmap.compress(minWidth, minHeight, quality, rotate + exifRotate, outputStream, format)
                }

                if (keepExif) {
                    ExifKeeper(file).copyExifToFile(File(targetPath))
                    return@execute
                }

                reply(targetPath)
            } catch (e: Exception) {
                if (FlutterImageCompressPlugin.showLog) e.printStackTrace()
                reply(null)
            }
        }
    }

}