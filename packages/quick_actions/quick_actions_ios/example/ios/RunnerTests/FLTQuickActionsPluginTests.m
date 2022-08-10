// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>

@interface FLTQuickActionsPluginTests : XCTestCase

@end

@implementation FLTQuickActionsPluginTests

- (void)testHandleMethodCall_setShortcutItems {
  NSDictionary *rawItem = @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    @"icon" : @"search_the_thing.png",
  };

  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"setShortcutItems"
                                                              arguments:@[ rawItem ]];

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

  OCMVerify([mockShortcutStateManager setShortcutItems:@[ rawItem ]]);
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

  UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];

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

  UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];

  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsShortcutItemKey : item}];

  XCTAssertFalse(launchResult,
                 @"didFinishLaunchingWithOptions must return false if launched from shortcut.");
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

- (void)testApplicationDidBecomeActive_launchWithoutShortcut {
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:mockShortcutStateManager];

  [plugin application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:@{}];
  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];
  OCMVerify(never(), [mockChannel invokeMethod:OCMOCK_ANY arguments:OCMOCK_ANY]);
}

- (void)testApplicationDidBecomeActive_launchWithShortcut {
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:mockShortcutStateManager];

  UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];
  [plugin application:[UIApplication sharedApplication]
      didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsShortcutItemKey : item}];

  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];
  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
}

- (void)testApplicationDidBecomeActive_launchWithShortcut_becomeActiveTwice {
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  id mockShortcutStateManager = OCMClassMock([FLTShortcutStateManager class]);
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel
                                shortcutStateManager:mockShortcutStateManager];

  UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];
  [plugin application:[UIApplication sharedApplication]
      didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsShortcutItemKey : item}];

  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];
  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];
  // shortcut should only be handled once per launch.
  OCMVerify(times(1), [mockChannel invokeMethod:@"launch" arguments:item.type]);
}

@end
