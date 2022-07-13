// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/camera_windows/camera_windows.h"

#include <flutter/plugin_registrar_windows.h>

#include "camera_plugin.h"

void CameraWindowsRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  camera_windows::CameraPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
