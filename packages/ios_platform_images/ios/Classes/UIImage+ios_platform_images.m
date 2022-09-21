// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import "UIImage+ios_platform_images.h"

@implementation UIImage (ios_platform_images)
+ (UIImage *)flutterImageWithName:(NSString *)name {
  NSString *filename = [name lastPathComponent];
  NSString *path = [name stringByDeletingLastPathComponent];
  for (int screenScale = [UIScreen mainScreen].scale; screenScale > 1; --screenScale) {
    NSString *key = [FlutterDartProject
        lookupKeyForAsset:[NSString stringWithFormat:@"%@/%d.0x/%@", path, screenScale, filename]];
    UIImage *image = [UIImage imageNamed:key
                                inBundle:[NSBundle mainBundle]
           compatibleWithTraitCollection:nil];
    if (image) {
      return image;
    }
  }
  NSString *key = [FlutterDartProject lookupKeyForAsset:name];
  return [UIImage imageNamed:key inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}
@end
