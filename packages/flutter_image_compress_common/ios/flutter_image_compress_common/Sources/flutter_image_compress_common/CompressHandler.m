//
// Created by cjl on 2018/9/8.
//

#import "CompressHandler.h"
#import "UIImage+scale.h"
#import "ImageCompressPlugin.h"
@import ImageIO;
@import SDWebImageWebPCoder;

@implementation CompressHandler {

}

+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                      rotate:(int)rotate format:(int)format {
    UIImage *img = [self isWebP:data] ? [UIImage sd_imageWithWebPData:data] : [[UIImage alloc] initWithData:data];
    return [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:format];
}

+ (NSData *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                         rotate:(int)rotate format:(int)format {
    if([ImageCompressPlugin showLog]){
        NSLog(@"width = %.0f",[image size].width);
        NSLog(@"height = %.0f",[image size].height);
        NSLog(@"minWidth = %d",minWidth);
        NSLog(@"minHeight = %d",minHeight);
        NSLog(@"format = %d", format);
    }

    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        image = [image rotate: rotate];
    }
    NSData *resultData = [self compressDataWithImage:image quality:quality format:format];

    return resultData;
}


+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight
                            quality:(int)quality rotate:(int)rotate format:(int)format {
    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        image = [image rotate: rotate];
    }
    return [self compressDataWithImage:image quality:quality format:format];
}

+ (NSData *)compressDataWithImage:(UIImage *)image quality:(float)quality format:(int)format  {
    NSData *data;
    if (format == 2) { // heic
        CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
        CIContext *ciContext = [[CIContext alloc]initWithOptions:nil];
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *target = [NSString stringWithFormat:@"%@%@.heic", tmpDir, [[NSUUID UUID] UUIDString]];
        NSURL *url = [NSURL fileURLWithPath:target];

        NSMutableDictionary *options = [NSMutableDictionary new];
        NSString *qualityKey = (__bridge NSString *)kCGImageDestinationLossyCompressionQuality;
//        CIImageRepresentationOption
        [options setObject:@(quality / 100) forKey: qualityKey];

        if (@available(iOS 11.0, *)) {
            CGColorSpaceRef colorSpace = ciImage.colorSpace;
            if (colorSpace == NULL) {
                colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
            }

            NSError *error = nil;
            BOOL success = [ciContext writeHEIFRepresentationOfImage:ciImage toURL:url format:kCIFormatARGB8 colorSpace:colorSpace options:options error:&error];

            if (success) {
                data = [NSData dataWithContentsOfURL:url];
            } else {
                data = nil;
                if([ImageCompressPlugin showLog]){
                    NSLog(@"HEIC write failed: %@", error.localizedDescription);
                }
            }

            if (colorSpace != ciImage.colorSpace) {
                CGColorSpaceRelease(colorSpace);
            }

            // Always attempt cleanup; ignore errors (file may already be gone
            // or may have been partially written on failure).
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        } else {
            // Fallback on earlier versions
            data = nil;
        }
    } else if(format == 3){ // webp
        SDImageCoderOptions *option = @{SDImageCoderEncodeCompressionQuality: @(quality / 100)};
        data = [[SDImageWebPCoder sharedCoder]encodedDataWithImage:image format:SDImageFormatWebP options:option];
    } else if(format == 1){ // png
        data = UIImagePNGRepresentation(image);
    }else { // 0 or other is jpeg
        data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    }

    return data;
}

+ (BOOL)isWebP:(NSData *)data {
    if (data.length < 12) return false;

    NSData *riff = [data subdataWithRange:NSMakeRange(8, 4)];
    NSString* format = [[NSString alloc] initWithData:riff encoding:(NSASCIIStringEncoding)];

    return [format isEqualToString:@"WEBP"];
}

+ (NSData *)dataByCopyingMetadataFromSource:(NSData *)sourceData
                                intoEncoded:(NSData *)encodedData {
    if (sourceData.length == 0 || encodedData.length == 0) {
        return nil;
    }

    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)sourceData, NULL);
    if (sourceRef == NULL) {
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"keepExif: could not read source metadata (unsupported container)");
        }
        return nil;
    }

    NSDictionary *rawSourceProps = (NSDictionary *)CFBridgingRelease(
        CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL));
    CFRelease(sourceRef);

    if (rawSourceProps == nil) {
        return nil;
    }

    CGImageSourceRef encodedRef = CGImageSourceCreateWithData((__bridge CFDataRef)encodedData, NULL);
    if (encodedRef == NULL) {
        return nil;
    }
    CFStringRef encodedType = CGImageSourceGetType(encodedRef);
    if (encodedType == NULL) {
        CFRelease(encodedRef);
        return nil;
    }

    NSMutableData *mergedData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(
        (__bridge CFMutableDataRef)mergedData, encodedType, 1, NULL);
    if (destination == NULL) {
        // ImageIO can't author this container (notably WebP). Signal the caller
        // to keep the original encoded bytes so we don't crash downstream.
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"keepExif: CGImageDestination for type %@ is not available; keeping compressed bytes without metadata", (__bridge NSString *)encodedType);
        }
        CFRelease(encodedRef);
        return nil;
    }

    // The pipeline scales and (optionally) rotates before re-encoding, so the
    // source's PixelWidth/PixelHeight and Orientation no longer describe the
    // encoded pixels. Overwrite them so viewers don't double-rotate or read
    // stale dimensions. Also drop keys that describe the source's *pixel
    // buffer* (color profile, depth, alpha channel, indexed/float model) —
    // those describe the source, not the re-encoded output. Passing a stale
    // ProfileName from a Display-P3 source into an sRGB JPEG output makes
    // color-managed viewers apply the wrong transform (visibly wrong colors);
    // passing HasAlpha=YES from a transparent PNG source into a JPEG (which
    // has no alpha) writes contradictory metadata.
    NSMutableDictionary *props = [rawSourceProps mutableCopy];
    [props removeObjectForKey:(NSString *)kCGImagePropertyPixelWidth];
    [props removeObjectForKey:(NSString *)kCGImagePropertyPixelHeight];
    [props removeObjectForKey:(NSString *)kCGImagePropertyFileSize];
    [props removeObjectForKey:(NSString *)kCGImagePropertyProfileName];
    [props removeObjectForKey:(NSString *)kCGImagePropertyColorModel];
    [props removeObjectForKey:(NSString *)kCGImagePropertyDepth];
    [props removeObjectForKey:(NSString *)kCGImagePropertyHasAlpha];
    [props removeObjectForKey:(NSString *)kCGImagePropertyIsFloat];
    [props removeObjectForKey:(NSString *)kCGImagePropertyIsIndexed];
    props[(NSString *)kCGImagePropertyOrientation] = @1;

    NSDictionary *tiffDict = props[(NSString *)kCGImagePropertyTIFFDictionary];
    if ([tiffDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tiff = [tiffDict mutableCopy];
        tiff[(NSString *)kCGImagePropertyTIFFOrientation] = @1;
        props[(NSString *)kCGImagePropertyTIFFDictionary] = tiff;
    }

    NSDictionary *exifDict = props[(NSString *)kCGImagePropertyExifDictionary];
    if ([exifDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *exif = [exifDict mutableCopy];
        [exif removeObjectForKey:(NSString *)kCGImagePropertyExifPixelXDimension];
        [exif removeObjectForKey:(NSString *)kCGImagePropertyExifPixelYDimension];
        props[(NSString *)kCGImagePropertyExifDictionary] = exif;
    }

    CGImageDestinationAddImageFromSource(destination, encodedRef, 0,
                                         (__bridge CFDictionaryRef)props);
    BOOL success = CGImageDestinationFinalize(destination);

    CFRelease(destination);
    CFRelease(encodedRef);

    if (!success) {
        if ([ImageCompressPlugin showLog]) {
            NSLog(@"keepExif: CGImageDestinationFinalize failed");
        }
        return nil;
    }
    // Finalize can return YES while AddImageFromSource silently no-ops.
    // Treat zero-length output as failure so the caller falls back to the
    // original encoded bytes.
    return mergedData.length > 0 ? mergedData : nil;
}

@end
