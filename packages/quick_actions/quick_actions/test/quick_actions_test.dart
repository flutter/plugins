import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:quick_actions_platform_interface/platform_interface/quick_actions_platform.dart';
import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';
import 'package:quick_actions_platform_interface/types/shortcut_item.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('$QuickActions', () {

    setUpAll(() {
      QuickActionsPlatform.instance = MockQuickActionsPlatform();
    });

    test('initialize() PlatformInterface', () {
      MockQuickActions quickActions = MockQuickActions();
      quickActions.initialize((type) { });

      verify(QuickActionsPlatform.instance.initialize((_)=>{})).called(1);
    });

    test('setShortcutItems() PlatformInterface', () {
      MockQuickActions quickActions = MockQuickActions();
      quickActions.initialize((type) { });
      quickActions.setShortcutItems([]);

      verify(QuickActionsPlatform.instance.initialize((String _) => {})).called(1);
      verify(QuickActionsPlatform.instance.setShortcutItems([])).called(1);
    });

    test('clearShortcutItems() PlatformInterface', () {
      MockQuickActions quickActions = MockQuickActions();
      quickActions.initialize((type) { 'launch';});
      quickActions.clearShortcutItems();

      verify(QuickActionsPlatform.instance.initialize((type) { 'launch';})).called(1);
      verify(QuickActionsPlatform.instance.clearShortcutItems()).called(1);
    });
  });
}

class MockQuickActionsPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements QuickActionsPlatform {
  @override
  Future<void> clearShortcutItems() async {
    super.noSuchMethod(
        Invocation.method(#clearShortcutItems, []));
  }

  @override
  void initialize(QuickActionHandler handler) {
    super.noSuchMethod(
        Invocation.method(#initialize, [handler]));
  }

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async {
    super.noSuchMethod(
        Invocation.method(#setShortcutItems, [items]));
  }
}

class MockQuickActions extends QuickActions {}