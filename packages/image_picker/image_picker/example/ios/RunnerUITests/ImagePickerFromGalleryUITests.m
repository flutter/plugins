// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <os/log.h>

const int kElementWaitingTime = 30;

@interface ImagePickerFromGalleryUITests : XCTestCase

@property(nonatomic, strong) XCUIApplication* app;

@end

@implementation ImagePickerFromGalleryUITests

- (void)setUp {
  // Delete the app if already exists, to test permission popups

  self.continueAfterFailure = NO;
  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
  __weak typeof(self) weakSelf = self;
  [self addUIInterruptionMonitorWithDescription:@"Permission popups"
                                        handler:^BOOL(XCUIElement* _Nonnull interruptingElement) {
                                          if (@available(iOS 14, *)) {
                                            XCUIElement* allPhotoPermission =
                                                interruptingElement
                                                    .buttons[@"Allow Access to All Photos"];
                                            if (![allPhotoPermission waitForExistenceWithTimeout:
                                                                         kElementWaitingTime]) {
                                              os_log_error(OS_LOG_DEFAULT, "%@",
                                                           self.app.debugDescription);
                                              XCTFail(@"Failed due to not able to find "
                                                      @"allPhotoPermission button with %@ seconds",
                                                      @(kElementWaitingTime));
                                            }
                                            [allPhotoPermission tap];
                                          } else {
                                            XCUIElement* ok = interruptingElement.buttons[@"OK"];
                                            if (![ok waitForExistenceWithTimeout:
                                                         kElementWaitingTime]) {
                                              os_log_error(OS_LOG_DEFAULT, "%@",
                                                           self.app.debugDescription);
                                              XCTFail(@"Failed due to not able to find ok button "
                                                      @"with %@ seconds",
                                                      @(kElementWaitingTime));
                                            }
                                            [ok tap];
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
  if (![imageFromGalleryButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds",
            @(kElementWaitingTime));
  }

  XCTAssertTrue(imageFromGalleryButton.exists);
  [imageFromGalleryButton tap];

  // Find and tap on the `pick` button.
  NSPredicate* predicateToFindPickButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

  XCUIElement* pickButton = [self.app.buttons elementMatchingPredicate:predicateToFindPickButton];
  if (![pickButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(kElementWaitingTime));
  }

  XCTAssertTrue(pickButton.exists);
  [pickButton tap];

  // There is a known bug where the permission popups interruption won't get fired until a tap
  // happened in the app. We expect a permission popup so we do a tap here.
  [self.app tap];

  // Find and tap on the `Cancel` button.
  NSPredicate* predicateToFindCancelButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"Cancel"];

  XCUIElement* cancelButton =
      [self.app.buttons elementMatchingPredicate:predicateToFindCancelButton];
  if (![cancelButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find Cancel button with %@ seconds",
            @(kElementWaitingTime));
  }

  XCTAssertTrue(cancelButton.exists);
  [cancelButton tap];

  // Find the "not picked image text".
  XCUIElement* imageNotPickedText = [self.app.staticTexts
      elementMatchingPredicate:[NSPredicate
                                   predicateWithFormat:@"label == %@",
                                                       @"You have not yet picked an image."]];
  if (![imageNotPickedText waitForExistenceWithTimeout:kElementWaitingTime]) {
    // Before https://github.com/flutter/engine/pull/22811 the label's a11y type was otherElements.
    // TODO(cyanglaz): Remove this after
    // https://github.com/flutter/flutter/commit/057e8230743ec96f33b73948ccd6b80081e3615e rolled to
    // stable.
    // https://github.com/flutter/flutter/issues/71927
    imageNotPickedText = [self.app.otherElements
        elementMatchingPredicate:[NSPredicate
                                     predicateWithFormat:@"label == %@",
                                                         @"You have not yet picked an image."]];
  }
  if (![imageNotPickedText waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find imageNotPickedText with %@ seconds",
            @(kElementWaitingTime));
  }

  XCTAssertTrue(imageNotPickedText.exists);
}

- (void)launchPickerAndPick {
  // Find and tap on the pick from gallery button.
  NSPredicate* predicateToFindImageFromGalleryButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_from_gallery"];

  XCUIElement* imageFromGalleryButton =
      [self.app.otherElements elementMatchingPredicate:predicateToFindImageFromGalleryButton];
  if (![imageFromGalleryButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds",
            @(kElementWaitingTime));
  }

  XCTAssertTrue(imageFromGalleryButton.exists);
  [imageFromGalleryButton tap];

  // Find and tap on the `pick` button.
  NSPredicate* predicateToFindPickButton =
      [NSPredicate predicateWithFormat:@"label == %@", @"PICK"];

  XCUIElement* pickButton = [self.app.buttons elementMatchingPredicate:predicateToFindPickButton];
  if (![pickButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(kElementWaitingTime));
  }

  XCTAssertTrue(pickButton.exists);
  [pickButton tap];

  // Find an image and tap on it. (IOS 14 UI, images are showing directly)
  XCUIElement* aImage;
  if (@available(iOS 14, *)) {
    aImage = self.app.scrollViews.firstMatch.images.firstMatch;
  } else {
    XCUIElement* allPhotosCell = [self.app.cells
        elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"All Photos"]];
    if (![allPhotosCell waitForExistenceWithTimeout:kElementWaitingTime]) {
      os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
      XCTFail(@"Failed due to not able to find \"All Photos\" cell with %@ seconds",
              @(kElementWaitingTime));
    }
    [allPhotosCell tap];
    aImage = [self.app.collectionViews elementMatchingType:XCUIElementTypeCollectionView
                                                identifier:@"PhotosGridView"]
                 .cells.firstMatch;
  }
  if (![aImage waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find an image with %@ seconds", @(kElementWaitingTime));
  }
  XCTAssertTrue(aImage.exists);
  [aImage tap];

  // Find the picked image.
  NSPredicate* predicateToFindPickedImage =
      [NSPredicate predicateWithFormat:@"label == %@", @"image_picker_example_picked_image"];

  XCUIElement* pickedImage = [self.app.images elementMatchingPredicate:predicateToFindPickedImage];
  if (![pickedImage waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pickedImage with %@ seconds", @(kElementWaitingTime));
  }

  XCTAssertTrue(pickedImage.exists);
}

@end
