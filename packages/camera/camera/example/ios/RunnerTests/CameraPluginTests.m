// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;

#import <OCMock/OCMock.h>

@interface CameraPlugin ()
- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger;
- (BOOL)handleMethodCallSync:(FlutterMethodCall *)call result:(FlutterResult)result;
- (BOOL)handleMethodCallAsync:(FlutterMethodCall *)call result:(FlutterResult)result;
@end

@interface CameraPluginTests : XCTestCase
@property(strong, nonatomic) id mockRegistrar;
@property(strong, nonatomic) id mockMessenger;
@property(strong, nonatomic) CameraPlugin *plugin;
@end

@implementation CameraPluginTests

- (void)setUp {
  [super setUp];
  self.mockRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  self.mockMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  OCMStub([self.mockRegistrar messenger]).andReturn(self.mockMessenger);
  self.plugin = [[CameraPlugin alloc] initWithRegistry:self.mockRegistrar
                                             messenger:self.mockMessenger];
}

- (void)testHandleMethodCallSync_ShouldHandleSyncMethods {
  id methodCallMock = OCMClassMock([FlutterMethodCall class]);
  OCMStub([methodCallMock method]).andReturn(@"create");

  BOOL result = [[self plugin] handleMethodCallSync:methodCallMock
                                             result:^(id _Nullable result){
                                             }];

  XCTAssertTrue(result);
}

- (void)testHandleMethodCallSync_ShouldNotHandleAsyncMethods {
  id methodCallMock = OCMClassMock([FlutterMethodCall class]);
  OCMStub([methodCallMock method]).andReturn(@"initialize");

  BOOL result = [[self plugin] handleMethodCallSync:methodCallMock
                                             result:^(id _Nullable result){
                                             }];

  XCTAssertFalse(result);
}

- (void)testHandleMethodCallAsync_ShouldHandleAsyncMethods {
  id methodCallMock = OCMClassMock([FlutterMethodCall class]);
  OCMStub([methodCallMock method]).andReturn(@"initialize");

  BOOL result = [[self plugin] handleMethodCallAsync:methodCallMock
                                              result:^(id _Nullable result){
                                              }];

  XCTAssertTrue(result);
}

- (void)testHandleMethodCallAsync_ShouldNotHandleSyncMethods {
  id methodCallMock = OCMClassMock([FlutterMethodCall class]);
  OCMStub([methodCallMock method]).andReturn(@"create");

  BOOL result = [[self plugin] handleMethodCallAsync:methodCallMock
                                              result:^(id _Nullable result){
                                              }];

  XCTAssertFalse(result);
}

- (void)testHandleMethodCall_ShouldNotCallAsyncHandlerForSyncMethod {
  id methodCallMock = OCMClassMock([FlutterMethodCall class]);
  OCMStub([methodCallMock method]).andReturn(@"create");
  id mockedPlugin = OCMPartialMock(self.plugin);
  id result = ^(id _Nullable result) {
  };
  OCMStub([mockedPlugin handleMethodCallSync:methodCallMock result:result]).andReturn(true);
  OCMStub([mockedPlugin handleMethodCallAsync:methodCallMock result:result]).andReturn(false);

  [[self plugin] handleMethodCall:methodCallMock result:result];

  OCMVerify([mockedPlugin handleMethodCallSync:methodCallMock result:result]);
  OCMVerify(never(), [mockedPlugin handleMethodCallAsync:methodCallMock result:result]);
}

- (void)testHandleMethodCall_ShouldCallAsyncHandlerForAsyncMethod {
  id methodCallMock = OCMClassMock([FlutterMethodCall class]);
  OCMStub([methodCallMock method]).andReturn(@"initialize");
  id mockedPlugin = OCMPartialMock(self.plugin);
  id result = ^(id _Nullable result) {
  };
  OCMStub([mockedPlugin handleMethodCallSync:methodCallMock result:result]).andReturn(false);
  OCMStub([mockedPlugin handleMethodCallAsync:methodCallMock result:result]).andReturn(true);

  [[self plugin] handleMethodCall:methodCallMock result:result];

  OCMVerify([mockedPlugin handleMethodCallSync:methodCallMock result:result]);
  OCMVerify([mockedPlugin handleMethodCallAsync:methodCallMock result:result]);
}

@end
