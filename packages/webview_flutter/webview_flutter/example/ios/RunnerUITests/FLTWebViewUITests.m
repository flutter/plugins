// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import os.log;

static UIColor* getPixelColorInImage(UIImage* image, int x, int y) {
  CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
  const UInt8* data = CFDataGetBytePtr(pixelData);

  int imageWidth = floor(image.size.width * image.scale);
  int pixelInfo = ((imageWidth * y) + x) * 4;  // 4 bytes per pixel

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

static bool compareColors(CIColor* aColor, CIColor* bColor) {
  return aColor.red == bColor.red && aColor.green == bColor.green && aColor.blue == bColor.blue &&
         aColor.alpha == bColor.alpha;
}

@interface FLTWebViewUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication* app;
@end

@implementation FLTWebViewUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testTransparentBackground {
  XCUIApplication* app = self.app;
  XCUIElement* menu = app.buttons[@"Show menu"];
  if (![menu waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find menu");
  }
  [menu tap];

  XCUIElement* transparentBackground = app.buttons[@"Transparent background example"];
  if (![transparentBackground waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Transparent background example");
  }
  [transparentBackground tap];

  sleep(5);

  XCUIScreenshot* screenshot = [[XCUIScreen mainScreen] screenshot];
  XCTAttachment* screenshotAttachment = [XCTAttachment attachmentWithScreenshot:screenshot];
  [screenshotAttachment setLifetime:XCTAttachmentLifetimeKeepAlways];
  [screenshotAttachment setName:@"Transparent background test screen"];
  [self addAttachment:screenshotAttachment];

  UIImage* screenshotImage = screenshot.image;
  UIColor* centerLeftColor = getPixelColorInImage(
      screenshotImage, 0, (screenshotImage.scale * screenshotImage.size.height) / 2);
  UIColor* centerColor = getPixelColorInImage(
      screenshotImage, (screenshotImage.scale * screenshotImage.size.width) / 2,
      (screenshotImage.scale * screenshotImage.size.height) / 2);
  CIColor* centerLeftCIColor = [CIColor colorWithCGColor:centerLeftColor.CGColor];
  CIColor* centerCIColor = [CIColor colorWithCGColor:centerColor.CGColor];

  XCTAttachment* centerLeftColorAttachment =
      [XCTAttachment attachmentWithString:centerLeftCIColor.stringRepresentation];
  [centerLeftColorAttachment setLifetime:XCTAttachmentLifetimeKeepAlways];
  [centerLeftColorAttachment setName:@"Left color"];
  [self addAttachment:centerLeftColorAttachment];
  XCTAttachment* centerColorAttachment =
      [XCTAttachment attachmentWithString:centerCIColor.stringRepresentation];
  [centerColorAttachment setLifetime:XCTAttachmentLifetimeKeepAlways];
  [centerColorAttachment setName:@"Center color"];
  [self addAttachment:centerColorAttachment];

  // Flutter Colors.green color : 0xFF4CAF50 -> rgba(76, 175, 80, 1)
  // https://github.com/flutter/flutter/blob/f4abaa0735eba4dfd8f33f73363911d63931fe03/packages/flutter/lib/src/material/colors.dart#L1208
  CIColor* flutterGreenColor = [CIColor colorWithRed:76.0f / 255.0f
                                               green:175.0f / 255.0f
                                                blue:80.0f / 255.0f
                                               alpha:1.0f];

  XCTAssertTrue(compareColors(flutterGreenColor, centerLeftCIColor));
  XCTAssertTrue(compareColors(CIColor.redColor, centerCIColor));
}

- (void)testUserAgent {
  XCUIApplication* app = self.app;
  XCUIElement* menu = app.buttons[@"Show menu"];
  if (![menu waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find menu");
  }
  [menu tap];

  XCUIElement* userAgent = app.buttons[@"Show user agent"];
  if (![userAgent waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Show user agent");
  }
  NSPredicate* userAgentPredicate =
      [NSPredicate predicateWithFormat:@"label BEGINSWITH 'User Agent: Mozilla/5.0 (iPhone; '"];
  XCUIElement* userAgentPopUp = [app.otherElements elementMatchingPredicate:userAgentPredicate];
  XCTAssertFalse(userAgentPopUp.exists);
  [userAgent tap];
  if (![userAgentPopUp waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find user agent pop up");
  }
}

- (void)testCache {
  XCUIApplication* app = self.app;
  XCUIElement* menu = app.buttons[@"Show menu"];
  if (![menu waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find menu");
  }
  [menu tap];

  XCUIElement* clearCache = app.buttons[@"Clear cache"];
  if (![clearCache waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Clear cache");
  }
  [clearCache tap];

  [menu tap];

  XCUIElement* listCache = app.buttons[@"List cache"];
  if (![listCache waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find List cache");
  }
  [listCache tap];

  XCUIElement* emptyCachePopup = app.otherElements[@"{\"cacheKeys\":[],\"localStorage\":{}}"];
  if (![emptyCachePopup waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find empty cache pop up");
  }

  [menu tap];
  XCUIElement* addCache = app.buttons[@"Add to cache"];
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

  XCUIElement* cachePopup =
      app.otherElements[@"{\"cacheKeys\":[\"test_caches_entry\"],\"localStorage\":{\"test_"
                        @"localStorage\":\"dummy_entry\"}}"];
  if (![cachePopup waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find cache pop up");
  }
}

@end
