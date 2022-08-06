// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;

#import <OCMock/OCMock.h>
#import "PartiallyMockedMapView.h"

@interface GoogleMapsTests : XCTestCase
@end

@implementation GoogleMapsTests

- (void)testPlugin {
  FLTGoogleMapsPlugin *plugin = [[FLTGoogleMapsPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

- (void)testFrameObserver {
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  CGRect frame = CGRectMake(0, 0, 100, 100);
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
  FLTGoogleMapController *controller = [[FLTGoogleMapController alloc] initWithMapView:mapView
                                                                        viewIdentifier:0
                                                                             arguments:nil
                                                                             registrar:registrar];

  for (NSInteger i = 0; i < 10; ++i) {
    [controller view];
  }
  XCTAssertEqual(mapView.frameObserverCount, 1);

  mapView.frame = frame;
  XCTAssertEqual(mapView.frameObserverCount, 0);
}

@end
