import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:local_auth/local_auth.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canCheckBiometrics', (WidgetTester tester) async {
    expect(LocalAuthentication().getAvailableBiometrics(), completion(isList));
  });
}
