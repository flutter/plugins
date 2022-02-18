// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTSavePhotoDelegate.h"

/**
 API exposed for unit tests.
 */
@interface FLTSavePhotoDelegate ()

/// Handler to write captured photo data into a file.
/// @param error the capture error.
/// @param photoDataProvider a closure that provides photo data.
- (void)handlePhotoCaptureResultWithError:(NSError *)error
                        photoDataProvider:(NSData * (^)(void))photoDataProvider;
@end
