import 'package:test/test.dart';
import 'package:flutter_driver/flutter_driver.dart';

void main() {
  group('Store connection tests', () {
    FlutterDriver driver;
    final SerializableFinder connectedFinder =
        find.text('The store is available.');

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('can connect', () async {
      await driver.waitFor(connectedFinder);
    });
  });
}
