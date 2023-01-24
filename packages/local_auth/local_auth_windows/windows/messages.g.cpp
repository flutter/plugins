// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v5.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#undef _HAS_EXCEPTIONS

#include "messages.g.h"

#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <optional>
#include <string>

namespace local_auth_windows {
/// The codec used by LocalAuthApi.
const flutter::StandardMessageCodec& LocalAuthApi::GetCodec() {
  return flutter::StandardMessageCodec::GetInstance(
      &flutter::StandardCodecSerializer::GetInstance());
}

// Sets up an instance of `LocalAuthApi` to handle messages through the
// `binary_messenger`.
void LocalAuthApi::SetUp(flutter::BinaryMessenger* binary_messenger,
                         LocalAuthApi* api) {
  {
    auto channel =
        std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
            binary_messenger,
            "dev.flutter.pigeon.LocalAuthApi.isDeviceSupported", &GetCodec());
    if (api != nullptr) {
      channel->SetMessageHandler(
          [api](const flutter::EncodableValue& message,
                const flutter::MessageReply<flutter::EncodableValue>& reply) {
            try {
              api->IsDeviceSupported([reply](ErrorOr<bool>&& output) {
                if (output.has_error()) {
                  reply(WrapError(output.error()));
                  return;
                }
                flutter::EncodableList wrapped;
                wrapped.push_back(
                    flutter::EncodableValue(std::move(output).TakeValue()));
                reply(flutter::EncodableValue(std::move(wrapped)));
              });
            } catch (const std::exception& exception) {
              reply(WrapError(exception.what()));
            }
          });
    } else {
      channel->SetMessageHandler(nullptr);
    }
  }
  {
    auto channel =
        std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
            binary_messenger, "dev.flutter.pigeon.LocalAuthApi.authenticate",
            &GetCodec());
    if (api != nullptr) {
      channel->SetMessageHandler(
          [api](const flutter::EncodableValue& message,
                const flutter::MessageReply<flutter::EncodableValue>& reply) {
            try {
              const auto& args = std::get<flutter::EncodableList>(message);
              const auto& encodable_localized_reason_arg = args.at(0);
              if (encodable_localized_reason_arg.IsNull()) {
                reply(WrapError("localized_reason_arg unexpectedly null."));
                return;
              }
              const auto& localized_reason_arg =
                  std::get<std::string>(encodable_localized_reason_arg);
              api->Authenticate(
                  localized_reason_arg, [reply](ErrorOr<bool>&& output) {
                    if (output.has_error()) {
                      reply(WrapError(output.error()));
                      return;
                    }
                    flutter::EncodableList wrapped;
                    wrapped.push_back(
                        flutter::EncodableValue(std::move(output).TakeValue()));
                    reply(flutter::EncodableValue(std::move(wrapped)));
                  });
            } catch (const std::exception& exception) {
              reply(WrapError(exception.what()));
            }
          });
    } else {
      channel->SetMessageHandler(nullptr);
    }
  }
}

flutter::EncodableValue LocalAuthApi::WrapError(
    std::string_view error_message) {
  return flutter::EncodableValue(flutter::EncodableList{
      flutter::EncodableValue(std::string(error_message)),
      flutter::EncodableValue("Error"), flutter::EncodableValue()});
}
flutter::EncodableValue LocalAuthApi::WrapError(const FlutterError& error) {
  return flutter::EncodableValue(flutter::EncodableList{
      flutter::EncodableValue(error.message()),
      flutter::EncodableValue(error.code()), error.details()});
}

}  // namespace local_auth_windows
