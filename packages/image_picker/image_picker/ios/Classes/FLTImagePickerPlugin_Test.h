// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import image_picker.Test;"

#import <image_picker/FLTImagePickerPlugin.h>

/// Methods exposed for unit testing.
@interface FLTImagePickerPlugin ()

@property(copy, nonatomic) FlutterResult result;
- (void)handleSavedPathList:(NSArray *)pathList;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
