
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * Host api implementation for WKPreferences.
 *
 * Handles creating WKPreferences that intercommunicate with a paired Dart object.
 */
@interface FWFPreferencesHostApiImpl : NSObject <FWFWKPreferencesHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * Host api implementation for WKWebsiteDataStore.
 *
 * Handles creating WKWebsiteDataStore that intercommunicate with a paired Dart object.
 */
@interface FWFWebsiteDataStoreHostApiImpl : NSObject <FWFWKWebsiteDataStoreHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * Host api implementation for WKHttpCookieStore.
 *
 * Handles creating WKHttpCookieStore that intercommunicate with a paired Dart object.
 */
@interface FWFHttpCookieStoreHostApiImpl : NSObject <FWFWKHttpCookieStoreHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * Host api implementation for WKScriptMessageHandler.
 *
 * Handles creating WKScriptMessageHandler that intercommunicate with a paired Dart object.
 */
@interface FWFScriptMessageHandlerHostApiImpl : NSObject <FWFWKScriptMessageHandlerHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * Host api implementation for WKUserContentController.
 *
 * Handles creating WKUserContentController that intercommunicate with a paired Dart object.
 */
@interface FWFUserContentControllerHostApiImpl : NSObject <FWFWKUserContentControllerHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * Host api implementation for WKWebViewConfiguration.
 *
 * Handles creating WKWebViewConfiguration that intercommunicate with a paired Dart object.
 */
@interface FWFWebViewConfigurationHostApiImpl : NSObject <FWFWKWebViewConfigurationHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * Implementation of WKUIDelegate for FWFUIDelegateHostApiImpl.
 */
@interface FWFUIDelegate : NSObject<WKUIDelegate>
@end


/**
 * Host api implementation for WKUIDelegate.
 *
 * Handles creating WKUIDelegate that intercommunicate with a paired Dart object.
 */
@interface FWFUIDelegateHostApiImpl : NSObject <FWFWKUIDelegateHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * Implementation of WKNavigationDelegate for FWFNavigationDelegateHostApiImpl.
 */
@interface FWFNavigationDelegate : NSObject<WKNavigationDelegate>
@end


/**
 * Host api implementation for WKNavigationDelegate.
 *
 * Handles creating WKNavigationDelegate that intercommunicate with a paired Dart object.
 */
@interface FWFNavigationDelegateHostApiImpl : NSObject <FWFWKNavigationDelegateHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
