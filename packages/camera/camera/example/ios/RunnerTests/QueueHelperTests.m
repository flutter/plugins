// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;

@interface QueueHelperTests : XCTestCase

@end

@implementation QueueHelperTests

- (void)testShouldStayOnMainQueueIfCalledFromMainQueue {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Block must be run on the main queue."];
  [QueueHelper ensureToRunOnMainQueue:^{
    if (NSThread.isMainThread) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldDispatchToMainQueueIfCalledFromBackgroundQueue {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Block must be run on the main queue."];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [QueueHelper ensureToRunOnMainQueue:^{
      if (NSThread.isMainThread) {
        [expectation fulfill];
      }
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSetAndCheckQueueSpecific {
  dispatch_queue_t queue = dispatch_queue_create("test", NULL);
  const char *specific = "specific";
  [QueueHelper setSpecific:specific forQueue:queue];

  XCTAssertFalse([QueueHelper isCurrentlyOnQueueWithSpecific:specific],
                 @"Must not be on the test queue before dispatching to it.");

  // Note: sync call
  dispatch_sync(queue, ^{
    XCTAssert([QueueHelper isCurrentlyOnQueueWithSpecific:specific],
              @"Must be on the test queue after dispatching to it.");
  });

  XCTAssertFalse([QueueHelper isCurrentlyOnQueueWithSpecific:specific],
                 @"Must not be on the test queue outside of dispatch_sync block.");
}

@end
