// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
//  CloudFirestoreCodec.m
//  cloud_firestore
//
//  Created by ananfang on 26/12/2017.
//

#import "CloudFirestoreCodec.h"

#pragma mark - CloudFirestoreCodecHelper
@implementation CloudFirestoreCodecHelper
+ (CloudFirestoreField)cloudFirestoreFieldForDataType:(FlutterStandardDataType)type {
    return (CloudFirestoreField)(type + CloudFirestoreFieldUInt8Data);
}

+ (FlutterStandardDataType)flutterStandardDataTypeForField:(CloudFirestoreField)field {
    return (FlutterStandardDataType)(field - CloudFirestoreFieldUInt8Data);
}

+ (UInt8)elementSizeForFlutterStandardDataType:(FlutterStandardDataType)type {
    switch (type) {
        case FlutterStandardDataTypeUInt8:
            return 1;
        case FlutterStandardDataTypeInt32:
            return 4;
        case FlutterStandardDataTypeInt64:
            return 8;
        case FlutterStandardDataTypeFloat64:
            return 8;
    }
}
@end
