// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeEventChannelTests : XCTestCase
@property(nonatomic, strong) FlutterEventChannel *mockEventChannel;
@property(nonatomic, strong) FLTThreadSafeEventChannel *threadSafeEventChannel;
@end

@implementation ThreadSafeEventChannelTests

- (void)setUp {
  [super setUp];
  _mockEventChannel = OCMClassMock([FlutterEventChannel class]);
  _threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:_mockEventChannel];
}

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  XCTestExpectation *mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler's completion block must be called on the main thread"];
  OCMStub([self.mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  });

  [self.threadSafeEventChannel setStreamHandler:nil
                                     completion:^{
                                       if (NSThread.isMainThread) {
                                         [mainThreadCompletionExpectation fulfill];
                                       }
                                     }];
  [self waitForExpectations:@[ mainThreadExpectation, mainThreadCompletionExpectation ] timeout:1];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  XCTestExpectation *mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler's completion block must be called on the main thread"];
  OCMStub([self.mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.threadSafeEventChannel setStreamHandler:nil
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
