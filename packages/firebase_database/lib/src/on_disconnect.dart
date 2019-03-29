part of firebase_database;

class OnDisconnect {
  OnDisconnect._(this._database, DatabaseReference reference)
      : path = reference.path;

  final FirebaseDatabase _database;
  final String path;

  Future<void> set(dynamic value, {dynamic priority}) {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _database._channel.invokeMethod(
      'OnDisconnect#set',
      <String, dynamic>{
        'app': _database.app?.name,
        'databaseURL': _database.databaseURL,
        'path': path,
        'value': value,
        'priority': priority
      },
    );
  }

  Future<void> remove() => set(null);

  Future<void> cancel() {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _database._channel.invokeMethod(
      'OnDisconnect#cancel',
      <String, dynamic>{
        'app': _database.app?.name,
        'databaseURL': _database.databaseURL,
        'path': path
      },
    );
  }

  Future<void> update(Map<String, dynamic> value) {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _database._channel.invokeMethod(
      'OnDisconnect#update',
      <String, dynamic>{
        'app': _database.app?.name,
        'databaseURL': _database.databaseURL,
        'path': path,
        'value': value
      },
    );
  }
}
