// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Firebase/Firebase.h>

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