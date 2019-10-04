// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlutterAndroidLifecyclePlugin.h"
#import <flutter_android_lifecycle/flutter_android_lifecycle-Swift.h>

@implementation FlutterAndroidLifecyclePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAndroidLifecyclePlugin registerWithRegistrar:registrar];
}
@end
