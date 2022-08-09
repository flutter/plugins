// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

NS_ASSUME_NONNULL_BEGIN

/// APIs exposed for unit tests.
@interface FLTQuickActionsPlugin ()

/// The type of the shortcut item selected when launching the app.
/// API exposed for unit tests.
@property(nonatomic, strong, nullable) NSString *launchingShortcutType;

/// Initializes a FLTQuickActionsPlugin with the given method channel.
/// API exposed for unit tests.
/// @param channel A method channel.
/// @return The initialized FLTQuickActionsPlugin.
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;

@end

NS_ASSUME_NONNULL_END
