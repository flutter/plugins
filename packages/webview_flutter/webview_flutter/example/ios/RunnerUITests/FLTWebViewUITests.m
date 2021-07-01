// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import os.log;

UIColor* getPixelColorInImage(UIImage* image, int x, int y) {
  CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
  const UInt8* data = CFDataGetBytePtr(pixelData);

  int pixelInfo = ((image.size.width * image.scale * y) + x) * 4;  // 4 bytes per pixel

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

bool compareColors(CIColor* aColor, CIColor* bColor) {
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
  XCTAttachment* attachment = [XCTAttachment attachmentWithScreenshot:screenshot];
  [attachment setLifetime:XCTAttachmentLifetimeKeepAlways];
  [attachment setName:@"Transparent background test screen"];
  [self addAttachment:attachment];

  UIImage* image = screenshot.image;
  UIColor* leftcolor = getPixelColorInImage(image, 0, (image.scale * image.size.height) / 2);
  UIColor* centercolor = getPixelColorInImage(image, (image.scale * image.size.width) / 2,
                                              (image.scale * image.size.height) / 2);
  CIColor* leftcicolor = [CIColor colorWithCGColor:leftcolor.CGColor];
  CIColor* centercicolor = [CIColor colorWithCGColor:centercolor.CGColor];

  XCTAttachment* colorLeftAtt =
      [XCTAttachment attachmentWithString:leftcicolor.stringRepresentation];
  [colorLeftAtt setLifetime:XCTAttachmentLifetimeKeepAlways];
  [colorLeftAtt setName:@"Left color"];
  [self addAttachment:colorLeftAtt];
  XCTAttachment* colorCenterAtt =
      [XCTAttachment attachmentWithString:centercicolor.stringRepresentation];
  [colorCenterAtt setLifetime:XCTAttachmentLifetimeKeepAlways];
  [colorCenterAtt setName:@"Center color"];
  [self addAttachment:colorCenterAtt];

  CIColor* flutterGreenColor = [CIColor colorWithRed:76.0f / 255.0f
                                               green:175.0f / 255.0f
                                                blue:80.0f / 255.0f
                                               alpha:1.0f];

  XCTAssertTrue(compareColors(flutterGreenColor, leftcicolor));
  XCTAssertTrue(compareColors(CIColor.redColor, centercicolor));
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
