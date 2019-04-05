import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  test('$Connectivity', () async {
    final FlutterDriver driver = await FlutterDriver.connect();
    await driver.requestData(null, timeout: const Duration(minutes: 1));
    driver.close();
  });
}
