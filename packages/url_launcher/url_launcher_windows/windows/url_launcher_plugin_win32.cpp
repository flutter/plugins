// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <sstream>
#include <string>

#include "url_launcher_plugin.h"

namespace url_launcher_plugin {

namespace {

using flutter::EncodableValue;

// Converts the given UTF-8 string to UTF-16.
std::wstring Utf16FromUtf8(const std::string& utf8_string) {
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

}  // namespace

void UrlLauncherPlugin::CanLaunchUrl(
    const std::string& url, std::unique_ptr<flutter::MethodResult<>> result) {
  size_t separator_location = url.find(":");
  if (separator_location == std::string::npos) {
    result->Success(EncodableValue(false));
    return;
  }
  std::wstring scheme = Utf16FromUtf8(url.substr(0, separator_location));

  HKEY key = nullptr;
  if (system_apis_->RegOpenKeyExW(HKEY_CLASSES_ROOT, scheme.c_str(), 0,
                                  KEY_QUERY_VALUE, &key) != ERROR_SUCCESS) {
    result->Success(EncodableValue(false));
    return;
  }
  bool has_handler =
      system_apis_->RegQueryValueExW(key, L"URL Protocol", nullptr, nullptr,
                                     nullptr) == ERROR_SUCCESS;
  system_apis_->RegCloseKey(key);

  result->Success(EncodableValue(has_handler));
}

void UrlLauncherPlugin::LaunchUrl(
    const std::string& url, std::unique_ptr<flutter::MethodResult<>> result) {
  std::wstring url_wide = Utf16FromUtf8(url);

  int status = static_cast<int>(reinterpret_cast<INT_PTR>(
      system_apis_->ShellExecuteW(nullptr, TEXT("open"), url_wide.c_str(),
                                  nullptr, nullptr, SW_SHOWNORMAL)));

  // Per ::ShellExecuteW documentation, anything >32 indicates success.
  if (status <= 32) {
    std::ostringstream error_message;
    error_message << "Failed to open " << url << ": ShellExecute error code "
                  << status;
    result->Error("open_error", error_message.str());
    return;
  }
  result->Success(EncodableValue(true));
}

}  // namespace url_launcher_plugin
