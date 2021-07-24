// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;

#import <OCMock/OCMock.h>

@interface CameraOrientationTests : XCTestCase
@property(strong, nonatomic) id mockRegistrar;
@property(strong, nonatomic) id mockMessenger;
@end

@implementation CameraOrientationTests

- (void)setUp {
  [super setUp];
  self.mockRegistrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  self.mockMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  OCMStub([self.mockRegistrar messenger]).andReturn(self.mockMessenger);
}

- (void)testOrientationNotifications {
  id mockMessenger = self.mockMessenger;
  [mockMessenger setExpectationOrderMatters:YES];
  XCUIDevice.sharedDevice.orientation = UIDeviceOrientationPortrait;

  [CameraPlugin registerWithRegistrar:self.mockRegistrar];

  [self rotate:UIDeviceOrientationPortraitUpsideDown expectedChannelOrientation:@"portraitDown"];
  [self rotate:UIDeviceOrientationPortrait expectedChannelOrientation:@"portraitUp"];
  [self rotate:UIDeviceOrientationLandscapeRight expectedChannelOrientation:@"landscapeLeft"];
  [self rotate:UIDeviceOrientationLandscapeLeft expectedChannelOrientation:@"landscapeRight"];

  OCMReject([mockMessenger sendOnChannel:[OCMArg any] message:[OCMArg any]]);
  // No notification when orientation doesn't change.
  XCUIDevice.sharedDevice.orientation = UIDeviceOrientationLandscapeLeft;
  // No notification when flat.
  XCUIDevice.sharedDevice.orientation = UIDeviceOrientationFaceUp;
  // No notification when facedown.
  XCUIDevice.sharedDevice.orientation = UIDeviceOrientationFaceDown;

  OCMVerifyAll(mockMessenger);
}

- (void)rotate:(UIDeviceOrientation)deviceOrientation
    expectedChannelOrientation:(NSString*)channelOrientation {
  id mockMessenger = self.mockMessenger;
  XCTestExpectation* orientationExpectation = [self expectationWithDescription:channelOrientation];

  OCMExpect([mockMessenger
      sendOnChannel:[OCMArg any]
            message:[OCMArg checkWithBlock:^BOOL(NSData* data) {
              NSObject<FlutterMethodCodec>* codec = [FlutterStandardMethodCodec sharedInstance];
              FlutterMethodCall* methodCall = [codec decodeMethodCall:data];
              [orientationExpectation fulfill];
              return
                  [methodCall.method isEqualToString:@"orientation_changed"] &&
                  [methodCall.arguments isEqualToDictionary:@{@"orientation" : channelOrientation}];
            }]]);

  XCUIDevice.sharedDevice.orientation = deviceOrientation;
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

@end
