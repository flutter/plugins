// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of ios_camera;

enum _CaptureInputClass { captureDeviceInput }

abstract class CaptureInput with NativeMethodCallHandler, CameraMappable {
  List<CaptureInputPort> get ports;
}

class CaptureInputPort with NativeMethodCallHandler, CameraMappable {
  CaptureInputPort._(this.input);

  final CaptureInput input;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{'handle': handle, 'inputHandle': input.handle};
  }
}

class CaptureDeviceInput extends CaptureInput {
  CaptureDeviceInput({@required this.device}) : assert(device != null) {
    _ports = <CaptureInputPort>[CaptureInputPort._(this)];
  }

  static const _CaptureInputClass _inputClass =
      _CaptureInputClass.captureDeviceInput;

  final CaptureDevice device;
  List<CaptureInputPort> _ports;

  @override
  List<CaptureInputPort> get ports {
    return List<CaptureInputPort>.unmodifiable(_ports);
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': handle,
      'class': _inputClass.toString(),
      'device': device.asMap(),
      'ports': ports
          .map<Map<String, dynamic>>((CaptureInputPort port) => port.asMap())
          .toList(),
    };
  }
}
