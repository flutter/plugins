// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera_plugin.h"

#include <flutter/flutter_view.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <mfapi.h>
#include <mfidl.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <windows.h>

#include <cassert>
#include <chrono>
#include <memory>

#include "device_info.h"
#include "string_utils.h"

namespace camera_windows {
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

// Channel events
const char kChannelName[] = "plugins.flutter.io/camera";

const char kAvailableCamerasMethod[] = "availableCameras";
const char kCreateMethod[] = "create";
const char kInitializeMethod[] = "initialize";
const char kTakePictureMethod[] = "takePicture";
const char kStartVideoRecordingMethod[] = "startVideoRecording";
const char kStopVideoRecordingMethod[] = "stopVideoRecording";
const char kPausePreview[] = "pausePreview";
const char kResumePreview[] = "resumePreview";
const char kDisposeMethod[] = "dispose";

const char kCameraNameKey[] = "cameraName";
const char kResolutionPresetKey[] = "resolutionPreset";
const char kEnableAudioKey[] = "enableAudio";

const char kCameraIdKey[] = "cameraId";
const char kMaxVideoDurationKey[] = "maxVideoDuration";

const char kResolutionPresetValueLow[] = "low";
const char kResolutionPresetValueMedium[] = "medium";
const char kResolutionPresetValueHigh[] = "high";
const char kResolutionPresetValueVeryHigh[] = "veryHigh";
const char kResolutionPresetValueUltraHigh[] = "ultraHigh";
const char kResolutionPresetValueMax[] = "max";

const std::string kPictureCaptureExtension = "jpeg";
const std::string kVideoCaptureExtension = "mp4";

// Looks for |key| in |map|, returning the associated value if it is present, or
// a nullptr if not.
const EncodableValue *ValueOrNull(const EncodableMap &map, const char *key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) {
    return nullptr;
  }
  return &(it->second);
}

// Parses resolution preset argument to enum value
ResolutionPreset ParseResolutionPreset(const std::string &resolution_preset) {
  if (resolution_preset.compare(kResolutionPresetValueLow) == 0) {
    return ResolutionPreset::RESOLUTION_PRESET_LOW;
  } else if (resolution_preset.compare(kResolutionPresetValueMedium) == 0) {
    return ResolutionPreset::RESOLUTION_PRESET_MEDIUM;
  } else if (resolution_preset.compare(kResolutionPresetValueHigh) == 0) {
    return ResolutionPreset::RESOLUTION_PRESET_HIGH;
  } else if (resolution_preset.compare(kResolutionPresetValueVeryHigh) == 0) {
    return ResolutionPreset::RESOLUTION_PRESET_VERY_HIGH;
  } else if (resolution_preset.compare(kResolutionPresetValueUltraHigh) == 0) {
    return ResolutionPreset::RESOLUTION_PRESET_ULTRA_HIGH;
  } else if (resolution_preset.compare(kResolutionPresetValueMax) == 0) {
    return ResolutionPreset::RESOLUTION_PRESET_MAX;
  }
  return ResolutionPreset::RESOLUTION_PRESET_AUTO;
}

bool HasCurrentTextureId(int64_t current_camera_id, const EncodableMap &args) {
  const auto *camera_id =
      std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));

  if (!camera_id) {
    return false;
  }
  return current_camera_id == *camera_id;
}

std::unique_ptr<CaptureDeviceInfo> GetDeviceInfo(IMFActivate *device) {
  assert(device);
  auto device_info = std::make_unique<CaptureDeviceInfo>();
  wchar_t *name;
  UINT32 name_size;

  HRESULT hr = device->GetAllocatedString(MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME,
                                          &name, &name_size);
  if (SUCCEEDED(hr)) {
    wchar_t *id;
    UINT32 id_size;
    hr = device->GetAllocatedString(
        MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_SYMBOLIC_LINK, &id, &id_size);

    if (SUCCEEDED(hr)) {
      device_info->display_name = Utf8FromUtf16(std::wstring(name, name_size));
      device_info->device_id = Utf8FromUtf16(std::wstring(id, id_size));
    }

    ::CoTaskMemFree(id);
  }

  ::CoTaskMemFree(name);
  return device_info;
}

std::string GetCurrentTimeString() {
  std::chrono::system_clock::duration now =
      std::chrono::system_clock::now().time_since_epoch();

  auto s = std::chrono::duration_cast<std::chrono::seconds>(now).count();
  auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(now).count();

  struct tm newtime;
  localtime_s(&newtime, &s);

  std::string time_start = "";
  time_start.resize(80);
  size_t len =
      strftime(&time_start[0], time_start.size(), "%Y_%m%d_%H%M%S_", &newtime);
  if (len > 0) {
    time_start.resize(len);
  }

  // Add milliseconds
  return time_start + std::to_string(ms - s * 1000);
}

bool GetFilePathForPicture(std::string &filename) {
  wchar_t *known_folder_path = nullptr;
  HRESULT hr = SHGetKnownFolderPath(FOLDERID_Pictures, KF_FLAG_CREATE, nullptr,
                                    &known_folder_path);

  if (SUCCEEDED(hr)) {
    std::string path = Utf8FromUtf16(std::wstring(known_folder_path));

    filename = path + "\\" + "PhotoCapture_" + GetCurrentTimeString() + "." +
               kPictureCaptureExtension;
  }

  return SUCCEEDED(hr);
}

bool GetFilePathForVideo(std::string &filename) {
  wchar_t *known_folder_path = nullptr;
  HRESULT hr = SHGetKnownFolderPath(FOLDERID_Videos, KF_FLAG_CREATE, nullptr,
                                    &known_folder_path);

  if (SUCCEEDED(hr)) {
    std::string path = Utf8FromUtf16(std::wstring(known_folder_path));

    filename = path + "\\" + "VideoCapture_" + GetCurrentTimeString() + "." +
               kVideoCaptureExtension;
  }

  return SUCCEEDED(hr);
}
}  // namespace

// static
void CameraPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<>>(
      registrar->messenger(), kChannelName,
      &flutter::StandardMethodCodec::GetInstance());

  std::unique_ptr<CameraPlugin> plugin = std::make_unique<CameraPlugin>(
      registrar->texture_registrar(), registrar->messenger());

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

CameraPlugin::CameraPlugin(flutter::TextureRegistrar *texture_registrar,
                           flutter::BinaryMessenger *messenger)
    : texture_registrar_(texture_registrar),
      messenger_(messenger),
      camera_factory_(std::make_unique<CameraFactoryImpl>()) {}

CameraPlugin::CameraPlugin(flutter::TextureRegistrar *texture_registrar,
                           flutter::BinaryMessenger *messenger,
                           std::unique_ptr<CameraFactory> camera_factory)
    : texture_registrar_(texture_registrar),
      messenger_(messenger),
      camera_factory_(std::move(camera_factory)) {}

CameraPlugin::~CameraPlugin() {}

void CameraPlugin::HandleMethodCall(
    const flutter::MethodCall<> &method_call,
    std::unique_ptr<flutter::MethodResult<>> result) {
  const std::string &method_name = method_call.method_name();

  if (method_name.compare(kAvailableCamerasMethod) == 0) {
    return AvailableCamerasMethodHandler(std::move(result));
  } else if (method_name.compare(kCreateMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return CreateMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kInitializeMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return this->InitializeMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kTakePictureMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return TakePictureMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kStartVideoRecordingMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return StartVideoRecordingMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kStopVideoRecordingMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return StopVideoRecordingMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kPausePreview) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return PausePreviewMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kResumePreview) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return ResumePreviewMethodHandler(*arguments, std::move(result));
  } else if (method_name.compare(kDisposeMethod) == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    assert(arguments);

    return DisposeMethodHandler(*arguments, std::move(result));
  } else {
    result->NotImplemented();
  }
}

void CameraPlugin::AvailableCamerasMethodHandler(
    std::unique_ptr<flutter::MethodResult<>> result) {
  // Enumerate devices.
  IMFActivate **devices;
  UINT32 count = 0;
  if (!this->EnumerateVideoCaptureDeviceSources(&devices, &count)) {
    result->Error("System error", "Failed to get available cameras");
    // No need to free devices here, cos allocation failed
    return;
  }

  if (count == 0) {
    result->Success(EncodableValue(EncodableList()));
    CoTaskMemFree(devices);
    return;
  }

  // Format found devices to the response
  EncodableList devices_list;
  for (UINT32 i = 0; i < count; ++i) {
    auto device_info = GetDeviceInfo(devices[i]);
    auto deviceName = GetUniqueDeviceName(std::move(device_info));

    // TODO: get lens facing info and sensor orientation from devices
    devices_list.push_back(EncodableMap({
        {EncodableValue("name"), EncodableValue(deviceName)},
        {EncodableValue("lensFacing"), EncodableValue("front")},
        {EncodableValue("sensorOrientation"), EncodableValue(0)},
    }));
  }

  CoTaskMemFree(devices);
  result->Success(std::move(EncodableValue(devices_list)));
}

bool CameraPlugin::EnumerateVideoCaptureDeviceSources(IMFActivate ***devices,
                                                      UINT32 *count) {
  return CaptureControllerImpl::EnumerateVideoCaptureDeviceSources(devices,
                                                                   count);
}

// Loops through cameras and returns camera with matching device_id or nullptr
Camera *CameraPlugin::GetCameraByDeviceId(std::string &device_id) {
  for (auto it = begin(cameras_); it != end(cameras_); ++it) {
    if ((*it)->HasDeviceId(device_id)) {
      return it->get();
    }
  }
  return nullptr;
}

// Loops through cameras and returns camera with matching camera_id or nullptr
Camera *CameraPlugin::GetCameraByCameraId(int64_t camera_id) {
  for (auto it = begin(cameras_); it != end(cameras_); ++it) {
    if ((*it)->HasCameraId(camera_id)) {
      return it->get();
    }
  }
  return nullptr;
}

void CameraPlugin::DisposeCameraByCameraId(int64_t camera_id) {
  for (auto it = begin(cameras_); it != end(cameras_); ++it) {
    if ((*it)->HasCameraId(camera_id)) {
      cameras_.erase(it);
      return;
    }
  }
}

// Creates and initializes capture controller
// and MFCaptureEngine for requested device
void CameraPlugin::CreateMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  // Parse enableAudio argument
  const auto *enable_audio =
      std::get_if<bool>(ValueOrNull(args, kEnableAudioKey));
  if (!enable_audio) {
    return result->Error("Argument error",
                         std::string(kEnableAudioKey) + " argument missing");
  }

  // Parse cameraName argument
  const auto *camera_name =
      std::get_if<std::string>(ValueOrNull(args, kCameraNameKey));
  if (!camera_name) {
    return result->Error("Argument error",
                         std::string(kCameraNameKey) + " argument missing");
  }
  auto device_info = ParseDeviceInfoFromCameraName(*camera_name);

  if (!device_info) {
    return result->Error(
        "Camera error", "Cannot parse argument " + std::string(kCameraNameKey));
  }

  if (GetCameraByDeviceId(device_info->device_id)) {
    return result->Error(
        "Camera error",
        "Camera with given " + std::string(*camera_name) + " already exists");
  }

  std::unique_ptr<camera_windows::Camera> camera =
      camera_factory_->CreateCamera(device_info->device_id);

  if (camera->HasPendingResultByType(PendingResultType::CREATE_CAMERA)) {
    // This should never happen
    return result->Error("Failed to create camera",
                         "Pending camera creation already exists");
  }

  if (camera->AddPendingResult(PendingResultType::CREATE_CAMERA,
                               std::move(result))) {
    // Parse resolutionPreset argument
    const auto *resolution_preset_argument =
        std::get_if<std::string>(ValueOrNull(args, kResolutionPresetKey));
    ResolutionPreset resolution_preset;
    if (resolution_preset_argument) {
      resolution_preset = ParseResolutionPreset(*resolution_preset_argument);
    } else {
      resolution_preset = ResolutionPreset::RESOLUTION_PRESET_AUTO;
    }

    camera->InitCamera(texture_registrar_, messenger_, *enable_audio,
                       resolution_preset);
    cameras_.push_back(std::move(camera));
  }
}

void CameraPlugin::InitializeMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  auto camera = GetCameraByCameraId(*camera_id);
  if (!camera) {
    return result->Error("Camera not created", "Please create camera first");
  }

  if (camera->HasPendingResultByType(PendingResultType::INITIALIZE)) {
    return result->Error("Failed to initialize",
                         "Initialize method already called");
  }

  if (camera->AddPendingResult(PendingResultType::INITIALIZE,
                               std::move(result))) {
    auto cc = camera->GetCaptureController();
    assert(cc);
    cc->StartPreview();
  }
}

void CameraPlugin::PausePreviewMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  auto camera = GetCameraByCameraId(*camera_id);
  if (!camera) {
    return result->Error("Camera not created", "Please create camera first");
  }

  if (camera->HasPendingResultByType(PendingResultType::PAUSE_PREVIEW)) {
    return result->Error("Failed to initialize",
                         "Pause preview method already called");
  }

  if (camera->AddPendingResult(PendingResultType::PAUSE_PREVIEW,
                               std::move(result))) {
    // Capture engine does not really have pause feature...
    // so preview is stopped instead.
    auto cc = camera->GetCaptureController();
    assert(cc);
    cc->PausePreview();
  }
}

void CameraPlugin::ResumePreviewMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  auto camera = GetCameraByCameraId(*camera_id);
  if (!camera) {
    return result->Error("Camera not created", "Please create camera first");
  }

  if (camera->HasPendingResultByType(PendingResultType::RESUME_PREVIEW)) {
    return result->Error("Failed to initialize",
                         "Resume preview method already called");
  }

  if (camera->AddPendingResult(PendingResultType::RESUME_PREVIEW,
                               std::move(result))) {
    // Capture engine does not really have pause feature...
    // so preview is started instead
    auto cc = camera->GetCaptureController();
    assert(cc);
    cc->ResumePreview();
  }
}

void CameraPlugin::StartVideoRecordingMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  auto camera = GetCameraByCameraId(*camera_id);
  if (!camera) {
    return result->Error("Camera not created", "Please create camera first");
  }

  if (camera->HasPendingResultByType(PendingResultType::START_RECORD)) {
    return result->Error("Failed to start video recording",
                         "Video recording starting already");
  }

  // Get max video duration
  int64_t max_video_duration_ms = -1;
  auto requested_max_video_duration_ms =
      std::get_if<std::int32_t>(ValueOrNull(args, kMaxVideoDurationKey));

  if (requested_max_video_duration_ms != nullptr) {
    max_video_duration_ms = *requested_max_video_duration_ms;
  }

  std::string path;
  if (GetFilePathForVideo(path)) {
    if (camera->AddPendingResult(PendingResultType::START_RECORD,
                                 std::move(result))) {
      auto str_path = std::string(path);
      auto cc = camera->GetCaptureController();
      assert(cc);
      cc->StartRecord(str_path, max_video_duration_ms);
    }
  } else {
    return result->Error("System error",
                         "Failed to get path for video capture");
  }
}

void CameraPlugin::StopVideoRecordingMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  auto camera = GetCameraByCameraId(*camera_id);
  if (!camera) {
    return result->Error("Camera not created", "Please create camera first");
  }

  if (camera->HasPendingResultByType(PendingResultType::STOP_RECORD)) {
    return result->Error("Failed to stop video recording",
                         "Video recording stopping already");
  }

  if (camera->AddPendingResult(PendingResultType::STOP_RECORD,
                               std::move(result))) {
    auto cc = camera->GetCaptureController();
    assert(cc);
    cc->StopRecord();
  }
}

void CameraPlugin::TakePictureMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  auto camera = GetCameraByCameraId(*camera_id);
  if (!camera) {
    return result->Error("Camera not created", "Please create camera first");
  }

  if (camera->HasPendingResultByType(PendingResultType::TAKE_PICTURE)) {
    return result->Error("Taking picture failed", "Picture already requested");
  }

  std::string path;
  if (GetFilePathForPicture(path)) {
    if (camera->AddPendingResult(PendingResultType::TAKE_PICTURE,
                                 std::move(result))) {
      auto cc = camera->GetCaptureController();
      assert(cc);
      cc->TakePicture(path);
    }
  } else {
    return result->Error("Taking picture failed", "Failed to get proper path");
  }
}

void CameraPlugin::DisposeMethodHandler(
    const EncodableMap &args, std::unique_ptr<flutter::MethodResult<>> result) {
  auto camera_id = std::get_if<std::int64_t>(ValueOrNull(args, kCameraIdKey));
  if (!camera_id) {
    return result->Error("Argument error",
                         std::string(kCameraIdKey) + " missing");
  }

  DisposeCameraByCameraId(*camera_id);
  result->Success();
}

}  // namespace camera_windows
