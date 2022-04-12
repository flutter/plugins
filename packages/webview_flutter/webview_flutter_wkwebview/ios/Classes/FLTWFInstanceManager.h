// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWFInstanceManager : NSObject
- (void)addInstance:(nonnull NSObject *)instance instanceID:(long)instanceID;

- (nullable NSObject *)removeInstanceWithID:(long)instanceId;

- (nullable NSNumber *)removeInstance:(NSObject *)instance;

- (nullable NSObject *)instanceForID:(long)instanceID;

- (nullable NSNumber *)instanceIDForInstance:(nonnull NSObject *)instance;
@end

NS_ASSUME_NONNULL_END
