import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class EventChannelMock {
  final MethodChannel _methodChannel;
  final Stream stream;
  final log = <MethodCall>[];

  StreamSubscription _streamSubscription;

  EventChannelMock({
    @required String channelName,
    @required this.stream,
  }) : _methodChannel = MethodChannel(channelName) {
    _methodChannel.setMockMethodCallHandler(_handler);
  }

  Future _handler(MethodCall methodCall) {
    log.add(methodCall);

    switch (methodCall.method) {
      case 'listen':
        _onListen();
        break;
      case 'cancel':
        _onCancel();
        break;
      default:
        return null;
    }

    return Future.value();
  }

  void _onListen() {
    _streamSubscription = stream.handleError((error) {
      ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        _methodChannel.name,
        _createErrorEnvelope(error),
            (_) {},
      );
    }).listen((event) {
      ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        _methodChannel.name,
        _createSuccessEnvelope(event),
            (_) {},
      );
    });
  }

  void _onCancel() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
  }

  ByteData _createErrorEnvelope(Exception error) {
    var code = "UNKNOWN_EXCEPTION";
    String message;
    dynamic details;

    if (error is PlatformException) {
      code = error.code;
      message = error.message;
      details = error.details;
    }

    return const StandardMethodCodec()
        .encodeErrorEnvelope(code: code, message: message, details: details);
  }

  ByteData _createSuccessEnvelope(dynamic event) {
    return const StandardMethodCodec().encodeSuccessEnvelope(event);
  }
}