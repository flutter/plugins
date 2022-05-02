
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFPreferencesHostApiTests : XCTestCase
@end

@implementation FWFPreferencesHostApiTests

- (void)testSetJavaScriptEnabled {
  FWFWebView *mockPreferences = OCMClassMock([
  
  
  setJavaScriptEnabled
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockPreferences withIdentifier:0];

  FWFPreferencesHostApiImpl *hostApi =
      [[FWFPreferencesHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setJavaScriptEnabledForPreferencesWithIdentifier
  
  :aValue
  
  
  error:&error];
  OCMVerify([mockWebView setJavaScriptEnabled:
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFWebsiteDataStoreHostApiTests : XCTestCase
@end

@implementation FWFWebsiteDataStoreHostApiTests

- (void)testRemoveDataOfTypes {
  FWFWebView *mockWebsiteDataStore = OCMClassMock([
  
  
  removeDataOfTypes
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebsiteDataStore withIdentifier:0];

  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeDataFromDataStoreWithIdentifier
  
  :aValue
  
  
  since:aValue
  
  error:&error];
  OCMVerify([mockWebView removeDataOfTypes:
  
  :aValue
  
  
  since:aValue
  
  ]);
  XCTAssertNil(error);
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFHttpCookieStoreHostApiTests : XCTestCase
@end

@implementation FWFHttpCookieStoreHostApiTests

- (void)testSetCookie {
  FWFWebView *mockHttpCookieStore = OCMClassMock([
  
  
  setCookie
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockHttpCookieStore withIdentifier:0];

  FWFHttpCookieStoreHostApiImpl *hostApi =
      [[FWFHttpCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setCookieForStoreWithIdentifier
  
  :aValue
  
  
  error:&error];
  OCMVerify([mockWebView setCookie:
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFScriptMessageHandlerHostApiTests : XCTestCase
@end

@implementation FWFScriptMessageHandlerHostApiTests

@end

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

- (void)testAddScriptMessageHandler {
  FWFWebView *mockUserContentController = OCMClassMock([
  
  
  addScriptMessageHandler
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi addScriptMessageHandlerForControllerWithIdentifier
  
  :aValue
  
  
  name:aValue
  
  error:&error];
  OCMVerify([mockWebView addScriptMessageHandler:
  
  :aValue
  
  
  name:aValue
  
  ]);
  XCTAssertNil(error);
}

- (void)testRemoveScriptMessageHandler {
  FWFWebView *mockUserContentController = OCMClassMock([
  
  
  removeScriptMessageHandler
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeScriptMessageHandlerForControllerWithIdentifier
  
  :aValue
  
  
  error:&error];
  OCMVerify([mockWebView removeScriptMessageHandler:
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testRemoveAllScriptMessageHandlers {
  FWFWebView *mockUserContentController = OCMClassMock([
  
  
  removeAllScriptMessageHandlers
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllScriptMessageHandlersForControllerWithIdentifier
  
  
  error:&error];
  OCMVerify([mockWebView removeAllScriptMessageHandlers:
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testAddUserScript {
  FWFWebView *mockUserContentController = OCMClassMock([
  
  
  addUserScript
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi addUserScriptForControllerWithIdentifier
  
  :aValue
  
  
  error:&error];
  OCMVerify([mockWebView addUserScript:
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testRemoveAllUserScripts {
  FWFWebView *mockUserContentController = OCMClassMock([
  
  
  removeAllUserScripts
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllUserScriptsForControllerWithIdentifier
  
  
  error:&error];
  OCMVerify([mockWebView removeAllUserScripts:
  
  
  ]);
  XCTAssertNil(error);
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFWebViewConfigurationHostApiTests : XCTestCase
@end

@implementation FWFWebViewConfigurationHostApiTests

- (void)testSetAllowsInlineMediaPlayback {
  FWFWebView *mockWebViewConfiguration = OCMClassMock([
  
  
  setAllowsInlineMediaPlayback
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setAllowsInlineMediaPlaybackForConfigurationWithIdentifier
  
  :aValue
  
  
  error:&error];
  OCMVerify([mockWebView setAllowsInlineMediaPlayback:
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testSetMediaTypesRequiringUserActionForPlayback {
  FWFWebView *mockWebViewConfiguration = OCMClassMock([
  
  
  setMediaTypesRequiringUserActionForPlayback
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setMediaTypesRequiresUserActionForConfigurationWithIdentifier
  
  :aValue
  
  
  error:&error];
  OCMVerify([mockWebView setMediaTypesRequiringUserActionForPlayback:
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFUIDelegateHostApiTests : XCTestCase
@end

@implementation FWFUIDelegateHostApiTests

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFNavigationDelegateHostApiTests : XCTestCase
@end

@implementation FWFNavigationDelegateHostApiTests

@end
