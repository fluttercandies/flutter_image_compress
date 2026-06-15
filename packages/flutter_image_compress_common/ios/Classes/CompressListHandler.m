//
//  CompressListHandler.m
//  flutter_image_compress
//
//  Created by cjl on 2018/9/8.
//

#import <Flutter/Flutter.h>
#import "CompressListHandler.h"
#import "CompressHandler.h"
#import "SYMetadata.h"
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <SDWebImage/SDWebImage.h>
#import <libwebp/encode.h>
#import <libwebp/decode.h>
#import <libwebp/mux.h>
#import <ImageIO/ImageIO.h>

@implementation CompressListHandler

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *args = call.arguments;
    FlutterStandardTypedData *list = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    int rotate = [args[4] intValue];
    int formatType = [args[6] intValue];

    BOOL keepExif = [args[7] boolValue];

    NSData *data = [list data];

    if (!data || data.length == 0) {
        result(nil);
        return;
    }

    NSString *imageType = [self mimeTypeByGuessingFromData:data];

    if ([imageType isEqualToString:@"image/webp"] || formatType == 3) {
        SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
        [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    }

    UIImage *img;
    if ([imageType isEqualToString:@"image/webp"]) {
        img = [[SDImageWebPCoder sharedCoder] decodedImageWithData:data options:nil];
    } else {
        img = [UIImage imageWithData:data];
    }

    if (!img) {
        result(nil);
        return;
    }

    int actualQuality = quality;
    if (formatType == 3 && actualQuality > 85) {
        actualQuality = 85;
    }

    NSData *compressedData = [CompressHandler compressWithUIImage:img
                                                         minWidth:minWidth
                                                        minHeight:minHeight
                                                          quality:actualQuality
                                                           rotate:rotate
                                                           format:formatType];

    if (!compressedData || compressedData.length == 0) {
        result(nil);
        return;
    }

    if (keepExif) {
        if (formatType == 3) {
            NSData *dataWithExif = [self addEXIToWebP:compressedData originalData:data];
            if (dataWithExif && dataWithExif.length > 0) {
                compressedData = dataWithExif;
            }
        } else {
            SYMetadata *metadata = [SYMetadata metadataWithImageData:data];
            if (metadata) {
                metadata.orientation = @1;
                NSData *dataWithExif = [SYMetadata dataWithImageData:compressedData andMetadata:metadata];
                if (dataWithExif && dataWithExif.length > 0) {
                    compressedData = dataWithExif;
                }
            }
        }
    }

    result([FlutterStandardTypedData typedDataWithBytes:compressedData]);
}

#pragma mark - WebP EXIF Handling (libwebp)

- (NSData *)addEXIToWebP:(NSData *)webpData originalData:(NSData *)originalData {
    NSDictionary *metadata = [self extractMetadataFromData:originalData];
    if (!metadata || metadata.count == 0) {
        return nil;
    }

    NSError *error;
    NSData *metadataJSON = [NSJSONSerialization dataWithJSONObject:metadata
                                                           options:0
                                                             error:&error];
    if (error || !metadataJSON) {
        return nil;
    }

    WebPData webp_data = {webpData.bytes, webpData.length};
    WebPMux *mux = WebPMuxCreate(&webp_data, 1);
    if (!mux) {
        return nil;
    }

    WebPData exif_metadata = {metadataJSON.bytes, metadataJSON.length};
    if (WebPMuxSetChunk(mux, "EXIF", &exif_metadata, 0) != WEBP_MUX_OK) {
        WebPMuxDelete(mux);
        return nil;
    }

    WebPData output_data;
    if (WebPMuxAssemble(mux, &output_data) != WEBP_MUX_OK) {
        WebPMuxDelete(mux);
        return nil;
    }

    NSData *resultData = [NSData dataWithBytes:output_data.bytes length:output_data.size];
    WebPDataClear(&output_data);
    WebPMuxDelete(mux);

    return resultData;
}

- (NSDictionary *)extractMetadataFromData:(NSData *)data {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) {
        return nil;
    }

    CFDictionaryRef metadataRef = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    CFRelease(source);
    if (!metadataRef) {
        return nil;
    }

    NSDictionary *metadata = (__bridge_transfer NSDictionary *)metadataRef;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSDictionary *exifDict = metadata[(__bridge NSString *)kCGImagePropertyExifDictionary];
    if (exifDict && exifDict.count > 0) {
        result[@"exif"] = exifDict;
    }

    NSDictionary *tiffDict = metadata[(__bridge NSString *)kCGImagePropertyTIFFDictionary];
    if (tiffDict && tiffDict.count > 0) {
        result[@"tiff"] = tiffDict;
    }

    NSDictionary *gpsDict = metadata[(__bridge NSString *)kCGImagePropertyGPSDictionary];
    if (gpsDict && gpsDict.count > 0) {
        result[@"gps"] = gpsDict;
    }

    NSNumber *orientation = metadata[(__bridge NSString *)kCGImagePropertyOrientation];
    if (orientation) {
        result[@"orientation"] = orientation;
    }

    return result.count > 0 ? result : nil;
}

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    if (data.length < 12) {
        return @"application/octet-stream";
    }

    char bytes[12] = {0};
    [data getBytes:&bytes length:12];

    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};

    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }

    return @"application/octet-stream";
}

@end
