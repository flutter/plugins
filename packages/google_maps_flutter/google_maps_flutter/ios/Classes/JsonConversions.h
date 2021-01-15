// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

@interface FLTGoogleMapJsonConversions : NSObject
+ (bool)toBool:(NSNumber*)data;
+ (int)toInt:(NSNumber*)data;
+ (double)toDouble:(NSNumber*)data;
+ (float)toFloat:(NSNumber*)data;
+ (CLLocationCoordinate2D)toLocation:(NSArray*)data;
+ (CGPoint)toPoint:(NSArray*)data;
+ (NSArray*)positionToJson:(CLLocationCoordinate2D)position;
+ (UIColor*)toColor:(NSNumber*)data;
+ (NSArray<CLLocation*>*)toPoints:(NSArray*)data;
+ (NSArray<NSArray<CLLocation*>*>*)toHoles:(NSArray*)data;
@end
