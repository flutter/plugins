// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_FILE_SELECTOR_PLUGIN_H_
#define PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_FILE_SELECTOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <functional>

#include "file_dialog_controller.h"
#include "messages.g.h"

namespace file_selector_windows {

// Abstraction for accessing the Flutter view's root window, to allow for faking
// in unit tests without creating fake window hierarchies, as well as to work
// around https://github.com/flutter/flutter/issues/90694.
using FlutterRootWindowProvider = std::function<HWND()>;

class FileSelectorPlugin : public flutter::Plugin, public FileSelectorApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  // Creates a new plugin instance for the given registar, using the given
  // factory to create native dialog controllers.
  FileSelectorPlugin(
      FlutterRootWindowProvider window_provider,
      std::unique_ptr<FileDialogControllerFactory> dialog_controller_factory);

  virtual ~FileSelectorPlugin();

  // FileSelectorApi
  ErrorOr<flutter::EncodableList> ShowOpenDialog(
      const SelectionOptions& options, const std::string* initial_directory,
      const std::string* confirm_button_text) override;
  ErrorOr<flutter::EncodableList> ShowSaveDialog(
      const SelectionOptions& options, const std::string* initialDirectory,
      const std::string* suggestedName,
      const std::string* confirmButtonText) override;

 private:
  // The provider for the root window to attach the dialog to.
  FlutterRootWindowProvider get_root_window_;

  // The factory for creating dialog controller instances.
  std::unique_ptr<FileDialogControllerFactory> controller_factory_;
};

}  // namespace file_selector_windows

#endif  // PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_FILE_SELECTOR_PLUGIN_H_
