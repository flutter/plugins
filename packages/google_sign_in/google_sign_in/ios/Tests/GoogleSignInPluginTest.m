// Copyright 2019 The Chromium Authors. All rights reserved.
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
@property(strong, nonatomic) GIDSignIn *mockSharedInstance;

@end

@implementation FLTGoogleSignInPluginTest

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.mockPluginRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  self.mockSharedInstance = [OCMockObject partialMockForObject:[GIDSignIn sharedInstance]];
  OCMStub(self.mockPluginRegistrar.messenger).andReturn(self.mockBinaryMessenger);
  self.plugin = [[FLTGoogleSignInPlugin alloc] init];
  [FLTGoogleSignInPlugin registerWithRegistrar:self.mockPluginRegistrar];
}

- (void)tearDown {
  [((OCMockObject *)self.mockSharedInstance) stopMocking];
  [super tearDown];
}

- (void)testRequestScopesResultErrorIfNotSignedIn {
  OCMStub(self.mockSharedInstance.currentUser).andReturn(nil);

  FlutterMethodCall *methodCall =
      [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                        arguments:@{@"scopes" : @[ @"mockScope1" ]}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  __block id result;
  [self.plugin handleMethodCall:methodCall
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqualObjects([((FlutterError *)result) code], @"sign_in_required");
}

- (void)testRequestScopesIfNoMissingScope {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock(GIDGoogleUser.class);
  OCMStub(self.mockSharedInstance.currentUser).andReturn(mockUser);
  NSArray *requestedScopes = @[ @"mockScope1" ];
  OCMStub(mockUser.grantedScopes).andReturn(requestedScopes);
  FlutterMethodCall *methodCall =
      [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                        arguments:@{@"scopes" : requestedScopes}];

  XCTestExpectation *expectation = [self expectationWithDescription:@"expect result returns true"];
  __block id result;
  [self.plugin handleMethodCall:methodCall
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue([result boolValue]);
}

- (void)testRequestScopesRequestsIfNotGranted {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock(GIDGoogleUser.class);
  OCMStub(self.mockSharedInstance.currentUser).andReturn(mockUser);
  NSArray *requestedScopes = @[ @"mockScope1" ];
  OCMStub(mockUser.grantedScopes).andReturn(@[]);

  FlutterMethodCall *methodCall =
      [FlutterMethodCall methodCallWithMethodName:@"requestScopes"
                                        arguments:@{@"scopes" : requestedScopes}];

  [self.plugin handleMethodCall:methodCall
                         result:^(id r){
                         }];

  XCTAssertTrue([self.mockSharedInstance.scopes containsObject:@"mockScope1"]);
  OCMVerify([self.mockSharedInstance signIn]);
}

- (void)testRequestScopesReturnsFalseIfNotGranted {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock(GIDGoogleUser.class);
  OCMStub(self.mockSharedInstance.currentUser).andReturn(mockUser);
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
  __block id result;
  [self.plugin handleMethodCall:methodCall
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertFalse([result boolValue]);
}

- (void)testRequestScopesReturnsTrueIfGranted {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock(GIDGoogleUser.class);
  OCMStub(self.mockSharedInstance.currentUser).andReturn(mockUser);
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
  __block id result;
  [self.plugin handleMethodCall:methodCall
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue([result boolValue]);
}

@end
