import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

export 'package:video_player/video_player.dart';

class VideoControllerProvider extends StatefulWidget {
  const VideoControllerProvider.asset({
    Key key,
    @required this.source,
    @required this.child,
  })  : type = DataSourceType.asset,
        _file = null,
        super(key: key);

  const VideoControllerProvider.network({
    Key key,
    @required this.source,
    @required this.child,
  })  : type = DataSourceType.network,
        _file = null,
        super(key: key);

  const VideoControllerProvider.file({
    Key key,
    File file,
    @required this.child,
  })  : _file = file,
        type = DataSourceType.file,
        source = null,
        super(key: key);

  final Widget child;
  final String source;
  final File _file;
  final DataSourceType type;

  @override
  _VideoProviderState createState() => _VideoProviderState();

  static VideoPlayerController of(BuildContext context) {
    final _VideoProviderInherited provider = context
        .ancestorInheritedElementForWidgetOfExactType(_VideoProviderInherited)
        ?.widget;
    return provider?.controller;
  }
}

class _VideoProviderState extends State<VideoControllerProvider> {
  VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    switch (widget.type) {
      case DataSourceType.asset:
        controller = VideoPlayerController.asset(widget.source);
        break;
      case DataSourceType.network:
        controller = VideoPlayerController.network(widget.source);
        break;
      case DataSourceType.file:
        controller = VideoPlayerController.file(widget._file);
        break;
      default:
        throw Exception('Could not create the VideoPlayerController.');
    }

    controller?.setVolume(1.0);
  }

  @override
  void dispose() {
    controller?.setVolume(0.0);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _VideoProviderInherited(
      controller: controller,
      child: widget.child,
    );
  }
}

class _VideoProviderInherited extends InheritedWidget {
  const _VideoProviderInherited({
    Key key,
    @required Widget child,
    @required this.controller,
  }) : super(key: key, child: child);

  final VideoPlayerController controller;

  @override
  bool updateShouldNotify(_VideoProviderInherited oldWidget) => false;
}
