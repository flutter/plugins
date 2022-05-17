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
@interface FWFNavigationDelegate : NSObject <WKNavigationDelegate>
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
