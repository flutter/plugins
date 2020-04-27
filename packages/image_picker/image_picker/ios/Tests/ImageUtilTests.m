// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker;
@import XCTest;

@interface ImageUtilTests : XCTestCase
@end

@implementation ImageUtilTests

- (void)testScaledImage_ShouldBeScaled {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image maxWidth:@3 maxHeight:@2];

  XCTAssertEqual(newImage.size.width, 3);
  XCTAssertEqual(newImage.size.height, 2);
}

- (void)testScaledGIFImage_ShouldBeScaled {
  // gif image that frame size is 3 and the duration is 1 second.
  GIFInfo *info = [FLTImagePickerImageUtil scaledGIFImage:ImagePickerTestImages.GIFTestData
                                                 maxWidth:@3
                                                maxHeight:@2];

  NSArray<UIImage *> *images = info.images;
  NSTimeInterval duration = info.interval;

  XCTAssertEqual(images.count, 3);
  XCTAssertEqual(duration, 1);

  for (UIImage *newImage in images) {
    XCTAssertEqual(newImage.size.width, 3);
    XCTAssertEqual(newImage.size.height, 2);
  }
}

@end
