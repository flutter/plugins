
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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFPreferencesHostApiImpl *hostApi =
      [[FWFPreferencesHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      WKPreferences 
  *preferences = (
  
        
        WKPreferences 
  *) [instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue([preferences isKindOfClass:[WKPreferences class]]);
  
  XCTAssertNil(error);
}


- (void)test SetJavaScriptEnabled {
  
    
    WKPreferences
     *mockPreferences = OCMClassMock([
  
  
  WKPreferences
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockPreferences withIdentifier:0];

  FWFPreferencesHostApiImpl *hostApi =
      [[FWFPreferencesHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      WKWebsiteDataStore 
  *websiteDataStore = (
  
        
        WKWebsiteDataStore 
  *) [instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue([websiteDataStore isKindOfClass:[WKWebsiteDataStore class]]);
  
  XCTAssertNil(error);
}


- (void)test RemoveDataOfTypes {
  
    
    WKWebsiteDataStore
     *mockWebsiteDataStore = OCMClassMock([
  
  
  WKWebsiteDataStore
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebsiteDataStore withIdentifier:0];

  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFHttpCookieStoreHostApiImpl *hostApi =
      [[FWFHttpCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      WKHttpCookieStore 
  *httpCookieStore = (
  
        
        WKHttpCookieStore 
  *) [instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue([httpCookieStore isKindOfClass:[WKHttpCookieStore class]]);
  
  XCTAssertNil(error);
}


- (void)test SetCookie {
  
    
    WKHttpCookieStore
     *mockHttpCookieStore = OCMClassMock([
  
  
  WKHttpCookieStore
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockHttpCookieStore withIdentifier:0];

  FWFHttpCookieStoreHostApiImpl *hostApi =
      [[FWFHttpCookieStoreHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFScriptMessageHandlerHostApiImpl *hostApi =
      [[FWFScriptMessageHandlerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
    FWFScriptMessageHandler
      
      
  *scriptMessageHandler = (
  
      FWFScriptMessageHandler
        
        
  *) [instanceManager instanceForIdentifier:0];
  
  XCTAssertTrue([scriptMessageHandler conformsToProtocol:@protocol(WKScriptMessageHandler)]);
  
  
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

@interface FWFUserContentControllerHostApiTests : XCTestCase
@end

@implementation FWFUserContentControllerHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      WKUserContentController 
  *userContentController = (
  
        
        WKUserContentController 
  *) [instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue([userContentController isKindOfClass:[WKUserContentController class]]);
  
  XCTAssertNil(error);
}


- (void)test AddScriptMessageHandler {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

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

- (void)test RemoveScriptMessageHandler {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeScriptMessageHandlerForControllerWithIdentifier:@0
                            
                            name:aValue
                               
                               error:&error];
  OCMVerify([mockUserContentController removeScriptMessageHandler

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

- (void)test RemoveAllScriptMessageHandlers {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi removeAllScriptMessageHandlersForControllerWithIdentifier:@0
                            
                               error:&error];
  OCMVerify([mockUserContentController removeAllScriptMessageHandlers

      
  ]);
  XCTAssertNil(error);
}

- (void)test AddUserScript {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi addUserScriptForControllerWithIdentifier:@0
                            
                            userScript:aValue
                               
                               error:&error];
  OCMVerify([mockUserContentController addUserScript

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

- (void)test RemoveAllUserScripts {
  
    
    WKUserContentController
     *mockUserContentController = OCMClassMock([
  
  
  WKUserContentController
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUserContentController withIdentifier:0];

  FWFUserContentControllerHostApiImpl *hostApi =
      [[FWFUserContentControllerHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      WKWebViewConfiguration 
  *webViewConfiguration = (
  
        
        WKWebViewConfiguration 
  *) [instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue([webViewConfiguration isKindOfClass:[WKWebViewConfiguration class]]);
  
  XCTAssertNil(error);
}


- (void)test SetAllowsInlineMediaPlayback {
  
    
    WKWebViewConfiguration
     *mockWebViewConfiguration = OCMClassMock([
  
  
  WKWebViewConfiguration
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:@0
                            
                            allow:aValue
                               
                               error:&error];
  OCMVerify([mockWebViewConfiguration setAllowsInlineMediaPlayback

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

- (void)test SetMediaTypesRequiringUserActionForPlayback {
  
    
    WKWebViewConfiguration
     *mockWebViewConfiguration = OCMClassMock([
  
  
  WKWebViewConfiguration
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

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
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFUIDelegateHostApiImpl *hostApi =
      [[FWFUIDelegateHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
    FWFUIDelegate
      
      
  *uIDelegate = (
  
      FWFUIDelegate
        
        
  *) [instanceManager instanceForIdentifier:0];
  
  XCTAssertTrue([uIDelegate conformsToProtocol:@protocol(WKUIDelegate)]);
  
  
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

@interface FWFNavigationDelegateHostApiTests : XCTestCase
@end

@implementation FWFNavigationDelegateHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFNavigationDelegateHostApiImpl *hostApi =
      [[FWFNavigationDelegateHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
    FWFNavigationDelegate
      
      
  *navigationDelegate = (
  
      FWFNavigationDelegate
        
        
  *) [instanceManager instanceForIdentifier:0];
  
  XCTAssertTrue([navigationDelegate conformsToProtocol:@protocol(WKNavigationDelegate)]);
  
  
  XCTAssertNil(error);
}


@end
