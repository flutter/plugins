// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <UIImage+ios_platform_images.h>

__attribute__((unused)) static UIImageView* MakeImage() {
  UIImage* image = [UIImage flutterImageWithName: @"assets/foo.png"];
  return [[UIImageView alloc] initWithImage:image];
}
