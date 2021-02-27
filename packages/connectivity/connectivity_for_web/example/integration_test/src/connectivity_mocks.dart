import 'dart:async';
import 'dart:html';

import 'package:flutter_test/flutter_test.dart';

/// A Fake implementation of the NetworkInformation API that allows
/// for external modification of its values.
/// 
/// Note that the DOM API works by internally mutating and broadcasting
/// 'change' events.
class FakeNetworkInformation extends Fake implements NetworkInformation {
  final StreamController<Event> _onChangeController = StreamController<Event>.broadcast();
  String? _type;
  String? _effectiveType;
  num? _downlink;
  int? _rtt;

  @override
  Stream<Event> get onChange => _onChangeController.stream;

  @override
  String? get type => _type;

  @override
  String? get effectiveType => _effectiveType;

  @override
  num? get downlink => _downlink;

  @override
  int? get rtt => _rtt;

  FakeNetworkInformation({
    String? type,
    String? effectiveType,
    num? downlink,
    int? rtt,
  }): this._type = type, this._effectiveType = effectiveType, this._downlink = downlink, this._rtt = rtt;

  /// Changes the desired values, and triggers the change event listener.
  Future<void> mockChangeValue({
    String? type,
    String? effectiveType,
    num? downlink,
    int? rtt,
  }) async {
    this._type = type;
    this._effectiveType = effectiveType;
    this._downlink = downlink;
    this._rtt = rtt;

    _onChangeController.add(Event('change'));
  }
}
