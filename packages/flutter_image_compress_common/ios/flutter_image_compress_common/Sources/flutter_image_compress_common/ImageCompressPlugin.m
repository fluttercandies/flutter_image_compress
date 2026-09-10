#import "ImageCompressPlugin.h"
#import "CompressListHandler.h"
#import "CompressFileHandler.h"

BOOL showLog = false;

@implementation ImageCompressPlugin
static dispatch_queue_t serial_queue;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    serial_queue = dispatch_get_global_queue(0, 0);

    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_image_compress"
                  binaryMessenger:[registrar messenger]];
    ImageCompressPlugin *instance = [[ImageCompressPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    dispatch_async(serial_queue, ^{
        if ([call.method isEqualToString:@"compressWithList"]) {
            CompressListHandler *handler = [[CompressListHandler alloc] init];
            [handler handleMethodCall:call result:result];
        } else if ([@"compressWithFile" isEqualToString:call.method]) {
            CompressFileHandler *handler = [[CompressFileHandler alloc] init];
            [handler handleMethodCall:call result:result];
        } else if ([@"compressWithFileAndGetFile" isEqualToString:call.method]) {
            CompressFileHandler *handler = [[CompressFileHandler alloc] init];
            [handler handleCompressFileToFile:call result:result];
        } else if ([@"showLog" isEqualToString:call.method]) {
            [self setShowLog:[call arguments]];
            result(@1);
        } else if([@"getSystemVersion" isEqualToString:call.method]) {
            NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
            result(systemVersion);
        } else {
            result(FlutterMethodNotImplemented);
        }
    });

}

+ (BOOL)showLog{
    return showLog;
}

- (void)setShowLog:(BOOL)log{
    showLog = log;
}

@end
