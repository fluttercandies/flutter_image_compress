package com.fluttercandies.flutter_image_compress.format

import android.util.SparseArray
import com.fluttercandies.flutter_image_compress.handle.FormatHandler

object FormatRegister {
    private val formatMap = SparseArray<FormatHandler>()

    fun registerFormat(handler: FormatHandler) {
        formatMap.append(handler.type, handler)
    }

    fun findFormat(formatIndex: Int): FormatHandler? {
        return formatMap.get(formatIndex)
    }

}