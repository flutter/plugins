// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import org.junit.Test;

import io.flutter.plugin.common.MethodChannel;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class PictureCaptureRequestTest {

    @Test
    public void state_is_idle_by_default() {
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null);
        assertEquals("Default state is idle", req.getState(), PictureCaptureRequestState.STATE_IDLE);
    }

    @Test
    public void setState_sets_state() {
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null);
        req.setState(PictureCaptureRequestState.STATE_WAITING_FOCUS);
        assertEquals("State is focusing", req.getState(), PictureCaptureRequestState.STATE_WAITING_FOCUS);
        req.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_START);
        assertEquals("State is preCapture", req.getState(), PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_START);
        req.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_DONE);
        assertEquals(
                "State is waitingPreCaptureReady",
                req.getState(),
                PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_DONE);
        req.setState(PictureCaptureRequestState.STATE_CAPTURING);
        assertEquals(
                "State is awaitingPreCapture", req.getState(), PictureCaptureRequestState.STATE_CAPTURING);
    }

    @Test
    public void setState_resets_timeout() {
        PictureCaptureRequest.TimeoutHandler mockTimeoutHandler =
                mock(PictureCaptureRequest.TimeoutHandler.class);
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null, mockTimeoutHandler);
        req.setState(PictureCaptureRequestState.STATE_WAITING_FOCUS);
        req.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_START);
        req.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_DONE);
        req.setState(PictureCaptureRequestState.STATE_CAPTURING);
        verify(mockTimeoutHandler, times(4)).resetTimeout(any());
        verify(mockTimeoutHandler, never()).clearTimeout(any());
    }

    @Test
    public void setState_clears_timeout() {
        PictureCaptureRequest.TimeoutHandler mockTimeoutHandler =
                mock(PictureCaptureRequest.TimeoutHandler.class);
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null, mockTimeoutHandler);
        req.setState(PictureCaptureRequestState.STATE_IDLE);
        req.setState(PictureCaptureRequestState.STATE_FINISHED);
        req = new PictureCaptureRequest(null, null, null, mockTimeoutHandler);
        req.setState(PictureCaptureRequestState.STATE_ERROR);
        verify(mockTimeoutHandler, never()).resetTimeout(any());
        verify(mockTimeoutHandler, times(3)).clearTimeout(any());
    }

    @Test
    public void finish_sets_result_and_state() {
        // Setup
        MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
        PictureCaptureRequest req = new PictureCaptureRequest(mockResult, null, null);
        // Act
        req.finish("/test/path");
        // Test
        verify(mockResult).success("/test/path");
        assertEquals("State is finished", req.getState(), PictureCaptureRequestState.STATE_FINISHED);
    }

    @Test
    public void finish_clears_timeout() {
        PictureCaptureRequest.TimeoutHandler mockTimeoutHandler =
                mock(PictureCaptureRequest.TimeoutHandler.class);
        MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
        PictureCaptureRequest req = new PictureCaptureRequest(mockResult, null, null, mockTimeoutHandler);
        req.finish("/test/path");
        verify(mockTimeoutHandler, never()).resetTimeout(any());
        verify(mockTimeoutHandler).clearTimeout(any());
    }

    @Test
    public void isFinished_is_true_When_state_is_finished_or_error() {
        // Setup
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null);
        // Test false states
        req.setState(PictureCaptureRequestState.STATE_IDLE);
        assertFalse(req.isFinished());
        req.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_START);
        assertFalse(req.isFinished());
        req.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_DONE);
        assertFalse(req.isFinished());
        // Test true states
        req.setState(PictureCaptureRequestState.STATE_FINISHED);
        assertTrue(req.isFinished());
        req = new PictureCaptureRequest(null, null, null); // Refresh
        req.setState(PictureCaptureRequestState.STATE_ERROR);
        assertTrue(req.isFinished());
    }

    @Test(expected = IllegalStateException.class)
    public void finish_throws_When_already_finished() {
        // Setup
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null);
        req.setState(PictureCaptureRequestState.STATE_FINISHED);
        // Act
        req.finish("/test/path");
    }

    @Test
    public void error_sets_result_and_state() {
        // Setup
        MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
        PictureCaptureRequest req = new PictureCaptureRequest(mockResult, null, null);
        // Act
        req.error("ERROR_CODE", "Error Message", null);
        // Test
        verify(mockResult).error("ERROR_CODE", "Error Message", null);
        assertEquals("State is error", req.getState(), PictureCaptureRequestState.STATE_ERROR);
    }

    @Test
    public void error_clears_timeout() {
        PictureCaptureRequest.TimeoutHandler mockTimeoutHandler =
                mock(PictureCaptureRequest.TimeoutHandler.class);
        MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
        PictureCaptureRequest req = new PictureCaptureRequest(mockResult, null, null, mockTimeoutHandler);
        req.error("ERROR_CODE", "Error Message", null);
        verify(mockTimeoutHandler, never()).resetTimeout(any());
        verify(mockTimeoutHandler).clearTimeout(any());
    }

    @Test(expected = IllegalStateException.class)
    public void error_throws_When_already_finished() {
        // Setup
        PictureCaptureRequest req = new PictureCaptureRequest(null, null, null);
        req.setState(PictureCaptureRequestState.STATE_FINISHED);
        // Act
        req.error(null, null, null);
    }
}
