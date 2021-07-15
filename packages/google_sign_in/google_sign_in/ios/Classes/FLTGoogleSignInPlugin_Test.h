// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <google_sign_in/FLTGoogleSignInPlugin.h>

@class GIDSignIn;

@interface FLTGoogleSignInPlugin ()

- (instancetype)initWithSignIn:(GIDSignIn *)signIn NS_DESIGNATED_INITIALIZER;

@end
