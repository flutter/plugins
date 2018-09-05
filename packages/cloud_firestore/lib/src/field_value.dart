// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

enum FieldValueType { arrayUnion, arrayRemove, delete, serverTimestamp }

class FieldValue {
  final FieldValueType type;
  final dynamic value;

  FieldValue._(this.type, this.value);

  static FieldValue arrayUnion(List<dynamic> elements) =>
      FieldValue._(FieldValueType.arrayUnion, elements);

  static FieldValue arrayRemove(List<dynamic> elements) =>
      FieldValue._(FieldValueType.arrayRemove, elements);

  static FieldValue delete() => FieldValue._(FieldValueType.delete, null);

  static FieldValue serverTimestamp() =>
      FieldValue._(FieldValueType.serverTimestamp, null);
}
