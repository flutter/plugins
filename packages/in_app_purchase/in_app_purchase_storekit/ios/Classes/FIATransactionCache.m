// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIATransactionCache.h"

@interface FIATransactionCache ()

/// A NSMutableDictionary storing the objects that are cached.
@property(nonatomic, strong, nonnull) NSMutableDictionary *cache;

@end

@implementation FIATransactionCache

- (instancetype)init {
  self = [super init];
  if (self) {
    self.cache = [[NSMutableDictionary alloc] init];
  }

  return self;
}

- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key {
  NSArray *cachedObjects = self.cache[@(key)];

  self.cache[@(key)] =
      cachedObjects ? [cachedObjects arrayByAddingObjectsFromArray:objects] : objects;
}

- (NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  return self.cache[@(key)];
}

- (void)clear {
  [self.cache removeAllObjects];
}

@end
