//
// Created by cjl on 2018/9/8.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)
- (UIImage *)scaleWithMinWidth:(CGFloat)minWidth minHeight:(CGFloat)minHeight {
    float w = self.size.width;
    float h = self.size.height;

    float sW = w / minWidth;
    float sH = h / minHeight;

    float scale = fmaxf(fmaxf(sW, sH), 1);

    CGSize s = CGSizeMake(w / scale, h / scale);
    UIGraphicsBeginImageContext(s);

    [self drawInRect:CGRectMake(0, 0, s.width, s.height)];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

@end