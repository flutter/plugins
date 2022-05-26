// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFileSelectorPlugin.h"
#import "messages.g.h"

@interface FLTFileSelectorPlugin () <UIDocumentPickerDelegate, FLTFileSelectorApi>

/**
 * The completion block of a FLTFileSelectorApi request.
 * It is saved and invoked later in a UIDocumentPickerDelegate method.
 */
@property(nonatomic) void (^pendingCompletion)(NSArray<NSString *> * _Nullable,
                                               FlutterError * _Nullable);

@end

@implementation FLTFileSelectorPlugin

#pragma mark - FLTFileSelectorApi

- (void)openFileSelectorWithConfig:(FLTFileSelectorConfig *)config
                        completion:(void (^)(NSArray<NSString *> * _Nullable,
                                             FlutterError * _Nullable))completion {
  if (self.pendingCompletion) {
    completion(nil, [FlutterError errorWithCode:@"error"
                                        message:@"There is already a pending file picker request."
                                        details:nil]);
    return;
  }

  UIDocumentPickerViewController *documentPicker =
  [[UIDocumentPickerViewController alloc] initWithDocumentTypes:config.utis
                                                         inMode:UIDocumentPickerModeImport];
  documentPicker.delegate = self;
  if (@available(iOS 11.0, *)) {
    documentPicker.allowsMultipleSelection = config.allowMultiSelection.boolValue;
  }

  UIViewController *rootVC = UIApplication.sharedApplication.delegate.window.rootViewController;
  if (rootVC) {
    [rootVC presentViewController:documentPicker animated:YES completion:nil];
    self.pendingCompletion = completion;
  } else {
    completion(nil, [FlutterError errorWithCode:@"error"
                                        message:@"Missing root view controller."
                                        details:nil]);
  }
}

#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFileSelectorPlugin *plugin = [[FLTFileSelectorPlugin alloc] init];
  FLTFileSelectorApiSetup(registrar.messenger, plugin);
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url {
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
