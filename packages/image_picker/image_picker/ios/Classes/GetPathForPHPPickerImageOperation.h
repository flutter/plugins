// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <PhotosUI/PhotosUI.h>

#import "FLTImagePickerImageUtil.h"
#import "FLTImagePickerMetaDataUtil.h"
#import "FLTImagePickerPhotoAssetUtil.h"

@interface GetPathForPHPPickerImageOperation : NSOperation

- (instancetype)initWithResult:(PHPickerResult *)result
                      pathlist:(NSMutableArray *)pathList
                     maxHeight:(NSNumber *)maxHeight
                      maxWidth:(NSNumber *)maxWidth
           desiredImageQuality:(NSNumber *)desiredImageQuality
                         index:(NSInteger)index API_AVAILABLE(ios(14));

@end
