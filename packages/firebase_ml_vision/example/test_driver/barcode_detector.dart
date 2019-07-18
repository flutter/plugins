// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void barcodeDetectorTests() {
  group('$BarcodeDetector', () {
    final BarcodeDetector detector = FirebaseVision.instance.barcodeDetector();

    test('detectInImage', () async {
      final String tmpFilename = await _loadImage('assets/test_barcode.jpg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      final List<Barcode> barcodes = await detector.detectInImage(
        visionImage,
      );

      expect(barcodes.length, 1);
    });

    test('detectInImage contactInfo', () async {
      final String tmpFilename = await _loadImage(
        'assets/test_contact_barcode.png',
      );

      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(
        tmpFilename,
      );

      final BarcodeDetector detector =
          FirebaseVision.instance.barcodeDetector();
      final List<Barcode> barcodes = await detector.detectInImage(
        visionImage,
      );

      expect(barcodes, hasLength(1));
      final BarcodeContactInfo info = barcodes[0].contactInfo;

      final BarcodePersonName name = info.name;
      expect(name.first, 'John');
      expect(name.last, 'Doe');
      expect(name.formattedName, 'John Doe');
      expect(name.middle, anyOf(isNull, isEmpty));
      expect(name.prefix, anyOf(isNull, isEmpty));
      expect(name.pronunciation, anyOf(isNull, isEmpty));
      expect(name.suffix, anyOf(isNull, isEmpty));

      expect(info.jobTitle, anyOf(isNull, isEmpty));
      expect(info.organization, anyOf(isNull, isEmpty));
      expect(info.urls, <String>['http://www.example.com']);
      expect(info.addresses, anyOf(isNull, isEmpty));

      expect(info.emails, hasLength(1));
      final BarcodeEmail email = info.emails[0];
      expect(email.address, 'email@example.com');
      expect(email.body, anyOf(isNull, isEmpty));
      expect(email.subject, anyOf(isNull, isEmpty));
      expect(email.type, BarcodeEmailType.unknown);

      expect(info.phones, hasLength(1));
      final BarcodePhone phone = info.phones[0];
      expect(phone.number, '555-555-5555');
      expect(phone.type, BarcodePhoneType.unknown);
    });

    test('close', () {
      expect(detector.close(), completes);
    });
  });
}
