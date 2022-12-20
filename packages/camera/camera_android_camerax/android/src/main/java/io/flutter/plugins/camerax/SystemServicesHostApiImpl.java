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
        // TODO(camsim99): Pass as a parameter whether or not to enable audio.
        CameraPermissionsManager cameraPermissionsManager = new CameraPermissionsManager(activity, permissionsRegistry, true);
    }

    @Override
    public void startListeningForDeviceOrientationChange() {
        //TODO(camsim99): Use this method to start listening for device orientation changes.
    }

}
