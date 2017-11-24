// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

final MethodChannel _channel = const MethodChannel('flutter.io/videoPlayer')
  // This will clear all open videos on the platform when a full restart is
  // performed.
  ..invokeMethod("init");

class DurationRange {
  final Duration start;
  final Duration end;
  DurationRange(this.start, this.end);
}

class VideoPlayerValue {
  final Duration duration;
  final Duration position;
  final List<DurationRange> buffered;
  final bool isPlaying;
  final String errorDescription;

  bool get initialized => duration != null;
  bool get isErroneous => errorDescription != null;

  VideoPlayerValue(
      {@required this.duration,
      this.position: const Duration(),
      this.buffered: const <DurationRange>[],
      this.isPlaying: false,
      this.errorDescription});

  VideoPlayerValue.uninitialized() : this(duration: null);

  VideoPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  VideoPlayerValue copyWith(
      {Duration duration,
      Duration position,
      List<DurationRange> buffered,
      bool isPlaying,
      String errorDescription}) {
    return new VideoPlayerValue(
        duration: duration ?? this.duration,
        position: position ?? this.position,
        buffered: buffered ?? this.buffered,
        isPlaying: isPlaying ?? this.isPlaying,
        errorDescription: errorDescription ?? this.errorDescription);
  }
}

/// Controls a platform video player, and provides updates when the state is
/// changing.
///
/// Instances are created asynchronously with [create].
///
/// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  final int _textureId;
  Timer timer;
  bool isDisposed = false;

  VideoPlayerController._internal(int textureId)
      : _textureId = textureId,
        super(new VideoPlayerValue(duration: null)) {
    new EventChannel("flutter.io/videoPlayer/videoEvents$textureId")
        .receiveBroadcastStream()
        .listen((event) {
      if (event["event"] == "initialized") {
        value = value.copyWith(
            duration: new Duration(milliseconds: event["duration"]));
      } else if (event["event"] == "completed") {
        value = value.copyWith(isPlaying: false);
      } else if (event["event"] == "bufferingUpdate") {
        List<List<int>> bufferedValues = event["values"];
        value = value.copyWith(
            buffered: bufferedValues
                .map((range) => new DurationRange(
                    new Duration(milliseconds: range[0]),
                    new Duration(milliseconds: range[1])))
                .toList());
      }
    }, onError: (PlatformException e) {
      value = new VideoPlayerValue.erroneous(e.message);
      timer?.cancel();
    });
  }

  static Future<VideoPlayerController> create(String dataSource) async {
    Map response =
        await _channel.invokeMethod('create', {'dataSource': dataSource});
    int textureId = response["textureId"];
    return new VideoPlayerController._internal(textureId);
  }

  Future<Null> dispose() async {
    if (isDisposed) {
      return;
    }
    timer?.cancel();
    await _channel.invokeMethod('dispose', {'textureId': _textureId});
    isDisposed = true;
    super.dispose();
  }

  Future<Null> play() async {
    if (isDisposed) {
      return;
    }
    await _channel.invokeMethod('play', {'textureId': _textureId});
    timer = new Timer.periodic(const Duration(milliseconds: 500),
        (Timer timer) async {
      if (isDisposed) {
        return;
      }
      Duration newPosition = await position;
      value = value.copyWith(position: newPosition);
    });
    value = value.copyWith(isPlaying: true);
  }

  Future<Null> setLooping(bool value) async {
    if (isDisposed) {
      return;
    }
    await _channel.invokeMethod(
        'setLooping', {'textureId': _textureId, 'looping': value});
  }

  Future<Null> pause() async {
    if (isDisposed) {
      return;
    }
    timer?.cancel();
    await _channel.invokeMethod('pause', {'textureId': _textureId});
    value = value.copyWith(isPlaying: false);
  }

  /// The position in the current video.
  Future<Duration> get position async {
    if (isDisposed) {
      return null;
    }
    return new Duration(
        milliseconds:
            await _channel.invokeMethod('position', {'textureId': _textureId}));
  }

  Future<Null> seekTo(Duration moment) async {
    if (isDisposed) {
      return;
    }
    if (moment > value.duration) {
      moment = value.duration;
    } else if (moment < const Duration()) {
      moment = const Duration();
    }
    await _channel.invokeMethod(
        'seekTo', {'textureId': _textureId, 'location': moment.inMilliseconds});
    value = value.copyWith(position: moment);
  }
}

/// Displays the video controlled by [controller].
class VideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  VideoPlayer(this.controller);

  Widget build(BuildContext context) {
    return new Texture(textureId: controller._textureId);
  }
}

class VideoProgressColors {
  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint disabledPaint;

  VideoProgressColors(
      {Color playedColor: const Color.fromRGBO(255, 0, 0, 0.7),
      Color bufferedColor: const Color.fromRGBO(30, 30, 200, 0.2),
      Color handleColor: const Color.fromRGBO(200, 200, 200, 1.0),
      Color disabledColor: const Color.fromRGBO(200, 200, 200, 0.5)})
      : playedPaint = new Paint()..color = playedColor,
        bufferedPaint = new Paint()..color = bufferedColor,
        handlePaint = new Paint()..color = handleColor,
        disabledPaint = new Paint()..color = disabledColor;
}

/// Displays the play/buffering status of the video controlled by [controller].
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;

  VideoProgressBar(this.controller, {VideoProgressColors colors})
      : colors = colors ?? new VideoProgressColors();

  _VideoProgressBarState createState() {
    return new _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  VoidCallback listener;
  VideoPlayerController get controller => widget.controller;

  _VideoProgressBarState() {
    listener = () {
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  Widget build(BuildContext context) {
    return new GestureDetector(
      child: (controller.value.isErroneous)
          ? new Text(controller.value.errorDescription)
          : new CustomPaint(
              painter: new ProgressBarPainter(controller.value, widget.colors)),
      onTapUp: (TapUpDetails details) {
        if (!controller.value.initialized) return;
        RenderBox box = context.findRenderObject();
        final tapPos = box.globalToLocal(details.globalPosition);
        final relative = tapPos.dx / box.size.width;
        final position = controller.value.duration * relative;
        controller.seekTo(position);
      },
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  VideoPlayerValue value;
  VideoProgressColors colors;
  ProgressBarPainter(this.value, this.colors);

  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        new Rect.fromPoints(
            new Offset(0.0, 0.0), new Offset(size.width, size.height)),
        colors.disabledPaint);
    if (!value.initialized) {
      return;
    }
    double playedPart = value.position.inMilliseconds /
        value.duration.inMilliseconds *
        size.width;
    for (DurationRange range in value.buffered) {
      double bufferedStart = range.start.inMilliseconds /
          value.duration.inMilliseconds *
          size.width;
      double bufferedEnd =
          range.end.inMilliseconds / value.duration.inMilliseconds * size.width;
      canvas.drawRect(
          new Rect.fromPoints(new Offset(bufferedStart, 0.0),
              new Offset(bufferedEnd, size.height)),
          colors.bufferedPaint);
    }
    canvas.drawRect(
        new Rect.fromPoints(Offset.zero, new Offset(playedPart, size.height)),
        colors.playedPaint);
    canvas.drawCircle(new Offset(playedPart, size.height / 2), size.height / 2,
        colors.handlePaint);
  }
}
