import 'dart:async';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() {
  group('StorageReference', () {
    group('getData', () {
      const MethodChannel channel = const MethodChannel(
        'firebase_storage',
      );

      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        channel.setMockMethodCallHandler((MethodCall methodCall) {
          log.add(methodCall);
          return new Future<Uint8List>.value(
              new Uint8List.fromList(<int>[1, 2, 3, 4]));
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getData(10);

        expect(
            log,
            equals(<MethodCall>[
              new MethodCall('StorageReference#getData', <String, dynamic>{
                'maxSize': 10,
                'path': 'avatars/large/image.jpg',
              }),
            ]));
      });

      test('returns correct result', () async {
        expect(await ref.getData(10),
            equals(new Uint8List.fromList(<int>[1, 2, 3, 4])));
      });
    });
  });
}
