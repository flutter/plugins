// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static com.google.android.exoplayer2.Player.REPEAT_MODE_ALL;
import static com.google.android.exoplayer2.Player.REPEAT_MODE_OFF;

import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.util.LongSparseArray;
import android.view.Surface;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.Player.EventListener;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.audio.AudioAttributes;
import com.google.android.exoplayer2.extractor.DefaultExtractorsFactory;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.dash.DashMediaSource;
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource;
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;
import com.google.android.exoplayer2.util.Util;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VideoPlayerPlugin implements MethodCallHandler {

  private static class VideoPlayer {

    private SimpleExoPlayer exoPlayer;

    private Surface surface;

    private final TextureRegistry.SurfaceTextureEntry textureEntry;

    private EventChannel.EventSink eventSink;

    private final EventChannel eventChannel;

    private boolean isInitialized = false;

    VideoPlayer(
        Context context,
        EventChannel eventChannel,
        TextureRegistry.SurfaceTextureEntry textureEntry,
        String dataSource,
        Result result) {
      this.eventChannel = eventChannel;
      this.textureEntry = textureEntry;

      BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();

      TrackSelection.Factory videoTrackSelectionFactory =
              new AdaptiveTrackSelection.Factory(bandwidthMeter);

      TrackSelector trackSelector = new DefaultTrackSelector(videoTrackSelectionFactory);
      exoPlayer = ExoPlayerFactory.newSimpleInstance(context, trackSelector);

      Uri uri = Uri.parse(dataSource);

      DataSource.Factory dataSourceFactory;
<<<<<<< HEAD
      if (uri.getScheme().equals("asset") || uri.getScheme().equals("file")) {
        dataSourceFactory = new DefaultDataSourceFactory(context, "ExoPlayer", bandwidthMeter);
=======
      if (isFileOrAsset(uri)) {
        dataSourceFactory = new DefaultDataSourceFactory(context, "ExoPlayer");
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      } else {
        dataSourceFactory =
            new DefaultHttpDataSourceFactory(
                "ExoPlayer",
                null,
                DefaultHttpDataSource.DEFAULT_CONNECT_TIMEOUT_MILLIS,
                DefaultHttpDataSource.DEFAULT_READ_TIMEOUT_MILLIS,
                true);
      }

      MediaSource mediaSource = buildMediaSource(uri, dataSourceFactory);
      exoPlayer.prepare(mediaSource);

      setupVideoPlayer(eventChannel, textureEntry, result);
    }

<<<<<<< HEAD
    private MediaSource buildMediaSource(Uri uri, DataSource.Factory mediaDataSourceFactory) {
=======
    private static boolean isFileOrAsset(Uri uri) {
      if (uri == null || uri.getScheme() == null) {
        return false;
      }
      String scheme = uri.getScheme();
      return scheme.equals("file") || scheme.equals("asset");
    }

    private MediaSource buildMediaSource(
        Uri uri, DataSource.Factory mediaDataSourceFactory, Context context) {
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      int type = Util.inferContentType(uri.getLastPathSegment());
      switch (type) {
        case C.TYPE_SS:
          return new SsMediaSource(
              uri, null, new DefaultSsChunkSource.Factory(mediaDataSourceFactory), null, null);
        case C.TYPE_DASH:
          return new DashMediaSource(
              uri, null, new DefaultDashChunkSource.Factory(mediaDataSourceFactory), null, null);
        case C.TYPE_HLS:
          return new HlsMediaSource(uri, mediaDataSourceFactory, null, null);
        case C.TYPE_OTHER:
          return new ExtractorMediaSource(
              uri, mediaDataSourceFactory, new DefaultExtractorsFactory(), null, null);
        default:
          {
            throw new IllegalStateException("Unsupported type: " + type);
          }
      }
    }

    private void setupVideoPlayer(
        EventChannel eventChannel,
        TextureRegistry.SurfaceTextureEntry textureEntry,
        Result result) {

      eventChannel.setStreamHandler(
          new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
              eventSink = sink;
            }

            @Override
            public void onCancel(Object o) {
              eventSink = null;
            }
          });

      surface = new Surface(textureEntry.surfaceTexture());
      exoPlayer.setVideoSurface(surface);
      setAudioAttributes(exoPlayer);

      exoPlayer.addListener(
          new EventListener() {

            @Override
            public void onPlayerStateChanged(final boolean playWhenReady, final int playbackState) {
              if (playbackState == Player.STATE_BUFFERING) {
<<<<<<< HEAD
                if (eventSink != null) {
                  Map<String, Object> event = new HashMap<>();
                  event.put("event", "bufferingUpdate");
                  List<Integer> range = Arrays.asList(0, exoPlayer.getBufferedPercentage());
                  // iOS supports a list of buffered ranges, so here is a list with a single range.
                  event.put("values", Collections.singletonList(range));
                  eventSink.success(event);
                }
              } else if (playbackState == Player.STATE_READY && !isInitialized) {
                isInitialized = true;
                sendInitialized();
=======
                sendBufferingUpdate();
              } else if (playbackState == Player.STATE_READY) {
                if (!isInitialized) {
                  isInitialized = true;
                  sendInitialized();
                }
              } else if (playbackState == Player.STATE_ENDED) {
                Map<String, Object> event = new HashMap<>();
                event.put("event", "completed");
                eventSink.success(event);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
              }
            }

            @Override
            public void onPlayerError(final ExoPlaybackException error) {
              if (eventSink != null) {
                eventSink.error("VideoError", "Video player had error " + error, null);
              }
            }
          });

      Map<String, Object> reply = new HashMap<>();
      reply.put("textureId", textureEntry.id());
      result.success(reply);
    }

    private void sendBufferingUpdate() {
      Map<String, Object> event = new HashMap<>();
      event.put("event", "bufferingUpdate");
      List<? extends Number> range = Arrays.asList(0, exoPlayer.getBufferedPosition());
      // iOS supports a list of buffered ranges, so here is a list with a single range.
      event.put("values", Collections.singletonList(range));
      eventSink.success(event);
    }

    @SuppressWarnings("deprecation")
    private static void setAudioAttributes(SimpleExoPlayer exoPlayer) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        exoPlayer.setAudioAttributes(
            new AudioAttributes.Builder().setContentType(C.CONTENT_TYPE_MOVIE).build());
      } else {
        exoPlayer.setAudioStreamType(C.STREAM_TYPE_MUSIC);
      }
    }

    void play() {
      exoPlayer.setPlayWhenReady(true);
    }

    void pause() {
      exoPlayer.setPlayWhenReady(false);
    }

    void setLooping(boolean value) {
      exoPlayer.setRepeatMode(value ? REPEAT_MODE_ALL : REPEAT_MODE_OFF);
    }

    void setVolume(double value) {
      float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
      exoPlayer.setVolume(bracketedValue);
    }

    void seekTo(int location) {
      exoPlayer.seekTo(location);
    }

    long getPosition() {
      return exoPlayer.getCurrentPosition();
    }

    @SuppressWarnings("SuspiciousNameCombination")
    private void sendInitialized() {
      if (isInitialized && eventSink != null) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "initialized");
        event.put("duration", exoPlayer.getDuration());
        if (exoPlayer.getVideoFormat() != null) {
          event.put("width", exoPlayer.getVideoFormat().width);
          event.put("height", exoPlayer.getVideoFormat().height);
        }
        eventSink.success(event);
      }
    }

    void dispose() {
      if (isInitialized) {
        exoPlayer.stop();
      }
      textureEntry.release();
      eventChannel.setStreamHandler(null);
      if (surface != null) {
        surface.release();
      }
      if (exoPlayer != null) {
        exoPlayer.release();
      }
    }
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "flutter.io/videoPlayer");
    channel.setMethodCallHandler(new VideoPlayerPlugin(registrar));
  }

  private VideoPlayerPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.videoPlayers = new LongSparseArray<>();
  }

  private final LongSparseArray<VideoPlayer> videoPlayers;

  private final Registrar registrar;

<<<<<<< HEAD
=======
  private void disposeAllPlayers() {
    for (int i = 0; i < videoPlayers.size(); i++) {
      videoPlayers.valueAt(i).dispose();
    }
    videoPlayers.clear();
  }

  private void onDestroy() {
    // The whole FlutterView is being destroyed. Here we release resources acquired for all instances
    // of VideoPlayer. Once https://github.com/flutter/flutter/issues/19358 is resolved this may
    // be replaced with just asserting that videoPlayers.isEmpty().
    // https://github.com/flutter/flutter/issues/20989 tracks this.
    disposeAllPlayers();
  }

>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    TextureRegistry textures = registrar.textures();
    if (textures == null) {
      result.error("no_activity", "video_player plugin requires a foreground activity", null);
      return;
    }
    switch (call.method) {
      case "init":
        disposeAllPlayers();
        break;
      case "create":
        {
          TextureRegistry.SurfaceTextureEntry handle = textures.createSurfaceTexture();
          EventChannel eventChannel =
              new EventChannel(
                  registrar.messenger(), "flutter.io/videoPlayer/videoEvents" + handle.id());

          VideoPlayer player;
          if (call.argument("asset") != null) {
            String assetLookupKey;
            if (call.argument("package") != null) {
              assetLookupKey =
                  registrar.lookupKeyForAsset(call.argument("asset"), call.argument("package"));
            } else {
              assetLookupKey = registrar.lookupKeyForAsset(call.argument("asset"));
            }
            player =
                new VideoPlayer(
                    registrar.context(),
                    eventChannel,
                    handle,
                    "asset:///" + assetLookupKey,
                    result);
            videoPlayers.put(handle.id(), player);
          } else {
            player =
                new VideoPlayer(
                    registrar.context(), eventChannel, handle, call.argument("uri"), result);
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
        player.setLooping(call.argument("looping"));
        result.success(null);
        break;
      case "setVolume":
        player.setVolume(call.argument("volume"));
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
        player.sendBufferingUpdate();
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
