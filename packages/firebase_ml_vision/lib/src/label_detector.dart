// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

class LabelDetector extends FirebaseVisionDetector {
  LabelDetector._(LabelDetectorOptions options);

  @override
  Future<void> close() async {
    // TODO: implement close
  }

  @override
  Future<void> detectInImage(FirebaseVisionImage visionImage) async {
    // TODO: implement detectInImage
  }
}

class LabelDetectorOptions {}
