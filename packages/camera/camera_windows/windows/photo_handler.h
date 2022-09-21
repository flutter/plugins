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

// Various states that the photo handler can be in.
//
// When created, the handler is in |kNotStarted| state and transtions in
// sequential order through the states.
enum class PhotoState {
  kNotStarted,
  kIdle,
  kTakingPhoto,
};

// Handles photo sink initialization and tracks photo capture states.
class PhotoHandler {
 public:
  PhotoHandler() {}
  virtual ~PhotoHandler() = default;

  // Prevent copying.
  PhotoHandler(PhotoHandler const&) = delete;
  PhotoHandler& operator=(PhotoHandler const&) = delete;

  // Initializes photo sink if not initialized and requests the capture engine
  // to take photo.
  //
  // Sets photo state to: kTakingPhoto.
  //
  // capture_engine:  A pointer to capture engine instance.
  //                  Called to take the photo.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual photo capture media type.
  // file_path:       A string that hold file path for photo capture.
  HRESULT TakePhoto(const std::string& file_path,
                    IMFCaptureEngine* capture_engine,
                    IMFMediaType* base_media_type);

  // Set the photo handler recording state to: kIdle.
  void OnPhotoTaken();

  // Returns true if photo state is kIdle.
  bool IsInitialized() const { return photo_state_ == PhotoState::kIdle; }

  // Returns true if photo state is kTakingPhoto.
  bool IsTakingPhoto() const {
    return photo_state_ == PhotoState::kTakingPhoto;
  }

  // Returns the filesystem path of the captured photo.
  std::string GetPhotoPath() const { return file_path_; }

 private:
  // Initializes record sink for video file capture.
  HRESULT InitPhotoSink(IMFCaptureEngine* capture_engine,
                        IMFMediaType* base_media_type);

  std::string file_path_;
  PhotoState photo_state_ = PhotoState::kNotStarted;
  ComPtr<IMFCapturePhotoSink> photo_sink_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PHOTO_HANDLER_H_
