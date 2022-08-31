// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Manages the shortcut related states.
@interface FLTShortcutStateManager : NSObject

/// Sets the list of shortcut items.
///
/// @param items the list of shortcut items to be parsed and set.
- (void)setShortcutItems:(NSArray *)items API_AVAILABLE(ios(9.0));
@end

NS_ASSUME_NONNULL_END
