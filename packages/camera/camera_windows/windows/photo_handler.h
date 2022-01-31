// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PHOTO_HANDLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PHOTO_HANDLER_H_

#include <mfapi.h>
#include <mfcaptureengine.h>
#include <wrl/client.h>

#include <memory>
#include <string>

#include "capture_engine_listener.h"

namespace camera_windows {
using Microsoft::WRL::ComPtr;

enum PhotoState {
  PHOTO_STATE__NOT_STARTED,
  PHOTO_STATE__IDLE,
  PHOTO_STATE__TAKING,
};

class PhotoHandler {
 public:
  PhotoHandler(){};
  virtual ~PhotoHandler() = default;

  // Prevent copying.
  PhotoHandler(PhotoHandler const&) = delete;
  PhotoHandler& operator=(PhotoHandler const&) = delete;

  // Initializes photo sink if not initialized and requests
  // capture engine to take photo.
  // Sets photo state to: taking.
  // Returns false if photo cannot be taken.
  //
  // capture_engine:  A pointer to capture engine instance.
  //                  Called to take the photo.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual photo capture media type.
  // file_path:       A string that hold file path for photo capture.
  bool TakePhoto(const std::string& file_path, IMFCaptureEngine* capture_engine,
                 IMFMediaType* base_media_type);

  // Set the photo handler recording state to: idle.
  void OnPhotoTaken();

  // Returns true if photo state is idle
  bool IsInitialized() {
    return photo_state_ == PhotoState::PHOTO_STATE__IDLE;
  };

  // Returns true if photo state is taking.
  bool IsTakingPhoto() {
    return photo_state_ == PhotoState::PHOTO_STATE__TAKING;
  };

  // Returns path to photo capture.
  std::string GetPhotoPath() { return file_path_; };

 private:
  // Initializes record sink for video file capture.
  HRESULT InitPhotoSink(IMFCaptureEngine* capture_engine,
                        IMFMediaType* base_media_type);

  std::string file_path_ = "";
  PhotoState photo_state_ = PhotoState::PHOTO_STATE__NOT_STARTED;
  ComPtr<IMFCapturePhotoSink> photo_sink_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PHOTO_HANDLER_H_
