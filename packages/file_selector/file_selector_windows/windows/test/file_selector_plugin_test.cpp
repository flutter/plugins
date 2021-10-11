// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "file_selector_plugin.h"

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <functional>
#include <memory>
#include <string>
#include <variant>

#include "file_dialog_controller.h"
#include "string_utils.h"
#include "test/test_file_dialog_controller.h"
#include "test/test_utils.h"

namespace file_selector_windows {
namespace test {

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using ::testing::DoAll;
using ::testing::Pointee;
using ::testing::Return;
using ::testing::SetArgPointee;

class MockMethodResult : public flutter::MethodResult<> {
 public:
  MOCK_METHOD(void, SuccessInternal, (const EncodableValue* result),
              (override));
  MOCK_METHOD(void, ErrorInternal,
              (const std::string& error_code, const std::string& error_message,
               const EncodableValue* details),
              (override));
  MOCK_METHOD(void, NotImplementedInternal, (), (override));
};

}  // namespace

TEST(FileSelectorPlugin, TestOpenSimple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_file.file(),
                                        IID_PPV_ARGS(&fake_result_array));

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_EQ(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_EQ(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };
  EncodableValue expected_paths(EncodableList({
      EncodableValue(Utf8FromUtf16(fake_selected_file.path())),
  }));
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_paths)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("openFile", std::make_unique<EncodableValue>(EncodableMap())),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestOpenWithArguments) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_file.file(),
                                        IID_PPV_ARGS(&fake_result_array));

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate arguments.
    EXPECT_EQ(dialog.GetDefaultFolderPath(), L"C:\\Program Files");
    EXPECT_EQ(dialog.GetFileName(), L"a name");
    EXPECT_EQ(dialog.GetOkButtonLabel(), L"Open it!");

    return MockShowResult(fake_result_array);
  };
  EncodableValue expected_paths(EncodableList({
      EncodableValue(Utf8FromUtf16(fake_selected_file.path())),
  }));
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_paths)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall(
          "openFile",
          std::make_unique<EncodableValue>(EncodableMap({
              // This directory must exist.
              {EncodableValue("initialDirectory"),
               EncodableValue("C:\\Program Files")},
              {EncodableValue("suggestedName"), EncodableValue("a name")},
              {EncodableValue("confirmButtonText"), EncodableValue("Open it!")},
          }))),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestOpenMultiple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestFileIdList fake_selected_file_1;
  ScopedTestFileIdList fake_selected_file_2;
  LPCITEMIDLIST fake_selected_files[] = {
      fake_selected_file_1.file(),
      fake_selected_file_2.file(),
  };
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromIDLists(2, fake_selected_files,
                                      &fake_result_array);

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_NE(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_EQ(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };
  EncodableValue expected_paths(EncodableList({
      EncodableValue(Utf8FromUtf16(fake_selected_file_1.path())),
      EncodableValue(Utf8FromUtf16(fake_selected_file_2.path())),
  }));
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_paths)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("openFile",
                 std::make_unique<EncodableValue>(EncodableMap({
                     {EncodableValue("multiple"), EncodableValue(true)},
                 }))),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestOpenWithFilter) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_file.file(),
                                        IID_PPV_ARGS(&fake_result_array));

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const EncodableValue text_group = EncodableValue(EncodableMap({
      {EncodableValue("label"), EncodableValue("Text")},
      {EncodableValue("extensions"), EncodableValue(EncodableList({
                                         EncodableValue("txt"),
                                         EncodableValue("json"),
                                     }))},
  }));
  const EncodableValue image_group = EncodableValue(EncodableMap({
      {EncodableValue("label"), EncodableValue("Images")},
      {EncodableValue("extensions"), EncodableValue(EncodableList({
                                         EncodableValue("png"),
                                         EncodableValue("gif"),
                                         EncodableValue("jpeg"),
                                     }))},
  }));
  const EncodableValue any_group = EncodableValue(EncodableMap({
      {EncodableValue("label"), EncodableValue("Any")},
  }));

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate filter.
    const std::vector<DialogFilter>& filters = dialog.GetFileTypes();
    EXPECT_EQ(filters.size(), 3U);
    if (filters.size() == 3U) {
      EXPECT_EQ(filters[0].name, L"Text");
      EXPECT_EQ(filters[0].spec, L"*.txt;*.json");
      EXPECT_EQ(filters[1].name, L"Images");
      EXPECT_EQ(filters[1].spec, L"*.png;*.gif;*.jpeg");
      EXPECT_EQ(filters[2].name, L"Any");
      EXPECT_EQ(filters[2].spec, L"*.*");
    }

    return MockShowResult(fake_result_array);
  };
  EncodableValue expected_paths(EncodableList({
      EncodableValue(Utf8FromUtf16(fake_selected_file.path())),
  }));
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_paths)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("openFile", std::make_unique<EncodableValue>(EncodableMap({
                                 {EncodableValue("acceptedTypeGroups"),
                                  EncodableValue(EncodableList({
                                      text_group,
                                      image_group,
                                      any_group,
                                  }))},
                             }))),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestOpenCancel) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    return MockShowResult();
  };
  // Cancel should return a null for the paths.
  EncodableValue expected_paths;
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_paths)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("openFile", std::make_unique<EncodableValue>(EncodableMap())),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestSaveSimple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator =
      [&shown, fake_result = fake_selected_file.file(), fake_window](
          const TestFileDialogController& dialog, HWND parent) {
        shown = true;
        EXPECT_EQ(parent, fake_window);

        // Validate options.
        FILEOPENDIALOGOPTIONS options;
        dialog.GetOptions(&options);
        EXPECT_EQ(options & FOS_ALLOWMULTISELECT, 0U);
        EXPECT_EQ(options & FOS_PICKFOLDERS, 0U);

        return MockShowResult(fake_result);
      };
  EncodableValue expected_path(Utf8FromUtf16(fake_selected_file.path()));
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_path)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("getSavePath",
                 std::make_unique<EncodableValue>(EncodableMap())),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestSaveWithArguments) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator =
      [&shown, fake_result = fake_selected_file.file(), fake_window](
          const TestFileDialogController& dialog, HWND parent) {
        shown = true;
        EXPECT_EQ(parent, fake_window);

        // Validate arguments.
        EXPECT_EQ(dialog.GetDefaultFolderPath(), L"C:\\Program Files");
        EXPECT_EQ(dialog.GetOkButtonLabel(), L"Save it!");

        return MockShowResult(fake_result);
      };
  EncodableValue expected_path(Utf8FromUtf16(fake_selected_file.path()));
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_path)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall(
          "getSavePath",
          std::make_unique<EncodableValue>(EncodableMap({
              // This directory must exist.
              {EncodableValue("initialDirectory"),
               EncodableValue("C:\\Program Files")},
              {EncodableValue("confirmButtonText"), EncodableValue("Save it!")},
          }))),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestSaveCancel) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    return MockShowResult();
  };
  // Cancel should return a null for the path.
  EncodableValue expected_path;
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_path)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("getSavePath",
                 std::make_unique<EncodableValue>(EncodableMap())),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestGetDirectorySimple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  IShellItemPtr fake_selected_directory;
  // This must be a directory that actually exists.
  ::SHCreateItemFromParsingName(L"C:\\Program Files", nullptr,
                                IID_PPV_ARGS(&fake_selected_directory));
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_directory,
                                        IID_PPV_ARGS(&fake_result_array));

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_EQ(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_NE(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };
  EncodableValue expected_path("C:\\Program Files");
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_path)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("getDirectoryPath",
                 std::make_unique<EncodableValue>(EncodableMap())),
      std::move(result));

  EXPECT_TRUE(shown);
}

TEST(FileSelectorPlugin, TestGetDirectoryCancel) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);

  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  bool shown = false;
  MockShow show_validator = [&shown, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    return MockShowResult();
  };
  // Cancel should return a null for the path.
  EncodableValue expected_path;
  // Expect the mock path.
  EXPECT_CALL(*result, SuccessInternal(Pointee(expected_path)));

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  plugin.HandleMethodCall(
      MethodCall("getDirectoryPath",
                 std::make_unique<EncodableValue>(EncodableMap())),
      std::move(result));

  EXPECT_TRUE(shown);
}

}  // namespace test
}  // namespace file_selector_windows
