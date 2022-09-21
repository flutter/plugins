// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_FILE_DIALOG_CONTROLLER_H_
#define PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_FILE_DIALOG_CONTROLLER_H_

#include <comdef.h>
#include <comip.h>
#include <shobjidl.h>
#include <windows.h>

#include <memory>

_COM_SMARTPTR_TYPEDEF(IFileDialog, IID_IFileDialog);

namespace file_selector_windows {

// A thin wrapper for IFileDialog to allow for faking and inspection in tests.
//
// Since this class defines the end of what can be unit tested, it should
// contain as little logic as possible.
class FileDialogController {
 public:
  // Creates a controller managing |dialog|.
  FileDialogController(IFileDialog* dialog);
  virtual ~FileDialogController();

  // Disallow copy and assign.
  FileDialogController(const FileDialogController&) = delete;
  FileDialogController& operator=(const FileDialogController&) = delete;

  // IFileDialog wrappers:
  virtual HRESULT SetFolder(IShellItem* folder);
  virtual HRESULT SetFileName(const wchar_t* name);
  virtual HRESULT SetFileTypes(UINT count, COMDLG_FILTERSPEC* filters);
  virtual HRESULT SetOkButtonLabel(const wchar_t* text);
  virtual HRESULT GetOptions(FILEOPENDIALOGOPTIONS* out_options) const;
  virtual HRESULT SetOptions(FILEOPENDIALOGOPTIONS options);
  virtual HRESULT Show(HWND parent);
  virtual HRESULT GetResult(IShellItem** out_item) const;

  // IFileOpenDialog wrapper. This will fail if the IFileDialog* provided to the
  // constructor was not an IFileOpenDialog instance.
  virtual HRESULT GetResults(IShellItemArray** out_items) const;

 private:
  IFileDialogPtr dialog_ = nullptr;
};

// Interface for creating FileDialogControllers, to allow for dependency
// injection.
class FileDialogControllerFactory {
 public:
  virtual ~FileDialogControllerFactory();

  virtual std::unique_ptr<FileDialogController> CreateController(
      IFileDialog* dialog) const = 0;
};

}  // namespace file_selector_windows

#endif  // PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_FILE_DIALOG_CONTROLLER_H_
