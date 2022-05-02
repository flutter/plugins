// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFPreferencesHostApiTests : XCTestCase
@end

@implementation FWFPreferencesHostApiTests

- (void)testSetJavaScriptEnabled {
  WKPreferences *mockPreferences = OCMClassMock([WKPreferences class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockPreferences withIdentifier:0];

  FWFPreferencesHostApiImpl *hostApi =
      [[FWFPreferencesHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setJavaScriptEnabledForPreferencesWithIdentifier:@0
  
  isEnabled:@YES
  
  error:&error];
  OCMVerify([mockPreferences setJavaScriptEnabled
  
  :YES
  
  
  ]);
  XCTAssertNil(error);
}

@end
