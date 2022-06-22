// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTGoogleMapJSONConversions : NSObject

+ (CLLocationCoordinate2D)locationFromLatLong:(NSArray *)latlong;
+ (CGPoint)pointFromArray:(NSArray *)array;
+ (NSArray *)arrayFromLocation:(CLLocationCoordinate2D)location;
+ (UIColor *)colorFromRGBA:(NSNumber *)data;
+ (NSArray<CLLocation *> *)pointsFromLatLongs:(NSArray *)data;
+ (NSArray<NSArray<CLLocation *> *> *)holesFromPointsArray:(NSArray *)data;
+ (nullable NSDictionary<NSString *, id> *)dictionaryFromPosition:
    (nullable GMSCameraPosition *)position;
+ (NSDictionary<NSString *, NSNumber *> *)dictionaryFromPoint:(CGPoint)point;
+ (nullable NSDictionary *)dictionaryFromCoordinateBounds:(nullable GMSCoordinateBounds *)bounds;
+ (nullable GMSCameraPosition *)cameraPostionFromDictionary:(nullable NSDictionary *)channelValue;
+ (CGPoint)pointFromDictionary:(NSDictionary *)dictionary;
+ (GMSCoordinateBounds *)coordinateBoundsFromLatLongs:(NSArray *)latlongs;
+ (GMSMapViewType)mapViewTypeFromTypeValue:(NSNumber *)value;
+ (nullable GMSCameraUpdate *)cameraUpdateFromChannelValue:(NSArray *)channelValue;

@end

NS_ASSUME_NONNULL_END
