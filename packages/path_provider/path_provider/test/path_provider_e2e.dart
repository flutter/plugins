import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get temporary directory', (WidgetTester tester) async {
    final String tempPath = (await getTemporaryDirectory()).path;
    expect(tempPath, isNotEmpty);
  });
}
