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

// A dummy `UIApplicationShortcutItem`.
- (UIApplicationShortcutItem *)searchTheThingShortcutItem {
  return [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];
}

// A dummy raw shortcut item.
- (NSDictionary<NSString *, NSString *> *)searchTheThingRawItem {
  return @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    @"icon" : @"search_the_thing.png",
  };
}

- (void)testHandleMethodCall_setShortcutItems {
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"setShortcutItems"
                                        arguments:@[ [self searchTheThingRawItem] ]];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result block must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertNil(result, @"result block must be called with nil.");
                      XCTAssertEqualObjects(UIApplication.sharedApplication.shortcutItems,
                                            @[ [self searchTheThingShortcutItem] ],
                                            @"shortcut items should be set correctly.");
                      [resultExpectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandleMethodCall_clearShortcutItems {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"clearShortcutItems"
                                                              arguments:nil];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"result block must be called."];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertNil(result, @"result block must be called with nil.");
                      XCTAssertEqual(UIApplication.sharedApplication.shortcutItems.count, 0,
                                     @"shortcut items should be cleared");
                      [resultExpectation fulfill];
                    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandleMethodCall_getLaunchAction {
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"getLaunchAction"
                                                              arguments:nil];

  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];
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
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];
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
  FLTQuickActionsPlugin *plugin = [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel];

  UIApplicationShortcutItem *item = [self searchTheThingShortcutItem];

  BOOL actionResult = [plugin application:[UIApplication sharedApplication]
             performActionForShortcutItem:item
                        completionHandler:^(BOOL succeeded){/* no-op */}];
  XCTAssert(actionResult, @"performActionForShortcutItem must return true.");
  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
}

- (void)testApplicationDidFinishLaunchingWithOptions_launchWithShortcut {
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];

  UIApplicationShortcutItem *item = [self searchTheThingShortcutItem];

  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsShortcutItemKey : item}];

  XCTAssertFalse(launchResult,
                 @"didFinishLaunchingWithOptions must return false if launched from shortcut.");
}

- (void)testApplicationDidFinishLaunchingWithOptions_launchWithoutShortcut {
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];
  BOOL launchResult = [plugin application:[UIApplication sharedApplication]
            didFinishLaunchingWithOptions:@{}];
  XCTAssertTrue(launchResult,
                @"didFinishLaunchingWithOptions must return true if not launched from shortcut.");
}

- (void)testApplicationDidBecomeActive {
  UIApplicationShortcutItem *item = [self searchTheThingShortcutItem];
  id mockChannel = OCMClassMock([FlutterMethodChannel class]);
  FLTQuickActionsPlugin *plugin = [[FLTQuickActionsPlugin alloc] initWithChannel:mockChannel];
  plugin.launchingShortcutType = item.type;
  [plugin applicationDidBecomeActive:[UIApplication sharedApplication]];

  OCMVerify([mockChannel invokeMethod:@"launch" arguments:item.type]);
  XCTAssertNil(plugin.launchingShortcutType,
               @"Must reset launchingShortcutType to nil after being used.");
}

@end
