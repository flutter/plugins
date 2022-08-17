// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/messages.g.dart',
  dartTestOut: 'test/test.dart',
  copyrightHeader: 'pigeons/copyright.txt',
))
class TextureMessage {
  TextureMessage(this.textureId);

  int textureId;
}

class LoopingMessage {
  LoopingMessage(this.textureId, this.isLooping);

  int textureId;
  bool isLooping;
}

class VolumeMessage {
  VolumeMessage(this.textureId, this.volume);

  int textureId;
  double volume;
}

class PlaybackSpeedMessage {
  PlaybackSpeedMessage(this.textureId, this.speed);

  int textureId;
  double speed;
}

class PositionMessage {
  PositionMessage(this.textureId, this.position);

  int textureId;
  int position;
}

class CreateMessage {
  CreateMessage(
      {this.asset,
      this.packageName,
      this.uri,
      this.formatHint,
      this.httpHeaders});
  String? asset;
  String? uri;
  String? packageName;
  String? formatHint;
  Map<String?, String?>? httpHeaders;
}

class MixWithOthersMessage {
  MixWithOthersMessage(this.mixWithOthers);

  bool mixWithOthers;
}

class PictureInPictureMessage {
  PictureInPictureMessage(this.textureId, this.enabled);

  int textureId;
  int enabled;
}

class PreparePictureInPictureMessage {
  PreparePictureInPictureMessage(
      this.textureId, this.top, this.left, this.width, this.height);

  int textureId;
  double top;
  double left;
  double width;
  double height;
}

@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class VideoPlayerApi {
  void initialize();
  TextureMessage create(CreateMessage msg);
  void dispose(TextureMessage msg);
  void setLooping(LoopingMessage msg);
  void setVolume(VolumeMessage msg);
  void setPlaybackSpeed(PlaybackSpeedMessage msg);
  void play(TextureMessage msg);
  PositionMessage position(TextureMessage msg);
  void seekTo(PositionMessage msg);
  void pause(TextureMessage msg);
  void setMixWithOthers(MixWithOthersMessage msg);
  bool isPictureInPictureSupported();
  void preparePictureInPicture(PreparePictureInPictureMessage msg);
  void setPictureInPicture(PictureInPictureMessage msg);
}
