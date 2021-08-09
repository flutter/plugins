// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

void main() {
  group('CameraErrorCode', () {
    group('toString returns a correct type for', () {
      test('notSupported', () {
        expect(
          CameraErrorCode.notSupported.toString(),
          equals('cameraNotSupported'),
        );
      });

      test('notFound', () {
        expect(
          CameraErrorCode.notFound.toString(),
          equals('cameraNotFound'),
        );
      });

      test('notReadable', () {
        expect(
          CameraErrorCode.notReadable.toString(),
          equals('cameraNotReadable'),
        );
      });

      test('overconstrained', () {
        expect(
          CameraErrorCode.overconstrained.toString(),
          equals('cameraOverconstrained'),
        );
      });

      test('permissionDenied', () {
        expect(
          CameraErrorCode.permissionDenied.toString(),
          equals('cameraPermission'),
        );
      });

      test('type', () {
        expect(
          CameraErrorCode.type.toString(),
          equals('cameraType'),
        );
      });

      test('abort', () {
        expect(
          CameraErrorCode.abort.toString(),
          equals('cameraAbort'),
        );
      });

      test('security', () {
        expect(
          CameraErrorCode.security.toString(),
          equals('cameraSecurity'),
        );
      });

      test('missingMetadata', () {
        expect(
          CameraErrorCode.missingMetadata.toString(),
          equals('cameraMissingMetadata'),
        );
      });

      test('orientationNotSupported', () {
        expect(
          CameraErrorCode.orientationNotSupported.toString(),
          equals('orientationNotSupported'),
        );
      });

      test('unknown', () {
        expect(
          CameraErrorCode.unknown.toString(),
          equals('cameraUnknown'),
        );
      });

      group('fromMediaError', () {
        test('with aborted error code', () {
          expect(
            CameraErrorCode.fromMediaError(
              FakeMediaError(MediaError.MEDIA_ERR_ABORTED),
            ).toString(),
            equals('mediaErrorAborted'),
          );
        });

        test('with network error code', () {
          expect(
            CameraErrorCode.fromMediaError(
              FakeMediaError(MediaError.MEDIA_ERR_NETWORK),
            ).toString(),
            equals('mediaErrorNetwork'),
          );
        });

        test('with decode error code', () {
          expect(
            CameraErrorCode.fromMediaError(
              FakeMediaError(MediaError.MEDIA_ERR_DECODE),
            ).toString(),
            equals('mediaErrorDecode'),
          );
        });

        test('with source not supported error code', () {
          expect(
            CameraErrorCode.fromMediaError(
              FakeMediaError(MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED),
            ).toString(),
            equals('mediaErrorSourceNotSupported'),
          );
        });

        test('with unknown error code', () {
          expect(
            CameraErrorCode.fromMediaError(
              FakeMediaError(5),
            ).toString(),
            equals('mediaErrorUnknown'),
          );
        });
      });
    });
  });
}
