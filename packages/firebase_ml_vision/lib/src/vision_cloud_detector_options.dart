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
      {this.maxResults = 10, this.modelType = modelTypeStable})
      : assert(maxResults > 0),
        assert(modelType == modelTypeLatest || modelType == modelTypeStable);

  static const int modelTypeStable = 1;
  static const int modelTypeLatest = 2;

  /// The number of results to be returned.
  ///
  /// Defaults to 10.
  /// Required to be greater than zero.
  final int maxResults;

  /// The type of model to use for the detection..
  ///
  /// Defaults to [modelTypeStable]
  /// Required to be [modelTypeStable] or [modelTypeLatest].
  final int modelType;
}
