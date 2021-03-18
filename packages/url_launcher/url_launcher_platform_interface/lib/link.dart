// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Signature for a function provided by the [Link] widget that instructs it to
/// follow the link.
typedef FollowLink = Future<void> Function();

/// Signature for a builder function passed to the [Link] widget to construct
/// the widget tree under it.
typedef LinkWidgetBuilder = Widget Function(
  BuildContext context,
  FollowLink? followLink,
);

/// Signature for a delegate function to build the [Link] widget.
typedef LinkDelegate = Widget Function(LinkInfo linkWidget);

final MethodCodec _codec = const JSONMethodCodec();

/// Defines where a Link URL should be open.
///
/// This is a class instead of an enum to allow future customizability e.g.
/// opening a link in a specific iframe.
class LinkTarget {
  /// Const private constructor with a [debugLabel] to allow the creation of
  /// multiple distinct const instances.
  const LinkTarget._({required this.debugLabel});

  /// Used to distinguish multiple const instances of [LinkTarget].
  final String debugLabel;

  /// Use the default target for each platform.
  ///
  /// On Android, the default is [blank]. On the web, the default is [self].
  ///
  /// iOS, on the other hand, defaults to [self] for web URLs, and [blank] for
  /// non-web URLs.
  static const defaultTarget = LinkTarget._(debugLabel: 'defaultTarget');

  /// On the web, this opens the link in the same tab where the flutter app is
  /// running.
  ///
  /// On Android and iOS, this opens the link in a webview within the app.
  static const self = LinkTarget._(debugLabel: 'self');

  /// On the web, this opens the link in a new tab or window (depending on the
  /// browser and user configuration).
  ///
  /// On Android and iOS, this opens the link in the browser or the relevant
  /// app.
  static const blank = LinkTarget._(debugLabel: 'blank');
}

/// Encapsulates all the information necessary to build a Link widget.
abstract class LinkInfo {
  /// Called at build time to construct the widget tree under the link.
  LinkWidgetBuilder get builder;

  /// The destination that this link leads to.
  Uri? get uri;

  /// The target indicating where to open the link.
  LinkTarget get target;

  /// Whether the link is disabled or not.
  bool get isDisabled;
}

/// Pushes the [routeName] into Flutter's navigation system via a platform
/// message.
Future<ByteData> pushRouteNameToFramework(
  BuildContext context,
  String routeName, {
  @visibleForTesting bool debugForceRouter = false,
}) {
  final PlatformMessageCallback? onPlatformMessage = window.onPlatformMessage;
  if (onPlatformMessage == null) {
    return Future<ByteData>.value(null);
  }
  final Completer<ByteData> completer = Completer<ByteData>();
  if (debugForceRouter || _hasRouter(context)) {
    SystemNavigator.routeInformationUpdated(location: routeName);
    onPlatformMessage(
      'flutter/navigation',
      _codec.encodeMethodCall(
        MethodCall('pushRouteInformation', <dynamic, dynamic>{
          'location': routeName,
          'state': null,
        }),
      ),
      completer.complete,
    );
  } else {
    onPlatformMessage(
      'flutter/navigation',
      _codec.encodeMethodCall(MethodCall('pushRoute', routeName)),
      completer.complete,
    );
  }
  return completer.future;
}

bool _hasRouter(BuildContext context) {
  try {
    return Router.of(context) != null;
  } on AssertionError {
    // When a `Router` can't be found, an assertion error is thrown.
    return false;
  }
}
