// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'mini_controller.dart';

void main() {
  runApp(
    MaterialApp(
      home: _App(),
    ),
  );
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        appBar: AppBar(
          title: const Text('Video player example'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.cloud),
                text: 'Remote mp4',
              ),
              Tab(
                icon: Icon(Icons.favorite),
                text: 'Remote enc m3u8',
              ),
              Tab(
                icon: Icon(Icons.insert_drive_file),
                text: 'Asset mp4',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _BumbleBeeRemoteVideo(),
            _BumbleBeeEncryptedLiveStream(),
            _ButterFlyAssetVideo(),
          ],
        ),
      ),
    );
  }
}

class _ButterFlyAssetVideo extends StatefulWidget {
  @override
  _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
}

class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
  late MiniController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiniController.asset('assets/Butterfly-209.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          const Text('With assets mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  late MiniController _controller;

  final GlobalKey<State<StatefulWidget>> _playerKey =
      GlobalKey<State<StatefulWidget>>();
  final Key _pictureInPictureKey = UniqueKey();
  bool _enableStartPictureInPictureAutomaticallyFromInline = false;

  @override
  void initState() {
    super.initState();
    _controller = MiniController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With remote mp4'),
          FutureBuilder<bool>(
            key: _pictureInPictureKey,
            future: _controller.isPictureInPictureSupported(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) =>
                Text(snapshot.data ?? false
                    ? 'Picture in picture is supported'
                    : 'Picture in picture is not supported'),
          ),
          Row(
            children: <Widget>[
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                    'Start picture in picture automatically when going to background'),
              ),
              Switch(
                value: _enableStartPictureInPictureAutomaticallyFromInline,
                onChanged: (bool newValue) {
                  setState(() {
                    _enableStartPictureInPictureAutomaticallyFromInline =
                        newValue;
                  });
                  _controller.setAutomaticallyStartPictureInPicture(
                      enableStartPictureInPictureAutomaticallyFromInline:
                          _enableStartPictureInPictureAutomaticallyFromInline);
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          MaterialButton(
            color: Colors.blue,
            onPressed: () {
              final RenderBox? box =
                  _playerKey.currentContext?.findRenderObject() as RenderBox?;
              if (box == null) {
                return;
              }
              final Offset offset = box.localToGlobal(Offset.zero);
              _controller.setPictureInPictureOverlayRect(
                rect: Rect.fromLTWH(
                  offset.dx,
                  offset.dy,
                  box.size.width,
                  box.size.height,
                ),
              );
            },
            child: const Text('Set picture in picture overlay rect'),
          ),
          MaterialButton(
            color: Colors.blue,
            onPressed: () {
              if (_controller.value.isPictureInPictureActive) {
                _controller.stopPictureInPicture();
              } else {
                _controller.startPictureInPicture();
              }
            },
            child: Text(_controller.value.isPictureInPictureActive
                ? 'Stop picture in picture'
                : 'Start picture in picture'),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              key: _playerKey,
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BumbleBeeEncryptedLiveStream extends StatefulWidget {
  @override
  _BumbleBeeEncryptedLiveStreamState createState() =>
      _BumbleBeeEncryptedLiveStreamState();
}

class _BumbleBeeEncryptedLiveStreamState
    extends State<_BumbleBeeEncryptedLiveStream> {
  late MiniController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiniController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/hls/encrypted_bee.m3u8',
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();

    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With remote encrypted m3u8'),
          Container(
            padding: const EdgeInsets.all(20),
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Text('loading...'),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final MiniController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
