// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

enum ShortDynamicLinkPathLength {unguessable, short}

class DynamicLinkComponentsOptions {
  DynamicLinkComponentsOptions([this.shortDynamicLinkPathLength]);

  final ShortDynamicLinkPathLength shortDynamicLinkPathLength;

  Map<String, dynamic> get _data => <String, dynamic>{
        'shortDynamicLinkPathLength': shortDynamicLinkPathLength?.index,
      };
}
