// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "RunnerUITestUtils.h"

@interface ImagePickerFromGalleryUITests : XCTestCase

@property (nonatomic, strong) XCUIApplication *app;

@end

@implementation ImagePickerFromGalleryUITests

- (void)setUp {
  // Delete the app if already exists, to test permission popups

  self.continueAfterFailure = NO;
  self.app = [[XCUIApplication alloc] init];
  [self.app  launch];
  [self addUIInterruptionMonitorWithDescription:@"Permission popups" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
    XCUIElement *ok = interruptingElement.buttons[@"OK"];
    if (ok.exists) {
      [ok tap];
    }
    // iOS 14.
    XCUIElement *allPhotoPermission = interruptingElement.buttons[@"Allow Access to All Photos"];
    if (allPhotoPermission.exists) {
      [allPhotoPermission tap];
    }
    return YES;
  }];
}

- (void)testPickingFromGallery {
  [self launchPickerAndCancel];
  [self launchPickerAndPick];
}

- (void)launchPickerAndCancel {
  // Find and tap on the pick from gallery button.
  NSPredicate* predicateToFindImageFromGalleryButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_from_gallery"];

  XCUIElement* imageFromGalleryButton =
      [self.app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
  if (![imageFromGalleryButton waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds", @(30));
  }

  XCTAssertTrue(imageFromGalleryButton.exists);
  [imageFromGalleryButton tap];

  // Find and tap on the `pick` button.
  NSPredicate* predicateToFindPickButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

  XCUIElement* pickButton = [self.app.buttons elementMatchingPredicate:predicateToFindPickButton];
  if (![pickButton waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(30));
  }

  XCTAssertTrue(pickButton.exists);
  [pickButton tap];

  // There is a known bug where the permission popups interruption won't get fired until a tap happened in the app. We expect a permission popup so we do a tap here.
  [self.app tap];

  // Find and tap on the `Cancel` button.
  NSPredicate* predicateToFindCancelButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"Cancel"];

  XCUIElement* cancelButton = [self.app.buttons elementMatchingPredicate:predicateToFindCancelButton];
  if (![cancelButton waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find Cancel button with %@ seconds", @(30));
  }

  XCTAssertTrue(cancelButton.exists);
  [cancelButton tap];

  // Find the "not picked image text".
  XCUIElement* imageNotPickedText = [self.app.otherElements
      elementMatchingPredicate:[NSPredicate
                                   predicateWithFormat:@"label == %@",
                                                       @"You have not yet picked an image."]];
  if (![imageNotPickedText waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find imageNotPickedText with %@ seconds", @(30));
  }

  XCTAssertTrue(imageNotPickedText.exists);
}

- (void)launchPickerAndPick {

  // Find and tap on the pick from gallery button.
  NSPredicate* predicateToFindImageFromGalleryButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_from_gallery"];

  XCUIElement* imageFromGalleryButton =
  [self.app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
  if (![imageFromGalleryButton waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds", @(30));
  }

  XCTAssertTrue(imageFromGalleryButton.exists);
  [imageFromGalleryButton tap];

  // Find and tap on the `pick` button.
  NSPredicate* predicateToFindPickButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

  XCUIElement* pickButton = [self.app.buttons elementMatchingPredicate:predicateToFindPickButton];
  if (![pickButton waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(30));
  }

  XCTAssertTrue(pickButton.exists);
  [pickButton tap];

  // Find an image and tap on it. (IOS 14 UI, images are showing direclty)
  XCUIElement* aImage = self.app.scrollViews.firstMatch.images.firstMatch;
  XCUIElement* allPhotosCell = [self.app.cells elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"All Photos"]];
  XCUIElement *firstExist = [RunnerUITestUtils waitForFirstExistence:@[aImage, allPhotosCell] timeout:30];
  if (firstExist) {
    // For iOS 14 and below, we need to tap on the "All Photos" cell to get to the images page.
    // The image a11y info is also different.
    if (allPhotosCell.exists) {
      [allPhotosCell tap];
      aImage = [self.app.collectionViews elementMatchingType:XCUIElementTypeCollectionView identifier:@"PhotosGridView"].cells.firstMatch;
    }
    if (![aImage waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", self.app.debugDescription);
      XCTFail(@"Failed due to not able to find an image with %@ seconds", @(30));
    }
    XCTAssertTrue(aImage.exists);
    [aImage tap];
  } else {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find an image with %@ seconds", @(30));
  }

  // Find the picked image.
  NSPredicate* predicateToFindPickedImage =
      [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_picked_image"];

  XCUIElement* pickedImage = [self.app.images elementMatchingPredicate:predicateToFindPickedImage];
  if (![pickedImage waitForExistenceWithTimeout:30]) {
    NSLog(@"%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pickedImage with %@ seconds", @(30));
  }

  XCTAssertTrue(pickedImage.exists);
}

@end
