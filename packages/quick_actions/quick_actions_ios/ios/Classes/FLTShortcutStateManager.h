// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Manages the shortcut related states.
///
/// There are 2 shortcut states: a list of all shortcuts, and the shortcut that is chosen when
/// launching the app.
@interface FLTShortcutStateManager : NSObject

/// The type of the shortcut item that is chosen when launching the app.
@property(nonatomic, retain, nullable) NSString *launchingShortcutType;

/// Sets the list of shortcut items.
- (void)setShortcutItems:(NSArray *)items;
@end

NS_ASSUME_NONNULL_END
