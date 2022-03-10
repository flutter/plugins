// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.audiofx.AudioEffect;
import android.net.Uri;
import android.os.Build;

final class VideoPlayer implements AudioManager.OnAudioFocusChangeListener {
  private static final String FORMAT_SS = "ss";
  private static final String FORMAT_DASH = "dash";
  private static final String FORMAT_HLS = "hls";
  private static final String FORMAT_OTHER = "other";

  private SimpleExoPlayer exoPlayer;

  private Surface surface;

  private final TextureRegistry.SurfaceTextureEntry textureEntry;

  private QueuingEventSink eventSink = new QueuingEventSink();

  private final EventChannel eventChannel;

  private boolean isInitialized = false;

  private final VideoPlayerOptions options;

  private AudioManager audioManager;

  private AudioFocusRequest focusRequest = null

  private Context context;

  private Uri uri;

  private DataSource.Factory dataSourceFactory;

  String hint;

  private Handler handler = new Handler();

  private AudioFocusRequest focusRequest;

  AudioManager.OnAudioFocusChangeListener afChangeListener = new AudioManager.OnAudioFocusChangeListener() {
    @Override
    public void onAudioFocusChange(int focusChange) {
      if (focusChange == AudioManager.AUDIOFOCUS_GAIN) {
        MediaSource mediaSource = buildMediaSource(uri, dataSourceFactory, hint, context);
        exoPlayer.setMediaSource(mediaSource);
        exoPlayer.prepare();
      }
    }
  };

  @Override
  public void onAudioFocusChange(int focusChange) {
    if (focusChange == AudioManager.AUDIOFOCUS_GAIN) {
      MediaSource mediaSource = buildMediaSource(uri, dataSourceFactory, hint, context);
      exoPlayer.setMediaSource(mediaSource);
      exoPlayer.prepare();
    }

    VideoPlayer(
            Context context,
            EventChannel eventChannel,
            TextureRegistry.SurfaceTextureEntry textureEntry,
            String dataSource,
            String formatHint,
            @NonNull Map < String, String > httpHeaders,
            VideoPlayerOptions options) {
      this.eventChannel = eventChannel;
      this.textureEntry = textureEntry;
      this.options = options;
      this.context = context;
      this.hint = formatHint;
      audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

      exoPlayer = new SimpleExoPlayer.Builder(context).build();

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        focusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN).
                setAudioAttributes(new AudioAttributes.Builder().setUsage(android.media.AudioAttributes.USAGE_MEDIA).
                        setContentType(android.media.AudioAttributes.CONTENT_TYPE_MUSIC).
                        build()).
                setAcceptsDelayedFocusGain(true).
                setOnAudioFocusChangeListener(this, handler).
                build();
      }

      Uri uri = Uri.parse(dataSource);
      this.uri = uri;
      DataSource.Factory dataSourceFactory;
      if (isHTTP(uri)) {
        DefaultHttpDataSource.Factory httpDataSourceFactory =
                new DefaultHttpDataSource.Factory()
                        .setUserAgent("ExoPlayer")
                        .setAllowCrossProtocolRedirects(true);

        if (httpHeaders != null && !httpHeaders.isEmpty()) {
          httpDataSourceFactory.setDefaultRequestProperties(httpHeaders);
        }
        dataSourceFactory = httpDataSourceFactory;
      } else {
        dataSourceFactory = new DefaultDataSourceFactory(context, "ExoPlayer");
      }
      this.dataSourceFactory = dataSourceFactory
      MediaSource mediaSource = buildMediaSource(uri, dataSourceFactory, formatHint, context);
      exoPlayer.setMediaSource(mediaSource);
      exoPlayer.prepare();

      setupVideoPlayer(eventChannel, textureEntry);
    }

    private static boolean isHTTP (Uri uri){
      if (uri == null || uri.getScheme() == null) {
        return false;
      }
      String scheme = uri.getScheme();
      return scheme.equals("http") || scheme.equals("https");
    }

    private MediaSource buildMediaSource (
            Uri uri, DataSource.Factory mediaDataSourceFactory, String formatHint, Context context){
      int type;
      if (formatHint == null) {
        type = Util.inferContentType(uri.getLastPathSegment());
      } else {
        switch (formatHint) {
          case FORMAT_SS:
            type = C.TYPE_SS;
            break;
          case FORMAT_DASH:
            type = C.TYPE_DASH;
            break;
          case FORMAT_HLS:
            type = C.TYPE_HLS;
            break;
          case FORMAT_OTHER:
            type = C.TYPE_OTHER;
            break;
          default:
            type = -1;
            break;
        }
      }
      switch (type) {
        case C.TYPE_SS:
          return new SsMediaSource.Factory(
                  new DefaultSsChunkSource.Factory(mediaDataSourceFactory),
                  new DefaultDataSourceFactory(context, null, mediaDataSourceFactory))
                  .createMediaSource(MediaItem.fromUri(uri));
        case C.TYPE_DASH:
          return new DashMediaSource.Factory(
                  new DefaultDashChunkSource.Factory(mediaDataSourceFactory),
                  new DefaultDataSourceFactory(context, null, mediaDataSourceFactory))
                  .createMediaSource(MediaItem.fromUri(uri));
        case C.TYPE_HLS:
          return new HlsMediaSource.Factory(mediaDataSourceFactory)
                  .createMediaSource(MediaItem.fromUri(uri));
        case C.TYPE_OTHER:
          return new ProgressiveMediaSource.Factory(mediaDataSourceFactory)
                  .createMediaSource(MediaItem.fromUri(uri));
        default: {
          throw new IllegalStateException("Unsupported type: " + type);
        }
      }
    }

    private void setupVideoPlayer (
            EventChannel eventChannel, TextureRegistry.SurfaceTextureEntry textureEntry){
      eventChannel.setStreamHandler(
              new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object o, EventChannel.EventSink sink) {
                  eventSink.setDelegate(sink);
                }

                @Override
                public void onCancel(Object o) {
                  eventSink.setDelegate(null);
                }
              });

      surface = new Surface(textureEntry.surfaceTexture());
      exoPlayer.setVideoSurface(surface);
      setAudioAttributes(exoPlayer, options.mixWithOthers);

      exoPlayer.addListener(
              new Listener() {
                private boolean isBuffering = false;

                public void setBuffering(boolean buffering) {
                  if (isBuffering != buffering) {
                    isBuffering = buffering;
                    Map<String, Object> event = new HashMap<>();
                    event.put("event", isBuffering ? "bufferingStart" : "bufferingEnd");
                    eventSink.success(event);
                  }
                }

                @Override
                public void onPlaybackStateChanged(final int playbackState) {
                  if (playbackState == Player.STATE_BUFFERING) {
                    setBuffering(true);
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
                  }

                  if (playbackState != Player.STATE_BUFFERING) {
                    setBuffering(false);
                  }
                }

                @Override
                public void onPlayerError(final ExoPlaybackException error) {
                  setBuffering(false);
                  if (eventSink != null) {
                    eventSink.error("VideoError", "Video player had error " + error, null);
                  }
                }
              });
    }

    void sendBufferingUpdate () {
      Map<String, Object> event = new HashMap<>();
      event.put("event", "bufferingUpdate");
      List<? extends Number> range = Arrays.asList(0, exoPlayer.getBufferedPosition());
      // iOS supports a list of buffered ranges, so here is a list with a single range.
      event.put("values", Collections.singletonList(range));
      eventSink.success(event);
    }

    @SuppressWarnings("deprecation")
    private static void setAudioAttributes (SimpleExoPlayer exoPlayer,boolean isMixMode){
      exoPlayer.setAudioAttributes(
              new AudioAttributes.Builder().setContentType(C.CONTENT_TYPE_MOVIE).build(), !isMixMode);
    }

    void play () {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        audioManager.requestAudioFocus(focusRequest);
      } else {
        audioManager.requestAudioFocus(afChangeListener, AudioEffect.CONTENT_TYPE_MUSIC, 0);
      }
      exoPlayer.setPlayWhenReady(true);
    }

    void pause () {
      exoPlayer.setPlayWhenReady(false);
    }

    void setLooping ( boolean value){
      exoPlayer.setRepeatMode(value ? REPEAT_MODE_ALL : REPEAT_MODE_OFF);
    }

    void setVolume ( double value){
      float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
      exoPlayer.setVolume(bracketedValue);
    }

    void setPlaybackSpeed ( double value){
// We do not need to consider pitch and skipSilence for now as we do not handle them and
// therefore never diverge from the default values.
      final PlaybackParameters playbackParameters = new PlaybackParameters(((float) value));

      exoPlayer.setPlaybackParameters(playbackParameters);
    }

    void seekTo ( int location){
      exoPlayer.seekTo(location);
    }

    long getPosition () {
      return exoPlayer.getCurrentPosition();
    }

    @SuppressWarnings("SuspiciousNameCombination")
    private void sendInitialized () {
      if (isInitialized) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "initialized");
        event.put("duration", exoPlayer.getDuration());

        if (exoPlayer.getVideoFormat() != null) {
          Format videoFormat = exoPlayer.getVideoFormat();
          int width = videoFormat.width;
          int height = videoFormat.height;
          int rotationDegrees = videoFormat.rotationDegrees;
          // Switch the width/height if video was taken in portrait mode
          if (rotationDegrees == 90 || rotationDegrees == 270) {
            width = exoPlayer.getVideoFormat().height;
            height = exoPlayer.getVideoFormat().width;
          }
          event.put("width", width);
          event.put("height", height);
        }
        eventSink.success(event);
      }
    }

    void dispose () {
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
