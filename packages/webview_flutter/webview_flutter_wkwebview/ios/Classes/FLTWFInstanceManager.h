// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Maintains instances to intercommunicate with Dart objects.
 *
 * When an instance is added with an instanceId, either can be used to retrieve the other.
 */
@interface FLTWFInstanceManager : NSObject
/**
 * Add a new instance to the manager.
 *
 * If an instance or instanceID has already been added, it will be replaced by the new values.
 */
- (void)addInstance:(nonnull NSObject *)instance instanceID:(long)instanceID;

/**
 * Remove the instance with instanceID from the manager.
 *
 * Returns the removed instance if the manager contains the instanceId, otherwise nil.
 */
- (nullable NSObject *)removeInstanceWithID:(long)instanceId;

/**
 * Remove the instance from the manager.
 *
 * Returns the instanceID of the removed instance if the manager contains the value, otherwise nil.
 */
- (nullable NSNumber *)removeInstance:(NSObject *)instance;

/**
 * Retrieve the Object paired with instanceId.
 *
 * Returns the instance stored with the instanceID if the manager contains the value, otherwise nil.
 */
- (nullable NSObject *)instanceForID:(long)instanceID;

/**
 * Retrieve the instanceID paired with an instance.
 *
 * Returns the instanceID paired with instance if the manager contains the value, otherwise nil.
 */
- (nullable NSNumber *)instanceIDForInstance:(nonnull NSObject *)instance;
@end

NS_ASSUME_NONNULL_END
