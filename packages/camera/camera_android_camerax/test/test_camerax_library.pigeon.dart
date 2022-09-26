// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v3.2.9), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import
// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;
import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camera_android_camerax/src/camerax_library.pigeon.dart';

class _TestJavaObjectHostApiCodec extends StandardMessageCodec {
  const _TestJavaObjectHostApiCodec();
}
abstract class TestJavaObjectHostApi {
  static const MessageCodec<Object?> codec = _TestJavaObjectHostApiCodec();

  void dispose(int identifier);
  static void setup(TestJavaObjectHostApi? api, {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.JavaObjectHostApi.dispose', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMockMessageHandler(null);
      } else {
        channel.setMockMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.JavaObjectHostApi.dispose was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_identifier = (args[0] as int?);
          assert(arg_identifier != null, 'Argument for dev.flutter.pigeon.JavaObjectHostApi.dispose was null, expected non-null int.');
          api.dispose(arg_identifier!);
          return <Object?, Object?>{};
        });
      }
    }
  }
}

class _TestCameraInfoHostApiCodec extends StandardMessageCodec {
  const _TestCameraInfoHostApiCodec();
}
abstract class TestCameraInfoHostApi {
  static const MessageCodec<Object?> codec = _TestCameraInfoHostApiCodec();

  int getSensorRotationDegrees(int identifier);
  static void setup(TestCameraInfoHostApi? api, {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CameraInfoHostApi.getSensorRotationDegrees', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMockMessageHandler(null);
      } else {
        channel.setMockMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CameraInfoHostApi.getSensorRotationDegrees was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_identifier = (args[0] as int?);
          assert(arg_identifier != null, 'Argument for dev.flutter.pigeon.CameraInfoHostApi.getSensorRotationDegrees was null, expected non-null int.');
          final int output = api.getSensorRotationDegrees(arg_identifier!);
          return <Object?, Object?>{'result': output};
        });
      }
    }
  }
}

class _TestCameraSelectorHostApiCodec extends StandardMessageCodec {
  const _TestCameraSelectorHostApiCodec();
}
abstract class TestCameraSelectorHostApi {
  static const MessageCodec<Object?> codec = _TestCameraSelectorHostApiCodec();

  void create(int identifier, int? lensFacing);
  List<int?> filter(int identifier, List<int?> cameraInfoIds);
  static void setup(TestCameraSelectorHostApi? api, {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CameraSelectorHostApi.create', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMockMessageHandler(null);
      } else {
        channel.setMockMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CameraSelectorHostApi.create was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_identifier = (args[0] as int?);
          assert(arg_identifier != null, 'Argument for dev.flutter.pigeon.CameraSelectorHostApi.create was null, expected non-null int.');
          final int? arg_lensFacing = (args[1] as int?);
          api.create(arg_identifier!, arg_lensFacing);
          return <Object?, Object?>{};
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CameraSelectorHostApi.filter', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMockMessageHandler(null);
      } else {
        channel.setMockMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CameraSelectorHostApi.filter was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_identifier = (args[0] as int?);
          assert(arg_identifier != null, 'Argument for dev.flutter.pigeon.CameraSelectorHostApi.filter was null, expected non-null int.');
          final List<int?>? arg_cameraInfoIds = (args[1] as List<Object?>?)?.cast<int?>();
          assert(arg_cameraInfoIds != null, 'Argument for dev.flutter.pigeon.CameraSelectorHostApi.filter was null, expected non-null List<int?>.');
          final List<int?> output = api.filter(arg_identifier!, arg_cameraInfoIds!);
          return <Object?, Object?>{'result': output};
        });
      }
    }
  }
}

class _TestProcessCameraProviderHostApiCodec extends StandardMessageCodec {
  const _TestProcessCameraProviderHostApiCodec();
}
abstract class TestProcessCameraProviderHostApi {
  static const MessageCodec<Object?> codec = _TestProcessCameraProviderHostApiCodec();

  Future<int> getInstance();
  List<int?> getAvailableCameraInfos(int instanceId);
  static void setup(TestProcessCameraProviderHostApi? api, {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.ProcessCameraProviderHostApi.getInstance', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMockMessageHandler(null);
      } else {
        channel.setMockMessageHandler((Object? message) async {
          // ignore message
          final int output = await api.getInstance();
          return <Object?, Object?>{'result': output};
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.ProcessCameraProviderHostApi.getAvailableCameraInfos', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMockMessageHandler(null);
      } else {
        channel.setMockMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.ProcessCameraProviderHostApi.getAvailableCameraInfos was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_instanceId = (args[0] as int?);
          assert(arg_instanceId != null, 'Argument for dev.flutter.pigeon.ProcessCameraProviderHostApi.getAvailableCameraInfos was null, expected non-null int.');
          final List<int?> output = api.getAvailableCameraInfos(arg_instanceId!);
          return <Object?, Object?>{'result': output};
        });
      }
    }
  }
}
