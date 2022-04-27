// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JsonConversions.h"

@implementation FLTGoogleMapJsonConversions

+ (bool)toBool:(NSNumber *)data {
  return data.boolValue;
}

+ (int)toInt:(NSNumber *)data {
  return data.intValue;
}

+ (double)toDouble:(NSNumber *)data {
  return data.doubleValue;
}

+ (float)toFloat:(NSNumber *)data {
  return data.floatValue;
}

+ (CLLocationCoordinate2D)toLocation:(NSArray *)data {
  return CLLocationCoordinate2DMake([FLTGoogleMapJsonConversions toDouble:data[0]],
                                    [FLTGoogleMapJsonConversions toDouble:data[1]]);
}

+ (CGPoint)toPoint:(NSArray *)data {
  return CGPointMake([FLTGoogleMapJsonConversions toDouble:data[0]],
                     [FLTGoogleMapJsonConversions toDouble:data[1]]);
}

+ (NSArray *)positionToJson:(CLLocationCoordinate2D)position {
  return @[ @(position.latitude), @(position.longitude) ];
}

+ (UIColor *)toColor:(NSNumber *)numberColor {
  unsigned long value = [numberColor unsignedLongValue];
  return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                         green:((float)((value & 0xFF00) >> 8)) / 255.0
                          blue:((float)(value & 0xFF)) / 255.0
                         alpha:((float)((value & 0xFF000000) >> 24)) / 255.0];
}

+ (NSArray<CLLocation *> *)toPoints:(NSArray *)data {
  NSMutableArray *points = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSNumber *latitude = data[i][0];
    NSNumber *longitude = data[i][1];
    CLLocation *point =
        [[CLLocation alloc] initWithLatitude:[FLTGoogleMapJsonConversions toDouble:latitude]
                                   longitude:[FLTGoogleMapJsonConversions toDouble:longitude]];
    [points addObject:point];
  }

  return points;
}

+ (NSArray<NSArray<CLLocation *> *> *)toHoles:(NSArray *)data {
  NSMutableArray<NSArray<CLLocation *> *> *holes = [[[NSMutableArray alloc] init] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSArray<CLLocation *> *points = [FLTGoogleMapJsonConversions toPoints:data[i]];
    [holes addObject:points];
  }

  return holes;
}

+ (GMUWeightedLatLng *)toWeightedLatLng:(NSArray *)data {
  return
      [[GMUWeightedLatLng alloc] initWithCoordinate:[FLTGoogleMapJsonConversions toLocation:data[0]]
                                          intensity:[FLTGoogleMapJsonConversions toDouble:data[1]]];
}

+ (NSArray<GMUWeightedLatLng *> *)toWeightedData:(NSArray *)data {
  NSMutableArray<GMUWeightedLatLng *> *weightedData = [[NSMutableArray alloc] init];
  for (NSArray *latLng in data) {
    GMUWeightedLatLng *weightedLatLng = [FLTGoogleMapJsonConversions toWeightedLatLng:latLng];
    [weightedData addObject:weightedLatLng];
  }

  return weightedData;
}

+ (GMUGradient *)toGradient:(NSDictionary *)data {
  NSMutableArray<UIColor *> *colors = [[NSMutableArray alloc] init];

  NSArray *colorData = data[@"colors"];
  for (NSNumber *colorCode in colorData) {
    [colors addObject:[FLTGoogleMapJsonConversions toColor:colorCode]];
  }

  return [[GMUGradient alloc]
      initWithColors:colors
         startPoints:data[@"startPoints"]
        colorMapSize:[FLTGoogleMapJsonConversions toInt:data[@"colorMapSize"]]];
}

@end
