
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFPreferencesHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFPreferencesHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFPreferencesHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    WKPreferences

        *)preferencesForIdentifier:(NSNumber *)instanceId {
  return (

      WKPreferences

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKPreferences

      *preferences =

          [[WKPreferences alloc] init];

  [self.instanceManager addInstance:preferences withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.preferences withIdentifier:instanceId.longValue];
}

- (void)setJavaScriptEnabledForPreferencesWithIdentifier:(nonnull NSNumber *)instanceId

                                                 enabled:(nonnull NSNumber *)enabled

                                                   error:(FlutterError *_Nullable *_Nonnull)error {
  [[self preferencesForIdentifier:instanceId] setJavaScriptEnabled

:enabled

  ];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"
#import "FWFWebsiteDataStoreHostApi.h"

@interface FWFWebsiteDataStoreHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebsiteDataStoreHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    WKWebsiteDataStore

        *)websiteDataStoreForIdentifier:(NSNumber *)instanceId {
  return (

      WKWebsiteDataStore

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebsiteDataStore

      *websiteDataStore =

          [[WKWebsiteDataStore alloc] init];

  [self.instanceManager addInstance:websiteDataStore withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.websiteDataStore
                     withIdentifier:instanceId.longValue];
}

- (void)removeDataFromDataStoreWithIdentifier:(nonnull NSNumber *)instanceId

                                    dataTypes:
                                        (nonnull NSArray<FWFWKWebsiteDataTypeEnumData *> *)dataTypes

                                        since:(nonnull NSNumber *)since

                                        error:(FlutterError *_Nullable *_Nonnull)error {
  return [[self websiteDataStoreForIdentifier:instanceId] removeDataOfTypes

                                                                           :dataTypes

                                                                      since:since

  ];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFHttpCookieStoreHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFHttpCookieStoreHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFHttpCookieStoreHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    WKHttpCookieStore

        *)httpCookieStoreForIdentifier:(NSNumber *)instanceId {
  return (

      WKHttpCookieStore

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKHttpCookieStore

      *httpCookieStore =

          [[WKHttpCookieStore alloc] init];

  [self.instanceManager addInstance:httpCookieStore withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.httpCookieStore
                     withIdentifier:instanceId.longValue];
}

- (void)setCookieForStoreWithIdentifier:(nonnull NSNumber *)instanceId

                                 cookie:(nonnull NSHttpCookie *)cookie

                                  error:(FlutterError *_Nullable *_Nonnull)error {
  [[self httpCookieStoreForIdentifier:instanceId] setCookie

:cookie

  ];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFScriptMessageHandlerHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFScriptMessageHandlerHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFScriptMessageHandlerHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    WKScriptMessageHandler

        *)scriptMessageHandlerForIdentifier:(NSNumber *)instanceId {
  return (

      WKScriptMessageHandler

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKScriptMessageHandler

      *scriptMessageHandler =

          [[WKScriptMessageHandler alloc] init];

  [self.instanceManager addInstance:scriptMessageHandler withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.scriptMessageHandler
                     withIdentifier:instanceId.longValue];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFUserContentControllerHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFUserContentControllerHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFUserContentControllerHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    WKUserContentController

        *)userContentControllerForIdentifier:(NSNumber *)instanceId {
  return (

      WKUserContentController

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKUserContentController

      *userContentController =

          [[WKUserContentController alloc] init];

  [self.instanceManager addInstance:userContentController withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.userContentController
                     withIdentifier:instanceId.longValue];
}

- (void)addScriptMessageHandlerForControllerWithIdentifier:(nonnull NSNumber *)instanceId

                                                   handler:(nonnull WKScriptMessageHandler *)handler

                                                      name:(nonnull NSString *)name

                                                     error:
                                                         (FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:instanceId] addScriptMessageHandler

                                                                               :handler

                                                                           name:name

  ];
}

- (void)removeScriptMessageHandlerForControllerWithIdentifier:(nonnull NSNumber *)instanceId

                                                         name:(nonnull NSString *)name

                                                        error:(FlutterError *_Nullable *_Nonnull)
                                                                  error {
  [[self userContentControllerForIdentifier:instanceId] removeScriptMessageHandler

:name

  ];
}

- (void)removeAllScriptMessageHandlersForControllerWithIdentifier:(nonnull NSNumber *)instanceId

                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  [[self userContentControllerForIdentifier:instanceId] removeAllScriptMessageHandlers

  ];
}

- (void)addUserScriptForControllerWithIdentifier:(nonnull NSNumber *)instanceId

                                      userScript:(nonnull WKUserScript *)userScript

                                           error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:instanceId] addUserScript

:userScript

  ];
}

- (void)removeAllUserScriptsForControllerWithIdentifier:(nonnull NSNumber *)instanceId

                                                  error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:instanceId] removeAllUserScripts

  ];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFWebViewConfigurationHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewConfigurationHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    WKWebViewConfiguration

        *)webViewConfigurationForIdentifier:(NSNumber *)instanceId {
  return (

      WKWebViewConfiguration

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration

      *webViewConfiguration =

          [[WKWebViewConfiguration alloc] init];

  [self.instanceManager addInstance:webViewConfiguration withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.webViewConfiguration
                     withIdentifier:instanceId.longValue];
}

- (void)setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:(nonnull NSNumber *)instanceId

                                                             allow:(nonnull NSNumber *)allow

                                                             error:
                                                                 (FlutterError *_Nullable *_Nonnull)
                                                                     error {
  [[self webViewConfigurationForIdentifier:instanceId] setAllowsInlineMediaPlayback

:allow

  ];
}

- (void)
    setMediaTypesRequiresUserActionForConfigurationWithIdentifier:(nonnull NSNumber *)instanceId

                                                            types:
                                                                (nonnull NSArray<
                                                                    FWFWKAudiovisualMediaTypeEnumData
                                                                        *> *)types

                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  [[self webViewConfigurationForIdentifier:instanceId] setMediaTypesRequiringUserActionForPlayback

:types

  ];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFUIDelegateHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@implementation FWFUIDelegate
@end

@interface FWFUIDelegateHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFUIDelegateHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFUIDelegate

       *)uIDelegateForIdentifier:(NSNumber *)instanceId {
  return (

      FWFUIDelegate

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  FWFUIDelegate

      *uIDelegate =

          [[FWFUIDelegate alloc] init];

  [self.instanceManager addInstance:uIDelegate withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.uIDelegate withIdentifier:instanceId.longValue];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFNavigationDelegateHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@implementation FWFNavigationDelegate
@end

@interface FWFNavigationDelegateHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFNavigationDelegate

       *)navigationDelegateForIdentifier:(NSNumber *)instanceId {
  return (

      FWFNavigationDelegate

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  FWFNavigationDelegate

      *navigationDelegate =

          [[FWFNavigationDelegate alloc] init];

  [self.instanceManager addInstance:navigationDelegate withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.navigationDelegate
                     withIdentifier:instanceId.longValue];
}

@end
