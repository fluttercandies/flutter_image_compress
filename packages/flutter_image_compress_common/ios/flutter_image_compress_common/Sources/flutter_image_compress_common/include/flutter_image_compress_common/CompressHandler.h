//
// Created by cjl on 2018/9/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CompressHandler : NSObject
+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                      rotate:(int)rotate format:(int)format;

+ (NSData *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                         rotate:(int)rotate format:(int)format;

+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight
                            quality:(int)quality rotate:(int)rotate format:(int)format;

// Copy every top-level image property dict (EXIF, TIFF, GPS, IPTC, PNG,
// maker notes, …) from `sourceData` into `encodedData`, and return the
// merged bytes. Uses CGImageSource → CGImageDestination directly, so
// keys a typed-model middleman would drop (e.g. TIFF DateTime on iOS
// screenshots) survive. Returns nil when the encoded container can't
// be re-authored by ImageIO (e.g. WebP) — callers must fall back to
// the original encoded bytes in that case.
+ (NSData *)dataByCopyingMetadataFromSource:(NSData *)sourceData
                                intoEncoded:(NSData *)encodedData;
@end
