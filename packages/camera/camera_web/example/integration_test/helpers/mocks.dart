// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:camera_web/src/camera_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockWindow extends Mock implements Window {}

class MockNavigator extends Mock implements Navigator {}

class MockMediaDevices extends Mock implements MediaDevices {}

class MockCameraSettings extends Mock implements CameraSettings {}

class MockMediaStreamTrack extends Mock implements MediaStreamTrack {}

/// A fake [MediaStream] that returns the provided [_videoTracks].
class FakeMediaStream extends Fake implements MediaStream {
  FakeMediaStream(this._videoTracks);

  final List<MediaStreamTrack> _videoTracks;

  @override
  List<MediaStreamTrack> getVideoTracks() => _videoTracks;
}

/// A fake [MediaDeviceInfo] that returns the provided [_deviceId], [_label] and [_kind].
class FakeMediaDeviceInfo extends Fake implements MediaDeviceInfo {
  FakeMediaDeviceInfo(this._deviceId, this._label, this._kind);

  final String _deviceId;
  final String _label;
  final String _kind;

  @override
  String? get deviceId => _deviceId;

  @override
  String? get label => _label;

  @override
  String? get kind => _kind;
}

/// A fake [DomException] that returns the provided error [_name].
class FakeDomException extends Fake implements DomException {
  FakeDomException(this._name);

  final String _name;

  @override
  String get name => _name;
}
