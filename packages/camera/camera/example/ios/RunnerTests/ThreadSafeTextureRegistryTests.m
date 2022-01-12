// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeTextureRegistryTests : XCTestCase
@property(nonatomic, strong) NSObject<FlutterTextureRegistry> *mockTextureRegistry;
@property(nonatomic, strong) FLTThreadSafeTextureRegistry *threadSafeTextureRegistry;
@end

@implementation ThreadSafeTextureRegistryTests

- (void)setUp {
  [super setUp];
  _mockTextureRegistry = OCMProtocolMock(@protocol(FlutterTextureRegistry));
  _threadSafeTextureRegistry =
      [[FLTThreadSafeTextureRegistry alloc] initWithTextureRegistry:_mockTextureRegistry];
}

- (void)testShouldStayOnMainThreadIfCalledFromMainThread {
  XCTestExpectation *registerTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture must be called on the main thread"];
  XCTestExpectation *unregisterTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"unregisterTexture must be called on the main thread"];
  XCTestExpectation *textureFrameAvailableExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"textureFrameAvailable must be called on the main thread"];
  XCTestExpectation *registerTextureCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture's completion block must be called on the main thread"];

  OCMStub([self.mockTextureRegistry registerTexture:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (NSThread.isMainThread) {
          [registerTextureExpectation fulfill];
        }
      });

  OCMStub([self.mockTextureRegistry unregisterTexture:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [unregisterTextureExpectation fulfill];
    }
  });

  OCMStub([self.mockTextureRegistry textureFrameAvailable:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [textureFrameAvailableExpectation fulfill];
    }
  });

  NSObject<FlutterTexture> *anyTexture = OCMProtocolMock(@protocol(FlutterTexture));
  [self.threadSafeTextureRegistry registerTexture:anyTexture
                                       completion:^(int64_t textureId) {
                                         if (NSThread.isMainThread) {
                                           [registerTextureCompletionExpectation fulfill];
                                         }
                                       }];
  [self.threadSafeTextureRegistry textureFrameAvailable:0];
  [self.threadSafeTextureRegistry unregisterTexture:0];
  [self waitForExpectations:@[
    registerTextureExpectation,
    unregisterTextureExpectation,
    textureFrameAvailableExpectation,
    registerTextureCompletionExpectation,
  ]
                    timeout:1];
}

- (void)testShouldDispatchToMainThreadIfCalledFromBackgroundThread {
  XCTestExpectation *registerTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture must be called on the main thread"];
  XCTestExpectation *unregisterTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"unregisterTexture must be called on the main thread"];
  XCTestExpectation *textureFrameAvailableExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"textureFrameAvailable must be called on the main thread"];
  XCTestExpectation *registerTextureCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture's completion block must be called on the main thread"];

  OCMStub([self.mockTextureRegistry registerTexture:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (NSThread.isMainThread) {
          [registerTextureExpectation fulfill];
        }
      });

  OCMStub([self.mockTextureRegistry unregisterTexture:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [unregisterTextureExpectation fulfill];
    }
  });

  OCMStub([self.mockTextureRegistry textureFrameAvailable:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [textureFrameAvailableExpectation fulfill];
    }
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSObject<FlutterTexture> *anyTexture = OCMProtocolMock(@protocol(FlutterTexture));
    [self.threadSafeTextureRegistry registerTexture:anyTexture
                                         completion:^(int64_t textureId) {
                                           if (NSThread.isMainThread) {
                                             [registerTextureCompletionExpectation fulfill];
                                           }
                                         }];
    [self.threadSafeTextureRegistry textureFrameAvailable:0];
    [self.threadSafeTextureRegistry unregisterTexture:0];
  });
  [self waitForExpectations:@[
    registerTextureExpectation,
    unregisterTextureExpectation,
    textureFrameAvailableExpectation,
    registerTextureCompletionExpectation,
  ]
                    timeout:1];
}

@end
