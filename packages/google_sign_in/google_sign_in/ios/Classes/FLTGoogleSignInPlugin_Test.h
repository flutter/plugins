// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import google_sign_in.Test;"

#import <google_sign_in/FLTGoogleSignInPlugin.h>

@class GIDSignIn;

/// Methods exposed for unit testing.
@interface FLTGoogleSignInPlugin ()

/// Inject @c GIDSignIn for testing.
- (instancetype)initWithSignIn:(GIDSignIn *)signIn NS_DESIGNATED_INITIALIZER;

@end
