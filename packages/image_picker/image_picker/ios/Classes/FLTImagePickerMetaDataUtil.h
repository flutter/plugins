// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
  FLTImagePickerMIMETypePNG,
  FLTImagePickerMIMETypeJPEG,
  FLTImagePickerMIMETypeGIF,
  FLTImagePickerMIMETypeOther,
} FLTImagePickerMIMEType;

extern NSString *const kFLTImagePickerDefaultSuffix;
extern const FLTImagePickerMIMEType kFLTImagePickerMIMETypeDefault;

@interface FLTImagePickerMetaDataUtil : NSObject

// Retrieve MIME type by reading the image data. We currently only support some popular types.
+ (FLTImagePickerMIMEType)getImageMIMETypeFromImageData:(NSData *)imageData;

// Get corresponding surfix from type.
+ (nullable NSString *)imageTypeSuffixFromType:(FLTImagePickerMIMEType)type;

+ (NSDictionary *)getMetaDataFromImageData:(NSData *)imageData;

+ (NSData *)updateMetaData:(NSDictionary *)metaData toImage:(NSData *)imageData;

// Converting UIImage to a NSData with the type proveide.
//
// The quality is for JPEG type only, it defaults to 1. It throws exception if setting a non-nil
// quality with type other than FLTImagePickerMIMETypeJPEG. Converting UIImage to
// FLTImagePickerMIMETypeGIF or FLTImagePickerMIMETypeTIFF is not supported in iOS. This
// method throws exception if trying to do so.
+ (nonnull NSData *)convertImage:(nonnull UIImage *)image
                       usingType:(FLTImagePickerMIMEType)type
                         quality:(nullable NSNumber *)quality;

@end

NS_ASSUME_NONNULL_END
