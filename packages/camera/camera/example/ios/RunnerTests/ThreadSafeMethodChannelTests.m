// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeMethodChannelTests : XCTestCase
@property(nonatomic, strong) FLTThreadSafeMethodChannel *channel;
@property(nonatomic, strong) XCTestExpectation *mainThreadExpectation;
@end

@implementation ThreadSafeMethodChannelTests

- (void)setUp {
  [super setUp];
  id mockMethodChannel = OCMClassMock([FlutterMethodChannel class]);

  _mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"invokeMethod must be called on the main thread"];
  _channel = [[FLTThreadSafeMethodChannel alloc] initWithMethodChannel:mockMethodChannel];

  OCMStub([mockMethodChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (NSThread.isMainThread) {
          [self.mainThreadExpectation fulfill];
        }
      });
}

- (void)testInvokeMethod_shouldStayOnMainThreadIfCalledFromMainThread {
  [self.channel invokeMethod:@"foo" arguments:nil];

  [self waitForExpectations:@[ self.mainThreadExpectation ] timeout:1];
}

- (void)testInvokeMethod__shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.channel invokeMethod:@"foo" arguments:nil];
  });
  [self waitForExpectations:@[ self.mainThreadExpectation ] timeout:1];
}

@end
