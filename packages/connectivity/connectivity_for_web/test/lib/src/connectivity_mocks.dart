import 'dart:html';

import 'package:connectivity_for_web/src/generated/network_information_types.dart'
    as dom;

/// A Mock implementation of the NetworkInformation API that allows
/// for external modification of its values.
class MockNetworkInformation extends dom.NetworkInformation {
  @override
  String type;

  @override
  String effectiveType;

  @override
  num downlink;

  @override
  num rtt;

  @override
  EventListener onchange;

  /// Constructor of mocked instances...
  MockNetworkInformation({
    this.type,
    this.effectiveType,
    this.downlink,
    this.rtt,
  });

  /// Changes the desired values, and triggers the change event listener.
  void mockChangeValue({
    String type,
    String effectiveType,
    num downlink,
    num rtt,
  }) {
    this.type = type ?? this.type;
    this.effectiveType = effectiveType ?? this.effectiveType;
    this.downlink = downlink ?? this.downlink;
    this.rtt = rtt ?? this.rtt;

    onchange(Event('change'));
  }

  @override
  void addEventListener(String type, listener, [bool useCapture]) {}

  @override
  bool dispatchEvent(Event event) {
    return true;
  }

  @override
  Events get on => null;

  @override
  void removeEventListener(String type, listener, [bool useCapture]) {}
}
