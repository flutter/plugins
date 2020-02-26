import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get temporary directory', (WidgetTester tester) async {
    final String tempPath = (await getTemporaryDirectory()).path;
    expect(tempPath, isNotEmpty);
  });
}
