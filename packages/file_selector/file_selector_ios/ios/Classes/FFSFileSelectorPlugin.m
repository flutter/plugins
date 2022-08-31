// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FFSFileSelectorPlugin.h"
#import "FFSFileSelectorPlugin_Test.h"
#import "messages.g.h"

#import <objc/runtime.h>

@implementation FFSFileSelectorPlugin

#pragma mark - FFSFileSelectorApi

- (void)openFileSelectorWithConfig:(FFSFileSelectorConfig *)config
                        completion:(void (^)(NSArray<NSString *> *_Nullable,
                                             FlutterError *_Nullable))completion {
  UIDocumentPickerViewController *documentPicker =
      self.documentPickerViewControllerOverride
          ?: [[UIDocumentPickerViewController alloc]
                 initWithDocumentTypes:config.utis
                                inMode:UIDocumentPickerModeImport];
  documentPicker.delegate = self;
  if (@available(iOS 11.0, *)) {
    documentPicker.allowsMultipleSelection = config.allowMultiSelection.boolValue;
  }

  UIViewController *presentingVC =
      self.presentingViewControllerOverride
          ?: UIApplication.sharedApplication.delegate.window.rootViewController;
  if (presentingVC) {
    objc_setAssociatedObject(documentPicker, @selector(openFileSelectorWithConfig:completion:),
                             completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [presentingVC presentViewController:documentPicker animated:YES completion:nil];
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

// This method is only called in iOS < 11.0. The new codepath is
// documentPicker:didPickDocumentsAtURLs:, implemented below.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentAtURL:(NSURL *)url {
  [self sendBackResults:@[ url.path ] error:nil forPicker:controller];
}
#pragma clang diagnostic pop

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
  NSMutableArray *paths = [NSMutableArray arrayWithCapacity:urls.count];
  for (NSURL *url in urls) {
    [paths addObject:url.path];
  };
  [self sendBackResults:paths error:nil forPicker:controller];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
  [self sendBackResults:@[] error:nil forPicker:controller];
}

#pragma mark - Helper Methods

- (void)sendBackResults:(NSArray<NSString *> *)results
                  error:(FlutterError *)error
              forPicker:(UIDocumentPickerViewController *)picker {
  void (^completionBlock)(NSArray<NSString *> *, FlutterError *) =
      objc_getAssociatedObject(picker, @selector(openFileSelectorWithConfig:completion:));
  if (completionBlock) {
    completionBlock(results, error);
    objc_setAssociatedObject(picker, @selector(openFileSelectorWithConfig:completion:), nil,
                             OBJC_ASSOCIATION_ASSIGN);
  }
}

@end
