// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseAuthPlugin.h"

#import "Firebase/Firebase.h"

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

NSDictionary *toDictionary(id<FIRUserInfo> userInfo) {
  return @{
    @"providerId" : userInfo.providerID,
    @"displayName" : userInfo.displayName ?: [NSNull null],
    @"uid" : userInfo.uid,
    @"photoUrl" : userInfo.photoURL.absoluteString ?: [NSNull null],
    @"email" : userInfo.email ?: [NSNull null],
  };
}

@implementation FirebaseAuthPlugin {
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_auth"
                                  binaryMessenger:[registrar messenger]];
  FirebaseAuthPlugin *instance = [[FirebaseAuthPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"currentUser" isEqualToString:call.method]) {
    id __block listener = [[FIRAuth auth]
        addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
          [self sendResult:result forUser:user error:nil];
          [auth removeAuthStateDidChangeListener:listener];
        }];
  } else if ([@"signInAnonymously" isEqualToString:call.method]) {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *user, NSError *error) {
      [self sendResult:result forUser:user error:error];
    }];
  } else if ([@"signInWithGoogle" isEqualToString:call.method]) {
    NSString *idToken = call.arguments[@"idToken"];
    NSString *accessToken = call.arguments[@"accessToken"];
    FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:accessToken];
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                [self sendResult:result forUser:user error:error];
                              }];
  } else if ([@"signInWithFacebook" isEqualToString:call.method]) {
    NSString *accessToken = call.arguments[@"accessToken"];
    FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                [self sendResult:result forUser:user error:error];
                              }];
  } else if ([@"createUserWithEmailAndPassword" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    NSString *password = call.arguments[@"password"];
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser *user, NSError *error) {
                               [self sendResult:result forUser:user error:error];
                             }];
  } else if ([@"signInWithEmailAndPassword" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    NSString *password = call.arguments[@"password"];
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser *user, NSError *error) {
                           [self sendResult:result forUser:user error:error];
                         }];
  } else if ([@"signOut" isEqualToString:call.method]) {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
      NSLog(@"Error signing out: %@", signOutError);
      [self sendResult:result forUser:nil error:signOutError];
    } else {
      [self sendResult:result forUser:nil error:nil];
    }
  } else if ([@"getToken" isEqualToString:call.method]) {
    [[FIRAuth auth].currentUser
        getTokenForcingRefresh:YES
                    completion:^(NSString *_Nullable token, NSError *_Nullable error) {
                      result(error != nil ? error.flutterError : token);
                    }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)sendResult:(FlutterResult)result forUser:(FIRUser *)user error:(NSError *)error {
  if (error != nil) {
    result(error.flutterError);
  } else if (user == nil) {
    result(nil);
  } else {
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *providerData =
        [NSMutableArray arrayWithCapacity:user.providerData.count];
    for (id<FIRUserInfo> userInfo in user.providerData) {
      [providerData addObject:toDictionary(userInfo)];
    }
    NSMutableDictionary *userData = [toDictionary(user) mutableCopy];
    userData[@"isAnonymous"] = [NSNumber numberWithBool:user.isAnonymous];
    userData[@"isEmailVerified"] = [NSNumber numberWithBool:user.isEmailVerified];
    userData[@"providerData"] = providerData;
    result(userData);
  }
}

@end
