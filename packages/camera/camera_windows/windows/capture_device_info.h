// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_DEVICE_INFO_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_DEVICE_INFO_H_

#include <string>

namespace camera_windows {

// Name and device ID information for a capture device.
class CaptureDeviceInfo {
 public:
  CaptureDeviceInfo() {}
  virtual ~CaptureDeviceInfo() = default;

  // Disallow copy and move.
  CaptureDeviceInfo(const CaptureDeviceInfo&) = delete;
  CaptureDeviceInfo& operator=(const CaptureDeviceInfo&) = delete;

  // Build unique device name from display name and device id.
  // Format: "display_name <device_id>".
  std::string GetUniqueDeviceName() const;

  // Parses display name and device id from unique device name format.
  // Format: "display_name <device_id>".
  bool CaptureDeviceInfo::ParseDeviceInfoFromCameraName(
      const std::string& camera_name);

  // Updates display name.
  void SetDisplayName(const std::string& display_name) {
    display_name_ = display_name;
  }

  // Updates device id.
  void SetDeviceID(const std::string& device_id) { device_id_ = device_id; }

  // Returns device id.
  std::string GetDeviceId() const { return device_id_; }

 private:
  std::string display_name_;
  std::string device_id_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_DEVICE_INFO_H_
