// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Options for cloud vision detectors.
///
class VisionCloudDetectorOptions {
  /// Constructor for [VisionCloudDetectorOptions].
  ///
  const VisionCloudDetectorOptions(
      {this.maxResults = 10, this.modelType = MODEL_TYPE_STABLE})
      : assert(maxResults > 0),
        assert(
            modelType == MODEL_TYPE_LATEST || modelType == MODEL_TYPE_STABLE);

  static const int MODEL_TYPE_STABLE = 1;
  static const int MODEL_TYPE_LATEST = 2;

  /// The number of results to be returned.
  /// Defaults to 10.
  /// Required to be greater than zero.
  final int maxResults;

  /// The type of model to use for the detection..
  /// Defaults to [MODEL_TYPE_STABLE]
  /// Required to be [MODEL_TYPE_STABLE] or [MODEL_TYPE_LATEST].
  final int modelType;
}
