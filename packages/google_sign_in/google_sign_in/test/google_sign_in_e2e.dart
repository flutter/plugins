import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    GoogleSignIn signIn = GoogleSignIn();
    expect(signIn, isNotNull);
  });
}
