// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

@interface GoogleMapActionRecorder : NSObject
- (instancetype)init;
- (void)startRecordingActions;
- (void)stopRecordingActions;
- (void)clearRecordedActions;
- (void)recordAction:(NSString*)action value:(NSString*)value;
- (void)recordAction:(NSString*)action boolValue:(BOOL)value;
- (NSArray*)getRecordedActions;
@end
