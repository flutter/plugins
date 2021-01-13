// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import io.flutter.plugin.common.MethodChannel;
import org.junit.Test;

public class PictureCaptureRequestTest {

  @Test
  public void state_is_idle_by_default() {
    PictureCaptureRequest req = new PictureCaptureRequest(null);
    assertEquals("Default state is idle", req.getState(), PictureCaptureRequest.State.idle);
  }

  @Test
  public void setState_sets_state() {
    PictureCaptureRequest req = new PictureCaptureRequest(null);
    req.setState(PictureCaptureRequest.State.focusing);
    assertEquals("State is focusing", req.getState(), PictureCaptureRequest.State.focusing);
    req.setState(PictureCaptureRequest.State.preCapture);
    assertEquals("State is preCapture", req.getState(), PictureCaptureRequest.State.preCapture);
    req.setState(PictureCaptureRequest.State.waitingPreCaptureReady);
    assertEquals(
        "State is waitingPreCaptureReady",
        req.getState(),
        PictureCaptureRequest.State.waitingPreCaptureReady);
    req.setState(PictureCaptureRequest.State.capturing);
    assertEquals(
        "State is awaitingPreCapture", req.getState(), PictureCaptureRequest.State.capturing);
  }

  @Test
  public void finish_sets_result_and_state() {
    // Setup
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    PictureCaptureRequest req = new PictureCaptureRequest(mockResult);
    // Act
    req.finish("/test/path");
    // Test
    verify(mockResult).success("/test/path");
    assertEquals("State is finished", req.getState(), PictureCaptureRequest.State.finished);
  }

  @Test
  public void isFinished_is_true_When_state_is_finished_or_error() {
    // Setup
    PictureCaptureRequest req = new PictureCaptureRequest(null);
    // Test false states
    req.setState(PictureCaptureRequest.State.idle);
    assertFalse(req.isFinished());
    req.setState(PictureCaptureRequest.State.preCapture);
    assertFalse(req.isFinished());
    req.setState(PictureCaptureRequest.State.capturing);
    assertFalse(req.isFinished());
    // Test true states
    req.setState(PictureCaptureRequest.State.finished);
    assertTrue(req.isFinished());
    req = new PictureCaptureRequest(null); // Refresh
    req.setState(PictureCaptureRequest.State.error);
    assertTrue(req.isFinished());
  }

  @Test(expected = IllegalStateException.class)
  public void finish_throws_When_already_finished() {
    // Setup
    PictureCaptureRequest req = new PictureCaptureRequest(null);
    req.setState(PictureCaptureRequest.State.finished);
    // Act
    req.finish("/test/path");
  }

  @Test
  public void error_sets_result_and_state() {
    // Setup
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    PictureCaptureRequest req = new PictureCaptureRequest(mockResult);
    // Act
    req.error("ERROR_CODE", "Error Message", null);
    // Test
    verify(mockResult).error("ERROR_CODE", "Error Message", null);
    assertEquals("State is error", req.getState(), PictureCaptureRequest.State.error);
  }

  @Test(expected = IllegalStateException.class)
  public void error_throws_When_already_finished() {
    // Setup
    PictureCaptureRequest req = new PictureCaptureRequest(null);
    req.setState(PictureCaptureRequest.State.finished);
    // Act
    req.error(null, null, null);
  }
}
