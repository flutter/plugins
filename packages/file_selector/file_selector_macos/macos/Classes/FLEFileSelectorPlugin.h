// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import <FlutterMacOS/FlutterMacOS.h>

/**
 * A FlutterPlugin to handle file choosing affordances. Owned by the FlutterViewController.
 * Responsible for creating and showing instances of NSSavePanel or NSOpenPanel and sending
 * selected file paths to flutter clients, via system channels.
 */
@interface FLEFileSelectorPlugin : NSObject <FlutterPlugin>

@end
