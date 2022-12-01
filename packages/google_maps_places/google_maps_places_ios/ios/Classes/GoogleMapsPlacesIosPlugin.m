// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapsPlacesIosPlugin.h"
#if __has_include(<google_maps_places_ios/google_maps_places_ios-Swift.h>)
#import <google_maps_places_ios/google_maps_places_ios-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "google_maps_places_ios-Swift.h"
#endif

@implementation GoogleMapsPlacesIosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftGoogleMapsPlacesIosPlugin registerWithRegistrar:registrar];
}
@end
