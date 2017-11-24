// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Controls play and pause of [controller].
///
/// Toggles play/pause on tap (accompanied by a fading status icon).
///
/// Plays (looping) on initialization, and pauses on deactivation.
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

  VideoPlayerController get controller => widget.controller;

  _VideoPlayPauseState() {
    listener = () {
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    if (!controller.value.isPlaying) controller.play();
  }

  @override
  void deactivate() {
    if (controller.value.isPlaying) controller.pause();
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
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
            imageFadeAnim =
                new FadeAnimation(child: new Icon(Icons.play_arrow, size: 100.0));
            controller.play();
          }
        },
      ),
      new Align(
          alignment: Alignment.bottomCenter,
          child: new SizedBox(
              height: 20.0,
              width: double.INFINITY,
              child: new VideoProgressBar(controller))),
      new Center(child: imageFadeAnim),
    ];

    if (!controller.value.initialized) {
      children.add(new Center(child: new CupertinoActivityIndicator()));
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
    animationController = new AnimationController(
        duration: widget.duration, vsync: this);
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
            opacity: 1.0 - animationController.value, child: widget.child)
        : new Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, Future<VideoPlayerController> controller);

/// A widget connecting its life cycle to a [VideoPlayerController].
class PlayerLifeCycle extends StatefulWidget {
  final VideoWidgetBuilder videoWidgetBuilder;
  final String uri;

  PlayerLifeCycle(this.uri, this.videoWidgetBuilder);

  @override
  _PlayerLifeCycleState createState() =>
      new _PlayerLifeCycleState(videoWidgetBuilder);
}

class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  final VideoWidgetBuilder videoWidgetBuilder;
  Future<VideoPlayerController> video;

  _PlayerLifeCycleState(this.videoWidgetBuilder);

  @override
  void initState() {
    super.initState();
    video = VideoPlayerController.create(widget.uri);
    video.then((VideoPlayerController controller) async {
      if (mounted) {
        await controller.setLooping(true);
        controller.play();
      }
    });
  }

  @override
  void dispose() {
    video.then((VideoPlayerController videoController) {
      videoController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoWidgetBuilder(context, video);
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
  final Future<VideoPlayerController> video;

  VideoInListOfCards(this.video);

  @override
  Widget build(BuildContext context) {
    Widget displayVideo = new FutureBuilder<VideoPlayerController>(
        future: video,
        builder: (BuildContext context,
            AsyncSnapshot<VideoPlayerController> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('No video loaded');
            case ConnectionState.waiting:
              return new CupertinoActivityIndicator();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return new VideoPlayPause(snapshot.data);
          }
        });

    return new ListView(
      children: [
        buildCard("Item a"),
        buildCard("Item b"),
        buildCard("Item c"),
        buildCard("Item d"),
        buildCard("Item e"),
        buildCard("Item f"),
        buildCard("Item g"),
        new Card(
            child: new Column(children: [
          new Column(
            children: [
              new ListTile(
                leading: const Icon(Icons.cake),
                title: new Text("Video video"),
              ),
              new Stack(
                  alignment: FractionalOffset.bottomRight +
                      new FractionalOffset(-0.1, -0.1),
                  children: <Widget>[
                    new Center(
                        child: new AspectRatio(
                            aspectRatio: 3 / 2,
                            child: displayVideo,
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
  final Future<VideoPlayerController> video;

  FullScreenVideo(this.video);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new AspectRatio(
        aspectRatio: 3 / 2,
        child: new FutureBuilder(
          future: video,
          builder: (BuildContext context,
              AsyncSnapshot<VideoPlayerController> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Text('No video loaded');
              case ConnectionState.waiting:
                return new Text('Awaiting video...');
              default:
                if (snapshot.hasError) {
                  return new Text('Error: ${snapshot.error}');
                } else {
                  return new VideoPlayPause(snapshot.data);
                }
            }
          },
        ),
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
              tabs: [
                new Tab(icon: new Icon(Icons.fullscreen)),
                new Tab(icon: new Icon(Icons.list)),
              ],
            ),
          ),
          body: new TabBarView(
            children: [
              new PlayerLifeCycle(
                'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
                (BuildContext context, Future<VideoPlayerController> video) =>
                    new FullScreenVideo(video),
              ),
              new PlayerLifeCycle(
                  'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
                  (BuildContext context, Future<VideoPlayerController> video) =>
                      new VideoInListOfCards(video)),
            ],
          ),
        ),
      ),
    ),
  );
}
