import 'dart:async';
import 'package:flutter/material.dart';
import './video_provider.dart';

class Player extends StatefulWidget {
  const Player({this.isLive = false});

  final bool isLive;

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  VideoPlayerController controller;
  bool initialized = false;
  bool playing = false;
  bool buffering = true;
  bool active = true;
  PlayPauseButton playPauseButton;

  @override
  void initState() {
    super.initState();
    controller = VideoControllerProvider.of(context);
    _initialize();
  }

  @override
  void dispose() async {
    controller?.removeListener(_listener);
    super.dispose();
  }

  Future<void> _initialize() async {
    controller.addListener(_listener);
    await controller.initialize();
    await controller.play();
  }

  Future<void> _playPause() async {
    if (!controller.value.initialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  void _listener() {
    if (!mounted) {
      return;
    }

    if (!initialized && controller.value.initialized) {
      return _refresh();
    }

    if (playing != controller.value.isPlaying) {
      return _refresh();
    }

    if (buffering != controller.value.isBuffering) {
      return _refresh();
    }
  }

  void _refresh() {
    if (!active) {
      return;
    }

    setState(() {
      initialized = controller.value.initialized;
      buffering = controller.value.isBuffering;
      playing = controller.value.isPlaying;
      playPauseButton =
          playing ? PlayPauseButton.playing() : PlayPauseButton.paused();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const SizedBox();
    }

    final List<Widget> children = <Widget>[
      GestureDetector(
        onTap: _playPause,
        child: VideoPlayer(controller),
      ),
      widget.isLive ? _buildLiveIndicator() : _buildProgressIndicator(),
    ];

    if (playPauseButton != null) {
      children.add(Center(child: playPauseButton));
    }

    if (controller.value.isBuffering) {
      children.add(Center(child: const CircularProgressIndicator()));
    }

    return Container(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.passthrough,
          children: children,
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Text(
          'LIVE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: VideoProgressIndicator(controller, allowScrubbing: true),
    );
  }
}

class PlayPauseButton extends StatefulWidget {
  PlayPauseButton({
    this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  PlayPauseButton.playing()
      : child = const Icon(Icons.play_arrow, size: 100.0),
        duration = const Duration(milliseconds: 500);

  PlayPauseButton.paused()
      : child = const Icon(Icons.pause, size: 100.0),
        duration = const Duration(milliseconds: 500);

  final Widget child;
  final Duration duration;

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);

    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}
