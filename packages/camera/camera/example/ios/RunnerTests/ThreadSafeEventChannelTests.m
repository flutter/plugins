// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeEventChannelTests : XCTestCase
@end

@implementation ThreadSafeEventChannelTests

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  FlutterEventChannel *mockEventChannel = OCMClassMock([FlutterEventChannel class]);
  FLTThreadSafeEventChannel *threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  XCTestExpectation *mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler's completion block must be called on the main thread"];
  OCMStub([mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  });

  [threadSafeEventChannel setStreamHandler:nil
                                completion:^{
                                  if (NSThread.isMainThread) {
                                    [mainThreadCompletionExpectation fulfill];
                                  }
                                }];
  [self waitForExpectations:@[ mainThreadExpectation, mainThreadCompletionExpectation ] timeout:1];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  FlutterEventChannel *mockEventChannel = OCMClassMock([FlutterEventChannel class]);
  FLTThreadSafeEventChannel *threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  XCTestExpectation *mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler's completion block must be called on the main thread"];
  OCMStub([mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [threadSafeEventChannel setStreamHandler:nil
                                  completion:^{
                                    if (NSThread.isMainThread) {
                                      [mainThreadCompletionExpectation fulfill];
                                    }
                                  }];
  });
  [self waitForExpectations:@[
    mainThreadExpectation,
    mainThreadCompletionExpectation,
  ]
                    timeout:1];
}

@end
