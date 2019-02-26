import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  test('SharedPreferences', () async {
    FlutterDriver driver = await FlutterDriver.connect();
    String result = await driver.requestData(null, timeout: const Duration(minutes: 1));
    expect(result, 'pass');
    if (driver != null) {
      driver.close();
    }
  });
}
