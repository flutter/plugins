// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/// Contains dummy data used for unit tests.
@interface Fixtures : NSObject

/// A dummy `UIApplicationShortcutItem`.
+ (UIApplicationShortcutItem *)searchTheThingShortcutItem;

/// A dummy `UIApplicationShortcutItem` with no icon.
+ (UIApplicationShortcutItem *)searchTheThingShortcutItem_noIcon;

/// A dummy raw shortcut item.
+ (NSDictionary<NSString *, NSObject *> *)searchTheThingRawItem;

/// A dummy raw shortcut item with no icon.
+ (NSDictionary<NSString *, NSObject *> *)searchTheThingRawItem_noIcon;

@end

NS_ASSUME_NONNULL_END
