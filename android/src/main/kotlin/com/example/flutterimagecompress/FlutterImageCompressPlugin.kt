package com.example.flutterimagecompress

import android.os.Build
import com.example.flutterimagecompress.core.CompressFileHandler
import com.example.flutterimagecompress.core.CompressListHandler
import com.example.flutterimagecompress.format.FormatRegister
import com.example.flutterimagecompress.handle.common.CommonHandler
import com.example.flutterimagecompress.handle.heif.HeifHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterImageCompressPlugin(private val registrar: Registrar) : MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "flutter_image_compress")
      val flutterImageCompressPlugin = FlutterImageCompressPlugin(registrar)
      channel.setMethodCallHandler(flutterImageCompressPlugin)
    }

    var showLog = false
  }

  init {
    FormatRegister.registerFormat(CommonHandler(0)) // jpeg
    FormatRegister.registerFormat(CommonHandler(1)) // png
    FormatRegister.registerFormat(HeifHandler()) // heic / heif
    FormatRegister.registerFormat(CommonHandler(3)) // webp
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    when (call.method) {
      "showLog" -> result.success(handleLog(call))
      "compressWithList" -> CompressListHandler(call, result).handle(registrar)
      "compressWithFile" -> CompressFileHandler(call, result).handle(registrar)
      "compressWithFileAndGetFile" -> CompressFileHandler(call, result).handleGetFile(registrar)
      "getSystemVersion" -> result.success(Build.VERSION.SDK_INT)
      else -> result.notImplemented()
    }
  }

  private fun handleLog(call: MethodCall): Int {
    val arg = call.arguments<Boolean>()
    showLog = (arg == true)
    return 1
  }

}
