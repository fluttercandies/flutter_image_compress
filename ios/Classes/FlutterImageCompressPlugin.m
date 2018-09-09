#import "FlutterImageCompressPlugin.h"
#import "CompressListHandler.h"
#import "CompressFileHandler.h"

@implementation FlutterImageCompressPlugin
static dispatch_queue_t serial_queue;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    serial_queue = dispatch_queue_create("com.jerry.SerialQueue", NULL);

    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_image_compress"
                  binaryMessenger:[registrar messenger]];
    FlutterImageCompressPlugin *instance = [[FlutterImageCompressPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    dispatch_sync(serial_queue, ^{
        if ([call.method isEqualToString:@"compressWithList"]) {
            CompressListHandler *handler = [[CompressListHandler alloc] init];
            [handler handleMethodCall:call result:result];
        } else if ([@"compressWithFile" isEqualToString:call.method]) {
            CompressFileHandler *handler = [[CompressFileHandler alloc] init];
            [handler handleMethodCall:call result:result];
        } else if ([@"compressWithFileAndGetFile" isEqualToString:call.method]) {
            CompressFileHandler *handler = [[CompressFileHandler alloc] init];
            [handler handleCompressFileToFile:call result:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    });

}

@end
