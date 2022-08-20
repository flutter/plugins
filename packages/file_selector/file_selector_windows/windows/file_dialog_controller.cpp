// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "file_dialog_controller.h"

#include <comdef.h>
#include <comip.h>
#include <windows.h>

_COM_SMARTPTR_TYPEDEF(IFileOpenDialog, IID_IFileOpenDialog);

namespace file_selector_windows {

FileDialogController::FileDialogController(IFileDialog* dialog)
    : dialog_(dialog) {}

FileDialogController::~FileDialogController() {}

HRESULT FileDialogController::SetFolder(IShellItem* folder) {
  return dialog_->SetFolder(folder);
}

HRESULT FileDialogController::SetFileName(const wchar_t* name) {
  return dialog_->SetFileName(name);
}

HRESULT FileDialogController::SetFileTypes(UINT count,
                                           COMDLG_FILTERSPEC* filters) {
  return dialog_->SetFileTypes(count, filters);
}

HRESULT FileDialogController::SetOkButtonLabel(const wchar_t* text) {
  return dialog_->SetOkButtonLabel(text);
}

HRESULT FileDialogController::GetOptions(
    FILEOPENDIALOGOPTIONS* out_options) const {
  return dialog_->GetOptions(out_options);
}

HRESULT FileDialogController::SetOptions(FILEOPENDIALOGOPTIONS options) {
  return dialog_->SetOptions(options);
}

HRESULT FileDialogController::Show(HWND parent) {
  return dialog_->Show(parent);
}

HRESULT FileDialogController::GetResult(IShellItem** out_item) const {
  return dialog_->GetResult(out_item);
}

HRESULT FileDialogController::GetResults(IShellItemArray** out_items) const {
  IFileOpenDialogPtr open_dialog;
  HRESULT result = dialog_->QueryInterface(IID_PPV_ARGS(&open_dialog));
  if (!SUCCEEDED(result)) {
    return result;
  }
  result = open_dialog->GetResults(out_items);
  return result;
}

FileDialogControllerFactory::~FileDialogControllerFactory() {}

}  // namespace file_selector_windows
