// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/file_selector_windows/file_selector_windows.h"

#include <flutter/plugin_registrar_windows.h>

#include "file_selector_plugin.h"

void FileSelectorWindowsRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  file_selector_windows::FileSelectorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
