// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#define FLTLogWarning(format, ...) NSLog((@"FirebaseAdMobPlugin <warning> " format), ##__VA_ARGS__)

@interface FLTFirebaseAdMobPlugin : NSObject <FlutterPlugin>
@end
