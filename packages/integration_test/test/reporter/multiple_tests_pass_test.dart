import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils.dart';

void main() async {
  test('When multiple tests pass', () async {
    final Map<String, Object> results = await run(_testMain);

    expect(results, hasLength(2));
    expect(results, containsPair('Passing testWidgets()', isSuccess));
    expect(results, containsPair('Passing test()', isSuccess));
  });
}

void _testMain() {
  testWidgets('Passing testWidgets()', (WidgetTester tester) async {
    expect(true, true);
  });

  test('Passing test()', () {
    expect(true, true);
  });
}
