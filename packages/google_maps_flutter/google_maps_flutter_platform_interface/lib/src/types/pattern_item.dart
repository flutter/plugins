// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart' show immutable;

/// Item used in the stroke pattern for a Polyline.
@immutable
class PatternItem {
  const PatternItem._(this._json);

  /// A dot used in the stroke pattern for a [Polyline].
  static const PatternItem dot = PatternItem._(<dynamic>['dot']);

  /// A dash used in the stroke pattern for a [Polyline].
  ///
  /// [length] has to be non-negative.
  static PatternItem dash(double length) {
    assert(length >= 0.0);
    return PatternItem._(<dynamic>['dash', length]);
  }

  /// A gap used in the stroke pattern for a [Polyline].
  ///
  /// [length] has to be non-negative.
  static PatternItem gap(double length) {
    assert(length >= 0.0);
    return PatternItem._(<dynamic>['gap', length]);
  }

  final dynamic _json;

  /// Converts this object to something serializable in JSON.
  dynamic toJson() => _json;
}
