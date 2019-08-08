package com.example.flutterimagecompress.core;
/// create 2019-08-08 by cai


import android.graphics.BitmapFactory;

public class BitmapOptionHelper {

    private static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        int originalWidth = options.outWidth;
        int originalHeight = options.outHeight;
        int inSampleSize = 1;
        if (originalHeight > reqHeight || originalWidth > reqHeight) {
            int halfHeight = originalHeight / 2;
            int halfWidth = originalWidth / 2;
            //压缩后的尺寸与所需的尺寸进行比较
            while ((halfWidth / inSampleSize) >= reqHeight && (halfHeight / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }
        return inSampleSize;
    }
}
