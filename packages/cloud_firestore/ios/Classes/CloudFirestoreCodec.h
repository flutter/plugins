// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
//  CloudFirestoreCodec.h
//  cloud_firestore
//
//  Created by ananfang on 26/12/2017.
//  ananfang@gmail.com
//

#import <Flutter/Flutter.h>
#import <Firebase/Firebase.h>

/**
 A `FlutterMessageCodec` using the Flutter standard binary encoding.
 
 This codec is guaranteed to be compatible with the corresponding [FirestoreMessageCodec] in this package.
 on the Dart side. These parts of the Flutter SDK are evolved synchronously.
 
 Supported messages are acyclic values of these forms:
 
 - `nil` or `NSNull`
 - `NSNumber` (including their representation of Boolean values)
 - `FlutterStandardBigInteger`
 - `NSString`
 - `FlutterStandardTypedData`
 - `NSArray` of supported values
 - `NSDictionary` with supported keys and values
 - `NSDate`
 - `FIRFieldValue`
 - `FIRGeoPoint`
 - `FIRDocumentReference`
 
 On the Dart side, these values are represented as follows:
 
 - `nil` or `NSNull`: null
 - `NSNumber`: `bool`, `int`, or `double`, depending on the contained value.
 - `FlutterStandardBigInteger`: `int`
 - `NSString`: `String`
 - `FlutterStandardTypedData`: `Uint8List`, `Int32List`, `Int64List`, or `Float64List`
 - `NSArray`: `List`
 - `NSDictionary`: `Map`
 - `NSDate`: `DateTime`
 - `FIRFieldValue`: FieldValue.delete and FieldValue.serverTimestamp
 - `FIRGeoPoint`: `GeoPoint`
 - `FIRDocumentReference`: `DocumentReference`
 */
@interface CloudFirestoreMessageCodec: NSObject<FlutterMessageCodec>
@end

/**
 A `FlutterMethodCodec` using the Flutter standard binary encoding.
 
 This codec is guaranteed to be compatible with the corresponding [FirestoreMessageCodec] in this package.
 on the Dart side. These parts of the Flutter SDK are evolved synchronously.
 
 Values supported as method arguments and result payloads are those supported by
 `CloudFirestoreMessageCodec`.
 */
@interface CloudFirestoreMethodCodec: NSObject<FlutterMethodCodec>
@end

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
    CloudFirestoreFieldMap,
    CloudFirestoreFieldDateTime,
    CloudFirestoreFieldFieldValue,
    CloudFirestoreFieldGeoPoint,
    CloudFirestoreFieldDocumentReference
};

#pragma mark - CloudFirestoreCodecHelper
@interface CloudFirestoreCodecHelper: NSObject
+ (CloudFirestoreField)cloudFirestoreFieldForDataType:(FlutterStandardDataType)type;
+ (FlutterStandardDataType)flutterStandardDataTypeForField:(CloudFirestoreField)field;
+ (UInt8)elementSizeForFlutterStandardDataType:(FlutterStandardDataType)type;
+ (FlutterStandardTypedData *)typedDataWithData:(NSData *)data type:(FlutterStandardDataType)type;
@end

#pragma mark - CloudFirestoreWriter
@interface CloudFirestoreWriter: NSObject
+ (instancetype)writerWithData:(NSMutableData*)data;
- (void)writeByte:(UInt8)value;
- (void)writeValue:(id)value;
@end

#pragma mark - CloudFirestoreReader
@interface CloudFirestoreReader: NSObject
+ (instancetype)readerWithData:(NSData*)data;
- (BOOL)hasMore;
- (UInt8)readByte;
- (id)readValue;
@end
