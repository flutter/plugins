// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTShortcutStateManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLTQuickActionsPlugin (Test)

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
           shortcutStateManager:(FLTShortcutStateManager *)shortcutStateManager;

@end

NS_ASSUME_NONNULL_END
