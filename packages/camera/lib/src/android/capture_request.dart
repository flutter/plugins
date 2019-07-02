// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of android_camera;

class CaptureRequest with CameraMappable {
  const CaptureRequest._({
    @required this.template,
    @required this.targets,
    this.jpegQuality,
  })  : assert(template != null),
        assert(targets != null),
        assert(jpegQuality == null || (jpegQuality >= 1 && jpegQuality <= 100));

  factory CaptureRequest._fromMap({
    @required Template template,
    @required Map<String, dynamic> map,
  }) {
    return CaptureRequest._(
      template: template,
      jpegQuality: map['jpeqQuality'],
      targets: List<Surface>.unmodifiable(<Surface>[]),
    );
  }

  final Template template;
  final List<Surface> targets;
  final int jpegQuality;

  CaptureRequest copyWith({List<Surface> targets, int jpegQuality}) {
    return CaptureRequest._(
      template: template,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      targets: List<Surface>.unmodifiable(targets ?? this.targets),
    );
  }

  @override
  Map<String, dynamic> asMap() {
    final List<Map<String, dynamic>> outputData = targets
        .map<Map<String, dynamic>>((Surface surface) => surface.asMap())
        .toList();

    return Map<String, dynamic>.unmodifiable(<String, dynamic>{
      'template': template.toString(),
      'jpegQuality': jpegQuality,
      'targets': outputData,
    });
  }
}
