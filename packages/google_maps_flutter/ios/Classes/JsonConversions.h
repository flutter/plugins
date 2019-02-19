// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

bool toBool(id json);

int toInt(id json);

double toDouble(id json);

float toFloat(id json);

CLLocationCoordinate2D toLocation(id json);

CGPoint toPoint(id json);
