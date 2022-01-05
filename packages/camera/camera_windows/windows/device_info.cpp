// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "device_info.h"

#include <memory>
#include <string>

namespace camera_windows {
std::string GetUniqueDeviceName(
    std::unique_ptr<CaptureDeviceInfo> device_info) {
  return device_info->display_name + " <" + device_info->device_id + ">";
}

std::unique_ptr<CaptureDeviceInfo> ParseDeviceInfoFromCameraName(
    const std::string &camera_name) {
  size_t delimeter_index = camera_name.rfind(' ', camera_name.length());
  if (delimeter_index != std::string::npos) {
    auto deviceInfo = std::make_unique<CaptureDeviceInfo>();
    deviceInfo->display_name = camera_name.substr(0, delimeter_index);
    deviceInfo->device_id = camera_name.substr(
        delimeter_index + 2, camera_name.length() - delimeter_index - 3);
    return deviceInfo;
  }

  return nullptr;
}
}  // namespace camera_windows