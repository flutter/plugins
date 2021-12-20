// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeTextureRegistryTests : XCTestCase
@end

@implementation ThreadSafeTextureRegistryTests {
  FLTThreadSafeTextureRegistry *_registry;
  XCTestExpectation *_registerTextureExpectation;
  XCTestExpectation *_unregisterTextureExpectation;
  XCTestExpectation *_textureFrameAvailableExpectation;
}

- (void)setUp {
  [super setUp];
  id mockTextureRegistry = OCMProtocolMock(@protocol(FlutterTextureRegistry));
  _registry = [[FLTThreadSafeTextureRegistry alloc] initWithTextureRegistry:mockTextureRegistry];

  _registerTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"registerTexture must be called in main thread"];
  _unregisterTextureExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"unregisterTexture must be called in main thread"];
  _textureFrameAvailableExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"textureFrameAvailable must be called in main thread"];

  OCMStub([mockTextureRegistry registerTexture:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self->_registerTextureExpectation fulfill];
    }
  });

  OCMStub([mockTextureRegistry unregisterTexture:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self->_unregisterTextureExpectation fulfill];
    }
  });

  OCMStub([mockTextureRegistry textureFrameAvailable:0]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [self->_textureFrameAvailableExpectation fulfill];
    }
  });
}

- (void)testShouldStayOnMainThreadIfCalledFromMainThread {
  NSObject<FlutterTexture> *anyTexture = OCMProtocolMock(@protocol(FlutterTexture));
  [_registry registerTextureSync:anyTexture];
  [_registry textureFrameAvailable:0];
  [_registry unregisterTexture:0];
  [self waitForExpectations:@[
    _registerTextureExpectation, _unregisterTextureExpectation, _textureFrameAvailableExpectation
  ]
                    timeout:1];
}

- (void)testShouldDispatchToMainThreadIfCalledFromBackgroundThread {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSObject<FlutterTexture> *anyTexture = OCMProtocolMock(@protocol(FlutterTexture));
    [self->_registry registerTextureSync:anyTexture];
    [self->_registry textureFrameAvailable:0];
    [self->_registry unregisterTexture:0];
  });
  [self waitForExpectations:@[
    _registerTextureExpectation, _unregisterTextureExpectation, _textureFrameAvailableExpectation
  ]
                    timeout:1];
}

@end
