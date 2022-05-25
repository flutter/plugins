// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFInstanceManager.h"

@interface FWFInstanceManager ()
@property dispatch_queue_t lockQueue;
@property NSMapTable<NSNumber *, NSObject *> *identifiersToInstances;
@property NSMapTable<NSObject *, NSNumber *> *instancesToIdentifiers;
@end

@implementation FWFInstanceManager
- (instancetype)init {
  if (self) {
    _lockQueue = dispatch_queue_create("FWFInstanceManager", DISPATCH_QUEUE_SERIAL);
    _identifiersToInstances = [NSMapTable strongToStrongObjectsMapTable];
    _instancesToIdentifiers = [NSMapTable strongToStrongObjectsMapTable];
  }
  return self;
}

- (void)addDartCreatedInstance:(nonnull NSObject *)instance
                withIdentifier:(long)instanceIdentifier {
  NSAssert(instance && instanceIdentifier >= 0,
           @"Instance must be nonnull and identifier must be >= 0.");
  dispatch_async(_lockQueue, ^{
    [self.instancesToIdentifiers setObject:@(instanceIdentifier) forKey:instance];
    [self.identifiersToInstances setObject:instance forKey:@(instanceIdentifier)];
  });
}

- (nullable NSObject *)removeInstanceWithIdentifier:(long)instanceIdentifier {
  NSObject *__block instance = nil;
  dispatch_sync(_lockQueue, ^{
    instance = [self.identifiersToInstances objectForKey:@(instanceIdentifier)];
    if (instance) {
      [self.identifiersToInstances removeObjectForKey:@(instanceIdentifier)];
      [self.instancesToIdentifiers removeObjectForKey:instance];
    }
  });
  return instance;
}

- (long)removeInstance:(NSObject *)instance {
  NSAssert(instance, @"Instance must be nonnull.");
  NSNumber *__block identifierNumber = nil;
  dispatch_sync(_lockQueue, ^{
    identifierNumber = [self.instancesToIdentifiers objectForKey:instance];
    if (identifierNumber) {
      [self.identifiersToInstances removeObjectForKey:identifierNumber];
      [self.instancesToIdentifiers removeObjectForKey:instance];
    }
  });
  return identifierNumber ? identifierNumber.longValue : NSNotFound;
}

- (nullable NSObject *)instanceForIdentifier:(long)instanceIdentifier {
  NSObject *__block instance = nil;
  dispatch_sync(_lockQueue, ^{
    instance = [self.identifiersToInstances objectForKey:@(instanceIdentifier)];
  });
  return instance;
}

- (long)identifierForInstance:(nonnull NSObject *)instance {
  NSNumber *__block identifierNumber = nil;
  dispatch_sync(_lockQueue, ^{
    identifierNumber = [self.instancesToIdentifiers objectForKey:instance];
  });
  return identifierNumber ? identifierNumber.longValue : NSNotFound;
}
@end
