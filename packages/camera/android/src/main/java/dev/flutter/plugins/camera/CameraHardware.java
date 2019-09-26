package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import java.util.List;

public interface CameraHardware {
  @NonNull
  List<CameraDetails> getAvailableCameras() throws CameraAccessException;
}
