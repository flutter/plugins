// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter;
@import XCTest;

#import "FlutterMock.h"

@interface GoogleMapsTests : XCTestCase
@end

@implementation GoogleMapsTests

- (void)testPlugin {
  FLTGoogleMapsPlugin *plugin = [[FLTGoogleMapsPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

- (void)testObserveCamera {
  XCTestExpectation *viewExpectation = [self expectationWithDescription:@"View loaded"];

  dispatch_async(dispatch_queue_create("", 0), ^{
    [self waitForExpectations:@[viewExpectation] timeout:1];
  });

  MockRegistrar *object = [[MockRegistrar alloc] init];
  FLTGoogleMapController *controller = [[FLTGoogleMapController alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                      viewIdentifier:0
                                                                           arguments:@{}
                                                                           registrar:object];

  for (NSInteger i = 0; i < 10000; ++i) {
    [controller view];
  }
  [[controller view] setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, 0, 0)] forKey:@"frame"];

  [viewExpectation fulfill];
}

@end
