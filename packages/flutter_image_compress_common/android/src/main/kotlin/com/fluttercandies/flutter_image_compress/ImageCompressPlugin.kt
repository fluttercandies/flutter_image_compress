package com.fluttercandies.flutter_image_compress

import android.content.Context
import android.os.Build
import com.fluttercandies.flutter_image_compress.core.CompressFileHandler
import com.fluttercandies.flutter_image_compress.core.CompressListHandler
import com.fluttercandies.flutter_image_compress.format.FormatRegister
import com.fluttercandies.flutter_image_compress.handle.common.CommonHandler
import com.fluttercandies.flutter_image_compress.handle.heif.HeifHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ImageCompressPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var context: Context
    private var channel: MethodChannel? = null

    companion object {
        var showLog = false
    }

    init {
        FormatRegister.registerFormat(CommonHandler(0)) // jpeg
        FormatRegister.registerFormat(CommonHandler(1)) // png
        FormatRegister.registerFormat(HeifHandler()) // heic / heif
        FormatRegister.registerFormat(CommonHandler(3)) // webp
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "showLog" -> result.success(handleLog(call))
            "compressWithList" -> CompressListHandler(call, result).handle(context)
            "compressWithFile" -> CompressFileHandler(call, result).handle(context)
            "compressWithFileAndGetFile" -> CompressFileHandler(call, result).handleGetFile(context)
            "getSystemVersion" -> result.success(Build.VERSION.SDK_INT)
            else -> result.notImplemented()
        }
    }

    private fun handleLog(call: MethodCall): Int {
        val arg = call.arguments<Boolean>()
        showLog = (arg == true)
        return 1
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_image_compress")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
