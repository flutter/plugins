// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import MapKit;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "PartiallyMockedMapView.h"

@interface FLTGoogleMapJSONConversionsTests : XCTestCase
@end

@implementation FLTGoogleMapJSONConversionsTests

- (void)testLocationFromLatLong {
  NSArray<NSNumber *> *latlong = @[ @1, @2 ];
  CLLocationCoordinate2D location = [FLTGoogleMapJSONConversions locationFromLatLong:latlong];
  XCTAssertEqual(location.latitude, 1);
  XCTAssertEqual(location.longitude, 2);
}

- (void)testPointFromArray {
  NSArray<NSNumber *> *array = @[ @1, @2 ];
  CGPoint point = [FLTGoogleMapJSONConversions pointFromArray:array];
  XCTAssertEqual(point.x, 1);
  XCTAssertEqual(point.y, 2);
}

- (void)testArrayFromLocation {
  CLLocationCoordinate2D location = CLLocationCoordinate2DMake(1, 2);
  NSArray<NSNumber *> *array = [FLTGoogleMapJSONConversions arrayFromLocation:location];
  XCTAssertEqual([array[0] integerValue], 1);
  XCTAssertEqual([array[1] integerValue], 2);
}

- (void)testColorFromRGBA {
  NSNumber *rgba = @(0x01020304);
  UIColor *color = [FLTGoogleMapJSONConversions colorFromRGBA:rgba];
  CGFloat red, green, blue, alpha;
  BOOL success = [color getRed:&red green:&green blue:&blue alpha:&alpha];
  XCTAssertTrue(success);
  const CGFloat accuracy = 0.0001;
  XCTAssertEqualWithAccuracy(red, 2 / 255.0, accuracy);
  XCTAssertEqualWithAccuracy(green, 3 / 255.0, accuracy);
  XCTAssertEqualWithAccuracy(blue, 4 / 255.0, accuracy);
  XCTAssertEqualWithAccuracy(alpha, 1 / 255.0, accuracy);
}

- (void)testPointsFromLatLongs {
  NSArray<NSArray *> *latlongs = @[ @[ @1, @2 ], @[ @(3), @(4) ] ];
  NSArray<CLLocation *> *locations = [FLTGoogleMapJSONConversions pointsFromLatLongs:latlongs];
  XCTAssertEqual(locations.count, 2);
  XCTAssertEqual(locations[0].coordinate.latitude, 1);
  XCTAssertEqual(locations[0].coordinate.longitude, 2);
  XCTAssertEqual(locations[1].coordinate.latitude, 3);
  XCTAssertEqual(locations[1].coordinate.longitude, 4);
}

- (void)testHolesFromPointsArray {
  NSArray<NSArray *> *pointsArray =
      @[ @[ @[ @1, @2 ], @[ @(3), @(4) ] ], @[ @[ @(5), @(6) ], @[ @(7), @(8) ] ] ];
  NSArray<NSArray<CLLocation *> *> *holes =
      [FLTGoogleMapJSONConversions holesFromPointsArray:pointsArray];
  XCTAssertEqual(holes.count, 2);
  XCTAssertEqual(holes[0][0].coordinate.latitude, 1);
  XCTAssertEqual(holes[0][0].coordinate.longitude, 2);
  XCTAssertEqual(holes[0][1].coordinate.latitude, 3);
  XCTAssertEqual(holes[0][1].coordinate.longitude, 4);
  XCTAssertEqual(holes[1][0].coordinate.latitude, 5);
  XCTAssertEqual(holes[1][0].coordinate.longitude, 6);
  XCTAssertEqual(holes[1][1].coordinate.latitude, 7);
  XCTAssertEqual(holes[1][1].coordinate.longitude, 8);
}

- (void)testDictionaryFromPosition {
  id mockPosition = OCMClassMock([GMSCameraPosition class]);
  NSValue *locationValue = [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(1, 2)];
  [(GMSCameraPosition *)[[mockPosition stub] andReturnValue:locationValue] target];
  [[[mockPosition stub] andReturnValue:@(2.0)] zoom];
  [[[mockPosition stub] andReturnValue:@(3.0)] bearing];
  [[[mockPosition stub] andReturnValue:@(75.0)] viewingAngle];
  NSDictionary *dictionary = [FLTGoogleMapJSONConversions dictionaryFromPosition:mockPosition];
  NSArray *targetArray = @[ @1, @2 ];
  XCTAssertEqualObjects(dictionary[@"target"], targetArray);
  XCTAssertEqualObjects(dictionary[@"zoom"], @2.0);
  XCTAssertEqualObjects(dictionary[@"bearing"], @3.0);
  XCTAssertEqualObjects(dictionary[@"tilt"], @75.0);
}

- (void)testDictionaryFromPoint {
  CGPoint point = CGPointMake(10, 20);
  NSDictionary *dictionary = [FLTGoogleMapJSONConversions dictionaryFromPoint:point];
  const CGFloat accuracy = 0.0001;
  XCTAssertEqualWithAccuracy([dictionary[@"x"] floatValue], point.x, accuracy);
  XCTAssertEqualWithAccuracy([dictionary[@"y"] floatValue], point.y, accuracy);
}

- (void)testDictionaryFromCoordinateBounds {
  XCTAssertNil([FLTGoogleMapJSONConversions dictionaryFromCoordinateBounds:nil]);

  GMSCoordinateBounds *bounds =
      [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(10, 20)
                                           coordinate:CLLocationCoordinate2DMake(30, 40)];
  NSDictionary *dictionary = [FLTGoogleMapJSONConversions dictionaryFromCoordinateBounds:bounds];
  NSArray *southwest = @[ @10, @20 ];
  NSArray *northeast = @[ @30, @40 ];
  XCTAssertEqualObjects(dictionary[@"southwest"], southwest);
  XCTAssertEqualObjects(dictionary[@"northeast"], northeast);
}

- (void)testCameraPostionFromDictionary {
  XCTAssertNil([FLTGoogleMapJSONConversions cameraPostionFromDictionary:nil]);

  NSDictionary *channelValue =
      @{@"target" : @[ @1, @2 ], @"zoom" : @3, @"bearing" : @4, @"tilt" : @5};

  GMSCameraPosition *cameraPosition =
      [FLTGoogleMapJSONConversions cameraPostionFromDictionary:channelValue];

  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(cameraPosition.target.latitude, 1, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.target.longitude, 2, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.zoom, 3, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.bearing, 4, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.viewingAngle, 5, accuracy);
}

- (void)testPointFromDictionary {
  XCTAssertNil([FLTGoogleMapJSONConversions cameraPostionFromDictionary:nil]);

  NSDictionary *dictionary = @{
    @"x" : @1,
    @"y" : @2,
  };

  CGPoint point = [FLTGoogleMapJSONConversions pointFromDictionary:dictionary];

  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(point.x, 1, accuracy);
  XCTAssertEqualWithAccuracy(point.y, 2, accuracy);
}

- (void)testCoordinateBoundsFromLatLongs {
  NSArray<NSNumber *> *latlong1 = @[ @1, @2 ];
  NSArray<NSNumber *> *latlong2 = @[ @(3), @(4) ];

  GMSCoordinateBounds *bounds =
      [FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:@[ latlong1, latlong2 ]];

  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(bounds.southWest.latitude, 1, accuracy);
  XCTAssertEqualWithAccuracy(bounds.southWest.longitude, 2, accuracy);
  XCTAssertEqualWithAccuracy(bounds.northEast.latitude, 3, accuracy);
  XCTAssertEqualWithAccuracy(bounds.northEast.longitude, 4, accuracy);
}

- (void)testMapViewTypeFromTypeValue {
  XCTAssertEqual(kGMSTypeNormal, [FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:@1]);
  XCTAssertEqual(kGMSTypeSatellite, [FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:@2]);
  XCTAssertEqual(kGMSTypeTerrain, [FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:@3]);
  XCTAssertEqual(kGMSTypeHybrid, [FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:@4]);
  XCTAssertEqual(kGMSTypeNone, [FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:@5]);
}

- (void)testCameraUpdateFromChannelValueNewCameraPosition {
  NSArray *channelValue = @[
    @"newCameraPosition", @{@"target" : @[ @1, @2 ], @"zoom" : @3, @"bearing" : @4, @"tilt" : @5}
  ];
  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValue];
  [[classMockCameraUpdate expect]
      setCamera:[FLTGoogleMapJSONConversions cameraPostionFromDictionary:channelValue[1]]];
  [classMockCameraUpdate stopMocking];
}

// TODO(cyanglaz): Fix the test for CameraUpdateFromChannelValue with the "NewLatlng" key.
// 2 approaches have been tried and neither worked for the tests.
//
// 1. Use OCMock to vefiry that [GMSCameraUpdate setTarget:] is triggered with the correct value.
// This class method conflicts with certain category method in OCMock, causing OCMock not able to
// disambigious them.
//
// 2. Directly verify the GMSCameraUpdate object returned by the method.
// The GMSCameraUpdate object returned from the method doesn't have any accessors to the "target"
// property. It can be used to update the "camera" property in GMSMapView. However, [GMSMapView
// moveCamera:] doesn't update the camera immediately. Thus the GMSCameraUpdate object cannot be
// verified.
//
// The code in below test uses the 2nd approach.
- (void)skip_testCameraUpdateFromChannelValueNewLatLong {
  NSArray *channelValue = @[ @"newLatLng", @[ @1, @2 ] ];

  GMSCameraUpdate *update = [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValue];

  GMSMapView *mapView = [[GMSMapView alloc]
      initWithFrame:CGRectZero
             camera:[GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(5, 6) zoom:1]];
  [mapView moveCamera:update];
  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(mapView.camera.target.latitude, 1,
                             accuracy);  // mapView.camera.target.latitude is still 5.
  XCTAssertEqualWithAccuracy(mapView.camera.target.longitude, 2,
                             accuracy);  // mapView.camera.target.longitude is still 6.
}

- (void)testCameraUpdateFromChannelValueNewLatLngBounds {
  NSArray<NSNumber *> *latlong1 = @[ @1, @2 ];
  NSArray<NSNumber *> *latlong2 = @[ @(3), @(4) ];
  GMSCoordinateBounds *bounds =
      [FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:@[ latlong1, latlong2 ]];

  NSArray *channelValue = @[ @"newLatLngBounds", @[ latlong1, latlong2 ], @20 ];
  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValue];

  [[classMockCameraUpdate expect] fitBounds:bounds withPadding:20];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromChannelValueNewLatLngZoom {
  NSArray *channelValue = @[ @"newLatLngZoom", @[ @1, @2 ], @3 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValue];

  [[classMockCameraUpdate expect] setTarget:CLLocationCoordinate2DMake(1, 2) zoom:3];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromChannelValueScrollBy {
  NSArray *channelValue = @[ @"scrollBy", @1, @2 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValue];

  [[classMockCameraUpdate expect] scrollByX:1 Y:2];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromChannelValueZoomBy {
  NSArray *channelValueNoPoint = @[ @"zoomBy", @1 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomBy:1];

  NSArray *channelValueWithPoint = @[ @"zoomBy", @1, @[ @2, @3 ] ];

  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValueWithPoint];

  [[classMockCameraUpdate expect] zoomBy:1 atPoint:CGPointMake(2, 3)];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromChannelValueZoomIn {
  NSArray *channelValueNoPoint = @[ @"zoomIn" ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomIn];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromChannelValueZoomOut {
  NSArray *channelValueNoPoint = @[ @"zoomOut" ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomOut];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromChannelValueZoomTo {
  NSArray *channelValueNoPoint = @[ @"zoomTo", @1 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromChannelValue:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomTo:1];
  [classMockCameraUpdate stopMocking];
}

@end
