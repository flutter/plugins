// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;
@import CoreGraphics;

@interface VideoPlayerUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end

@implementation VideoPlayerUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testPlayVideo {
  XCUIApplication *app = self.app;

  XCUIElement *remoteTab = [app.otherElements
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
  XCTAssertTrue([remoteTab waitForExistenceWithTimeout:30.0]);
  XCTAssertTrue([remoteTab.label containsString:@"Remote"]);

  XCUIElement *playButton = app.staticTexts[@"Play"];
  XCTAssertTrue([playButton waitForExistenceWithTimeout:30.0]);
  [playButton tap];

  NSPredicate *find1xButton = [NSPredicate predicateWithFormat:@"label CONTAINS '1.0x'"];
  XCUIElement *playbackSpeed1x = [app.staticTexts elementMatchingPredicate:find1xButton];
  BOOL foundPlaybackSpeed1x = [playbackSpeed1x waitForExistenceWithTimeout:30.0];
  XCTAssertTrue(foundPlaybackSpeed1x);
  [playbackSpeed1x tap];

  XCUIElement *playbackSpeed5xButton = app.buttons[@"5.0x"];
  XCTAssertTrue([playbackSpeed5xButton waitForExistenceWithTimeout:30.0]);
  [playbackSpeed5xButton tap];

  NSPredicate *find5xButton = [NSPredicate predicateWithFormat:@"label CONTAINS '5.0x'"];
  XCUIElement *playbackSpeed5x = [app.staticTexts elementMatchingPredicate:find5xButton];
  BOOL foundPlaybackSpeed5x = [playbackSpeed5x waitForExistenceWithTimeout:30.0];
  XCTAssertTrue(foundPlaybackSpeed5x);

  // Cycle through tabs.
  for (NSString *tabName in @[ @"Asset mp4", @"Remote mp4" ]) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName];
    XCUIElement *unselectedTab = [app.staticTexts elementMatchingPredicate:predicate];
    XCTAssertTrue([unselectedTab waitForExistenceWithTimeout:30.0]);
    XCTAssertFalse(unselectedTab.isSelected);
    [unselectedTab tap];

    XCUIElement *selectedTab = [app.otherElements
        elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName]];
    XCTAssertTrue([selectedTab waitForExistenceWithTimeout:30.0]);
    XCTAssertTrue(selectedTab.isSelected);
  }
}

- (void)testEncryptedVideoStream {
  // This is to fix a bug (https://github.com/flutter/flutter/issues/111457) in iOS 16 with blank
  // video for encrypted video streams.

  NSString *tabName = @"Remote enc m3u8";

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName];
  XCUIElement *unselectedTab = [self.app.staticTexts elementMatchingPredicate:predicate];
  XCTAssertTrue([unselectedTab waitForExistenceWithTimeout:30.0]);
  XCTAssertFalse(unselectedTab.isSelected);
  [unselectedTab tap];

  XCUIElement *selectedTab = [self.app.otherElements
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName]];
  XCTAssertTrue([selectedTab waitForExistenceWithTimeout:30.0]);
  XCTAssertTrue(selectedTab.isSelected);

  // Wait until the video is loaded.
  [NSThread sleepForTimeInterval:60];

  NSMutableSet *frames = [NSMutableSet set];
  int numberOfFrames = 60;
  for (int i = 0; i < numberOfFrames; i++) {
    UIImage *image = self.app.screenshot.image;

    // Plugin CI does not support attaching screenshot.
    // Convert the image to base64 encoded string, and print it out for debugging purpose.
    // NSLog truncates long strings, so need to scale downn image.
    CGSize smallerSize = CGSizeMake(100, 200);
    UIGraphicsBeginImageContextWithOptions(smallerSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, smallerSize.width, smallerSize.height)];
    UIImage *smallerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // 0.5 compression is good enough for debugging purpose.
    NSData *imageData = UIImageJPEGRepresentation(smallerImage, 0.5);
    NSString *imageString = [imageData base64EncodedStringWithOptions:0];
    NSLog(@"frame %d image data:\n%@", i, imageString);

    [frames addObject:imageString];

    // The sample interval must NOT be the same as video length.
    // Otherwise it would always result in the same frame.
    [NSThread sleepForTimeInterval:1];
  }

  // At least 1 loading and 2 distinct frames (3 in total) to validate that the video is playing.
  XCTAssert(frames.count >= 3, @"Must have at least 3 distinct frames.");
}

@end
