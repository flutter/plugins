// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapActionRecorder.h"

@implementation GoogleMapActionRecorder {
  NSMutableArray* actions;
  BOOL recordActions;
}
- (instancetype)init {
  self = [super init];
  if (self) {
    actions = [[NSMutableArray alloc] init];
    recordActions = NO;
  }
  return self;
}
- (void)startRecordingActions {
  recordActions = YES;
}
- (void)stopRecordingActions {
  recordActions = NO;
}
- (void)clearRecordedActions {
  [actions removeAllObjects];
}
- (void)recordAction:(NSString*)action value:(NSString*)value {
  if (!recordActions) {
    return;
  }
  NSMutableString* str = [[NSMutableString alloc] initWithCapacity:1000];
  [str appendString:action];
  if (value) {
    [str appendString:@" "];
    [str appendString:value];
  }
  [actions addObject:str];
}
- (void)recordAction:(NSString*)action boolValue:(BOOL)value {
  if (!recordActions) {
    return;
  }
  NSUInteger capacity = [action length] + 5;
  NSMutableString* str = [[NSMutableString alloc] initWithCapacity:capacity];
  [str appendString:action];
  [str appendString:@" "];
  if (value) {
    [str appendString:@"true"];
  } else {
    [str appendString:@"false"];
  }
  [actions addObject:str];
}

- (NSArray*)getRecordedActions {
  return actions;
}

@end
