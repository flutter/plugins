// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFWebsiteDataStoreHostApiTests : XCTestCase
@end

@implementation FWFWebsiteDataStoreHostApiTests
- (void)testCreateFromWebViewConfigurationWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  [instanceManager addInstance:[[WKWebViewConfiguration alloc] init] withIdentifier:0];

  FlutterError *error;
  [hostApi createFromWebViewConfigurationWithIdentifier:@1 configurationIdentifier:@0 error:&error];
  WKWebsiteDataStore *dataStore = (WKWebsiteDataStore *)[instanceManager instanceForIdentifier:1];
  XCTAssertTrue([dataStore isKindOfClass:[WKWebsiteDataStore class]]);
  XCTAssertNil(error);
}

- (void)testCreateDefaultDataStoreWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createDefaultDataStoreWithIdentifier:@0 error:&error];
  WKWebsiteDataStore *dataStore = (WKWebsiteDataStore *)[instanceManager instanceForIdentifier:0];
  XCTAssertEqualObjects(dataStore, [WKWebsiteDataStore defaultDataStore]);
  XCTAssertNil(error);
}

- (void)testRemoveDataOfTypes {
  WKWebsiteDataStore *mockWebsiteDataStore = OCMClassMock([WKWebsiteDataStore class]);

  WKWebsiteDataRecord *mockDataRecord = OCMClassMock([WKWebsiteDataRecord class]);
  OCMStub([mockWebsiteDataStore
      fetchDataRecordsOfTypes:[NSSet setWithObject:WKWebsiteDataTypeLocalStorage]
            completionHandler:([OCMArg invokeBlockWithArgs:@[ mockDataRecord ], nil])]);

  OCMStub([mockWebsiteDataStore
      removeDataOfTypes:[NSSet setWithObject:WKWebsiteDataTypeLocalStorage]
          modifiedSince:[NSDate dateWithTimeIntervalSince1970:45.0]
      completionHandler:([OCMArg invokeBlock])]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebsiteDataStore withIdentifier:0];

  FWFWebsiteDataStoreHostApiImpl *hostApi =
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  NSNumber __block *returnValue;
  FlutterError *__block blockError;
  [hostApi removeDataFromDataStoreWithIdentifier:@0
                                         ofTypes:@[
                                           [FWFWKWebsiteDataTypeEnumData
                                               makeWithValue:FWFWKWebsiteDataTypeEnumLocalStorage]
                                         ]
                                   modifiedSince:@45.0
                                      completion:^(NSNumber *result, FlutterError *error) {
                                        returnValue = result;
                                        blockError = error;
                                      }];
  XCTAssertEqualObjects(returnValue, @YES);
  XCTAssertNil(blockError);
}
@end
