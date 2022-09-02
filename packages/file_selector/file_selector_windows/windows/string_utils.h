// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_STRING_UTILS_H_
#define PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_STRING_UTILS_H_

#include <shobjidl.h>

#include <string>

namespace file_selector_windows {

// Converts the given UTF-16 string to UTF-8.
std::string Utf8FromUtf16(std::wstring_view utf16_string);

// Converts the given UTF-8 string to UTF-16.
std::wstring Utf16FromUtf8(std::string_view utf8_string);

}  // namespace file_selector_windows

#endif  // PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_STRING_UTILS_H_
