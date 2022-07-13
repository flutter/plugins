// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mock [MethodChannel] implementation for use in tests.
class MethodChannelMock {
  /// Creates a new instance with the specified channel name.
  ///
  /// This method channel will handle all method invocations specified by
  /// returning the value mapped to the method name key. If a delay is
  /// specified, results are returned after the delay has elapsed.
  MethodChannelMock({
    required String channelName,
    this.delay,
    required this.methods,
  }) : methodChannel = MethodChannel(channelName) {
    methodChannel.setMockMethodCallHandler(_handler);
  }

  final Duration? delay;
  final MethodChannel methodChannel;
  final Map<String, dynamic> methods;
  final List<MethodCall> log = <MethodCall>[];

  Future<dynamic> _handler(MethodCall methodCall) async {
    log.add(methodCall);

    if (!methods.containsKey(methodCall.method)) {
      throw MissingPluginException('No TEST implementation found for method '
          '${methodCall.method} on channel ${methodChannel.name}');
    }

    return Future<dynamic>.delayed(delay ?? Duration.zero, () {
      final dynamic result = methods[methodCall.method];
      if (result is Exception) {
        throw result;
      }

      return Future<dynamic>.value(result);
    });
  }
}
