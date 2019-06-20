// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct GIFInfo {
  // frames of animation
  NSArray<UIImage *> *images;
  NSTimeInterval interval;
} GIFInfo;

@interface FLTImagePickerImageUtil : NSObject

+ (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight;

// Resize all gif animation frames.
+ (GIFInfo)scaledGIFImage:(NSData *)data
                 maxWidth:(NSNumber *)maxWidth
                maxHeight:(NSNumber *)maxHeight;

@end

NS_ASSUME_NONNULL_END
