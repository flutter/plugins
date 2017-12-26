// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
//  CloudFirestoreCodec.h
//  cloud_firestore
//
//  Created by ananfang on 26/12/2017.
//

#import <Flutter/Flutter.h>

#pragma mark - Enum: CloudFirestoreField
typedef NS_ENUM(NSInteger, CloudFirestoreField) {
    CloudFirestoreFieldNil,
    CloudFirestoreFieldTrue,
    CloudFirestoreFieldFalse,
    CloudFirestoreFieldInt32,
    CloudFirestoreFieldInt64,
    CloudFirestoreFieldIntHex,
    CloudFirestoreFieldFloat64,
    CloudFirestoreFieldString,
    CloudFirestoreFieldUInt8Data,
    CloudFirestoreFieldInt32Data,
    CloudFirestoreFieldInt64Data,
    CloudFirestoreFieldFloat64Data,
    CloudFirestoreFieldList,
    CloudFirestoreFieldMap
};

#pragma mark - CloudFirestoreCodecHelper
@interface CloudFirestoreCodecHelper: NSObject
+ (CloudFirestoreField)cloudFirestoreFieldForDataType:(FlutterStandardDataType)type;
+ (FlutterStandardDataType)flutterStandardDataTypeForField:(CloudFirestoreField)field;
+ (UInt8)elementSizeForFlutterStandardDataType:(FlutterStandardDataType)type;
@end
