package com.example.flutterimagecompress

private fun getUint16(bytes: List<Int>, offset: Int, littleEndian: Boolean): Int {
    val value = (bytes[offset] shl 8) or bytes[offset + 1]
    return if (littleEndian) value.reverseBytes() else value
}

private fun getUint32(bytes: List<Int>, offset: Int, littleEndian: Boolean): Int {
    val value = (bytes[offset] shl 24) or (bytes[offset + 1] shl 16) or (bytes[offset + 2] shl 8) or bytes[offset + 3]
    return if (littleEndian) value.reverseBytes() else value
}

fun Int.reverseBytes(): Int {
    val v0 = ((this ushr 0) and 0xFF)
    val v1 = ((this ushr 8) and 0xFF)
    val v2 = ((this ushr 16) and 0xFF)
    val v3 = ((this ushr 24) and 0xFF)
    return (v0 shl 24) or (v1 shl 16) or (v2 shl 8) or (v3 shl 0)
}

object Exif {
    fun getRotationDegrees(_bytes: ByteArray): Int {
        val bytes = _bytes.take(64 * 1024).map { b -> b.toInt() and 0xff }

        if (getUint16(bytes, 0, false) != 0xffd8) {
            return 0
        }

        val length = bytes.size
        var offset = 2

        while (offset < length) {
            val marker = getUint16(bytes, offset, false)
            offset += 2

            if (marker == 0xffe1) {
                if (getUint32(bytes, offset + 2, false) != 0x45786966) {
                    return 0
                }
                offset += 2

                val little = getUint16(bytes, offset + 6, false) == 0x4949
                offset += 6

                offset += getUint32(bytes, offset + 4, little)

                val tags = getUint16(bytes, offset, little)
                offset += 2

                for (idx in 0..tags) {
                    if (getUint16(bytes, offset + (idx * 12), little) == 0x0112) {
                        when (getUint16(bytes, offset + (idx * 12) + 8, little)) {
                            1 -> return 0
                            3 -> return 180
                            6 -> return 90
                            8 -> return 270
                        }
                    }
                }
            } else if (marker and 0xff00 != 0xff00) {
                break
            } else {
                offset += getUint16(bytes, offset, false)
            }
        }

        return 0
    }
}