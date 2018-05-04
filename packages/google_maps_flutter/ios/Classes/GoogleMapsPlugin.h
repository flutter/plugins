// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"
#import "GoogleMapMarkerController.h"

@interface FLTGoogleMapsPlugin : NSObject<FlutterPlugin, FLTGoogleMapDelegate>
@end
