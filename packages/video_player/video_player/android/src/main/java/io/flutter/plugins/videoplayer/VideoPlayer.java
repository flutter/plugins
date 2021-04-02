// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static com.google.android.exoplayer2.Player.REPEAT_MODE_ALL;
import static com.google.android.exoplayer2.Player.REPEAT_MODE_OFF;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;
import android.view.Surface;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.Player.EventListener;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.audio.AudioAttributes;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.ProgressiveMediaSource;
import com.google.android.exoplayer2.source.TrackGroup;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.source.dash.DashMediaSource;
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource;
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector.Parameters;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector.ParametersBuilder;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector.SelectionOverride;
import com.google.android.exoplayer2.trackselection.MappingTrackSelector;
import com.google.android.exoplayer2.trackselection.MappingTrackSelector.MappedTrackInfo;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;
import com.google.android.exoplayer2.util.Assertions;
import com.google.android.exoplayer2.util.MimeTypes;
import com.google.android.exoplayer2.util.Util;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

final class VideoPlayer {

  private static final String FORMAT_SS = "ss";
  private static final String FORMAT_DASH = "dash";
  private static final String FORMAT_HLS = "hls";
  private static final String FORMAT_OTHER = "other";

  private SimpleExoPlayer exoPlayer;

  private DefaultTrackSelector trackSelector;

  private Parameters trackSelectorParameters;

  private Surface surface;

  private final TextureRegistry.SurfaceTextureEntry textureEntry;

  private QueuingEventSink eventSink = new QueuingEventSink();

  private final EventChannel eventChannel;

  private boolean isInitialized = false;

  private final VideoPlayerOptions options;

  VideoPlayer(
      Context context,
      EventChannel eventChannel,
      TextureRegistry.SurfaceTextureEntry textureEntry,
      String dataSource,
      String formatHint,
      Map<String, String> httpHeaders,
      VideoPlayerOptions options) {
    this.eventChannel = eventChannel;
    this.textureEntry = textureEntry;
    this.options = options;

    TrackSelection.Factory trackSelectionFactory = new AdaptiveTrackSelection.Factory();
    trackSelectorParameters = new DefaultTrackSelector.ParametersBuilder(context).build();

    trackSelector = new DefaultTrackSelector(context, trackSelectionFactory);
    trackSelector.setParameters(trackSelectorParameters);

    exoPlayer = new SimpleExoPlayer.Builder(context).setTrackSelector(trackSelector).build();

    Uri uri = Uri.parse(dataSource);

    DataSource.Factory dataSourceFactory;
    if (isHTTP(uri)) {
      DefaultHttpDataSourceFactory httpDataSourceFactory =
          new DefaultHttpDataSourceFactory(
              "ExoPlayer",
              null,
              DefaultHttpDataSource.DEFAULT_CONNECT_TIMEOUT_MILLIS,
              DefaultHttpDataSource.DEFAULT_READ_TIMEOUT_MILLIS,
              true);
      if (httpHeaders != null && !httpHeaders.isEmpty()) {
        httpDataSourceFactory.getDefaultRequestProperties().set(httpHeaders);
      }
      dataSourceFactory = httpDataSourceFactory;
    } else {
      dataSourceFactory = new DefaultDataSourceFactory(context, "ExoPlayer");
    }

    MediaSource mediaSource = buildMediaSource(uri, dataSourceFactory, formatHint, context);
    exoPlayer.setMediaSource(mediaSource);
    exoPlayer.prepare();

    setupVideoPlayer(eventChannel, textureEntry);
  }

  private static boolean isHTTP(Uri uri) {
    if (uri == null || uri.getScheme() == null) {
      return false;
    }
    String scheme = uri.getScheme();
    return scheme.equals("http") || scheme.equals("https");
  }

  private MediaSource buildMediaSource(
      Uri uri, DataSource.Factory mediaDataSourceFactory, String formatHint, Context context) {
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
      default:
        {
          throw new IllegalStateException("Unsupported type: " + type);
        }
    }
  }

  private void setupVideoPlayer(
      EventChannel eventChannel, TextureRegistry.SurfaceTextureEntry textureEntry) {

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
        new EventListener() {
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
          @SuppressWarnings("ReferenceEquality")
          public void onTracksChanged(
              TrackGroupArray trackGroups, TrackSelectionArray trackSelections) {
            //todo(aliyazdi75): use this listener to change subtitle after implementing ffmpeg.
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

  void sendBufferingUpdate() {
    Map<String, Object> event = new HashMap<>();
    event.put("event", "bufferingUpdate");
    List<? extends Number> range = Arrays.asList(0, exoPlayer.getBufferedPosition());
    // iOS supports a list of buffered ranges, so here is a list with a single range.
    event.put("values", Collections.singletonList(range));
    eventSink.success(event);
  }

  @SuppressWarnings("deprecation")
  private static void setAudioAttributes(SimpleExoPlayer exoPlayer, boolean isMixMode) {
    exoPlayer.setAudioAttributes(
        new AudioAttributes.Builder().setContentType(C.CONTENT_TYPE_MOVIE).build(), !isMixMode);
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

  void setPlaybackSpeed(double value) {
    // We do not need to consider pitch and skipSilence for now as we do not handle them and
    // therefore never diverge from the default values.
    final PlaybackParameters playbackParameters = new PlaybackParameters(((float) value));

    exoPlayer.setPlaybackParameters(playbackParameters);
  }

  void seekTo(int location) {
    exoPlayer.seekTo(location);
  }

  long getPosition() {
    return exoPlayer.getCurrentPosition();
  }

  private void updateTrackSelectorParameters() {
    if (trackSelector != null) {
      trackSelectorParameters = trackSelector.getParameters();
    }
  }

  public ArrayList<Object> getTrackSelections() {
    ArrayList<Object> trackSelections = new ArrayList<>();
    ArrayList<Integer> autoTrackSelectionTypes = new ArrayList<>();
    MappedTrackInfo mappedTrackInfo =
        Assertions.checkNotNull(trackSelector.getCurrentMappedTrackInfo());
    for (int rendererIndex = 0;
        rendererIndex < mappedTrackInfo.getRendererCount();
        rendererIndex++) {
      TrackGroupArray trackGroups = mappedTrackInfo.getTrackGroups(rendererIndex);
      if (isSupportedTrackForRenderer(trackGroups, mappedTrackInfo, rendererIndex)) {
        int trackType = mappedTrackInfo.getRendererType(rendererIndex);
        for (int groupIndex = 0; groupIndex < trackGroups.length; groupIndex++) {
          TrackGroup group = trackGroups.get(groupIndex);

          //add auto track for each track selection types
          if (!autoTrackSelectionTypes.contains(trackType)) {
            autoTrackSelectionTypes.add(trackType);
            HashMap<String, Object> autoTrackSelection = new HashMap<>();
            autoTrackSelection.put("isUnknown", false);
            autoTrackSelection.put("isAuto", true);
            autoTrackSelection.put("trackType", trackType);
            autoTrackSelection.put(
                "isSelected",
                !trackSelectorParameters.hasSelectionOverride(rendererIndex, trackGroups));
            autoTrackSelection.put("trackId", Integer.toString(rendererIndex));
            trackSelections.add(autoTrackSelection);
          }

          //add tracks
          for (int trackIndex = 0; trackIndex < group.length; trackIndex++) {
            HashMap<String, Object> trackSelection = new HashMap<>();
            Format trackFormat = group.getFormat(trackIndex);
            int inferPrimaryTrackType = inferPrimaryTrackType(trackFormat);
            trackSelection.put("isUnknown", false);
            switch (inferPrimaryTrackType) {
              case C.TRACK_TYPE_VIDEO:
                trackSelection.put("rolesFlag", roleIntMap(trackFormat));
                trackSelection.put("width", trackWidth(trackFormat));
                trackSelection.put("height", trackHeight(trackFormat));
                trackSelection.put("bitrate", trackBitrate(trackFormat));
                break;
              case C.TRACK_TYPE_AUDIO:
                trackSelection.put("language", buildLanguageString(trackFormat));
                trackSelection.put("label", buildLabelString(trackFormat));
                trackSelection.put("rolesFlag", roleIntMap(trackFormat));
                trackSelection.put("channelCount", audioChannelCount(trackFormat));
                trackSelection.put("bitrate", trackBitrate(trackFormat));
                break;
              case C.TRACK_TYPE_TEXT:
                trackSelection.put("language", buildLanguageString(trackFormat));
                trackSelection.put("label", buildLabelString(trackFormat));
                trackSelection.put("rolesFlag", roleIntMap(trackFormat));
                break;
              default:
                trackSelection.put("isUnknown", true);
            }

            SelectionOverride selectionOverride =
                trackSelectorParameters.getSelectionOverride(rendererIndex, trackGroups);
            trackSelection.put("isAuto", false);
            trackSelection.put("trackType", trackType);
            trackSelection.put(
                "isSelected",
                selectionOverride != null
                    && selectionOverride.containsTrack(trackIndex)
                    && selectionOverride.groupIndex == groupIndex);
            trackSelection.put("trackId", getTrackId(rendererIndex, groupIndex, trackIndex));
            trackSelections.add(trackSelection);
          }
        }
      }
    }
    return trackSelections;
  }

  private Boolean isSupportedTrackForRenderer(
      TrackGroupArray trackGroups,
      MappingTrackSelector.MappedTrackInfo mappedTrackInfo,
      Integer rendererIndex) {
    if (trackGroups.length == 0) {
      return false;
    }
    int trackType = mappedTrackInfo.getRendererType(rendererIndex);
    return isSupportedTrackType(trackType);
  }

  private Boolean isSupportedTrackType(Integer trackType) {
    switch (trackType) {
      case C.TRACK_TYPE_VIDEO:
      case C.TRACK_TYPE_AUDIO:
      case C.TRACK_TYPE_TEXT:
        return true;
      default:
        return false;
    }
  }

  private static Integer inferPrimaryTrackType(Format format) {
    int trackType = MimeTypes.getTrackType(format.sampleMimeType);
    if (trackType != C.TRACK_TYPE_UNKNOWN) {
      return trackType;
    }
    if (MimeTypes.getVideoMediaMimeType(format.codecs) != null) {
      return C.TRACK_TYPE_VIDEO;
    }
    if (MimeTypes.getAudioMediaMimeType(format.codecs) != null) {
      return C.TRACK_TYPE_AUDIO;
    }
    if (format.width != Format.NO_VALUE || format.height != Format.NO_VALUE) {
      return C.TRACK_TYPE_VIDEO;
    }
    if (format.channelCount != Format.NO_VALUE || format.sampleRate != Format.NO_VALUE) {
      return C.TRACK_TYPE_AUDIO;
    }
    return C.TRACK_TYPE_UNKNOWN;
  }

  private String buildLabelString(Format format) {
    return TextUtils.isEmpty(format.label) ? "" : format.label;
  }

  private String buildLanguageString(Format format) {
    String language = format.language;
    if (language == null
        || TextUtils.isEmpty(language)
        || C.LANGUAGE_UNDETERMINED.equals(language)) {
      return "";
    }
    Locale locale = Util.SDK_INT >= 21 ? Locale.forLanguageTag(language) : new Locale(language);
    return locale.getDisplayName();
  }

  private Integer roleIntMap(Format format) {
    if ((format.roleFlags & C.ROLE_FLAG_ALTERNATE) != 0) {
      return 0;
    }
    if ((format.roleFlags & C.ROLE_FLAG_SUPPLEMENTARY) != 0) {
      return 1;
    }
    if ((format.roleFlags & C.ROLE_FLAG_COMMENTARY) != 0) {
      return 2;
    }
    if ((format.roleFlags & (C.ROLE_FLAG_CAPTION | C.ROLE_FLAG_DESCRIBES_MUSIC_AND_SOUND)) != 0) {
      return 3;
    }
    return -1;
  }

  private Integer audioChannelCount(Format format) {
    int channelCount = format.channelCount;
    if (channelCount < 1) {
      return -1;
    }
    return channelCount;
  }

  private Integer trackBitrate(Format format) {
    return format.bitrate;
  }

  private Integer trackWidth(Format format) {
    return format.width;
  }

  private Integer trackHeight(Format format) {
    return format.height;
  }

  private String getTrackId(Integer rendererIndex, Integer groupIndex, Integer trackIndex) {
    return rendererIndex.toString() + groupIndex.toString() + trackIndex.toString();
  }

  public void setTrackSelection(String trackId) {
    if (!(trackId.length() == 1 || trackId.length() == 3)) {
      throw new IllegalStateException("Unsupported trackId: " + trackId);
    }
    //set auto track selection
    int rendererIndex = Character.getNumericValue(trackId.charAt(0));
    ParametersBuilder builder = trackSelectorParameters.buildUpon();
    builder.clearSelectionOverrides(rendererIndex);
    //set non auto track selection
    if (trackId.length() == 3) {
      int groupIndex = Character.getNumericValue(trackId.charAt(1));
      int trackIndex = Character.getNumericValue(trackId.charAt(2));
      SelectionOverride override = new SelectionOverride(groupIndex, trackIndex);
      MappedTrackInfo mappedTrackInfo =
          Assertions.checkNotNull(trackSelector.getCurrentMappedTrackInfo());
      builder.setSelectionOverride(
          rendererIndex, mappedTrackInfo.getTrackGroups(rendererIndex), override);
    }
    trackSelector.setParameters(builder);
    updateTrackSelectorParameters();
  }

  @SuppressWarnings("SuspiciousNameCombination")
  private void sendInitialized() {
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

  void dispose() {
    if (isInitialized) {
      exoPlayer.stop();
    }
    textureEntry.release();
    eventChannel.setStreamHandler(null);
    updateTrackSelectorParameters();
    if (trackSelector != null) {
      trackSelector = null;
    }
    if (surface != null) {
      surface.release();
    }
    if (exoPlayer != null) {
      exoPlayer.release();
    }
  }
}
