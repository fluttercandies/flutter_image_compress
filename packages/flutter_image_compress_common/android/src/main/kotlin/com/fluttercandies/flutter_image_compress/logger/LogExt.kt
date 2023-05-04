package com.fluttercandies.flutter_image_compress.logger

import android.util.Log
import com.fluttercandies.flutter_image_compress.ImageCompressPlugin

fun log(any: Any?) {
  if (ImageCompressPlugin.showLog) {
    Log.i("flutter_image_compress", any?.toString() ?: "null")
  }
}
