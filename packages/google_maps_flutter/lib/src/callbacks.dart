// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Callback function taking a single argument.
typedef void ArgumentCallback<T>(T argument);

/// Mutable collection of [ArgumentCallback] instances, itself an [ArgumentCallback].
///
/// Additions and removals happening during a single [call] invocation do not
/// change who gets a callback until the next such invocation.
class ArgumentCallbacks<T> {
  final List<ArgumentCallback<T>> _callbacks = <ArgumentCallback<T>>[];
  VoidCallback _onEmptyChanged;

  void call(T argument) {
    final int length = _callbacks.length;
    if (length == 1) {
      _callbacks[0].call(argument);
    } else if (0 < length) {
      for (ArgumentCallback<T> callback
          in new List<ArgumentCallback<T>>.from(_callbacks)) {
        callback(argument);
      }
    }
  }

  void add(ArgumentCallback<T> callback) {
    _callbacks.add(callback);
    if (_onEmptyChanged != null && _callbacks.length == 1) _onEmptyChanged();
  }

  void remove(ArgumentCallback<T> callback) {
    final bool removed = _callbacks.remove(callback);
    if (_onEmptyChanged != null && removed && _callbacks.isEmpty)
      _onEmptyChanged();
  }

  bool get isEmpty => _callbacks.isEmpty;

  bool get isNotEmpty => _callbacks.isNotEmpty;
}
