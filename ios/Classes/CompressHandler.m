//
// Created by cjl on 2018/9/8.
//

#import "CompressHandler.h"
#import "UIImage+scale.h"


@implementation CompressHandler {

}


+ (NSMutableArray *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality {
    UIImage *img = [[UIImage alloc] initWithData:data];
    return [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality];
}

+ (NSMutableArray *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality {
    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];

    NSData *data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    NSMutableArray *array = [NSMutableArray array];

    Byte *bytes = data.bytes;
    for (int i = 0; i < data.length; ++i) {
        [array addObject:@(bytes[i])];
    }
    return array;
}


+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality {
    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];

    NSData *data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    return data;
}


@end