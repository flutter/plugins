// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "texture_handler.h"

#include <cassert>

namespace camera_windows {

TextureHandler::~TextureHandler() {
  if (texture_registrar_ && texture_id_ > -1) {
    texture_registrar_->UnregisterTexture(texture_id_);
  }
  texture_id_ = -1;
  texture_registrar_ = nullptr;
  texture_ = nullptr;
  dest_buffer_ = nullptr;
  source_buffer_ = nullptr;
}

int64_t TextureHandler::RegisterTexture() {
  if (!texture_registrar_) {
    return -1;
  }

  // Create flutter desktop pixelbuffer texture;
  texture_ =
      std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
          [this](size_t width,
                 size_t height) -> const FlutterDesktopPixelBuffer* {
            return this->ConvertPixelBufferForFlutter(width, height);
          }));

  texture_id_ = texture_registrar_->RegisterTexture(texture_.get());
  return texture_id_;
}

bool TextureHandler::UpdateBuffer(uint8_t* data, uint32_t data_length) {
  // Scoped lock guard.
  {
    const std::lock_guard<std::mutex> lock(source_buffer_mutex);
    if (!texture_registrar_ || texture_id_ == -1) {
      return false;
    }

    if (source_buffer_ == nullptr || source_buffer_size_ != data_length) {
      // Update source buffer size.
      source_buffer_ = std::make_unique<uint8_t[]>(data_length);
      source_buffer_size_ = data_length;
    }
    std::copy(data, data + data_length, source_buffer_.get());
  }
  OnBufferUpdated();
  return true;
};

// Marks texture frame available after buffer is updated.
void TextureHandler::OnBufferUpdated() {
  if (texture_registrar_ && texture_id_ > -1) {
    texture_registrar_->MarkTextureFrameAvailable(texture_id_);
  }
}

const FlutterDesktopPixelBuffer* TextureHandler::ConvertPixelBufferForFlutter(
    size_t target_width, size_t target_height) {
  // Lock guard source buffer
  const std::lock_guard<std::mutex> lock(source_buffer_mutex);
  if (!texture_registrar_) {
    return nullptr;
  }

  const uint32_t bytes_per_pixel = 4;
  const uint32_t pixels_total = preview_frame_width_ * preview_frame_height_;
  const uint32_t data_size = pixels_total * bytes_per_pixel;
  if (source_buffer_ && data_size > 0 && source_buffer_size_ == data_size) {
    dest_buffer_ = std::make_unique<uint8_t[]>(data_size);

    // Map buffers to structs for easier conversion.
    MFVideoFormatRGB32Pixel* src =
        (MFVideoFormatRGB32Pixel*)source_buffer_.get();
    FlutterDesktopPixel* dst = (FlutterDesktopPixel*)dest_buffer_.get();

    for (uint32_t i = 0; i < pixels_total; i++) {
      dst[i].r = src[i].r;
      dst[i].g = src[i].g;
      dst[i].b = src[i].b;
      dst[i].a = 255;
    }

    // TODO: add release_callback for FlutterDesktopPixelBuffer
    // and clear dest_buffer after each frame.
    flutter_desktop_pixel_buffer_.buffer = dest_buffer_.get();
    flutter_desktop_pixel_buffer_.width = preview_frame_width_;
    flutter_desktop_pixel_buffer_.height = preview_frame_height_;
    return &flutter_desktop_pixel_buffer_;
  }

  return nullptr;
}

}  // namespace camera_windows