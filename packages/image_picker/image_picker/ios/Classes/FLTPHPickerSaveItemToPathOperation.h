// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <PhotosUI/PhotosUI.h>
#import "FLTImagePickerImageUtil.h"
#import "FLTImagePickerMetaDataUtil.h"
#import "FLTImagePickerPhotoAssetUtil.h"
/*!
 @class FLTPHPickerSaveItemToPathOperation
 @brief The FLTPHPickerSaveItemToPathOperation class
 @discussion This class was implemented to handle saved media paths and populate the pathList
 with the final result by using GetSavedPath type block.
 @superclass SuperClass: NSOperation\n
 @helps It helps FLTImagePickerPlugin class.
 */
@interface FLTPHPickerSaveItemToPathOperation : NSOperation

- (instancetype)initWithResult:(PHPickerResult *)result
                maxImageHeight:(NSNumber *)maxHeight
                 maxImageWidth:(NSNumber *)maxWidth
           desiredImageQuality:(NSNumber *)desiredImageQuality
                savedPathBlock:(void (^)(NSString *))savedPathBlock API_AVAILABLE(ios(14));

@end
