//
// Created by cjl on 2018/9/8.
//

#import "CompressFileHandler.h"
#import "CompressHandler.h"
#import "SYMetadata.h"
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <SDWebImage/SDWebImage.h>
#import <libwebp/encode.h>
#import <libwebp/decode.h>
#import <libwebp/mux.h>
#import <ImageIO/ImageIO.h>

@implementation CompressFileHandler

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSArray *args = call.arguments;

    if ([@"compressImage" isEqualToString:call.method]) {
        [self compressImage:args result:result];
    } else if ([@"compressImageToFile" isEqualToString:call.method]) {
        [self compressImageToFile:args result:result];
    } else if ([@"compressWithFile" isEqualToString:call.method]) {
        [self compressWithFile:args result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)compressWithFile:(NSArray *)args result:(FlutterResult)result {
    if (args.count < 9) {
        result(nil);
        return;
    }

    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    int rotate = [args[4] intValue];

    int formatType = [args[6] intValue];
    BOOL keepExif = [args[7] boolValue];

    NSString *fileExtension = [[path pathExtension] lowercaseString];
    if ([fileExtension isEqualToString:@"webp"] && formatType != 3) {
        formatType = 3;
        if (quality > 85) quality = 85;
    }

    [self processCompressionWithPath:path minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate formatType:formatType keepExif:keepExif result:result isFileMode:NO targetPath:nil];
}


- (void)compressImage:(NSArray *)args result:(FlutterResult)result {
    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    int rotate = [args[4] intValue];
    int formatType = [args[6] intValue];
    BOOL keepExif = [args[7] boolValue];

    [self processCompressionWithPath:path minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate formatType:formatType keepExif:keepExif result:result isFileMode:NO targetPath:nil];
}

- (void)compressImageToFile:(NSArray *)args result:(FlutterResult)result {
    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    NSString *targetPath = args[4];
    int rotate = [args[5] intValue];

    int formatType = [args[7] intValue];
    BOOL keepExif = [args[8] boolValue];

    [self processCompressionWithPath:path minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate formatType:formatType keepExif:keepExif result:result isFileMode:YES targetPath:targetPath];
}

- (void)processCompressionWithPath:(NSString *)path
                          minWidth:(int)minWidth
                         minHeight:(int)minHeight
                           quality:(int)quality
                            rotate:(int)rotate
                        formatType:(int)formatType
                          keepExif:(BOOL)keepExif
                            result:(FlutterResult)result
                        isFileMode:(BOOL)isFileMode
                        targetPath:(NSString *)targetPath {

    UIImage *img;
    
    NSURL *imageUrl = [NSURL fileURLWithPath:path];
    NSData *nsdata = [NSData dataWithContentsOfURL:imageUrl];

    if (!nsdata || nsdata.length == 0) {
        result(nil);
        return;
    }

    NSString *imageType = [self mimeTypeByGuessingFromData:nsdata];

    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];

    if ([imageType isEqualToString:@"image/webp"]) {
        img = [[SDImageWebPCoder sharedCoder] decodedImageWithData:nsdata options:nil];
    } else {
        img = [UIImage imageWithData:nsdata];
    }

    if (!img) {
        result(nil);
        return;
    }

    NSData *data = [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:formatType];

    if (!data || data.length == 0) {
        result(nil);
        return;
    }

    if (keepExif) {
        if (formatType == 3) {
            NSData *dataWithExif = [self addEXIToWebP:data originalPath:path];
            if (dataWithExif && dataWithExif.length > 0) {
                data = dataWithExif;
            }
        } else {
            SYMetadata *metadata = [SYMetadata metadataWithFileURL:[NSURL fileURLWithPath:path]];
            if (metadata) {
                metadata.orientation = @1;
                NSData *dataWithExif = [SYMetadata dataWithImageData:data andMetadata:metadata];
                if (dataWithExif && dataWithExif.length > 0) {
                    data = dataWithExif;
                }
            }
        }
    }

    if (isFileMode && targetPath) {
        BOOL success = [data writeToURL:[NSURL fileURLWithPath:targetPath] atomically:YES];
        result(success ? targetPath : nil);
    } else {
        result([FlutterStandardTypedData typedDataWithBytes:data]);
    }
}

- (NSData *)addEXIToWebP:(NSData *)webpData originalPath:(NSString *)path {
    NSDictionary *metadata = [self extractMetadataFromPath:path];
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

- (NSDictionary *)extractMetadataFromPath:(NSString *)path {
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)fileURL, NULL);
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

    char bytes[12] = {0};
    [data getBytes:&bytes length:12];

    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char swf[3] = {'F', 'W', 'S'};
    const char swc[3] = {'C', 'W', 'S'};
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

    return @"application/octet-stream"; // default type

}
@end
