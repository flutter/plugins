// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JsonConversions.h"

@implementation FLTGoogleMapJsonConversions

+ (bool)toBool:(NSNumber*)data {
  return data.boolValue;
}

+ (int)toInt:(NSNumber*)data {
  return data.intValue;
}

+ (double)toDouble:(NSNumber*)data {
  return data.doubleValue;
}

+ (float)toFloat:(NSNumber*)data {
  return data.floatValue;
}

+ (CLLocationCoordinate2D)toLocation:(NSArray*)data {
  return CLLocationCoordinate2DMake([FLTGoogleMapJsonConversions toDouble:data[0]],
                                    [FLTGoogleMapJsonConversions toDouble:data[1]]);
}

+ (CGPoint)toPoint:(NSArray*)data {
  return CGPointMake([FLTGoogleMapJsonConversions toDouble:data[0]],
                     [FLTGoogleMapJsonConversions toDouble:data[1]]);
}

+ (NSArray*)positionToJson:(CLLocationCoordinate2D)position {
  return @[ @(position.latitude), @(position.longitude) ];
}

+ (UIColor*)toColor:(NSArray*)data {
  NSNumber* numberColor = (NSNumber*)data;
  long value = [numberColor longValue];
  return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                         green:((float)((value & 0xFF00) >> 8)) / 255.0
                          blue:((float)(value & 0xFF)) / 255.0
                         alpha:1.0];
}

+ (NSMutableArray*)toPoints:json {
  NSMutableArray* points = [[NSMutableArray alloc] init];
  NSArray* data = json;
  for (int i = 0; i < [data count]; i++) {
    CLLocation* point =
        [[CLLocation alloc] initWithLatitude:[FLTGoogleMapJsonConversions toDouble:data[i][0]]
                                   longitude:[FLTGoogleMapJsonConversions toDouble:data[i][1]]];
    [points addObject:point];
  }

  return points;
}

@end
