#import "FlutterImageCompressPlugin.h"
#import "CompressListHandler.h"
#import "CompressFileHandler.h"

@implementation FlutterImageCompressPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_image_compress"
                  binaryMessenger:[registrar messenger]];
    FlutterImageCompressPlugin *instance = [[FlutterImageCompressPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    if ([call.method isEqualToString:@"compressWithList"]) {
        CompressListHandler *handler = [[CompressListHandler alloc] init];
        [handler handleMethodCall:call result:result];
    } else if ([@"compressWithFile" isEqualToString:call.method]) {
        CompressFileHandler *handler = [[CompressFileHandler alloc] init];
        [handler handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
