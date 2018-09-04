// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

class ArrayUnion {
  final List<dynamic> value;
  ArrayUnion(this.value);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! ArrayUnion) return false;
    final ArrayUnion typedOther = other;
    final ListEquality<dynamic> eq = const ListEquality<dynamic>();
    return eq.equals(value, typedOther.value);
  }

  @override
  int get hashCode => hashList(value);
}

class ArrayRemove {
  final List<dynamic> value;
  ArrayRemove(this.value);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! ArrayRemove) return false;
    final ArrayRemove typedOther = other;
    final ListEquality<dynamic> eq = const ListEquality<dynamic>();
    return eq.equals(value, typedOther.value);
  }

  @override
  int get hashCode => hashList(value);
}
