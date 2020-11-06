// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#import "RunnerUITestUtils.h"

@implementation RunnerUITestUtils

+ (XCUIElement *)waitForFirstExistence:(NSArray *)elements timeout:(NSTimeInterval)timeout {
  if (elements.count == 0) {
    return nil;
  }
  NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
  while ([NSDate timeIntervalSinceReferenceDate] - startTime < timeout) {
    for (XCUIElement *element in elements) {
      if (element.exists) {
        return element;
      }
    }
  }
  return nil;
}

@end
