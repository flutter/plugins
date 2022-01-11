// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeTextureRegistryTests : XCTestCase
@property(nonatomic, strong) FLTThreadSafeTextureRegistry *registry;
@property(nonatomic, strong) XCTestExpectation *registerTextureExpectation;
@property(nonatomic, strong) XCTestExpectation *registerTextureCompletionExpectation;
@property(nonatomic, strong) XCTestExpectation *unregisterTextureExpectation;
@property(nonatomic, strong) XCTestExpectation *textureFrameAvailableExpectation;

@end

@implementation ThreadSafeTextureRegistryTests

- (void)setUp {
  [super setUp];
  id mockTextureRegistry = OCMProtocolMock(@protocol(FlutterTextureRegistry));
  _registry = [[FLTThreadSafeTextureRegistry alloc] initWithTextureRegistry:mockTextureRegistry];

  _registerTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture must be called on the main thread"];
  _unregisterTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"unregisterTexture must be called on the main thread"];
  _textureFrameAvailableExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"textureFrameAvailable must be called on the main thread"];
  _registerTextureCompletionExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture's completion block must be called on the main thread"];

  OCMStub([mockTextureRegistry registerTexture:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self.registerTextureExpectation fulfill];
    }
  });

  OCMStub([mockTextureRegistry unregisterTexture:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self.unregisterTextureExpectation fulfill];
    }
  });

  OCMStub([mockTextureRegistry textureFrameAvailable:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self.textureFrameAvailableExpectation fulfill];
    }
  });
}

- (void)testShouldStayOnMainThreadIfCalledFromMainThread {
  NSObject<FlutterTexture> *anyTexture = OCMProtocolMock(@protocol(FlutterTexture));
  __weak XCTestExpectation *registerTextureCompletionExpectation =
      self.registerTextureCompletionExpectation;
  [self.registry registerTexture:anyTexture
                      completion:^(int64_t textureId) {
                        if (NSThread.isMainThread) {
                          [registerTextureCompletionExpectation fulfill];
                        }
                      }];
  [self.registry textureFrameAvailable:0];
  [self.registry unregisterTexture:0];
  [self waitForExpectations:@[
    self.registerTextureExpectation,
    self.unregisterTextureExpectation,
    self.textureFrameAvailableExpectation,
    self.registerTextureCompletionExpectation,
  ]
                    timeout:1];
}

- (void)testShouldDispatchToMainThreadIfCalledFromBackgroundThread {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSObject<FlutterTexture> *anyTexture = OCMProtocolMock(@protocol(FlutterTexture));
    __weak XCTestExpectation *registerTextureCompletionExpectation =
        self.registerTextureCompletionExpectation;
    [self.registry registerTexture:anyTexture
                        completion:^(int64_t textureId) {
                          if (NSThread.isMainThread) {
                            [registerTextureCompletionExpectation fulfill];
                          }
                        }];
    [self.registry textureFrameAvailable:0];
    [self.registry unregisterTexture:0];
  });
  [self waitForExpectations:@[
    self.registerTextureExpectation,
    self.unregisterTextureExpectation,
    self.textureFrameAvailableExpectation,
    self.registerTextureCompletionExpectation,
  ]
                    timeout:1];
}

@end
