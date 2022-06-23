// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <image_picker_ios/FLTPHPickerSaveItemToPathOperation.h>

@interface FLTPHPickerSaveItemToPathOperation ()

- (void)completeOperationWithPath:(NSString *)savedPath;
- (void)setExecuting:(BOOL)isExecuting;

@end
