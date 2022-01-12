// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeMethodChannelTests : XCTestCase
@property(nonatomic, strong) FlutterMethodChannel *mockMethodChannel;
@property(nonatomic, strong) FLTThreadSafeMethodChannel *threadSafeMethodChannel;
@end

@implementation ThreadSafeMethodChannelTests

- (void)setUp {
  [super setUp];
  _mockMethodChannel = OCMClassMock([FlutterMethodChannel class]);
  _threadSafeMethodChannel =
      [[FLTThreadSafeMethodChannel alloc] initWithMethodChannel:_mockMethodChannel];
}

- (void)testInvokeMethod_shouldStayOnMainThreadIfCalledFromMainThread {
  XCTestExpectation *mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"invokeMethod must be called on the main thread"];

  OCMStub([self.mockMethodChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (NSThread.isMainThread) {
          [mainThreadExpectation fulfill];
        }
      });

  [self.threadSafeMethodChannel invokeMethod:@"foo" arguments:nil];
  [self waitForExpectations:@[ mainThreadExpectation ] timeout:1];
}

- (void)testInvokeMethod__shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  XCTestExpectation *mainThreadExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"invokeMethod must be called on the main thread"];

  OCMStub([self.mockMethodChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (NSThread.isMainThread) {
          [mainThreadExpectation fulfill];
        }
      });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.threadSafeMethodChannel invokeMethod:@"foo" arguments:nil];
  });
  [self waitForExpectations:@[ mainThreadExpectation ] timeout:1];
}

@end
