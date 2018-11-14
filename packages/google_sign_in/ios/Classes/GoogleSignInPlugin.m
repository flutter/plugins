// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "GoogleSignInPlugin.h"
#import <GoogleSignIn/GoogleSignIn.h>

// The key within `GoogleService-Info.plist` used to hold the application's
// client id.  See https://developers.google.com/identity/sign-in/ios/start
// for more info.
static NSString *const kClientIdKey = @"CLIENT_ID";

// These error codes must match with ones declared on Android and Dart sides.
static NSString *const kErrorReasonSignInRequired = @"sign_in_required";
static NSString *const kErrorReasonSignInCanceled = @"sign_in_canceled";
static NSString *const kErrorReasonSignInFailed = @"sign_in_failed";

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  NSString *errorCode;
  if (self.code == kGIDSignInErrorCodeHasNoAuthInKeychain) {
    errorCode = kErrorReasonSignInRequired;
  } else if (self.code == kGIDSignInErrorCodeCanceled) {
    errorCode = kErrorReasonSignInCanceled;
  } else {
    errorCode = kErrorReasonSignInFailed;
  }
  return [FlutterError errorWithCode:errorCode
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@interface FLTGoogleSignInPlugin () <GIDSignInDelegate, GIDSignInUIDelegate>
@end

@implementation FLTGoogleSignInPlugin {
  FlutterResult _accountRequest;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/google_sign_in"
                                  binaryMessenger:[registrar messenger]];
  FLTGoogleSignInPlugin *instance = [[FLTGoogleSignInPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;

    // On the iOS simulator, we get "Broken pipe" errors after sign-in for some
    // unknown reason. We can avoid crashing the app by ignoring them.
    signal(SIGPIPE, SIG_IGN);
  }
  return self;
}

#pragma mark - <FlutterPlugin> protocol

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"init"]) {
    NSString *signInOption = call.arguments[@"signInOption"];
    if ([signInOption isEqualToString:@"SignInOption.games"]) {
      result([FlutterError errorWithCode:@"unsupported-options"
                                 message:@"Games sign in is not supported on iOS"
                                 details:nil]);
    } else {
      NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info"
                                                       ofType:@"plist"];
      if (path) {
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        [GIDSignIn sharedInstance].clientID = plist[kClientIdKey];
        [GIDSignIn sharedInstance].scopes = call.arguments[@"scopes"];
        [GIDSignIn sharedInstance].hostedDomain = call.arguments[@"hostedDomain"];
        result(nil);
      } else {
        result([FlutterError errorWithCode:@"missing-config"
                                   message:@"GoogleService-Info.plist file not found"
                                   details:nil]);
      }
    }
  } else if ([call.method isEqualToString:@"signInSilently"]) {
    if ([self setAccountRequest:result]) {
      [[GIDSignIn sharedInstance] signInSilently];
    }
  } else if ([call.method isEqualToString:@"isSignedIn"]) {
    result(@([[GIDSignIn sharedInstance] hasAuthInKeychain]));
  } else if ([call.method isEqualToString:@"signIn"]) {
    if ([self setAccountRequest:result]) {
      [[GIDSignIn sharedInstance] signIn];
    }
  } else if ([call.method isEqualToString:@"getTokens"]) {
    GIDGoogleUser *currentUser = [GIDSignIn sharedInstance].currentUser;
    GIDAuthentication *auth = currentUser.authentication;
    [auth getTokensWithHandler:^void(GIDAuthentication *authentication, NSError *error) {
      result(error != nil ? error.flutterError : @{
        @"idToken" : authentication.idToken,
        @"accessToken" : authentication.accessToken,
      });
    }];
  } else if ([call.method isEqualToString:@"signOut"]) {
    [[GIDSignIn sharedInstance] signOut];
    result(nil);
  } else if ([call.method isEqualToString:@"disconnect"]) {
    if ([self setAccountRequest:result]) {
      [[GIDSignIn sharedInstance] disconnect];
    }
  } else if ([call.method isEqualToString:@"clearAuthCache"]) {
    // There's nothing to be done here on iOS since the expired/invalid
    // tokens are refreshed automatically by getTokensWithHandler.
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)setAccountRequest:(FlutterResult)request {
  if (_accountRequest != nil) {
    request([FlutterError errorWithCode:@"concurrent-requests"
                                message:@"Concurrent requests to account signin"
                                details:nil]);
    return NO;
  }
  _accountRequest = request;
  return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
  NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
  id annotation = options[UIApplicationOpenURLOptionsAnnotationKey];
  return [[GIDSignIn sharedInstance] handleURL:url
                             sourceApplication:sourceApplication
                                    annotation:annotation];
}

#pragma mark - <GIDSignInUIDelegate> protocol

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
  UIViewController *rootViewController =
      [UIApplication sharedApplication].delegate.window.rootViewController;
  [rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
  [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <GIDSignInDelegate> protocol

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  if (error != nil) {
    // Forward all errors and let Dart side decide how to handle.
    [self respondWithAccount:nil error:error];
  } else {
    NSURL *photoUrl;
    if (user.profile.hasImage) {
      // Placeholder that will be replaced by on the Dart side based on screen
      // size
      photoUrl = [user.profile imageURLWithDimension:1337];
    }
    [self respondWithAccount:@{
      @"displayName" : user.profile.name ?: [NSNull null],
      @"email" : user.profile.email ?: [NSNull null],
      @"id" : user.userID ?: [NSNull null],
      @"photoUrl" : [photoUrl absoluteString] ?: [NSNull null],
    }
                       error:nil];
  }
}

- (void)signIn:(GIDSignIn *)signIn
    didDisconnectWithUser:(GIDGoogleUser *)user
                withError:(NSError *)error {
  [self respondWithAccount:@{} error:nil];
}

#pragma mark - private methods

- (void)respondWithAccount:(id)account error:(NSError *)error {
  FlutterResult result = _accountRequest;
  _accountRequest = nil;
  result(error != nil ? error.flutterError : account);
}

@end
