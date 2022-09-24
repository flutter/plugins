// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTShortcutStateManager.h"

@implementation FLTShortcutStateManager

- (void)setShortcutItems:(NSArray *)items {
  NSMutableArray<UIApplicationShortcutItem *> *newShortcuts = [[NSMutableArray alloc] init];

  for (id item in items) {
    UIApplicationShortcutItem *shortcut = [self deserializeShortcutItem:item];
    [newShortcuts addObject:shortcut];
  }

  [UIApplication sharedApplication].shortcutItems = newShortcuts;
}

- (UIApplicationShortcutItem *)deserializeShortcutItem:(NSDictionary *)serialized {
  UIApplicationShortcutIcon *icon =
      [serialized[@"icon"] isKindOfClass:[NSNull class]]
          ? nil
          : [UIApplicationShortcutIcon iconWithTemplateImageName:serialized[@"icon"]];
  return [[UIApplicationShortcutItem alloc] initWithType:serialized[@"type"]
                                          localizedTitle:serialized[@"localizedTitle"]
                                       localizedSubtitle:nil
                                                    icon:icon
                                                userInfo:nil];
}

@end
