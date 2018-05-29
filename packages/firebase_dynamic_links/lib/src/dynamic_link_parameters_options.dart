// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// For specifying length for short Dynamic Links.
enum ShortDynamicLinkPathLength { unguessable, short }

/// Options class for defining how Dynamic Link URLs are generated.
class DynamicLinkParametersOptions {
  DynamicLinkParametersOptions({this.shortDynamicLinkPathLength});

  /// Specifies the length of the path component of a short Dynamic Link.
  final ShortDynamicLinkPathLength shortDynamicLinkPathLength;

  Map<String, dynamic> get _data => <String, dynamic>{
        'shortDynamicLinkPathLength': shortDynamicLinkPathLength?.index,
      };
}
