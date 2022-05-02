
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
  
    
    WKPreferences
     *mockPreferences = OCMClassMock([
  
  
  WKPreferences
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockPreferences withIdentifier:0];

  FWFPreferencesHostApiImpl *hostApi =
      [[FWFPreferencesHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setJavaScriptEnabledForPreferencesWithIdentifier:@0
  
  enabled:aValue
  
  error:&error];
  OCMVerify([mockPreferences setJavaScriptEnabled
  
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
  
    
    WKWebsiteDataStore
     *mockWebsiteDataStore = OCMClassMock([
  
  
  WKWebsiteDataStore
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebsiteDataStore withIdentifier:0];

  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeDataFromDataStoreWithIdentifier:@0
  
  dataTypes:aValue
  
  since:aValue
  
  error:&error];
  OCMVerify([mockWebsiteDataStore removeDataOfTypes
  
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
  
    
    WKHttpCookieStore
     *mockHttpCookieStore = OCMClassMock([
  
  
  WKHttpCookieStore
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockHttpCookieStore withIdentifier:0];

  FWFHttpCookieStoreHostApiImpl *hostApi =
      [[FWFHttpCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setCookieForStoreWithIdentifier:@0
  
  cookie:aValue
  
  error:&error];
  OCMVerify([mockHttpCookieStore setCookie
  
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
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi addScriptMessageHandlerForControllerWithIdentifier:@0
  
  handler:aValue
  
  name:aValue
  
  error:&error];
  OCMVerify([mockUserContentController addScriptMessageHandler
  
  :aValue
  
  
  name:aValue
  
  ]);
  XCTAssertNil(error);
}

- (void)testRemoveScriptMessageHandler {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeScriptMessageHandlerForControllerWithIdentifier:@0
  
  name:aValue
  
  error:&error];
  OCMVerify([mockUserContentController removeScriptMessageHandler
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testRemoveAllScriptMessageHandlers {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllScriptMessageHandlersForControllerWithIdentifier:@0
  
  error:&error];
  OCMVerify([mockUserContentController removeAllScriptMessageHandlers
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testAddUserScript {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi addUserScriptForControllerWithIdentifier:@0
  
  userScript:aValue
  
  error:&error];
  OCMVerify([mockUserContentController addUserScript
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testRemoveAllUserScripts {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllUserScriptsForControllerWithIdentifier:@0
  
  error:&error];
  OCMVerify([mockUserContentController removeAllUserScripts
  
  
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
  
    
    WKWebViewConfiguration
     *mockWebViewConfiguration = OCMClassMock([
  
  
  WKWebViewConfiguration
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:@0
  
  allow:aValue
  
  error:&error];
  OCMVerify([mockWebViewConfiguration setAllowsInlineMediaPlayback
  
  :aValue
  
  
  ]);
  XCTAssertNil(error);
}

- (void)testSetMediaTypesRequiringUserActionForPlayback {
  
    
    WKWebViewConfiguration
     *mockWebViewConfiguration = OCMClassMock([
  
  
  WKWebViewConfiguration
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setMediaTypesRequiresUserActionForConfigurationWithIdentifier:@0
  
  types:aValue
  
  error:&error];
  OCMVerify([mockWebViewConfiguration setMediaTypesRequiringUserActionForPlayback
  
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
