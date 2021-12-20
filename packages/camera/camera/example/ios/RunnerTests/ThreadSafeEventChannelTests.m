// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeEventChannelTests : XCTestCase
@end

@implementation ThreadSafeEventChannelTests {
  FLTThreadSafeEventChannel *_channel;
  XCTestExpectation *_mainThreadExpectation;
}

- (void)setUp {
  [super setUp];
  id mockEventChannel = OCMClassMock([FlutterEventChannel class]);

  _mainThreadExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"invokeMethod must be called in main thread"];
  _channel = [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  OCMStub([mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self->_mainThreadExpectation fulfill];
    }
  });
}

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  [_channel setStreamHandler:nil];
  [self waitForExpectations:@[ _mainThreadExpectation ] timeout:1];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self->_channel setStreamHandler:nil];
  });
  [self waitForExpectations:@[ _mainThreadExpectation ] timeout:1];
}

@end
