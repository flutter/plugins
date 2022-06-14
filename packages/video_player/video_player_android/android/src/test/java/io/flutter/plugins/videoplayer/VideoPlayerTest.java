// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class VideoPlayerTest {
  private ExoPlayer fakeExoPlayer;
  private EventChannel fakeEventChannel;
  private TextureRegistry.SurfaceTextureEntry fakeSurfaceTextureEntry;
  private VideoPlayerOptions fakeVideoPlayerOptions;
  private QueuingEventSink fakeEventSink;

  @Captor private ArgumentCaptor<HashMap<String, Object>> eventCaptor;

  @Before
  public void before() {
    MockitoAnnotations.openMocks(this);

    fakeExoPlayer = mock(ExoPlayer.class);
    fakeEventChannel = mock(EventChannel.class);
    fakeSurfaceTextureEntry = mock(TextureRegistry.SurfaceTextureEntry.class);
    fakeVideoPlayerOptions = mock(VideoPlayerOptions.class);
    fakeEventSink = mock(QueuingEventSink.class);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_90RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(90).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 200);
    assertEquals(event.get("height"), 100);
    assertEquals(event.get("rotationCorrection"), null);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_270RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(270).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 200);
    assertEquals(event.get("height"), 100);
    assertEquals(event.get("rotationCorrection"), null);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_0RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(0).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 100);
    assertEquals(event.get("height"), 200);
    assertEquals(event.get("rotationCorrection"), null);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_180RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(180).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 100);
    assertEquals(event.get("height"), 200);
    assertEquals(event.get("rotationCorrection"), 180);
  }
}
