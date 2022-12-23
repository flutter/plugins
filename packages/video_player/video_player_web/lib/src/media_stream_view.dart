// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/widgets.dart';

import 'shims/dart_ui.dart' as ui;
import 'video_player.dart';

/// Wraps a [HtmlElementView] which can render [html.MediaStream].
class MediaStreamView extends StatefulWidget {
  /// Create a [MediaStreamView] from a [VideoPlayer] instance.
  const MediaStreamView({
    Key? key,
    required this.mediaStream,
  }) : super(key: key);

  /// The [html.MediaStream] content to render into a [html.VideoElement].
  final html.MediaStream mediaStream;

  @override
  MediaStreamViewState createState() => MediaStreamViewState();
}

/// The state of [MediaStreamView].
class MediaStreamViewState extends State<MediaStreamView> {
  late final html.VideoElement _videoElement;

  String get _viewType => 'videoPlayer-${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    _videoElement = html.VideoElement()
      ..id = 'videoElement-${identityHashCode(this)}'
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..muted = true
      ..autoplay = true
      ..controls = false
      ..srcObject = widget.mediaStream;
    // TODO(hterkelsen): Use initialization parameters once they are available
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement,
    );
  }

  @override
  void didUpdateWidget(MediaStreamView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mediaStream != oldWidget.mediaStream) {
      _videoElement.srcObject = widget.mediaStream;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }

  @override
  void dispose() {
    _videoElement.srcObject = null;
    super.dispose();
  }
}
