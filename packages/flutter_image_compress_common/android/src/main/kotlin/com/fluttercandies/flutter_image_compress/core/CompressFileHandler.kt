package com.fluttercandies.flutter_image_compress.core

import android.content.Context
import com.fluttercandies.flutter_image_compress.ImageCompressPlugin
import com.fluttercandies.flutter_image_compress.exif.Exif
import com.fluttercandies.flutter_image_compress.format.FormatRegister
import com.fluttercandies.flutter_image_compress.logger.log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.OutputStream

class CompressFileHandler(private val call: MethodCall, result: MethodChannel.Result) : ResultHandler(result) {
    fun handle(context: Context) {
        threadPool.execute {
            @Suppress("UNCHECKED_CAST")
            val args: List<Any> = call.arguments as List<Any>
            val filePath = args[0] as String
            var minWidth = args[1] as Int
            var minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            val autoCorrectionAngle = args[5] as Boolean
            val format = args[6] as Int
            val keepExif = args[7] as Boolean
            val inSampleSize = args[8] as Int
            val numberOfRetries = args[9] as Int
            val formatHandler = FormatRegister.findFormat(format)
            if (formatHandler == null) {
                log("No support format.")
                replyError("unsupported_format", "No handler for format=$format")
                return@execute
            }
            val outputStream = ByteArrayOutputStream()
            try {
                val exifRotate = if (autoCorrectionAngle) {
                    val bytes = File(filePath).readBytes()
                    Exif.getRotationDegrees(bytes)
                } else {
                    0
                }
                if (exifRotate == 270 || exifRotate == 90) {
                    val tmp = minWidth
                    minWidth = minHeight
                    minHeight = tmp
                }
                val targetRotate = rotate + exifRotate
                formatHandler.handleFile(
                    context,
                    filePath,
                    outputStream,
                    minWidth,
                    minHeight,
                    quality,
                    targetRotate,
                    keepExif,
                    inSampleSize,
                    numberOfRetries
                )
                reply(outputStream.toByteArray())
            } catch (e: Exception) {
                if (ImageCompressPlugin.showLog) e.printStackTrace()
                replyError("unknown", e.message ?: "compress failed")
            } finally {
                outputStream.close()
            }
        }
    }

    fun handleGetFile(context: Context) {
        threadPool.execute {
            @Suppress("UNCHECKED_CAST")
            val args: List<Any> = call.arguments as List<Any>
            val file = args[0] as String
            var minWidth = args[1] as Int
            var minHeight = args[2] as Int
            val quality = args[3] as Int
            val targetPath = args[4] as String
            val rotate = args[5] as Int
            val autoCorrectionAngle = args[6] as Boolean
            val format = args[7] as Int
            val keepExif = args[8] as Boolean
            val inSampleSize = args[9] as Int
            val numberOfRetries = args[10] as Int
            val formatHandler = FormatRegister.findFormat(format)
            if (formatHandler == null) {
                log("No support format.")
                replyError("unsupported_format", "No handler for format=$format")
                return@execute
            }
            var outputStream: OutputStream? = null
            try {
                val exifRotate = if (autoCorrectionAngle) {
                    Exif.getRotationDegrees(File(file))
                } else {
                    0
                }
                if (exifRotate == 270 || exifRotate == 90) {
                    val tmp = minWidth
                    minWidth = minHeight
                    minHeight = tmp
                }
                val targetRotate = rotate + exifRotate
                File(targetPath).parentFile?.mkdirs()
                outputStream = File(targetPath).outputStream()
                formatHandler.handleFile(
                    context,
                    file,
                    outputStream,
                    minWidth,
                    minHeight,
                    quality,
                    targetRotate,
                    keepExif,
                    inSampleSize,
                    numberOfRetries
                )
                reply(targetPath)
            } catch (e: Exception) {
                if (ImageCompressPlugin.showLog) e.printStackTrace()
                replyError("unknown", e.message ?: "compress failed")
            } finally {
                outputStream?.close()
            }
        }
    }
}
