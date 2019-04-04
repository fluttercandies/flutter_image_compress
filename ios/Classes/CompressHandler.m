//
// Created by cjl on 2018/9/8.
//

#import "CompressHandler.h"
#import "UIImage+scale.h"
#import "FlutterImageCompressPlugin.h"

@implementation CompressHandler {

}

+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality rotate:(int) rotate{
    UIImage *img = [[UIImage alloc] initWithData:data];
    return [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate];
}

+ (NSData *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality rotate:(int) rotate{
    if([FlutterImageCompressPlugin showLog]){
        NSLog(@"width = %.0f",[image size].width);
        NSLog(@"height = %.0f",[image size].height);
        NSLog(@"minWidth = %d",minWidth);
        NSLog(@"minHeight = %d",minHeight);
    }
    
    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        image = [image rotate: rotate];
    }
    NSData *data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    return data;
}


+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality rotate:(int) rotate{
    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        image = [image rotate: rotate];
    }
    NSData *data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    return data;
}


@end
