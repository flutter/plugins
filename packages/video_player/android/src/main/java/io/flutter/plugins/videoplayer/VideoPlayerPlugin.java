// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.res.AssetFileDescriptor;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.view.Surface;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VideoPlayerPlugin implements MethodCallHandler {
  private static class VideoPlayer {
    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    private final MediaPlayer mediaPlayer;
    private EventChannel.EventSink eventSink;
    private final EventChannel eventChannel;
    private boolean isInitialized = false;

    VideoPlayer(
        EventChannel eventChannel,
        TextureRegistry.SurfaceTextureEntry textureEntry,
        AssetFileDescriptor afd,
        final Result result) {
      this.eventChannel = eventChannel;
      this.mediaPlayer = new MediaPlayer();
      this.textureEntry = textureEntry;
      try {
        mediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
        setupVideoPlayer(eventChannel, textureEntry, mediaPlayer, result);
      } catch (IOException e) {
        result.error("VideoError", "IOError when initializing video player " + e.toString(), null);
      }
    }

    VideoPlayer(
        EventChannel eventChannel,
        TextureRegistry.SurfaceTextureEntry textureEntry,
        String dataSource,
        Result result) {
      this.eventChannel = eventChannel;
      this.mediaPlayer = new MediaPlayer();
      this.textureEntry = textureEntry;
      try {
        mediaPlayer.setDataSource(dataSource);
        setupVideoPlayer(eventChannel, textureEntry, mediaPlayer, result);
      } catch (IOException e) {
        result.error("VideoError", "IOError when initializing video player " + e.toString(), null);
      }
    }

    private void setupVideoPlayer(
        EventChannel eventChannel,
        TextureRegistry.SurfaceTextureEntry textureEntry,
        final MediaPlayer mediaPlayer,
        Result result) {

      eventChannel.setStreamHandler(
          new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
              eventSink = sink;
              sendInitialized();
            }

            @Override
            public void onCancel(Object o) {
              eventSink = null;
            }
          });

      mediaPlayer.setSurface(new Surface(textureEntry.surfaceTexture()));
      setAudioAttributes(mediaPlayer);
      mediaPlayer.setOnPreparedListener(
          new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
              mediaPlayer.setOnBufferingUpdateListener(
                  new MediaPlayer.OnBufferingUpdateListener() {
                    @Override
                    public void onBufferingUpdate(MediaPlayer mediaPlayer, int percent) {
                      if (eventSink != null) {
                        Map<String, Object> event = new HashMap<>();
                        event.put("event", "bufferingUpdate");
                        List<Integer> range =
                            Arrays.asList(0, percent * mediaPlayer.getDuration() / 100);
                        // iOS supports a list of buffered ranges, so here is a list with a single range.
                        event.put("values", Collections.singletonList(range));
                        eventSink.success(event);
                      }
                    }
                  });
              isInitialized = true;
              sendInitialized();
            }
          });

      mediaPlayer.setOnErrorListener(
          new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
              if (eventSink != null) {
                eventSink.error(
                    "VideoError", "Video player had error " + what + " extra " + extra, null);
              }
              return true;
            }
          });

      mediaPlayer.setOnCompletionListener(
          new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
              Map<String, Object> event = new HashMap<>();
              event.put("event", "completed");
              eventSink.success(event);
            }
          });

      mediaPlayer.setOnInfoListener(
          new MediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(MediaPlayer mediaPlayer, int what, int extra) {
              Map<String, Object> event = new HashMap<>();
              switch (what) {
                case MediaPlayer.MEDIA_INFO_BUFFERING_START:
                  {
                    event.put("event", "bufferingStart");
                    eventSink.success(event);
                    return true;
                  }
                case MediaPlayer.MEDIA_INFO_BUFFERING_END:
                  {
                    event.put("event", "bufferingEnd");
                    eventSink.success(event);
                    return true;
                  }
              }
              return false;
            }
          });

      mediaPlayer.prepareAsync();

      Map<String, Object> reply = new HashMap<>();
      reply.put("textureId", textureEntry.id());
      result.success(reply);
    }

    @SuppressWarnings("deprecation")
    private static void setAudioAttributes(MediaPlayer mediaPlayer) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        mediaPlayer.setAudioAttributes(
            new AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                .build());
      } else {
        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
      }
    }

    void play() {
      if (!mediaPlayer.isPlaying()) {
        mediaPlayer.start();
      }
    }

    void pause() {
      if (mediaPlayer.isPlaying()) {
        mediaPlayer.pause();
      }
    }

    void setLooping(boolean value) {
      mediaPlayer.setLooping(value);
    }

    void setVolume(double value) {
      float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
      mediaPlayer.setVolume(bracketedValue, bracketedValue);
    }

    void seekTo(int location) {
      mediaPlayer.seekTo(location);
    }

    int getPosition() {
      return mediaPlayer.getCurrentPosition();
    }

    private void sendInitialized() {
      if (isInitialized && eventSink != null) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "initialized");
        event.put("duration", mediaPlayer.getDuration());
        event.put("width", mediaPlayer.getVideoWidth());
        event.put("height", mediaPlayer.getVideoHeight());
        eventSink.success(event);
      }
    }

    void dispose() {
      if (isInitialized && mediaPlayer.isPlaying()) {
        mediaPlayer.stop();
      }
      mediaPlayer.reset();
      mediaPlayer.release();
      textureEntry.release();
      eventChannel.setStreamHandler(null);
    }
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "flutter.io/videoPlayer");
    channel.setMethodCallHandler(new VideoPlayerPlugin(registrar));
  }

  private VideoPlayerPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.videoPlayers = new HashMap<>();
  }

  private final Map<Long, VideoPlayer> videoPlayers;
  private final Registrar registrar;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    TextureRegistry textures = registrar.textures();
    if (textures == null) {
      result.error("no_activity", "video_player plugin requires a foreground activity", null);
      return;
    }
    switch (call.method) {
      case "init":
        for (VideoPlayer player : videoPlayers.values()) {
          player.dispose();
        }
        videoPlayers.clear();
        break;
      case "create":
        {
          TextureRegistry.SurfaceTextureEntry handle = textures.createSurfaceTexture();
          EventChannel eventChannel =
              new EventChannel(
                  registrar.messenger(), "flutter.io/videoPlayer/videoEvents" + handle.id());

          VideoPlayer player;
          if (call.argument("asset") != null) {
            try {
              String assetLookupKey;
              if (call.argument("package") != null) {
                assetLookupKey =
                    registrar.lookupKeyForAsset(
                        (String) call.argument("asset"), (String) call.argument("package"));
              } else {
                assetLookupKey = registrar.lookupKeyForAsset((String) call.argument("asset"));
              }
              AssetFileDescriptor fd = registrar.context().getAssets().openFd(assetLookupKey);
              player = new VideoPlayer(eventChannel, handle, fd, result);
              videoPlayers.put(handle.id(), player);
            } catch (IOException e) {
              result.error(
                  "IOError",
                  "Error trying to access asset "
                      + (String) call.argument("asset")
                      + ". "
                      + e.toString(),
                  null);
            }
          } else {
            player = new VideoPlayer(eventChannel, handle, (String) call.argument("uri"), result);
            videoPlayers.put(handle.id(), player);
          }
          break;
        }
      default:
        {
          long textureId = ((Number) call.argument("textureId")).longValue();
          VideoPlayer player = videoPlayers.get(textureId);
          if (player == null) {
            result.error(
                "Unknown textureId",
                "No video player associated with texture id " + textureId,
                null);
            return;
          }
          onMethodCall(call, result, textureId, player);
          break;
        }
    }
  }

  private void onMethodCall(MethodCall call, Result result, long textureId, VideoPlayer player) {
    switch (call.method) {
      case "setLooping":
        player.setLooping((Boolean) call.argument("looping"));
        result.success(null);
        break;
      case "setVolume":
        player.setVolume((Double) call.argument("volume"));
        result.success(null);
        break;
      case "play":
        player.play();
        result.success(null);
        break;
      case "pause":
        player.pause();
        result.success(null);
        break;
      case "seekTo":
        int location = ((Number) call.argument("location")).intValue();
        player.seekTo(location);
        result.success(null);
        break;
      case "position":
        result.success(player.getPosition());
        break;
      case "dispose":
        player.dispose();
        videoPlayers.remove(textureId);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
