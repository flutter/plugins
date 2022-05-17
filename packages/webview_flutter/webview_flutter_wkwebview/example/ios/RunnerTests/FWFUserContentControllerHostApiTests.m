// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFUserContentControllerHostApiTests : XCTestCase
@end

@implementation FWFUserContentControllerHostApiTests
- (void)testCreateFromWebViewConfigurationWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  [instanceManager addInstance:[[WKWebViewConfiguration alloc] init] withIdentifier:0];

  FlutterError *error;
  [hostApi createFromWebViewConfigurationWithIdentifier:@1 configurationIdentifier:@0 error:&error];
  WKUserContentController *userContentController =
      (WKUserContentController *)[instanceManager instanceForIdentifier:1];
  XCTAssertTrue([userContentController isKindOfClass:[WKUserContentController class]]);
  XCTAssertNil(error);
}

- (void)testAddScriptMessageHandler {
  WKUserContentController *mockUserContentController =
      OCMClassMock([WKUserContentController class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  id<WKScriptMessageHandler> mockMessageHandler =
      OCMProtocolMock(@protocol(WKScriptMessageHandler));
  [instanceManager addInstance:mockMessageHandler withIdentifier:1];

  FlutterError *error;
  [hostApi addScriptMessageHandlerForControllerWithIdentifier:@0
                                            handlerIdentifier:@1
                                                       ofName:@"apple"
                                                        error:&error];
  OCMVerify([mockUserContentController addScriptMessageHandler:mockMessageHandler name:@"apple"]);
  XCTAssertNil(error);
}

- (void)testRemoveScriptMessageHandler {
  WKUserContentController *mockUserContentController =
      OCMClassMock([WKUserContentController class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeScriptMessageHandlerForControllerWithIdentifier:@0 name:@"apple" error:&error];
  OCMVerify([mockUserContentController removeScriptMessageHandlerForName:@"apple"]);
  XCTAssertNil(error);
}

- (void)testRemoveAllScriptMessageHandlers API_AVAILABLE(ios(14.0)) {
  WKUserContentController *mockUserContentController =
      OCMClassMock([WKUserContentController class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllScriptMessageHandlersForControllerWithIdentifier:@0 error:&error];
  OCMVerify([mockUserContentController removeAllScriptMessageHandlers]);
  XCTAssertNil(error);
}

- (void)testAddUserScript {
  WKUserContentController *mockUserContentController =
      OCMClassMock([WKUserContentController class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi
      addUserScriptForControllerWithIdentifier:@0
                                    userScript:
                                        [FWFWKUserScriptData
                                             makeWithSource:@"runAScript"
                                              injectionTime:
                                                  [FWFWKUserScriptInjectionTimeEnumData
                                                      makeWithValue:
                                                          FWFWKUserScriptInjectionTimeEnumAtDocumentEnd]
                                            isMainFrameOnly:@YES]
                                         error:&error];

  OCMVerify([mockUserContentController addUserScript:[OCMArg isKindOfClass:[WKUserScript class]]]);
  XCTAssertNil(error);
}

- (void)testRemoveAllUserScripts {
  WKUserContentController *mockUserContentController =
      OCMClassMock([WKUserContentController class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllUserScriptsForControllerWithIdentifier:@0 error:&error];
  OCMVerify([mockUserContentController removeAllUserScripts]);
  XCTAssertNil(error);
}
@end
