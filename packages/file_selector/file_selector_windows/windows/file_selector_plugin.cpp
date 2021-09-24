// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/file_selector_windows/file_selector_plugin.h"

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

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// From method_channel_file_selector.dart
const char kChannelName[] = "plugins.flutter.io/file_selector";

const char kOpenFileMethod[] = "openFile";
const char kGetSavePathMethod[] = "getSavePath";
const char kGetDirectoryPathMethod[] = "getDirectoryPath";

const char kAcceptedTypeGroupsKey[] = "acceptedTypeGroups";
const char kConfirmButtonTextKey[] = "confirmButtonText";
const char kInitialDirectoryKey[] = "initialDirectory";
const char kMultipleKey[] = "multiple";
const char kSuggestedNameKey[] = "suggestedName";

// From x_type_group.dart
// Only 'extensions' are supported by Windows for filtering.
const char kTypeGroupLabelKey[] = "label";
const char kTypeGroupExtensionsKey[] = "extensions";

// Converts the given UTF-16 string to UTF-8.
std::string Utf8FromUtf16(const std::wstring &utf16_string) {
  if (utf16_string.empty()) {
    return std::string();
  }
  int target_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string.data(),
      static_cast<int>(utf16_string.length()), nullptr, 0, nullptr, nullptr);
  if (target_length == 0) {
    return std::string();
  }
  std::string utf8_string;
  utf8_string.resize(target_length);
  int converted_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string.data(),
      static_cast<int>(utf16_string.length()), utf8_string.data(),
      target_length, nullptr, nullptr);
  if (converted_length == 0) {
    return std::string();
  }
  return utf8_string;
}

// Converts the given UTF-8 string to UTF-16.
std::wstring Utf16FromUtf8(const std::string &utf8_string) {
  if (utf8_string.empty()) {
    return std::wstring();
  }
  int target_length =
      ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
                            static_cast<int>(utf8_string.length()), nullptr, 0);
  if (target_length == 0) {
    return std::wstring();
  }
  std::wstring utf16_string;
  utf16_string.resize(target_length);
  int converted_length =
      ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
                            static_cast<int>(utf8_string.length()),
                            utf16_string.data(), target_length);
  if (converted_length == 0) {
    return std::wstring();
  }
  return utf16_string;
}

// Looks for |key| in |map|, returning the associated value if it is present, or
// a nullptr if not.
const EncodableValue *ValueOrNull(const EncodableMap &map, const char *key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) {
    return nullptr;
  }
  return &(it->second);
}

// Returns the path for |shell_item| as a UTF-8 string, or an
// empty string on failure.
std::string GetPathForShellItem(IShellItem *shell_item) {
  wchar_t *wide_path = nullptr;
  if (!SUCCEEDED(shell_item->GetDisplayName(SIGDN_FILESYSPATH, &wide_path))) {
    return "";
  }
  std::string path = Utf8FromUtf16(wide_path);
  CoTaskMemFree(wide_path);
  return path;
}

// Wraps an IFileDialog, managing object lifetime as a scoped object and
// providing a simplified API for interacting with it as needed for the plugin.
class DialogWrapper {
 public:
  explicit DialogWrapper(IID type) {
    is_open_dialog_ = type == CLSID_FileOpenDialog;
    last_result_ = CoCreateInstance(type, nullptr, CLSCTX_INPROC_SERVER,
                                    IID_PPV_ARGS(&dialog_));
  }

  ~DialogWrapper() {
    if (dialog_) {
      dialog_->Release();
    }
  }

  // Attempts to set the default folder for the dialog to |path|,
  // if it exists.
  void SetDefaultFolder(const std::string &path) {
    std::wstring wide_path = Utf16FromUtf8(path);
    IShellItem *item;
    last_result_ = SHCreateItemFromParsingName(wide_path.c_str(), nullptr,
                                               IID_PPV_ARGS(&item));
    if (!SUCCEEDED(last_result_)) {
      return;
    }
    dialog_->SetDefaultFolder(item);
    item->Release();
  }

  // Sets the file name that is initially shown in the dialog.
  void SetFileName(const std::string &name) {
    std::wstring wide_name = Utf16FromUtf8(name);
    last_result_ = dialog_->SetFileName(wide_name.c_str());
  }

  // Sets the label of the confirmation button.
  void SetOkButtonLabel(const std::string &label) {
    std::wstring wide_label = Utf16FromUtf8(label);
    last_result_ = dialog_->SetOkButtonLabel(wide_label.c_str());
  }

  // Adds the given options to the dialog's current option set.
  void AddOptions(FILEOPENDIALOGOPTIONS new_options) {
    FILEOPENDIALOGOPTIONS options;
    last_result_ = dialog_->GetOptions(&options);
    if (!SUCCEEDED(last_result_)) {
      return;
    }
    options |= new_options;
    if (options & FOS_PICKFOLDERS) {
      opening_directory_ = true;
    }
    last_result_ = dialog_->SetOptions(options);
  }

  // Sets the filters for allowed file types to select.
  void SetFileTypeFilters(const EncodableList &filters) {
    const std::wstring spec_delimiter = L";";
    const std::wstring file_wildcard = L"*.";
    std::vector<COMDLG_FILTERSPEC> filter_specs;
    // Temporary ownership of the constructed strings whose data is used in
    // filter_specs, so that they live until the call to SetFileTypes is done.
    std::vector<std::wstring> filter_names;
    std::vector<std::wstring> filter_extensions;
    filter_extensions.reserve(filters.size());
    filter_names.reserve(filters.size());

    for (const EncodableValue &filter_info_value : filters) {
      const auto &filter_info = std::get<EncodableMap>(filter_info_value);
      const auto *filter_name = std::get_if<std::string>(
          ValueOrNull(filter_info, kTypeGroupLabelKey));
      const auto *extensions = std::get_if<EncodableList>(
          ValueOrNull(filter_info, kTypeGroupExtensionsKey));
      filter_names.push_back(filter_name ? Utf16FromUtf8(*filter_name) : L"");
      filter_extensions.push_back(L"");
      std::wstring &spec = filter_extensions.back();
      if (!extensions || extensions->empty()) {
        spec += L"*.*";
      } else {
        for (const EncodableValue &extension : *extensions) {
          if (!spec.empty()) {
            spec += spec_delimiter;
          }
          spec +=
              file_wildcard + Utf16FromUtf8(std::get<std::string>(extension));
        }
      }
      filter_specs.push_back({filter_names.back().c_str(), spec.c_str()});
    }
    last_result_ = dialog_->SetFileTypes(static_cast<UINT>(filter_specs.size()),
                                         filter_specs.data());
  }

  // Displays the dialog, and returns the selected file or files as an
  // EncodableValue of type List (for open) or String (for save), or a null
  // EncodableValue on cancel or error.
  EncodableValue Show(HWND parent_window) {
    assert(dialog_);
    last_result_ = dialog_->Show(parent_window);
    if (!SUCCEEDED(last_result_)) {
      return EncodableValue();
    }

    if (is_open_dialog_) {
      IFileOpenDialog *open_dialog;
      last_result_ = dialog_->QueryInterface(IID_PPV_ARGS(&open_dialog));
      if (!SUCCEEDED(last_result_)) {
        return EncodableValue();
      }
      IShellItemArray *shell_items;
      last_result_ = open_dialog->GetResults(&shell_items);
      open_dialog->Release();
      if (!SUCCEEDED(last_result_)) {
        return EncodableValue();
      }
      IEnumShellItems *item_enumerator;
      last_result_ = shell_items->EnumItems(&item_enumerator);
      if (!SUCCEEDED(last_result_)) {
        shell_items->Release();
        return EncodableValue();
      }
      EncodableList files;
      IShellItem *shell_item;
      while (item_enumerator->Next(1, &shell_item, nullptr) == S_OK) {
        files.push_back(EncodableValue(GetPathForShellItem(shell_item)));
        shell_item->Release();
      }
      item_enumerator->Release();
      shell_items->Release();
      if (opening_directory_) {
        // The directory option expects a String, not a List<String>.
        if (files.empty()) {
          return EncodableValue();
        }
        return EncodableValue(files[0]);
      } else {
        return EncodableValue(std::move(files));
      }
    } else {
      IShellItem *shell_item;
      last_result_ = dialog_->GetResult(&shell_item);
      if (!SUCCEEDED(last_result_)) {
        return EncodableValue();
      }
      EncodableValue file(GetPathForShellItem(shell_item));
      shell_item->Release();
      return file;
    }
  }

  // Returns the result of the last Win32 API call related to this object.
  HRESULT last_result() { return last_result_; }

 private:
  IFileDialog *dialog_ = nullptr;
  bool is_open_dialog_;
  bool opening_directory_ = false;
  HRESULT last_result_;
};

// Displays the open or save dialog (according to |method|) and sends the
// selected file path(s) back to the engine via |result|, or sends an
// error on failure.
//
// |result| is guaranteed to be resolved by this function.
void ShowDialog(HWND parent_window, const std::string &method,
                const EncodableMap &args,
                std::unique_ptr<flutter::MethodResult<>> result) {
  IID dialog_type = method.compare(kGetSavePathMethod) == 0
                        ? CLSID_FileSaveDialog
                        : CLSID_FileOpenDialog;
  DialogWrapper dialog(dialog_type);
  if (!SUCCEEDED(dialog.last_result())) {
    result->Error("System error", "Could not create dialog",
                  EncodableValue(dialog.last_result()));
    return;
  }

  FILEOPENDIALOGOPTIONS dialog_options = 0;
  if (method.compare(kGetDirectoryPathMethod) == 0) {
    dialog_options |= FOS_PICKFOLDERS;
  }
  const auto *allow_multiple_selection =
      std::get_if<bool>(ValueOrNull(args, kMultipleKey));
  if (allow_multiple_selection && *allow_multiple_selection) {
    dialog_options |= FOS_ALLOWMULTISELECT;
  }
  if (dialog_options != 0) {
    dialog.AddOptions(dialog_options);
  }

  const auto *initial_dir =
      std::get_if<std::string>(ValueOrNull(args, kInitialDirectoryKey));
  if (initial_dir) {
    dialog.SetDefaultFolder(*initial_dir);
  }
  const auto *suggested_name =
      std::get_if<std::string>(ValueOrNull(args, kSuggestedNameKey));
  if (suggested_name) {
    dialog.SetFileName(*suggested_name);
  }
  const auto *confirm_label =
      std::get_if<std::string>(ValueOrNull(args, kConfirmButtonTextKey));
  if (confirm_label) {
    dialog.SetOkButtonLabel(*confirm_label);
  }
  const auto *accepted_types =
      std::get_if<EncodableList>(ValueOrNull(args, kAcceptedTypeGroupsKey));
  if (accepted_types && !accepted_types->empty()) {
    dialog.SetFileTypeFilters(*accepted_types);
  }

  EncodableValue files = dialog.Show(parent_window);
  if (files.IsNull() &&
      dialog.last_result() != HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
    ;
    result->Error("System error", "Could not show dialog",
                  EncodableValue(dialog.last_result()));
  }
  result->Success(files);
}

// Returns the top-level window that owns |view|.
HWND GetRootWindow(flutter::FlutterView *view) {
  return GetAncestor(view->GetNativeWindow(), GA_ROOT);
}

class FileSelectorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  virtual ~FileSelectorPlugin();

 private:
  FileSelectorPlugin(flutter::PluginRegistrarWindows *registrar);

  // Called when a method is called on plugin channel;
  void HandleMethodCall(const flutter::MethodCall<> &method_call,
                        std::unique_ptr<flutter::MethodResult<>> result);

  // The registrar for this plugin, for accessing the window.
  flutter::PluginRegistrarWindows *registrar_;
};

// static
void FileSelectorPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<>>(
      registrar->messenger(), "plugins.flutter.io/file_selector",
      &flutter::StandardMethodCodec::GetInstance());

  // Uses new instead of make_unique due to private constructor.
  std::unique_ptr<FileSelectorPlugin> plugin(new FileSelectorPlugin(registrar));

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FileSelectorPlugin::FileSelectorPlugin(
    flutter::PluginRegistrarWindows *registrar)
    : registrar_(registrar) {}

FileSelectorPlugin::~FileSelectorPlugin() = default;

void FileSelectorPlugin::HandleMethodCall(
    const flutter::MethodCall<> &method_call,
    std::unique_ptr<flutter::MethodResult<>> result) {
  const std::string &method_name = method_call.method_name();
  if (method_name.compare(kOpenFileMethod) == 0 ||
      method_name.compare(kGetSavePathMethod) == 0 ||
      method_name.compare(kGetDirectoryPathMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);
    ShowDialog(GetRootWindow(registrar_->GetView()), method_name, *arguments,
               std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void FileSelectorPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  FileSelectorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
