// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

namespace file_selector_windows {

class FileSelectorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FileSelectorPlugin(flutter::PluginRegistrarWindows *registrar);

  virtual ~FileSelectorPlugin();

 private:
  // Called when a method is called on plugin channel;
  void HandleMethodCall(const flutter::MethodCall<> &method_call,
                        std::unique_ptr<flutter::MethodResult<>> result);

  // The registrar for this plugin, for accessing the window.
  flutter::PluginRegistrarWindows *registrar_;
};

}  // namespace file_selector_windows
