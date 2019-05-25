// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audio_player/audio_player.dart';

/// An example of using the plugin, controlling lifecycle and playback of the
/// audio.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Controls play and pause of [controller].
///
/// Toggles play/pause on tap (accompanied by a change action icon).
///
/// Plays (looping) on initialization, and mutes on deactivation.
class AudioWithControllers extends StatefulWidget {
  AudioWithControllers(this.controller);

  final AudioPlayerController controller;

  @override
  State createState() {
    return _AudioWithControllersState();
  }
}

class _AudioWithControllersState extends State<AudioWithControllers> {
  _AudioWithControllersState() {
    listener = () {
      setState(() {});
    };
  }

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  AudioPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.setVolume(1.0);
    controller.setSpeed(1.0);
    controller.play();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.pause();
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: controller.value.isPlaying
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              onTap: (!controller.value.initialized)
                  ? null
                  : () {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        if (controller.value.position >=
                            controller.value.duration) {
                          controller.seekTo(const Duration(microseconds: 0));
                        }
                        controller.play();
                      }
                    },
            ),
            Flexible(
              child: AudioProgressIndicator(
                controller,
                allowScrubbing: true,
              ),
            ),
            GestureDetector(
              child: controller.value.isLooping
                  ? const Icon(Icons.loop)
                  : const Icon(Icons.loop,color: Colors.blueGrey,),
              onTap: (!controller.value.initialized)
                  ? null
                  : () {
                      if (controller.value.isLooping) {
                        controller.setLooping(false);
                      } else {
                        controller.setLooping(true);
                      }
                    },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text('volume'),
            Expanded(
              child: Slider(
                min: 0.0,
                max: 1.0,
                label: '${controller.value.volume}',
                value: controller.value.volume,
                onChanged: (double newVolume) =>
                    controller.setVolume(newVolume),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text('speed'),
            Expanded(
              child: Slider(
                min: 0.0,
                max: 2.0,
                label: '${controller.value.speed}',
                value: controller.value.speed,
                onChanged: (double newSpeed) => controller.setSpeed(newSpeed),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
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
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}

typedef Widget AudioWidgetBuilder(
    BuildContext context, AudioPlayerController controller);

abstract class PlayerLifeCycle extends StatefulWidget {
  PlayerLifeCycle(this.dataSource, this.childBuilder);

  final AudioWidgetBuilder childBuilder;
  final String dataSource;
}

/// A widget connecting its life cycle to a [AudioPlayerController] using
/// a data source from the network.
class NetworkPlayerLifeCycle extends PlayerLifeCycle {
  NetworkPlayerLifeCycle(String dataSource, AudioWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _NetworkPlayerLifeCycleState createState() => _NetworkPlayerLifeCycleState();
}

/// A widget connecting its life cycle to a [AudioPlayerController] using
/// an asset as data source
class AssetPlayerLifeCycle extends PlayerLifeCycle {
  AssetPlayerLifeCycle(String dataSource, AudioWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _AssetPlayerLifeCycleState createState() => _AssetPlayerLifeCycleState();
}

abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  AudioPlayerController controller;

  @override

  /// Subclasses should implement [createAudioPlayerController], which is used
  /// by this method.
  void initState() {
    super.initState();
    controller = createAudioPlayerController();
    controller.addListener(() {
      if (controller.value.hasError) {
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

  AudioPlayerController createAudioPlayerController();
}

class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  AudioPlayerController createAudioPlayerController() {
    return AudioPlayerController.network(widget.dataSource);
  }
}

class _AssetPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  AudioPlayerController createAudioPlayerController() {
    return AudioPlayerController.asset(widget.dataSource);
  }
}

/// A filler card to show the audio in a list of scrolling contents.
Widget buildCard(String title) {
  return Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.airline_seat_flat_angled),
          title: Text(title),
        ),
        ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text('BUY TICKETS'),
                onPressed: () {
                  /* ... */
                },
              ),
              FlatButton(
                child: const Text('SELL TICKETS'),
                onPressed: () {
                  /* ... */
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AudioInListOfCards extends StatelessWidget {
  AudioInListOfCards(this.controller);

  final AudioPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        buildCard("Item a"),
        buildCard("Item b"),
        buildCard("Item c"),
        buildCard("Item d"),
        buildCard("Item e"),
        buildCard("Item f"),
        buildCard("Item g"),
        Card(
            child: Column(children: <Widget>[
          Column(
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.cake),
                title: Text("Audio audio"),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Audio(controller),
              ),
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

class Audio extends StatefulWidget {
  Audio(this.controller);

  final AudioPlayerController controller;

  @override
  AudioState createState() => AudioState();
}

class AudioState extends State<Audio> {
  AudioPlayerController get controller => widget.controller;
  bool initialized = false;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.initialized) {
        initialized = controller.value.initialized;
        setState(() {});
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(child: AudioWithControllers(controller));
    } else {
      return Container();
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Audio player example'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: <Widget>[
                Tab(icon: Icon(Icons.audiotrack)),
                Tab(icon: Icon(Icons.list)),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text('remote MP3'),
                  NetworkPlayerLifeCycle(
                    'https://www.musicscreen.be/mp3gallery/content/songs/MP3/Electrique/Vertu.mp3',
                    (BuildContext context, AudioPlayerController controller) =>
                        Audio(controller),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20.0),
                  ),
                ],
              ),
              AssetPlayerLifeCycle(
                  'assets/crowd-cheering.mp3',
                  (BuildContext context, AudioPlayerController controller) =>
                      AudioInListOfCards(controller)),
            ],
          ),
        ),
      ),
    ),
  );
}
