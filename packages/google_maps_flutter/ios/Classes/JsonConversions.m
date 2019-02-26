// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JsonConversions.h"

@implementation FLTGoogleMapJsonConversions

+ (bool)toBool:(id)json {
  NSNumber* data = json;
  return data.boolValue;
}

+ (int)toInt:(id)json {
  NSNumber* data = json;
  return data.intValue;
}

+ (double)toDouble:(id)json {
  NSNumber* data = json;
  return data.doubleValue;
}

+ (float)toFloat:(id)json {
  NSNumber* data = json;
  return data.floatValue;
}

+ (CLLocationCoordinate2D)toLocation:(id)json {
  NSArray* data = json;
  return CLLocationCoordinate2DMake([FLTGoogleMapJsonConversions toDouble:data[0]],
                                    [FLTGoogleMapJsonConversions toDouble:data[1]]);
}

+ (CGPoint)toPoint:(id)json {
  NSArray* data = json;
  return CGPointMake([FLTGoogleMapJsonConversions toDouble:data[0]],
                     [FLTGoogleMapJsonConversions toDouble:data[1]]);
}

@end