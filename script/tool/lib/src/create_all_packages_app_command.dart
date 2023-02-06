// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'common/core.dart';
import 'common/package_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

const String _outputDirectoryFlag = 'output-dir';

const String _projectName = 'all_packages';

const int _exitUpdateMacosPodfileFailed = 3;
const int _exitUpdateMacosPbxprojFailed = 4;
const int _exitGenNativeBuildFilesFailed = 5;

/// A command to create an application that builds all in a single application.
class CreateAllPackagesAppCommand extends PackageCommand {
  /// Creates an instance of the builder command.
  CreateAllPackagesAppCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Directory? pluginsRoot,
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    final Directory defaultDir =
        pluginsRoot ?? packagesDir.fileSystem.currentDirectory;
    argParser.addOption(_outputDirectoryFlag,
        defaultsTo: defaultDir.path,
        help:
            'The path the directory to create the "$_projectName" project in.\n'
            'Defaults to the repository root.');
  }

  /// The location to create the synthesized app project.
  Directory get _appDirectory => packagesDir.fileSystem
      .directory(getStringArg(_outputDirectoryFlag))
      .childDirectory(_projectName);

  /// The synthesized app project.
  RepositoryPackage get app => RepositoryPackage(_appDirectory);

  @override
  String get description =>
      'Generate Flutter app that includes all target packagas.';

  @override
  String get name => 'create-all-packages-app';

  @override
  Future<void> run() async {
    final int exitCode = await _createApp();
    if (exitCode != 0) {
      throw ToolExit(exitCode);
    }

    final Set<String> excluded = getExcludedPackageNames();
    if (excluded.isNotEmpty) {
      print('Exluding the following plugins from the combined build:');
      for (final String plugin in excluded) {
        print('  $plugin');
      }
      print('');
    }

    await _genPubspecWithAllPlugins();

    // Run `flutter pub get` to generate all native build files.
    // TODO(stuartmorgan): This hangs on Windows for some reason. Since it's
    // currently not needed on Windows, skip it there, but we should investigate
    // further and/or implement https://github.com/flutter/flutter/issues/93407,
    // and remove the need for this conditional.
    if (!platform.isWindows) {
      if (!await _genNativeBuildFiles()) {
        printError(
            "Failed to generate native build files via 'flutter pub get'");
        throw ToolExit(_exitGenNativeBuildFilesFailed);
      }
    }

    await Future.wait(<Future<void>>[
      _updateAppGradle(),
      _updateManifest(),
      _updateMacosPbxproj(),
      // This step requires the native file generation triggered by
      // flutter pub get above, so can't currently be run on Windows.
      if (!platform.isWindows) _updateMacosPodfile(),
    ]);
  }

  Future<int> _createApp() async {
    final io.ProcessResult result = io.Process.runSync(
      flutterCommand,
      <String>[
        'create',
        '--template=app',
        '--project-name=$_projectName',
        '--android-language=java',
        _appDirectory.path,
      ],
    );

    print(result.stdout);
    print(result.stderr);
    return result.exitCode;
  }

  Future<void> _updateAppGradle() async {
    final File gradleFile = app
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle');
    if (!gradleFile.existsSync()) {
      throw ToolExit(64);
    }

    final StringBuffer newGradle = StringBuffer();
    for (final String line in gradleFile.readAsLinesSync()) {
      if (line.contains('minSdkVersion')) {
        // minSdkVersion 20 is required by Google maps.
        // minSdkVersion 19 is required by WebView.
        newGradle.writeln('minSdkVersion 20');
      } else if (line.contains('compileSdkVersion')) {
        // compileSdkVersion 33 is required by local_auth.
        newGradle.writeln('compileSdkVersion 33');
      } else {
        newGradle.writeln(line);
      }
      if (line.contains('defaultConfig {')) {
        newGradle.writeln('        multiDexEnabled true');
      } else if (line.contains('dependencies {')) {
        // Tests for https://github.com/flutter/flutter/issues/43383
        newGradle.writeln(
          "    implementation 'androidx.lifecycle:lifecycle-runtime:2.2.0-rc01'\n",
        );
      }
    }
    gradleFile.writeAsStringSync(newGradle.toString());
  }

  Future<void> _updateManifest() async {
    final File manifestFile = app
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childDirectory('src')
        .childDirectory('main')
        .childFile('AndroidManifest.xml');
    if (!manifestFile.existsSync()) {
      throw ToolExit(64);
    }

    final StringBuffer newManifest = StringBuffer();
    for (final String line in manifestFile.readAsLinesSync()) {
      if (line.contains('package="com.example.$_projectName"')) {
        newManifest
          ..writeln('package="com.example.$_projectName"')
          ..writeln('xmlns:tools="http://schemas.android.com/tools">')
          ..writeln()
          ..writeln(
            '<uses-sdk tools:overrideLibrary="io.flutter.plugins.camera"/>',
          );
      } else {
        newManifest.writeln(line);
      }
    }
    manifestFile.writeAsStringSync(newManifest.toString());
  }

  Future<void> _genPubspecWithAllPlugins() async {
    // Read the old pubspec file's Dart SDK version, in order to preserve it
    // in the new file. The template sometimes relies on having opted in to
    // specific language features via SDK version, so using a different one
    // can cause compilation failures.
    final Pubspec originalPubspec = app.parsePubspec();
    const String dartSdkKey = 'sdk';
    final VersionConstraint dartSdkConstraint =
        originalPubspec.environment?[dartSdkKey] ??
            VersionConstraint.compatibleWith(
              Version.parse('2.12.0'),
            );

    final Map<String, PathDependency> pluginDeps =
        await _getValidPathDependencies();
    final Pubspec pubspec = Pubspec(
      _projectName,
      description: 'Flutter app containing all 1st party plugins.',
      version: Version.parse('1.0.0+1'),
      environment: <String, VersionConstraint>{
        dartSdkKey: dartSdkConstraint,
      },
      dependencies: <String, Dependency>{
        'flutter': SdkDependency('flutter'),
      }..addAll(pluginDeps),
      devDependencies: <String, Dependency>{
        'flutter_test': SdkDependency('flutter'),
      },
      dependencyOverrides: pluginDeps,
    );
    app.pubspecFile.writeAsStringSync(_pubspecToString(pubspec));
  }

  Future<Map<String, PathDependency>> _getValidPathDependencies() async {
    final Map<String, PathDependency> pathDependencies =
        <String, PathDependency>{};

    await for (final PackageEnumerationEntry entry in getTargetPackages()) {
      final RepositoryPackage package = entry.package;
      final Directory pluginDirectory = package.directory;
      final String pluginName = pluginDirectory.basename;
      final Pubspec pubspec = package.parsePubspec();

      if (pubspec.publishTo != 'none') {
        pathDependencies[pluginName] = PathDependency(pluginDirectory.path);
      }
    }
    return pathDependencies;
  }

  String _pubspecToString(Pubspec pubspec) {
    return '''
### Generated file. Do not edit. Run `dart pub global run flutter_plugin_tools gen-pubspec` to update.
name: ${pubspec.name}
description: ${pubspec.description}
publish_to: none

version: ${pubspec.version}

environment:${_pubspecMapString(pubspec.environment!)}

dependencies:${_pubspecMapString(pubspec.dependencies)}

dependency_overrides:${_pubspecMapString(pubspec.dependencyOverrides)}

dev_dependencies:${_pubspecMapString(pubspec.devDependencies)}
###''';
  }

  String _pubspecMapString(Map<String, Object?> values) {
    final StringBuffer buffer = StringBuffer();

    for (final MapEntry<String, Object?> entry in values.entries) {
      buffer.writeln();
      final Object? entryValue = entry.value;
      if (entryValue is VersionConstraint) {
        String value = entryValue.toString();
        // Range constraints require quoting.
        if (value.startsWith('>') || value.startsWith('<')) {
          value = "'$value'";
        }
        buffer.write('  ${entry.key}: $value');
      } else if (entryValue is SdkDependency) {
        buffer.write('  ${entry.key}: \n    sdk: ${entryValue.sdk}');
      } else if (entryValue is PathDependency) {
        String depPath = entryValue.path;
        if (path.style == p.Style.windows) {
          // Posix-style path separators are preferred in pubspec.yaml (and
          // using a consistent format makes unit testing simpler), so convert.
          final List<String> components = path.split(depPath);
          final String firstComponent = components.first;
          // path.split leaves a \ on drive components that isn't necessary,
          // and confuses pub, so remove it.
          if (firstComponent.endsWith(r':\')) {
            components[0] =
                firstComponent.substring(0, firstComponent.length - 1);
          }
          depPath = p.posix.joinAll(components);
        }
        buffer.write('  ${entry.key}: \n    path: $depPath');
      } else {
        throw UnimplementedError(
          'Not available for type: ${entryValue.runtimeType}',
        );
      }
    }

    return buffer.toString();
  }

  Future<bool> _genNativeBuildFiles() async {
    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>['pub', 'get'],
      workingDir: _appDirectory,
    );
    return exitCode == 0;
  }

  Future<void> _updateMacosPodfile() async {
    /// Only change the macOS deployment target if the host platform is macOS.
    /// The Podfile is not generated on other platforms.
    if (!platform.isMacOS) {
      return;
    }

    final File podfileFile =
        app.platformDirectory(FlutterPlatform.macos).childFile('Podfile');
    if (!podfileFile.existsSync()) {
      printError("Can't find Podfile for macOS");
      throw ToolExit(_exitUpdateMacosPodfileFailed);
    }

    final StringBuffer newPodfile = StringBuffer();
    for (final String line in podfileFile.readAsLinesSync()) {
      if (line.contains('platform :osx')) {
        // macOS 10.15 is required by in_app_purchase.
        newPodfile.writeln("platform :osx, '10.15'");
      } else {
        newPodfile.writeln(line);
      }
    }
    podfileFile.writeAsStringSync(newPodfile.toString());
  }

  Future<void> _updateMacosPbxproj() async {
    final File pbxprojFile = app
        .platformDirectory(FlutterPlatform.macos)
        .childDirectory('Runner.xcodeproj')
        .childFile('project.pbxproj');
    if (!pbxprojFile.existsSync()) {
      printError("Can't find project.pbxproj for macOS");
      throw ToolExit(_exitUpdateMacosPbxprojFailed);
    }

    final StringBuffer newPbxproj = StringBuffer();
    for (final String line in pbxprojFile.readAsLinesSync()) {
      if (line.contains('MACOSX_DEPLOYMENT_TARGET')) {
        // macOS 10.15 is required by in_app_purchase.
        newPbxproj.writeln('				MACOSX_DEPLOYMENT_TARGET = 10.15;');
      } else {
        newPbxproj.writeln(line);
      }
    }
    pbxprojFile.writeAsStringSync(newPbxproj.toString());
  }
}
