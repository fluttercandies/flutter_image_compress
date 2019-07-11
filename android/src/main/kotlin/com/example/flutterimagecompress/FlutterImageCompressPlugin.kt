package com.example.flutterimagecompress

import com.example.flutterimagecompress.core.CompressFileHandler
import com.example.flutterimagecompress.core.CompressListHandler
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
            channel.setMethodCallHandler(FlutterImageCompressPlugin(registrar))
        }

        var showLog = false
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when (call.method) {
            "showLog" -> result.success(handleLog(call))
            "compressWithList" -> CompressListHandler(call, result).handle(registrar)
            "compressWithFile" -> CompressFileHandler(call, result).handle(registrar)
            "compressWithFileAndGetFile" -> CompressFileHandler(call, result).handleGetFile()
            else -> result.notImplemented()
        }
    }

    private fun handleLog(call: MethodCall): Int {
        val arg = call.arguments<Boolean>()
        showLog = (arg == true)
        return 1
    }

}
