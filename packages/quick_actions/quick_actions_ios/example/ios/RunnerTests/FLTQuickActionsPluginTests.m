// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>
#import "TestUtils.h"

@interface FLTQuickActionsTests : XCTestCase
@end

@implementation FLTQuickActionsTests

- (void)testHandleMethodCall_setShortcutItems {
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"setShortcutItems"
                                        arguments:@[ TestUtils.searchTheThingRawItem ]];

  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:mockShortcutStateManager];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result block must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertNil(result, @"result block must be called with nil.");
                      [resultExpectation fulfill];
                    }];

  OCMVerify([mockShortcutStateManager setShortcutItems:@[ TestUtils.searchTheThingRawItem ]]);

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandleMethodCall_clearShortcutItems {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"clearShortcutItems"
                                                              arguments:nil];

  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:mockShortcutStateManager];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result block must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertNil(result, @"result block must be called with nil.");
                      [resultExpectation fulfill];
                    }];

  OCMVerify([mockShortcutStateManager setShortcutItems:@[]]);

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandleMethodCall_getLaunchAction {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"getLaunchAction"
                                                              arguments:nil];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:nil];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result block must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertNil(result, @"result block must be called with nil.");
                      [resultExpectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandleMethodCall_NonExistMethods {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"nonExist" arguments:nil];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:nil];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertEqual(result, FlutterMethodNotImplemented, @"result block must be called with FlutterMethodNotImplemented");
                      [resultExpectation fulfill];
                    }];

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testApplicationPerformActionForShortcutItem {
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:OCMClassMock([FLTShortcutStateManager class])];

  UIApplicationShortcutItem *item = TestUtils.searchTheThingShortcutItem;

  BOOL actionResult = [plugin application:[UIApplication sharedApplication]
             performActionForShortcutItem:item
                        completionHandler:^(BOOL succeeded){
                        }];
  XCTAssert(actionResult, @"performActionForShortcutItem must return true.");

  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
}

- (void)testApplicationDidFinishLaunchingWithOptions_launchWithShortcut {
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:mockShortcutStateManager];

  UIApplicationShortcutItem *item = TestUtils.searchTheThingShortcutItem;

  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsShortcutItemKey : item}];

  XCTAssertFalse(launchResult, @"didFinishLaunchingWithOptions must return false if launched from shortcut.");

  OCMVerify([mockShortcutStateManager setLaunchingShortcutType:item.type]);
}

- (void)testApplicationDidFinishLaunchingWithOptions_launchWithoutShortcut {
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:mockShortcutStateManager];

  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{}];

  XCTAssertTrue(launchResult, @"didFinishLaunchingWithOptions must return true if not launched from shortcut.");
}

- (void)testApplicationDidBecomeActive {
  UIApplicationShortcutItem *item = TestUtils.searchTheThingShortcutItem;

  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  OCMStub([mockShortcutStateManager launchingShortcutType]).andReturn(item.type);

  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:mockShortcutStateManager];

  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];

  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
  OCMVerify([mockShortcutStateManager setLaunchingShortcutType:nil]);
}

@end
