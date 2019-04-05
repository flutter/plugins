import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  test('SharedPreferences', () async {
    final FlutterDriver driver = await FlutterDriver.connect();
    await driver.requestData(null, timeout: const Duration(minutes: 1));
    if (driver != null) {
      driver.close();
    }
  });
}
