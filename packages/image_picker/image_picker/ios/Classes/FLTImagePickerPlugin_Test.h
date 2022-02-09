// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import image_picker.Test;"

#import <image_picker/FLTImagePickerPlugin.h>

/** Methods exposed for unit testing. */
@interface FLTImagePickerPlugin ()

/** The Flutter result callback use to report results back to Flutter App. */
@property(copy, nonatomic) FlutterResult result;

/**
 * Applies NSMutableArray on the FLutterResult.
 *
 * NSString must be returned by FlutterResult if the single image
 * mode is active. It is checked by maxImagesAllowed and
 * returns the first object of the pathlist.
 *
 * NSMutableArray must be returned by FlutterResult if the multi-image
 * mode is active. After the pathlist count is checked then it returns
 * the pathlist.
 *
 * @param pathList that should be applied to FlutterResult.
 */
- (void)handleSavedPathList:(NSArray *)pathList;

/**
 * Tells the delegate that the user cancelled the pick operation.
 *
 * Your delegate’s implementation of this method should dismiss the picker view
 * by calling the dismissModalViewControllerAnimated: method of the parent
 * view controller.
 *
 * Implementation of this method is optional, but expected.
 *
 * @param picker The controller object managing the image picker interface.
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

/**
 * Sets UIImagePickerController instances that will be used when a new
 * controller would normally be created. Each call to
 * createImagePickerController will remove the current first element from
 * the array.
 *
 * Should be used for testing purposes only.
 */
- (void)setImagePickerControllerOverrides:
    (NSArray<UIImagePickerController *> *)imagePickerControllers;

@end
