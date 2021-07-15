// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

@import XCTest;
@import google_sign_in;
@import GoogleSignIn;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

@interface FLTGoogleSignInPluginTest : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;
@property(strong, nonatomic) NSObject<FlutterPluginRegistrar> *mockPluginRegistrar;
@property(strong, nonatomic) FLTGoogleSignInPlugin *plugin;
@property(strong, nonatomic) id mockSharedInstance;

@end

@implementation FLTGoogleSignInPluginTest

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.mockPluginRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  id mockSharedInstance = OCMClassMock([GIDSignIn class]);
  OCMStub([mockSharedInstance sharedInstance]).andReturn(mockSharedInstance);
  self.mockSharedInstance = mockSharedInstance;

  OCMStub(self.mockPluginRegistrar.messenger).andReturn(self.mockBinaryMessenger);
  self.plugin = [[FLTGoogleSignInPlugin alloc] init];
  [FLTGoogleSignInPlugin registerWithRegistrar:self.mockPluginRegistrar];
}

- (void)tearDown {
  [self.mockSharedInstance stopMocking];
  [super tearDown];
}

- (void)testUnimplementedMethod {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"bogus"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(id result) {
    XCTAssertEqualObjects(result, FlutterMethodNotImplemented);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSignOut {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"signOut"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(id result) {
    XCTAssertNil(result);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
  OCMVerify([self.mockSharedInstance signOut]);
}

- (void)testDisconnect {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"disconnect"
                                    arguments:nil];

  [self.plugin handleMethodCall:methodCall result:^(id result) {}];
  OCMVerify([self.mockSharedInstance disconnect]);
}

- (void)testClearAuthCache {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"clearAuthCache"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(id result) {
    XCTAssertNil(result);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Init

- (void)testInitGamesSignInUnsupported {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"init"
                                    arguments:@{@"signInOption" : @"SignInOption.games"}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(FlutterError *result) {
    XCTAssertEqualObjects(result.code, @"unsupported-options");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testInitGoogleServiceInfoPlist {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"init"
                                    arguments:@{@"scopes" : @[ @"mockScope1" ], @"hostedDomain" : @"example.com"}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(id result) {
    XCTAssertNil(result);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];

  id mockSharedInstance = self.mockSharedInstance;
  OCMVerify([mockSharedInstance setScopes:@[ @"mockScope1" ]]);
  OCMVerify([mockSharedInstance setHostedDomain:@"example.com"]);

  // Set in example app GoogleService-Info.plist.
  OCMVerify([mockSharedInstance setClientID:@"479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com"]);
  OCMVerify([mockSharedInstance setServerClientID:@"YOUR_SERVER_CLIENT_ID"]);
}

- (void)testInitNullDomain {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"init"
                                    arguments:@{@"hostedDomain" : [NSNull null]}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(id r) {
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
  OCMVerify([self.mockSharedInstance setHostedDomain:nil]);
}

- (void)testInitDynamicClientId {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"init"
                                    arguments:@{@"clientId" : @"mockClientId"}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall result:^(id r) {
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
  OCMVerify([self.mockSharedInstance setClientID:@"mockClientId"]);
}

#pragma mark - Is signed in

- (void)testIsNotSignedIn {
  OCMStub([self.mockSharedInstance hasPreviousSignIn]).andReturn(NO);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"isSignedIn"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(NSNumber *result) {
    XCTAssertFalse(result.boolValue);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testIsSignedIn {
  OCMStub([self.mockSharedInstance hasPreviousSignIn]).andReturn(YES);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"isSignedIn"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(NSNumber *result) {
    XCTAssertTrue(result.boolValue);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Sign in silently

- (void)testSignInSilently {
  OCMExpect([self.mockSharedInstance restorePreviousSignIn]);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"signInSilently"
                                    arguments:nil];

  [self.plugin handleMethodCall:methodCall
                         result:^(id result) {}];
  OCMVerifyAll(self.mockSharedInstance);
}

- (void)testSignInSilentlyFailsConcurrently {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"signInSilently"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];

  OCMExpect([self.mockSharedInstance restorePreviousSignIn]).andDo(^(NSInvocation *invocation) {
    // Simulate calling the same method while the previous one is in flight.
    [self.plugin handleMethodCall:methodCall
                           result:^(FlutterError *result) {
      XCTAssertEqualObjects(result.code, @"concurrent-requests");
      [expectation fulfill];
    }];
  });

  [self.plugin handleMethodCall:methodCall
                         result:^(id result) {}];

  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Sign in

- (void)testSignIn {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"signIn"
                                    arguments:nil];

  [self.plugin handleMethodCall:methodCall
                         result:^(NSNumber *result) {}];

  id mockSharedInstance = self.mockSharedInstance;
  OCMVerify([mockSharedInstance setPresentingViewController:[OCMArg isKindOfClass:[FlutterViewController class]]]);
  OCMVerify([mockSharedInstance signIn]);
}

- (void)testSignInExecption {
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"signIn"
                                    arguments:nil];
  OCMExpect([self.mockSharedInstance signIn]).andThrow([NSException exceptionWithName:@"MockName" reason:@"MockReason" userInfo:nil]);

  __block FlutterError *error;
  XCTAssertThrows(
  [self.plugin handleMethodCall:methodCall
                                           result:^(FlutterError *result) {
    error = result;
                    }]);


  XCTAssertEqualObjects(error.code, @"google_sign_in");
  XCTAssertEqualObjects(error.message, @"MockReason");
  XCTAssertEqualObjects(error.details, @"MockName");
}

#pragma mark - Get tokens

- (void)testGetTokens {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  OCMStub([mockAuthentication idToken]).andReturn(@"mockIdToken");
  OCMStub([mockAuthentication accessToken]).andReturn(@"mockAccessToken");
  [[mockAuthentication stub] getTokensWithHandler:[OCMArg invokeBlockWithArgs:mockAuthentication, [NSNull null], nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"getTokens"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(NSDictionary<NSString *, NSString *> *result) {
    XCTAssertEqualObjects(result[@"idToken"], @"mockIdToken");
    XCTAssertEqualObjects(result[@"accessToken"], @"mockAccessToken");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensNoAuthKeychainError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain code:kGIDSignInErrorCodeHasNoAuthInKeychain userInfo:nil];
  [[mockAuthentication stub] getTokensWithHandler:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"getTokens"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(FlutterError *result) {
    XCTAssertEqualObjects(result.code, @"sign_in_required");
    XCTAssertEqualObjects(result.message, kGIDSignInErrorDomain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensCancelledError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:kGIDSignInErrorDomain code:kGIDSignInErrorCodeCanceled userInfo:nil];
  [[mockAuthentication stub] getTokensWithHandler:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"getTokens"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(FlutterError *result) {
    XCTAssertEqualObjects(result.code, @"sign_in_canceled");
    XCTAssertEqualObjects(result.message, kGIDSignInErrorDomain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensURLError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
  [[mockAuthentication stub] getTokensWithHandler:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"getTokens"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(FlutterError *result) {
    XCTAssertEqualObjects(result.code, @"network_error");
    XCTAssertEqualObjects(result.message, NSURLErrorDomain);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetTokensUnknownError {
  id mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);

  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  NSError *error = [NSError errorWithDomain:@"BogusDomain" code:42 userInfo:nil];
  [[mockAuthentication stub] getTokensWithHandler:[OCMArg invokeBlockWithArgs:[NSNull null], error, nil]];
  OCMStub([mockUser authentication]).andReturn(mockAuthentication);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"getTokens"
                                    arguments:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(FlutterError *result) {
    XCTAssertEqualObjects(result.code, @"sign_in_failed");
    XCTAssertEqualObjects(result.message, @"BogusDomain");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - Request scopes

- (void)testRequestScopesResultErrorIfNotSignedIn {
  OCMStub([self.mockSharedInstance currentUser]).andReturn(nil);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                    arguments:@{@"scopes" : @[ @"mockScope1" ]}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(FlutterError *result) {
    XCTAssertEqualObjects(result.code, @"sign_in_required");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesIfNoMissingScope {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);
  NSArray *requestedScopes = @[ @"mockScope1" ];
  OCMStub(mockUser.grantedScopes).andReturn(requestedScopes);
  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                    arguments:@{@"scopes" : requestedScopes}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(NSNumber *result) {
    XCTAssertTrue(result.boolValue);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesRequestsIfNotGranted {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);
  NSArray *requestedScopes = @[ @"mockScope1" ];
  OCMStub(mockUser.grantedScopes).andReturn(@[]);
  id mockSharedInstance = self.mockSharedInstance;
  OCMStub([mockSharedInstance scopes]).andReturn(@[]);

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                    arguments:@{@"scopes" : requestedScopes}];

  [self.plugin handleMethodCall:methodCall
                         result:^(id r){
  }];

  OCMVerify([mockSharedInstance setScopes:@[ @"mockScope1" ]]);
  OCMVerify([mockSharedInstance signIn]);
}

- (void)testRequestScopesReturnsFalseIfNotGranted {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);
  NSArray *requestedScopes = @[ @"mockScope1" ];
  OCMStub(mockUser.grantedScopes).andReturn(@[]);

  OCMStub([self.mockSharedInstance signIn]).andDo(^(NSInvocation *invocation) {
    [((NSObject<GIDSignInDelegate> *)self.plugin) signIn:self.mockSharedInstance
                                        didSignInForUser:mockUser
                                               withError:nil];
  });

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                    arguments:@{@"scopes" : requestedScopes}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns false"];
  [self.plugin handleMethodCall:methodCall
                         result:^(NSNumber *result) {
    XCTAssertFalse(result.boolValue);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRequestScopesReturnsTrueIfGranted {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock([GIDGoogleUser class]);
  OCMStub([self.mockSharedInstance currentUser]).andReturn(mockUser);
  NSArray *requestedScopes = @[ @"mockScope1" ];
  NSMutableArray *availableScopes = [NSMutableArray new];
  OCMStub(mockUser.grantedScopes).andReturn(availableScopes);

  OCMStub([self.mockSharedInstance signIn]).andDo(^(NSInvocation *invocation) {
    [availableScopes addObject:@"mockScope1"];
    [((NSObject<GIDSignInDelegate> *)self.plugin) signIn:self.mockSharedInstance
                                        didSignInForUser:mockUser
                                               withError:nil];
  });

  FlutterMethodCall *methodCall =
  [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                    arguments:@{@"scopes" : requestedScopes}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  [self.plugin handleMethodCall:methodCall
                         result:^(NSNumber *result) {
    XCTAssertTrue(result.boolValue);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
