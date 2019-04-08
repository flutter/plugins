import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseDatabase', () {
    final FirebaseDatabase database = FirebaseDatabase.instance;

    test('runTransaction', () async {
      final DatabaseReference ref = database.reference().child('counter');
      final int value = await ref.once() ?? 0;
      final TransactionResult transactionResult =
        await ref.runTransaction((MutableData mutableData) async {
        mutableData.value = (mutableData.value ?? 0) + 1;
        return mutableData;
      });
      assert(transactionResult.committed, true);
      assert(transactionResult.dataSnapshot.value > value, true);
    });

  });
}
