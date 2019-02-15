// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseCorePlugin.h"

#import <Firebase/Firebase.h>

static NSDictionary *getDictionaryFromFIROptions(FIROptions *options) {
  return @{
    @"googleAppID" : options.googleAppID ?: [NSNull null],
    @"bundleID" : options.bundleID ?: [NSNull null],
    @"GCMSenderID" : options.GCMSenderID ?: [NSNull null],
    @"APIKey" : options.APIKey ?: [NSNull null],
    @"clientID" : options.clientID ?: [NSNull null],
    @"trackingID" : options.trackingID ?: [NSNull null],
    @"projectID" : options.projectID ?: [NSNull null],
    @"androidClientID" : options.androidClientID ?: [NSNull null],
    @"databaseUrl" : options.databaseURL ?: [NSNull null],
    @"storageBucket" : options.storageBucket ?: [NSNull null],
    @"deepLinkURLScheme" : options.deepLinkURLScheme ?: [NSNull null],
  };
}

static NSDictionary *getDictionaryFromFIRApp(FIRApp *app) {
  return @{@"name" : app.name, @"options" : getDictionaryFromFIROptions(app.options)};
}

@implementation FLTFirebaseCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_core"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseCorePlugin *instance = [[FLTFirebaseCorePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"FirebaseApp#configure" isEqualToString:call.method]) {
    NSString *name = call.arguments[@"name"];
    NSDictionary *optionsDictionary = call.arguments[@"options"];
    FIROptions *options =
        [[FIROptions alloc] initWithGoogleAppID:optionsDictionary[@"googleAppID"]
                                    GCMSenderID:optionsDictionary[@"GCMSenderID"]];
    if (![optionsDictionary[@"bundleID"] isEqual:[NSNull null]])
      options.bundleID = optionsDictionary[@"bundleID"];
    if (![optionsDictionary[@"APIKey"] isEqual:[NSNull null]])
      options.APIKey = optionsDictionary[@"APIKey"];
    if (![optionsDictionary[@"clientID"] isEqual:[NSNull null]])
      options.clientID = optionsDictionary[@"clientID"];
    if (![optionsDictionary[@"trackingID"] isEqual:[NSNull null]])
      options.trackingID = optionsDictionary[@"trackingID"];
    if (![optionsDictionary[@"projectID"] isEqual:[NSNull null]])
      options.projectID = optionsDictionary[@"projectID"];
    if (![optionsDictionary[@"androidClientID"] isEqual:[NSNull null]])
      options.androidClientID = optionsDictionary[@"androidClientID"];
    if (![optionsDictionary[@"databaseURL"] isEqual:[NSNull null]])
      options.databaseURL = optionsDictionary[@"databaseURL"];
    if (![optionsDictionary[@"storageBucket"] isEqual:[NSNull null]])
      options.storageBucket = optionsDictionary[@"storageBucket"];
    if (![optionsDictionary[@"deepLinkURLScheme"] isEqual:[NSNull null]])
      options.deepLinkURLScheme = optionsDictionary[@"deepLinkURLScheme"];
    [FIRApp configureWithName:name options:options];
    result(nil);
  } else if ([@"FirebaseApp#allApps" isEqualToString:call.method]) {
    NSDictionary<NSString *, FIRApp *> *allApps = [FIRApp allApps];
    NSMutableArray *appsList = [NSMutableArray array];
    for (NSString *name in allApps) {
      FIRApp *app = allApps[name];
      [appsList addObject:getDictionaryFromFIRApp(app)];
    }
    result(appsList.count > 0 ? appsList : nil);
  } else if ([@"FirebaseApp#appNamed" isEqualToString:call.method]) {
    NSString *name = call.arguments;
    FIRApp *app = [FIRApp appNamed:name];
    result(getDictionaryFromFIRApp(app));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
