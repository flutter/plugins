// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

class Blob {
  final Uint8List bytes;
  const Blob(this.bytes);

  @override
  bool operator ==(dynamic other) =>
      other is Blob && other.hashCode == hashCode;

  @override
  int get hashCode {
    return hashCodeIteration(0, bytes);
  }

  int hashCodeIteration(int hashBase, Iterable<int> byteList) {
    if (byteList.isNotEmpty) {
      return hashCodeIteration(
          hashValues(hashBase, byteList.first), byteList.skip(1));
    }
    return hashBase;
  }
}
