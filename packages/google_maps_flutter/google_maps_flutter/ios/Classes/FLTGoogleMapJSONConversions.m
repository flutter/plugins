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
@end
