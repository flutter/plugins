// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapsPlugin.h"

#pragma mark - GoogleMaps plugin implementation

@implementation FLTGoogleMapsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTGoogleMapFactory *googleMapFactory = [[FLTGoogleMapFactory alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:googleMapFactory
                                withId:@"plugins.flutter.io/google_maps"
      gestureRecognizersBlockingPolicy:
          FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded];
}

@end
