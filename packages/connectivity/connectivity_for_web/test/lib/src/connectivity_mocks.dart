import 'dart:html';

import 'package:mockito/mockito.dart';

/// A Mock implementation of the NetworkInformation API that allows
/// for external modification of its values.
class MockNetworkInformation extends Mock implements NetworkInformation {
  /// The callback that will fire after the network information values change.
  Function onchange;

  /// Changes the desired values, and triggers the change event listener.
  void mockChangeValue({
    String type,
    String effectiveType,
    num downlink,
    num rtt,
  }) async {
    when(this.type).thenAnswer((_) => type);
    when(this.effectiveType).thenAnswer((_) => effectiveType);
    when(this.downlink).thenAnswer((_) => downlink);
    when(this.rtt).thenAnswer((_) => rtt);

    onchange(Event('change'));
  }
}
