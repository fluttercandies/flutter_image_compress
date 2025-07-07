//
//  SYMetadataJFIF.m
//  SYPictureMetadataExample
//
//  Created by Stan Chevallier on 12/16/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import "../include/flutter_image_compress_common/SYPictureMetadata/SYMetadataJFIF.h"
#import <ImageIO/ImageIO.h>

@implementation SYMetadataJFIF

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{SYStringSel(version):      (NSString *)kCGImagePropertyJFIFVersion,
             SYStringSel(xDensity):     (NSString *)kCGImagePropertyJFIFXDensity,
             SYStringSel(yDensity):     (NSString *)kCGImagePropertyJFIFYDensity,
             SYStringSel(densityUnit):  (NSString *)kCGImagePropertyJFIFDensityUnit,
             SYStringSel(isProgressive):(NSString *)kCGImagePropertyJFIFIsProgressive,
             };
}

@end
