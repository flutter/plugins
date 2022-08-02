// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FFSFileSelectorPlugin.h"
#import "FFSFileSelectorPlugin_Test.h"
#import "messages.g.h"

@implementation FFSFileSelectorPlugin

#pragma mark - FFSFileSelectorApi

- (void)openFileSelectorWithConfig:(FFSFileSelectorConfig *)config
                        completion:(void (^)(NSArray<NSString *> * _Nullable,
                                             FlutterError * _Nullable))completion {
  if (self.pendingCompletion) {
    completion(nil, [FlutterError errorWithCode:@"error"
                                        message:@"There is already a pending file picker request."
                                        details:nil]);
    return;
  }

  UIDocumentPickerViewController *documentPicker = self.documentPickerViewControllerOverride ?:
  [[UIDocumentPickerViewController alloc] initWithDocumentTypes:config.utis
                                                         inMode:UIDocumentPickerModeImport];
  documentPicker.delegate = self;
  if (@available(iOS 11.0, *)) {
    documentPicker.allowsMultipleSelection = config.allowMultiSelection.boolValue;
  }

  UIViewController *presentingVC = self.presentingViewControllerOverride ?:
      UIApplication.sharedApplication.delegate.window.rootViewController;
  if (presentingVC) {
    [presentingVC presentViewController:documentPicker animated:YES completion:nil];
    self.pendingCompletion = completion;
  } else {
    completion(nil, [FlutterError errorWithCode:@"error"
                                        message:@"Missing root view controller."
                                        details:nil]);
  }
}

#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  FFSFileSelectorApiSetup(registrar.messenger, plugin);
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url {
  // This method is only called in iOS < 11.0.
  if (self.pendingCompletion) {
    self.pendingCompletion(@[ url.path ], nil);
    self.pendingCompletion = nil;
  }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
  if (self.pendingCompletion) {
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:urls.count];
    [urls enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
      [paths addObject:url.path];
    }];
    self.pendingCompletion(paths, nil);
    self.pendingCompletion = nil;
  }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
  if (self.pendingCompletion) {
    self.pendingCompletion(nil, nil);
    self.pendingCompletion = nil;
  }
}

@end
