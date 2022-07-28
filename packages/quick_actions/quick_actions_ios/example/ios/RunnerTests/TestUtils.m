// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "TestUtils.h"

@implementation TestUtils

+ (UIApplicationShortcutItem *)searchTheThingShortcutItem {
  return [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];
}

+ (NSDictionary<NSString *, NSString *> *)searchTheThingRawItem {
  return @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    @"icon" : @"search_the_thing.png",
  };
}

@end
