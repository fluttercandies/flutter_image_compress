//
// Created by cjl on 2018/9/8.
//

#import "CompressFileHandler.h"
#import "CompressHandler.h"
#import "SYMetadata.h"

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

    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSData *data = [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:formatType];

    if (keepExif) {
        SYMetadata *metadata = [SYMetadata metadataWithFileURL:[NSURL fileURLWithPath:path]];
        metadata.orientation = @0;
        data = [SYMetadata dataWithImageData:data andMetadata:metadata];
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

    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSData *data = [CompressHandler compressDataWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:formatType];

    if (keepExif) {
        SYMetadata *metadata = [SYMetadata metadataWithFileURL:[NSURL fileURLWithPath:path]];
        metadata.orientation = @0;
        data = [SYMetadata dataWithImageData:data andMetadata:metadata];
    }

    [data writeToURL:[[NSURL alloc] initFileURLWithPath:targetPath] atomically:YES];

    result(targetPath);
}
@end
