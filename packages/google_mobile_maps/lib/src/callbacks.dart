// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

/// Mutable collection of [VoidCallback] instances, itself a [VoidCallback].
///
/// Additions and removals happening during a single [call] invocation do not
/// change who gets a callback until the next such invocation.
class VoidCallbacks {
  List<VoidCallback> _callbacks = <VoidCallback>[];

  void call() {
    final int length = _callbacks.length;
    if (length == 1) {
      _callbacks[0].call();
    } else if (0 < length) {
      final List<VoidCallback> clone = new List<VoidCallback>.from(_callbacks);
      for (VoidCallback callback in clone) {
        callback();
      }
    }
  }

  void add(VoidCallback callback) {
    _callbacks.add(callback);
  }

  void remove(VoidCallback callback) {
    _callbacks.remove(callback);
  }

  bool get isEmpty => _callbacks.isEmpty;

  bool get isNotEmpty => _callbacks.isNotEmpty;
}

/// Callback function taking a single argument.
typedef void ArgumentCallback<T>(T argument);

/// Mutable collection of [ArgumentCallback] instances, itself an [ArgumentCallback].
///
/// Additions and removals happening during a single [call] invocation do not
/// change who gets a callback until the next such invocation.
class ArgumentCallbacks<T> {
  List<ArgumentCallback<T>> _callbacks = <ArgumentCallback<T>>[];

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
  }

  void remove(ArgumentCallback<T> callback) {
    _callbacks.remove(callback);
  }

  bool get isEmpty => _callbacks.isEmpty;

  bool get isNotEmpty => _callbacks.isNotEmpty;
}
