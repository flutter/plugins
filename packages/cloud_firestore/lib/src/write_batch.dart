// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

// TODO: Find out what happens to batches post-commit.
// Use Java source and iOS source
// See if I need to dispose or block.

class WriteBatch {
  WriteBatch():
    _handle = Firestore.channel.invokeMethod(
      'Batch#create',
    );

  Future<int> _handle;
  final List<Future<Null>> _actions = <Future<Null>>[];

  Future<Null> commit() async {
      await Future.wait(_actions);
      return await Firestore.channel.invokeMethod(
        'Batch#commit',
        <String, dynamic>{'handle': await _handle}
      );
    }

  void delete(DocumentReference reference){
    _handle.then((int handle){
      _actions.add(
        Firestore.channel.invokeMethod(
          'Batch#delete',
          <String, dynamic>{
            'handle': handle,
            'path': reference.path
          },
        ),
      );
    });
  }

  void set(DocumentReference reference, Map<String, dynamic> data, [SetOptions options]){
    _handle.then((int handle){
      _actions.add(
        Firestore.channel.invokeMethod(
          'Batch#set',
          <String, dynamic>{
            'handle': handle,
            'path': reference.path,
            'data': data,
            'options': options?._data,
          },
        ),
      );
    });
  }

  void update(DocumentReference reference, Map<String, dynamic> data){
    _handle.then((int handle){
      _actions.add(
        Firestore.channel.invokeMethod(
          'Batch#update',
          <String, dynamic>{
            'handle': handle,
            'path': reference.path,
            'data': data,
          },
        ),
      );
    });
  }
}