// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeMethodChannelTests : XCTestCase
@end

@implementation ThreadSafeMethodChannelTests {
  FLTThreadSafeMethodChannel *_channel;
  XCTestExpectation *_mainThreadExpectation;
}

- (void)setUp {
  [super setUp];
  id mockMethodChannel = OCMClassMock([FlutterMethodChannel class]);

  _mainThreadExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"invokeMethod must be called in main thread"];
  _channel = [[FLTThreadSafeMethodChannel alloc] initWithMethodChannel:mockMethodChannel];

  OCMStub([mockMethodChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (NSThread.isMainThread) {
          [self->_mainThreadExpectation fulfill];
        }
      });
}

- (void)testInvokeMethod_shouldStayOnMainThreadIfCalledFromMainThread {
  [_channel invokeMethod:@"foo" arguments:nil];

  [self waitForExpectations:@[ _mainThreadExpectation ] timeout:1];
}

- (void)testInvokeMethod__shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self->_channel invokeMethod:@"foo" arguments:nil];
  });
  [self waitForExpectations:@[ _mainThreadExpectation ] timeout:1];
}

@end
