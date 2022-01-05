// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_DEVICE_INFO_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_DEVICE_INFO_H_

#include <memory>
#include <string>

namespace camera_windows {

struct CaptureDeviceInfo {
  std::string display_name;
  std::string device_id;
};

std::string GetUniqueDeviceName(std::unique_ptr<CaptureDeviceInfo> device_info);

std::unique_ptr<CaptureDeviceInfo> ParseDeviceInfoFromCameraName(
    const std::string &device_name);

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_DEVICE_INFO_H_