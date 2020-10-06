// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#import <XCTest/XCTest.h>

@interface ImagePickerExampleUITests : XCTestCase

@end

@implementation ImagePickerExampleUITests

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLauchingImagePickerFromPhotoGalleryTwiceNoCrash {
  XCUIApplication* app = [[XCUIApplication alloc] init];
  [app launch];

  // There has been a bug where bring up the image picker from gallery twice will crash
  const int numberOfTries = 2;

  for (int i = 0; i < numberOfTries; i ++) {
    NSPredicate* predicateToFindImageFromGalleryButton = [NSPredicate
        predicateWithFormat:@"label == %@",
                            @"image_picker_example_from_gallery"];

    XCUIElement* imageFromGalleryButton = [app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
    if (![imageFromGalleryButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds",
              @(30));
    }

    XCTAssertNotNil(imageFromGalleryButton);
    [imageFromGalleryButton tap];

    NSPredicate* predicateToFindPickButton = [NSPredicate
        predicateWithFormat:@"label == %@",
                            @"PICK"];

    XCUIElement* pickButton = [app.buttons elementMatchingPredicate:predicateToFindPickButton];
    if (![pickButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find pick button with %@ seconds",
              @(30));
    }

    XCTAssertNotNil(pickButton);
    [pickButton tap];

    NSPredicate* predicateToFindCancelButton = [NSPredicate
        predicateWithFormat:@"label == %@",
                            @"Cancel"];

    XCUIElement* cancelButton = [app.buttons elementMatchingPredicate:predicateToFindCancelButton];
    if (![cancelButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find Cancel button with %@ seconds",
              @(30));
    }

    XCTAssertNotNil(cancelButton);
    [cancelButton tap];
  }
}

@end
