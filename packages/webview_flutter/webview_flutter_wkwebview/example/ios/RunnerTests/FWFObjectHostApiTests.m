// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFObjectHostApiTests : XCTestCase
@end

@implementation FWFObjectHostApiTests
- (void)testAddObserver {
  NSObject *mockObject = OCMClassMock([NSObject class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockObject withIdentifier:0];

  FWFObjectHostApiImpl *hostApi = [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];
  
  NSObject *observerObject = [[NSObject alloc] init];
  [instanceManager addInstance:observerObject withIdentifier:1];

  FlutterError *error;
  [hostApi addObserverForObjectWithIdentifier:@0
                            observerIdentifier:@1
                            keyPath:@"myKey"
                            options:@[[FWFNSKeyValueObservingOptionsEnumData makeWithValue:FWFNSKeyValueObservingOptionsEnumOldValue],
                                      [FWFNSKeyValueObservingOptionsEnumData makeWithValue:FWFNSKeyValueObservingOptionsEnumNewValue]]
                              error:&error];
  
  OCMVerify([mockObject addObserver:observerObject forKeyPath:@"myKey" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil]);
  XCTAssertNil(error);
}

- (void)testRemoveObserver {
  NSObject *mockObject = OCMClassMock([NSObject class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockObject withIdentifier:0];

  FWFObjectHostApiImpl *hostApi =
      [[FWFObjectHostApiImpl alloc]
          initWithInstanceManager:instanceManager];
  
  NSObject *observerObject = [[NSObject alloc] init];
  [instanceManager addInstance:observerObject withIdentifier:1];

  FlutterError *error;
  [hostApi removeObserverForObjectWithIdentifier:@0
                            observerIdentifier:@1
                            keyPath:@"myKey"
                               error:&error];
  OCMVerify([mockObject removeObserver:observerObject forKeyPath:@"myKey"]);
  XCTAssertNil(error);
}

- (void)testDispose {
  NSObject *object = [[NSObject alloc] init];

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:object withIdentifier:0];

  FWFObjectHostApiImpl *hostApi =
      [[FWFObjectHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi disposeObjectWithIdentifier:@0 error:&error];
  XCTAssertEqual([instanceManager identifierForInstance:object], NSNotFound);
  XCTAssertNil(error);
}

@end
