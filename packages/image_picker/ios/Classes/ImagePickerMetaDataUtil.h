// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
  FlutterImagePickerMIMETypePNG,
  FlutterImagePickerMIMETypeJPEG,
  FlutterImagePickerMIMETypeOther,
} FlutterImagePickerMIMEType;

extern NSString *const kFlutterImagePickerDefaultSuffix;
extern const FlutterImagePickerMIMEType kFlutterImagePickerMIMETypeDefault;

@interface ImagePickerMetaDataUtil : NSObject

// Retrieve MIME type by reading the image data. We currently only support some popular types.
+ (FlutterImagePickerMIMEType)getImageMIMETypeFromImageData:(NSData *)imageData;

// Get corresponding surfix from type.
+ (NSString *)imageTypeSuffixFromType:(FlutterImagePickerMIMEType)type;

+ (NSDictionary *)getMetaDataFromImageData:(NSData *)imageData;

+ (NSData *)updateMetaData:(NSDictionary *)metaData toImage:(NSData *)imageData;

+ (UIImageOrientation)getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
    (CGImagePropertyOrientation)cgImageOrientation;

// Converting UIImage to a NSData with the type proveide.
//
// The quality is for JPEG type only, it defaults to 1. It throws exception if setting a non-nil
// quality with type other than FlutterImagePickerMIMETypeJPEG. Converting UIImage to
// FlutterImagePickerMIMETypeGIF or FlutterImagePickerMIMETypeTIFF is not supported in iOS. This
// method throws exception if trying to do so.
+ (nonnull NSData *)convertImage:(nonnull UIImage *)image
                       usingType:(FlutterImagePickerMIMEType)type
                         quality:(nullable NSNumber *)quality;

@end

NS_ASSUME_NONNULL_END
