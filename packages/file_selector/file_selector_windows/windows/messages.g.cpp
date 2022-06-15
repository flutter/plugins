// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v3.1.4), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#include "messages.g.h"

#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <optional>
#include <string>

namespace file_selector_windows {

/* TypeGroup */

const std::string& TypeGroup::label() const { return label_; }
void TypeGroup::set_label(std::string_view value_arg) { label_ = value_arg; }

const flutter::EncodableList& TypeGroup::extensions() const {
  return extensions_;
}
void TypeGroup::set_extensions(const flutter::EncodableList& value_arg) {
  extensions_ = value_arg;
}

flutter::EncodableMap TypeGroup::ToEncodableMap() const {
  return flutter::EncodableMap{
      {flutter::EncodableValue("label"), flutter::EncodableValue(label_)},
      {flutter::EncodableValue("extensions"),
       flutter::EncodableValue(extensions_)},
  };
}

TypeGroup::TypeGroup() {}

TypeGroup::TypeGroup(flutter::EncodableMap map) {
  auto encodable_label = map.at(flutter::EncodableValue("label"));
  if (const std::string* pointer_label =
          std::get_if<std::string>(&encodable_label)) {
    label_ = *pointer_label;
  }
  auto encodable_extensions = map.at(flutter::EncodableValue("extensions"));
  if (const flutter::EncodableList* pointer_extensions =
          std::get_if<flutter::EncodableList>(&encodable_extensions)) {
    extensions_ = *pointer_extensions;
  }
}

/* SelectionOptions */

bool SelectionOptions::allow_multiple() const { return allow_multiple_; }
void SelectionOptions::set_allow_multiple(bool value_arg) {
  allow_multiple_ = value_arg;
}

bool SelectionOptions::select_folders() const { return select_folders_; }
void SelectionOptions::set_select_folders(bool value_arg) {
  select_folders_ = value_arg;
}

const flutter::EncodableList& SelectionOptions::allowed_types() const {
  return allowed_types_;
}
void SelectionOptions::set_allowed_types(
    const flutter::EncodableList& value_arg) {
  allowed_types_ = value_arg;
}

flutter::EncodableMap SelectionOptions::ToEncodableMap() const {
  return flutter::EncodableMap{
      {flutter::EncodableValue("allowMultiple"),
       flutter::EncodableValue(allow_multiple_)},
      {flutter::EncodableValue("selectFolders"),
       flutter::EncodableValue(select_folders_)},
      {flutter::EncodableValue("allowedTypes"),
       flutter::EncodableValue(allowed_types_)},
  };
}

SelectionOptions::SelectionOptions() {}

SelectionOptions::SelectionOptions(flutter::EncodableMap map) {
  auto encodable_allow_multiple =
      map.at(flutter::EncodableValue("allowMultiple"));
  if (const bool* pointer_allow_multiple =
          std::get_if<bool>(&encodable_allow_multiple)) {
    allow_multiple_ = *pointer_allow_multiple;
  }
  auto encodable_select_folders =
      map.at(flutter::EncodableValue("selectFolders"));
  if (const bool* pointer_select_folders =
          std::get_if<bool>(&encodable_select_folders)) {
    select_folders_ = *pointer_select_folders;
  }
  auto encodable_allowed_types =
      map.at(flutter::EncodableValue("allowedTypes"));
  if (const flutter::EncodableList* pointer_allowed_types =
          std::get_if<flutter::EncodableList>(&encodable_allowed_types)) {
    allowed_types_ = *pointer_allowed_types;
  }
}

FileSelectorApiCodecSerializer::FileSelectorApiCodecSerializer() {}
flutter::EncodableValue FileSelectorApiCodecSerializer::ReadValueOfType(
    uint8_t type, flutter::ByteStreamReader* stream) const {
  switch (type) {
    case 128:
      return flutter::CustomEncodableValue(
          SelectionOptions(std::get<flutter::EncodableMap>(ReadValue(stream))));

    case 129:
      return flutter::CustomEncodableValue(
          TypeGroup(std::get<flutter::EncodableMap>(ReadValue(stream))));

    default:
      return flutter::StandardCodecSerializer::ReadValueOfType(type, stream);
  }
}

void FileSelectorApiCodecSerializer::WriteValue(
    const flutter::EncodableValue& value,
    flutter::ByteStreamWriter* stream) const {
  if (const flutter::CustomEncodableValue* custom_value =
          std::get_if<flutter::CustomEncodableValue>(&value)) {
    if (custom_value->type() == typeid(SelectionOptions)) {
      stream->WriteByte(128);
      WriteValue(
          std::any_cast<SelectionOptions>(*custom_value).ToEncodableMap(),
          stream);
      return;
    }
    if (custom_value->type() == typeid(TypeGroup)) {
      stream->WriteByte(129);
      WriteValue(std::any_cast<TypeGroup>(*custom_value).ToEncodableMap(),
                 stream);
      return;
    }
  }
  flutter::StandardCodecSerializer::WriteValue(value, stream);
}

/** The codec used by FileSelectorApi. */
const flutter::StandardMessageCodec& FileSelectorApi::GetCodec() {
  return flutter::StandardMessageCodec::GetInstance(
      &FileSelectorApiCodecSerializer::GetInstance());
}

/** Sets up an instance of `FileSelectorApi` to handle messages through the
 * `binary_messenger`. */
void FileSelectorApi::SetUp(flutter::BinaryMessenger* binary_messenger,
                            FileSelectorApi* api) {
  {
    auto channel =
        std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
            binary_messenger,
            "dev.flutter.pigeon.FileSelectorApi.showOpenDialog", &GetCodec());
    if (api != nullptr) {
      channel->SetMessageHandler(
          [api](const flutter::EncodableValue& message,
                const flutter::MessageReply<flutter::EncodableValue>& reply) {
            flutter::EncodableMap wrapped;
            try {
              auto args = std::get<flutter::EncodableList>(message);
              auto encodable_options_arg = args.at(0);
              if (encodable_options_arg.IsNull()) {
                wrapped.insert(std::make_pair(
                    flutter::EncodableValue("error"),
                    WrapError("options_arg unexpectedly null.")));
                reply(wrapped);
                return;
              }
              const SelectionOptions& options_arg =
                  std::any_cast<const SelectionOptions&>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_options_arg));
              auto& encodable_initial_directory_arg = args.at(1);
              std::optional<std::string> initial_directory_arg =
                  std::any_cast<std::optional<std::string>>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_initial_directory_arg));
              auto& encodable_confirm_button_text_arg = args.at(2);
              std::optional<std::string> confirm_button_text_arg =
                  std::any_cast<std::optional<std::string>>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_confirm_button_text_arg));
              ErrorOr<flutter::EncodableList> output =
                  api->ShowOpenDialog(options_arg, initial_directory_arg,
                                      confirm_button_text_arg);
              if (output.hasError()) {
                wrapped.insert(std::make_pair(flutter::EncodableValue("error"),
                                              WrapError(output.error())));
              } else {
                  wrapped.insert(std::make_pair(
                      flutter::EncodableValue("result"),
                      flutter::EncodableValue(std::move(output).TakeValue())));
              }
            } catch (const std::exception& exception) {
              wrapped.insert(std::make_pair(flutter::EncodableValue("error"),
                                            WrapError(exception.what())));
            }
            reply(wrapped);
          });
    } else {
      channel->SetMessageHandler(nullptr);
    }
  }
  {
    auto channel =
        std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
            binary_messenger,
            "dev.flutter.pigeon.FileSelectorApi.showSaveDialog", &GetCodec());
    if (api != nullptr) {
      channel->SetMessageHandler(
          [api](const flutter::EncodableValue& message,
                const flutter::MessageReply<flutter::EncodableValue>& reply) {
            flutter::EncodableMap wrapped;
            try {
              auto args = std::get<flutter::EncodableList>(message);
              auto encodable_options_arg = args.at(0);
              if (encodable_options_arg.IsNull()) {
                wrapped.insert(std::make_pair(
                    flutter::EncodableValue("error"),
                    WrapError("options_arg unexpectedly null.")));
                reply(wrapped);
                return;
              }
              const SelectionOptions& options_arg =
                  std::any_cast<const SelectionOptions&>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_options_arg));
              auto encodable_initial_directory_arg = args.at(1);
              std::optional<std::string> initial_directory_arg =
                  std::any_cast<std::optional<std::string>>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_initial_directory_arg));
              auto encodable_suggested_name_arg = args.at(2);
              std::optional<std::string> suggested_name_arg =
                  std::any_cast<std::optional<std::string>>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_suggested_name_arg));
              auto encodable_confirm_button_text_arg = args.at(3);
              std::optional<std::string> confirm_button_text_arg =
                  std::any_cast<std::optional<std::string>>(
                      std::get<flutter::CustomEncodableValue>(
                          encodable_confirm_button_text_arg));
              ErrorOr<flutter::EncodableList> output =
                  api->ShowSaveDialog(options_arg, initial_directory_arg,
                                      suggested_name_arg,
                                      confirm_button_text_arg);
              if (output.hasError()) {
                wrapped.insert(std::make_pair(flutter::EncodableValue("error"),
                                              WrapError(output.error())));
              } else {
                wrapped.insert(std::make_pair(flutter::EncodableValue("result"),
                                              flutter::EncodableValue(std::move(output).TakeValue())));
              }
            } catch (const std::exception& exception) {
              wrapped.insert(std::make_pair(flutter::EncodableValue("error"),
                                            WrapError(exception.what())));
            }
            reply(wrapped);
          });
    } else {
      channel->SetMessageHandler(nullptr);
    }
  }
}

flutter::EncodableMap FileSelectorApi::WrapError(
    std::string_view error_message) {
  return flutter::EncodableMap(
      {{flutter::EncodableValue("message"),
        flutter::EncodableValue(std::string(error_message))},
       {flutter::EncodableValue("code"), flutter::EncodableValue("Error")},
       {flutter::EncodableValue("details"), flutter::EncodableValue()}});
}
flutter::EncodableMap FileSelectorApi::WrapError(const FlutterError& error) {
  return flutter::EncodableMap(
      {{flutter::EncodableValue("message"),
        flutter::EncodableValue(error.message)},
       {flutter::EncodableValue("code"), flutter::EncodableValue(error.code)},
       {flutter::EncodableValue("details"), error.details}});
}

}  // namespace file_selector_windows
