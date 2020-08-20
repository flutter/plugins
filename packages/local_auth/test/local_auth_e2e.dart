import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:local_auth/local_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canCheckBiometrics', (WidgetTester tester) async {
    expect(LocalAuthentication().getAvailableBiometrics(), completion(isList));
  });
}
