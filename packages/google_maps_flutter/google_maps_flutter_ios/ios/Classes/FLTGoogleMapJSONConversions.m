// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapJSONConversions.h"

@implementation FLTGoogleMapJSONConversions

+ (CLLocationCoordinate2D)locationFromLatLong:(NSArray *)latlong {
  return CLLocationCoordinate2DMake([latlong[0] doubleValue], [latlong[1] doubleValue]);
}

+ (CGPoint)pointFromArray:(NSArray *)array {
  return CGPointMake([array[0] doubleValue], [array[1] doubleValue]);
}

+ (NSArray *)arrayFromLocation:(CLLocationCoordinate2D)location {
  return @[ @(location.latitude), @(location.longitude) ];
}

+ (UIColor *)colorFromRGBA:(NSNumber *)numberColor {
  unsigned long value = [numberColor unsignedLongValue];
  return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                         green:((float)((value & 0xFF00) >> 8)) / 255.0
                          blue:((float)(value & 0xFF)) / 255.0
                         alpha:((float)((value & 0xFF000000) >> 24)) / 255.0];
}

+ (NSNumber *)rgbaFromColor:(UIColor *)color {
  CGFloat red, green, blue, alpha;
  [color getRed:&red green:&green blue:&blue alpha:&alpha];
  unsigned long value = ((unsigned long)(alpha * 255) << 24) | ((unsigned long)(red * 255) << 16) |
                        ((unsigned long)(green * 255) << 8) | ((unsigned long)(blue * 255));
  return @(value);
}

+ (NSArray<CLLocation *> *)pointsFromLatLongs:(NSArray *)data {
  NSMutableArray *points = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSNumber *latitude = data[i][0];
    NSNumber *longitude = data[i][1];
    CLLocation *point = [[CLLocation alloc] initWithLatitude:[latitude doubleValue]
                                                   longitude:[longitude doubleValue]];
    [points addObject:point];
  }

  return points;
}

+ (NSArray<NSArray<CLLocation *> *> *)holesFromPointsArray:(NSArray *)data {
  NSMutableArray<NSArray<CLLocation *> *> *holes = [[[NSMutableArray alloc] init] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSArray<CLLocation *> *points = [FLTGoogleMapJSONConversions pointsFromLatLongs:data[i]];
    [holes addObject:points];
  }

  return holes;
}

+ (nullable NSDictionary<NSString *, id> *)dictionaryFromPosition:(GMSCameraPosition *)position {
  if (!position) {
    return nil;
  }
  return @{
    @"target" : [FLTGoogleMapJSONConversions arrayFromLocation:[position target]],
    @"zoom" : @([position zoom]),
    @"bearing" : @([position bearing]),
    @"tilt" : @([position viewingAngle]),
  };
}

+ (NSDictionary<NSString *, NSNumber *> *)dictionaryFromPoint:(CGPoint)point {
  return @{
    @"x" : @(lroundf(point.x)),
    @"y" : @(lroundf(point.y)),
  };
}

+ (nullable NSDictionary *)dictionaryFromCoordinateBounds:(GMSCoordinateBounds *)bounds {
  if (!bounds) {
    return nil;
  }
  return @{
    @"southwest" : [FLTGoogleMapJSONConversions arrayFromLocation:[bounds southWest]],
    @"northeast" : [FLTGoogleMapJSONConversions arrayFromLocation:[bounds northEast]],
  };
}

+ (nullable GMSCameraPosition *)cameraPostionFromDictionary:(nullable NSDictionary *)data {
  if (!data) {
    return nil;
  }
  return [GMSCameraPosition
      cameraWithTarget:[FLTGoogleMapJSONConversions locationFromLatLong:data[@"target"]]
                  zoom:[data[@"zoom"] floatValue]
               bearing:[data[@"bearing"] doubleValue]
          viewingAngle:[data[@"tilt"] doubleValue]];
}

+ (CGPoint)pointFromDictionary:(NSDictionary *)dictionary {
  double x = [dictionary[@"x"] doubleValue];
  double y = [dictionary[@"y"] doubleValue];
  return CGPointMake(x, y);
}

+ (GMSCoordinateBounds *)coordinateBoundsFromLatLongs:(NSArray *)latlongs {
  return [[GMSCoordinateBounds alloc]
      initWithCoordinate:[FLTGoogleMapJSONConversions locationFromLatLong:latlongs[0]]
              coordinate:[FLTGoogleMapJSONConversions locationFromLatLong:latlongs[1]]];
}

+ (GMSMapViewType)mapViewTypeFromTypeValue:(NSNumber *)typeValue {
  int value = [typeValue intValue];
  return (GMSMapViewType)(value == 0 ? 5 : value);
}

+ (nullable GMSCameraUpdate *)cameraUpdateFromChannelValue:(NSArray *)channelValue {
  NSString *update = channelValue[0];
  if ([update isEqualToString:@"newCameraPosition"]) {
    return [GMSCameraUpdate
        setCamera:[FLTGoogleMapJSONConversions cameraPostionFromDictionary:channelValue[1]]];
  } else if ([update isEqualToString:@"newLatLng"]) {
    return [GMSCameraUpdate
        setTarget:[FLTGoogleMapJSONConversions locationFromLatLong:channelValue[1]]];
  } else if ([update isEqualToString:@"newLatLngBounds"]) {
    return [GMSCameraUpdate
          fitBounds:[FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:channelValue[1]]
        withPadding:[channelValue[2] doubleValue]];
  } else if ([update isEqualToString:@"newLatLngZoom"]) {
    return
        [GMSCameraUpdate setTarget:[FLTGoogleMapJSONConversions locationFromLatLong:channelValue[1]]
                              zoom:[channelValue[2] floatValue]];
  } else if ([update isEqualToString:@"scrollBy"]) {
    return [GMSCameraUpdate scrollByX:[channelValue[1] doubleValue]
                                    Y:[channelValue[2] doubleValue]];
  } else if ([update isEqualToString:@"zoomBy"]) {
    if (channelValue.count == 2) {
      return [GMSCameraUpdate zoomBy:[channelValue[1] floatValue]];
    } else {
      return [GMSCameraUpdate zoomBy:[channelValue[1] floatValue]
                             atPoint:[FLTGoogleMapJSONConversions pointFromArray:channelValue[2]]];
    }
  } else if ([update isEqualToString:@"zoomIn"]) {
    return [GMSCameraUpdate zoomIn];
  } else if ([update isEqualToString:@"zoomOut"]) {
    return [GMSCameraUpdate zoomOut];
  } else if ([update isEqualToString:@"zoomTo"]) {
    return [GMSCameraUpdate zoomTo:[channelValue[1] floatValue]];
  }
  return nil;
}

+ (GMUWeightedLatLng *)weightedLatLngFromArray:(NSArray *)data {
  NSAssert(data.count == 2, @"WeightedLatLng data must have length of 2");
  if (data.count != 2) {
    return nil;
  }
  return [[GMUWeightedLatLng alloc]
      initWithCoordinate:[FLTGoogleMapJSONConversions locationFromLatLong:data[0]]
               intensity:[data[1] doubleValue]];
}

+ (NSArray *)arrayFromWeightedLatLng:(GMUWeightedLatLng *)weightedLatLng {
  GMSMapPoint point = {weightedLatLng.point.x, weightedLatLng.point.y};
  return @[
    [FLTGoogleMapJSONConversions arrayFromLocation:GMSUnproject(point)], @(weightedLatLng.intensity)
  ];
}

+ (NSArray<GMUWeightedLatLng *> *)weightedDataFromArray:(NSArray *)data {
  NSMutableArray<GMUWeightedLatLng *> *weightedData = [[NSMutableArray alloc] init];
  for (NSArray *latLng in data) {
    GMUWeightedLatLng *weightedLatLng =
        [FLTGoogleMapJSONConversions weightedLatLngFromArray:latLng];
    if (weightedLatLng == nil) continue;
    [weightedData addObject:weightedLatLng];
  }

  return weightedData;
}

+ (NSArray *)arrayFromWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData {
  NSMutableArray *data = [[NSMutableArray alloc] init];
  for (GMUWeightedLatLng *weightedLatLng in weightedData) {
    [data addObject:[FLTGoogleMapJSONConversions arrayFromWeightedLatLng:weightedLatLng]];
  }

  return data;
}

+ (GMUGradient *)gradientFromDictionary:(NSDictionary *)data {
  NSMutableArray<UIColor *> *colors = [[NSMutableArray alloc] init];

  NSArray *colorData = data[@"colors"];
  for (NSNumber *colorCode in colorData) {
    [colors addObject:[FLTGoogleMapJSONConversions colorFromRGBA:colorCode]];
  }

  return [[GMUGradient alloc] initWithColors:colors
                                 startPoints:data[@"startPoints"]
                                colorMapSize:[data[@"colorMapSize"] intValue]];
}

+ (NSDictionary *)dictionaryFromGradient:(GMUGradient *)gradient {
  NSMutableArray<NSNumber *> *colorCodes = [[NSMutableArray alloc] init];
  for (UIColor *color in gradient.colors) {
    [colorCodes addObject:[FLTGoogleMapJSONConversions rgbaFromColor:color]];
  }

  return @{
    @"colors" : colorCodes,
    @"startPoints" : gradient.startPoints,
    @"colorMapSize" : @(gradient.mapSize)
  };
}

@end
