//
// Created by cjl on 2018/9/8.
//

#import "CompressFileHandler.h"
#import "CompressHandler.h"
#import "ImageCompressPlugin.h"
@import SDWebImageWebPCoder;
@import SDWebImage;

@implementation CompressFileHandler {

}
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSArray *args = call.arguments;
    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    int rotate = [args[4] intValue];

    int formatType = [args[6] intValue];
    BOOL keepExif = [args[7] boolValue];

    
    UIImage *img;
    
    NSURL *imageUrl = [NSURL fileURLWithPath:path];
    NSData *nsdata = [NSData dataWithContentsOfURL:imageUrl];

    if (nsdata == nil) {
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"Input file could not be read (path=%@)", path);
        }
        result([FlutterError errorWithCode:@"io_failed"
                                   message:[NSString stringWithFormat:@"Input file could not be read (path=%@)", path]
                                   details:nil]);
        return;
    }

    NSString *imageType = [self mimeTypeByGuessingFromData:nsdata];

    //  NSLog(@" nsdata length: %@", imageType);

    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];

    if([imageType  isEqual: @"image/webp"]) {
    img = [[SDImageWebPCoder sharedCoder] decodedImageWithData:nsdata options:nil];
    } else {
        img = [UIImage imageWithData:nsdata];
    }

    if (img == nil) {
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"Input file is not a decodable image (mime=%@, path=%@)", imageType, path);
        }
        result([FlutterError errorWithCode:@"decode_failed"
                                   message:[NSString stringWithFormat:@"Input file is not a decodable image (mime=%@, path=%@)", imageType, path]
                                   details:nil]);
        return;
    }

    NSData *data = [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:formatType];

    if (keepExif && data.length > 0) {
        // Pass the whole source property dictionary through
        // CGImageSource → CGImageDestination directly. This preserves keys
        // (TIFF DateTime on iOS screenshots — #168, GPS, IPTC, maker notes)
        // that a typed-model middleman used to drop, and correctly
        // overrides orientation/pixel dims for the re-encoded output.
        // Returns nil when ImageIO can't author the container (WebP — see
        // #217/#369) — fall back to the compressed bytes without metadata.
        NSData *withMetadata = [CompressHandler dataByCopyingMetadataFromSource:nsdata intoEncoded:data];
        if (withMetadata.length > 0) {
            data = withMetadata;
        }
    }

    if (data == nil) {
        result([FlutterError errorWithCode:@"encode_failed"
                                   message:@"Encoder returned no data"
                                   details:nil]);
        return;
    }
    result([FlutterStandardTypedData typedDataWithBytes:data]);
}

- (void)handleCompressFileToFile:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *args = call.arguments;
    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    NSString *targetPath = args[4];
    int rotate = [args[5] intValue];

    int formatType = [args[7] intValue];
    BOOL keepExif = [args[8] boolValue];

    
    UIImage *img;
    
    NSURL *imageUrl = [NSURL fileURLWithPath:path];
    NSData *nsdata = [NSData dataWithContentsOfURL:imageUrl];

    if (nsdata == nil) {
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"Input file could not be read (path=%@)", path);
        }
        result([FlutterError errorWithCode:@"io_failed"
                                   message:[NSString stringWithFormat:@"Input file could not be read (path=%@)", path]
                                   details:nil]);
        return;
    }

    NSString *imageType = [self mimeTypeByGuessingFromData:nsdata];

    //  NSLog(@" nsdata length: %@", imageType);

    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];

    if([imageType  isEqual: @"image/webp"]) {
    img = [[SDImageWebPCoder sharedCoder] decodedImageWithData:nsdata options:nil];
    } else {
        img = [UIImage imageWithData:nsdata];
    }

    if (img == nil) {
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"Input file is not a decodable image (mime=%@, path=%@)", imageType, path);
        }
        result([FlutterError errorWithCode:@"decode_failed"
                                   message:[NSString stringWithFormat:@"Input file is not a decodable image (mime=%@, path=%@)", imageType, path]
                                   details:nil]);
        return;
    }

    NSData *data = [CompressHandler compressDataWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:formatType];

    if (keepExif && data.length > 0) {
        // See handleMethodCall: for rationale. Direct CGImageSource →
        // CGImageDestination passthrough of source properties, with
        // orientation/dimensions overridden to match the re-encoded bytes.
        NSData *withMetadata = [CompressHandler dataByCopyingMetadataFromSource:nsdata intoEncoded:data];
        if (withMetadata.length > 0) {
            data = withMetadata;
        }
    }

    if (data == nil) {
        result([FlutterError errorWithCode:@"encode_failed"
                                   message:@"Encoder returned no data"
                                   details:nil]);
        return;
    }
    NSURL *targetURL = [[NSURL alloc] initFileURLWithPath:targetPath];
    NSURL *parentURL = [targetURL URLByDeletingLastPathComponent];
    if (parentURL) {
        NSError *dirErr = nil;
        // Create the parent directory if missing. If it already exists,
        // withIntermediateDirectories:YES makes this a no-op. If it fails
        // (permission denied, path is a file, etc.), we log and continue —
        // writeToURL: below will report the actual failure back to Dart.
        [[NSFileManager defaultManager] createDirectoryAtURL:parentURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&dirErr];
        if (dirErr != nil && [ImageCompressPlugin showLog]) {
            NSLog(@"Failed to create target parent directory %@: %@", parentURL.path, dirErr.localizedDescription);
        }
    }
    BOOL success = [data writeToURL:targetURL atomically:YES];
    if (success) {
        result(targetPath);
    } else {
        result([FlutterError errorWithCode:@"io_failed"
                                   message:[NSString stringWithFormat:@"Failed to write compressed data to %@", targetPath]
                                   details:nil]);
    }
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

    // ISO BMFF (HEIC/HEIF/AVIF) — box at bytes 0-7 is [size][ftyp], brand at bytes 8-11.
    const char ftyp[4] = {'f', 't', 'y', 'p'};
    if (!memcmp(bytes + 4, ftyp, 4)) {
        const char *brand = bytes + 8;
        if (!memcmp(brand, "heic", 4) || !memcmp(brand, "heix", 4) || !memcmp(brand, "hevc", 4)) {
            return @"image/heic";
        }
        if (!memcmp(brand, "mif1", 4) || !memcmp(brand, "msf1", 4)) {
            return @"image/heif";
        }
        if (!memcmp(brand, "avif", 4) || !memcmp(brand, "avis", 4)) {
            return @"image/avif";
        }
        // Unknown ISO BMFF brand (e.g. MP4/MOV — same container, not an image).
        // Fall through so the octet-stream diagnostic still reflects reality.
    }

    return @"application/octet-stream"; // default type

}
@end
