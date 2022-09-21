// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_TEST_TEST_FILE_DIALOG_CONTROLLER_H_
#define PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_TEST_TEST_FILE_DIALOG_CONTROLLER_H_

#include <comdef.h>
#include <comip.h>
#include <windows.h>

#include <functional>
#include <memory>
#include <variant>
#include <vector>

#include "file_dialog_controller.h"
#include "test/test_utils.h"

_COM_SMARTPTR_TYPEDEF(IFileDialog, IID_IFileDialog);

namespace file_selector_windows {
namespace test {

class TestFileDialogController;

// A value to use for GetResult(s) in TestFileDialogController. The type depends
// on whether the dialog is an open or save dialog.
using MockShowResult =
    std::variant<std::monostate, IShellItemPtr, IShellItemArrayPtr>;
// Called for TestFileDialogController::Show, to do validation and provide a
// mock return value for GetResult(s).
using MockShow =
    std::function<MockShowResult(const TestFileDialogController&, HWND)>;

// A C++-friendly version of a COMDLG_FILTERSPEC.
struct DialogFilter {
  std::wstring name;
  std::wstring spec;

  DialogFilter(const wchar_t* name, const wchar_t* spec)
      : name(name), spec(spec) {}
};

// An extension of the normal file dialog controller that:
// - Allows for inspection of set values.
// - Allows faking the 'Show' interaction, providing tests an opportunity to
//   validate the dialog settings and provide a return value, via MockShow.
class TestFileDialogController : public FileDialogController {
 public:
  TestFileDialogController(IFileDialog* dialog, MockShow mock_show);
  ~TestFileDialogController();

  // FileDialogController:
  HRESULT SetFolder(IShellItem* folder) override;
  HRESULT SetFileTypes(UINT count, COMDLG_FILTERSPEC* filters) override;
  HRESULT SetOkButtonLabel(const wchar_t* text) override;
  HRESULT Show(HWND parent) override;
  HRESULT GetResult(IShellItem** out_item) const override;
  HRESULT GetResults(IShellItemArray** out_items) const override;

  // Accessors for validating IFileDialogController setter calls.
  // Gets the folder path set by FileDialogController::SetFolder.
  //
  // This exists because there are multiple ways that the value returned by
  // GetDialogFolderPath can be changed, so this allows specifically validating
  // calls to SetFolder.
  std::wstring GetSetFolderPath() const;
  // Gets dialog folder path by calling IFileDialog::GetFolder.
  std::wstring GetDialogFolderPath() const;
  std::wstring GetFileName() const;
  const std::vector<DialogFilter>& GetFileTypes() const;
  std::wstring GetOkButtonLabel() const;

 private:
  IFileDialogPtr dialog_;
  MockShow mock_show_;
  MockShowResult mock_result_;

  // The last set values, for IFileDialog properties that have setters but no
  // corresponding getters.
  std::wstring set_folder_path_;
  std::wstring ok_button_label_;
  std::vector<DialogFilter> filter_groups_;
};

// A controller factory that vends TestFileDialogController instances.
class TestFileDialogControllerFactory : public FileDialogControllerFactory {
 public:
  // Creates a factory whose instances use mock_show for the Show callback.
  TestFileDialogControllerFactory(MockShow mock_show);
  virtual ~TestFileDialogControllerFactory();

  // Disallow copy and assign.
  TestFileDialogControllerFactory(const TestFileDialogControllerFactory&) =
      delete;
  TestFileDialogControllerFactory& operator=(
      const TestFileDialogControllerFactory&) = delete;

  // FileDialogControllerFactory:
  std::unique_ptr<FileDialogController> CreateController(
      IFileDialog* dialog) const override;

 private:
  MockShow mock_show_;
};

}  // namespace test
}  // namespace file_selector_windows

#endif  // PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_TEST_TEST_FILE_DIALOG_CONTROLLER_H_
