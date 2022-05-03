
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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFObjectHostApiImpl *hostApi =
      [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];

  NSObject *object = (

      NSObject *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([object isKindOfClass:[NSObject class]]);

  XCTAssertNil(error);
}

- (void)test AddObserver {
  NSObject
     *mockObject = OCMClassMock([
  
  
  NSObject
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockObject withIdentifier:0];

  FWFObjectHostApiImpl *hostApi =
      [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi addObserverForObjectWithIdentifier:@0

                                     observer:aValue

                                      keyPath:aValue

                                      options:aValue

                                        error:&error];
  OCMVerify([mockObject addObserver

                                   :aValue

                            keyPath:aValue

                            options:aValue

  ]);
  XCTAssertNil(error);
}

- (void)test RemoveObserver {
  NSObject
     *mockObject = OCMClassMock([
  
  
  NSObject
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockObject withIdentifier:0];

  FWFObjectHostApiImpl *hostApi =
      [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeObserverForObjectWithIdentifier:@0

                                        observer:aValue

                                         keyPath:aValue

                                           error:&error];
  OCMVerify([mockObject removeObserver

                                      :aValue

                               keyPath:aValue

  ]);
  XCTAssertNil(error);
}

- (void)test Dispose {
  NSObject
     *mockObject = OCMClassMock([
  
  
  NSObject
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockObject withIdentifier:0];

  FWFObjectHostApiImpl *hostApi =
      [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi disposeObjectWithIdentifier:@0

                                 error:&error];
  OCMVerify([mockObject dispose

  ]);
  XCTAssertNil(error);
}

@end
