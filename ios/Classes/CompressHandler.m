//
// Created by cjl on 2018/9/8.
//

#import "CompressHandler.h"
#import "UIImage+scale.h"
#import "FlutterImageCompressPlugin.h"

@implementation CompressHandler {

}

+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                      rotate:(int)rotate format:(int)format {
    UIImage *img = [[UIImage alloc] initWithData:data];
    return [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:format];
}

+ (NSData *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                         rotate:(int)rotate format:(int)format {
    if([FlutterImageCompressPlugin showLog]){
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
    if (format != 1) {
        data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    } else {
        data = UIImagePNGRepresentation(image);
    }

    return data;
}

@end
