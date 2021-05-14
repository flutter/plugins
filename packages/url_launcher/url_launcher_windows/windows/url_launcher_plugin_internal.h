// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_URL_LAUNCHER_URL_LAUNCHER_WINDOWS_WINDOWS_URL_LAUNCHER_PLUGIN_INTERNAL_H_
#define PACKAGES_URL_LAUNCHER_URL_LAUNCHER_WINDOWS_WINDOWS_URL_LAUNCHER_PLUGIN_INTERNAL_H_

#include "include/url_launcher_windows/url_launcher_plugin.h"

void OpenLink(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value,
    std::string url_string);

void CanLaunch(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value,
    std::string url_string);

#endif  // PACKAGES_URL_LAUNCHER_URL_LAUNCHER_WINDOWS_WINDOWS_URL_LAUNCHER_PLUGIN_INTERNAL_H_
