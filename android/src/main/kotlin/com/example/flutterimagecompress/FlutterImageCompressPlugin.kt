package com.example.flutterimagecompress

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterImageCompressPlugin() : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "flutter_image_compress")
            channel.setMethodCallHandler(FlutterImageCompressPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "compressWithList" -> CompressListHandler(call, result).handle()
            "compressWithFile" -> CompressFileHandler(call, result).handle()
            "compressWithFileAndGetFile" -> CompressFileHandler(call, result).handleGetFile()
            else -> result.notImplemented()
        }
    }
}
