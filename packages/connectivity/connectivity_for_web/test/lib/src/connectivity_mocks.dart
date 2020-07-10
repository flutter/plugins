import 'dart:async';
import 'dart:html';

import 'package:mockito/mockito.dart';

/// A Mock implementation of the NetworkInformation API that allows
/// for external modification of its values.
class MockNetworkInformation extends Mock implements NetworkInformation {
  StreamController<Event> _onChangeController = StreamController<Event>();

  @override
  Stream<Event> get onChange => _onChangeController.stream;

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

    _onChangeController.add(Event('change'));
  }
}
