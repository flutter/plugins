// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

class AndroidParameters {
  AndroidParameters(
      {this.fallbackUrl, this.minimumVersion, @required this.packageName});

  final Uri fallbackUrl;
  final int minimumVersion;
  final String packageName;

  Map<String, dynamic> get _data => <String, dynamic>{
        'fallbackUrl': fallbackUrl?.toString(),
        'minimumVersion': minimumVersion,
        'packageName': packageName,
      };
}
