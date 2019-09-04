import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class VideoPlayer {
  VideoPlayer({this.uri, this.eventChannel, this.textureId});

  final PluginEventChannel<Map<String, dynamic>> eventChannel;
  final StreamController<Map<String, dynamic>> controller =
      StreamController<Map<String, dynamic>>();

  final Uri uri;
  final int textureId;
  VideoElement videoElement;
  bool isInitialized = false;

  Map<String, int> setupVideoPlayer(
      PluginEventChannel<Map<String, dynamic>> eventChannel) {
    eventChannel.controller = controller;
    videoElement = VideoElement()
      ..src = uri.toString()
      ..autoplay = false
      ..controls = false
      ..style.border = 'none';

    ui.platformViewRegistry.registerViewFactory(
        textureId.toString(), (int viewId) => videoElement);

    videoElement.onCanPlay.listen((dynamic _) {
      if (!isInitialized) {
        isInitialized = true;
        sendInitialized();
      }
    });
    videoElement.onError.listen((dynamic error) {
      controller.addError(error);
    });
    videoElement.onEnded.listen((dynamic _) {
      final Map<String, String> event = <String, String>{"event": "completed"};
      controller.add(event);
    });

    final Map<String, int> reply = <String, int>{"textureId": textureId};
    return reply;
  }

  void sendBufferingUpdate() {
    // TODO: convert TimeRanges
    final Map<String, dynamic> event = <String, dynamic>{
      "event": "bufferingUpdate",
      "values": videoElement.buffered,
    };
    controller.add(event);
  }

  void play() {
    videoElement.play();
  }

  void pause() {
    videoElement.pause();
  }

  void setLooping(bool value) {
    videoElement.loop = value;
  }

  void setVolume(double value) {
    videoElement.volume = value;
  }

  void seekTo(int location) {
    videoElement.currentTime = location.toDouble() / 1000;
  }

  int getPosition() {
    final int position = (videoElement.currentTime * 1000).round();
    return position;
  }

  void sendInitialized() {
    final Map<String, dynamic> event = <String, dynamic>{
      'event': 'initialized',
      'duration': videoElement.duration * 1000,
      'width': videoElement.videoWidth,
      'height': videoElement.videoHeight,
    };
    controller.add(event);
  }

  void dispose() {
    videoElement.removeAttribute('src');
    videoElement.load();
  }
}

class VideoPlayerPlugin {
  VideoPlayerPlugin(this._registrar);

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel('flutter.io/videoPlayer',
        const StandardMethodCodec(), registrar.messenger);
    final VideoPlayerPlugin instance = VideoPlayerPlugin(registrar);
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Map<int, VideoPlayer> videoPlayers = <int, VideoPlayer>{};
  Registrar _registrar;

  int textureCounter = 1;

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "init":
        // TODO: gracefully handle multiple calls to init
        // disposeAllPlayers();
        break;
      case "create":
        final int textureId = textureCounter;
        textureCounter++;

        final PluginEventChannel<Map<String, dynamic>> eventChannel =
            PluginEventChannel<Map<String, dynamic>>(
                'flutter.io/videoPlayer/videoEvents$textureId',
                const StandardMethodCodec(),
                _registrar.messenger);

        final VideoPlayer player = VideoPlayer(
          uri: Uri.parse(call.arguments['uri']),
          eventChannel: eventChannel,
          textureId: textureId,
        );

        final Map<String, int> reply = player.setupVideoPlayer(eventChannel);

        videoPlayers[textureId] = player;
        return reply;

      default:
        final int textureId = call.arguments["textureId"];

        final VideoPlayer player = videoPlayers[textureId];
        if (player == null) {
          throw Exception(
              "No video player associated with texture id $textureId");
        }

        return _onMethodCall(call, textureId, player);
    }
  }

  void disposeAllPlayers() {
    videoPlayers.forEach((_, VideoPlayer videoPlayer) => videoPlayer.dispose());
    videoPlayers.clear();
  }

  dynamic _onMethodCall(MethodCall call, int textureId, VideoPlayer player) {
    switch (call.method) {
      case "setLooping":
        player.setLooping(call.arguments["looping"]);
        return null;
      case "setVolume":
        player.setVolume(call.arguments["volume"]);
        return null;
      case "play":
        player.play();
        return null;
      case "pause":
        player.pause();
        return null;
      case "seekTo":
        player.seekTo(call.arguments["location"]);
        return null;
      case "position":
        player.sendBufferingUpdate();
        return player.getPosition();
      case "dispose":
        player.dispose();
        videoPlayers.remove(textureId);
        return null;
      default:
        throw UnimplementedError();
    }
  }
}
