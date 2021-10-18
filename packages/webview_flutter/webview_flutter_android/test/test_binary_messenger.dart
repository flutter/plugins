import 'dart:ui';

import 'package:flutter/services.dart';

class TestBinaryMessenger implements BinaryMessenger {
  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) async {
    // Do nothing.
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) async {
    return StandardMessageCodec().encodeMessage(<Object?, Object?>{});
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    // Do nothing.
  }
}
