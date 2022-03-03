// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TransactionCacheKey) {
  TransactionCacheKeyUpdatedDownloads,
  TransactionCacheKeyUpdatedTransactions,
  TransactionCacheKeyRemovedTransactions
};

@interface FIATransactionCache : NSObject

/// Add objects to the transaction cache.
///
/// If the cache already contain an array of objects on the specified key, the supplied
/// array will be appended to the existing array.
- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key;

/// Gets the array of objects stored at the given key.
///
/// If there are no objects associated with the given key nil is returned.
- (NSArray *)getObjectsForKey:(TransactionCacheKey)key;

/// Remove objects to the transaction cache for the supplied key.
- (void)removeObjectsForKey:(TransactionCacheKey)key;

@end

NS_ASSUME_NONNULL_END
