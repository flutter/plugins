// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

@interface UIImage (ios_platform_images)

/// Loads a UIImage from the embedded Flutter project's assets.
///
/// This method loads the Flutter asset that is appropriate for the current
/// screen.  If you are on a 2x retina device where usually `UIImage` would be
/// loading `@2x` assets, it will attempt to load the `2.0x` variant.  It will
/// load the standard image if it can't find the `2.0x` variant.
///
/// For example, if your Flutter project's `pubspec.yaml` lists "assets/foo.png"
/// and "assets/2.0x/foo.png", calling
/// `[UIImage flutterImageWithName:@"assets/foo.png"]` will load
/// "assets/2.0x/foo.png".
///
/// See also https://flutter.dev/docs/development/ui/assets-and-images
///
/// Note: We don't yet support images from package dependencies (ex.
/// `AssetImage('icons/heart.png', package: 'my_icons')`).
+ (UIImage*)flutterImageWithName:(NSString*)name;

@end
