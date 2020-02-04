// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWKUIDelegate : NSObject <WKUIDelegate>

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel;

@end

NS_ASSUME_NONNULL_END
