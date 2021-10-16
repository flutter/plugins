// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import camera.Test;
@import XCTest;
@import Flutter;

#import <OCMock/OCMock.h>

@interface CameraOrientationTests : XCTestCase
@property(strong, nonatomic) id mockMessenger;
@property(strong, nonatomic) CameraPlugin *cameraPlugin;
@end

@implementation CameraOrientationTests

- (void)setUp {
  [super setUp];

  self.mockMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.cameraPlugin = [[CameraPlugin alloc] initWithRegistry:nil messenger:self.mockMessenger];
}

- (void)testOrientationNotifications {
  id mockMessenger = self.mockMessenger;
  [mockMessenger setExpectationOrderMatters:YES];

  [self rotate:UIDeviceOrientationPortraitUpsideDown expectedChannelOrientation:@"portraitDown"];
  [self rotate:UIDeviceOrientationPortrait expectedChannelOrientation:@"portraitUp"];
  [self rotate:UIDeviceOrientationLandscapeRight expectedChannelOrientation:@"landscapeLeft"];
  [self rotate:UIDeviceOrientationLandscapeLeft expectedChannelOrientation:@"landscapeRight"];

  OCMReject([mockMessenger sendOnChannel:[OCMArg any] message:[OCMArg any]]);

  // No notification when flat.
  [self.cameraPlugin
      orientationChanged:[self createMockNotificationForOrientation:UIDeviceOrientationFaceUp]];
  // No notification when facedown.
  [self.cameraPlugin
      orientationChanged:[self createMockNotificationForOrientation:UIDeviceOrientationFaceDown]];

  OCMVerifyAll(mockMessenger);
}

- (void)rotate:(UIDeviceOrientation)deviceOrientation
    expectedChannelOrientation:(NSString *)channelOrientation {
  id mockMessenger = self.mockMessenger;
  XCTestExpectation *orientationExpectation = [self expectationWithDescription:channelOrientation];

  OCMExpect([mockMessenger
      sendOnChannel:[OCMArg any]
            message:[OCMArg checkWithBlock:^BOOL(NSData *data) {
              NSObject<FlutterMethodCodec> *codec = [FlutterStandardMethodCodec sharedInstance];
              FlutterMethodCall *methodCall = [codec decodeMethodCall:data];
              [orientationExpectation fulfill];
              return
                  [methodCall.method isEqualToString:@"orientation_changed"] &&
                  [methodCall.arguments isEqualToDictionary:@{@"orientation" : channelOrientation}];
            }]]);

  [self.cameraPlugin
      orientationChanged:[self createMockNotificationForOrientation:deviceOrientation]];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (NSNotification *)createMockNotificationForOrientation:(UIDeviceOrientation)deviceOrientation {
  UIDevice *mockDevice = OCMClassMock([UIDevice class]);
  OCMStub([mockDevice orientation]).andReturn(deviceOrientation);

  return [NSNotification notificationWithName:@"orientation_test" object:mockDevice];
}

@end
