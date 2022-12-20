// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class SystemServicesHostApiImpl implements SystemServiesHostApi {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;

    private Activity activity;
    private PermissionsRegistry permissionsRegistry;


    public SystemServicesHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
      this.binaryMessenger = binaryMessenger;
      this.instanceManager = instanceManager;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public void setPermissionsRegistry(PermissionsRegistry permissionsRegistry) {
        this.permissionsRegistry = permissionsRegistry;
    }

    @Override
    public Boolean requestCameraPermissions() {
        CameraPermissionsManager cameraPermissionsManager = new CameraPermissionsManager();
        cameraPermissionsManager.requestPermissions(
            activity,
            permissionsRegistry,
            true, // TODO(camsim99): Pass as a parameter whether or not to enable audio.
            (String errCode, String errDesc) -> {
              if (errCode == null) {
                result = true;
              } else {
                result = false;
              }
            }
        );
        // TODO(camsim99): Make this void? Unclear how to handle this.
        return true;
    }

    @Override
    public void startListeningForDeviceOrientationChange() {
        //TODO(camsim99): Use this method to start listening for device orientation changes.
    }

}
