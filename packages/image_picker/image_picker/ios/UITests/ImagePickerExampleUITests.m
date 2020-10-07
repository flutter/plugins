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

  for (int i = 0; i < numberOfTries; i++) {
    // Find and tap on the pick from gallery button.
    NSPredicate* predicateToFindImageFromGalleryButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_from_gallery"];

    XCUIElement* imageFromGalleryButton =
        [app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
    if (![imageFromGalleryButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds", @(30));
    }

    XCTAssertNotNil(imageFromGalleryButton);
    [imageFromGalleryButton tap];

    // Find and tap on the `pick` button.
    NSPredicate* predicateToFindPickButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

    XCUIElement* pickButton = [app.buttons elementMatchingPredicate:predicateToFindPickButton];
    if (![pickButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(30));
    }

    XCTAssertNotNil(pickButton);
    [pickButton tap];

    // Find and tap on the `Cancel` button.
    NSPredicate* predicateToFindCancelButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"Cancel"];

    XCUIElement* cancelButton = [app.buttons elementMatchingPredicate:predicateToFindCancelButton];
    if (![cancelButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find Cancel button with %@ seconds", @(30));
    }

    XCTAssertNotNil(cancelButton);
    [cancelButton tap];

    // Find the "not picked image text".
    XCUIElement* imageNotPickedText = [app.otherElements
        elementMatchingPredicate:[NSPredicate
                                     predicateWithFormat:@"label == %@",
                                                         @"You have not yet picked an image."]];
    if (![imageNotPickedText waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find imageNotPickedText with %@ seconds", @(30));
    }

    XCTAssertNotNil(imageNotPickedText);
  }
}

- (void)testLauchingImagePickerFromPhotoGalleryAndPickImages {
  XCUIApplication* app = [[XCUIApplication alloc] init];
  [app launch];

  // Running multiple times to ensure there are no race conditions.
  const int numberOfTries = 10;

  for (int i = 0; i < numberOfTries; i++) {
    // Find and tap on the pick from gallery button.
    NSPredicate* predicateToFindImageFromGalleryButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_from_gallery"];

    XCUIElement* imageFromGalleryButton =
        [app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
    if (![imageFromGalleryButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds", @(30));
    }

    XCTAssertNotNil(imageFromGalleryButton);
    [imageFromGalleryButton tap];

    // Find and tap on the `pick` button.
    NSPredicate* predicateToFindPickButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

    XCUIElement* pickButton = [app.buttons elementMatchingPredicate:predicateToFindPickButton];
    if (![pickButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(30));
    }

    XCTAssertNotNil(pickButton);
    [pickButton tap];

    // Find an image and tap on it.
    XCUIElement* aImage = app.scrollViews.firstMatch.images.firstMatch;
    if (![aImage waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find an image with %@ seconds", @(30));
    }

    XCTAssertNotNil(aImage);

    [aImage tap];

    // Find the picked image.
    NSPredicate* predicateToFindPickedImage =
        [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_picked_image"];

    XCUIElement* pickedImage = [app.images elementMatchingPredicate:predicateToFindPickedImage];
    if (![pickedImage waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find pickedImage with %@ seconds", @(30));
    }

    XCTAssertNotNil(pickedImage);
  }
}

- (void)testLauchingImagePickerDismissBySwipingDownTwice {
  XCUIApplication* app = [[XCUIApplication alloc] init];
  [app launch];

  // There has been a bug where bring up the image picker from gallery twice will crash
  const int numberOfTries = 2;

  for (int i = 0; i < numberOfTries; i++) {
    // Find and tap on the pick from gallery button.
    NSPredicate* predicateToFindImageFromGalleryButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_from_gallery"];

    XCUIElement* imageFromGalleryButton =
        [app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
    if (![imageFromGalleryButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds", @(30));
    }

    XCTAssertNotNil(imageFromGalleryButton);
    [imageFromGalleryButton tap];

    // Find and tap on the `pick` button.
    NSPredicate* predicateToFindPickButton =
        [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

    XCUIElement* pickButton = [app.buttons elementMatchingPredicate:predicateToFindPickButton];
    if (![pickButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(30));
    }

    XCTAssertNotNil(pickButton);
    [pickButton tap];

    // Swipe down to dismiss image picker
    XCUIElement* aImage = app.scrollViews.firstMatch.images.firstMatch;
    [aImage swipeDown];
    NSPredicate* imageDisappear = [NSPredicate predicateWithFormat:@"exists == FALSE"];
    XCTestExpectation* expection = [self expectationForPredicate:imageDisappear
                                             evaluatedWithObject:aImage
                                                         handler:nil];
    [self waitForExpectations:@[ expection ] timeout:30];

    // Find the "not picked image text".
    XCUIElement* imageNotPickedText = [app.otherElements
        elementMatchingPredicate:[NSPredicate
                                     predicateWithFormat:@"label == %@",
                                                         @"You have not yet picked an image."]];
    if (![imageNotPickedText waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find imageNotPickedText with %@ seconds", @(30));
    }

    XCTAssertNotNil(imageNotPickedText);
  }
}

- (XCUICoordinate*)getNormalizedCoordinate:(XCUIApplication*)app point:(CGVector)vector {
  XCUICoordinate* appZero = [app coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
  XCUICoordinate* coordinate = [appZero coordinateWithOffset:vector];
  return coordinate;
}

@end
