// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "capture_device_info.h"

#include <memory>
#include <string>

namespace camera_windows {
std::string CaptureDeviceInfo::GetUniqueDeviceName() const {
  return display_name_ + " <" + device_id_ + ">";
}

bool CaptureDeviceInfo::ParseDeviceInfoFromCameraName(
    const std::string& camera_name) {
  size_t delimeter_index = camera_name.rfind(' ', camera_name.length());
  if (delimeter_index != std::string::npos) {
    auto deviceInfo = std::make_unique<CaptureDeviceInfo>();
    display_name_ = camera_name.substr(0, delimeter_index);
    device_id_ = camera_name.substr(delimeter_index + 2,
                                    camera_name.length() - delimeter_index - 3);
    return true;
  }

  return false;
}

}  // namespace camera_windows
