part of firebase_database;

class OnDisconnect {
  OnDisconnect._(this._database, DatabaseReference reference)
      : path = reference.path;

  final FirebaseDatabase _database;
  final String path;

  Future<void> set(dynamic value, {dynamic priority}) {
    return _database._channel.invokeMethod<void>(
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
    return _database._channel.invokeMethod<void>(
      'OnDisconnect#cancel',
      <String, dynamic>{
        'app': _database.app?.name,
        'databaseURL': _database.databaseURL,
        'path': path
      },
    );
  }

  Future<void> update(Map<String, dynamic> value) {
    return _database._channel.invokeMethod<void>(
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
