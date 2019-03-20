// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseVision', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      FirebaseVision.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'BarcodeDetector#detectInImage':
            return returnValue;
          case 'FaceDetector#processImage':
            return returnValue;
          case 'TextRecognizer#processImage':
            return returnValue;
          default:
            return null;
        }
      });
      log.clear();
    });

    group('$FirebaseVisionImageMetadata', () {
      final TextRecognizer recognizer =
          FirebaseVision.instance.textRecognizer();

      setUp(() {
        returnValue = <dynamic, dynamic>{
          'text': '',
          'blocks': <dynamic>[],
        };
      });

      test('default serialization', () async {
        final FirebaseVisionImageMetadata metadata =
            FirebaseVisionImageMetadata(
          rawFormat: 35,
          size: const Size(1.0, 1.0),
          planeData: <FirebaseVisionImagePlaneMetadata>[
            FirebaseVisionImagePlaneMetadata(
              bytesPerRow: 1000,
              height: 480,
              width: 480,
            ),
          ],
        );
        final FirebaseVisionImage image =
            FirebaseVisionImage.fromBytes(Uint8List(0), metadata);
        await recognizer.processImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'TextRecognizer#processImage',
            arguments: <String, dynamic>{
              'type': 'bytes',
              'path': null,
              'bytes': Uint8List(0),
              'metadata': <String, dynamic>{
                'width': 1.0,
                'height': 1.0,
                'rotation': 0,
                'rawFormat': 35,
                'planeData': <dynamic>[
                  <String, dynamic>{
                    'bytesPerRow': 1000,
                    'height': 480,
                    'width': 480,
                  },
                ],
              },
              'options': <String, dynamic>{},
            },
          ),
        ]);
      });
    });

    group('$BarcodeDetector', () {
      BarcodeDetector detector;
      FirebaseVisionImage image;
      List<dynamic> returnBarcodes;

      setUp(() {
        detector = FirebaseVision.instance.barcodeDetector();
        image = FirebaseVisionImage.fromFilePath('empty');
        returnBarcodes = <dynamic>[
          <dynamic, dynamic>{
            'rawValue': 'hello:raw',
            'displayValue': 'hello:display',
            'format': 0,
            'left': 1.0,
            'top': 2.0,
            'width': 3.0,
            'height': 4.0,
            'points': <dynamic>[
              <dynamic>[5.0, 6.0],
              <dynamic>[7.0, 8.0],
            ],
          },
        ];
      });

      test('detectInImage unknown', () async {
        returnBarcodes[0]['valueType'] = BarcodeValueType.unknown.index;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'BarcodeDetector#detectInImage',
            arguments: <String, dynamic>{
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'barcodeFormats': 0xFFFF,
              },
            },
          ),
        ]);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.unknown);
        expect(barcode.boundingBox, Rect.fromLTWH(1.0, 2.0, 3.0, 4.0));
        expect(barcode.rawValue, 'hello:raw');
        expect(barcode.displayValue, 'hello:display');
        expect(barcode.cornerPoints, const <Offset>[
          Offset(5.0, 6.0),
          Offset(7.0, 8.0),
        ]);
      });

      test('detectInImage email', () async {
        final Map<dynamic, dynamic> email = <dynamic, dynamic>{
          'address': 'a',
          'body': 'b',
          'subject': 's',
          'type': BarcodeEmailType.home.index,
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.email.index;
        returnBarcodes[0]['email'] = email;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.email);
        expect(barcode.email.address, 'a');
        expect(barcode.email.body, 'b');
        expect(barcode.email.subject, 's');
        expect(barcode.email.type, BarcodeEmailType.home);
      });

      test('detectInImage phone', () async {
        final Map<dynamic, dynamic> phone = <dynamic, dynamic>{
          'number': '000',
          'type': BarcodePhoneType.fax.index,
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.phone.index;
        returnBarcodes[0]['phone'] = phone;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.phone);
        expect(barcode.phone.number, '000');
        expect(barcode.phone.type, BarcodePhoneType.fax);
      });

      test('detectInImage sms', () async {
        final Map<dynamic, dynamic> sms = <dynamic, dynamic>{
          'phoneNumber': '000',
          'message': 'm'
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.sms.index;
        returnBarcodes[0]['sms'] = sms;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.sms);
        expect(barcode.sms.phoneNumber, '000');
        expect(barcode.sms.message, 'm');
      });

      test('detectInImage url', () async {
        final Map<dynamic, dynamic> url = <dynamic, dynamic>{
          'title': 't',
          'url': 'u'
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.url.index;
        returnBarcodes[0]['url'] = url;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.url);
        expect(barcode.url.title, 't');
        expect(barcode.url.url, 'u');
      });

      test('detectInImage wifi', () async {
        final Map<dynamic, dynamic> wifi = <dynamic, dynamic>{
          'ssid': 's',
          'password': 'p',
          'encryptionType': BarcodeWiFiEncryptionType.wep.index,
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.wifi.index;
        returnBarcodes[0]['wifi'] = wifi;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.wifi);
        expect(barcode.wifi.ssid, 's');
        expect(barcode.wifi.password, 'p');
        expect(barcode.wifi.encryptionType, BarcodeWiFiEncryptionType.wep);
      });

      test('detectInImage geoPoint', () async {
        final Map<dynamic, dynamic> geoPoint = <dynamic, dynamic>{
          'latitude': 0.2,
          'longitude': 0.3,
        };

        returnBarcodes[0]['valueType'] =
            BarcodeValueType.geographicCoordinates.index;
        returnBarcodes[0]['geoPoint'] = geoPoint;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.geographicCoordinates);
        expect(barcode.geoPoint.latitude, 0.2);
        expect(barcode.geoPoint.longitude, 0.3);
      });

      test('detectInImage contactInfo', () async {
        final Map<dynamic, dynamic> contact = <dynamic, dynamic>{
          'addresses': <dynamic>[
            <dynamic, dynamic>{
              'addressLines': <String>['al'],
              'type': BarcodeAddressType.work.index,
            }
          ],
          'emails': <dynamic>[
            <dynamic, dynamic>{
              'type': BarcodeEmailType.home.index,
              'address': 'a',
              'body': 'b',
              'subject': 's'
            },
          ],
          'name': <dynamic, dynamic>{
            'formattedName': 'fn',
            'first': 'f',
            'last': 'l',
            'middle': 'm',
            'prefix': 'p',
            'pronunciation': 'pn',
            'suffix': 's',
          },
          'phones': <dynamic>[
            <dynamic, dynamic>{
              'number': '012',
              'type': BarcodePhoneType.mobile.index,
            }
          ],
          'urls': <String>['url'],
          'jobTitle': 'j',
          'organization': 'o'
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.contactInfo.index;
        returnBarcodes[0]['contactInfo'] = contact;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.contactInfo);
        expect(barcode.contactInfo.addresses[0].type, BarcodeAddressType.work);
        expect(barcode.contactInfo.addresses[0].addressLines[0], 'al');
        expect(barcode.contactInfo.emails[0].type, BarcodeEmailType.home);
        expect(barcode.contactInfo.emails[0].address, 'a');
        expect(barcode.contactInfo.emails[0].body, 'b');
        expect(barcode.contactInfo.emails[0].subject, 's');
        expect(barcode.contactInfo.name.first, 'f');
        expect(barcode.contactInfo.name.last, 'l');
        expect(barcode.contactInfo.name.middle, 'm');
        expect(barcode.contactInfo.name.formattedName, 'fn');
        expect(barcode.contactInfo.name.prefix, 'p');
        expect(barcode.contactInfo.name.suffix, 's');
        expect(barcode.contactInfo.name.pronunciation, 'pn');
        expect(barcode.contactInfo.phones[0].type, BarcodePhoneType.mobile);
        expect(barcode.contactInfo.phones[0].number, '012');
        expect(barcode.contactInfo.urls[0], 'url');
        expect(barcode.contactInfo.jobTitle, 'j');
        expect(barcode.contactInfo.organization, 'o');
      });

      test('detectInImage calendarEvent', () async {
        final Map<dynamic, dynamic> calendar = <dynamic, dynamic>{
          'eventDescription': 'e',
          'location': 'l',
          'organizer': 'o',
          'status': 'st',
          'summary': 'sm',
          'start': '2017-07-04 12:34:56.123',
          'end': '2018-08-05 01:23:45.456',
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.calendarEvent.index;
        returnBarcodes[0]['calendarEvent'] = calendar;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.calendarEvent);
        expect(barcode.calendarEvent.eventDescription, 'e');
        expect(barcode.calendarEvent.location, 'l');
        expect(barcode.calendarEvent.organizer, 'o');
        expect(barcode.calendarEvent.status, 'st');
        expect(barcode.calendarEvent.summary, 'sm');
        expect(
            barcode.calendarEvent.start, DateTime(2017, 7, 4, 12, 34, 56, 123));
        expect(barcode.calendarEvent.end, DateTime(2018, 8, 5, 1, 23, 45, 456));
      });

      test('detectInImage driversLicense', () async {
        final Map<dynamic, dynamic> driver = <dynamic, dynamic>{
          'firstName': 'fn',
          'middleName': 'mn',
          'lastName': 'ln',
          'gender': 'g',
          'addressCity': 'ac',
          'addressState': 'a',
          'addressStreet': 'st',
          'addressZip': 'az',
          'birthDate': 'bd',
          'documentType': 'dt',
          'licenseNumber': 'l',
          'expiryDate': 'ed',
          'issuingDate': 'id',
          'issuingCountry': 'ic'
        };

        returnBarcodes[0]['valueType'] = BarcodeValueType.driverLicense.index;
        returnBarcodes[0]['driverLicense'] = driver;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.driverLicense);
        expect(barcode.driverLicense.firstName, 'fn');
        expect(barcode.driverLicense.middleName, 'mn');
        expect(barcode.driverLicense.lastName, 'ln');
        expect(barcode.driverLicense.gender, 'g');
        expect(barcode.driverLicense.addressCity, 'ac');
        expect(barcode.driverLicense.addressState, 'a');
        expect(barcode.driverLicense.addressStreet, 'st');
        expect(barcode.driverLicense.addressZip, 'az');
        expect(barcode.driverLicense.birthDate, 'bd');
        expect(barcode.driverLicense.documentType, 'dt');
        expect(barcode.driverLicense.licenseNumber, 'l');
        expect(barcode.driverLicense.expiryDate, 'ed');
        expect(barcode.driverLicense.issuingDate, 'id');
        expect(barcode.driverLicense.issuingCountry, 'ic');
      });

      test('detectInImage no blocks', () async {
        returnValue = <dynamic>[];

        final List<Barcode> blocks = await detector.detectInImage(image);
        expect(blocks, isEmpty);
      });

      test('detectInImage no bounding box', () async {
        returnValue = <dynamic>[
          <dynamic, dynamic>{
            'rawValue': 'potato:raw',
            'displayValue': 'potato:display',
            'valueType': 0,
            'format': 0,
            'points': <dynamic>[
              <dynamic>[17.0, 18.0],
              <dynamic>[19.0, 20.0],
            ],
          },
        ];

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.boundingBox, null);
        expect(barcode.rawValue, 'potato:raw');
        expect(barcode.displayValue, 'potato:display');
        expect(barcode.cornerPoints, const <Offset>[
          Offset(17.0, 18.0),
          Offset(19.0, 20.0),
        ]);
      });

      test('enums match device APIs', () {
        expect(BarcodeValueType.values.length, 13);
        expect(BarcodeValueType.unknown.index, 0);
        expect(BarcodeValueType.contactInfo.index, 1);
        expect(BarcodeValueType.email.index, 2);
        expect(BarcodeValueType.isbn.index, 3);
        expect(BarcodeValueType.phone.index, 4);
        expect(BarcodeValueType.product.index, 5);
        expect(BarcodeValueType.sms.index, 6);
        expect(BarcodeValueType.text.index, 7);
        expect(BarcodeValueType.url.index, 8);
        expect(BarcodeValueType.wifi.index, 9);
        expect(BarcodeValueType.geographicCoordinates.index, 10);
        expect(BarcodeValueType.calendarEvent.index, 11);
        expect(BarcodeValueType.driverLicense.index, 12);

        expect(BarcodeEmailType.values.length, 3);
        expect(BarcodeEmailType.unknown.index, 0);
        expect(BarcodeEmailType.work.index, 1);
        expect(BarcodeEmailType.home.index, 2);

        expect(BarcodePhoneType.values.length, 5);
        expect(BarcodePhoneType.unknown.index, 0);
        expect(BarcodePhoneType.work.index, 1);
        expect(BarcodePhoneType.home.index, 2);
        expect(BarcodePhoneType.fax.index, 3);
        expect(BarcodePhoneType.mobile.index, 4);

        expect(BarcodeWiFiEncryptionType.values.length, 4);
        expect(BarcodeWiFiEncryptionType.unknown.index, 0);
        expect(BarcodeWiFiEncryptionType.open.index, 1);
        expect(BarcodeWiFiEncryptionType.wpa.index, 2);
        expect(BarcodeWiFiEncryptionType.wep.index, 3);

        expect(BarcodeAddressType.values.length, 3);
        expect(BarcodeAddressType.unknown.index, 0);
        expect(BarcodeAddressType.work.index, 1);
        expect(BarcodeAddressType.home.index, 2);
      });

      group('$BarcodeDetectorOptions', () {
        test('barcodeFormats', () async {
          // The constructor for `BarcodeDetectorOptions` can't be `const`
          // without triggering a `CONST_EVAL_TYPE_BOOL_INT` error.
          // ignore: prefer_const_constructors
          final BarcodeDetectorOptions options = BarcodeDetectorOptions(
            barcodeFormats: BarcodeFormat.code128 |
                BarcodeFormat.dataMatrix |
                BarcodeFormat.ean8,
          );

          final BarcodeDetector detector =
              FirebaseVision.instance.barcodeDetector(options);
          await detector.detectInImage(image);

          expect(
            log[0].arguments['options']['barcodeFormats'],
            0x0001 | 0x0010 | 0x0040,
          );
        });
      });
    });

    group('$FaceDetector', () {
      List<dynamic> testFaces;

      setUp(() {
        testFaces = <dynamic>[
          <dynamic, dynamic>{
            'left': 0.0,
            'top': 1.0,
            'width': 2.0,
            'height': 3.0,
            'headEulerAngleY': 4.0,
            'headEulerAngleZ': 5.0,
            'leftEyeOpenProbability': 0.4,
            'rightEyeOpenProbability': 0.5,
            'smilingProbability': 0.2,
            'trackingId': 8,
            'landmarks': <dynamic, dynamic>{
              'bottomMouth': <dynamic>[0.1, 1.1],
              'leftCheek': <dynamic>[2.1, 3.1],
              'leftEar': <dynamic>[4.1, 5.1],
              'leftEye': <dynamic>[6.1, 7.1],
              'leftMouth': <dynamic>[8.1, 9.1],
              'noseBase': <dynamic>[10.1, 11.1],
              'rightCheek': <dynamic>[12.1, 13.1],
              'rightEar': <dynamic>[14.1, 15.1],
              'rightEye': <dynamic>[16.1, 17.1],
              'rightMouth': <dynamic>[18.1, 19.1],
            },
          },
        ];
      });

      test('processImage', () async {
        returnValue = testFaces;

        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(
            enableClassification: true,
            enableLandmarks: true,
            enableTracking: false,
            minFaceSize: 0.5,
            mode: FaceDetectorMode.accurate,
          ),
        );

        final FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<Face> faces = await detector.processImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'FaceDetector#processImage',
            arguments: <String, dynamic>{
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'enableClassification': true,
                'enableLandmarks': true,
                'enableTracking': false,
                'minFaceSize': 0.5,
                'mode': 'accurate',
              },
            },
          ),
        ]);

        final Face face = faces[0];
        expect(face.boundingBox, Rect.fromLTWH(0.0, 1.0, 2.0, 3.0));
        expect(face.headEulerAngleY, 4.0);
        expect(face.headEulerAngleZ, 5.0);
        expect(face.leftEyeOpenProbability, 0.4);
        expect(face.rightEyeOpenProbability, 0.5);
        expect(face.smilingProbability, 0.2);
        expect(face.trackingId, 8);

        for (FaceLandmarkType type in FaceLandmarkType.values) {
          expect(face.getLandmark(type).type, type);
        }

        Offset p(FaceLandmarkType type) {
          return face.getLandmark(type).position;
        }

        expect(p(FaceLandmarkType.bottomMouth), const Offset(0.1, 1.1));
        expect(p(FaceLandmarkType.leftCheek), const Offset(2.1, 3.1));
        expect(p(FaceLandmarkType.leftEar), const Offset(4.1, 5.1));
        expect(p(FaceLandmarkType.leftEye), const Offset(6.1, 7.1));
        expect(p(FaceLandmarkType.leftMouth), const Offset(8.1, 9.1));
        expect(p(FaceLandmarkType.noseBase), const Offset(10.1, 11.1));
        expect(p(FaceLandmarkType.rightCheek), const Offset(12.1, 13.1));
        expect(p(FaceLandmarkType.rightEar), const Offset(14.1, 15.1));
        expect(p(FaceLandmarkType.rightEye), const Offset(16.1, 17.1));
        expect(p(FaceLandmarkType.rightMouth), const Offset(18.1, 19.1));
      });

      test('processImage with null landmark', () async {
        testFaces[0]['landmarks']['bottomMouth'] = null;
        returnValue = testFaces;

        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(),
        );
        final FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<Face> faces = await detector.processImage(image);

        expect(faces[0].getLandmark(FaceLandmarkType.bottomMouth), isNull);
      });

      test('processImage no faces', () async {
        returnValue = <dynamic>[];

        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(),
        );
        final FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<Face> faces = await detector.processImage(image);
        expect(faces, isEmpty);
      });
    });

    group('$TextRecognizer', () {
      final TextRecognizer recognizer =
          FirebaseVision.instance.textRecognizer();
      final FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(
        'empty',
      );

      setUp(() {
        final List<dynamic> elements = <dynamic>[
          <dynamic, dynamic>{
            'text': 'hello',
            'left': 1.0,
            'top': 2.0,
            'width': 3.0,
            'height': 4.0,
            'points': <dynamic>[
              <dynamic>[5.0, 6.0],
              <dynamic>[7.0, 8.0],
            ],
            'recognizedLanguages': <dynamic>[
              <dynamic, dynamic>{
                'languageCode': 'ab',
              },
              <dynamic, dynamic>{
                'languageCode': 'cd',
              }
            ],
            'confidence': 0.1,
          },
          <dynamic, dynamic>{
            'text': 'my',
            'left': 4.0,
            'top': 3.0,
            'width': 2.0,
            'height': 1.0,
            'points': <dynamic>[
              <dynamic>[6.0, 5.0],
              <dynamic>[8.0, 7.0],
            ],
            'recognizedLanguages': <dynamic>[],
            'confidence': 0.2,
          },
        ];

        final List<dynamic> lines = <dynamic>[
          <dynamic, dynamic>{
            'text': 'friend',
            'left': 5.0,
            'top': 6.0,
            'width': 7.0,
            'height': 8.0,
            'points': <dynamic>[
              <dynamic>[9.0, 10.0],
              <dynamic>[11.0, 12.0],
            ],
            'recognizedLanguages': <dynamic>[
              <dynamic, dynamic>{
                'languageCode': 'ef',
              },
              <dynamic, dynamic>{
                'languageCode': 'gh',
              }
            ],
            'elements': elements,
            'confidence': 0.3,
          },
          <dynamic, dynamic>{
            'text': 'how',
            'left': 8.0,
            'top': 7.0,
            'width': 4.0,
            'height': 5.0,
            'points': <dynamic>[
              <dynamic>[10.0, 9.0],
              <dynamic>[12.0, 11.0],
            ],
            'recognizedLanguages': <dynamic>[],
            'elements': <dynamic>[],
            'confidence': 0.4,
          },
        ];

        final List<dynamic> blocks = <dynamic>[
          <dynamic, dynamic>{
            'text': 'friend',
            'left': 13.0,
            'top': 14.0,
            'width': 15.0,
            'height': 16.0,
            'points': <dynamic>[
              <dynamic>[17.0, 18.0],
              <dynamic>[19.0, 20.0],
            ],
            'recognizedLanguages': <dynamic>[
              <dynamic, dynamic>{
                'languageCode': 'ij',
              },
              <dynamic, dynamic>{
                'languageCode': 'kl',
              }
            ],
            'lines': lines,
            'confidence': 0.5,
          },
          <dynamic, dynamic>{
            'text': 'hello',
            'left': 14.0,
            'top': 13.0,
            'width': 16.0,
            'height': 15.0,
            'points': <dynamic>[
              <dynamic>[18.0, 17.0],
              <dynamic>[20.0, 19.0],
            ],
            'recognizedLanguages': <dynamic>[],
            'lines': <dynamic>[],
            'confidence': 0.6,
          },
        ];

        final dynamic visionText = <dynamic, dynamic>{
          'text': 'testext',
          'blocks': blocks,
        };

        returnValue = visionText;
      });

      group('$TextBlock', () {
        test('processImage', () async {
          final VisionText text = await recognizer.processImage(image);

          expect(text.blocks, hasLength(2));

          TextBlock block = text.blocks[0];
          expect(block.boundingBox, Rect.fromLTWH(13.0, 14.0, 15.0, 16.0));
          expect(block.text, 'friend');
          expect(block.cornerPoints, const <Offset>[
            Offset(17.0, 18.0),
            Offset(19.0, 20.0),
          ]);
          expect(block.recognizedLanguages, hasLength(2));
          expect(block.recognizedLanguages[0].languageCode, 'ij');
          expect(block.recognizedLanguages[1].languageCode, 'kl');
          expect(block.confidence, 0.5);

          block = text.blocks[1];
          expect(block.boundingBox, Rect.fromLTWH(14.0, 13.0, 16.0, 15.0));
          expect(block.text, 'hello');
          expect(block.cornerPoints, const <Offset>[
            Offset(18.0, 17.0),
            Offset(20.0, 19.0),
          ]);
          expect(block.confidence, 0.6);
        });
      });

      group('$TextLine', () {
        test('processImage', () async {
          final VisionText text = await recognizer.processImage(image);

          TextLine line = text.blocks[0].lines[0];
          expect(line.boundingBox, Rect.fromLTWH(5, 6, 7, 8));
          expect(line.text, 'friend');
          expect(line.cornerPoints, const <Offset>[
            Offset(9.0, 10.0),
            Offset(11.0, 12.0),
          ]);
          expect(line.recognizedLanguages, hasLength(2));
          expect(line.recognizedLanguages[0].languageCode, 'ef');
          expect(line.recognizedLanguages[1].languageCode, 'gh');
          expect(line.confidence, 0.3);

          line = text.blocks[0].lines[1];
          expect(line.boundingBox, Rect.fromLTWH(8.0, 7.0, 4.0, 5.0));
          expect(line.text, 'how');
          expect(line.cornerPoints, const <Offset>[
            Offset(10.0, 9.0),
            Offset(12.0, 11.0),
          ]);
          expect(line.confidence, 0.4);
        });
      });

      group('$TextElement', () {
        test('processImage', () async {
          final VisionText text = await recognizer.processImage(image);

          TextElement element = text.blocks[0].lines[0].elements[0];
          expect(element.boundingBox, Rect.fromLTWH(1.0, 2.0, 3.0, 4.0));
          expect(element.text, 'hello');
          expect(element.cornerPoints, const <Offset>[
            Offset(5.0, 6.0),
            Offset(7.0, 8.0),
          ]);
          expect(element.recognizedLanguages, hasLength(2));
          expect(element.recognizedLanguages[0].languageCode, 'ab');
          expect(element.recognizedLanguages[1].languageCode, 'cd');
          expect(element.confidence, 0.1);

          element = text.blocks[0].lines[0].elements[1];
          expect(element.boundingBox, Rect.fromLTWH(4.0, 3.0, 2.0, 1.0));
          expect(element.text, 'my');
          expect(element.cornerPoints, const <Offset>[
            Offset(6.0, 5.0),
            Offset(8.0, 7.0),
          ]);
          expect(element.confidence, 0.2);
        });
      });

      test('processImage', () async {
        final VisionText text = await recognizer.processImage(image);

        expect(text.text, 'testext');
        expect(log, <Matcher>[
          isMethodCall(
            'TextRecognizer#processImage',
            arguments: <String, dynamic>{
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{},
            },
          ),
        ]);
      });

      test('processImage no bounding box', () async {
        returnValue = <dynamic, dynamic>{
          'blocks': <dynamic>[
            <dynamic, dynamic>{
              'text': '',
              'points': <dynamic>[],
              'recognizedLanguages': <dynamic>[],
              'lines': <dynamic>[],
            },
          ],
        };

        final VisionText text = await recognizer.processImage(image);

        final TextBlock block = text.blocks[0];
        expect(block.boundingBox, null);
      });
    });
  });
}
