// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_STRING_UTILS_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_STRING_UTILS_H_

#include <shobjidl.h>

#include <string>

namespace camera_windows {

// Converts the given UTF-16 string to UTF-8.
std::string Utf8FromUtf16(const std::wstring& utf16_string);

// Converts the given UTF-8 string to UTF-16.
std::wstring Utf16FromUtf8(const std::string& utf8_string);

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_STRING_UTILS_H_
