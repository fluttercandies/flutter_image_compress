package com.fluttercandies.imagecompressexample

import android.util.Log
import androidx.exifinterface.media.ExifInterface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Mirrors the iOS/macOS example test helper (see example/shared/ExifTestHelper.swift).
        // The plugin's public channel intentionally does not expose an EXIF
        // reader; this test-only channel lets integration tests verify what
        // metadata survives the compression pipeline on Android.
        //
        // Returns tags prefixed with a container name so tests can assert
        // survival of both plain EXIF (exif:DateTimeOriginal), TIFF-side
        // (tiff:DateTime, tiff:Make), and GPS (gps:GPSLatitude).
        // Prefix mapping aligns with the CGImageProperty sub-dict names iOS
        // uses so tests can share the same canary constants.
        //
        // The tag inventory here is intentionally broad — it mirrors every
        // tag ExifKeeper attempts to preserve (see
        // flutter_image_compress_common/.../exif/ExifKeeper.java). Keeping
        // the helper's tag list narrower than the writer's would let a
        // regression that shrinks ExifKeeper pass silently — the test would
        // report "kept everything" simply because it wasn't looking at the
        // dropped tag.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "flutter_image_compress/test"
        ).setMethodCallHandler { call, result ->
            if (call.method != "readExifKeys") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val bytes = call.arguments as? ByteArray
            if (bytes == null) {
                Log.w(
                    "ExifTestHelper",
                    "readExifKeys called with wrong argument type: " +
                            "${call.arguments?.javaClass?.name}"
                )
                result.error(
                    "BAD_ARG",
                    "readExifKeys expects a ByteArray; got " +
                            (call.arguments?.javaClass?.name ?: "null"),
                    null,
                )
                return@setMethodCallHandler
            }
            try {
                val exif = ExifInterface(ByteArrayInputStream(bytes))
                val out = mutableListOf<String>()
                for (tag in ANDROID_TAG_PREFIXES) {
                    if (exif.getAttribute(tag.name) != null) {
                        out.add("${tag.prefix}:${tag.displayName}")
                    }
                }
                result.success(out)
            } catch (e: Exception) {
                Log.w("ExifTestHelper", "readExifKeys failed: $e")
                result.success(emptyList<String>())
            }
        }
    }

    // Prefix and displayName pair up so the output keys look like the ones
    // iOS emits from CGImageProperty sub-dicts. The list intentionally mirrors
    // every tag ExifKeeper.java preserves; keep them in sync so a shrinking
    // regression on ExifKeeper stays visible to the tests.
    private data class AndroidExifTag(
        val name: String,
        val prefix: String,
        val displayName: String,
    )

    companion object {
        private val ANDROID_TAG_PREFIXES = listOf(
            // Descriptive / authorship (TIFF-side)
            AndroidExifTag(ExifInterface.TAG_IMAGE_DESCRIPTION, "tiff", "ImageDescription"),
            AndroidExifTag(ExifInterface.TAG_MAKE, "tiff", "Make"),
            AndroidExifTag(ExifInterface.TAG_MODEL, "tiff", "Model"),
            AndroidExifTag(ExifInterface.TAG_SOFTWARE, "tiff", "Software"),
            AndroidExifTag(ExifInterface.TAG_ARTIST, "tiff", "Artist"),
            AndroidExifTag(ExifInterface.TAG_COPYRIGHT, "tiff", "Copyright"),
            AndroidExifTag(ExifInterface.TAG_USER_COMMENT, "exif", "UserComment"),
            // Resolution
            AndroidExifTag(ExifInterface.TAG_X_RESOLUTION, "tiff", "XResolution"),
            AndroidExifTag(ExifInterface.TAG_Y_RESOLUTION, "tiff", "YResolution"),
            AndroidExifTag(ExifInterface.TAG_RESOLUTION_UNIT, "tiff", "ResolutionUnit"),
            AndroidExifTag(ExifInterface.TAG_Y_CB_CR_POSITIONING, "tiff", "YCbCrPositioning"),
            // Date/time
            AndroidExifTag(ExifInterface.TAG_DATETIME, "tiff", "DateTime"),
            AndroidExifTag(ExifInterface.TAG_DATETIME_ORIGINAL, "exif", "DateTimeOriginal"),
            AndroidExifTag(ExifInterface.TAG_DATETIME_DIGITIZED, "exif", "DateTimeDigitized"),
            AndroidExifTag(ExifInterface.TAG_SUBSEC_TIME, "exif", "SubsecTime"),
            AndroidExifTag(ExifInterface.TAG_SUBSEC_TIME_ORIGINAL, "exif", "SubsecTimeOriginal"),
            AndroidExifTag(ExifInterface.TAG_SUBSEC_TIME_DIGITIZED, "exif", "SubsecTimeDigitized"),
            AndroidExifTag(ExifInterface.TAG_OFFSET_TIME, "exif", "OffsetTime"),
            AndroidExifTag(ExifInterface.TAG_OFFSET_TIME_ORIGINAL, "exif", "OffsetTimeOriginal"),
            AndroidExifTag(ExifInterface.TAG_OFFSET_TIME_DIGITIZED, "exif", "OffsetTimeDigitized"),
            // Exposure / capture parameters
            AndroidExifTag(ExifInterface.TAG_EXPOSURE_TIME, "exif", "ExposureTime"),
            AndroidExifTag(ExifInterface.TAG_F_NUMBER, "exif", "FNumber"),
            AndroidExifTag(ExifInterface.TAG_EXPOSURE_PROGRAM, "exif", "ExposureProgram"),
            AndroidExifTag(ExifInterface.TAG_ISO_SPEED_RATINGS, "exif", "ISOSpeedRatings"),
            AndroidExifTag(ExifInterface.TAG_SHUTTER_SPEED_VALUE, "exif", "ShutterSpeedValue"),
            AndroidExifTag(ExifInterface.TAG_APERTURE_VALUE, "exif", "ApertureValue"),
            AndroidExifTag(ExifInterface.TAG_BRIGHTNESS_VALUE, "exif", "BrightnessValue"),
            AndroidExifTag(ExifInterface.TAG_EXPOSURE_BIAS_VALUE, "exif", "ExposureBiasValue"),
            AndroidExifTag(ExifInterface.TAG_MAX_APERTURE_VALUE, "exif", "MaxApertureValue"),
            AndroidExifTag(ExifInterface.TAG_SUBJECT_DISTANCE, "exif", "SubjectDistance"),
            AndroidExifTag(ExifInterface.TAG_METERING_MODE, "exif", "MeteringMode"),
            AndroidExifTag(ExifInterface.TAG_LIGHT_SOURCE, "exif", "LightSource"),
            AndroidExifTag(ExifInterface.TAG_FLASH, "exif", "Flash"),
            AndroidExifTag(ExifInterface.TAG_FOCAL_LENGTH, "exif", "FocalLength"),
            AndroidExifTag(ExifInterface.TAG_FLASH_ENERGY, "exif", "FlashEnergy"),
            AndroidExifTag(ExifInterface.TAG_EXPOSURE_INDEX, "exif", "ExposureIndex"),
            AndroidExifTag(ExifInterface.TAG_SENSITIVITY_TYPE, "exif", "SensitivityType"),
            AndroidExifTag(ExifInterface.TAG_EXPOSURE_MODE, "exif", "ExposureMode"),
            AndroidExifTag(ExifInterface.TAG_WHITE_BALANCE, "exif", "WhiteBalance"),
            AndroidExifTag(ExifInterface.TAG_DIGITAL_ZOOM_RATIO, "exif", "DigitalZoomRatio"),
            AndroidExifTag(ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM, "exif", "FocalLengthIn35mmFilm"),
            AndroidExifTag(ExifInterface.TAG_SCENE_CAPTURE_TYPE, "exif", "SceneCaptureType"),
            AndroidExifTag(ExifInterface.TAG_GAIN_CONTROL, "exif", "GainControl"),
            AndroidExifTag(ExifInterface.TAG_CONTRAST, "exif", "Contrast"),
            AndroidExifTag(ExifInterface.TAG_SATURATION, "exif", "Saturation"),
            AndroidExifTag(ExifInterface.TAG_SHARPNESS, "exif", "Sharpness"),
            AndroidExifTag(ExifInterface.TAG_SUBJECT_DISTANCE_RANGE, "exif", "SubjectDistanceRange"),
            // EXIF metadata versions / color space
            AndroidExifTag(ExifInterface.TAG_EXIF_VERSION, "exif", "ExifVersion"),
            AndroidExifTag(ExifInterface.TAG_FLASHPIX_VERSION, "exif", "FlashpixVersion"),
            AndroidExifTag(ExifInterface.TAG_COLOR_SPACE, "exif", "ColorSpace"),
            AndroidExifTag(ExifInterface.TAG_COMPONENTS_CONFIGURATION, "exif", "ComponentsConfiguration"),
            // Camera lens
            AndroidExifTag(ExifInterface.TAG_LENS_MAKE, "exif", "LensMake"),
            AndroidExifTag(ExifInterface.TAG_LENS_MODEL, "exif", "LensModel"),
            AndroidExifTag(ExifInterface.TAG_LENS_SERIAL_NUMBER, "exif", "LensSerialNumber"),
            AndroidExifTag(ExifInterface.TAG_LENS_SPECIFICATION, "exif", "LensSpecification"),
            AndroidExifTag(ExifInterface.TAG_BODY_SERIAL_NUMBER, "exif", "BodySerialNumber"),
            AndroidExifTag(ExifInterface.TAG_CAMERA_OWNER_NAME, "exif", "CameraOwnerName"),
            AndroidExifTag(ExifInterface.TAG_IMAGE_UNIQUE_ID, "exif", "ImageUniqueID"),
            // GPS
            AndroidExifTag(ExifInterface.TAG_GPS_VERSION_ID, "gps", "GPSVersionID"),
            AndroidExifTag(ExifInterface.TAG_GPS_LATITUDE, "gps", "GPSLatitude"),
            AndroidExifTag(ExifInterface.TAG_GPS_LATITUDE_REF, "gps", "GPSLatitudeRef"),
            AndroidExifTag(ExifInterface.TAG_GPS_LONGITUDE, "gps", "GPSLongitude"),
            AndroidExifTag(ExifInterface.TAG_GPS_LONGITUDE_REF, "gps", "GPSLongitudeRef"),
            AndroidExifTag(ExifInterface.TAG_GPS_ALTITUDE, "gps", "GPSAltitude"),
            AndroidExifTag(ExifInterface.TAG_GPS_ALTITUDE_REF, "gps", "GPSAltitudeRef"),
            AndroidExifTag(ExifInterface.TAG_GPS_TIMESTAMP, "gps", "GPSTimeStamp"),
            AndroidExifTag(ExifInterface.TAG_GPS_DATESTAMP, "gps", "GPSDateStamp"),
        )
    }
}
