// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>

@import in_app_purchase_storekit;

@interface FIATransactionCacheTests : XCTestCase

@end

@implementation FIATransactionCacheTests

- (void)testAddObjectsForNewKey {
  NSArray *dummyArray = @[ @1, @2, @3 ];
  FIATransactionCache *cache = [[FIATransactionCache alloc] init];
  [cache addObjects:dummyArray forKey:TransactionCacheKeyUpdatedTransactions];

  XCTAssertEqual(dummyArray, [cache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
}

- (void)testAddObjectsForExistingKey {
  NSArray *dummyArray = @[ @1, @2, @3 ];
  FIATransactionCache *cache = [[FIATransactionCache alloc] init];
  [cache addObjects:dummyArray forKey:TransactionCacheKeyUpdatedTransactions];

  XCTAssertEqual(dummyArray, [cache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);

  [cache addObjects:@[ @4, @5, @6 ] forKey:TransactionCacheKeyUpdatedTransactions];

  NSArray *expected = @[ @1, @2, @3, @4, @5, @6 ];
  XCTAssertEqualObjects(expected, [cache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
}

- (void)testGetObjectsForNonExistingKey {
  FIATransactionCache *cache = [[FIATransactionCache alloc] init];
  XCTAssertNil([cache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
}

- (void)testClear {
  NSArray *fakeUpdatedTransactions = @[ @1, @2, @3 ];
  NSArray *fakeRemovedTransactions = @[ @"Remove 1", @"Remove 2", @"Remove 3" ];
  NSArray *fakeUpdatedDownloads = @[ @"Download 1", @"Download 2" ];
  FIATransactionCache *cache = [[FIATransactionCache alloc] init];
  [cache addObjects:fakeUpdatedTransactions forKey:TransactionCacheKeyUpdatedTransactions];
  [cache addObjects:fakeRemovedTransactions forKey:TransactionCacheKeyRemovedTransactions];
  [cache addObjects:fakeUpdatedDownloads forKey:TransactionCacheKeyUpdatedDownloads];

  XCTAssertEqual(fakeUpdatedTransactions,
                 [cache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
  XCTAssertEqual(fakeRemovedTransactions,
                 [cache getObjectsForKey:TransactionCacheKeyRemovedTransactions]);
  XCTAssertEqual(fakeUpdatedDownloads,
                 [cache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]);

  [cache clear];

  XCTAssertNil([cache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
  XCTAssertNil([cache getObjectsForKey:TransactionCacheKeyRemovedTransactions]);
  XCTAssertNil([cache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]);
}
@end
