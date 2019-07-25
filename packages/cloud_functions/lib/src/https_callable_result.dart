// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of cloud_functions;

/// The result of calling a HttpsCallable function.
class HttpsCallableResult {
  HttpsCallableResult._(this.data);

  /// Returns the data that was returned from the Callable HTTPS trigger.
  final dynamic data;
}
