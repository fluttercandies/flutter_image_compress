package com.example.flutterimagecompress.core.heif

import com.nokia.heif.HEIF

/// create 2020-01-10 by cai
typealias NByteArrayInputStream = com.nokia.heif.io.ByteArrayInputStream

typealias NByteArrayOutputStream = com.nokia.heif.io.ByteArrayOutputStream

interface HeicHandler {
  
  fun isHeic(format: Int): Boolean {
    return format == 2
  }
  
  fun handleImage(inputData: NByteArrayInputStream, outputStream: NByteArrayOutputStream, minWidth: Int, minHeight: Int, quality: Int, rotate: Int) {
    val heif = HEIF()
    heif.load(inputData)
    heif.save(outputStream)
  }
  
}