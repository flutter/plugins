// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import os.log;

static UIColor *getPixelColorInImage(CGImageRef image, size_t x, size_t y) {
  CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image));
  const UInt8 *data = CFDataGetBytePtr(pixelData);

  size_t bytesPerRow = CGImageGetBytesPerRow(image);
  size_t pixelInfo = (bytesPerRow * y) + (x * 4);  // 4 bytes per pixel

  UInt8 red = data[pixelInfo + 0];
  UInt8 green = data[pixelInfo + 1];
  UInt8 blue = data[pixelInfo + 2];
  UInt8 alpha = data[pixelInfo + 3];
  CFRelease(pixelData);

  return [UIColor colorWithRed:red / 255.0f
                         green:green / 255.0f
                          blue:blue / 255.0f
                         alpha:alpha / 255.0f];
}

@interface FLTWebViewUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end

@implementation FLTWebViewUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testTransparentBackground {
  XCUIApplication *app = self.app;
  XCUIElement *menu = app.buttons[@"Show menu"];
  if (![menu waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find menu");
  }
  [menu tap];

  XCUIElement *transparentBackground = app.buttons[@"Transparent background example"];
  if (![transparentBackground waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Transparent background example");
  }
  [transparentBackground tap];

  XCUIElement *transparentBackgroundLoaded =
      app.webViews.staticTexts[@"Transparent background test"];
  if (![transparentBackgroundLoaded waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Transparent background test");
  }

  XCUIScreenshot *screenshot = [[XCUIScreen mainScreen] screenshot];

  UIImage *screenshotImage = screenshot.image;
  CGImageRef screenshotCGImage = screenshotImage.CGImage;
  UIColor *centerLeftColor =
      getPixelColorInImage(screenshotCGImage, 0, CGImageGetHeight(screenshotCGImage) / 2);
  UIColor *centerColor =
      getPixelColorInImage(screenshotCGImage, CGImageGetWidth(screenshotCGImage) / 2,
                           CGImageGetHeight(screenshotCGImage) / 2);

  CGColorSpaceRef centerLeftColorSpace = CGColorGetColorSpace(centerLeftColor.CGColor);
  // Flutter Colors.green color : 0xFF4CAF50 -> rgba(76, 175, 80, 1)
  // https://github.com/flutter/flutter/blob/f4abaa0735eba4dfd8f33f73363911d63931fe03/packages/flutter/lib/src/material/colors.dart#L1208
  // The background color of the webview is : rgba(0, 0, 0, 0.5)
  // The expected color is : rgba(38, 87, 40, 1)
  CGFloat flutterGreenColorComponents[] = {38.0f / 255.0f, 87.0f / 255.0f, 40.0f / 255.0f, 1.0f};
  CGColorRef flutterGreenColor = CGColorCreate(centerLeftColorSpace, flutterGreenColorComponents);
  CGFloat redColorComponents[] = {1.0f, 0.0f, 0.0f, 1.0f};
  CGColorRef redColor = CGColorCreate(centerLeftColorSpace, redColorComponents);
  CGColorSpaceRelease(centerLeftColorSpace);

  XCTAssertTrue(CGColorEqualToColor(flutterGreenColor, centerLeftColor.CGColor));
  XCTAssertTrue(CGColorEqualToColor(redColor, centerColor.CGColor));
}

- (void)testUserAgent {
  XCUIApplication *app = self.app;
  XCUIElement *menu = app.buttons[@"Show menu"];
  if (![menu waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find menu");
  }
  [menu tap];

  XCUIElement *userAgent = app.buttons[@"Show user agent"];
  if (![userAgent waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Show user agent");
  }
  NSPredicate *userAgentPredicate =
      [NSPredicate predicateWithFormat:@"label BEGINSWITH 'User Agent: Mozilla/5.0 (iPhone; '"];
  XCUIElement *userAgentPopUp = [app.otherElements elementMatchingPredicate:userAgentPredicate];
  XCTAssertFalse(userAgentPopUp.exists);
  [userAgent tap];
  if (![userAgentPopUp waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find user agent pop up");
  }
}

- (void)testCache {
  XCUIApplication *app = self.app;
  XCUIElement *menu = app.buttons[@"Show menu"];
  if (![menu waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find menu");
  }
  [menu tap];

  XCUIElement *clearCache = app.buttons[@"Clear cache"];
  if (![clearCache waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Clear cache");
  }
  [clearCache tap];

  [menu tap];

  XCUIElement *listCache = app.buttons[@"List cache"];
  if (![listCache waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find List cache");
  }
  [listCache tap];

  XCUIElement *emptyCachePopup = app.otherElements[@"{\"cacheKeys\":[],\"localStorage\":{}}"];
  if (![emptyCachePopup waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find empty cache pop up");
  }

  [menu tap];
  XCUIElement *addCache = app.buttons[@"Add to cache"];
  if (![addCache waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Add to cache");
  }
  [addCache tap];
  [menu tap];

  if (![listCache waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find List cache");
  }
  [listCache tap];

  XCUIElement *cachePopup =
      app.otherElements[@"{\"cacheKeys\":[\"test_caches_entry\"],\"localStorage\":{\"test_"
                        @"localStorage\":\"dummy_entry\"}}"];
  if (![cachePopup waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find cache pop up");
  }
}

@end
