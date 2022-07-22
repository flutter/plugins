// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "test/test_file_dialog_controller.h"

#include <windows.h>

#include <functional>
#include <memory>
#include <variant>

namespace file_selector_windows {
namespace test {

TestFileDialogController::TestFileDialogController(IFileDialog* dialog,
                                                   MockShow mock_show)
    : dialog_(dialog),
      mock_show_(std::move(mock_show)),
      FileDialogController(dialog) {}

TestFileDialogController::~TestFileDialogController() {}

HRESULT TestFileDialogController::SetFolder(IShellItem* folder) {
  wchar_t* path_chars = nullptr;
  if (SUCCEEDED(folder->GetDisplayName(SIGDN_FILESYSPATH, &path_chars))) {
    set_folder_path_ = path_chars;
  } else {
    set_folder_path_ = L"";
  }

  return FileDialogController::SetFolder(folder);
}

HRESULT TestFileDialogController::SetFileTypes(UINT count,
                                               COMDLG_FILTERSPEC* filters) {
  filter_groups_.clear();
  for (unsigned int i = 0; i < count; ++i) {
    filter_groups_.push_back(
        DialogFilter(filters[i].pszName, filters[i].pszSpec));
  }
  return FileDialogController::SetFileTypes(count, filters);
}

HRESULT TestFileDialogController::SetOkButtonLabel(const wchar_t* text) {
  ok_button_label_ = text;
  return FileDialogController::SetOkButtonLabel(text);
}

HRESULT TestFileDialogController::Show(HWND parent) {
  mock_result_ = mock_show_(*this, parent);
  if (std::holds_alternative<std::monostate>(mock_result_)) {
    return HRESULT_FROM_WIN32(ERROR_CANCELLED);
  }
  return S_OK;
}

HRESULT TestFileDialogController::GetResult(IShellItem** out_item) const {
  *out_item = std::get<IShellItemPtr>(mock_result_);
  (*out_item)->AddRef();
  return S_OK;
}

HRESULT TestFileDialogController::GetResults(
    IShellItemArray** out_items) const {
  *out_items = std::get<IShellItemArrayPtr>(mock_result_);
  (*out_items)->AddRef();
  return S_OK;
}

std::wstring TestFileDialogController::GetSetFolderPath() const {
  return set_folder_path_;
}

std::wstring TestFileDialogController::GetDialogFolderPath() const {
  IShellItemPtr item;
  if (!SUCCEEDED(dialog_->GetFolder(&item))) {
    return L"";
  }

  wchar_t* path_chars = nullptr;
  if (!SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &path_chars))) {
    return L"";
  }
  std::wstring path(path_chars);
  ::CoTaskMemFree(path_chars);
  return path;
}

std::wstring TestFileDialogController::GetFileName() const {
  wchar_t* name_chars = nullptr;
  if (!SUCCEEDED(dialog_->GetFileName(&name_chars))) {
    return L"";
  }
  std::wstring name(name_chars);
  ::CoTaskMemFree(name_chars);
  return name;
}

const std::vector<DialogFilter>& TestFileDialogController::GetFileTypes()
    const {
  return filter_groups_;
}

std::wstring TestFileDialogController::GetOkButtonLabel() const {
  return ok_button_label_;
}

// ----------------------------------------

TestFileDialogControllerFactory::TestFileDialogControllerFactory(
    MockShow mock_show)
    : mock_show_(std::move(mock_show)) {}
TestFileDialogControllerFactory::~TestFileDialogControllerFactory() {}

std::unique_ptr<FileDialogController>
TestFileDialogControllerFactory::CreateController(IFileDialog* dialog) const {
  return std::make_unique<TestFileDialogController>(dialog, mock_show_);
}

}  // namespace test
}  // namespace file_selector_windows
