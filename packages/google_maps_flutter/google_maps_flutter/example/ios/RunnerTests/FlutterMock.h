// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import Flutter;

NS_ASSUME_NONNULL_BEGIN

@interface MockRegistrar : NSObject <FlutterPluginRegistrar>
@end

@interface MockBinaryMessenger : NSObject <FlutterBinaryMessenger>
@end

@interface MockTextureRegistry : NSObject <FlutterTextureRegistry>
@end

NS_ASSUME_NONNULL_END
