//
// Created by cjl on 2018/9/8.
//

#import "CompressFileHandler.h"
#import "CompressHandler.h"
#import "FlutterImageCompressPlugin.h"

@implementation CompressFileHandler {

}
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSArray *args = call.arguments;
    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    int rotate = [args[4] intValue];

    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSData *data = [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate];
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
    
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSData *data = [CompressHandler compressDataWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate];
    [data writeToURL:[[NSURL alloc] initFileURLWithPath:targetPath] atomically:YES];

    result(targetPath);
}
@end
