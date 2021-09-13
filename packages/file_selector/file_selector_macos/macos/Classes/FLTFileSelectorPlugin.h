// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import <FlutterMacOS/FlutterMacOS.h>

@interface FLTFileSelectorController : NSObject

@end

@protocol FLTPanelController < NSObject>

- (void)displaySavePanel:(nonnull NSSavePanel*)panel
          forWindow:(nullable NSWindow *)window
completionHandler:(void (^ _Nonnull)( NSURL *_Nullable URL))handler;

- (void)displayOpenPanel:(nonnull NSOpenPanel*)panel
          forWindow:(nullable NSWindow *)window
completionHandler:(void (^ _Nonnull)( NSArray<NSURL *> *_Nullable URLs))handler;

@end

/**
 * A FlutterPlugin to handle file choosing affordances. Owned by the FlutterViewController.
 * Responsible for creating and showing instances of NSSavePanel or NSOpenPanel and sending
 * selected file paths to flutter clients, via system channels.
 */
@interface FLTFileSelectorPlugin : NSObject <FlutterPlugin>

-(nonnull instancetype)initWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar panelController:(nonnull id<FLTPanelController>)panelController;

@end
