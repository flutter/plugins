// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
#import "FLTShortcutStateManager.h"

NS_ASSUME_NONNULL_BEGIN

/// APIs exposed for unit tests.
@interface FLTQuickActionsPlugin ()

/// Initializes a FLTQuickActionsPlugin with the given method channel.
/// API exposed for unit tests.
/// @param channel A method channel.
/// @param shortcutStateManager An FLTShortcutStateManager that manages shortcut related states.
/// @return The initialized FLTQuickActionsPlugin.
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
           shortcutStateManager:(FLTShortcutStateManager *)shortcutStateManager;

@end

NS_ASSUME_NONNULL_END
