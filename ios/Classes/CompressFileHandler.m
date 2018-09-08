//
// Created by cjl on 2018/9/8.
//

#import <Flutter/Flutter.h>
#import "CompressFileHandler.h"
#import "CompressHandler.h"


@implementation CompressFileHandler {

}
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSArray *args = call.arguments;
    NSString *path = args[0];
    int minWidth = [args[1] intValue];
    int minHeight = [args[2] intValue];
    int quality = [args[3] intValue];

    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSArray *array = [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality];
    result(array);
}
@end