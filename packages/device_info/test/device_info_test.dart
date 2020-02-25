import 'package:device_info/device_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Testing the Device Info', () {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    deviceInfoPlugin.androidInfo.then((AndroidDeviceInfo andinfo) {
      expect(andinfo, isNotNull);
    });
    deviceInfoPlugin.iosInfo.then((IosDeviceInfo iosinfo) {
      expect(iosinfo, isNotNull);
    });
  });
}
