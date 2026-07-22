package com.fluttercandies.flutter_image_compress.exif;
/// create 2019-07-02 by cai

import android.content.Context;
import android.util.Log;

import org.apache.commons.io.IOUtils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import androidx.exifinterface.media.ExifInterface;

public class ExifKeeper {
    // Tags copied from the source image to the re-encoded output. We reference
    // ExifInterface.TAG_* constants (compile-time strings) so the list stays in
    // sync with the library. We intentionally skip:
    //   - fields invalidated by re-encoding / resizing:
    //       TAG_IMAGE_WIDTH, TAG_IMAGE_LENGTH, TAG_PIXEL_X_DIMENSION,
    //       TAG_PIXEL_Y_DIMENSION
    //   - JPEG structural fields the encoder rewrites:
    //       TAG_BITS_PER_SAMPLE, TAG_COMPRESSION, TAG_SAMPLES_PER_PIXEL,
    //       TAG_ROWS_PER_STRIP, TAG_STRIP_BYTE_COUNTS, TAG_STRIP_OFFSETS,
    //       TAG_PHOTOMETRIC_INTERPRETATION, TAG_PLANAR_CONFIGURATION
    //   - thumbnail pointers/data:
    //       TAG_JPEG_INTERCHANGE_FORMAT, TAG_JPEG_INTERCHANGE_FORMAT_LENGTH,
    //       and all TAG_THUMBNAIL_*
    private static final List<String> attributes = Arrays.asList(
            // Descriptive / authorship
            ExifInterface.TAG_IMAGE_DESCRIPTION,
            ExifInterface.TAG_MAKE,
            ExifInterface.TAG_MODEL,
            ExifInterface.TAG_SOFTWARE,
            ExifInterface.TAG_ARTIST,
            ExifInterface.TAG_COPYRIGHT,
            ExifInterface.TAG_USER_COMMENT,

            // Orientation and resolution
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.TAG_X_RESOLUTION,
            ExifInterface.TAG_Y_RESOLUTION,
            ExifInterface.TAG_RESOLUTION_UNIT,
            ExifInterface.TAG_Y_CB_CR_POSITIONING,

            // Date/time
            ExifInterface.TAG_DATETIME,
            ExifInterface.TAG_DATETIME_ORIGINAL,
            ExifInterface.TAG_DATETIME_DIGITIZED,
            ExifInterface.TAG_SUBSEC_TIME,
            ExifInterface.TAG_SUBSEC_TIME_ORIGINAL,
            ExifInterface.TAG_SUBSEC_TIME_DIGITIZED,
            ExifInterface.TAG_OFFSET_TIME,
            ExifInterface.TAG_OFFSET_TIME_ORIGINAL,
            ExifInterface.TAG_OFFSET_TIME_DIGITIZED,

            // Exposure / capture parameters
            ExifInterface.TAG_EXPOSURE_TIME,
            ExifInterface.TAG_F_NUMBER,
            ExifInterface.TAG_EXPOSURE_PROGRAM,
            ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY,
            ExifInterface.TAG_SHUTTER_SPEED_VALUE,
            ExifInterface.TAG_APERTURE_VALUE,
            ExifInterface.TAG_BRIGHTNESS_VALUE,
            ExifInterface.TAG_EXPOSURE_BIAS_VALUE,
            ExifInterface.TAG_MAX_APERTURE_VALUE,
            ExifInterface.TAG_SUBJECT_DISTANCE,
            ExifInterface.TAG_METERING_MODE,
            ExifInterface.TAG_LIGHT_SOURCE,
            ExifInterface.TAG_FLASH,
            ExifInterface.TAG_FOCAL_LENGTH,
            ExifInterface.TAG_FLASH_ENERGY,
            ExifInterface.TAG_EXPOSURE_INDEX,
            ExifInterface.TAG_SENSITIVITY_TYPE,
            ExifInterface.TAG_EXPOSURE_MODE,
            ExifInterface.TAG_WHITE_BALANCE,
            ExifInterface.TAG_DIGITAL_ZOOM_RATIO,
            ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM,
            ExifInterface.TAG_SCENE_CAPTURE_TYPE,
            ExifInterface.TAG_GAIN_CONTROL,
            ExifInterface.TAG_CONTRAST,
            ExifInterface.TAG_SATURATION,
            ExifInterface.TAG_SHARPNESS,
            ExifInterface.TAG_SUBJECT_DISTANCE_RANGE,

            // EXIF metadata versions / color space
            ExifInterface.TAG_EXIF_VERSION,
            ExifInterface.TAG_FLASHPIX_VERSION,
            ExifInterface.TAG_COLOR_SPACE,
            ExifInterface.TAG_COMPONENTS_CONFIGURATION,

            // Camera lens
            ExifInterface.TAG_LENS_MAKE,
            ExifInterface.TAG_LENS_MODEL,
            ExifInterface.TAG_LENS_SERIAL_NUMBER,
            ExifInterface.TAG_LENS_SPECIFICATION,
            ExifInterface.TAG_BODY_SERIAL_NUMBER,
            ExifInterface.TAG_CAMERA_OWNER_NAME,

            // Image identifiers
            ExifInterface.TAG_IMAGE_UNIQUE_ID,

            // GPS
            ExifInterface.TAG_GPS_VERSION_ID,
            ExifInterface.TAG_GPS_LATITUDE,
            ExifInterface.TAG_GPS_LATITUDE_REF,
            ExifInterface.TAG_GPS_LONGITUDE,
            ExifInterface.TAG_GPS_LONGITUDE_REF,
            ExifInterface.TAG_GPS_ALTITUDE,
            ExifInterface.TAG_GPS_ALTITUDE_REF,
            ExifInterface.TAG_GPS_TIMESTAMP,
            ExifInterface.TAG_GPS_DATESTAMP,
            ExifInterface.TAG_GPS_SATELLITES,
            ExifInterface.TAG_GPS_STATUS,
            ExifInterface.TAG_GPS_MEASURE_MODE,
            ExifInterface.TAG_GPS_DOP,
            ExifInterface.TAG_GPS_SPEED,
            ExifInterface.TAG_GPS_SPEED_REF,
            ExifInterface.TAG_GPS_TRACK,
            ExifInterface.TAG_GPS_TRACK_REF,
            ExifInterface.TAG_GPS_IMG_DIRECTION,
            ExifInterface.TAG_GPS_IMG_DIRECTION_REF,
            ExifInterface.TAG_GPS_MAP_DATUM,
            ExifInterface.TAG_GPS_DEST_LATITUDE,
            ExifInterface.TAG_GPS_DEST_LATITUDE_REF,
            ExifInterface.TAG_GPS_DEST_LONGITUDE,
            ExifInterface.TAG_GPS_DEST_LONGITUDE_REF,
            ExifInterface.TAG_GPS_DEST_BEARING,
            ExifInterface.TAG_GPS_DEST_BEARING_REF,
            ExifInterface.TAG_GPS_DEST_DISTANCE,
            ExifInterface.TAG_GPS_DEST_DISTANCE_REF,
            ExifInterface.TAG_GPS_PROCESSING_METHOD,
            ExifInterface.TAG_GPS_AREA_INFORMATION,
            ExifInterface.TAG_GPS_DIFFERENTIAL,
            ExifInterface.TAG_GPS_H_POSITIONING_ERROR
    );

    private final ExifInterface oldExif;

    public ExifKeeper(String filePath) throws IOException {
        this.oldExif = new ExifInterface(filePath);
    }

    public ExifKeeper(byte[] buf) throws IOException {
        this.oldExif = new ExifInterface(new ByteArrayInputStream(buf));
    }

    private static void copyExif(ExifInterface oldExif, ExifInterface newExif) {
        for (String attribute : attributes) {
            setIfNotNull(oldExif, newExif, attribute);
        }
        // Output pixels are re-encoded in display orientation by the pipeline
        // (BitmapFactory decode + optional Bitmap.rotate before compress), so the
        // source's TAG_ORIENTATION must not carry over — otherwise viewers double-rotate.
        newExif.setAttribute(
                ExifInterface.TAG_ORIENTATION,
                String.valueOf(ExifInterface.ORIENTATION_NORMAL)
        );
        try {
            newExif.saveAttributes();
        } catch (IOException ignored) {
        }
    }

    private static void setIfNotNull(ExifInterface oldExif, ExifInterface newExif, String property) {
        if (oldExif.getAttribute(property) != null) {
            newExif.setAttribute(property, oldExif.getAttribute(property));
        }
    }

    public ByteArrayOutputStream writeToOutputStream(Context context, ByteArrayOutputStream outputStream) {
        FileOutputStream fileOutputStream = null;
        FileInputStream fileInputStream = null;
        File file = null;
        try {
            String uuid = UUID.randomUUID().toString();
            file = new File(context.getCacheDir(), uuid + ".jpg");
            fileOutputStream = new FileOutputStream(file);
            IOUtils.write(outputStream.toByteArray(), fileOutputStream);
            fileOutputStream.close();
            ExifInterface newExif = new ExifInterface(file.getAbsolutePath());
            copyExif(oldExif, newExif);
            newExif.saveAttributes();
            fileOutputStream.close();
            ByteArrayOutputStream newStream = new ByteArrayOutputStream();
            fileInputStream = new FileInputStream(file);
            IOUtils.copy(fileInputStream, newStream);
            fileInputStream.close();
            return newStream;
        } catch (Exception ex) {
            Log.e("ExifDataCopier", "Error preserving Exif data on selected image: " + ex);
        } finally {
            if (fileInputStream != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (fileOutputStream != null) {
                try {
                    fileOutputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (file != null) {
                //noinspection ResultOfMethodCallIgnored
                file.delete();
            }
        }
        return outputStream;
    }

    public void copyExifToFile(File file) {
        try {
            ExifInterface newExif = new ExifInterface(file.getAbsolutePath());
            copyExif(oldExif, newExif);
            newExif.saveAttributes();
        } catch (IOException ignored) {
        }
    }
}
