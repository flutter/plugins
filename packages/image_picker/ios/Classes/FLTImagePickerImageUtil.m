// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTImagePickerImageUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface GIFInfo ()

@property(strong, nonatomic, readwrite) NSArray<UIImage *> *images;
@property(assign, nonatomic, readwrite) NSTimeInterval interval;

@end

@implementation GIFInfo

- (instancetype)initWithImages:(NSArray<UIImage *> *)images interval:(NSTimeInterval)interval;
{
  self = [super init];
  if (self) {
    self.images = images;
    self.interval = interval;
  }
  return self;
}

@end

@implementation FLTImagePickerImageUtil : NSObject

+ (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight {
  NSData *imageData = UIImagePNGRepresentation(image);
  CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
  CFDictionaryRef options = (__bridge CFDictionaryRef) @{
    (id)kCGImageSourceCreateThumbnailWithTransform : @YES,
    (id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
    (id)kCGImageSourceThumbnailMaxPixelSize : MAX(maxWidth, maxHeight)
  };

  CGImageRef scaledImageRef = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
  UIImage *scaled = [UIImage imageWithCGImage:scaledImageRef];
  CGImageRelease(scaledImageRef);
  return scaled;
}

+ (GIFInfo *)scaledGIFImage:(NSData *)data
                   maxWidth:(NSNumber *)maxWidth
                  maxHeight:(NSNumber *)maxHeight {
  NSMutableDictionary<NSString *, id> *options = [NSMutableDictionary dictionary];
  options[(NSString *)kCGImageSourceShouldCache] = @(YES);
  options[(NSString *)kCGImageSourceTypeIdentifierHint] = (NSString *)kUTTypeGIF;

  CGImageSourceRef imageSource =
      CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)options);

  size_t numberOfFrames = CGImageSourceGetCount(imageSource);
  NSMutableArray<UIImage *> *images = [NSMutableArray arrayWithCapacity:numberOfFrames];

  NSTimeInterval interval = 0.0;
  for (size_t index = 0; index < numberOfFrames; index++) {
    CGImageRef imageRef =
        CGImageSourceCreateImageAtIndex(imageSource, index, (CFDictionaryRef)options);

    NSDictionary *properties = (NSDictionary *)CFBridgingRelease(
        CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL));
    NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];

    NSNumber *delay = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (!delay) {
      delay = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
    }

    if (interval == 0.0) {
      interval = [delay doubleValue];
    }

    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    image = [self scaledImage:image maxWidth:maxWidth maxHeight:maxHeight];

    [images addObject:image];

    CGImageRelease(imageRef);
  }

  CFRelease(imageSource);

  GIFInfo *info = [[GIFInfo alloc] initWithImages:images interval:interval];

  return info;
}

@end
