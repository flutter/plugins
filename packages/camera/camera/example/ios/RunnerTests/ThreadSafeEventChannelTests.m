// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeEventChannelTests : XCTestCase
@property(nonatomic, strong) FLTThreadSafeEventChannel *channel;
@property(nonatomic, strong) XCTestExpectation *mainThreadExpectation;
@property(nonatomic, strong) XCTestExpectation *mainThreadCompletionExpectation;
@end

@implementation ThreadSafeEventChannelTests

- (void)setUp {
  [super setUp];
  id mockEventChannel = OCMClassMock([FlutterEventChannel class]);

  _mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler must be called on the main thread"];
  _mainThreadCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"setStreamHandler's completion block must be called on the main thread"];
  _channel = [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  OCMStub([mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self.mainThreadExpectation fulfill];
    }
  });
}

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  __weak XCTestExpectation *mainThreadCompletionExpectation = self.mainThreadCompletionExpectation;
  [self.channel setStreamHandler:nil
                      completion:^{
                        if (NSThread.isMainThread) {
                          [mainThreadCompletionExpectation fulfill];
                        }
                      }];
  [self waitForExpectations:@[ self.mainThreadExpectation, self.mainThreadCompletionExpectation ]
                    timeout:1];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  __weak XCTestExpectation *mainThreadCompletionExpectation = self.mainThreadCompletionExpectation;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.channel setStreamHandler:nil
                        completion:^{
                          if (NSThread.isMainThread) {
                            [mainThreadCompletionExpectation fulfill];
                          }
                        }];
  });
  [self waitForExpectations:@[
    self.mainThreadExpectation,
    self.mainThreadCompletionExpectation,
  ]
                    timeout:1];
}

@end
