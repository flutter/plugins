// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseAuthPlugin.h"

#import "Firebase/Firebase.h"

static NSString *getFlutterErrorCode(NSError *error) {
  NSString *code = [error userInfo][FIRAuthErrorNameKey];
  if (code != nil) {
    return code;
  }
  return [NSString stringWithFormat:@"ERROR_%d", (int)error.code];
}

NSDictionary *toDictionary(id<FIRUserInfo> userInfo) {
  return @{
    @"providerId" : userInfo.providerID,
    @"displayName" : userInfo.displayName ?: [NSNull null],
    @"uid" : userInfo.uid ?: [NSNull null],
    @"photoUrl" : userInfo.photoURL.absoluteString ?: [NSNull null],
    @"email" : userInfo.email ?: [NSNull null],
    @"phoneNumber" : userInfo.phoneNumber ?: [NSNull null],
  };
}

@interface FLTFirebaseAuthPlugin ()
@property(nonatomic, retain) NSMutableDictionary *authStateChangeListeners;
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTFirebaseAuthPlugin

// Handles are ints used as indexes into the NSMutableDictionary of active observers
int nextHandle = 0;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_auth"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAuthPlugin *instance = [[FLTFirebaseAuthPlugin alloc] init];
  instance.channel = channel;
  instance.authStateChangeListeners = [[NSMutableDictionary alloc] init];
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

- (FIRAuth *_Nullable)getAuth:(NSDictionary *)args {
  NSString *appName = [args objectForKey:@"app"];
  return [FIRAuth authWithApp:[FIRApp appNamed:appName]];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"currentUser" isEqualToString:call.method]) {
    id __block listener = [[self getAuth:call.arguments]
        addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
          [self sendResult:result forUser:user error:nil];
          [auth removeAuthStateDidChangeListener:listener];
        }];
  } else if ([@"signInAnonymously" isEqualToString:call.method]) {
    [[self getAuth:call.arguments]
        signInAnonymouslyWithCompletion:^(FIRAuthDataResult *authResult, NSError *error) {
          [self sendResult:result forUser:authResult.user error:error];
        }];
  } else if ([@"signInWithCredential" isEqualToString:call.method]) {
    [[self getAuth:call.arguments]
        signInAndRetrieveDataWithCredential:[self getCredential:call.arguments]
                                 completion:^(FIRAuthDataResult *authResult, NSError *error) {
                                   [self sendResult:result forUser:authResult.user error:error];
                                 }];
  } else if ([@"createUserWithEmailAndPassword" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    NSString *password = call.arguments[@"password"];
    [[self getAuth:call.arguments]
        createUserWithEmail:email
                   password:password
                 completion:^(FIRAuthDataResult *authResult, NSError *error) {
                   [self sendResult:result forUser:authResult.user error:error];
                 }];
  } else if ([@"fetchSignInMethodsForEmail" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    [[self getAuth:call.arguments]
        fetchProvidersForEmail:email
                    completion:^(NSArray<NSString *> *providers, NSError *error) {
                      [self sendResult:result forObject:providers error:error];
                    }];
  } else if ([@"sendEmailVerification" isEqualToString:call.method]) {
    [[self getAuth:call.arguments].currentUser
        sendEmailVerificationWithCompletion:^(NSError *_Nullable error) {
          [self sendResult:result forObject:nil error:error];
        }];
  } else if ([@"reload" isEqualToString:call.method]) {
    [[self getAuth:call.arguments].currentUser reloadWithCompletion:^(NSError *_Nullable error) {
      [self sendResult:result forObject:nil error:error];
    }];
  } else if ([@"delete" isEqualToString:call.method]) {
    [[self getAuth:call.arguments].currentUser deleteWithCompletion:^(NSError *_Nullable error) {
      [self sendResult:result forObject:nil error:error];
    }];
  } else if ([@"sendPasswordResetEmail" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    [[self getAuth:call.arguments] sendPasswordResetWithEmail:email
                                                   completion:^(NSError *error) {
                                                     [self sendResult:result
                                                            forObject:nil
                                                                error:error];
                                                   }];
  } else if ([@"signInWithEmailAndPassword" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    NSString *password = call.arguments[@"password"];
    [[self getAuth:call.arguments]
        signInWithEmail:email
               password:password
             completion:^(FIRAuthDataResult *authResult, NSError *error) {
               [self sendResult:result forUser:authResult.user error:error];
             }];
  } else if ([@"signOut" isEqualToString:call.method]) {
    NSError *signOutError;
    BOOL status = [[self getAuth:call.arguments] signOut:&signOutError];
    if (!status) {
      NSLog(@"Error signing out: %@", signOutError);
      [self sendResult:result forObject:nil error:signOutError];
    } else {
      [self sendResult:result forObject:nil error:nil];
    }
  } else if ([@"getIdToken" isEqualToString:call.method]) {
    [[self getAuth:call.arguments].currentUser
        getIDTokenForcingRefresh:YES
                      completion:^(NSString *_Nullable token, NSError *_Nullable error) {
                        [self sendResult:result forObject:token error:error];
                      }];
  } else if ([@"reauthenticateWithCredential" isEqualToString:call.method]) {
    [[self getAuth:call.arguments].currentUser
        reauthenticateWithCredential:[self getCredential:call.arguments]
                          completion:^(NSError *_Nullable error) {
                            [self sendResult:result forObject:nil error:error];
                          }];
  } else if ([@"linkWithCredential" isEqualToString:call.method]) {
    [[self getAuth:call.arguments].currentUser
        linkWithCredential:[self getCredential:call.arguments]
                completion:^(FIRUser *user, NSError *error) {
                  [self sendResult:result forUser:user error:error];
                }];
  } else if ([@"unlinkFromProvider" isEqualToString:call.method]) {
    NSString *provider = call.arguments[@"provider"];
    [[self getAuth:call.arguments].currentUser
        unlinkFromProvider:provider
                completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                  [self sendResult:result forUser:user error:error];
                }];
  } else if ([@"updateEmail" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    [[self getAuth:call.arguments].currentUser updateEmail:email
                                                completion:^(NSError *error) {
                                                  [self sendResult:result
                                                         forObject:nil
                                                             error:error];
                                                }];
  } else if ([@"updatePassword" isEqualToString:call.method]) {
    NSString *password = call.arguments[@"password"];
    [[self getAuth:call.arguments].currentUser updatePassword:password
                                                   completion:^(NSError *error) {
                                                     [self sendResult:result
                                                            forObject:nil
                                                                error:error];
                                                   }];
  } else if ([@"updateProfile" isEqualToString:call.method]) {
    FIRUserProfileChangeRequest *changeRequest =
        [[self getAuth:call.arguments].currentUser profileChangeRequest];
    if (call.arguments[@"displayName"]) {
      changeRequest.displayName = call.arguments[@"displayName"];
    }
    if (call.arguments[@"photoUrl"]) {
      changeRequest.photoURL = [NSURL URLWithString:call.arguments[@"photoUrl"]];
    }
    [changeRequest commitChangesWithCompletion:^(NSError *error) {
      [self sendResult:result forObject:nil error:error];
    }];
  } else if ([@"signInWithCustomToken" isEqualToString:call.method]) {
    NSString *token = call.arguments[@"token"];
    [[self getAuth:call.arguments]
        signInWithCustomToken:token
                   completion:^(FIRAuthDataResult *authResult, NSError *error) {
                     [self sendResult:result forUser:authResult.user error:error];
                   }];

  } else if ([@"startListeningAuthState" isEqualToString:call.method]) {
    NSNumber *identifier = [NSNumber numberWithInteger:nextHandle++];

    FIRAuthStateDidChangeListenerHandle listener = [[self getAuth:call.arguments]
        addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
          NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
          response[@"id"] = identifier;
          if (user) {
            response[@"user"] = [self dictionaryFromUser:user];
          }
          [self.channel invokeMethod:@"onAuthStateChanged" arguments:response];
        }];
    [self.authStateChangeListeners setObject:listener forKey:identifier];
    result(identifier);
  } else if ([@"stopListeningAuthState" isEqualToString:call.method]) {
    NSNumber *identifier =
        [NSNumber numberWithInteger:[call.arguments[@"id"] unsignedIntegerValue]];

    FIRAuthStateDidChangeListenerHandle listener = self.authStateChangeListeners[identifier];
    if (listener) {
      [[self getAuth:call.arguments]
          removeAuthStateDidChangeListener:self.authStateChangeListeners];
      [self.authStateChangeListeners removeObjectForKey:identifier];
      result(nil);
    } else {
      result([FlutterError
          errorWithCode:@"ERROR_LISTENER_NOT_FOUND"
                message:[NSString stringWithFormat:@"Listener with identifier '%d' not found.",
                                                   identifier.intValue]
                details:nil]);
    }
  } else if ([@"verifyPhoneNumber" isEqualToString:call.method]) {
    NSString *phoneNumber = call.arguments[@"phoneNumber"];
    NSNumber *handle = call.arguments[@"handle"];
    [[FIRPhoneAuthProvider provider]
        verifyPhoneNumber:phoneNumber
               UIDelegate:nil
               completion:^(NSString *verificationID, NSError *error) {
                 if (error) {
                   [self.channel invokeMethod:@"phoneVerificationFailed"
                                    arguments:@{
                                      @"exception" : [self mapVerifyPhoneError:error],
                                      @"handle" : handle
                                    }];
                 } else {
                   [self.channel
                       invokeMethod:@"phoneCodeSent"
                          arguments:@{@"verificationId" : verificationID, @"handle" : handle}];
                 }
               }];
    result(nil);
  } else if ([@"signInWithPhoneNumber" isEqualToString:call.method]) {
    NSString *verificationId = call.arguments[@"verificationId"];
    NSString *smsCode = call.arguments[@"smsCode"];

    FIRPhoneAuthCredential *credential =
        [[FIRPhoneAuthProvider provider] credentialWithVerificationID:verificationId
                                                     verificationCode:smsCode];
    [[self getAuth:call.arguments]
        signInWithCredential:credential
                  completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                    [self sendResult:result forUser:user error:error];
                  }];
  } else if ([@"setLanguageCode" isEqualToString:call.method]) {
    NSString *language = call.arguments[@"language"];
    [[self getAuth:call.arguments] setLanguageCode:language];
    [self sendResult:result forObject:nil error:nil];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSMutableDictionary *)dictionaryFromUser:(FIRUser *)user {
  NSMutableArray<NSDictionary<NSString *, NSString *> *> *providerData =
      [NSMutableArray arrayWithCapacity:user.providerData.count];
  for (id<FIRUserInfo> userInfo in user.providerData) {
    [providerData addObject:toDictionary(userInfo)];
  }

  long creationDate = [user.metadata.creationDate timeIntervalSince1970];
  long lastSignInDate = [user.metadata.lastSignInDate timeIntervalSince1970];

  NSMutableDictionary *userData = [toDictionary(user) mutableCopy];
  userData[@"creationTimestamp"] = [NSNumber numberWithLong:creationDate];
  userData[@"lastSignInTimestamp"] = [NSNumber numberWithInt:lastSignInDate];
  userData[@"isAnonymous"] = [NSNumber numberWithBool:user.isAnonymous];
  userData[@"isEmailVerified"] = [NSNumber numberWithBool:user.isEmailVerified];
  userData[@"providerData"] = providerData;
  return userData;
}

- (void)sendResult:(FlutterResult)result forUser:(FIRUser *)user error:(NSError *)error {
  [self sendResult:result
         forObject:(user != nil ? [self dictionaryFromUser:user] : nil)
             error:error];
}

- (void)sendResult:(FlutterResult)result forObject:(NSObject *)object error:(NSError *)error {
  if (error != nil) {
    result([FlutterError errorWithCode:getFlutterErrorCode(error)
                               message:error.localizedDescription
                               details:nil]);
  } else if (object == nil) {
    result(nil);
  } else {
    result(object);
  }
}

- (id)mapVerifyPhoneError:(NSError *)error {
  NSString *errorCode = @"verifyPhoneNumberError";

  if (error.code == FIRAuthErrorCodeCaptchaCheckFailed) {
    errorCode = @"captchaCheckFailed";
  } else if (error.code == FIRAuthErrorCodeQuotaExceeded) {
    errorCode = @"quotaExceeded";
  } else if (error.code == FIRAuthErrorCodeInvalidPhoneNumber) {
    errorCode = @"invalidPhoneNumber";
  } else if (error.code == FIRAuthErrorCodeMissingPhoneNumber) {
    errorCode = @"missingPhoneNumber";
  }
  return @{@"code" : errorCode, @"message" : error.localizedDescription};
}

- (FIRAuthCredential *)getCredential:(NSDictionary *)arguments {
  NSString *provider = arguments[@"provider"];
  NSDictionary *data = arguments[@"data"];
  FIRAuthCredential *credential;
  if ([FIREmailAuthProviderID isEqualToString:provider]) {
    NSString *email = data[@"email"];
    NSString *password = data[@"password"];
    credential = [FIREmailAuthProvider credentialWithEmail:email password:password];
  } else if ([FIRGoogleAuthProviderID isEqualToString:provider]) {
    NSString *idToken = data[@"idToken"];
    NSString *accessToken = data[@"accessToken"];
    credential = [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:accessToken];
  } else if ([FIRFacebookAuthProviderID isEqualToString:provider]) {
    NSString *accessToken = data[@"accessToken"];
    credential = [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
  } else if ([FIRTwitterAuthProviderID isEqualToString:provider]) {
    NSString *authToken = data[@"authToken"];
    NSString *authTokenSecret = data[@"authTokenSecret"];
    credential = [FIRTwitterAuthProvider credentialWithToken:authToken secret:authTokenSecret];
  } else if ([FIRGitHubAuthProviderID isEqualToString:provider]) {
    NSString *token = data[@"token"];
    credential = [FIRGitHubAuthProvider credentialWithToken:token];
  } else if ([FIRPhoneAuthProviderID isEqualToString:provider]) {
    NSString *verificationId = data[@"verificationId"];
    NSString *smsCode = data[@"smsCode"];
    credential = [[FIRPhoneAuthProvider providerWithAuth:[self getAuth:arguments]]
        credentialWithVerificationID:verificationId
                    verificationCode:smsCode];
  } else {
    NSLog(@"Support for an auth provider with identifier '%@' is not implemented.", provider);
  }
  return credential;
}
@end
