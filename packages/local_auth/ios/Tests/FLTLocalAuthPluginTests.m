// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import LocalAuthentication;
@import XCTest;

#import <OCMock/OCMock.h>

#if __has_include(<local_auth/FLTLocalAuthPlugin.h>)
#import <local_auth/FLTLocalAuthPlugin.h>
#else
@import local_auth;
#endif

// Private API needed for tests.
@interface FLTLocalAuthPlugin (Test)
@property(nonatomic, nullable) LAContext* authContextOverride;
@end

@interface FLTLocalAuthPluginTests : XCTestCase
@end

@implementation FLTLocalAuthPluginTests

- (void)testSuccessfullAuthWithBiometrics {
  FLTLocalAuthPlugin* plugin = [[FLTLocalAuthPlugin alloc] init];
  id mockAuthContext = OCMClassMock([LAContext class]);
  plugin.authContextOverride = mockAuthContext;

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  NSString* reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation*) = ^(NSInvocation* invocation) {
    void (^reply)(BOOL, NSError*);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(YES, nil);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(YES),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation* expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      [expectation fulfill];
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertTrue([result boolValue]);
                    }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testSuccessfullAuthWithoutBiometrics {
  FLTLocalAuthPlugin* plugin = [[FLTLocalAuthPlugin alloc] init];
  id mockAuthContext = OCMClassMock([LAContext class]);
  plugin.authContextOverride = mockAuthContext;

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString* reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation*) = ^(NSInvocation* invocation) {
    void (^reply)(BOOL, NSError*);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(YES, nil);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation* expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      [expectation fulfill];
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertTrue([result boolValue]);
                    }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFailedAuthWithBiometrics {
  FLTLocalAuthPlugin* plugin = [[FLTLocalAuthPlugin alloc] init];
  id mockAuthContext = OCMClassMock([LAContext class]);
  plugin.authContextOverride = mockAuthContext;

  const LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
  NSString* reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation*) = ^(NSInvocation* invocation) {
    void (^reply)(BOOL, NSError*);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(NO, [NSError errorWithDomain:@"error" code:99 userInfo:nil]);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(YES),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation* expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      [expectation fulfill];
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertFalse([result boolValue]);
                    }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFailedAuthWithoutBiometrics {
  FLTLocalAuthPlugin* plugin = [[FLTLocalAuthPlugin alloc] init];
  id mockAuthContext = OCMClassMock([LAContext class]);
  plugin.authContextOverride = mockAuthContext;

  const LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
  NSString* reason = @"a reason";
  OCMStub([mockAuthContext canEvaluatePolicy:policy error:[OCMArg setTo:nil]]).andReturn(YES);

  // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
  // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
  // a background thread.
  void (^backgroundThreadReplyCaller)(NSInvocation*) = ^(NSInvocation* invocation) {
    void (^reply)(BOOL, NSError*);
    [invocation getArgument:&reply atIndex:4];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
      reply(NO, [NSError errorWithDomain:@"error" code:99 userInfo:nil]);
    });
  };
  OCMStub([mockAuthContext evaluatePolicy:policy localizedReason:reason reply:[OCMArg any]])
      .andDo(backgroundThreadReplyCaller);

  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"authenticate"
                                                              arguments:@{
                                                                @"biometricOnly" : @(NO),
                                                                @"localizedReason" : reason,
                                                              }];

  XCTestExpectation* expectation = [self expectationWithDescription:@"Result is called"];
  [plugin handleMethodCall:call
                    result:^(id _Nullable result) {
                      XCTAssertTrue([NSThread isMainThread]);
                      [expectation fulfill];
                      XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
                      XCTAssertFalse([result boolValue]);
                    }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
