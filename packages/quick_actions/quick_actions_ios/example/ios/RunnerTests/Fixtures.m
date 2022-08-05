// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Fixtures.h"

@implementation Fixtures

+ (UIApplicationShortcutItem *)searchTheThingShortcutItem {
  return [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];
}

+ (UIApplicationShortcutItem *)searchTheThingShortcutItem_noIcon {
  return [[UIApplicationShortcutItem alloc] initWithType:@"SearchTheThing"
                                          localizedTitle:@"Search the thing"
                                       localizedSubtitle:nil
                                                    icon:nil
                                                userInfo:nil];
}

+ (NSDictionary<NSString *, NSObject *> *)searchTheThingRawItem {
  return @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    @"icon" : @"search_the_thing.png",
  };
}

+ (NSDictionary<NSString *, NSObject *> *)searchTheThingRawItem_noIcon {
  return @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    // Dart's null value is passed to iOS as `NSNull`.
    // The key value pair is still present in the dictionary.
    @"icon" : [NSNull null],
  };
}

@end
