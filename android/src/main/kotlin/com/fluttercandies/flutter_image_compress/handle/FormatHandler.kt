package com.fluttercandies.flutter_image_compress.handle

import android.content.Context
import java.io.OutputStream

interface FormatHandler {

  val type: Int

  val typeName: String

  fun handleByteArray(context: Context, byteArray: ByteArray, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int)

  fun handleFile(context: Context, path: String, outputStream: OutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int, keepExif: Boolean, inSampleSize: Int,numberOfRetries:Int)
}