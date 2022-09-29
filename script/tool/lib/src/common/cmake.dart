// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'core.dart';
import 'process_runner.dart';

const String _cacheCommandKey = 'CMAKE_COMMAND:INTERNAL';

/// A utility class for interacting with CMake projects.
class CMakeProject {
  /// Creates an instance that runs commands for [project] with the given
  /// [processRunner].
  CMakeProject(
    this.flutterProject, {
    required this.buildMode,
    this.processRunner = const ProcessRunner(),
    this.platform = const LocalPlatform(),
  });

  /// The directory of a Flutter project to run Gradle commands in.
  final Directory flutterProject;

  /// The [ProcessRunner] used to run commands. Overridable for testing.
  final ProcessRunner processRunner;

  /// The platform that commands are being run on.
  final Platform platform;

  /// The build mode (e.g., Debug, Release).
  ///
  /// This is a constructor paramater because on Linux many properties depend
  /// on the build mode since it uses a single-configuration generator.
  final String buildMode;

  late final String _cmakeCommand = _determineCmakeCommand();

  /// The project's platform directory name.
  String get _platformDirName => platform.isWindows ? 'windows' : 'linux';

  /// The project's 'example' build directory for this instance's platform.
  Directory get buildDirectory {
    Directory buildDir =
        flutterProject.childDirectory('build').childDirectory(_platformDirName);
    if (platform.isLinux) {
      buildDir = buildDir
          // TODO(stuartmorgan): Support arm64 if that ever becomes a supported
          // CI configuration for the repository.
          .childDirectory('x64')
          // Linux uses a single-config generator, so the base build directory
          // includes the configuration.
          .childDirectory(buildMode.toLowerCase());
    }
    return buildDir;
  }

  File get _cacheFile => buildDirectory.childFile('CMakeCache.txt');

  /// Returns the CMake command to run build commands for this project.
  ///
  /// Assumes the project has been built at least once, such that the CMake
  /// generation step has run.
  String getCmakeCommand() {
    return _cmakeCommand;
  }

  /// Returns the CMake command to run build commands for this project. This is
  /// used to initialize _cmakeCommand, and should not be called directly.
  ///
  /// Assumes the project has been built at least once, such that the CMake
  /// generation step has run.
  String _determineCmakeCommand() {
    // On Linux 'cmake' is expected to be in the path, so doesn't need to
    // be lookup up and cached.
    if (platform.isLinux) {
      return 'cmake';
    }
    final File cacheFile = _cacheFile;
    String? command;
    for (String line in cacheFile.readAsLinesSync()) {
      line = line.trim();
      if (line.startsWith(_cacheCommandKey)) {
        command = line.substring(line.indexOf('=') + 1).trim();
        break;
      }
    }
    if (command == null) {
      printError('Unable to find CMake command in ${cacheFile.path}');
      throw ToolExit(100);
    }
    return command;
  }

  /// Whether or not the project is ready to have CMake commands run on it
  /// (i.e., whether the `flutter` tool has generated the necessary files).
  bool isConfigured() => _cacheFile.existsSync();

  /// Runs a `cmake` command with the given parameters.
  Future<int> runBuild(
    String target, {
    List<String> arguments = const <String>[],
  }) {
    return processRunner.runAndStream(
      getCmakeCommand(),
      <String>[
        '--build',
        buildDirectory.path,
        '--target',
        target,
        if (platform.isWindows) ...<String>['--config', buildMode],
        ...arguments,
      ],
    );
  }
}
