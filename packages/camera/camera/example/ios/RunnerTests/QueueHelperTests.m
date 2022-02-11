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

- (void)testCreateQueue {
  const char *label = "label";
  const char *specific = "specific";
  dispatch_queue_t queue = [QueueHelper createQueueWithLabel:label specific:specific];
  XCTAssert(0 == strcmp(label, dispatch_queue_get_label(queue)), "Must set the correct label.");
  XCTAssert(0 == strcmp(specific, dispatch_queue_get_specific(queue, specific)),
            "Must set the correct specific.");
}

- (void)testIsCurrentlyOnQueueWithSpecific {
  const char *specific = "specific";
  dispatch_queue_t queue = [QueueHelper createQueueWithLabel:"test" specific:specific];
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
