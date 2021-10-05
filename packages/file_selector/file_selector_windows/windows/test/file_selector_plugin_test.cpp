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

#include <memory>
#include <string>

#include "file_dialog_controller.h"

namespace file_selector_windows {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::DoAll;
using ::testing::Pointee;
using ::testing::Return;
using ::testing::SetArgPointee;

// An extension of the normal file dialog controller that:
// - Allows for inspection of set values.
// - Allows faking the 'Show' interaction.
class TestFileDialogController : public FileDialogController {};

class TestFileDialogControllerFactory : public FileDialogControllerFactory {
 public:
  TestFileDialogControllerFactory() {}
  virtual ~TestFileDialogControllerFactory() {}

  // Disallow copy and assign.
  TestFileDialogControllerFactory(const TestFileDialogControllerFactory&) =
      delete;
  TestFileDialogControllerFactory& operator=(
      const TestFileDialogControllerFactory&) = delete;

  std::unique_ptr<FileDialogController> CreateController(
      IFileDialog* dialog) override {
    return std::make_unique<FileDialogController>(dialog);
  }
};

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

TEST(FileSelectorPlugin, Placeholder) {
  FileSelectorPlugin plugin(
      nullptr, std::make_unique<TestFileDialogControllerFactory>());

  EXPECT_TRUE(true);
}

}  // namespace test
}  // namespace file_selector_windows
