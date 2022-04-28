// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FTLFileSelectorPlugin.h"

@interface FTLFileSelectorPlugin () <UIDocumentPickerDelegate>

@property(nonatomic) FlutterResult pendingResult;

@end

@implementation FTLFileSelectorPlugin

- (void)openPickerWithCall:(FlutterMethodCall *)call
                    result:(FlutterResult)result
       allowMultiSelection:(BOOL)allowMultiSelection {
  NSDictionary *acceptedTypes = call.arguments[@"acceptedTypes"];
  UIDocumentPickerViewController *documentPicker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:acceptedTypes[@"UTIs"]
                                                             inMode:UIDocumentPickerModeImport];
  documentPicker.delegate = self;
  if (@available(iOS 11.0, *)) {
    documentPicker.allowsMultipleSelection = allowMultiSelection;
  }

  UIViewController *rootVC = UIApplication.sharedApplication.delegate.window.rootViewController;
  if (rootVC) {
    [rootVC presentViewController:documentPicker animated:YES completion:nil];
    self.pendingResult = result;
  } else {
    result([FlutterError errorWithCode:@"error"
                               message:@"Missing root view controller."
                               details:nil]);
  }
}

#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/file_selector_ios"
                                  binaryMessenger:registrar.messenger];
  FTLFileSelectorPlugin *plugin = [[FTLFileSelectorPlugin alloc] init];
  [registrar addMethodCallDelegate:plugin channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"openFile" isEqualToString:call.method]) {
    [self openPickerWithCall:call result:result allowMultiSelection:NO];
  } else if ([@"openFiles" isEqualToString:call.method]) {
    [self openPickerWithCall:call result:result allowMultiSelection:YES];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentAtURL:(NSURL *)url {
  // This method is only called in iOS prior to version 13.
  if (self.pendingResult) {
    self.pendingResult(@[ url.path ]);
    self.pendingResult = nil;
  }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
  if (self.pendingResult) {
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:urls.count];
    [urls enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
      [paths addObject:url.path];
    }];
    self.pendingResult(paths);
    self.pendingResult = nil;
  }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
  if (self.pendingResult) {
    self.pendingResult(nil);
    self.pendingResult = nil;
  }
}

@end
