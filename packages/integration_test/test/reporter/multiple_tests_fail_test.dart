import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils.dart';

void main() async {
  test('When multiple tests fail', () async {
    final Map<String, Object> results = await run(_testMain);

    expect(results, hasLength(2));
    expect(results, containsPair('Failing testWidgets()', isFailure));
    expect(results, containsPair('Failing test()', isFailure));
  });
}

void _testMain() {
  testWidgets('Failing testWidgets()', (WidgetTester tester) async {
    expect(false, true);
  });

  test('Failing test()', () {
    expect(false, true);
  });
}
