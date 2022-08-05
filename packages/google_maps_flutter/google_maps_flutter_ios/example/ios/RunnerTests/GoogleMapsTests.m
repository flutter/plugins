// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "PartiallyMockedMapView.h"

@interface FLTGoogleMapFactory (Test)
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;
@end

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

- (void)testMapsServiceSync {
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FLTGoogleMapFactory *factory1 = [[FLTGoogleMapFactory alloc] initWithRegistrar:registrar];
  XCTAssertNotNil(factory1.sharedMapServices);
  FLTGoogleMapFactory *factory2 = [[FLTGoogleMapFactory alloc] initWithRegistrar:registrar];
  // Test pointer equality, should be same retained singleton +[GMSServices sharedServices] object.
  // Retaining the opaque object should be enough to avoid multiple internal initializations,
  // but don't test the internals of the GoogleMaps API. Assume that it does what is documented.
  // https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_services#a436e03c32b1c0be74e072310a7158831
  XCTAssertEqual(factory1.sharedMapServices, factory2.sharedMapServices);
}

@end
