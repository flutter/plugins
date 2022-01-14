// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_SYSTEM_API_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_SYSTEM_API_H_

namespace camera_windows {

class SystemApi {
 public:
  SystemApi(){};
  virtual ~SystemApi() = default;

  // Disallow copy and move.
  SystemApi(const SystemApi&) = delete;
  SystemApi& operator=(const SystemApi&) = delete;
};

class SystemApiImpl : public SystemApi {
 public:
  SystemApiImpl(){};
  virtual ~SystemApiImpl() = default;

  // Disallow copy and move.
  SystemApiImpl(const SystemApiImpl&) = delete;
  SystemApiImpl& operator=(const SystemApiImpl&) = delete;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_SYSTEM_API_H_