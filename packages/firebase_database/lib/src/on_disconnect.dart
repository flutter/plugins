part of firebase_database;

class OnDisconnect {

  OnDisconnect._(this._database, DatabaseReference reference): path = reference.path;

  final FirebaseDatabase _database;
  final String path;

  Future<Null> set(dynamic value, {dynamic priority}) {
    return _database._channel.invokeMethod(
      'OnDisconnect#set',
      <String, dynamic>{'path': path, 'value': value, 'priority': priority},
    );
  }

  Future<Null> update(Map<String, dynamic> value) {
    return _database._channel.invokeMethod(
      'OnDisconnect#update',
      <String, dynamic>{'path': path, 'value': value},
    );
  }

  Future<Null> remove() => set(null);

  Future<Null> cancel() {
    return _database._channel.invokeMethod(
      'OnDisconnect#cancel',
      <String, dynamic>{'path': path},
    );
  }
}