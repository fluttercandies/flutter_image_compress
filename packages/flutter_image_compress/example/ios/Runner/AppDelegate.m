#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import <ImageIO/ImageIO.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  BOOL launched = [super application:application didFinishLaunchingWithOptions:launchOptions];
  [self registerTestHelperChannel];
  return launched;
}

// Test-only channel: exposes native ImageIO metadata inspection so
// integration_test/ can assert EXIF preservation without needing to link
// ImageIO into pure-Dart tests. Not part of the plugin API surface.
- (void)registerTestHelperChannel {
  FlutterViewController *controller = (FlutterViewController *)self.window.rootViewController;
  if (![controller isKindOfClass:[FlutterViewController class]]) {
    return;
  }
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_image_compress/test"
            binaryMessenger:controller.binaryMessenger];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if (![call.method isEqualToString:@"readExifKeys"]) {
      result(FlutterMethodNotImplemented);
      return;
    }
    FlutterStandardTypedData *typed = call.arguments;
    if (![typed isKindOfClass:[FlutterStandardTypedData class]]) {
      result(@[]);
      return;
    }
    NSData *data = typed.data;
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (src == NULL) {
      result(@[]);
      return;
    }
    NSDictionary *props = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
    CFRelease(src);
    NSDictionary *exif = props[(__bridge NSString *)kCGImagePropertyExifDictionary];
    if (![exif isKindOfClass:[NSDictionary class]]) {
      result(@[]);
      return;
    }
    result([exif allKeys]);
  }];
}

@end
