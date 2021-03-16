import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/list_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('$ListCommand', () {
    CommandRunner<ListCommand> runner;

    setUp(() {
      initializeFakePackages();
      final ListCommand command = ListCommand(mockPackagesDir, mockFileSystem);

      runner = CommandRunner<Null>('list_test', 'Test for $ListCommand');
      runner.addCommand(command);
    });

    test('lists plugins', () async {
      createFakePlugin('plugin1');
      createFakePlugin('plugin2');

      final List<String> plugins =
          await runCapturingPrint(runner, <String>['list', '--type=plugin']);

      expect(
        plugins,
        orderedEquals(<String>[
          '/packages/plugin1',
          '/packages/plugin2',
        ]),
      );

      cleanupPackages();
    });

    test('lists examples', () async {
      createFakePlugin('plugin1', withSingleExample: true);
      createFakePlugin('plugin2',
          withExamples: <String>['example1', 'example2']);
      createFakePlugin('plugin3');

      final List<String> examples =
          await runCapturingPrint(runner, <String>['list', '--type=example']);

      expect(
        examples,
        orderedEquals(<String>[
          '/packages/plugin1/example',
          '/packages/plugin2/example/example1',
          '/packages/plugin2/example/example2',
        ]),
      );

      cleanupPackages();
    });

    test('lists packages', () async {
      createFakePlugin('plugin1', withSingleExample: true);
      createFakePlugin('plugin2',
          withExamples: <String>['example1', 'example2']);
      createFakePlugin('plugin3');

      final List<String> packages =
          await runCapturingPrint(runner, <String>['list', '--type=package']);

      expect(
        packages,
        unorderedEquals(<String>[
          '/packages/plugin1',
          '/packages/plugin1/example',
          '/packages/plugin2',
          '/packages/plugin2/example/example1',
          '/packages/plugin2/example/example2',
          '/packages/plugin3',
        ]),
      );

      cleanupPackages();
    });

    test('lists files', () async {
      createFakePlugin('plugin1', withSingleExample: true);
      createFakePlugin('plugin2',
          withExamples: <String>['example1', 'example2']);
      createFakePlugin('plugin3');

      final List<String> examples =
          await runCapturingPrint(runner, <String>['list', '--type=file']);

      expect(
        examples,
        unorderedEquals(<String>[
          '/packages/plugin1/pubspec.yaml',
          '/packages/plugin1/example/pubspec.yaml',
          '/packages/plugin2/pubspec.yaml',
          '/packages/plugin2/example/example1/pubspec.yaml',
          '/packages/plugin2/example/example2/pubspec.yaml',
          '/packages/plugin3/pubspec.yaml',
        ]),
      );

      cleanupPackages();
    });

    test('lists plugins using federated plugin layout', () async {
      createFakePlugin('plugin1');

      // Create a federated plugin by creating a directory under the packages
      // directory with several packages underneath.
      final Directory federatedPlugin =
          mockPackagesDir.childDirectory('my_plugin')..createSync();
      final Directory clientLibrary =
          federatedPlugin.childDirectory('my_plugin')..createSync();
      createFakePubspec(clientLibrary);
      final Directory webLibrary =
          federatedPlugin.childDirectory('my_plugin_web')..createSync();
      createFakePubspec(webLibrary);
      final Directory macLibrary =
          federatedPlugin.childDirectory('my_plugin_macos')..createSync();
      createFakePubspec(macLibrary);

      // Test without specifying `--type`.
      final List<String> plugins =
          await runCapturingPrint(runner, <String>['list']);

      expect(
        plugins,
        unorderedEquals(<String>[
          '/packages/plugin1',
          '/packages/my_plugin/my_plugin',
          '/packages/my_plugin/my_plugin_web',
          '/packages/my_plugin/my_plugin_macos',
        ]),
      );

      cleanupPackages();
    });

    test('can filter plugins with the --plugins argument', () async {
      createFakePlugin('plugin1');

      // Create a federated plugin by creating a directory under the packages
      // directory with several packages underneath.
      final Directory federatedPlugin =
          mockPackagesDir.childDirectory('my_plugin')..createSync();
      final Directory clientLibrary =
          federatedPlugin.childDirectory('my_plugin')..createSync();
      createFakePubspec(clientLibrary);
      final Directory webLibrary =
          federatedPlugin.childDirectory('my_plugin_web')..createSync();
      createFakePubspec(webLibrary);
      final Directory macLibrary =
          federatedPlugin.childDirectory('my_plugin_macos')..createSync();
      createFakePubspec(macLibrary);

      List<String> plugins = await runCapturingPrint(
          runner, <String>['list', '--plugins=plugin1']);
      expect(
        plugins,
        unorderedEquals(<String>[
          '/packages/plugin1',
        ]),
      );

      plugins = await runCapturingPrint(
          runner, <String>['list', '--plugins=my_plugin']);
      expect(
        plugins,
        unorderedEquals(<String>[
          '/packages/my_plugin/my_plugin',
          '/packages/my_plugin/my_plugin_web',
          '/packages/my_plugin/my_plugin_macos',
        ]),
      );

      plugins = await runCapturingPrint(
          runner, <String>['list', '--plugins=my_plugin/my_plugin_web']);
      expect(
        plugins,
        unorderedEquals(<String>[
          '/packages/my_plugin/my_plugin_web',
        ]),
      );

      plugins = await runCapturingPrint(runner,
          <String>['list', '--plugins=my_plugin/my_plugin_web,plugin1']);
      expect(
        plugins,
        unorderedEquals(<String>[
          '/packages/plugin1',
          '/packages/my_plugin/my_plugin_web',
        ]),
      );
    });
  });
}
