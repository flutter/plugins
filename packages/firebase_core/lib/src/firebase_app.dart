// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_core;

class FirebaseApp {
  @visibleForTesting
  const FirebaseApp({this.name, @required this.options});

  /// Gets the name of this app.
  ///
  /// If null, the default name is used.
  final String name;

  /// Gets a copy of the options for this app. These are non-modifiable.
  final FirebaseOptions options;

  @visibleForTesting
  static const MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  static Map<String, FirebaseApp> _namedApps = <String, FirebaseApp>{};

  /// Returns a previously created FirebaseApp instance with the given name,
  /// or null if no such app exists.
  factory FirebaseApp.named(String name) => _namedApps['name'];

  /// Configures an app with the given name.
  ///
  /// If an app with that name has already been configured, asserts that the
  /// [options] haven't changed.
  static Future<FirebaseApp> configure(
      {String name, @required FirebaseOptions options}) {
    final FirebaseApp existingApp = _namedApps[name];
    if (existingApp != null) {
      assert(existingApp.options == options);
      return new Future<FirebaseApp>.sync(() => existingApp);
    }
    assert(options.googleAppID != null);
    _namedApps[name] = new FirebaseApp(name: name, options: options);
    return channel.invokeMethod('FirebaseApp#configure', <String, dynamic>{
      'name': name,
      'options': options.asMap,
    }).then((dynamic _) => _namedApps[name]);
  }

  /// Returns a list of all extant FirebaseApp instances, or null if there are
  /// no FirebaseApp instances.
  static Future<List<FirebaseApp>> allApps() async {
    final List<dynamic> result = await channel.invokeMethod(
      'FirebaseApp#allApps',
    );
    return result?.map<FirebaseApp>((dynamic app) {
      return new FirebaseApp(
        name: app['name'],
        options: new FirebaseOptions.from(app['options']),
      );
    })?.toList();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseApp) return false;
    return other.name == name && other.options == options;
  }

  @override
  int get hashCode => hashValues(name, options);

  @override
  String toString() => '$FirebaseApp($name, $options)';
}
