// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/v4/src/types/types.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewCookieManagerCreationParams] for
/// more information.
@immutable
class AndroidWebViewCookieManagerCreationParams
    extends PlatformWebViewCookieManagerCreationParams {
  /// Creates a new [AndroidWebViewCookieManagerCreationParams] instance.
  const AndroidWebViewCookieManagerCreationParams._(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewCookieManagerCreationParams params,
  ) : super();

  /// Creates a [AndroidWebViewCookieManagerCreationParams] instance based on [PlatformWebViewCookieManagerCreationParams].
  factory AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
      PlatformWebViewCookieManagerCreationParams params) {
    return AndroidWebViewCookieManagerCreationParams._(params);
  }
}
