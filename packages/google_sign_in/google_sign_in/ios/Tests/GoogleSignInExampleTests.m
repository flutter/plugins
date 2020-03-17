// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

@import XCTest;
@import google_sign_in;
@import GoogleSignIn;
@import OCMock;

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

- (void)testRequestScopesIfNoMissingScope {
  // Mock Google Signin internal calls
  GIDGoogleUser *mockUser = OCMClassMock(GIDGoogleUser.class);
  OCMStub(self.mockSharedInstance.currentUser).andReturn(mockUser);
  NSArray *currentScopes = @[@"mockScope1"];
  OCMStub(mockUser.grantedScopes).andReturn(currentScopes);
  FlutterMethodCall *methodCall = [FlutterMethodCall methodCallWithMethodName:@"requestScopes" arguments:@{@"scopes":currentScopes}];

  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect result returns true"];
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
