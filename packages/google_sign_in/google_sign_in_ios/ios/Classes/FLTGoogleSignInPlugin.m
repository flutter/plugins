// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleSignInPlugin.h"
#import "FLTGoogleSignInPlugin_Test.h"

#import <GoogleSignIn/GoogleSignIn.h>

// The key within `GoogleService-Info.plist` used to hold the application's
// client id.  See https://developers.google.com/identity/sign-in/ios/start
// for more info.
static NSString *const kClientIdKey = @"CLIENT_ID";

static NSString *const kServerClientIdKey = @"SERVER_CLIENT_ID";

// These error codes must match with ones declared on Android and Dart sides.
static NSString *const kErrorReasonSignInRequired = @"sign_in_required";
static NSString *const kErrorReasonSignInCanceled = @"sign_in_canceled";
static NSString *const kErrorReasonNetworkError = @"network_error";
static NSString *const kErrorReasonSignInFailed = @"sign_in_failed";

static FlutterError *getFlutterError(NSError *error) {
  NSString *errorCode;
  if (error.code == kGIDSignInErrorCodeHasNoAuthInKeychain) {
    errorCode = kErrorReasonSignInRequired;
  } else if (error.code == kGIDSignInErrorCodeCanceled) {
    errorCode = kErrorReasonSignInCanceled;
  } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
    errorCode = kErrorReasonNetworkError;
  } else {
    errorCode = kErrorReasonSignInFailed;
  }
  return [FlutterError errorWithCode:errorCode
                             message:error.domain
                             details:error.localizedDescription];
}

@interface FLTGoogleSignInPlugin () <GIDSignInDelegate>
@property(strong, readonly) GIDSignIn *signIn;

// Redeclared as not a designated initializer.
- (instancetype)init;
@end

@implementation FLTGoogleSignInPlugin {
  FlutterResult _accountRequest;
  NSArray<NSString *> *_additionalScopesRequest;
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
  return [self initWithSignIn:GIDSignIn.sharedInstance];
}

- (instancetype)initWithSignIn:(GIDSignIn *)signIn {
  self = [super init];
  if (self) {
    _signIn = signIn;
    _signIn.delegate = self;

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
        NSMutableDictionary<NSString *, NSString *> *plist =
            [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        BOOL hasDynamicClientId = [call.arguments[@"clientId"] isKindOfClass:[NSString class]];

        if (hasDynamicClientId) {
          self.signIn.clientID = call.arguments[@"clientId"];
        } else {
          self.signIn.clientID = plist[kClientIdKey];
        }

        self.signIn.serverClientID = plist[kServerClientIdKey];
        self.signIn.scopes = call.arguments[@"scopes"];
        if (call.arguments[@"hostedDomain"] == [NSNull null]) {
          self.signIn.hostedDomain = nil;
        } else {
          self.signIn.hostedDomain = call.arguments[@"hostedDomain"];
        }
        result(nil);
      } else {
        result([FlutterError errorWithCode:@"missing-config"
                                   message:@"GoogleService-Info.plist file not found"
                                   details:nil]);
      }
    }
  } else if ([call.method isEqualToString:@"signInSilently"]) {
    if ([self setAccountRequest:result]) {
      [self.signIn restorePreviousSignIn];
    }
  } else if ([call.method isEqualToString:@"isSignedIn"]) {
    result(@([self.signIn hasPreviousSignIn]));
  } else if ([call.method isEqualToString:@"signIn"]) {
    self.signIn.presentingViewController = [self topViewController];

    if ([self setAccountRequest:result]) {
      @try {
        [self.signIn signIn];
      } @catch (NSException *e) {
        result([FlutterError errorWithCode:@"google_sign_in" message:e.reason details:e.name]);
        [e raise];
      }
    }
  } else if ([call.method isEqualToString:@"getTokens"]) {
    GIDGoogleUser *currentUser = self.signIn.currentUser;
    GIDAuthentication *auth = currentUser.authentication;
    [auth getTokensWithHandler:^void(GIDAuthentication *authentication, NSError *error) {
      result(error != nil ? getFlutterError(error) : @{
        @"idToken" : authentication.idToken,
        @"accessToken" : authentication.accessToken,
      });
    }];
  } else if ([call.method isEqualToString:@"signOut"]) {
    [self.signIn signOut];
    result(nil);
  } else if ([call.method isEqualToString:@"disconnect"]) {
    if ([self setAccountRequest:result]) {
      [self.signIn disconnect];
    }
  } else if ([call.method isEqualToString:@"clearAuthCache"]) {
    // There's nothing to be done here on iOS since the expired/invalid
    // tokens are refreshed automatically by getTokensWithHandler.
    result(nil);
  } else if ([call.method isEqualToString:@"requestScopes"]) {
    GIDGoogleUser *user = self.signIn.currentUser;
    if (user == nil) {
      result([FlutterError errorWithCode:@"sign_in_required"
                                 message:@"No account to grant scopes."
                                 details:nil]);
      return;
    }

    NSArray<NSString *> *currentScopes = self.signIn.scopes;
    NSArray<NSString *> *scopes = call.arguments[@"scopes"];
    NSArray<NSString *> *missingScopes = [scopes
        filteredArrayUsingPredicate:[NSPredicate
                                        predicateWithBlock:^BOOL(id scope, NSDictionary *bindings) {
                                          return ![user.grantedScopes containsObject:scope];
                                        }]];

    if (!missingScopes || !missingScopes.count) {
      result(@(YES));
      return;
    }

    if ([self setAccountRequest:result]) {
      _additionalScopesRequest = missingScopes;
      self.signIn.scopes = [currentScopes arrayByAddingObjectsFromArray:missingScopes];
      self.signIn.presentingViewController = [self topViewController];
      self.signIn.loginHint = user.profile.email;
      @try {
        [self.signIn signIn];
      } @catch (NSException *e) {
        result([FlutterError errorWithCode:@"request_scopes" message:e.reason details:e.name]);
      }
    }
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

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  return [self.signIn handleURL:url];
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
    if (_additionalScopesRequest) {
      bool granted = YES;
      for (NSString *scope in _additionalScopesRequest) {
        if (![user.grantedScopes containsObject:scope]) {
          granted = NO;
          break;
        }
      }
      _accountRequest(@(granted));
      _accountRequest = nil;
      _additionalScopesRequest = nil;
      return;
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
        @"serverAuthCode" : user.serverAuthCode ?: [NSNull null]
      }
                         error:nil];
    }
  }
}

- (void)signIn:(GIDSignIn *)signIn
    didDisconnectWithUser:(GIDGoogleUser *)user
                withError:(NSError *)error {
  [self respondWithAccount:@{} error:nil];
}

#pragma mark - private methods

- (void)respondWithAccount:(NSDictionary<NSString *, id> *)account error:(NSError *)error {
  FlutterResult result = _accountRequest;
  _accountRequest = nil;
  result(error != nil ? getFlutterError(error) : account);
}

- (UIViewController *)topViewController {
  return [self topViewControllerFromViewController:[UIApplication sharedApplication]
                                                       .keyWindow.rootViewController];
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    return [self
        topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
  }
  if ([viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController = (UITabBarController *)viewController;
    return [self topViewControllerFromViewController:tabController.selectedViewController];
  }
  if (viewController.presentedViewController) {
    return [self topViewControllerFromViewController:viewController.presentedViewController];
  }
  return viewController;
}
@end
