// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;

#import "MockFLTThreadSafeFlutterResult.h"

@implementation MockFLTThreadSafeFlutterResult
/**
 * Initializes the MockFLTThreadSafeFlutterResult.
 */
- (instancetype)init {
  self = [super init];
  return self;
}

/**
 * Initializes the MockFLTThreadSafeFlutterResult with an expectation.
 */
- (instancetype)initWithExpectation:(XCTestExpectation *)expectation {
  self = [super init];
  _expectation = expectation;
  return self;
}

/**
 * Called when result is successful.
 *
 * Stores the data in the `receivedResult` property and fulfills the expectation.
 */
- (void)sendSuccessWithData:(id)data {
  _receivedResult = data;
  [self->_expectation fulfill];
}

/**
 * Called when result is successful.
 *
 * Fulfills the expectation.
 */
- (void)sendSuccess {
  _receivedResult = nil;
  [self->_expectation fulfill];
}
@end
