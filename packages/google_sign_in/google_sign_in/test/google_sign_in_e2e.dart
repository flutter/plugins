import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    GoogleSignIn signIn = GoogleSignIn();
    expect(signIn, isNotNull);
  });
}
