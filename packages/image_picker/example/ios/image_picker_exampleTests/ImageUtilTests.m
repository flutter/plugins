// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FLTImagePickerImageUtil.h"

@interface ImageUtilTests : XCTestCase

@property(strong, nonatomic) NSBundle *testBundle;

@end

@implementation ImageUtilTests

- (void)setUp {
  self.testBundle = [NSBundle bundleForClass:self.class];
}

- (void)testScaledImage_ShouldBeScaled {
  NSData *data = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                          ofType:@"jpg"]];
  UIImage *image = [UIImage imageWithData:data];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image maxWidth:@3 maxHeight:@2];

  XCTAssertEqual(newImage.size.width, 3);
  XCTAssertEqual(newImage.size.height, 2);
}

- (void)testScaledGIFImage_ShouldBeScaled {
  // gif image that frame size is 3 and the duration is 1 second.
  NSData *data = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"gifImage"
                                                                          ofType:@"gif"]];
  GIFInfo *info = [FLTImagePickerImageUtil scaledGIFImage:data maxWidth:@3 maxHeight:@2];

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
