// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

@interface FLTImagePickerPlugin : NSObject <FlutterPlugin>

+ (void)getSize:(CGSize*)size drawRect:(CGRect*)drawRect
   originalSize:(CGSize)originalSize
       maxWidth:(NSNumber*)maxWidth
      maxHeight:(NSNumber*)maxHeight
           crop:(BOOL)crop;

@end
