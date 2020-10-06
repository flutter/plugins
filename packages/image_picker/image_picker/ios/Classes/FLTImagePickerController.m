// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTImagePickerController.h"
#import "FLTImagePickerPlugin.h"

@interface FLTImagePickerController ()

@property(weak, nonatomic) FLTImagePickerPlugin *plugin;

@end

@implementation FLTImagePickerController

- (instancetype)initWithPlugin:(FLTImagePickerPlugin *)plugin {
  self = [super init];
  if (self) {
    self.plugin = plugin;
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.delegate = plugin;
  }
  return self;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  // When image picker is dismissed by the swiping down gesture,
  // the delegate method [imagePickerControllerDidCancel:] will not be called,
  // which results the method channel not getting responses.
  // This [viewWillDisappear:] will handle such cases.
  [self.plugin handleImagePickerControllerDismissed];
}

@end
