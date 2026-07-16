//
//  CompressListHandler.m
//  flutter_image_compress
//
//  Created by cjl on 2018/9/8.
//

#import <Flutter/Flutter.h>
#import "CompressListHandler.h"
#import "CompressHandler.h"

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
    NSData *compressedData = [CompressHandler compressWithData:data minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:formatType];

    if (compressedData == nil) {
        result([FlutterError errorWithCode:@"encode_failed"
                                   message:@"Encoder returned no data"
                                   details:nil]);
        return;
    }

    if (keepExif && compressedData.length > 0) {
        // Direct CGImageSource → CGImageDestination passthrough of every
        // top-level source property dict — preserves EXIF, TIFF DateTime
        // (#168 screenshots), GPS, IPTC, PNG chunks. Returns nil for
        // containers ImageIO can't author (e.g. WebP — #217/#369); in that
        // case keep the compressed bytes without metadata.
        NSData *withMetadata = [CompressHandler dataByCopyingMetadataFromSource:data intoEncoded:compressedData];
        if (withMetadata.length > 0) {
            compressedData = withMetadata;
        }
    }

    result([FlutterStandardTypedData typedDataWithBytes:compressedData]);
}


@end
