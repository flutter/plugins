// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <PhotosUI/PhotosUI.h>

#import "FLTImagePickerImageUtil.h"
#import "FLTImagePickerMetaDataUtil.h"
#import "FLTImagePickerPhotoAssetUtil.h"

/*!
 @class FLTPHPickerSaveImageToPathOperation

 @brief The FLTPHPickerSaveImageToPathOperation class

 @discussion    This class was implemented to handle saved image paths and populate the pathList
 with the final result by using GetSavedPath type block.

 @superclass SuperClass: NSOperation\n
 @helps It helps FLTImagePickerPlugin class.
 */
@interface FLTPHPickerSaveItemToPathOperation : NSOperation

- (instancetype)initWithResult:(PHPickerResult *)result
                maxImageHeight:(NSNumber *)maxImageHeight
                 maxImageWidth:(NSNumber *)maxImageWidth
           desiredImageQuality:(NSNumber *)desiredImageQuality
                savedPathBlock:(void (^)(NSString *))savedPathBlock API_AVAILABLE(ios(14));

- (instancetype)initWithAsset:(PHAsset *)asset
               maxImageHeight:(NSNumber *)maxImageHeight
                maxImageWidth:(NSNumber *)maxImageWidth
          desiredImageQuality:(NSNumber *)desiredImageQuality
               savedPathBlock:(void (^)(NSString *))savedPathBlock;

@end

/*!
 @class FLTPHPickerSaveImageToPathOperationFactory

 @brief The FLTPHPickerSaveImageToPathOperationFactory class

 @discussion This class was implemented to assist in creating instances of the
 FLTPHPickerSaveItemToPathOperation class. This factoy is required for the operation's creation to
 be stubbable in unit tests.

 @superclass SuperClass: NSObject\n
 @helps It helps FLTImagePickerPlugin class.
 */
@interface FLTPHPickerSaveItemToPathOperationFactory : NSObject

+ (FLTPHPickerSaveItemToPathOperation *)operationWithResult:(PHPickerResult *)result
                                             maxImageHeight:(NSNumber *)maxImageHeight
                                              maxImageWidth:(NSNumber *)maxImageWidth
                                        desiredImageQuality:(NSNumber *)desiredImageQuality
                                             savedPathBlock:(void (^)(NSString *))savedPathBlock
    API_AVAILABLE(ios(14));

+ (FLTPHPickerSaveItemToPathOperation *)operationWithAsset:(PHAsset *)asset
                                            maxImageHeight:(NSNumber *)maxImageHeight
                                             maxImageWidth:(NSNumber *)maxImageWidth
                                       desiredImageQuality:(NSNumber *)desiredImageQuality
                                            savedPathBlock:(void (^)(NSString *))savedPathBlock;

@end
