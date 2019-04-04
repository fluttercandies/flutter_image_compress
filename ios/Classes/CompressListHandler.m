//
//  CompressListHandler.m
//  flutter_image_compress
//
//  Created by cjl on 2018/9/8.
//

#import <Flutter/Flutter.h>
#import "CompressListHandler.h"
#import "CompressHandler.h"
#import "FlutterImageCompressPlugin.h"

@implementation CompressListHandler

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *args = call.arguments;
    FlutterStandardTypedData *list = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];
    int rotate = [args[4] intValue];

    NSData *data = [list data];
    NSData *compressedData = [CompressHandler compressWithData:data minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate];

    result([FlutterStandardTypedData typedDataWithBytes:compressedData]);
}


@end
