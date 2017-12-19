// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Firebase/Firebase.h>

/**
 A `FlutterMethodCodec` using the Flutter standard binary encoding.

 This codec is guaranteed to be compatible with the corresponding
 [FirestoreMethodCodec](https://www.dartdocs.org/documentation/cloud_firestore/latest/cloud_firestore/FirestoreMethodCodec-class.html)
 on the Dart side. These parts of the Flutter SDK are evolved synchronously.

 Values supported as method arguments and result payloads are those supported by
 `FlutterStandardMessageCodec`.
 */
@interface FlutterStandardMethodCodec : NSObject<FlutterMethodCodec>
@end

/**
 A `FirestoreMessageCodec` using the Flutter standard binary encoding.

 This codec is guaranteed to be compatible with the corresponding
 [FirestoreMessageCodec](https://www.dartdocs.org/documentation/cloud_firestore/latest/cloud_firestore/FirestoreMessageCodec-class.html)
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
 - `FIRFieldValue`: `FieldValue`
 - `FIRGeoPoint`: `GeoPoint`
 - `FIRDocumentReference`: `DocumentReference`
 */
@interface FirestoreMessageCodec : NSObject<FlutterMessageCodec>
@end

typedef NS_ENUM(NSInteger, FirestoreField) {
  FirestoreFieldNil,
  FirestoreFieldTrue,
  FirestoreFieldFalse,
  FirestoreFieldInt32,
  FirestoreFieldInt64,
  FirestoreFieldIntHex,
  FirestoreFieldFloat64,
  FirestoreFieldString,
  FirestoreFieldUInt8Data,
  FirestoreFieldInt32Data,
  FirestoreFieldInt64Data,
  FirestoreFieldFloat64Data,
  FirestoreFieldList,
  FirestoreFieldMap,
  FirestoreFieldDateTime,
  FirestoreFieldFieldValue,
  FirestoreFieldGeoPoint,
  FirestoreFieldDocumentReference
};

namespace shell {
FirestoreField FirestoreFieldForDataType(FlutterStandardDataType type) {
  return (FirestoreField)(type + FirestoreFieldUInt8Data);
}
FlutterStandardDataType FlutterStandardDataTypeForField(FirestoreField field) {
  return (FlutterStandardDataType)(field - FirestoreFieldUInt8Data);
}
UInt8 elementSizeForFlutterStandardDataType(FlutterStandardDataType type) {
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
}  // namespace shell

@interface FirebaseWriter : NSObject
+ (instancetype)writerWithData:(NSMutableData*)data;
- (void)writeByte:(UInt8)value;
- (void)writeValue:(id)value;
@end

@interface FirebaseReader : NSObject
+ (instancetype)readerWithData:(NSData*)data;
- (BOOL)hasMore;
- (UInt8)readByte;
- (id)readValue;
@end