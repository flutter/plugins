// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>
#import "Fixtures.h"

@interface FLTQuickActionsPluginTests : XCTestCase

@end

@implementation FLTQuickActionsPluginTests

- (void)testHandleMethodCall_setShortcutItems {
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"setShortcutItems"
                                        arguments:@[ [Fixtures searchTheThingRawItem] ]];

  FLTShortcutStateManager *mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);

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
  [self waitForExpectationsWithTimeout:1 handler:nil];
  OCMVerify([mockShortcutStateManager setShortcutItems:@[ [Fixtures searchTheThingRawItem] ]]);
}

- (void)testHandleMethodCall_clearShortcutItems {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"clearShortcutItems"
                                                              arguments:nil];
  FLTShortcutStateManager *mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
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
  [self waitForExpectationsWithTimeout:1 handler:nil];
  OCMVerify([mockShortcutStateManager setShortcutItems:@[]]);
}

- (void)testHandleMethodCall_getLaunchAction {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"getLaunchAction"
                                                              arguments:nil];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:OCMClassMock([FLTShortcutStateManager class])];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result block must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertNil(result, @"result block must be called with nil.");
                      [resultExpectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandleMethodCall_nonExistMethods {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"nonExist" arguments:nil];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:OCMClassMock([FLTShortcutStateManager class])];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result must be called."];
  [plugin
      handleMethodCall:call
                result:^(id _Nullable result) {
                  XCTAssertEqual(result, FlutterMethodNotImplemented,
                                 @"result block must be called with FlutterMethodNotImplemented");
                  [resultExpectation fulfill];
                }];

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testApplicationPerformActionForShortcutItem {
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:OCMClassMock([FLTShortcutStateManager class])];

  UIApplicationShortcutItem *item = [Fixtures searchTheThingShortcutItem];

  BOOL actionResult = [plugin application:[UIApplication sharedApplication]
             performActionForShortcutItem:item
                        completionHandler:^(BOOL succeeded){/* no-op */}];
  XCTAssert(actionResult, @"performActionForShortcutItem must return true.");
  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
}

- (void)testApplicationDidFinishLaunchingWithOptions_launchWithShortcut {
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:mockShortcutStateManager];

  UIApplicationShortcutItem *item = [Fixtures searchTheThingShortcutItem];

  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsShortcutItemKey : item}];

  XCTAssertFalse(launchResult,
                 @"didFinishLaunchingWithOptions must return false if launched from shortcut.");
  OCMVerify([mockShortcutStateManager setLaunchingShortcutType:item.type]);
}

- (void)testApplicationDidFinishLaunchingWithOptions_launchWithoutShortcut {
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])
                                shortcutStateManager:OCMClassMock([FLTShortcutStateManager class])];
  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{}];
  XCTAssertTrue(launchResult,
                @"didFinishLaunchingWithOptions must return true if not launched from shortcut.");
}

- (void)testApplicationDidBecomeActive {
  UIApplicationShortcutItem *item = [Fixtures searchTheThingShortcutItem];
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:mockShortcutStateManager];
  OCMStub([mockShortcutStateManager launchingShortcutType]).andReturn(item.type);
  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];

  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
  OCMVerify([mockShortcutStateManager setLaunchingShortcutType:nil]);
}

@end
