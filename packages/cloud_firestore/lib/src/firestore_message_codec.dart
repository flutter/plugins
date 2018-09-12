// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

@visibleForTesting
class FirestoreMessageCodec extends StandardMessageCodec {
  const FirestoreMessageCodec();

  static const int _kDateTime = 128;
  static const int _kGeoPoint = 129;
  static const int _kDocumentReference = 130;
  static const int _kBlob = 131;
  static const int _kArrayUnion = 132;
  static const int _kArrayRemove = 133;
  static const int _kDelete = 134;
  static const int _kServerTimestamp = 135;

  static const Map<FieldValueType, int> _kFieldValueCodes =
      <FieldValueType, int>{
    FieldValueType.arrayUnion: _kArrayUnion,
    FieldValueType.arrayRemove: _kArrayRemove,
    FieldValueType.delete: _kDelete,
    FieldValueType.serverTimestamp: _kServerTimestamp,
  };

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is DateTime) {
      buffer.putUint8(_kDateTime);
      buffer.putInt64(value.millisecondsSinceEpoch);
    } else if (value is GeoPoint) {
      buffer.putUint8(_kGeoPoint);
      buffer.putFloat64(value.latitude);
      buffer.putFloat64(value.longitude);
    } else if (value is DocumentReference) {
      buffer.putUint8(_kDocumentReference);
      final List<int> appName = utf8.encoder.convert(value.firestore.app.name);
      writeSize(buffer, appName.length);
      buffer.putUint8List(appName);
      final List<int> bytes = utf8.encoder.convert(value.path);
      writeSize(buffer, bytes.length);
      buffer.putUint8List(bytes);
    } else if (value is Blob) {
      buffer.putUint8(_kBlob);
      writeSize(buffer, value.bytes.length);
      buffer.putUint8List(value.bytes);
    } else if (value is FieldValue) {
      final int code = _kFieldValueCodes[value.type];
      assert(code != null);
      buffer.putUint8(code);
      if (value.value != null) writeValue(buffer, value.value);
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  dynamic readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case _kDateTime:
        return DateTime.fromMillisecondsSinceEpoch(buffer.getInt64());
      case _kGeoPoint:
        return GeoPoint(buffer.getFloat64(), buffer.getFloat64());
      case _kDocumentReference:
        final int appNameLength = readSize(buffer);
        final String appName =
            utf8.decoder.convert(buffer.getUint8List(appNameLength));
        final FirebaseApp app = FirebaseApp(name: appName);
        final Firestore firestore = Firestore(app: app);
        final int pathLength = readSize(buffer);
        final String path =
            utf8.decoder.convert(buffer.getUint8List(pathLength));
        return firestore.document(path);
      case _kBlob:
        final int length = readSize(buffer);
        final List<int> bytes = buffer.getUint8List(length);
        return Blob(bytes);
      case _kArrayUnion:
        final List<dynamic> value = readValue(buffer);
        return FieldValue.arrayUnion(value);
      case _kArrayRemove:
        final List<dynamic> value = readValue(buffer);
        return FieldValue.arrayRemove(value);
      case _kDelete:
        return FieldValue.delete();
      case _kServerTimestamp:
        return FieldValue.serverTimestamp();
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}
