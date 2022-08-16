// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera.h"

namespace camera_windows {
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// Camera channel events.
constexpr char kCameraMethodChannelBaseName[] =
    "plugins.flutter.io/camera_windows/camera";
constexpr char kVideoRecordedEvent[] = "video_recorded";
constexpr char kCameraClosingEvent[] = "camera_closing";
constexpr char kErrorEvent[] = "error";

// Camera error codes
constexpr char kCameraAccessDenied[] = "CameraAccessDenied";
constexpr char kCameraError[] = "camera_error";
constexpr char kPluginDisposed[] = "plugin_disposed";

std::string GetErrorCode(CameraResult result) {
  assert(result != CameraResult::kSuccess);

  switch (result) {
    case CameraResult::kAccessDenied:
      return kCameraAccessDenied;

    case CameraResult::kSuccess:
    case CameraResult::kError:
    default:
      return kCameraError;
  }
}

CameraImpl::CameraImpl(const std::string& device_id)
    : device_id_(device_id), Camera(device_id) {}

CameraImpl::~CameraImpl() {
  // Sends camera closing event.
  OnCameraClosing();

  capture_controller_ = nullptr;
  SendErrorForPendingResults(kPluginDisposed,
                             "Plugin disposed before request was handled");
}

bool CameraImpl::InitCamera(flutter::TextureRegistrar* texture_registrar,
                            flutter::BinaryMessenger* messenger,
                            bool record_audio,
                            ResolutionPreset resolution_preset) {
  auto capture_controller_factory =
      std::make_unique<CaptureControllerFactoryImpl>();
  return InitCamera(std::move(capture_controller_factory), texture_registrar,
                    messenger, record_audio, resolution_preset);
}

bool CameraImpl::InitCamera(
    std::unique_ptr<CaptureControllerFactory> capture_controller_factory,
    flutter::TextureRegistrar* texture_registrar,
    flutter::BinaryMessenger* messenger, bool record_audio,
    ResolutionPreset resolution_preset) {
  assert(!device_id_.empty());
  messenger_ = messenger;
  capture_controller_ =
      capture_controller_factory->CreateCaptureController(this);
  return capture_controller_->InitCaptureDevice(
      texture_registrar, device_id_, record_audio, resolution_preset);
}

bool CameraImpl::AddPendingResult(
    PendingResultType type, std::unique_ptr<flutter::MethodResult<>> result) {
  assert(result);

  auto it = pending_results_.find(type);
  if (it != pending_results_.end()) {
    result->Error("Duplicate request", "Method handler already called");
    return false;
  }

  pending_results_.insert(std::make_pair(type, std::move(result)));
  return true;
}

std::unique_ptr<flutter::MethodResult<>> CameraImpl::GetPendingResultByType(
    PendingResultType type) {
  auto it = pending_results_.find(type);
  if (it == pending_results_.end()) {
    return nullptr;
  }
  auto result = std::move(it->second);
  pending_results_.erase(it);
  return result;
}

bool CameraImpl::HasPendingResultByType(PendingResultType type) const {
  auto it = pending_results_.find(type);
  if (it == pending_results_.end()) {
    return false;
  }
  return it->second != nullptr;
}

void CameraImpl::SendErrorForPendingResults(const std::string& error_code,
                                            const std::string& description) {
  for (const auto& pending_result : pending_results_) {
    pending_result.second->Error(error_code, description);
  }
  pending_results_.clear();
}

MethodChannel<>* CameraImpl::GetMethodChannel() {
  assert(messenger_);
  assert(camera_id_);

  // Use existing channel if initialized
  if (camera_channel_) {
    return camera_channel_.get();
  }

  auto channel_name =
      std::string(kCameraMethodChannelBaseName) + std::to_string(camera_id_);

  camera_channel_ = std::make_unique<flutter::MethodChannel<>>(
      messenger_, channel_name, &flutter::StandardMethodCodec::GetInstance());

  return camera_channel_.get();
}

void CameraImpl::OnCreateCaptureEngineSucceeded(int64_t texture_id) {
  // Use texture id as camera id
  camera_id_ = texture_id;
  auto pending_result =
      GetPendingResultByType(PendingResultType::kCreateCamera);
  if (pending_result) {
    pending_result->Success(EncodableMap(
        {{EncodableValue("cameraId"), EncodableValue(texture_id)}}));
  }
}

void CameraImpl::OnCreateCaptureEngineFailed(CameraResult result,
                                             const std::string& error) {
  auto pending_result =
      GetPendingResultByType(PendingResultType::kCreateCamera);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result->Error(error_code, error);
  }
}

void CameraImpl::OnStartPreviewSucceeded(int32_t width, int32_t height) {
  auto pending_result = GetPendingResultByType(PendingResultType::kInitialize);
  if (pending_result) {
    pending_result->Success(EncodableValue(EncodableMap({
        {EncodableValue("previewWidth"),
         EncodableValue(static_cast<float>(width))},
        {EncodableValue("previewHeight"),
         EncodableValue(static_cast<float>(height))},
    })));
  }
};

void CameraImpl::OnStartPreviewFailed(CameraResult result,
                                      const std::string& error) {
  auto pending_result = GetPendingResultByType(PendingResultType::kInitialize);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result->Error(error_code, error);
  }
};

void CameraImpl::OnResumePreviewSucceeded() {
  auto pending_result =
      GetPendingResultByType(PendingResultType::kResumePreview);
  if (pending_result) {
    pending_result->Success();
  }
}

void CameraImpl::OnResumePreviewFailed(CameraResult result,
                                       const std::string& error) {
  auto pending_result =
      GetPendingResultByType(PendingResultType::kResumePreview);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result->Error(error_code, error);
  }
}

void CameraImpl::OnPausePreviewSucceeded() {
  auto pending_result =
      GetPendingResultByType(PendingResultType::kPausePreview);
  if (pending_result) {
    pending_result->Success();
  }
}

void CameraImpl::OnPausePreviewFailed(CameraResult result,
                                      const std::string& error) {
  auto pending_result =
      GetPendingResultByType(PendingResultType::kPausePreview);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result->Error(error_code, error);
  }
}

void CameraImpl::OnStartRecordSucceeded() {
  auto pending_result = GetPendingResultByType(PendingResultType::kStartRecord);
  if (pending_result) {
    pending_result->Success();
  }
};

void CameraImpl::OnStartRecordFailed(CameraResult result,
                                     const std::string& error) {
  auto pending_result = GetPendingResultByType(PendingResultType::kStartRecord);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result->Error(error_code, error);
  }
};

void CameraImpl::OnStopRecordSucceeded(const std::string& file_path) {
  auto pending_result = GetPendingResultByType(PendingResultType::kStopRecord);
  if (pending_result) {
    pending_result->Success(EncodableValue(file_path));
  }
};

void CameraImpl::OnStopRecordFailed(CameraResult result,
                                    const std::string& error) {
  auto pending_result = GetPendingResultByType(PendingResultType::kStopRecord);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result->Error(error_code, error);
  }
};

void CameraImpl::OnTakePictureSucceeded(const std::string& file_path) {
  auto pending_result = GetPendingResultByType(PendingResultType::kTakePicture);
  if (pending_result) {
    pending_result->Success(EncodableValue(file_path));
  }
};

void CameraImpl::OnTakePictureFailed(CameraResult result,
                                     const std::string& error) {
  auto pending_take_picture_result =
      GetPendingResultByType(PendingResultType::kTakePicture);
  if (pending_take_picture_result) {
    std::string error_code = GetErrorCode(result);
    pending_take_picture_result->Error(error_code, error);
  }
};

void CameraImpl::OnVideoRecordSucceeded(const std::string& file_path,
                                        int64_t video_duration_ms) {
  if (messenger_ && camera_id_ >= 0) {
    auto channel = GetMethodChannel();

    std::unique_ptr<EncodableValue> message_data =
        std::make_unique<EncodableValue>(
            EncodableMap({{EncodableValue("path"), EncodableValue(file_path)},
                          {EncodableValue("maxVideoDuration"),
                           EncodableValue(video_duration_ms)}}));

    channel->InvokeMethod(kVideoRecordedEvent, std::move(message_data));
  }
}

void CameraImpl::OnVideoRecordFailed(CameraResult result,
                                     const std::string& error){};

void CameraImpl::OnCaptureError(CameraResult result, const std::string& error) {
  if (messenger_ && camera_id_ >= 0) {
    auto channel = GetMethodChannel();

    std::unique_ptr<EncodableValue> message_data =
        std::make_unique<EncodableValue>(EncodableMap(
            {{EncodableValue("description"), EncodableValue(error)}}));
    channel->InvokeMethod(kErrorEvent, std::move(message_data));
  }

  std::string error_code = GetErrorCode(result);
  SendErrorForPendingResults(error_code, error);
}

void CameraImpl::OnCameraClosing() {
  if (messenger_ && camera_id_ >= 0) {
    auto channel = GetMethodChannel();
    channel->InvokeMethod(kCameraClosingEvent,
                          std::move(std::make_unique<EncodableValue>()));
  }
}

}  // namespace camera_windows
