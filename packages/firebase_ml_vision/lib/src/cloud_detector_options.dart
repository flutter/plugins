// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Model types for cloud vision APIs.
enum CloudModelType { stable, latest }

/// Options for cloud vision detectors.
class CloudDetectorOptions {
  /// Constructor for [CloudDetectorOptions].
  ///
  /// [maxResults] must be greater than 0, otherwise AssertionError is thrown.
  /// Default is 10.
  ///
  /// [modelType] has default [CloudModelType.stable].
  const CloudDetectorOptions(
      {this.maxResults = 10, this.modelType = CloudModelType.stable})
      : assert(maxResults > 0),
        assert(modelType != null);

  /// The number of results to be returned.
  ///
  /// Defaults to 10.
  /// Required to be greater than zero.
  final int maxResults;

  /// The type of model to use for the detection.
  final CloudModelType modelType;

  Map<String, dynamic> _serialize() => <String, dynamic>{
        'maxResults': maxResults,
        'modelType': _enumToString(modelType),
      };
}
