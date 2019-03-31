// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_core;

class FirebaseApp {
  @visibleForTesting
  const FirebaseApp({@required this.name}) : assert(name != null);

  /// The name of this app.
  final String name;

  static final String defaultAppName =
      Platform.isIOS ? '__FIRAPP_DEFAULT' : '[DEFAULT]';

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  /// A copy of the options for this app. These are non-modifiable.
  ///
  /// This getter is asynchronous because apps can also be configured by native
  /// code.
  Future<FirebaseOptions> get options async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final Map<dynamic, dynamic> app = await channel.invokeMethod(
      'FirebaseApp#appNamed',
      name,
    );
    assert(app != null);
    return FirebaseOptions.from(app['options']);
  }

  /// Returns a previously created FirebaseApp instance with the given name,
  /// or null if no such app exists.
  static Future<FirebaseApp> appNamed(String name) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final Map<dynamic, dynamic> app = await channel.invokeMethod(
      'FirebaseApp#appNamed',
      name,
    );
    return app == null ? null : FirebaseApp(name: app['name']);
  }

  /// Returns the default (first initialized) instance of the FirebaseApp.
  static final FirebaseApp instance = FirebaseApp(name: defaultAppName);

  /// Configures an app with the given [name] and [options].
  ///
  /// Configuring the default app is not currently supported. Plugins that
  /// can interact with the default app should configure it automatically at
  /// plugin registration time.
  ///
  /// Changing the options of a configured app is not supported.
  static Future<FirebaseApp> configure({
    @required String name,
    @required FirebaseOptions options,
  }) async {
    assert(name != null);
    assert(name != defaultAppName);
    assert(options != null);
    assert(options.googleAppID != null);
    final FirebaseApp existingApp = await FirebaseApp.appNamed(name);
    if (existingApp != null) {
      return existingApp;
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod(
      'FirebaseApp#configure',
      <String, dynamic>{'name': name, 'options': options.asMap},
    );
    return FirebaseApp(name: name);
  }

  /// Returns a list of all extant FirebaseApp instances, or null if there are
  /// no FirebaseApp instances.
  static Future<List<FirebaseApp>> allApps() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final List<dynamic> result = await channel.invokeMethod(
      'FirebaseApp#allApps',
    );
    return result
        ?.map<FirebaseApp>(
          (dynamic app) => FirebaseApp(name: app['name']),
        )
        ?.toList();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseApp) return false;
    return other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => '$FirebaseApp($name)';
}
