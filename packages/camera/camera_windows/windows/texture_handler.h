// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEXTURE_HANDLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEXTURE_HANDLER_H_

#include <flutter/texture_registrar.h>

#include <memory>
#include <mutex>
#include <string>

namespace camera_windows {

// Describes flutter desktop pixelbuffers pixel data order.
struct FlutterDesktopPixel {
  uint8_t r = 0;
  uint8_t g = 0;
  uint8_t b = 0;
  uint8_t a = 0;
};

// Describes MFVideoFormat_RGB32 data order.
struct MFVideoFormatRGB32Pixel {
  uint8_t b = 0;
  uint8_t g = 0;
  uint8_t r = 0;
  uint8_t x = 0;
};

// Handles the registration of Flutter textures, pixel buffers, and the
// conversion of texture formats.
class TextureHandler {
 public:
  TextureHandler(flutter::TextureRegistrar* texture_registrar)
      : texture_registrar_(texture_registrar) {}
  virtual ~TextureHandler();

  // Prevent copying.
  TextureHandler(TextureHandler const&) = delete;
  TextureHandler& operator=(TextureHandler const&) = delete;

  // Updates source data buffer with given data.
  bool UpdateBuffer(uint8_t* data, uint32_t data_length);

  // Registers texture and updates given texture_id pointer value.
  int64_t RegisterTexture();

  // Updates current preview texture size.
  void UpdateTextureSize(uint32_t width, uint32_t height) {
    preview_frame_width_ = width;
    preview_frame_height_ = height;
  }

  // Sets software mirror state.
  void SetMirrorPreviewState(bool mirror) { mirror_preview_ = mirror; }

 private:
  // Informs flutter texture registrar of updated texture.
  void OnBufferUpdated();

  // Converts local pixel buffer to flutter pixel buffer.
  const FlutterDesktopPixelBuffer* ConvertPixelBufferForFlutter(size_t width,
                                                                size_t height);

  // Checks if texture registrar, texture id and texture are available.
  bool TextureRegistered() {
    return texture_registrar_ && texture_ && texture_id_ > -1;
  }

  bool mirror_preview_ = true;
  int64_t texture_id_ = -1;
  uint32_t bytes_per_pixel_ = 4;
  uint32_t source_buffer_size_ = 0;
  uint32_t preview_frame_width_ = 0;
  uint32_t preview_frame_height_ = 0;

  std::vector<uint8_t> source_buffer_;
  std::vector<uint8_t> dest_buffer_;
  std::unique_ptr<flutter::TextureVariant> texture_;
  std::unique_ptr<FlutterDesktopPixelBuffer> flutter_desktop_pixel_buffer_ =
      nullptr;
  flutter::TextureRegistrar* texture_registrar_ = nullptr;

  std::mutex buffer_mutex_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEXTURE_HANDLER_H_
