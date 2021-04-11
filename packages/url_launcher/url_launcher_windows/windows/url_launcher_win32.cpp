// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/url_launcher_windows/url_launcher_plugin.h"

#include <windows.h>

#include <string>

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

void OpenLink(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value, std::string url_string) {
    std::wstring url_wide = Utf16FromUtf8(url_string);

   int status = static_cast<int>(reinterpret_cast<INT_PTR>(
       ::ShellExecute(nullptr, TEXT("open"), url_wide.c_str(), nullptr,
                      nullptr, SW_SHOWNORMAL)));

    if (status <= 32) {
       std::ostringstream error_message;
       error_message << "Failed to open " << url_string << ": ShellExecute error code "
                     << status;
       value->Error("open_error", error_message.str());
       return;
     }

     value->Success(flutter::EncodableValue(true));
}

void CanLaunch(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value, std::string url_string) {
    bool can_launch = false;
    size_t separator_location = url_string.find(":");
    if (separator_location != std::string::npos) {
      std::wstring scheme = Utf16FromUtf8(url_string.substr(0, separator_location));
      HKEY key = nullptr;
      if (::RegOpenKeyEx(HKEY_CLASSES_ROOT, scheme.c_str(), 0, KEY_QUERY_VALUE,
                         &key) == ERROR_SUCCESS) {
        can_launch = ::RegQueryValueEx(key, L"URL Protocol", nullptr, nullptr,
                                       nullptr, nullptr) == ERROR_SUCCESS;
        ::RegCloseKey(key);
      }
    }
    value->Success(flutter::EncodableValue(can_launch));
}