// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Implementation of WKScriptMessageHandler for FWFScriptMessageHandlerHostApiImpl.
 */
@interface FWFScriptMessageHandler : NSObject <WKScriptMessageHandler>
@end

/**
 * Host api implementation for WKScriptMessageHandler.
 *
 * Handles creating WKScriptMessageHandler that intercommunicate with a paired Dart object.
 */
@interface FWFScriptMessageHandlerHostApiImpl : NSObject <FWFWKScriptMessageHandlerHostApi>
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
