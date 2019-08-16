// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// Mixin for classes that own `StreamSubscription`s and expose an API for
/// disposing of themselves by cancelling the subscriptions
abstract class StreamSubscriberMixin<T> {
  List<StreamSubscription<T>> _subscriptions = <StreamSubscription<T>>[];

  /// Listens to a stream and saves it to the list of subscriptions.
  void listen(Stream<T> stream, void onData(T data), {Function onError}) {
    if (stream != null) {
      _subscriptions.add(stream.listen(onData, onError: onError));
    }
  }

  /// Cancels all streams that were previously added with listen().
  void cancelSubscriptions() {
    _subscriptions
        .forEach((StreamSubscription<T> subscription) => subscription.cancel());
  }
}
