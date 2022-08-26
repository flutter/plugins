// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "file_selector_plugin.h"

#include <comdef.h>
#include <comip.h>
#include <flutter/flutter_view.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
#include <windows.h>

#include <cassert>
#include <memory>
#include <string>
#include <vector>

#include "file_dialog_controller.h"
#include "string_utils.h"

_COM_SMARTPTR_TYPEDEF(IEnumShellItems, IID_IEnumShellItems);
_COM_SMARTPTR_TYPEDEF(IFileDialog, IID_IFileDialog);
_COM_SMARTPTR_TYPEDEF(IShellItem, IID_IShellItem);
_COM_SMARTPTR_TYPEDEF(IShellItemArray, IID_IShellItemArray);

namespace file_selector_windows {

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// The kind of file dialog to show.
enum class DialogMode { open, save };

// Returns the path for |shell_item| as a UTF-8 string, or an
// empty string on failure.
std::string GetPathForShellItem(IShellItem* shell_item) {
  if (shell_item == nullptr) {
    return "";
  }
  wchar_t* wide_path = nullptr;
  if (!SUCCEEDED(shell_item->GetDisplayName(SIGDN_FILESYSPATH, &wide_path))) {
    return "";
  }
  std::string path = Utf8FromUtf16(wide_path);
  ::CoTaskMemFree(wide_path);
  return path;
}

// Implementation of FileDialogControllerFactory that makes standard
// FileDialogController instances.
class DefaultFileDialogControllerFactory : public FileDialogControllerFactory {
 public:
  DefaultFileDialogControllerFactory() {}
  virtual ~DefaultFileDialogControllerFactory() {}

  // Disallow copy and assign.
  DefaultFileDialogControllerFactory(
      const DefaultFileDialogControllerFactory&) = delete;
  DefaultFileDialogControllerFactory& operator=(
      const DefaultFileDialogControllerFactory&) = delete;

  std::unique_ptr<FileDialogController> CreateController(
      IFileDialog* dialog) const override {
    assert(dialog != nullptr);
    return std::make_unique<FileDialogController>(dialog);
  }
};

// Wraps an IFileDialog, managing object lifetime as a scoped object and
// providing a simplified API for interacting with it as needed for the plugin.
class DialogWrapper {
 public:
  explicit DialogWrapper(const FileDialogControllerFactory& dialog_factory,
                         IID type) {
    is_open_dialog_ = type == CLSID_FileOpenDialog;
    IFileDialogPtr dialog = nullptr;
    last_result_ = CoCreateInstance(type, nullptr, CLSCTX_INPROC_SERVER,
                                    IID_PPV_ARGS(&dialog));
    dialog_controller_ = dialog_factory.CreateController(dialog);
  }

  // Attempts to set the default folder for the dialog to |path|,
  // if it exists.
  void SetFolder(std::string_view path) {
    std::wstring wide_path = Utf16FromUtf8(path);
    IShellItemPtr item;
    last_result_ = SHCreateItemFromParsingName(wide_path.c_str(), nullptr,
                                               IID_PPV_ARGS(&item));
    if (!SUCCEEDED(last_result_)) {
      return;
    }
    dialog_controller_->SetFolder(item);
  }

  // Sets the file name that is initially shown in the dialog.
  void SetFileName(std::string_view name) {
    std::wstring wide_name = Utf16FromUtf8(name);
    last_result_ = dialog_controller_->SetFileName(wide_name.c_str());
  }

  // Sets the label of the confirmation button.
  void SetOkButtonLabel(std::string_view label) {
    std::wstring wide_label = Utf16FromUtf8(label);
    last_result_ = dialog_controller_->SetOkButtonLabel(wide_label.c_str());
  }

  // Adds the given options to the dialog's current option set.
  void AddOptions(FILEOPENDIALOGOPTIONS new_options) {
    FILEOPENDIALOGOPTIONS options;
    last_result_ = dialog_controller_->GetOptions(&options);
    if (!SUCCEEDED(last_result_)) {
      return;
    }
    options |= new_options;
    if (options & FOS_PICKFOLDERS) {
      opening_directory_ = true;
    }
    last_result_ = dialog_controller_->SetOptions(options);
  }

  // Sets the filters for allowed file types to select.
  void SetFileTypeFilters(const EncodableList& filters) {
    const std::wstring spec_delimiter = L";";
    const std::wstring file_wildcard = L"*.";
    std::vector<COMDLG_FILTERSPEC> filter_specs;
    // Temporary ownership of the constructed strings whose data is used in
    // filter_specs, so that they live until the call to SetFileTypes is done.
    std::vector<std::wstring> filter_names;
    std::vector<std::wstring> filter_extensions;
    filter_extensions.reserve(filters.size());
    filter_names.reserve(filters.size());

    for (const EncodableValue& filter_info_value : filters) {
      const auto& type_group = std::any_cast<TypeGroup>(
          std::get<flutter::CustomEncodableValue>(filter_info_value));
      filter_names.push_back(Utf16FromUtf8(type_group.label()));
      filter_extensions.push_back(L"");
      std::wstring& spec = filter_extensions.back();
      if (type_group.extensions().empty()) {
        spec += L"*.*";
      } else {
        for (const EncodableValue& extension : type_group.extensions()) {
          if (!spec.empty()) {
            spec += spec_delimiter;
          }
          spec +=
              file_wildcard + Utf16FromUtf8(std::get<std::string>(extension));
        }
      }
      filter_specs.push_back({filter_names.back().c_str(), spec.c_str()});
    }
    last_result_ = dialog_controller_->SetFileTypes(
        static_cast<UINT>(filter_specs.size()), filter_specs.data());
  }

  // Displays the dialog, and returns the selected files, or nullopt on error.
  std::optional<EncodableList> Show(HWND parent_window) {
    assert(dialog_controller_);
    last_result_ = dialog_controller_->Show(parent_window);
    if (!SUCCEEDED(last_result_)) {
      return std::nullopt;
    }

    EncodableList files;
    if (is_open_dialog_) {
      IShellItemArrayPtr shell_items;
      last_result_ = dialog_controller_->GetResults(&shell_items);
      if (!SUCCEEDED(last_result_)) {
        return std::nullopt;
      }
      IEnumShellItemsPtr item_enumerator;
      last_result_ = shell_items->EnumItems(&item_enumerator);
      if (!SUCCEEDED(last_result_)) {
        return std::nullopt;
      }
      IShellItemPtr shell_item;
      while (item_enumerator->Next(1, &shell_item, nullptr) == S_OK) {
        files.push_back(EncodableValue(GetPathForShellItem(shell_item)));
      }
    } else {
      IShellItemPtr shell_item;
      last_result_ = dialog_controller_->GetResult(&shell_item);
      if (!SUCCEEDED(last_result_)) {
        return std::nullopt;
      }
      files.push_back(EncodableValue(GetPathForShellItem(shell_item)));
    }
    return files;
  }

  // Returns the result of the last Win32 API call related to this object.
  HRESULT last_result() { return last_result_; }

 private:
  // The dialog controller that all interactions are mediated through, to allow
  // for unit testing.
  std::unique_ptr<FileDialogController> dialog_controller_;
  bool is_open_dialog_;
  bool opening_directory_ = false;
  HRESULT last_result_;
};

ErrorOr<flutter::EncodableList> ShowDialog(
    const FileDialogControllerFactory& dialog_factory, HWND parent_window,
    DialogMode mode, const SelectionOptions& options,
    const std::string* initial_directory, const std::string* suggested_name,
    const std::string* confirm_label) {
  IID dialog_type =
      mode == DialogMode::save ? CLSID_FileSaveDialog : CLSID_FileOpenDialog;
  DialogWrapper dialog(dialog_factory, dialog_type);
  if (!SUCCEEDED(dialog.last_result())) {
    return FlutterError("System error", "Could not create dialog",
                        EncodableValue(dialog.last_result()));
  }

  FILEOPENDIALOGOPTIONS dialog_options = 0;
  if (options.select_folders()) {
    dialog_options |= FOS_PICKFOLDERS;
  }
  if (options.allow_multiple()) {
    dialog_options |= FOS_ALLOWMULTISELECT;
  }
  if (dialog_options != 0) {
    dialog.AddOptions(dialog_options);
  }

  if (initial_directory) {
    dialog.SetFolder(*initial_directory);
  }
  if (suggested_name) {
    dialog.SetFileName(*suggested_name);
  }
  if (confirm_label) {
    dialog.SetOkButtonLabel(*confirm_label);
  }

  if (!options.allowed_types().empty()) {
    dialog.SetFileTypeFilters(options.allowed_types());
  }

  std::optional<EncodableList> files = dialog.Show(parent_window);
  if (!files) {
    if (dialog.last_result() != HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
      return FlutterError("System error", "Could not show dialog",
                          EncodableValue(dialog.last_result()));
    } else {
      return EncodableList();
    }
  }
  return std::move(files.value());
}

// Returns the top-level window that owns |view|.
HWND GetRootWindow(flutter::FlutterView* view) {
  return ::GetAncestor(view->GetNativeWindow(), GA_ROOT);
}

}  // namespace

// static
void FileSelectorPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  std::unique_ptr<FileSelectorPlugin> plugin =
      std::make_unique<FileSelectorPlugin>(
          [registrar] { return GetRootWindow(registrar->GetView()); },
          std::make_unique<DefaultFileDialogControllerFactory>());

  FileSelectorApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
}

FileSelectorPlugin::FileSelectorPlugin(
    FlutterRootWindowProvider window_provider,
    std::unique_ptr<FileDialogControllerFactory> dialog_controller_factory)
    : get_root_window_(std::move(window_provider)),
      controller_factory_(std::move(dialog_controller_factory)) {}

FileSelectorPlugin::~FileSelectorPlugin() = default;

ErrorOr<flutter::EncodableList> FileSelectorPlugin::ShowOpenDialog(
    const SelectionOptions& options, const std::string* initialDirectory,
    const std::string* confirmButtonText) {
  return ShowDialog(*controller_factory_, get_root_window_(), DialogMode::open,
                    options, initialDirectory, nullptr, confirmButtonText);
}

ErrorOr<flutter::EncodableList> FileSelectorPlugin::ShowSaveDialog(
    const SelectionOptions& options, const std::string* initialDirectory,
    const std::string* suggestedName, const std::string* confirmButtonText) {
  return ShowDialog(*controller_factory_, get_root_window_(), DialogMode::save,
                    options, initialDirectory, suggestedName,
                    confirmButtonText);
}

}  // namespace file_selector_windows
