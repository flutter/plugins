import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test/test.dart';

void main() {
  group('$ImagePicker', () {
    const MethodChannel channel = const MethodChannel('image_picker');

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return '';
      });

      log.clear();
    });

    group('#pickImage', () {
      test('passes the width and height arguments correctly', () async {
        await ImagePicker.pickImage();
        await ImagePicker.pickImage(desiredWidth: 10.0);
        await ImagePicker.pickImage(desiredHeight: 10.0);
        await ImagePicker.pickImage(
          desiredWidth: 10.0,
          desiredHeight: 20.0,
        );

        expect(
          log,
          equals(
            <MethodCall>[
              const MethodCall('pickImage', const <String, double>{
                'width': null,
                'height': null,
              }),
              const MethodCall('pickImage', const <String, double>{
                'width': 10.0,
                'height': null,
              }),
              const MethodCall('pickImage', const <String, double>{
                'width': null,
                'height': 10.0,
              }),
              const MethodCall('pickImage', const <String, double>{
                'width': 10.0,
                'height': 20.0,
              }),
            ],
          ),
        );
      });

      test('does not accept a negative width or height argument', () {
        expect(ImagePicker.pickImage(desiredWidth: -1.0), throwsArgumentError);
        expect(ImagePicker.pickImage(desiredHeight: -1.0), throwsArgumentError);
      });
    });
  });
}
