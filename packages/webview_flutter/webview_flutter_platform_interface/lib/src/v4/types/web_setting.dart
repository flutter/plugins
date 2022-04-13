// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// A single setting for configuring a WebViewPlatform which may be absent.
@immutable
class WebSetting<T> {
  /// Constructs an absent setting instance.
  ///
  /// The [isPresent] field for the instance will be false.
  ///
  /// Accessing [value] for an absent instance will throw.
  const WebSetting.absent()
      : _value = null,
        isPresent = false;

  /// Constructs a setting of the given `value`.
  ///
  /// The [isPresent] field for the instance will be true.
  const WebSetting.of(T value)
      : _value = value,
        isPresent = true;

  final T? _value;

  /// The setting's value.
  ///
  /// Throws if [WebSetting.isPresent] is false.
  T get value {
    if (!isPresent) {
      throw StateError('Cannot access a value of an absent WebSetting');
    }
    assert(isPresent);
    // The intention of this getter is to return T whether it is nullable or
    // not whereas _value is of type T? since _value can be null even when
    // T is not nullable (when isPresent == false).
    //
    // We promote _value to T using `as T` instead of `!` operator to handle
    // the case when _value is legitimately null (and T is a nullable type).
    // `!` operator would always throw if _value is null.
    return _value as T;
  }

  /// True when this web setting instance contains a value.
  ///
  /// When false the [WebSetting.value] getter throws.
  final bool isPresent;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is WebSetting<T> &&
        other.isPresent == isPresent &&
        other._value == _value;
  }

  @override
  int get hashCode => Object.hash(_value, isPresent);
}
