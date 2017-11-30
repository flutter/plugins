// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Controls play and pause of [controller].
///
/// Toggles play/pause on tap (accompanied by a fading status icon).
///
/// Plays (looping) on initialization, and mutes on deactivation.
class VideoPlayPause extends StatefulWidget {
  final VideoPlayerController controller;

  VideoPlayPause(this.controller);

  @override
  State createState() {
    return new _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  FadeAnimation imageFadeAnim =
      new FadeAnimation(child: new Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  _VideoPlayPauseState() {
    listener = () {
      setState(() {});
    };
  }

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.setVolume(1.0);
    controller.play();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      new GestureDetector(
        child: new VideoPlayer(controller),
        onTap: () {
          if (!controller.value.initialized) {
            return;
          }
          if (controller.value.isPlaying) {
            imageFadeAnim =
                new FadeAnimation(child: new Icon(Icons.pause, size: 100.0));
            controller.pause();
          } else {
            imageFadeAnim = new FadeAnimation(
                child: new Icon(Icons.play_arrow, size: 100.0));
            controller.play();
          }
        },
      ),
      new Align(
        alignment: Alignment.bottomCenter,
        child: new SizedBox(
          height: 20.0,
          width: double.INFINITY,
          child: new VideoProgressBar(controller),
        ),
      ),
      new Center(child: imageFadeAnim),
    ];

    if (!controller.value.initialized) {
      children.add(new Center(child: const CupertinoActivityIndicator()));
    }

    return new Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.passthrough,
      children: children,
    );
  }
}

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  FadeAnimation({this.child, this.duration: const Duration(milliseconds: 500)});

  @override
  _FadeAnimationState createState() => new _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        new AnimationController(duration: widget.duration, vsync: this);
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
  void didUpdateWidget(FadeAnimation oldWidget) {
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
        ? new Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : new Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

/// A widget connecting its life cycle to a [VideoPlayerController].
class PlayerLifeCycle extends StatefulWidget {
  final VideoWidgetBuilder childBuilder;
  final String uri;

  PlayerLifeCycle(this.uri, this.childBuilder);

  @override
  _PlayerLifeCycleState createState() => new _PlayerLifeCycleState();
}

class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  VideoPlayerController controller;

  _PlayerLifeCycleState();

  @override
  void initState() {
    super.initState();
    controller = new VideoPlayerController(widget.uri);
    controller.addListener(() {
      if (controller.value.isErroneous) {
        print(controller.value.errorDescription);
      }
    });
    controller.initialize();
    controller.setLooping(true);
    controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }
}

/// A filler card to show the video in a list of scrolling contents.
Widget buildCard(String title) {
  return new Card(
    child: new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new ListTile(
          leading: const Icon(Icons.airline_seat_flat_angled),
          title: new Text(title),
        ),
        new ButtonTheme.bar(
          child: new ButtonBar(
            children: <Widget>[
              new FlatButton(
                child: const Text('BUY TICKETS'),
                onPressed: () {/* ... */},
              ),
              new FlatButton(
                child: const Text('SELL TICKETS'),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class VideoInListOfCards extends StatelessWidget {
  final VideoPlayerController controller;

  VideoInListOfCards(this.controller);

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        buildCard("Item a"),
        buildCard("Item b"),
        buildCard("Item c"),
        buildCard("Item d"),
        buildCard("Item e"),
        buildCard("Item f"),
        buildCard("Item g"),
        new Card(
            child: new Column(children: <Widget>[
          new Column(
            children: <Widget>[
              const ListTile(
                leading: const Icon(Icons.cake),
                title: const Text("Video video"),
              ),
              new Stack(
                  alignment: FractionalOffset.bottomRight +
                      const FractionalOffset(-0.1, -0.1),
                  children: <Widget>[
                    new Center(
                        child: new AspectRatio(
                      aspectRatio: 3 / 2,
                      child: new VideoPlayPause(controller),
                    )),
                    new Image.asset('assets/flutter-mark-square-64.png'),
                  ]),
            ],
          ),
        ])),
        buildCard("Item h"),
        buildCard("Item i"),
        buildCard("Item j"),
        buildCard("Item k"),
        buildCard("Item l"),
      ],
    );
  }
}

class FullScreenVideo extends StatelessWidget {
  final VideoPlayerController controller;

  FullScreenVideo(this.controller);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new AspectRatio(
        aspectRatio: 3 / 2,
        child: new VideoPlayPause(controller),
      ),
    );
  }
}

void main() {
  runApp(
    new MaterialApp(
      home: new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: const Text('Video player example'),
            bottom: new TabBar(
              isScrollable: true,
              tabs: <Widget>[
                new Tab(icon: new Icon(Icons.fullscreen)),
                new Tab(icon: new Icon(Icons.list)),
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              new PlayerLifeCycle(
                'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
                (BuildContext context, VideoPlayerController controller) =>
                    new FullScreenVideo(controller),
              ),
              new PlayerLifeCycle(
                  'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
                  (BuildContext context, VideoPlayerController controller) =>
                      new VideoInListOfCards(controller)),
            ],
          ),
        ),
      ),
    ),
  );
}
