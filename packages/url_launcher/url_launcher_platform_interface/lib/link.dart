// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for a function provided by the [Link] widget that instructs it to
/// follow the link.
typedef FollowLink = Future<void> Function();

/// Signature for a builder function passed to the [Link] widget to construct
/// the widget tree under it.
typedef LinkWidgetBuilder = Widget Function(
  BuildContext context,
  FollowLink followLink,
);

/// Signature for a delegate function to build the [Link] widget.
typedef LinkDelegate = Widget Function(Link linkWidget);

/// Defines where a Link URL should be open.
///
/// This is a class instead of an enum to allow future customizability e.g.
/// opening a link in a specific iframe.
class LinkTarget {
  /// Const private constructor with a [debugLabel] to allow the creation of
  /// multiple distinct const instances.
  const LinkTarget._({this.debugLabel});

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

/// Used to override the delegate that builds the link.
set linkDelegate(LinkDelegate delegate) {
  Link._linkDelegate = delegate;
}

/// A widget that renders a real link on the web, and uses WebViews in native
/// platforms to open links.
///
/// Example link to an external URL:
///
/// ```dart
/// Link(
///   uri: Uri.parse('https://flutter.dev'),
///   builder: (BuildContext context, FollowLink followLink) => RaisedButton(
///     onPressed: followLink,
///     // ... other properties here ...
///   )},
/// );
/// ```
///
/// Example link to a route name within the app:
///
/// ```dart
/// Link(
///   uri: Uri.parse('/home'),
///   builder: (BuildContext context, FollowLink followLink) => RaisedButton(
///     onPressed: followLink,
///     // ... other properties here ...
///   )},
/// );
/// ```
class Link extends StatelessWidget {
  /// Called at build time to construct the widget tree under the link.
  final LinkWidgetBuilder builder;

  /// The destination that this link leads to.
  final Uri uri;

  /// The target indicating where to open the link.
  final LinkTarget target;

  /// Whether the link is disabled or not.
  bool get isDisabled => uri == null;

  static LinkDelegate _linkDelegate = (Link link) => _DefaultLinkDelegate(link);

  /// Creates a widget that renders a real link on the web, and uses WebViews in
  /// native platforms to open links.
  Link({
    Key key,
    @required this.uri,
    LinkTarget target,
    @required this.builder,
  })  : target = target ?? LinkTarget.defaultTarget,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return _linkDelegate(this);
  }
}

class _DefaultLinkDelegate extends StatelessWidget {
  const _DefaultLinkDelegate(this.link);

  final Link link;

  Future<void> _followLink() {
    // The default link delegate uses url launcher to open URIs.
    // TODO(mdebbar): use url_launcher.
    return Future<void>.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return link.builder(context, link.isDisabled ? null : _followLink);
  }
}
